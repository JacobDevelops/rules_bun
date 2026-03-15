"""Rule for running JS/TS scripts with Bun."""

load("//internal:bun_command.bzl", "append_shell_flag", "append_shell_flag_files", "append_shell_flag_values", "append_shell_install_mode", "append_shell_raw_flags", "render_shell_array", "shell_quote")
load("//internal:js_library.bzl", "collect_js_runfiles")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")

def _bun_binary_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    entry_point = ctx.file.entry_point
    dep_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.data + ctx.files.preload + ctx.files.env_files + [bun_bin],
        primary_file = entry_point,
    )

    launcher_lines = [render_shell_array("bun_args", ["--bun", "run"])]
    append_shell_install_mode(launcher_lines, "bun_args", ctx.attr.install_mode)
    append_shell_flag_files(launcher_lines, "bun_args", "--preload", ctx.files.preload)
    append_shell_flag_files(launcher_lines, "bun_args", "--env-file", ctx.files.env_files)
    append_shell_flag(launcher_lines, "bun_args", "--no-env-file", ctx.attr.no_env_file)
    append_shell_flag(launcher_lines, "bun_args", "--smol", ctx.attr.smol)
    append_shell_flag_values(launcher_lines, "bun_args", "--conditions", ctx.attr.conditions)
    append_shell_raw_flags(launcher_lines, "bun_args", ctx.attr.run_flags)
    launcher_lines.append('bun_args+=("${primary_source}")')
    for arg in ctx.attr.args:
        launcher_lines.append("bun_args+=(%s)" % shell_quote(arg))

    command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_exec_dir}"
__BUN_ARGS__
exec "${bun_bin}" "${bun_args[@]}" "$@"
""".replace("__BUN_ARGS__", "\n".join(launcher_lines))

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = render_workspace_setup(
            bun_short_path = bun_bin.short_path,
            install_metadata_short_path = workspace_info.install_metadata_file.short_path if workspace_info.install_metadata_file else "",
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
        "preload": attr.label_list(
            allow_files = True,
            doc = "Modules to preload with `--preload` before running the entry point.",
        ),
        "env_files": attr.label_list(
            allow_files = True,
            doc = "Additional environment files loaded with `--env-file`.",
        ),
        "no_env_file": attr.bool(
            default = False,
            doc = "If true, disables Bun's automatic `.env` loading.",
        ),
        "smol": attr.bool(
            default = False,
            doc = "If true, enables Bun's lower-memory runtime mode.",
        ),
        "conditions": attr.string_list(
            doc = "Custom package resolve conditions passed to Bun.",
        ),
        "install_mode": attr.string(
            default = "disable",
            values = ["disable", "auto", "fallback", "force"],
            doc = "Whether Bun may auto-install missing packages at runtime.",
        ),
        "run_flags": attr.string_list(
            doc = "Additional raw flags forwarded to `bun run` before the entry point.",
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
