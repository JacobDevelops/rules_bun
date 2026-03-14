"""Rule for running JS/TS scripts with Bun in watch mode for development."""

load("//internal:bun_command.bzl", "append_shell_flag", "append_shell_flag_files", "append_shell_flag_values", "append_shell_install_mode", "append_shell_raw_flags", "render_shell_array", "shell_quote")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")

def _bun_dev_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    entry_point = ctx.file.entry_point
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.data + ctx.files.restart_on + ctx.files.preload + ctx.files.env_files + [bun_bin],
        primary_file = entry_point,
    )

    restart_watch_paths = "\n".join([path.short_path for path in ctx.files.restart_on])
    launcher_lines = [render_shell_array("bun_args", ["--bun", "run"])]
    append_shell_install_mode(launcher_lines, "bun_args", ctx.attr.install_mode)
    append_shell_flag_files(launcher_lines, "bun_args", "--preload", ctx.files.preload)
    append_shell_flag_files(launcher_lines, "bun_args", "--env-file", ctx.files.env_files)
    append_shell_flag(launcher_lines, "bun_args", "--no-env-file", ctx.attr.no_env_file)
    append_shell_flag(launcher_lines, "bun_args", "--smol", ctx.attr.smol)
    append_shell_flag_values(launcher_lines, "bun_args", "--conditions", ctx.attr.conditions)
    append_shell_flag(launcher_lines, "bun_args", "--no-clear-screen", ctx.attr.no_clear_screen)
    append_shell_raw_flags(launcher_lines, "bun_args", ctx.attr.run_flags)
    launcher_lines.append('bun_args+=("${primary_source}")')
    for arg in ctx.attr.args:
        launcher_lines.append("bun_args+=(%s)" % shell_quote(arg))

    command = """
__BUN_ARGS__
watch_mode="__WATCH_MODE__"
if [[ "${watch_mode}" == "hot" ]]; then
    bun_args+=("--hot")
else
    bun_args+=("--watch")
fi

if [[ __RESTART_COUNT__ -eq 0 ]]; then
    trap cleanup_runtime_workspace EXIT
    cd "${runtime_exec_dir}"
    exec "${bun_bin}" "${bun_args[@]}" "$@"
fi

readarray -t restart_paths <<'EOF_RESTART_PATHS'
__RESTART_PATHS__
EOF_RESTART_PATHS

file_mtime() {
    local path="$1"
    if stat -f '%m' "${path}" >/dev/null 2>&1; then
        stat -f '%m' "${path}"
        return 0
    fi
    stat -c '%Y' "${path}"
}

declare -A mtimes
for rel in "${restart_paths[@]}"; do
    path="${runfiles_dir}/_main/${rel}"
    if [[ -e "${path}" ]]; then
        mtimes["${rel}"]="$(file_mtime "${path}")"
    else
        mtimes["${rel}"]="missing"
    fi
done

child_pid=""
restart_child() {
    if [[ -n "${child_pid}" ]] && kill -0 "${child_pid}" 2>/dev/null; then
        kill "${child_pid}"
        wait "${child_pid}" || true
    fi

    (
        cd "${runtime_exec_dir}"
        exec "${bun_bin}" "${bun_args[@]}" "$@"
    ) &
    child_pid=$!
}

cleanup() {
    if [[ -n "${child_pid}" ]] && kill -0 "${child_pid}" 2>/dev/null; then
        kill "${child_pid}"
        wait "${child_pid}" || true
    fi
    cleanup_runtime_workspace
}

trap cleanup EXIT INT TERM

restart_child "$@"

while true; do
    sleep 1
    changed=0
    for rel in "${restart_paths[@]}"; do
        path="${runfiles_dir}/_main/${rel}"
        if [[ -e "${path}" ]]; then
            current="$(file_mtime "${path}")"
        else
            current="missing"
        fi
        if [[ "${current}" != "${mtimes[${rel}]}" ]]; then
            mtimes["${rel}"]="${current}"
            changed=1
        fi
    done
    if [[ "${changed}" -eq 1 ]]; then
        restart_child "$@"
    fi
done
""".replace("__WATCH_MODE__", ctx.attr.watch_mode).replace(
        "__RESTART_COUNT__",
        str(len(ctx.files.restart_on)),
    ).replace(
        "__RESTART_PATHS__",
        restart_watch_paths,
    ).replace(
        "__BUN_ARGS__",
        "\n".join(launcher_lines),
    )

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
            runfiles = workspace_runfiles(ctx, workspace_info, direct_files = [launcher]),
        ),
    ]

bun_dev = rule(
    implementation = _bun_dev_impl,
    doc = """Runs a JS/TS entry point in Bun development watch mode.

This rule is intended for local dev loops (`bazel run`) and supports Bun
watch/HMR plus optional full restarts on selected file changes.
""",
    attrs = {
        "entry_point": attr.label(
            mandatory = True,
            allow_single_file = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs"],
            doc = "Path to the main JS/TS file to execute in dev mode.",
        ),
        "watch_mode": attr.string(
            default = "watch",
            values = ["watch", "hot"],
            doc = "Bun live-reload mode: `watch` (default) or `hot`.",
        ),
        "restart_on": attr.label_list(
            allow_files = True,
            doc = "Files that trigger a full Bun process restart when they change.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a `node_modules` tree, typically produced by `bun_install`, in runfiles.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional runtime files required by the dev process.",
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
            doc = "Whether Bun may auto-install missing packages in dev mode.",
        ),
        "no_clear_screen": attr.bool(
            default = False,
            doc = "If true, disables terminal clearing on Bun reloads.",
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
