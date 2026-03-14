load("//internal:bun_install.bzl", "bun_install_repository")

_translate = tag_class(
    attrs = {
        "name": attr.string(mandatory = True),
        "package_json": attr.label(mandatory = True),
        "lockfile": attr.label(mandatory = True),
        "install_inputs": attr.label_list(allow_files = True),
        "isolated_home": attr.bool(default = True),
    },
)

def _npm_translate_lock_impl(ctx):
    for mod in ctx.modules:
        for install in mod.tags.translate:
            bun_install_repository(
                name = install.name,
                package_json = install.package_json,
                bun_lockfile = install.lockfile,
                install_inputs = install.install_inputs,
                isolated_home = install.isolated_home,
                visible_repo_name = install.name,
            )

npm_translate_lock = module_extension(
    implementation = _npm_translate_lock_impl,
    tag_classes = {"translate": _translate},
)
