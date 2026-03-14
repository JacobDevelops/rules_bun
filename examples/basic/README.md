# basic example

Minimal `bun_dev` example.

Run:

```bash
bazel run //examples/basic:web_dev
```

This starts Bun in watch mode for `main.ts`.

For the hot-reload launcher variant:

```bash
bazel run //examples/basic:web_dev_hot_restart
```

This starts Bun with `watch_mode = "hot"`, disables screen clearing, and wires
`README.md` through `restart_on` to exercise the custom restart launcher path.
