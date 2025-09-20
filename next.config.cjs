const { createVanillaExtractPlugin } = require("@vanilla-extract/next-plugin");
const withVanillaExtract = createVanillaExtractPlugin();

const baseConfig = {
  reactStrictMode: true,
  // Keep your “ship now” knobs
  typescript: { ignoreBuildErrors: true },
  eslint: { ignoreDuringBuilds: true },
};

module.exports = withVanillaExtract(baseConfig);
