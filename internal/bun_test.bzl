"""Rule for running test suites with Bun."""

load("//internal:js_library.bzl", "collect_js_runfiles")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")


def _shell_quote(value):
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _bun_test_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    primary_file = ctx.files.srcs[0]
    dep_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.srcs + ctx.files.data + [bun_bin],
        primary_file = primary_file,
    )

    src_args = " ".join([_shell_quote(src.short_path) for src in ctx.files.srcs])
    command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_workspace}"
test_args=(__SRC_ARGS__)

if [[ -n "${TESTBRIDGE_TEST_ONLY:-}" && -n "${COVERAGE_DIR:-}" ]]; then
    exec "${bun_bin}" --bun test "${test_args[@]}" --test-name-pattern "${TESTBRIDGE_TEST_ONLY}" --coverage "$@"
fi
if [[ -n "${TESTBRIDGE_TEST_ONLY:-}" ]]; then
    exec "${bun_bin}" --bun test "${test_args[@]}" --test-name-pattern "${TESTBRIDGE_TEST_ONLY}" "$@"
fi
if [[ -n "${COVERAGE_DIR:-}" ]]; then
    exec "${bun_bin}" --bun test "${test_args[@]}" --coverage "$@"
fi
exec "${bun_bin}" --bun test "${test_args[@]}" "$@"
""".replace("__SRC_ARGS__", src_args)
    if ctx.attr.args:
        default_args = "\n".join(['test_args+=({})'.format(_shell_quote(arg)) for arg in ctx.attr.args])
        command = command.replace(
            'test_args=(__SRC_ARGS__)',
            'test_args=(__SRC_ARGS__)\n' + default_args,
        )

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = render_workspace_setup(
            bun_short_path = bun_bin.short_path,
            primary_source_short_path = primary_file.short_path,
            working_dir_mode = "workspace",
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


bun_test = rule(
    implementation = _bun_test_impl,
    doc = """Runs Bun tests as a Bazel test target.

Supports Bazel test filtering (`--test_filter`) and coverage integration.
""",
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs"],
            doc = "Test source files passed to `bun test`.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a `node_modules` tree, typically produced by `bun_install`, in runfiles.",
        ),
        "deps": attr.label_list(
            doc = "Library dependencies required by test sources.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional runtime files needed by tests.",
        ),
    },
    test = True,
    toolchains = ["//bun:toolchain_type"],
)
