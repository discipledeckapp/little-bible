# Little Bible — Translation Charter
**Version 1.0 | Established 2026-06-12 | BINDING on all content**

---

> This charter governs every word written for Little Bible.
> It applies to all books, all chapters, all languages, all contributors.
> No content may be published that has not been checked against this charter.

---

## Part 1 — Purpose and Source

### 1.1 Source Text
The Little Bible is adapted from the **King James Version (KJV)** of the Bible, which is in the public domain.

- The KJV is the authoritative source text.
- No verse may be omitted, skipped, or merged with another verse.
- The `kjv` field in every verse object must contain the exact KJV text, unmodified.

### 1.2 Nature of the Adaptation
Little Bible is a **child-accessible adaptation**, not a paraphrase or a loose retelling.

- Every idea present in the source verse must appear in the `little_bible` field.
- No doctrine may be added that is not present in the source verse.
- No doctrine may be removed to make the text more comfortable.
- The adaptation must be faithful enough that a theologian reviewing it would confirm all essential meaning is preserved.

### 1.3 Target Reading Level
**Primary target: Age 4–5** (being read aloud by a parent)
**Secondary target: Age 6–7** (emerging independent reader)

Every verse must pass this test:
> *"If I read this aloud to a typical 4-year-old right now, would they understand every sentence?"*

If the answer is no — simplify. Do not publish.

---

## Part 2 — Sentence Rules

### 2.1 Length
| Rule | Requirement |
|------|-------------|
| Maximum words per sentence | **8** |
| Preferred sentence length | **3–6 words** |
| Ideas per sentence | **1** |
| Paragraphs | **Not permitted** |

### 2.2 Breaking Complex Verses
When a KJV verse contains multiple ideas:
1. Identify each distinct idea.
2. Write one sentence per idea.
3. Every sentence must independently pass the 8-word rule.

**Example:**

KJV (Proverbs 1:2):
> "To know wisdom and instruction; to perceive the words of understanding;"

Wrong:
> "These sayings will help you learn wisdom and understand what is right." *(12 words)*

Correct:
> "These sayings help us learn wisdom. They show us what is right." *(7 words + 7 words ✓)*

### 2.3 Voice
- Active voice preferred.
- Second person ("you") or first person plural ("we") for relational connection.
- Warm, direct, gentle.
- Present tense where possible.

---

## Part 3 — Field Standards

### 3.1 `little_bible`
- Max 8 words per sentence. Prefer 3–6.
- One idea per sentence. Multiple sentences allowed.
- No prohibited vocabulary (see Vocabulary Guide).
- Full theological content of source verse preserved.
- Passes 4-year-old read-aloud comprehension test.

### 3.2 `memory_phrase`
- **Hard maximum: 4 words.**
- Must be a complete, self-contained theological truth.
- Must directly reflect the verse's core message — not a peripheral detail.
- Must be memorizable by a 4-year-old.
- Written as something a child could say to themselves or recite unprompted.

**Approved examples:**
```
Say no to wrong.
Listen to your parents.
Wisdom keeps us safe.
Wisdom starts with God.
God helps me understand.
Choices have results.
Never hurt the innocent.
Seek God right now.
```

**Rejected examples (with reasons):**
```
Wise people never stop learning.     → 5 words, too long
Listening to wisdom brings peace.    → 5 words, too long
Our choices grow into what we get.   → 7 words, far too long
```

### 3.3 `prayer`
- **Hard maximum: 10 words.**
- Must begin with `God,` — never `Dear God,` (adds a word unnecessarily).
- Must be a genuine prayer — a request or thanksgiving, not a declaration.
- Must connect directly to the verse's message.
- Must be prayed naturally by a child.

**Approved examples:**
```
God, help me obey You.
God, help me choose right.
God, keep me on Your path.
God, thank You for wise teachers.
God, help me trust You in hard times.
```

**Word counting:**
> God(1), help(2) me(3) obey(4) You(5). = 5 words ✓
> God(1), help(2) me(3) trust(4) You(5) in(6) hard(7) times(8). = 8 words ✓

### 3.4 `discussion_question`
- **Hard maximum: 10 words.**
- One question only. Never two questions in one field.
- Must be answerable by a child who has heard only the `little_bible` text.
- Opens a natural parent-child conversation.
- Preferred starters: Who, What, Why, How, Can you.

**Approved examples:**
```
Who teaches you good things?
What does being fair mean?
How do we show respect to God?
Why should we never stop learning?
What does it feel like to be safe?
```

---

## Part 4 — Doctrinal Policies

### 4.1 The Fear of the Lord
**Policy: Never remove. Never soften to mere friendliness.**

The fear of the Lord is the foundation of biblical wisdom (Proverbs 1:7, 9:10). It must be present in any verse where it appears in the source text.

**Approved child-level translations:**
- "Respecting God is where wisdom begins."
- "God is great and holy. That is where wisdom starts."
- "Honor God. Listen to Him. That is wisdom."

**Forbidden translations:**
- "Be a little bit scared of God" *(trivializes)*
- "Love God" *(alone — removes the element of awe and reverence)*
- Omitting the concept entirely

### 4.2 Sin
**Policy: Never remove. Never reframe as mere mistakes.**

Sin is willful disobedience against God. It must be distinguished from accidents or mistakes.

**Approved terms:**
- "doing wrong"
- "disobeying God"
- "choosing the wrong path"
- "bad choices"

**Forbidden framings:**
- "making a mistake" *(alone — removes moral dimension)*
- "accidents" *(unless the verse is about unintentional acts)*
- Omitting sin where it appears in the source

### 4.3 Repentance
**Policy: Always preserve repentance calls. Frame as turning back to God.**

**Approved terms:**
- "turn back to God"
- "stop doing wrong"
- "come back to God"
- "turn around and listen"

### 4.4 Judgment and Consequences
**Policy: Never remove. Consequences are acts of God's justice and love.**

When a verse describes judgment or consequences:
- Preserve the consequence clearly.
- Frame it as the natural result of choices.
- Do not make God sound cruel — but do not remove His justice.

**Approved framing:**
- "Bad choices always come back to us."
- "When we ignore God, trouble follows."
- "God is fair. Wrong choices have results."

### 4.5 Death and Destruction
When a verse mentions death or severe destruction:
- Preserve the warning.
- Remove graphic detail while keeping the severity.
- Use: "They got hurt very badly." / "It ended very badly for them." / "They suffered greatly."

### 4.6 God's Wrath
God's wrath is an expression of His holy justice against sin — not cruelty.
- Never present God as randomly angry.
- Frame as: "God is holy. He cannot be okay with wrong. That is why it matters."
- Always hold wrath alongside love and mercy where both appear in the passage context.

### 4.7 Promises
**Policy: Every divine promise must be preserved.**

Promises are among the most important content for a child's faith formation. When a verse contains a promise from God:
- The promise must appear clearly in `little_bible`.
- The `memory_phrase` should ideally capture the promise.
- The `meaning` field should explain the theological weight of the promise.

### 4.8 Commands
**Policy: Every command must be preserved.**

God's commands are not optional suggestions. When a verse contains a command:
- The command form must be preserved in `little_bible` (imperative voice).
- The `discussion_question` should invite a response to the command.

### 4.9 Jesus Christ in the Old Testament
When translating Old Testament passages that foreshadow Christ:
- The `little_bible` text should not artificially insert Jesus.
- The `meaning` field may note the connection to Christ.
- The `parent_guide` should help parents make the connection when appropriate.

### 4.10 The Gospel
Little Bible exists in the context of the whole Gospel. No chapter should be translated in a way that presents salvation by works, moralism, or self-improvement alone. The Gospel background — humanity's need for God, God's provision through Christ — should inform the `meaning` and `parent_guide` fields even in Old Testament wisdom literature.

---

## Part 5 — Multi-Language Translation

When translating an existing English `little_bible` verse into another language:

1. The **English Little Bible text** is the source — not the KJV directly.
2. Translate `little_bible`, `memory_phrase`, `prayer`, and `discussion_question`.
3. Word limits apply in the target language (approximate equivalence is acceptable).
4. Translate `chapter_summary`, `main_lesson`, `parent_guide`, and `application_for_children`.
5. Do not translate `kjv` — this field always remains in English KJV.
6. Adjust `keywords` if needed for the illustration system.

---

## Part 6 — Content Integrity Rules

### 6.1 No verse skipping
Every verse of every chapter must be translated. If a verse is particularly difficult (e.g., adult content, extreme violence), apply the difficulty handling rules in `LittleBible_Theology_Guide.md` — do not skip.

### 6.2 No verse merging
Each verse object must correspond to exactly one KJV verse. Do not merge two verses into one object.

### 6.3 No additions
The `little_bible` field must not add theological content not present in the source verse. The `meaning` field may add cross-references and theological depth.

### 6.4 Consistency across chapters
Before translating a new chapter, review the most recently published chapter. Match:
- Sentence style and length
- Vocabulary level
- Memory phrase format
- Prayer opening format
- Theological framing

### 6.5 Version control
When this charter is updated, the version number increments. All content produced under older versions must be audited for the new requirements before new chapters are published.
