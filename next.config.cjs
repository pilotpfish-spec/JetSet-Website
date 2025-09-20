const withVanillaExtract = require('@vanilla-extract/next-plugin').default;

const nextConfig = {
  reactStrictMode: true,
};

module.exports = withVanillaExtract(nextConfig);
