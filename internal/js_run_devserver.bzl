"""Compatibility rule for running an executable target as a dev server."""

load("//internal:js_library.bzl", "collect_js_runfiles")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")

def _shell_quote(value):
    return "'" + value.replace("'", "'\"'\"'") + "'"

def _js_run_devserver_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    package_json = ctx.file.package_json
    dep_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]
    tool_default_info = ctx.attr.tool[DefaultInfo]

    workspace_info = create_bun_workspace_info(
        ctx,
        primary_file = package_json or tool_default_info.files_to_run.executable,
        package_json = package_json,
        package_dir_hint = ctx.attr.package_dir_hint,
        extra_files = ctx.files.data + [bun_bin, tool_default_info.files_to_run.executable],
    )

    tool_workspace = ctx.attr.tool.label.workspace_name or "_main"
    tool_path = "{}/{}".format(tool_workspace, tool_default_info.files_to_run.executable.short_path)
    default_args = " ".join([_shell_quote(arg) for arg in ctx.attr.args])

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = render_workspace_setup(
            bun_short_path = bun_bin.short_path,
            install_metadata_short_path = workspace_info.install_metadata_file.short_path if workspace_info.install_metadata_file else "",
            primary_source_short_path = package_json.short_path if package_json else tool_default_info.files_to_run.executable.short_path,
            package_json_short_path = package_json.short_path if package_json else "",
            package_dir_hint = ctx.attr.package_dir_hint,
            working_dir_mode = ctx.attr.working_dir,
        ) + """
trap cleanup_runtime_workspace EXIT
cd "${runtime_exec_dir}"
tool="${runfiles_dir}/__TOOL_SHORT_PATH__"
exec "${tool}" __DEFAULT_ARGS__ "$@"
""".replace("__TOOL_SHORT_PATH__", tool_path).replace("__DEFAULT_ARGS__", default_args),
    )

    return [
        workspace_info,
        DefaultInfo(
            executable = launcher,
            runfiles = workspace_runfiles(
                ctx,
                workspace_info,
                direct_files = [launcher, tool_default_info.files_to_run.executable],
                transitive_files = dep_runfiles,
            ).merge(tool_default_info.default_runfiles),
        ),
    ]

js_run_devserver = rule(
    implementation = _js_run_devserver_impl,
    doc = """Runs an executable target from a staged JS workspace.

This is a Bun-backed compatibility adapter for `rules_js`-style devserver
targets. It stages the same runtime workspace as the Bun rules, then executes
the provided tool with any default arguments.
""",
    attrs = {
        "tool": attr.label(
            mandatory = True,
            executable = True,
            cfg = "target",
            doc = "Executable target to launch as the dev server.",
        ),
        "package_json": attr.label(
            allow_single_file = True,
            doc = "Optional package.json used to resolve the package working directory.",
        ),
        "package_dir_hint": attr.string(
            default = ".",
            doc = "Optional package-relative directory hint when package_json is not supplied.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a node_modules tree, typically produced by bun_install or npm_translate_lock, in runfiles.",
        ),
        "deps": attr.label_list(
            doc = "Library dependencies required by the dev server.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional runtime files required by the dev server.",
        ),
        "working_dir": attr.string(
            default = "workspace",
            values = ["workspace", "package"],
            doc = "Working directory at runtime: Bazel runfiles workspace root or the resolved package directory.",
        ),
    },
    executable = True,
    toolchains = ["//bun:toolchain_type"],
)
