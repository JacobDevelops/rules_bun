"""rules_js-style public API backed by Bun."""

load("//internal:js_compat.bzl", _JsInfo = "JsInfo", _js_binary = "js_binary", _js_library = "js_library", _js_run_devserver = "js_run_devserver", _js_test = "js_test", _ts_library = "ts_library")

visibility("public")

JsInfo = _JsInfo
js_binary = _js_binary
js_test = _js_test
js_run_devserver = _js_run_devserver
js_library = _js_library
ts_library = _ts_library
