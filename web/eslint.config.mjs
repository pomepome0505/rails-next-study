import tsParser from "@typescript-eslint/parser";
import { defineConfig } from "eslint/config";
import reactHooks from "eslint-plugin-react-hooks";

export default defineConfig([
  {
    ...reactHooks.configs.flat.recommended,
    files: ["src/**/*.ts?(x)"],
    languageOptions: { parser: tsParser },
    rules: {
      // Biome が担当するため無効化
      "react-hooks/rules-of-hooks": "off",
      "react-hooks/exhaustive-deps": "off",
    },
  },
  { ignores: ["node_modules/**", ".next/**"] },
]);
