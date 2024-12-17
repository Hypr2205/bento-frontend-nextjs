/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: [
      'plus.unsplash.com',
      'images.unsplash.com',
      'i.pinimg.com',
      'i.pravatar.cc',
      'localhost',
    ],
  },
  output: 'standalone',
};

export default nextConfig;
