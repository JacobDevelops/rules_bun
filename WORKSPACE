workspace(name = "rules_bun")

load("//internal:bun_install.bzl", "bun_install")
load("//bun:repositories.bzl", "bun_register_toolchains")

bun_register_toolchains()

bun_install(
	name = "script_test_vite_node_modules",
	package_json = "//tests/script_test:vite_app/package.json",
	bun_lockfile = "//tests/script_test:vite_app/bun.lock",
)

bun_install(
	name = "script_test_vite_monorepo_node_modules",
	package_json = "//tests/script_test:vite_monorepo/package.json",
	bun_lockfile = "//tests/script_test:vite_monorepo/bun.lock",
)

bun_install(
	name = "examples_vite_monorepo_node_modules",
	package_json = "//examples/vite_monorepo:package.json",
	bun_lockfile = "//examples/vite_monorepo:bun.lock",
)
