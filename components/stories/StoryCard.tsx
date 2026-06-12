'use client';

import Link from 'next/link';
import { Story, StoryStatus } from '@/types';
import PazSparrow from '@/components/mascot/PazSparrow';

interface StoryCardProps {
  story: Story;
  status?: StoryStatus;
  onClick?: () => void;
  size?: 'sm' | 'md' | 'lg';
}

export default function StoryCard({ story, status = 'unread', size = 'md' }: StoryCardProps) {
  // Size variants
  const sizeClasses = {
    sm: 'w-32 h-44',
    md: 'w-40 h-56',
    lg: 'w-48 h-64',
  };

  const isComplete = status === 'complete' || status === 'memorised';
  const isStarted = status === 'in-progress';

  return (
    <Link
      href={`/stories/${story.id}`}
      className={`
        ${sizeClasses[size]} relative flex flex-col rounded-2xl overflow-hidden
        shadow-md hover:shadow-lg transition-all duration-200
        hover:-translate-y-1 active:scale-95
        ${isComplete ? 'ring-2 ring-amber-400' : ''}
        ${status === 'memorised' ? 'ring-2 ring-amber-500' : ''}
        focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-amber-400
      `}
      style={{ background: story.coverColor + '18' }}
      aria-label={`${story.title}${isComplete ? ' — completed' : ''}`}
    >
      {/* Illustration area */}
      <div
        className="flex-1 flex items-center justify-center relative"
        style={{ background: `linear-gradient(160deg, ${story.coverColor}22 0%, ${story.coverColor}44 100%)` }}
      >
        {/* Big emoji as placeholder illustration */}
        <span
          className="select-none"
          style={{ fontSize: size === 'sm' ? '3rem' : size === 'md' ? '4rem' : '5rem' }}
          role="img"
          aria-label={story.title}
        >
          {story.coverEmoji}
        </span>

        {/* Paz sparrow appears on completed stories */}
        {isComplete && (
          <div className="absolute bottom-2 right-2">
            <PazSparrow state="perching" size={size === 'sm' ? 20 : 28} />
          </div>
        )}

        {/* Memorised golden ring */}
        {status === 'memorised' && (
          <div className="absolute top-2 right-2 w-5 h-5 rounded-full bg-amber-400 flex items-center justify-center">
            <span className="text-xs">⭐</span>
          </div>
        )}

        {/* In-progress indicator */}
        {isStarted && (
          <div className="absolute top-2 left-2 w-2 h-2 rounded-full bg-amber-400 animate-pulse" />
        )}
      </div>

      {/* Title area */}
      <div
        className="px-3 py-2 bg-white border-t"
        style={{ borderColor: story.coverColor + '33' }}
      >
        <p
          className="text-xs font-bold leading-tight text-stone-800 line-clamp-2"
          style={{ fontFamily: 'var(--font-display)' }}
        >
          {story.title}
        </p>
        <p className="text-xs text-stone-400 mt-0.5 truncate">
          {story.bibleRef}
        </p>
      </div>

      {/* Completion overlay */}
      {isComplete && (
        <div className="absolute inset-0 bg-amber-400/5 pointer-events-none rounded-2xl" />
      )}
    </Link>
  );
}
