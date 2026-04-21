import { expect, test } from "bun:test";
import { greet } from "../src/index";

test("greet returns a personalised greeting", () => {
    expect(greet("World")).toBe("Hello, World!");
});

test("greet works with any name", () => {
    expect(greet("Bun")).toBe("Hello, Bun!");
});
