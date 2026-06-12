// Emoji scene compositions keyed by verse keywords.
// Falls back to a neutral open-book scene when no keyword matches.
// Phase 2: replace with SVG paths from public/illustrations/{lang}/{book}/{ch}/{v}.svg

const KEYWORD_SCENES: Record<string, string> = {
  solomon:     '👑📜✨',
  king:        '👑🏛️🌟',
  wisdom:      '📜✨💛',
  knowledge:   '📚💡🌟',
  understanding: '💡🌿✨',
  instruction: '📖👆💛',
  learning:    '📖🌱✨',
  fairness:    '⚖️🌿💛',
  right:       '🌟⭐💛',
  choices:     '🌳🛤️🌤️',
  young:       '👦🌱💛',
  simple:      '👶🌿💛',
  fear:        '🙏☁️✨',
  prayer:      '🙏🌤️✨',
  god:         '✨☀️🕊️',
  lord:        '✨☁️🌅',
  heart:       '❤️✨💛',
  trust:       '🤝🌟💛',
  friend:      '👫💛🌸',
  warning:     '⚠️🛑🌿',
  foolish:     '😔💭🌧️',
  street:      '🏙️📢🌆',
  city:        '🏙️⛩️🌇',
  voice:       '📢🌊✨',
  shepherd:    '🐑🌿👐',
  creation:    '🌍🌿☀️',
  lion:        '🦁✨',
  family:      '👨‍👩‍👧❤️🌸',
  father:      '👨‍👦💛🌿',
  mother:      '👩‍👦❤️🌸',
  child:       '👧🌱💛',
  call:        '📢✨🌤️',
  way:         '🛤️🌿☀️',
  path:        '🛤️🌸✨',
  life:        '🌿🌱💛',
  peace:       '🕊️🌿💛',
  sin:         '🌧️⚫🌫️',
  evil:        '🌑🌧️⚫',
  good:        '🌞🌿💛',
  light:       '☀️✨💛',
  dark:        '🌑🌫️',
  tree:        '🌳🌿💛',
  fruit:       '🍇🌿✨',
  water:       '💧🌊🌿',
  bread:       '🍞💛🌾',
};

const DEFAULT_SCENE = '📖✨💛';

export function getVerseScene(keywords: string[]): string {
  for (const kw of keywords) {
    const lower = kw.toLowerCase();
    for (const [key, scene] of Object.entries(KEYWORD_SCENES)) {
      if (lower.includes(key)) return scene;
    }
  }
  return DEFAULT_SCENE;
}

export function getIllustrationPath(
  bookSlug: string,
  chapter: number,
  verse: number,
  lang = 'en'
): string {
  return `/illustrations/${lang}/${bookSlug}/${chapter}/${verse}.svg`;
}
