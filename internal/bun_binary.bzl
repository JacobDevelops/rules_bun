"""Rule for running JS/TS scripts with Bun."""

load("//internal:js_library.bzl", "collect_js_runfiles")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")

def _shell_quote(value):
    return "'" + value.replace("'", "'\"'\"'") + "'"

def _bun_binary_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    entry_point = ctx.file.entry_point
    dep_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.data + [bun_bin],
        primary_file = entry_point,
    )

    command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_exec_dir}"
exec "${bun_bin}" --bun run "${primary_source}" "$@"
"""
    if ctx.attr.args:
        command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_exec_dir}"
exec "${bun_bin}" --bun run "${primary_source}" __DEFAULT_ARGS__ "$@"
""".replace("__DEFAULT_ARGS__", " ".join([_shell_quote(arg) for arg in ctx.attr.args]))

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = render_workspace_setup(
            bun_short_path = bun_bin.short_path,
            primary_source_short_path = entry_point.short_path,
            working_dir_mode = ctx.attr.working_dir,
        ) + command,
    )

    return [
        workspace_info,
        DefaultInfo(
            executable = launcher,
            runfiles = workspace_runfiles(
                ctx,
                workspace_info,
                direct_files = [launcher],
                transitive_files = dep_runfiles,
            ),
        ),
    ]


bun_binary = rule(
    implementation = _bun_binary_impl,
    doc = """Runs a JS/TS entry point with Bun as an executable target.

Use this rule for non-test scripts and CLIs that should run via `bazel run`.
""",
    attrs = {
        "entry_point": attr.label(
            mandatory = True,
            allow_single_file = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs"],
            doc = "Path to the main JS/TS file to execute.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a `node_modules` tree, typically produced by `bun_install`, in runfiles.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional runtime files required by the program.",
        ),
        "deps": attr.label_list(
            doc = "Library dependencies required by the program.",
        ),
        "working_dir": attr.string(
            default = "workspace",
            values = ["workspace", "entry_point"],
            doc = "Working directory at runtime: `workspace` root or nearest `entry_point` ancestor containing `.env`/`package.json`.",
        ),
    },
    executable = True,
    toolchains = ["//bun:toolchain_type"],
)
