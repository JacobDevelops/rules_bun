"""Rule for running package.json scripts with Bun."""

load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")

def _shell_quote(value):
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _bun_script_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    package_json = ctx.file.package_json
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.data + [bun_bin],
        package_dir_hint = package_json.dirname or ".",
        package_json = package_json,
        primary_file = package_json,
    )
    command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_exec_dir}"
exec "${bun_bin}" --bun run __SCRIPT__ "$@"
""".replace("__SCRIPT__", _shell_quote(ctx.attr.script))

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = render_workspace_setup(
            bun_short_path = bun_bin.short_path,
            package_dir_hint = package_json.dirname or ".",
            package_json_short_path = package_json.short_path,
            primary_source_short_path = package_json.short_path,
            working_dir_mode = ctx.attr.working_dir,
        ) + command,
    )

    return [
        workspace_info,
        DefaultInfo(
            executable = launcher,
            runfiles = workspace_runfiles(ctx, workspace_info, direct_files = [launcher]),
        ),
    ]


bun_script = rule(
    implementation = _bun_script_impl,
    doc = """Runs a named `package.json` script with Bun as an executable target.

Use this rule to expose existing package scripts such as `dev`, `build`, or
`check` via `bazel run` without adding wrapper shell scripts. This is a good fit
for Vite-style workflows, where scripts like `vite dev` or `vite build` are
declared in `package.json` and expect to run from the package directory with
`node_modules/.bin` available on `PATH`.
""",
    attrs = {
        "script": attr.string(
            mandatory = True,
            doc = "Name of the `package.json` script to execute via `bun run <script>`.",
        ),
        "package_json": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Label of the `package.json` file containing the named script.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a `node_modules` tree, typically produced by `bun_install`, in runfiles. Executables from `node_modules/.bin` are added to `PATH`, which is useful for scripts such as `vite`.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional runtime files required by the script.",
        ),
        "working_dir": attr.string(
            default = "package",
            values = ["workspace", "package"],
            doc = "Working directory at runtime: Bazel runfiles `workspace` root or the directory containing `package.json`. The default `package` mode matches tools such as Vite that resolve config and assets relative to the package directory.",
        ),
    },
    executable = True,
    toolchains = ["//bun:toolchain_type"],
)
