import { readFileSync } from "node:fs";

export function helperMessage(): string {
  const payload = readFileSync(new URL("./payload.txt", import.meta.url), "utf8").trim();
  return `helper:${payload}`;
}
