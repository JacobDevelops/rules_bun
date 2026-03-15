"""Rule for running package.json scripts with Bun."""

load("//internal:bun_command.bzl", "append_shell_flag", "append_shell_flag_files", "append_shell_flag_value", "append_shell_flag_values", "append_shell_install_mode", "append_shell_raw_flags", "render_shell_array", "shell_quote")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")


def _bun_script_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    package_json = ctx.file.package_json
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.data + ctx.files.preload + ctx.files.env_files + [bun_bin],
        package_dir_hint = package_json.dirname or ".",
        package_json = package_json,
        primary_file = package_json,
    )

    launcher_lines = [render_shell_array("bun_args", ["--bun", "run"])]
    append_shell_install_mode(launcher_lines, "bun_args", ctx.attr.install_mode)
    append_shell_flag_files(launcher_lines, "bun_args", "--preload", ctx.files.preload)
    append_shell_flag_files(launcher_lines, "bun_args", "--env-file", ctx.files.env_files)
    append_shell_flag(launcher_lines, "bun_args", "--no-env-file", ctx.attr.no_env_file)
    append_shell_flag(launcher_lines, "bun_args", "--smol", ctx.attr.smol)
    append_shell_flag_values(launcher_lines, "bun_args", "--conditions", ctx.attr.conditions)
    append_shell_flag(launcher_lines, "bun_args", "--workspaces", ctx.attr.workspaces)
    append_shell_flag_values(launcher_lines, "bun_args", "--filter", ctx.attr.filters)
    if ctx.attr.execution_mode == "parallel":
        append_shell_flag(launcher_lines, "bun_args", "--parallel", True)
    elif ctx.attr.execution_mode == "sequential":
        append_shell_flag(launcher_lines, "bun_args", "--sequential", True)
    append_shell_flag(launcher_lines, "bun_args", "--no-exit-on-error", ctx.attr.no_exit_on_error)
    append_shell_flag_value(launcher_lines, "bun_args", "--shell", ctx.attr.shell)
    append_shell_flag(launcher_lines, "bun_args", "--silent", ctx.attr.silent)
    append_shell_raw_flags(launcher_lines, "bun_args", ctx.attr.run_flags)
    launcher_lines.append('bun_args+=(%s)' % shell_quote(ctx.attr.script))
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
            package_dir_hint = package_json.dirname or ".",
            package_json_short_path = package_json.short_path,
            primary_source_short_path = package_json.short_path,
            install_metadata_short_path = workspace_info.install_metadata_file.short_path if workspace_info.install_metadata_file else "",
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
        "preload": attr.label_list(
            allow_files = True,
            doc = "Modules to preload with `--preload` before running the script.",
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
            doc = "Whether Bun may auto-install missing packages while running the script.",
        ),
        "filters": attr.string_list(
            doc = "Workspace package filters passed via repeated `--filter` flags.",
        ),
        "workspaces": attr.bool(
            default = False,
            doc = "If true, runs the script in all workspace packages.",
        ),
        "execution_mode": attr.string(
            default = "single",
            values = ["single", "parallel", "sequential"],
            doc = "How Bun should execute matching workspace scripts.",
        ),
        "no_exit_on_error": attr.bool(
            default = False,
            doc = "If true, Bun keeps running other workspace scripts when one fails.",
        ),
        "shell": attr.string(
            default = "",
            values = ["", "bun", "system"],
            doc = "Optional shell implementation for package scripts.",
        ),
        "silent": attr.bool(
            default = False,
            doc = "If true, suppresses Bun's command echo for package scripts.",
        ),
        "run_flags": attr.string_list(
            doc = "Additional raw flags forwarded to `bun run` before the script name.",
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
