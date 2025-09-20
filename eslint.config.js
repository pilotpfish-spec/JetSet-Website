import * as nextPlugin from "eslint-plugin-next";

const nextRecommended =
  (nextPlugin && nextPlugin.configs && (nextPlugin.configs.recommended || nextPlugin.configs["recommended"])) || { rules: {} };

export default [
  { ignores: ["**/*.bak","**/*.backup.*","**/backup_stash/**","**/recovery/**","C:/_website_stash/**"] },
  {
    files: ["**/*.{ts,tsx,js,jsx}"],
    plugins: { "@next/next": nextPlugin.default ?? nextPlugin },
    rules: {
      ...(nextRecommended.rules ?? {}),
    },
  },
];
