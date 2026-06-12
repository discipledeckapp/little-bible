// Maps story ID → array of { phrase, fact, emoji }
// These get matched against the story's read.text to auto-highlight wonder words.
export interface WonderWordDef {
  phrase: string;
  fact: string;
  emoji: string;
}

export const WONDER_WORDS: Record<string, WonderWordDef[]> = {
  'god-made-everything': [
    {
      phrase: 'In the beginning',
      fact: 'The Hebrew word for "beginning" is bereshit — the very first word in the whole Bible!',
      emoji: '📜',
    },
    {
      phrase: 'the heavens and the earth',
      fact: 'Ancient Hebrews used "heavens and earth" to mean absolutely everything — every star, mountain, ocean, and creature.',
      emoji: '🌌',
    },
    {
      phrase: 'the Spirit of God',
      fact: 'The word "Spirit" in Hebrew is ruach — it also means breath and wind. God breathed life into creation!',
      emoji: '💨',
    },
  ],
  'noahs-big-boat': [
    {
      phrase: 'ark',
      fact: "Noah's ark was as long as 1.5 football fields — big enough to hold 2 of every animal!",
      emoji: '🚢',
    },
    {
      phrase: 'forty days and forty nights',
      fact: 'In the Bible, forty often means a long, complete time of testing. Moses spent 40 days on Mount Sinai too!',
      emoji: '⛈️',
    },
  ],
  'david-the-shepherd-boy': [
    {
      phrase: 'shepherd',
      fact: 'Shepherds in Bible times lived with their sheep day and night, protecting them from lions and bears — just like David did!',
      emoji: '🐑',
    },
    {
      phrase: 'slingshot',
      fact: 'Slingers in the ancient world were deadly accurate. A trained slinger could hit a target the size of a coin from 100 metres away!',
      emoji: '🪨',
    },
  ],
  'birth-of-jesus': [
    {
      phrase: 'manger',
      fact: 'A manger is a feeding trough for animals. Jesus was laid in one because there was no room at the inn — God came humbly!',
      emoji: '🌾',
    },
    {
      phrase: 'Bethlehem',
      fact: 'Bethlehem means "House of Bread" in Hebrew. Fitting — Jesus would one day call himself the Bread of Life!',
      emoji: '🏘️',
    },
  ],
  'how-to-pray': [
    {
      phrase: 'Our Father',
      fact: "Jesus taught us to call God \"Father\" — abba in Aramaic. It's an intimate word, like saying \"Dad.\" God wants us that close!",
      emoji: '🙏',
    },
    {
      phrase: 'hallowed',
      fact: '"Hallowed" means completely holy and set apart. When we say it, we\'re saying God is unlike anyone or anything else.',
      emoji: '✨',
    },
  ],
};

/**
 * Returns wonder word definitions for a given story, or empty array if none defined.
 */
export function getWonderWords(storyId: string): WonderWordDef[] {
  return WONDER_WORDS[storyId] ?? [];
}
