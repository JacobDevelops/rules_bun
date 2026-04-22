module github.com/example/api

go 1.26

// golangci-lint is managed as a Go tool so the linter version is tied to the
// same Go toolchain that compiles the code.  See apps/api/lint_test.sh.
tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint
