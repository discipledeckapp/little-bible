import Link from 'next/link';
import type { Topic } from '@/lib/topics';

interface TopicsSectionProps {
  topics: Topic[];
}

export default function TopicsSection({ topics }: TopicsSectionProps) {
  if (!topics.length) return null;

  const preview = topics.slice(0, 6);

  return (
    <section className="py-12 px-4 sm:px-6 bg-white" aria-labelledby="topics-heading">
      <div className="max-w-5xl mx-auto">

        <div className="flex items-end justify-between mb-6">
          <div>
            <h2 id="topics-heading" className="text-2xl sm:text-3xl font-extrabold text-stone-900 font-display">
              Scriptures by Topic
            </h2>
            <p className="text-stone-500 text-sm mt-1">
              Find Bible verses on what your family needs today
            </p>
          </div>
          <Link
            href="/topics"
            className="hidden sm:inline-flex items-center gap-1.5 text-amber-600 hover:text-amber-800 font-bold text-sm transition-colors"
          >
            All {topics.length} topics →
          </Link>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
          {preview.map((topic) => (
            <Link
              key={topic.id}
              href={`/topics/${topic.id}`}
              className={`group flex items-center gap-3 p-4 rounded-2xl border transition-all hover:shadow-md active:scale-[0.98] ${topic.colorLight} ${topic.colorBorder} border`}
            >
              <span className="text-2xl shrink-0" aria-hidden="true">{topic.emoji}</span>
              <div className="min-w-0">
                <p className={`font-bold text-sm ${topic.colorText}`}>{topic.title}</p>
                <p className="text-stone-500 text-xs leading-snug mt-0.5 line-clamp-1">
                  {topic.description.split('.')[0]}
                </p>
              </div>
            </Link>
          ))}
        </div>

        <Link
          href="/topics"
          className="mt-5 flex items-center justify-center gap-2 sm:hidden text-amber-600 hover:text-amber-800 font-bold text-sm py-3"
        >
          View all {topics.length} topics →
        </Link>

      </div>
    </section>
  );
}
