"""Rule for running JS/TS scripts with Bun."""


def _bun_binary_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    entry_point = ctx.file.entry_point

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = """#!/usr/bin/env bash
set -euo pipefail

runfiles_dir="${{RUNFILES_DIR:-$0.runfiles}}"
workspace_root="${{runfiles_dir}}/_main"
bun_bin="${{runfiles_dir}}/_main/{bun_short_path}"
entry_point="${{runfiles_dir}}/_main/{entry_short_path}"

resolve_entrypoint_workdir() {{
    local dir
    dir="$(dirname "${{entry_point}}")"
    while [[ "${{dir}}" == "${{workspace_root}}"* ]]; do
        if [[ -f "${{dir}}/.env" || -f "${{dir}}/package.json" ]]; then
            echo "${{dir}}"
            return 0
        fi
        if [[ "${{dir}}" == "${{workspace_root}}" ]]; then
            break
        fi
        dir="$(dirname "${{dir}}")"
    done
    echo "$(dirname "${{entry_point}}")"
}}

working_dir="{working_dir}"
if [[ "${{working_dir}}" == "entry_point" ]]; then
    cd "$(resolve_entrypoint_workdir)"
else
    cd "${{workspace_root}}"
fi

exec "${{bun_bin}}" --bun run "${{entry_point}}" "$@"
""".format(
            bun_short_path = bun_bin.short_path,
            entry_short_path = entry_point.short_path,
            working_dir = ctx.attr.working_dir,
        ),
    )

    transitive_files = []
    if ctx.attr.node_modules:
        transitive_files.append(ctx.attr.node_modules[DefaultInfo].files)

    runfiles = ctx.runfiles(
        files = [bun_bin, entry_point] + ctx.files.data,
        transitive_files = depset(transitive = transitive_files),
    )

    return [
        DefaultInfo(
            executable = launcher,
            runfiles = runfiles,
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
        "working_dir": attr.string(
            default = "workspace",
            values = ["workspace", "entry_point"],
            doc = "Working directory at runtime: `workspace` root or nearest `entry_point` ancestor containing `.env`/`package.json`.",
        ),
    },
    executable = True,
    toolchains = ["//bun:toolchain_type"],
)
