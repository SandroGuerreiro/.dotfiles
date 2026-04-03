#!/usr/bin/env python3
"""
get-slack-creds.py
Extracts Slack session credentials from Brave or Chrome on macOS.
Outputs to stdout only — nothing is written to disk.

Usage:
  python3 get-slack-creds.py
    → prints SLACK_XOXC and SLACK_COOKIE to stdout

  python3 get-slack-creds.py --fetch <slack_api_endpoint> [param=value ...]
    → fetches a Slack API endpoint using extracted credentials and prints JSON
    Examples:
      python3 get-slack-creds.py --fetch conversations.replies channel=CHANNEL_ID ts=THREAD_TS
      python3 get-slack-creds.py --fetch conversations.history channel=CHANNEL_ID oldest=TS limit=10
"""

import hashlib
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.parse
import urllib.request

BROWSERS = [
    {
        "app_name": "Brave Browser",
        "keychain_service": "Brave Safe Storage",
        "cookies_db": os.path.expanduser(
            "~/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies"
        ),
    },
    {
        "app_name": "Google Chrome",
        "keychain_service": "Chrome Safe Storage",
        "cookies_db": os.path.expanduser(
            "~/Library/Application Support/Google/Chrome/Default/Cookies"
        ),
    },
]


def get_xoxc(app_name):
    js = (
        "(() => { try {"
        " const t = JSON.parse(localStorage.localConfig_v2).teams;"
        " return t[Object.keys(t)[0]].token;"
        "} catch(e) { return ''; } })()"
    )
    # Search all windows and tabs, not just the active one
    script = f"""
tell application "{app_name}"
    set tokenFound to ""
    repeat with w in windows
        repeat with t in tabs of w
            try
                set r to execute t javascript "{js}"
                if r starts with "xoxc-" then
                    set tokenFound to r
                    exit repeat
                end if
            end try
        end repeat
        if tokenFound is not "" then exit repeat
    end repeat
    return tokenFound
end tell
"""
    result = subprocess.run(["osascript", "-e", script], capture_output=True, text=True)
    token = result.stdout.strip()
    return token if token.startswith("xoxc-") else None


def get_keychain_password(service):
    result = subprocess.run(
        ["security", "find-generic-password", "-w", "-s", service],
        capture_output=True, text=True,
    )
    return result.stdout.strip() or None


def derive_key(password):
    return hashlib.pbkdf2_hmac("sha1", password.encode(), b"saltysalt", 1003, dklen=16)


def decrypt(encrypted, key):
    if not encrypted or bytes(encrypted[:3]) != b"v10":
        return None

    payload = bytes(encrypted[3:])
    iv = b" " * 16

    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".bin")
    try:
        tmp.write(payload)
        tmp.flush()
        tmp.close()
        result = subprocess.run(
            ["openssl", "enc", "-d", "-aes-128-cbc", "-nosalt", "-nopad",
             "-K", key.hex(), "-iv", iv.hex(), "-in", tmp.name],
            capture_output=True,
        )
        if result.returncode != 0 or not result.stdout:
            return None
        decrypted = result.stdout
        pad = decrypted[-1]
        if 1 <= pad <= 16:
            decrypted = decrypted[:-pad]
        text = decrypted.decode("utf-8", errors="ignore")
        # AES-CBC first block can be garbled if the IV is slightly off;
        # the xoxd- token always starts at a known marker so extract from there.
        if "xoxd-" in text:
            return "xoxd-" + text.split("xoxd-", 1)[1]
        return text
    finally:
        os.unlink(tmp.name)


def get_d_cookie(cookies_db, key):
    tmp_db = tempfile.mktemp(suffix=".db")
    try:
        shutil.copy2(cookies_db, tmp_db)
        conn = sqlite3.connect(tmp_db)
        row = conn.execute(
            "SELECT encrypted_value FROM cookies WHERE host_key LIKE '%.slack.com' AND name = 'd'"
        ).fetchone()
        conn.close()
        return decrypt(row[0], key) if row else None
    finally:
        if os.path.exists(tmp_db):
            os.unlink(tmp_db)


def open_slack_and_wait(app_name, timeout=180):
    """Open app.slack.com and poll until the xoxc token is available (handles login flows)."""
    print(f"No Slack tab found — opening app.slack.com in {app_name}...", file=sys.stderr)
    print("If you need to log in, do so now. Waiting up to 3 minutes...", file=sys.stderr)
    subprocess.run(["open", "-a", app_name, "https://app.slack.com"], capture_output=True)
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(3)
        token = get_xoxc(app_name)
        if token:
            return True
    return False


def get_credentials():
    for browser in BROWSERS:
        if not os.path.exists(browser["cookies_db"]):
            continue

        xoxc = get_xoxc(browser["app_name"])

        if not xoxc:
            # Try opening Slack and retrying once (handles login flows too)
            if open_slack_and_wait(browser["app_name"]):
                xoxc = get_xoxc(browser["app_name"])

        if not xoxc:
            continue

        password = get_keychain_password(browser["keychain_service"])
        if not password:
            sys.exit(f"ERROR: Could not read '{browser['keychain_service']}' from Keychain.\nGo to System Settings → Privacy & Security → Full Disk Access and add Terminal/iTerm.")

        key = derive_key(password)
        d_cookie = get_d_cookie(browser["cookies_db"], key)
        if not d_cookie:
            sys.exit(f"ERROR: Could not decrypt Slack 'd' cookie from {browser['app_name']}.")

        return xoxc, d_cookie

    sys.exit("ERROR: Could not find or open Slack in any supported browser.")


def slack_fetch(endpoint, params, xoxc, d_cookie):
    url = f"https://slack.com/api/{endpoint}?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {xoxc}")
    req.add_header("Cookie", f"d={d_cookie}")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())


def main():
    if len(sys.argv) >= 3 and sys.argv[1] == "--fetch":
        endpoint = sys.argv[2]
        params = dict(arg.split("=", 1) for arg in sys.argv[3:])
        xoxc, d_cookie = get_credentials()
        result = slack_fetch(endpoint, params, xoxc, d_cookie)
        print(json.dumps(result, indent=2))
        return

    xoxc, d_cookie = get_credentials()
    print(f"SLACK_XOXC={xoxc}")
    print(f"SLACK_COOKIE=d={d_cookie}")


if __name__ == "__main__":
    main()
