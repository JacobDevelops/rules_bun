import { spawnSync } from "node:child_process";

const bun = process.execPath;
const extraArgs = process.argv.slice(2);

for (const args of [
  ["run", "--cwd", "./packages/i18n", "build"],
  ["run", "--cwd", "./packages/app-b", "build", "--", ...extraArgs],
]) {
  const result = spawnSync(bun, args, { stdio: "inherit" });
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}
