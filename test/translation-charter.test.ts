import { describe, expect, it } from 'vitest';
import {
  validate,
  validateFields,
  doctrinalAdvisories,
  countWords,
  sentences,
  MAX_WORDS_PER_SENTENCE,
} from '@/lib/content/translation-charter';

const errors = (field: Parameters<typeof validate>[0], value: string) =>
  validate(field, value).get('error');

describe('word counting (§3.3 worked example)', () => {
  it('counts punctuation as part of its word', () => {
    expect(countWords('God, help me obey You.')).toBe(5);
    expect(countWords('God, help me trust You in hard times.')).toBe(8);
  });

  it('ignores stray whitespace and punctuation-only tokens', () => {
    expect(countWords('  God,   help  me  ')).toBe(3);
    expect(countWords('')).toBe(0);
    expect(countWords(' — ')).toBe(0);
  });
});

describe('sentence splitting (§2.2)', () => {
  it('splits on sentence-final punctuation', () => {
    expect(sentences('These sayings help us learn wisdom. They show us what is right.')).toEqual([
      'These sayings help us learn wisdom.',
      'They show us what is right.',
    ]);
  });
});

describe('§2.1 sentence length in little_bible', () => {
  it('accepts the charter\'s own approved rewrite', () => {
    const result = validate(
      'little_bible',
      'These sayings help us learn wisdom. They show us what is right.',
    );
    expect(result.get('error')).toHaveLength(0);
  });

  it('rejects the charter\'s own 12-word negative example', () => {
    const found = errors(
      'little_bible',
      'These sayings will help you learn wisdom and understand what is right.',
    );
    expect(found).toHaveLength(1);
    expect(found[0].rule).toBe('2.1');
    expect(found[0].message).toContain('12 words');
    expect(found[0].suggestion).toContain('one sentence per idea');
  });

  it(`flags exactly at the ${MAX_WORDS_PER_SENTENCE + 1}-word boundary, not at the limit`, () => {
    const eight = 'God is good and kind and very true.';
    const nine = 'God is good and kind and very true today.';
    expect(countWords(eight)).toBe(MAX_WORDS_PER_SENTENCE);
    expect(errors('little_bible', eight)).toHaveLength(0);
    expect(errors('little_bible', nine)).toHaveLength(1);
  });

  it('nudges without blocking between the preferred and maximum length', () => {
    const result = validate('little_bible', 'God is very good and kind today.');
    expect(result.get('error')).toHaveLength(0);
    expect(result.get('warning').some((i) => i.rule === '2.1')).toBe(true);
    expect(result.ok).toBe(true);
  });

  it('rejects paragraphs', () => {
    const found = errors('little_bible', 'God is good.\n\nGod is kind.');
    expect(found.some((i) => i.message.includes('Paragraphs'))).toBe(true);
  });
});

describe('Tier 3 vocabulary', () => {
  it('rejects a Tier 3 word and supplies the charter\'s replacement', () => {
    const found = errors('little_bible', 'Behold the path.');
    expect(found).toHaveLength(1);
    expect(found[0].rule).toBe('Vocabulary Tier 3');
    expect(found[0].message).toContain('"Behold"');
    expect(found[0].suggestion).toBe('look / see');
  });

  it('matches case-insensitively and ignores attached punctuation', () => {
    expect(errors('prayer', 'God, help me, verily.').some((i) => i.suggestion === 'truly / really')).toBe(true);
  });

  it('reports each distinct Tier 3 word once, not once per occurrence', () => {
    const found = errors('little_bible', 'Behold. Behold. Behold.');
    expect(found.filter((i) => i.rule === 'Vocabulary Tier 3')).toHaveLength(1);
  });

  it('does not fire on a substring of a longer word', () => {
    // "ye" must not match inside "yes"; "thy" must not match inside "rhythm".
    expect(errors('little_bible', 'Say yes to God.')).toHaveLength(0);
  });

  it('applies to every charter-governed field', () => {
    for (const field of ['little_bible', 'memory_phrase', 'prayer', 'discussion_question'] as const) {
      expect(errors(field, 'behold').some((i) => i.rule === 'Vocabulary Tier 3')).toBe(true);
    }
  });

  it('warns on Tier 2 words without blocking', () => {
    const result = validate('little_bible', 'God gives us grace.');
    expect(result.ok).toBe(true);
    expect(result.get('warning').some((i) => i.rule === 'Vocabulary Tier 2')).toBe(true);
  });
});

describe('§3.2 memory phrase', () => {
  it.each([
    'Say no to wrong.',
    'Listen to your parents.',
    'Wisdom keeps us safe.',
    'Wisdom starts with God.',
    'God helps me understand.',
    'Choices have results.',
    'Never hurt the innocent.',
    'Seek God right now.',
  ])('accepts the approved example %j', (phrase) => {
    expect(errors('memory_phrase', phrase)).toHaveLength(0);
  });

  it.each([
    ['Wise people never stop learning.', 5],
    ['Listening to wisdom brings peace.', 5],
    ['Our choices grow into what we get.', 7],
  ])('rejects the charter\'s own rejected example %j', (phrase, count) => {
    const found = errors('memory_phrase', phrase);
    expect(found.some((i) => i.rule === '3.2' && i.message.includes(`${count} words`))).toBe(true);
  });

  it('rejects a question posing as a memory phrase', () => {
    expect(errors('memory_phrase', 'Is God good?').some((i) => i.message.includes('never a question'))).toBe(true);
  });
});

describe('§3.3 prayer', () => {
  it.each([
    'God, help me obey You.',
    'God, help me choose right.',
    'God, keep me on Your path.',
    'God, thank You for wise teachers.',
    'God, help me trust You in hard times.',
  ])('accepts the approved example %j', (prayer) => {
    expect(errors('prayer', prayer)).toHaveLength(0);
  });

  it('rejects "Dear God," and suggests the corrected opening', () => {
    const found = errors('prayer', 'Dear God, help me.');
    const issue = found.find((i) => i.message.includes('Dear God'));
    expect(issue).toBeDefined();
    expect(issue!.suggestion).toBe('God, help me.');
  });

  it('rejects a prayer that does not open with God,', () => {
    const found = errors('prayer', 'Help me be kind.');
    expect(found.some((i) => i.message.includes('must begin with "God,"'))).toBe(true);
    expect(found[0].suggestion).toBe('God, help me be kind.');
  });

  it('rejects a prayer over ten words', () => {
    const found = errors('prayer', 'God, please help me to be kind and good and gentle always.');
    expect(found.some((i) => i.message.includes('hard maximum is 10'))).toBe(true);
  });
});

describe('§3.4 discussion question', () => {
  it.each([
    'Who teaches you good things?',
    'What does being fair mean?',
    'How do we show respect to God?',
    'Why should we never stop learning?',
    'What does it feel like to be safe?',
  ])('accepts the approved example %j', (question) => {
    expect(errors('discussion_question', question)).toHaveLength(0);
  });

  it('rejects two questions in one field', () => {
    const found = errors('discussion_question', 'Who is God? What did He make?');
    expect(found.some((i) => i.message.includes('One question only'))).toBe(true);
  });

  it('rejects a statement and suggests the question form', () => {
    const found = errors('discussion_question', 'Tell me about God.');
    const issue = found.find((i) => i.message.includes('must be a question'));
    expect(issue?.suggestion).toBe('Tell me about God?');
  });

  it('rejects a question over ten words', () => {
    const found = errors(
      'discussion_question',
      'What do you think God wanted the people to learn here?',
    );
    expect(found.some((i) => i.message.includes('hard maximum is 10'))).toBe(true);
  });
});

describe('validateFields', () => {
  it('reports issues across every field in one pass', () => {
    const result = validateFields({
      memory_phrase: 'Wise people never stop learning.',
      prayer: 'Dear God, help me.',
      discussion_question: 'Tell me about God.',
    });
    const fields = new Set(result.get('error').map((i) => i.field));
    expect(fields).toEqual(new Set(['memory_phrase', 'prayer', 'discussion_question']));
    expect(result.ok).toBe(false);
  });

  it('passes a fully compliant package', () => {
    const result = validateFields({
      little_bible: 'God made everything. It was very good.',
      memory_phrase: 'God made everything.',
      prayer: 'God, thank You for everything.',
      discussion_question: 'What did God make?',
    });
    expect(result.ok).toBe(true);
  });

  it('treats an empty field as a form concern, not a charter violation', () => {
    expect(validate('prayer', '').issues).toHaveLength(0);
    expect(validate('memory_phrase', '   ').issues).toHaveLength(0);
  });
});

describe('doctrinal advisories (§4)', () => {
  it('flags a dropped fear of the Lord', () => {
    const found = doctrinalAdvisories(
      'The fear of the LORD is the beginning of knowledge',
      'Learning about God is fun.',
    );
    expect(found.some((a) => a.policy.startsWith('4.1'))).toBe(true);
  });

  it('accepts reverent language as preserving it', () => {
    const found = doctrinalAdvisories(
      'The fear of the LORD is the beginning of knowledge',
      'Respecting God is where wisdom begins.',
    );
    expect(found.some((a) => a.policy.startsWith('4.1'))).toBe(false);
  });

  it('flags sin softened into a mistake', () => {
    const found = doctrinalAdvisories('all have sinned', 'Everyone makes a mistake sometimes.');
    expect(found.some((a) => a.message.includes('strips the moral dimension'))).toBe(true);
  });

  it('asks a reviewer to confirm judgment and death passages', () => {
    expect(doctrinalAdvisories('the wrath of God', 'God is sad.').some((a) => a.policy.includes('4.4'))).toBe(true);
    expect(doctrinalAdvisories('they shall surely die', 'It ended badly.').some((a) => a.policy.startsWith('4.5'))).toBe(true);
  });

  it('stays quiet on a passage that raises none of the policies', () => {
    expect(doctrinalAdvisories('God is love', 'God loves us.')).toHaveLength(0);
  });
});
