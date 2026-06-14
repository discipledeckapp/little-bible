import type { MetadataRoute } from 'next';
import { BIBLE_BOOKS } from '@/lib/bibleBooks';
import { getLanguageIndex, getBookIndex } from '@/lib/content';
import { getAllStories } from '@/lib/stories';
import { getAllTopics } from '@/lib/topics';

const BASE = 'https://littlebible.org';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const now = new Date();

  // ── Static pages ────────────────────────────────────────────────────────
  const staticPages: MetadataRoute.Sitemap = [
    { url: BASE,              lastModified: now, changeFrequency: 'daily',   priority: 1.0 },
    { url: `${BASE}/stories`, lastModified: now, changeFrequency: 'weekly',  priority: 0.9 },
    { url: `${BASE}/topics`,  lastModified: now, changeFrequency: 'weekly',  priority: 0.85 },
    { url: `${BASE}/donate`,  lastModified: now, changeFrequency: 'monthly', priority: 0.4 },
  ];

  // ── All 66 book index pages ──────────────────────────────────────────────
  const bookPages: MetadataRoute.Sitemap = BIBLE_BOOKS.map(book => ({
    url: `${BASE}/${book.slug}`,
    lastModified: now,
    changeFrequency: 'monthly' as const,
    priority: book.status === 'available' ? 0.8 : book.status === 'in-progress' ? 0.7 : 0.4,
  }));

  // ── Available chapter pages ──────────────────────────────────────────────
  const chapterPages: MetadataRoute.Sitemap = [];
  try {
    const books = getLanguageIndex('en');
    for (const book of books) {
      const chapters = getBookIndex(book.slug, 'en');
      for (const ch of chapters) {
        chapterPages.push({
          url: `${BASE}/${book.slug}/${ch.chapter}`,
          lastModified: now,
          changeFrequency: 'monthly' as const,
          priority: 0.7,
        });
      }
    }
  } catch {
    // No content available yet
  }

  // ── Story pages ──────────────────────────────────────────────────────────
  const stories = await getAllStories();
  const storyPages: MetadataRoute.Sitemap = stories.map(story => ({
    url: `${BASE}/stories/${story.id}`,
    lastModified: now,
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }));

  // ── Topic pages ───────────────────────────────────────────────────────────
  const topicPages: MetadataRoute.Sitemap = getAllTopics().map(topic => ({
    url: `${BASE}/topics/${topic.id}`,
    lastModified: now,
    changeFrequency: 'monthly' as const,
    priority: 0.75,
  }));

  return [...staticPages, ...bookPages, ...chapterPages, ...storyPages, ...topicPages];
}
