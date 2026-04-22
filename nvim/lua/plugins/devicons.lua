return {
	"nvim-tree/nvim-web-devicons",
	opts = {
		override_by_extension = {
			-- TypeScript / JavaScript
			["tsx"] = { icon = "", color = "#519aba", cterm_color = "74", name = "Tsx" },
			["jsx"] = { icon = "", color = "#519aba", cterm_color = "74", name = "Jsx" },
			["mjs"] = { icon = "", color = "#cbcb41", cterm_color = "185", name = "Mjs" },
			-- Python
			["py"]  = { icon = "", color = "#519aba", cterm_color = "74", name = "Py" },
			["pyw"] = { icon = "", color = "#519aba", cterm_color = "74", name = "Pyw" },
			-- Ruby
			["rb"]  = { icon = "", color = "#cc3e44", cterm_color = "167", name = "Rb" },
			-- Systems
			["c"]   = { icon = "", color = "#519aba", cterm_color = "74", name = "C" },
			["cs"]  = { icon = "󰌛", color = "#519aba", cterm_color = "74", name = "Cs" },
			["go"]  = { icon = "", color = "#519aba", cterm_color = "74", name = "Go" },
			["rs"]  = { icon = "", color = "#6d8086", cterm_color = "66", name = "Rs" },
			["kt"]  = { icon = "", color = "#e37933", cterm_color = "208", name = "Kotlin" },
			["dart"] = { icon = "", color = "#519aba", cterm_color = "74", name = "Dart" },
			-- Web
			["html"] = { icon = "", color = "#e37933", cterm_color = "208", name = "Html" },
			["htm"]  = { icon = "", color = "#e37933", cterm_color = "208", name = "Htm" },
			["css"]  = { icon = "", color = "#519aba", cterm_color = "74", name = "Css" },
			["less"] = { icon = "", color = "#519aba", cterm_color = "74", name = "Less" },
			-- Shell
			["sh"]   = { icon = "", color = "#8dc149", cterm_color = "113", name = "Sh" },
			["bash"] = { icon = "", color = "#8dc149", cterm_color = "113", name = "Bash" },
			["zsh"]  = { icon = "", color = "#8dc149", cterm_color = "113", name = "Zsh" },
			["fish"] = { icon = "", color = "#8dc149", cterm_color = "113", name = "Fish" },
			-- Data / Query
			["sql"]     = { icon = "", color = "#f55385", cterm_color = "204", name = "Sql" },
			["graphql"] = { icon = "", color = "#f55385", cterm_color = "204", name = "GraphQL" },
			["gql"]     = { icon = "", color = "#f55385", cterm_color = "204", name = "GraphQL" },
			-- Config / Markup
			["yaml"] = { icon = "", color = "#a074c4", cterm_color = "140", name = "Yaml" },
			["yml"]  = { icon = "", color = "#a074c4", cterm_color = "140", name = "Yml" },
			["toml"] = { icon = "", color = "#6d8086", cterm_color = "66", name = "Toml" },
			["md"]   = { icon = "", color = "#519aba", cterm_color = "74", name = "Md" },
			-- Frameworks
			["svelte"]  = { icon = "", color = "#cc3e44", cterm_color = "167", name = "Svelte" },
			["prisma"]  = { icon = "", color = "#519aba", cterm_color = "74", name = "Prisma" },
			-- R
			["r"] = { icon = "󰟔", color = "#519aba", cterm_color = "74", name = "R" },
			["R"] = { icon = "󰟔", color = "#519aba", cterm_color = "74", name = "R" },
			-- Certs / Keys
			["pem"]  = { icon = "", color = "#8dc149", cterm_color = "113", name = "Pem" },
			["key"]  = { icon = "", color = "#8dc149", cterm_color = "113", name = "Key" },
			["cert"] = { icon = "", color = "#8dc149", cterm_color = "113", name = "Cert" },
			["crt"]  = { icon = "", color = "#8dc149", cterm_color = "113", name = "Crt" },
			-- Env
			["env"] = { icon = "", color = "#6d8086", cterm_color = "66", name = "Env" },
		},
		override_by_filename = {
			["package.json"]         = { icon = "", color = "#e37933", cterm_color = "208", name = "PackageJson" },
			["package-lock.json"]    = { icon = "", color = "#cc3e44", cterm_color = "167", name = "PackageLockJson" },
			[".gitignore"]           = { icon = "", color = "#41535b", cterm_color = "240", name = "GitIgnore" },
			[".gitconfig"]           = { icon = "", color = "#41535b", cterm_color = "240", name = "GitConfig" },
			[".env"]                 = { icon = "", color = "#6d8086", cterm_color = "66", name = "Env" },
			["dockerfile"]           = { icon = "󰡨", color = "#519aba", cterm_color = "74", name = "Dockerfile" },
			["docker-compose.yml"]   = { icon = "󰡨", color = "#519aba", cterm_color = "74", name = "DockerCompose" },
			["docker-compose.yaml"]  = { icon = "󰡨", color = "#519aba", cterm_color = "74", name = "DockerCompose" },
			["makefile"]             = { icon = "", color = "#e37933", cterm_color = "208", name = "Makefile" },
			["gnumakefile"]          = { icon = "", color = "#e37933", cterm_color = "208", name = "Makefile" },
			["cargo.toml"]           = { icon = "", color = "#6d8086", cterm_color = "66", name = "CargoToml" },
			["go.mod"]               = { icon = "", color = "#519aba", cterm_color = "74", name = "GoMod" },
			["go.sum"]               = { icon = "", color = "#519aba", cterm_color = "74", name = "GoSum" },
		},
	},
}
