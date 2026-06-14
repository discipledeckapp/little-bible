'use client';

import { useState, useEffect } from 'react';
import type { StoryActivity, ActivityType } from '@/types/activities';
import { fetchStoryActivity } from '@/lib/activities';
import { addSeeds } from '@/lib/progress';
import MemoryBuilder from './MemoryBuilder';
import StorySequencer from './StorySequencer';
import CharacterMatcher from './CharacterMatcher';
import ApplicationPrompt from './ApplicationPrompt';

interface ActivityGateProps {
  storyId: string;
  storyTitle: string;
  doTodayAction?: string;
  onSeedsEarned: (seeds: number) => void;
  onDismiss: () => void;
}

interface ActivityCard {
  type: ActivityType;
  label: string;
  emoji: string;
  color: string;
  lightColor: string;
  duration: string;
  tag: string;
}

const ACTIVITY_CARDS: ActivityCard[] = [
  {
    type:       'memory-builder',
    label:      'Memory Builder',
    emoji:      '🔤',
    color:      '#F59E0B',
    lightColor: '#FFFBEB',
    duration:   '~2 min',
    tag:        'Memory',
  },
  {
    type:       'story-sequence',
    label:      'Story Order',
    emoji:      '📅',
    color:      '#0EA5E9',
    lightColor: '#F0F9FF',
    duration:   '~1 min',
    tag:        'Sequence',
  },
  {
    type:       'character-match',
    label:      'Character Match',
    emoji:      '🔗',
    color:      '#16A34A',
    lightColor: '#F0FDF4',
    duration:   '~2 min',
    tag:        'Match',
  },
  {
    type:       'application',
    label:      'Think About It',
    emoji:      '💭',
    color:      '#7C3AED',
    lightColor: '#F5F3FF',
    duration:   '~1 min',
    tag:        'Reflect',
  },
];

export default function ActivityGate({
  storyId,
  storyTitle,
  doTodayAction,
  onSeedsEarned,
  onDismiss,
}: ActivityGateProps) {
  const [activityData, setActivityData] = useState<StoryActivity | null | 'loading'>('loading');
  const [activeType, setActiveType] = useState<ActivityType | null>(null);
  const [completed, setCompleted] = useState<ActivityType[]>([]);

  useEffect(() => {
    fetchStoryActivity(storyId).then(setActivityData);
  }, [storyId]);

  function getAvailableCards(): ActivityCard[] {
    if (activityData === 'loading' || activityData === null) {
      // If no data, only application is available
      return ACTIVITY_CARDS.filter(c => c.type === 'application');
    }
    return ACTIVITY_CARDS.filter(c => {
      switch (c.type) {
        case 'memory-builder':   return !!activityData.memoryBuilder;
        case 'story-sequence':   return !!activityData.sequence;
        case 'character-match':  return !!activityData.matches;
        case 'application':      return true;
        default:                 return false;
      }
    });
  }

  function handleActivityComplete(seedsEarned: number, type: ActivityType) {
    addSeeds(seedsEarned);
    onSeedsEarned(seedsEarned);
    setCompleted(prev => [...prev, type]);
    // Record in API fire-and-forget
    fetch('/api/activities/record', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ storyId, activityType: type, seedsEarned }),
    }).catch(() => {});
    // Brief pause then return to menu
    setTimeout(() => setActiveType(null), 600);
  }

  // Render active activity fullscreen
  if (activeType && activityData && activityData !== 'loading') {
    return (
      <div className="fixed inset-0 z-50 bg-white overflow-y-auto">
        {activeType === 'memory-builder' && activityData.memoryBuilder && (
          <MemoryBuilder
            data={activityData.memoryBuilder}
            onComplete={(seeds, perfect) => handleActivityComplete(seeds, 'memory-builder')}
            onBack={() => setActiveType(null)}
          />
        )}
        {activeType === 'story-sequence' && activityData.sequence && (
          <StorySequencer
            prompt={activityData.sequence.prompt}
            items={activityData.sequence.items}
            onComplete={(seeds, perfect) => handleActivityComplete(seeds, 'story-sequence')}
            onBack={() => setActiveType(null)}
          />
        )}
        {activeType === 'character-match' && activityData.matches && (
          <CharacterMatcher
            prompt={activityData.matches.prompt}
            pairs={activityData.matches.pairs}
            onComplete={(seeds, perfect) => handleActivityComplete(seeds, 'character-match')}
            onBack={() => setActiveType(null)}
          />
        )}
        {activeType === 'application' && (
          <ApplicationPrompt
            data={activityData.application ?? {
              question: doTodayAction ?? 'What did you learn from this story? Share it with someone today!',
              options: [
                { id: 'share',   label: 'I will share it',   emoji: '🗣️' },
                { id: 'pray',    label: 'I will pray about it', emoji: '🙏' },
                { id: 'do',      label: 'I will do it today', emoji: '⚡' },
              ],
              followUp: 'Great! God loves when we put His Word into action.',
            }}
            onComplete={(seeds) => handleActivityComplete(seeds, 'application')}
            onBack={() => setActiveType(null)}
          />
        )}
      </div>
    );
  }

  const availableCards = getAvailableCards();

  return (
    <div className="fixed inset-0 z-50 bg-amber-50 overflow-y-auto">
      <div className="min-h-full flex flex-col px-5 py-6 max-w-lg mx-auto">

        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <button
            onClick={onDismiss}
            className="text-sm font-semibold text-stone-400 hover:text-stone-600 flex items-center gap-1.5"
          >
            ← Back to story
          </button>
          {completed.length > 0 && (
            <span className="text-xs font-bold text-amber-600 bg-amber-100 rounded-full px-3 py-1">
              {completed.length} done ✓
            </span>
          )}
        </div>

        {/* Title */}
        <div className="text-center mb-2">
          <div className="text-4xl mb-3">🌟</div>
          <h2 className="text-2xl font-bold text-stone-800 mb-1" style={{ fontFamily: 'var(--font-display)' }}>
            Practice Time!
          </h2>
          <p className="text-stone-500 text-sm leading-relaxed">
            Spend 2 minutes practicing what you read in{' '}
            <strong className="text-stone-700">{storyTitle}</strong>
          </p>
        </div>

        {/* Loading */}
        {activityData === 'loading' && (
          <div className="flex-1 flex items-center justify-center">
            <div className="w-8 h-8 border-3 border-amber-300 border-t-amber-600 rounded-full animate-spin" />
          </div>
        )}

        {/* Activity cards */}
        {activityData !== 'loading' && (
          <div className="grid grid-cols-2 gap-3 mt-6 flex-1">
            {availableCards.map(card => {
              const isDone = completed.includes(card.type);
              return (
                <button
                  key={card.type}
                  onClick={() => !isDone && setActiveType(card.type)}
                  className={`relative flex flex-col items-start p-4 rounded-2xl border-2 transition-all active:scale-[0.97] text-left ${
                    isDone
                      ? 'bg-green-50 border-green-300 opacity-70'
                      : 'bg-white border-stone-100 hover:border-amber-300 hover:shadow-md'
                  }`}
                  style={!isDone ? { '--hover-border': card.color } as React.CSSProperties : {}}
                >
                  {isDone && (
                    <div className="absolute top-2.5 right-2.5 w-5 h-5 bg-green-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs font-bold">✓</span>
                    </div>
                  )}
                  <div
                    className="w-11 h-11 rounded-xl flex items-center justify-center text-xl mb-3"
                    style={{ background: card.lightColor }}
                  >
                    {card.emoji}
                  </div>
                  <p className="font-bold text-stone-800 text-sm leading-tight mb-1">{card.label}</p>
                  <div className="flex items-center gap-1.5 mt-auto">
                    <span
                      className="text-[10px] font-bold px-2 py-0.5 rounded-full"
                      style={{ background: card.lightColor, color: card.color }}
                    >
                      {card.tag}
                    </span>
                    <span className="text-[10px] text-stone-400 font-medium">{card.duration}</span>
                  </div>
                </button>
              );
            })}
          </div>
        )}

        {/* Dismiss */}
        <button
          onClick={onDismiss}
          className="mt-6 text-stone-400 hover:text-stone-600 text-sm font-medium text-center py-2"
        >
          Maybe later →
        </button>
      </div>
    </div>
  );
}
