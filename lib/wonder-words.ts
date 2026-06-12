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
  'god-made-me': [
    {
      phrase: 'wonderfully made',
      fact: 'The Hebrew word for "wonderfully" is nipleti — it means set apart and distinguished. There is nobody else in the whole world exactly like you!',
      emoji: '✨',
    },
    {
      phrase: 'innermost self',
      fact: 'Ancient Hebrew people believed the kidneys were the seat of the deepest feelings and thoughts — when David said God made his innermost parts, he meant God made the very deepest part of who he was.',
      emoji: '💜',
    },
    {
      phrase: 'on purpose',
      fact: 'Scientists say that the human body has about 37 trillion cells. God carefully made every single one of yours — and He knew your name before any of them existed!',
      emoji: '🌟',
    },
  ],
  'gods-rainbow-promise': [
    {
      phrase: 'rainbow',
      fact: 'A rainbow appears when sunlight shines through water droplets in the air — it is always a full circle, but we only ever see the top half from the ground. God painted a promise in the whole sky!',
      emoji: '🌈',
    },
    {
      phrase: 'a promise',
      fact: 'The Hebrew word for this kind of promise is berit — it means a covenant, the most serious and unbreakable agreement two people can make. God made one with every living creature on earth!',
      emoji: '🤝',
    },
    {
      phrase: 'never again',
      fact: "God has kept this promise for thousands of years. Every time it rains and the rainbow comes out, God is renewing the same promise He made to Noah's family right after the flood.",
      emoji: '🕊️',
    },
  ],
  'daniel-and-the-lions': [
    {
      phrase: "lions' den",
      fact: 'Lions were kept by ancient kings as a symbol of power and as a way to execute criminals. The den was a pit with a stone rolled over the entrance — very much like a tomb!',
      emoji: '🦁',
    },
    {
      phrase: 'three times a day',
      fact: 'Daniel prayed facing Jerusalem — even while living hundreds of miles away in Babylon. Jewish people prayed toward Jerusalem because the Temple was there: the place where God\'s presence lived.',
      emoji: '🕌',
    },
    {
      phrase: 'sent His angel',
      fact: 'The word "angel" in Hebrew means messenger. God sent a messenger into the darkness of the pit to be with Daniel — a reminder that no place is too dark or too dangerous for God to reach.',
      emoji: '👼',
    },
  ],
  'jonah-and-the-big-fish': [
    {
      phrase: 'great fish',
      fact: 'The Bible does not say it was a whale — just a "great fish" especially prepared by God. Sperm whales have been found with large intact objects inside them, and their throats are wide enough to swallow a person whole!',
      emoji: '🐋',
    },
    {
      phrase: 'three days and three nights',
      fact: 'Jesus later pointed to Jonah\'s three days inside the fish as a picture of His own death and resurrection — three days in the tomb, then alive again. Jonah\'s story pointed to Jesus all along!',
      emoji: '⏳',
    },
    {
      phrase: 'great city of Nineveh',
      fact: 'Nineveh was the capital of the Assyrian Empire — one of the most powerful and feared nations in the ancient world. It was so big the Bible says it took three days just to walk across it!',
      emoji: '🏙️',
    },
  ],
  'jesus-loves-children': [
    {
      phrase: 'little ones',
      fact: 'In the ancient world, children had very little social status — they were considered unimportant until they grew up. Jesus completely reversed this by saying the Kingdom of God belongs to people who are like children.',
      emoji: '👦',
    },
    {
      phrase: 'Kingdom of God',
      fact: '"Kingdom of God" does not mean a place with a castle — it means wherever God is in charge. Jesus said that people who come to Him with simple trust and open hands are the ones who fit right in!',
      emoji: '👑',
    },
    {
      phrase: 'took them up in his arms',
      fact: 'The Greek word used here means Jesus gathered them up close — the same kind of embrace a parent gives a child. Jesus stopped teaching crowds just to hold children. That is how much He wanted them near.',
      emoji: '🤗',
    },
  ],
  'the-good-shepherd': [
    {
      phrase: 'Good Shepherd',
      fact: 'Shepherds in Bible times did not drive their sheep from behind — they walked ahead and the sheep followed the sound of their voice. Every shepherd had a unique call, and their sheep knew it.',
      emoji: '🐑',
    },
    {
      phrase: 'lays down his life for the sheep',
      fact: 'A hired worker who looked after sheep for money would run away if a wolf or lion attacked. But a true shepherd stayed and fought — even at risk of his own life. Jesus said He is that kind of shepherd.',
      emoji: '🛡️',
    },
    {
      phrase: 'know my sheep',
      fact: 'Shepherds in the ancient Middle East would often give each sheep a personal name. Studies show sheep can recognise and remember up to 50 different sheep faces — and their shepherd\'s face — for years.',
      emoji: '💛',
    },
  ],
  'the-lost-sheep': [
    {
      phrase: 'ninety-nine',
      fact: 'A flock of one hundred sheep was a large and valuable herd — worth a shepherd\'s whole livelihood. Leaving ninety-nine to search for one was a wildly generous and risky thing to do. That is how much you matter to God.',
      emoji: '💯',
    },
    {
      phrase: 'layeth it on his shoulders',
      fact: 'When a sheep was found after being lost, it was often too exhausted or injured to walk. The shepherd would drape it across his shoulders — bearing the sheep\'s full weight all the way home. Jesus carries us the same way.',
      emoji: '🏔️',
    },
    {
      phrase: 'Rejoice with me',
      fact: 'Jesus said there is more joy in heaven over one person coming back to God than over ninety-nine who never wandered. Heaven throws a party every time someone comes home!',
      emoji: '🎉',
    },
  ],
  'the-lost-son': [
    {
      phrase: 'faraway country',
      fact: "In Jesus' time, asking for your inheritance early was a huge insult — it was like saying, \"I wish you were dead.\" Yet the father gave it anyway. That is a picture of how freely God gives.",
      emoji: '🌍',
    },
    {
      phrase: 'his father ran',
      fact: 'In the ancient Middle East, dignified older men never ran in public — it was considered deeply undignified. But this father ran anyway, robe flying, because love was more important than reputation.',
      emoji: '🏃',
    },
    {
      phrase: 'he was lost, and is found',
      fact: 'The father used the same words the shepherd used about his lost sheep. Jesus told both stories on the same day to show one great truth: God searches for the lost and celebrates wildly when they come home.',
      emoji: '🎊',
    },
  ],
  'the-good-neighbour': [
    {
      phrase: 'road from Jerusalem to Jericho',
      fact: 'The road from Jerusalem to Jericho dropped over 1,000 metres in just 27 kilometres — winding through rocky desert. It was so dangerous that travellers called it the "Way of Blood" because of the bandits who hid along it.',
      emoji: '🛣️',
    },
    {
      phrase: 'Samaritan',
      fact: 'Jewish people and Samaritans had been enemies for hundreds of years — they had different temples, different traditions, and would not even share drinking water. Jesus chose a Samaritan as the hero of the story on purpose.',
      emoji: '🤝',
    },
    {
      phrase: 'bandaged his wounds',
      fact: 'The Samaritan used his own oil and wine to clean the wounds — both were expensive. Then he paid the innkeeper two denarii, which was about two days\' wages. Real love costs something.',
      emoji: '🩹',
    },
  ],
  'jesus-saves': [
    {
      phrase: 'crucified',
      fact: 'Crucifixion was the most serious punishment in the Roman Empire, used for the worst criminals. The fact that Jesus — the Son of God — died this way shows just how far He was willing to go for us.',
      emoji: '✝️',
    },
    {
      phrase: 'Father, forgive them',
      fact: 'While He was on the cross in tremendous pain, Jesus prayed for the very people hurting Him. No other person in history has ever done anything like it. That prayer is still being answered today.',
      emoji: '🙏',
    },
    {
      phrase: 'He is not here, but is risen',
      fact: 'The tomb where Jesus was buried was sealed with a massive stone and guarded by Roman soldiers — the most secure tomb possible. Yet on the third day it was empty. Over 500 people saw Jesus alive after the resurrection!',
      emoji: '🌅',
    },
  ],
};

/**
 * Returns wonder word definitions for a given story, or empty array if none defined.
 */
export function getWonderWords(storyId: string): WonderWordDef[] {
  return WONDER_WORDS[storyId] ?? [];
}
