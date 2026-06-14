import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  turbopack: {
    root: path.resolve(__dirname),
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'lh3.googleusercontent.com',
        pathname: '/**',
      },
    ],
  },

  async redirects() {
    return [
      // ── Singular → plural route normalization ──────────────────────────
      // Guard against links referencing the old singular forms
      {
        source: '/story/:slug',
        destination: '/stories/:slug',
        permanent: true,
      },
      {
        source: '/journey/:slug',
        destination: '/journeys/:slug',
        permanent: true,
      },
      {
        source: '/topic/:slug',
        destination: '/topics/:slug',
        permanent: true,
      },

      // ── App download aliases ────────────────────────────────────────────
      // All device/platform links resolve to the single download page
      {
        source: '/android',
        destination: '/download',
        permanent: false,
      },
      {
        source: '/ios',
        destination: '/download',
        permanent: false,
      },
      {
        source: '/app',
        destination: '/download',
        permanent: false,
      },
      {
        source: '/waitlist',
        destination: '/download',
        permanent: false,
      },

      // ── Challenge aliases ───────────────────────────────────────────────
      {
        source: '/7-day-challenge',
        destination: '/challenge',
        permanent: false,
      },
      {
        source: '/littlebiblechallenge',
        destination: '/challenge',
        permanent: false,
      },

      // ── Free resources aliases ──────────────────────────────────────────
      {
        source: '/resources',
        destination: '/free',
        permanent: false,
      },
      {
        source: '/devotional',
        destination: '/free/7-day-devotional',
        permanent: false,
      },

      // ── Utility aliases ─────────────────────────────────────────────────
      {
        source: '/coming-soon',
        destination: '/',
        permanent: false,
      },
      {
        source: '/help',
        destination: '/',
        permanent: false,
      },
      {
        source: '/support',
        destination: '/donate',
        permanent: false,
      },

      // ── Legacy route patterns ───────────────────────────────────────────
      // Old #anchor approach to library — redirect to home page section
      {
        source: '/library',
        destination: '/#library',
        permanent: false,
      },
      {
        source: '/books',
        destination: '/#library',
        permanent: false,
      },
    ];
  },
};

export default nextConfig;
