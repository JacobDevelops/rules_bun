"""rules_js-style compatibility exports backed by Bun."""

load("//internal:bun_binary.bzl", _bun_binary = "bun_binary")
load("//internal:bun_test.bzl", _bun_test = "bun_test")
load("//internal:js_library.bzl", _JsInfo = "JsInfo", _js_library = "js_library", _ts_library = "ts_library")
load("//internal:js_run_devserver.bzl", _js_run_devserver = "js_run_devserver")

JsInfo = _JsInfo
js_library = _js_library
ts_library = _ts_library
js_run_devserver = _js_run_devserver

def js_binary(name, **kwargs):
    _bun_binary(name = name, **kwargs)

def js_test(name, entry_point = None, srcs = None, **kwargs):
    if entry_point != None:
        if srcs != None:
            fail("js_test accepts either `entry_point` or `srcs`, but not both")
        srcs = [entry_point]

    if srcs == None:
        fail("js_test requires `entry_point` or `srcs`")

    _bun_test(
        name = name,
        srcs = srcs,
        **kwargs
    )
