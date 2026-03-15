import { expect, test } from "bun:test";

import { helperMessage } from "./helper.ts";

test("js_test compatibility layer propagates deps and data", () => {
  expect(helperMessage()).toBe("helper:payload-from-lib");
});
