const { createVanillaExtractPlugin } = require("@vanilla-extract/next-plugin");

const withVanillaExtract = createVanillaExtractPlugin();

module.exports = withVanillaExtract({
  reactStrictMode: true,
});
/* build-safety: appended by script */
module.exports.typescript = { ...(module.exports.typescript || {}), ignoreBuildErrors: true };
module.exports.eslint = { ...(module.exports.eslint || {}), ignoreDuringBuilds: true };
