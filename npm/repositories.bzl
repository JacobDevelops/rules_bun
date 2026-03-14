load("//internal:bun_install.bzl", "bun_install_repository")

def npm_translate_lock(name, package_json, lockfile, install_inputs = [], isolated_home = True):
    bun_install_repository(
        name = name,
        package_json = package_json,
        bun_lockfile = lockfile,
        install_inputs = install_inputs,
        isolated_home = isolated_home,
        visible_repo_name = name,
    )
