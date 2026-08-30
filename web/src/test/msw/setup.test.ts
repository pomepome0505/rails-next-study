import { describe, expect, it } from "vitest";

describe("テスト環境", () => {
  it("MSW のハンドラが応答する", async () => {
    const res = await fetch("http://localhost/api/me");
    const body = await res.json();

    expect(body).toEqual({ id: 1, name: "Alice", email: "alice@example.com" });
  });
});
