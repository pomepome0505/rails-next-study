import { HttpResponse, http } from "msw";

export const handlers = [
  http.get("*/api/me", () =>
    HttpResponse.json({ id: 1, name: "Alice", email: "alice@example.com" }),
  ),
];
