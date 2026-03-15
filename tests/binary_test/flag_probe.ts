const state = globalThis as typeof globalThis & { __rules_bun_preloaded?: string };

console.log(JSON.stringify({
  preloaded: state.__rules_bun_preloaded ?? null,
  env: process.env.RUNTIME_FLAG_TEST ?? null,
  argv: process.argv.slice(2),
}));
