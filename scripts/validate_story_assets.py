#!/usr/bin/env python3
"""Audit every Little Bible story against the mandatory-asset + registration checklist.

Run from the project root:  python3 scripts/validate_story_assets.py

Checks, for every JSON in mobile/assets/stories/:
  - story JSON shape (id matches filename, all five steps, verses, memory verse/phrase)
  - activity JSON: memoryBuilder (phrase MUST equal the story memoryPhrase), sequence (4 items,
    orders 1-4), matches (3 pairs), application (3 options + followUp)
  - Edge TTS audio: one scene_N.mp3 per childText paragraph, one verse_N.mp3 per verse,
    memory_verse.mp3, and no stale scene files left behind by a scene-count change
  - all seven registrations: _curriculumOrder, kSceneRegistry, coloring _sceneFor, pubspec audio
    dir, golden-test storyIds, mobile manifest route, home_screen slot (not still comingSoon)
  - goldens: card + wide at t=0.0/0.5/1.0
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
M = os.path.join(ROOT, "mobile")

def read(p):
    with open(p) as f:
        return f.read()

stories_dir = os.path.join(M, "assets/stories")
story_ids = sorted(f[:-5] for f in os.listdir(stories_dir) if f.endswith(".json"))

content_service = read(os.path.join(M, "lib/core/services/content_service.dart"))
curriculum_order = re.search(r"_curriculumOrder = \[(.*?)\n\];", content_service, re.S).group(1)
ordered = re.findall(r"'([a-z0-9-]+)'", curriculum_order)

scene_painter = read(os.path.join(M, "lib/features/story/widgets/scene_painter.dart"))
registry = re.search(r"kSceneRegistry\s*=\s*\{(.*?)\n\};", scene_painter, re.S).group(1)
registered = set(re.findall(r"'([a-z0-9-]+)'\s*:", registry))

coloring = read(os.path.join(M, "lib/features/story/screens/coloring_screen.dart"))
coloring_cases = set(re.findall(r"case '([a-z0-9-]+)'", coloring))

pubspec = read(os.path.join(M, "pubspec.yaml"))
pubspec_dirs = set(re.findall(r"assets/audio/stories/([a-z0-9-]+)/", pubspec))

golden = read(os.path.join(M, "test/widget/scene_painter_golden_test.dart"))
golden_ids = set(re.findall(r"'([a-z0-9-]+)'", golden))

home = read(os.path.join(M, "lib/features/home/screens/home_screen.dart"))
manifest = read(os.path.join(ROOT, "app/api/mobile/manifest/route.ts"))
manifest_ids = set(re.findall(r"'([a-z0-9-]+)'", manifest)) | set(re.findall(r'"([a-z0-9-]+)"', manifest))

problems = []

def flag(sid, msg):
    problems.append(f"{sid}: {msg}")

for sid in story_ids:
    s = json.loads(read(os.path.join(stories_dir, f"{sid}.json")))
    steps = s.get("steps", {})

    # --- story JSON shape
    for k in ("id", "title", "subtitle"):
        if not s.get(k):
            flag(sid, f"story JSON missing '{k}'")
    if s.get("id") != sid:
        flag(sid, f"story JSON id '{s.get('id')}' != filename")
    for k in ("read", "remember", "discuss", "pray", "doToday"):
        if k not in steps:
            flag(sid, f"steps.{k} missing")
    read_step = steps.get("read", {})
    raw_child = (read_step.get("childText") or "").strip() or (read_step.get("text") or "")
    child_scenes = [s for s in raw_child.split("\n\n") if s.strip()]
    if not child_scenes:
        flag(sid, "steps.read.childText empty")
    verses = read_step.get("verses") or []
    if not verses:
        flag(sid, "steps.read.verses empty")
    for i, v in enumerate(verses):
        if not v.get("little_bible"):
            flag(sid, f"verse[{i}] missing little_bible")
    remember = steps.get("remember", {})
    phrase = remember.get("memoryPhrase")
    if not remember.get("memoryVerse"):
        flag(sid, "remember.memoryVerse missing")
    if not phrase:
        flag(sid, "remember.memoryPhrase missing")

    # --- activity JSON
    apath = os.path.join(M, "assets/activities", f"{sid}.json")
    if not os.path.exists(apath):
        flag(sid, "ACTIVITY JSON MISSING")
    else:
        a = json.loads(read(apath))
        mb = a.get("memoryBuilder")
        if not mb:
            flag(sid, "activity.memoryBuilder missing")
        else:
            if phrase and mb.get("phrase") != phrase:
                flag(sid, f"memoryBuilder.phrase != story memoryPhrase\n     story:    {phrase!r}\n     activity: {mb.get('phrase')!r}")
            if mb.get("phraseWords") != (mb.get("phrase") or "").split(" "):
                flag(sid, "memoryBuilder.phraseWords != phrase.split(' ')")
            for k in ("verseRef", "verseText", "verseWords"):
                if not mb.get(k):
                    flag(sid, f"memoryBuilder.{k} missing")
            # verseWords is the Fill-the-Gap distractor pool, not a strict split of
            # verseText — but every word must come from the verse, and there must be
            # enough >=3-letter words to fill 2 distractors per question.
            # (verseText is the KJV; verseWords is the child-friendly rendering,
            #  so they deliberately differ.)
            vw = mb.get("verseWords") or []
            if len({w for w in vw if len(w) >= 3}) < 3:
                flag(sid, "verseWords has <3 distinct words of length>=3 (too few distractors)")
        seq = a.get("sequence")
        if not seq:
            flag(sid, "activity.sequence missing")
        else:
            items = seq.get("items") or []
            if len(items) != 4:
                flag(sid, f"sequence has {len(items)} items (need 4)")
            if sorted(i.get("order") for i in items) != [1, 2, 3, 4]:
                flag(sid, "sequence orders != 1..4")
            for i in items:
                for k in ("id", "label", "emoji"):
                    if not i.get(k):
                        flag(sid, f"sequence item missing {k}")
        mt = a.get("matches")
        if not mt:
            flag(sid, "activity.matches missing")
        else:
            pairs = mt.get("pairs") or []
            if len(pairs) != 3:
                flag(sid, f"matches has {len(pairs)} pairs (need 3)")
            for p in pairs:
                for k in ("leftId", "left", "leftEmoji", "rightId", "right", "rightEmoji"):
                    if not p.get(k):
                        flag(sid, f"matches pair missing {k}")
        ap = a.get("application")
        if not ap:
            flag(sid, "activity.application missing")
        else:
            if not ap.get("question"):
                flag(sid, "application.question missing")
            if len(ap.get("options") or []) != 3:
                flag(sid, f"application has {len(ap.get('options') or [])} options (need 3)")
            if not ap.get("followUp"):
                flag(sid, "application.followUp missing")

    # --- audio
    adir = os.path.join(M, "assets/audio/stories", sid)
    if not os.path.isdir(adir):
        flag(sid, "AUDIO DIR MISSING")
    else:
        files = set(os.listdir(adir))
        for n in range(len(child_scenes)):
            if f"scene_{n}.mp3" not in files:
                flag(sid, f"missing scene_{n}.mp3")
        for n in range(len(verses)):
            if f"verse_{n}.mp3" not in files:
                flag(sid, f"missing verse_{n}.mp3")
        if "memory_verse.mp3" not in files:
            flag(sid, "missing memory_verse.mp3")
        extra_scenes = [f for f in files if re.match(r"scene_\d+\.mp3", f)
                        and int(f[6:-4]) >= len(child_scenes)]
        if extra_scenes:
            flag(sid, f"stale audio (scene count changed?): {sorted(extra_scenes)}")

    # --- registrations
    if sid not in ordered:
        flag(sid, "not in content_service _curriculumOrder")
    if sid not in registered:
        flag(sid, "not in kSceneRegistry")
    if sid not in coloring_cases:
        flag(sid, "no coloring_screen _sceneFor case")
    if sid not in pubspec_dirs:
        flag(sid, "audio dir not declared in pubspec.yaml")
    if sid not in golden_ids:
        flag(sid, "not in scene_painter_golden_test storyIds")
    if sid not in manifest_ids:
        flag(sid, "not in app/api/mobile/manifest/route.ts")
    if sid not in home:
        flag(sid, "not referenced in home_screen.dart")
    elif re.search(r"'" + re.escape(sid) + r"'[^\n]*comingSoon:\s*true", home):
        flag(sid, "home_screen slot still comingSoon: true")

    # --- goldens
    gdir = os.path.join(M, "test/widget/goldens")
    for aspect in ("card", "wide"):
        for t in ("t0_0", "t0_5", "t1_0"):
            gp = os.path.join(gdir, f"scene_{sid}_{aspect}_{t}.png")
            if not os.path.exists(gp):
                flag(sid, f"missing golden scene_{sid}_{aspect}_{t}.png")

extra_ordered = [s for s in ordered if s not in story_ids]
if extra_ordered:
    problems.append(f"_curriculumOrder references non-existent stories: {extra_ordered}")
not_ordered = [s for s in story_ids if s not in ordered]

print(f"stories on disk: {len(story_ids)}   in _curriculumOrder: {len(ordered)}")
if not_ordered:
    print(f"on disk but not in curriculum order: {not_ordered}")
print()
if problems:
    print(f"### {len(problems)} PROBLEM(S)\n")
    for p in problems:
        print("  -", p)
    sys.exit(1)

print("### ALL CLEAN")
