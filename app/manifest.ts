import type { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'Little Bible',
    short_name: 'Little Bible',
    description: "All 66 books of Scripture faithfully adapted for children ages 4–7.",
    start_url: '/',
    display: 'standalone',
    background_color: '#FFFBF5',
    theme_color: '#B45309',
    icons: [
      { src: '/icon', sizes: '512x512', type: 'image/png', purpose: 'any' },
      { src: '/icon', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      { src: '/apple-icon', sizes: '180x180', type: 'image/png' },
    ],
  };
}
