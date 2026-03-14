"""Lightweight JS/TS source grouping rules."""

JsInfo = provider(
    doc = "Provides transitive JavaScript/TypeScript metadata for Bun and JS compatibility rules.",
    fields = {
        "sources": "Direct source files owned by this target.",
        "transitive_sources": "Transitive source files from this target and its deps.",
        "types": "Direct type files owned by this target.",
        "transitive_types": "Transitive type files from this target and its deps.",
        "data_files": "Direct runtime data files owned by this target.",
        "transitive_runfiles": "Transitive runtime files from this target and its deps.",
    },
)

BunSourcesInfo = provider(
    "Provides transitive sources for Bun libraries.",
    fields = ["transitive_sources"],
)

def collect_js_sources(dep):
    if JsInfo in dep:
        return dep[JsInfo].transitive_sources
    if BunSourcesInfo in dep:
        return dep[BunSourcesInfo].transitive_sources
    return dep[DefaultInfo].files

def collect_js_runfiles(dep):
    if JsInfo in dep:
        return dep[JsInfo].transitive_runfiles
    if BunSourcesInfo in dep:
        return dep[BunSourcesInfo].transitive_sources
    return dep[DefaultInfo].files

def _bun_library_impl(ctx):
    transitive_sources = [collect_js_sources(dep) for dep in ctx.attr.deps]
    transitive_types = [
        dep[JsInfo].transitive_types
        for dep in ctx.attr.deps
        if JsInfo in dep
    ]
    transitive_runfiles = [collect_js_runfiles(dep) for dep in ctx.attr.deps]

    all_sources = depset(
        direct = ctx.files.srcs,
        transitive = transitive_sources,
    )
    all_types = depset(
        direct = ctx.files.types,
        transitive = transitive_types,
    )
    all_runfiles = depset(
        direct = ctx.files.srcs + ctx.files.types + ctx.files.data,
        transitive = transitive_runfiles,
    )
    default_files = depset(
        direct = ctx.files.srcs + ctx.files.types + ctx.files.data,
        transitive = transitive_sources + transitive_types + transitive_runfiles,
    )

    js_info = JsInfo(
        sources = depset(ctx.files.srcs),
        transitive_sources = all_sources,
        types = depset(ctx.files.types),
        transitive_types = all_types,
        data_files = depset(ctx.files.data),
        transitive_runfiles = all_runfiles,
    )
    return [
        js_info,
        BunSourcesInfo(transitive_sources = all_sources),
        DefaultInfo(files = default_files),
    ]

js_library = rule(
    implementation = _bun_library_impl,
    doc = "Aggregates JavaScript sources and transitive Bun source dependencies.",
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".js", ".jsx", ".mjs", ".cjs"],
            doc = "JavaScript source files in this library.",
        ),
        "types": attr.label_list(
            allow_files = [".d.ts"],
            doc = "Optional declaration files associated with this library.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Optional runtime files propagated to dependents.",
        ),
        "deps": attr.label_list(
            doc = "Other Bun source libraries to include transitively.",
        ),
    },
)

ts_library = rule(
    implementation = _bun_library_impl,
    doc = "Aggregates TypeScript sources and transitive Bun source dependencies.",
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".ts", ".tsx"],
            doc = "TypeScript source files in this library.",
        ),
        "types": attr.label_list(
            allow_files = [".d.ts"],
            doc = "Optional declaration files associated with this library.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Optional runtime files propagated to dependents.",
        ),
        "deps": attr.label_list(
            doc = "Other Bun source libraries to include transitively.",
        ),
    },
)
