"""Rule for running test suites with Bun."""

load("//internal:bun_command.bzl", "append_shell_flag", "append_shell_flag_files", "append_shell_flag_value", "append_shell_flag_values", "append_shell_install_mode", "append_shell_raw_flags", "render_shell_array", "shell_quote")
load("//internal:js_library.bzl", "collect_js_runfiles")
load("//internal:workspace.bzl", "create_bun_workspace_info", "render_workspace_setup", "workspace_runfiles")


def _bun_test_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin
    primary_file = ctx.files.srcs[0]
    dep_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]
    workspace_info = create_bun_workspace_info(
        ctx,
        extra_files = ctx.files.srcs + ctx.files.data + ctx.files.preload + ctx.files.env_files + [bun_bin],
        primary_file = primary_file,
    )

    launcher_lines = [render_shell_array("bun_args", ["--bun", "test"])]
    append_shell_install_mode(launcher_lines, "bun_args", ctx.attr.install_mode)
    append_shell_flag_files(launcher_lines, "bun_args", "--preload", ctx.files.preload)
    append_shell_flag_files(launcher_lines, "bun_args", "--env-file", ctx.files.env_files)
    append_shell_flag(launcher_lines, "bun_args", "--no-env-file", ctx.attr.no_env_file)
    append_shell_flag(launcher_lines, "bun_args", "--smol", ctx.attr.smol)
    append_shell_flag_value(launcher_lines, "bun_args", "--timeout", str(ctx.attr.timeout_ms) if ctx.attr.timeout_ms > 0 else None)
    append_shell_flag(launcher_lines, "bun_args", "--update-snapshots", ctx.attr.update_snapshots)
    append_shell_flag_value(launcher_lines, "bun_args", "--rerun-each", str(ctx.attr.rerun_each) if ctx.attr.rerun_each > 0 else None)
    append_shell_flag_value(launcher_lines, "bun_args", "--retry", str(ctx.attr.retry) if ctx.attr.retry > 0 else None)
    append_shell_flag(launcher_lines, "bun_args", "--todo", ctx.attr.todo)
    append_shell_flag(launcher_lines, "bun_args", "--only", ctx.attr.only)
    append_shell_flag(launcher_lines, "bun_args", "--pass-with-no-tests", ctx.attr.pass_with_no_tests)
    append_shell_flag(launcher_lines, "bun_args", "--concurrent", ctx.attr.concurrent)
    append_shell_flag(launcher_lines, "bun_args", "--randomize", ctx.attr.randomize)
    append_shell_flag_value(launcher_lines, "bun_args", "--seed", str(ctx.attr.seed) if ctx.attr.seed > 0 else None)
    append_shell_flag_value(launcher_lines, "bun_args", "--bail", str(ctx.attr.bail) if ctx.attr.bail > 0 else None)
    append_shell_flag_value(launcher_lines, "bun_args", "--max-concurrency", str(ctx.attr.max_concurrency) if ctx.attr.max_concurrency > 0 else None)
    append_shell_raw_flags(launcher_lines, "bun_args", ctx.attr.test_flags)
    launcher_lines.append('coverage_requested="0"')
    launcher_lines.append('coverage_dir=""')
    launcher_lines.append('if [[ "${COVERAGE_DIR:-}" != "" ]]; then')
    launcher_lines.append('  coverage_requested="1"')
    launcher_lines.append('  coverage_dir="${COVERAGE_DIR}"')
    launcher_lines.append('elif [[ "%s" == "1" ]]; then' % ("1" if ctx.attr.coverage else "0"))
    launcher_lines.append('  coverage_requested="1"')
    launcher_lines.append('  coverage_dir="${TEST_UNDECLARED_OUTPUTS_DIR:-${runtime_workspace}/coverage}"')
    launcher_lines.append('fi')
    launcher_lines.append('if [[ "${coverage_requested}" == "1" ]]; then')
    launcher_lines.append('  bun_args+=("--coverage")')
    launcher_lines.append('  bun_args+=("--coverage-dir" "${coverage_dir}")')
    if ctx.attr.coverage_reporters:
        for reporter in ctx.attr.coverage_reporters:
            launcher_lines.append('  bun_args+=("--coverage-reporter" %s)' % shell_quote(reporter))
    else:
        launcher_lines.append('  if [[ "${COVERAGE_DIR:-}" != "" ]]; then')
        launcher_lines.append('    bun_args+=("--coverage-reporter" "lcov")')
        launcher_lines.append('  fi')
    launcher_lines.append('fi')
    launcher_lines.append('if [[ -n "${TESTBRIDGE_TEST_ONLY:-}" ]]; then')
    launcher_lines.append('  bun_args+=("--test-name-pattern" "${TESTBRIDGE_TEST_ONLY}")')
    launcher_lines.append('fi')
    if ctx.attr.reporter == "junit":
        launcher_lines.append('reporter_out="${XML_OUTPUT_FILE:-${runtime_workspace}/junit.xml}"')
        launcher_lines.append('bun_args+=("--reporter" "junit" "--reporter-outfile" "${reporter_out}")')
    elif ctx.attr.reporter == "dots":
        launcher_lines.append('bun_args+=("--reporter" "dots")')
    for src in ctx.files.srcs:
        launcher_lines.append("bun_args+=(%s)" % shell_quote(src.short_path))
    for arg in ctx.attr.args:
        launcher_lines.append("bun_args+=(%s)" % shell_quote(arg))

    command = """
trap cleanup_runtime_workspace EXIT
cd "${runtime_workspace}"
__BUN_ARGS__
exec "${bun_bin}" "${bun_args[@]}" "$@"
""".replace("__BUN_ARGS__", "\n".join(launcher_lines))

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
        "preload": attr.label_list(
            allow_files = True,
            doc = "Modules to preload with `--preload` before running tests.",
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
        "install_mode": attr.string(
            default = "disable",
            values = ["disable", "auto", "fallback", "force"],
            doc = "Whether Bun may auto-install missing packages while testing.",
        ),
        "timeout_ms": attr.int(
            default = 0,
            doc = "Optional per-test timeout in milliseconds.",
        ),
        "update_snapshots": attr.bool(
            default = False,
            doc = "If true, updates Bun snapshot files.",
        ),
        "rerun_each": attr.int(
            default = 0,
            doc = "Optional number of times to rerun each test file.",
        ),
        "retry": attr.int(
            default = 0,
            doc = "Optional default retry count for all tests.",
        ),
        "todo": attr.bool(
            default = False,
            doc = "If true, includes tests marked with `test.todo()`.",
        ),
        "only": attr.bool(
            default = False,
            doc = "If true, runs only tests marked with `test.only()` or `describe.only()`.",
        ),
        "pass_with_no_tests": attr.bool(
            default = False,
            doc = "If true, exits successfully when no tests are found.",
        ),
        "concurrent": attr.bool(
            default = False,
            doc = "If true, treats all tests as concurrent tests.",
        ),
        "randomize": attr.bool(
            default = False,
            doc = "If true, runs tests in random order.",
        ),
        "seed": attr.int(
            default = 0,
            doc = "Optional randomization seed.",
        ),
        "bail": attr.int(
            default = 0,
            doc = "Optional failure count after which Bun exits the test run.",
        ),
        "reporter": attr.string(
            default = "console",
            values = ["console", "dots", "junit"],
            doc = "Test reporter format.",
        ),
        "max_concurrency": attr.int(
            default = 0,
            doc = "Optional maximum number of concurrent tests.",
        ),
        "coverage": attr.bool(
            default = False,
            doc = "If true, always enables Bun coverage output.",
        ),
        "coverage_reporters": attr.string_list(
            doc = "Repeated Bun coverage reporters such as `text` or `lcov`.",
        ),
        "test_flags": attr.string_list(
            doc = "Additional raw flags forwarded to `bun test` before the test source list.",
        ),
    },
    test = True,
    toolchains = ["//bun:toolchain_type"],
)
