"""Rule for bundling JS/TS sources with Bun."""

load("//internal:bun_build_support.bzl", "add_bun_build_common_flags", "bun_build_transitive_inputs")


def _output_name(target_name, entry):
    stem = entry.basename.rsplit(".", 1)[0]
    return "{}__{}.js".format(target_name, stem)


def _bun_bundle_impl(ctx):
    toolchain = ctx.toolchains["//bun:toolchain_type"]
    bun_bin = toolchain.bun.bun_bin

    transitive_inputs = bun_build_transitive_inputs(ctx)

    outputs = []
    for entry in ctx.files.entry_points:
        output = ctx.actions.declare_file(_output_name(ctx.label.name, entry))
        outputs.append(output)

        args = ctx.actions.args()
        args.add("--bun")
        args.add("build")
        add_bun_build_common_flags(args, ctx.attr)
        args.add("--outfile")
        args.add(output.path)
        args.add(entry.path)

        ctx.actions.run(
            executable = bun_bin,
            arguments = [args],
            inputs = depset(
                direct = [entry] + ctx.files.data,
                transitive = transitive_inputs,
            ),
            outputs = [output],
            mnemonic = "BunBundle",
            progress_message = "Bundling {} with Bun".format(entry.short_path),
        )

    return [DefaultInfo(files = depset(outputs))]


bun_bundle = rule(
    implementation = _bun_bundle_impl,
    doc = """Bundles one or more JS/TS entry points using Bun build.

Each entry point produces one output JavaScript artifact.
""",
    attrs = {
        "entry_points": attr.label_list(
            mandatory = True,
            allow_files = [".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs"],
            doc = "Entry files to bundle.",
        ),
        "node_modules": attr.label(
            doc = "Optional label providing package files from a `node_modules` tree, typically produced by `bun_install`, for package resolution.",
        ),
        "deps": attr.label_list(
            doc = "Source/library dependencies that provide transitive inputs.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional non-source files needed during bundling.",
        ),
        "install_mode": attr.string(
            default = "disable",
            values = ["disable", "auto", "fallback", "force"],
            doc = "Whether Bun may auto-install missing packages during bundling.",
        ),
        "target": attr.string(
            default = "browser",
            values = ["browser", "node", "bun"],
            doc = "Bun build target environment.",
        ),
        "format": attr.string(
            default = "esm",
            values = ["esm", "cjs", "iife"],
            doc = "Output module format.",
        ),
        "minify": attr.bool(
            default = False,
            doc = "If true, minifies bundle output.",
        ),
        "sourcemap": attr.bool(
            default = False,
            doc = "If true, emits source maps.",
        ),
        "external": attr.string_list(
            doc = "Package names to treat as externals (not bundled).",
        ),
        "build_flags": attr.string_list(
            doc = "Additional raw flags forwarded to `bun build`.",
        ),
    },
    toolchains = ["//bun:toolchain_type"],
)
