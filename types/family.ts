export interface FamilyData {
  id: string;
  name: string | null;
  journeyId: string | null;
  createdAt: string;
  members: FamilyMember[];
  streak: FamilyStreak | null;
}

export interface FamilyMember {
  id: string;
  name: string;
  age: number | null;
  avatarId: string;
  accentColor: string | null;
  faithGoals: string[];
  seeds: number;
  sortOrder: number;
  lastReadBook?: string | null;
  lastReadChapter?: number | null;
  lastReadAt?: string | null;
  completedChapters?: string[];
}

export interface FamilyStreak {
  currentStreak: number;
  longestStreak: number;
  lastReadDate: string;
}

export interface FamilyDashboard {
  family: FamilyData;
  totalSeeds: number;
  recentActivity: ActivityItem[];
}

export interface ActivityItem {
  type: 'verse_complete' | 'chapter_complete' | 'milestone' | 'memory_verse';
  memberId: string;
  memberName: string;
  memberAvatarId: string;
  description: string;
  bookSlug?: string;
  chapter?: number;
  occurredAt: string;
}

export const AVATARS: Record<string, { emoji: string; label: string; bg: string; color: string }> = {
  lion:      { emoji: '🦁', label: 'Lion',      bg: 'bg-amber-100',   color: 'text-amber-800' },
  whale:     { emoji: '🐋', label: 'Whale',     bg: 'bg-blue-100',    color: 'text-blue-800'  },
  butterfly: { emoji: '🦋', label: 'Butterfly', bg: 'bg-purple-100',  color: 'text-purple-800'},
  sparrow:   { emoji: '🐦', label: 'Sparrow',   bg: 'bg-sky-100',     color: 'text-sky-800'   },
  lamb:      { emoji: '🐑', label: 'Lamb',      bg: 'bg-stone-100',   color: 'text-stone-700' },
  dove:      { emoji: '🕊️', label: 'Dove',      bg: 'bg-slate-100',   color: 'text-slate-700' },
  rainbow:   { emoji: '🌈', label: 'Rainbow',   bg: 'bg-pink-100',    color: 'text-pink-700'  },
  star:      { emoji: '⭐', label: 'Star',      bg: 'bg-yellow-100',  color: 'text-yellow-700'},
  sun:       { emoji: '☀️', label: 'Sun',       bg: 'bg-orange-100',  color: 'text-orange-700'},
  flower:    { emoji: '🌸', label: 'Flower',    bg: 'bg-rose-100',    color: 'text-rose-700'  },
  fish:      { emoji: '🐟', label: 'Fish',      bg: 'bg-cyan-100',    color: 'text-cyan-700'  },
  bear:      { emoji: '🐻', label: 'Bear',      bg: 'bg-amber-100',   color: 'text-amber-900' },
};

export const FAITH_GOALS: { id: string; emoji: string; label: string }[] = [
  { id: 'know_god',      emoji: '💛', label: 'Know God'        },
  { id: 'know_jesus',    emoji: '✝️', label: 'Know Jesus'      },
  { id: 'prayer',        emoji: '🙏', label: 'Prayer'          },
  { id: 'stories',       emoji: '📖', label: 'Bible Stories'   },
  { id: 'character',     emoji: '🌟', label: 'Character'       },
  { id: 'worship',       emoji: '🎵', label: 'Worship'         },
  { id: 'family',        emoji: '👨‍👩‍👧', label: 'Family Devotions'},
  { id: 'memory',        emoji: '📿', label: 'Memory Verses'   },
];

export function getTreeStage(totalSeeds: number): {
  emoji: string;
  label: string;
  next: number | null;
  progress: number;
} {
  const stages = [
    { min: 0,    max: 49,   emoji: '🌱', label: 'Seedling'       },
    { min: 50,   max: 149,  emoji: '🌿', label: 'Sapling'        },
    { min: 150,  max: 349,  emoji: '🌳', label: 'Young Tree'     },
    { min: 350,  max: 699,  emoji: '🌳', label: 'Flourishing'    },
    { min: 700,  max: 1199, emoji: '🌳', label: 'Strong Oak'     },
    { min: 1200, max: null, emoji: '🌳', label: 'Ancient Tree'   },
  ];

  for (let i = stages.length - 1; i >= 0; i--) {
    const s = stages[i];
    if (totalSeeds >= s.min) {
      const next = s.max !== null ? s.max + 1 : null;
      const progress = s.max !== null
        ? Math.min(100, Math.round(((totalSeeds - s.min) / (s.max - s.min + 1)) * 100))
        : 100;
      return { emoji: s.emoji, label: s.label, next, progress };
    }
  }
  return { emoji: '🌱', label: 'Seedling', next: 50, progress: 0 };
}
