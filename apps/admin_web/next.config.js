/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: {
      allowedOrigins: ['admin.growly.id', 'localhost:3000']
    }
  }
}

module.exports = nextConfig
