// Machine-checkable subset of docs/LittleBible_Translation_Charter.md v1.0 and
// docs/LittleBible_Vocabulary_Guide.md v1.0.
//
// The charter is binding on all content, but only part of it can be decided by a
// program: word limits, the Tier 3 replacement table, and the prayer/question
// formats. Everything doctrinal — "is all essential meaning preserved?", "is the
// fear of the Lord still present?" — belongs to a human reviewer. Where a rule is
// only partly decidable, this emits a `warning` that draws the reviewer's eye
// rather than an `error` that pretends certainty.

export type CharterField =
  | 'little_bible'
  | 'memory_phrase'
  | 'prayer'
  | 'discussion_question';

export type CharterSeverity = 'error' | 'warning';

export interface CharterIssue {
  field: CharterField;
  severity: CharterSeverity;
  /** The charter section this comes from, e.g. "2.1" or "Vocabulary Tier 3". */
  rule: string;
  message: string;
  /** Concrete replacement text where the charter supplies one. */
  suggestion?: string;
}

export interface CharterResult {
  issues: CharterIssue[];
  get: (severity: CharterSeverity) => CharterIssue[];
  /** True when nothing blocks submission. Warnings do not block. */
  ok: boolean;
}

// ─── Charter limits ──────────────────────────────────────────────────────────

/** §2.1 — maximum words per sentence in adapted text. */
export const MAX_WORDS_PER_SENTENCE = 8;
/** §2.1 — preferred range; exceeding it is a nudge, not a failure. */
export const PREFERRED_WORDS_PER_SENTENCE = 6;
/** §3.2 — hard maximum. */
export const MAX_MEMORY_PHRASE_WORDS = 4;
/** §3.3 — hard maximum. */
export const MAX_PRAYER_WORDS = 10;
/** §3.4 — hard maximum. */
export const MAX_QUESTION_WORDS = 10;

/**
 * Vocabulary Guide Tier 3 — "must never appear in little_bible, memory_phrase,
 * prayer, or discussion_question". Keys are matched case-insensitively on whole
 * words; the value is the charter's own suggested replacement.
 */
export const TIER_3_REPLACEMENTS: Record<string, string> = {
  understanding: 'knowing what is right / wisdom',
  instruction: 'teaching / what God teaches',
  perceive: 'know / understand / see',
  discretion: 'thinking carefully / making good choices',
  counsel: 'good advice / teaching',
  interpretation: 'what it means',
  covetousness: 'greed / always wanting more',
  prosperity: 'doing well / having good things',
  reproof: 'correction / being told you were wrong',
  subtilty: 'careful thinking / wisdom',
  equity: 'being fair / treating people right',
  concourse: 'busy place / where many people gather',
  uttereth: 'says / calls out / speaks',
  crieth: 'calls out / shouts / says loudly',
  hearkeneth: 'listens / pays attention',
  entice: 'try to get someone to do wrong',
  consent: 'agree / say yes',
  ornament: 'something beautiful',
  lurk: 'hide and wait',
  privily: 'in secret / hiding',
  calamity: 'big trouble / disaster',
  desolation: 'everything destroyed / nothing left',
  despise: 'really hate / want nothing to do with',
  attain: 'reach / get / learn',
  transgression: "breaking God's law / sinning",
  iniquity: 'sin / doing great wrong',
  abomination: 'something God hates / something very wrong',
  sanctification: 'becoming more like God',
  propitiation: 'the price paid for sin',
  atonement: 'making things right with God / being forgiven',
  justification: 'being made right with God',
  sanctify: 'set apart for God / make holy',
  sanctified: 'made holy / set apart',
  righteous: 'doing what God says is right',
  unrighteous: 'not doing what God says is right',
  wrath: "God's anger at sin",
  merciful: 'kind and forgiving / full of mercy',
  compassion: "caring deeply about someone's pain",
  omnipotent: 'all-powerful / able to do anything',
  omniscient: 'knows everything',
  omnipresent: 'everywhere at once',
  eternal: 'forever / never ends',
  sovereign: 'in charge of everything / the highest ruler',
  brethren: 'brothers / fellow believers',
  hath: 'has',
  doth: 'does',
  thee: 'you',
  thou: 'you',
  thy: 'your',
  thine: 'your',
  hast: 'have',
  ye: 'you (plural)',
  verily: 'truly / really',
  forsake: 'leave / abandon / stop following',
  behold: 'look / see',
  lest: 'so that / in case',
  slay: 'kill / destroy',
  smite: 'hit hard / strike down',
  perish: 'die / be destroyed',
  salvation: 'being saved / God rescuing us',
  redemption: 'being bought back / being freed',
  abide: 'stay / remain / live',
  cleave: 'hold tight / stay close',
};

/**
 * Vocabulary Guide Tier 2 — allowed, but must be explained on use or swapped for
 * Tier 1. Emitted as warnings so an editor is reminded to add the gloss.
 */
export const TIER_2_WORDS = new Set([
  'wisdom', 'obedience', 'praise', 'worship', 'commandment', 'peace', 'grace',
  'mercy', 'blessing', 'sin', 'creation', 'spirit', 'courage', 'promise',
  'warning', 'consequence', 'rescue', 'covenant', 'holy', 'shame', 'guilty',
  'forgiven', 'humble', 'proud', 'servant', 'shepherd', 'temple', 'offering',
  'sacrifice', 'faithful', 'glory',
]);

// ─── Text helpers ────────────────────────────────────────────────────────────

/** Charter word counting: punctuation attaches to its word ("God," is one word). */
export function countWords(text: string): number {
  return words(text).length;
}

export function words(text: string): string[] {
  return text.trim().split(/\s+/).filter((w) => w.replace(/[^\p{L}\p{N}]/gu, '').length > 0);
}

/** Splits on sentence-final punctuation, keeping only non-empty sentences. */
export function sentences(text: string): string[] {
  return text
    .split(/(?<=[.!?])\s+/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

function normalise(word: string): string {
  return word.toLowerCase().replace(/[^\p{L}\p{N}']/gu, '');
}

// ─── Rules ───────────────────────────────────────────────────────────────────

function checkVocabulary(field: CharterField, text: string, issues: CharterIssue[]): void {
  const seenTier3 = new Set<string>();
  const seenTier2 = new Set<string>();

  for (const raw of words(text)) {
    const word = normalise(raw);
    if (!word) continue;

    const replacement = TIER_3_REPLACEMENTS[word];
    if (replacement && !seenTier3.has(word)) {
      seenTier3.add(word);
      issues.push({
        field,
        severity: 'error',
        rule: 'Vocabulary Tier 3',
        message: `"${raw}" is Tier 3 vocabulary and must never appear in ${field}.`,
        suggestion: replacement,
      });
      continue;
    }

    if (TIER_2_WORDS.has(word) && !seenTier2.has(word)) {
      seenTier2.add(word);
      issues.push({
        field,
        severity: 'warning',
        rule: 'Vocabulary Tier 2',
        message: `"${raw}" is Tier 2 — explain it in the same breath or swap it for Tier 1 words.`,
        suggestion: `e.g. "${raw} — ${'a short explanation a 4-year-old would follow'}"`,
      });
    }
  }
}

function checkSentenceLengths(field: CharterField, text: string, issues: CharterIssue[]): void {
  for (const sentence of sentences(text)) {
    const count = countWords(sentence);
    if (count > MAX_WORDS_PER_SENTENCE) {
      issues.push({
        field,
        severity: 'error',
        rule: '2.1',
        message: `Sentence is ${count} words; the maximum is ${MAX_WORDS_PER_SENTENCE}. "${sentence}"`,
        suggestion: 'Split it into one sentence per idea — each under 8 words (§2.2).',
      });
    } else if (count > PREFERRED_WORDS_PER_SENTENCE) {
      issues.push({
        field,
        severity: 'warning',
        rule: '2.1',
        message: `Sentence is ${count} words; 3–6 is preferred. "${sentence}"`,
      });
    }
  }
}

function checkLittleBible(text: string, issues: CharterIssue[]): void {
  checkSentenceLengths('little_bible', text, issues);
  if (/\n\s*\n/.test(text)) {
    issues.push({
      field: 'little_bible',
      severity: 'error',
      rule: '2.1',
      message: 'Paragraphs are not permitted in adapted verse text.',
      suggestion: 'Use single sentences separated by a space.',
    });
  }
}

function checkMemoryPhrase(text: string, issues: CharterIssue[]): void {
  const count = countWords(text);
  if (count > MAX_MEMORY_PHRASE_WORDS) {
    issues.push({
      field: 'memory_phrase',
      severity: 'error',
      rule: '3.2',
      message: `Memory phrase is ${count} words; the hard maximum is ${MAX_MEMORY_PHRASE_WORDS}.`,
      suggestion: 'Cut to the core truth, e.g. "Wisdom starts with God."',
    });
  }
  if (text.trim() && /\?/.test(text)) {
    issues.push({
      field: 'memory_phrase',
      severity: 'error',
      rule: '3.2',
      message: 'A memory phrase states a truth; it is never a question.',
    });
  }
}

function checkPrayer(text: string, issues: CharterIssue[]): void {
  const trimmed = text.trim();
  const count = countWords(trimmed);

  if (count > MAX_PRAYER_WORDS) {
    issues.push({
      field: 'prayer',
      severity: 'error',
      rule: '3.3',
      message: `Prayer is ${count} words; the hard maximum is ${MAX_PRAYER_WORDS}.`,
    });
  }
  if (/^dear\s+god\b/i.test(trimmed)) {
    issues.push({
      field: 'prayer',
      severity: 'error',
      rule: '3.3',
      message: 'Prayers open with "God," — "Dear God," spends a word for nothing.',
      suggestion: trimmed.replace(/^dear\s+god\b/i, 'God'),
    });
  } else if (trimmed && !/^god\s*,/i.test(trimmed)) {
    issues.push({
      field: 'prayer',
      severity: 'error',
      rule: '3.3',
      message: 'Prayers must begin with "God,".',
      suggestion: `God, ${trimmed.charAt(0).toLowerCase()}${trimmed.slice(1)}`,
    });
  }
}

function checkDiscussionQuestion(text: string, issues: CharterIssue[]): void {
  const trimmed = text.trim();
  const count = countWords(trimmed);

  if (count > MAX_QUESTION_WORDS) {
    issues.push({
      field: 'discussion_question',
      severity: 'error',
      rule: '3.4',
      message: `Question is ${count} words; the hard maximum is ${MAX_QUESTION_WORDS}.`,
    });
  }
  const questionMarks = (trimmed.match(/\?/g) ?? []).length;
  if (questionMarks > 1) {
    issues.push({
      field: 'discussion_question',
      severity: 'error',
      rule: '3.4',
      message: 'One question only — never two questions in one field.',
    });
  }
  if (trimmed && questionMarks === 0) {
    issues.push({
      field: 'discussion_question',
      severity: 'error',
      rule: '3.4',
      message: 'The discussion field must be a question.',
      suggestion: `${trimmed.replace(/\.$/, '')}?`,
    });
  }
}

// ─── Public API ──────────────────────────────────────────────────────────────

function result(issues: CharterIssue[]): CharterResult {
  return {
    issues,
    get: (severity) => issues.filter((i) => i.severity === severity),
    ok: !issues.some((i) => i.severity === 'error'),
  };
}

/** Validates a single field. Called on blur in the admin editors. */
export function validate(field: CharterField, value: string): CharterResult {
  const issues: CharterIssue[] = [];
  const text = value ?? '';

  if (!text.trim()) return result(issues); // Emptiness is a form-level concern.

  checkVocabulary(field, text, issues);

  switch (field) {
    case 'little_bible':
      checkLittleBible(text, issues);
      break;
    case 'memory_phrase':
      checkMemoryPhrase(text, issues);
      break;
    case 'prayer':
      checkPrayer(text, issues);
      break;
    case 'discussion_question':
      checkDiscussionQuestion(text, issues);
      break;
  }

  return result(issues);
}

/** Validates a whole package's charter-governed fields in one pass. */
export function validateFields(fields: Partial<Record<CharterField, string>>): CharterResult {
  const issues: CharterIssue[] = [];
  for (const [field, value] of Object.entries(fields)) {
    if (typeof value !== 'string') continue;
    issues.push(...validate(field as CharterField, value).issues);
  }
  return result(issues);
}

// ─── Doctrinal advisories (§4) ───────────────────────────────────────────────

export interface DoctrinalAdvisory {
  policy: string;
  message: string;
}

/**
 * Compares a KJV source verse with its adaptation and surfaces the §4 policies a
 * reviewer must confirm by hand. These are never errors — a program cannot tell
 * whether meaning was preserved, only that a concept in the source has no obvious
 * echo in the adaptation.
 */
export function doctrinalAdvisories(kjv: string, adaptation: string): DoctrinalAdvisory[] {
  const source = kjv.toLowerCase();
  const adapted = adaptation.toLowerCase();
  const advisories: DoctrinalAdvisory[] = [];

  const mentions = (text: string, terms: string[]) => terms.some((t) => text.includes(t));

  if (mentions(source, ['fear of the lord', 'fear the lord', 'fear of god'])) {
    if (!mentions(adapted, ['respect', 'honour', 'honor', 'holy', 'great'])) {
      advisories.push({
        policy: '4.1 The Fear of the Lord',
        message:
          'The source verse carries the fear of the Lord, but the adaptation shows no reverence or awe. It must never be reduced to friendliness or dropped.',
      });
    }
  }

  if (mentions(source, ['sin', 'transgression', 'iniquity', 'wicked'])) {
    if (!mentions(adapted, ['wrong', 'disobey', 'sin', 'bad choice'])) {
      advisories.push({
        policy: '4.2 Sin',
        message:
          'The source verse names sin but the adaptation does not. Sin must never be reframed as a mere mistake or removed.',
      });
    }
    if (mentions(adapted, ['mistake', 'accident'])) {
      advisories.push({
        policy: '4.2 Sin',
        message:
          '"Mistake" / "accident" strips the moral dimension from sin. Use "doing wrong" or "disobeying God".',
      });
    }
  }

  if (mentions(source, ['repent', 'turn ye', 'return unto'])) {
    if (!mentions(adapted, ['turn back', 'come back', 'stop doing wrong', 'turn around'])) {
      advisories.push({
        policy: '4.3 Repentance',
        message: 'A call to repentance in the source has no counterpart in the adaptation.',
      });
    }
  }

  if (mentions(source, ['wrath', 'anger of the lord', 'judgment', 'judgement'])) {
    advisories.push({
      policy: '4.4 / 4.6 Judgment and Wrath',
      message:
        "Confirm the consequence is preserved and framed as God's justice — never as random anger, and never removed.",
    });
  }

  if (mentions(source, ['die', 'died', 'death', 'slay', 'slew', 'destroy'])) {
    advisories.push({
      policy: '4.5 Death and Destruction',
      message:
        'Confirm the severity is preserved while graphic detail is removed, and that the package sensitivity tier reflects it.',
    });
  }

  if (mentions(source, ['covenant', 'i will', 'promise'])) {
    advisories.push({
      policy: '4.7 Promises',
      message: 'Confirm every divine promise in the source appears clearly in the adaptation.',
    });
  }

  return advisories;
}
