import { helperMessage } from "./helper.ts";

console.log(`${helperMessage()} ${Bun.argv.slice(2).join(" ")}`.trim());
