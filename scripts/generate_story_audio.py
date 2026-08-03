"""
Generate story narration audio using Microsoft Edge TTS (free, no API key).

Voice: en-US-AriaNeural — warm, clear, child-friendly.
Alternative child-friendly voices to try:
  en-US-JennyNeural     — friendly, slightly higher pitch
  en-US-MichelleNeural  — calm and warm
  en-GB-SoniaNeural     — clear British accent

Run: python3 scripts/generate_story_audio.py
Output: mobile/assets/audio/stories/{storyId}/scene_{n}.mp3
"""

import asyncio
import json
import os
from pathlib import Path
import edge_tts

VOICE = "en-US-AriaNeural"
STORIES_DIR = Path("mobile/assets/stories")
AUDIO_DIR = Path("mobile/assets/audio/stories")

# Prosody adjustments for a children's app — slightly slower, engaged tone
RATE = "-10%"   # slightly slower than normal
PITCH = "+5Hz"  # slightly warmer


async def generate_scene(text: str, output_path: Path) -> None:
    communicate = edge_tts.Communicate(
        text=text,
        voice=VOICE,
        rate=RATE,
        pitch=PITCH,
    )
    await communicate.save(str(output_path))
    print(f"  ✓ {output_path.name}")


async def process_story(story_path: Path) -> None:
    with open(story_path, encoding="utf-8") as f:
        story = json.load(f)

    story_id = story["id"]
    child_text: str = story["steps"]["read"]["childText"]
    memory_verse: str = story["steps"]["remember"]["memoryVerse"]
    verse_ref: str = story["steps"]["remember"]["ref"]
    verses: list = story["steps"]["read"].get("verses", [])

    scenes = [s.strip() for s in child_text.split("\n\n") if s.strip()]

    out_dir = AUDIO_DIR / story_id
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n📖 {story['title']} ({story_id}) — {len(scenes)} scenes, {len(verses)} verses")

    tasks = []

    # Story scenes
    for i, scene in enumerate(scenes):
        out = out_dir / f"scene_{i}.mp3"
        if out.exists():
            print(f"  – scene_{i}.mp3 already exists, skipping")
        else:
            tasks.append(generate_scene(scene, out))

    # Bible passage verses — used by BibleVerseScreen (Edge TTS preferred over device TTS)
    for i, verse in enumerate(verses):
        out = out_dir / f"verse_{i}.mp3"
        if out.exists():
            print(f"  – verse_{i}.mp3 already exists, skipping")
        else:
            lb = verse.get("little_bible", "").strip()
            ref = verse.get("ref", "").strip()
            if lb:
                # Speak the text then the reference so the child hears the citation.
                text = f"{lb}  {ref}." if ref else lb
                tasks.append(generate_scene(text, out))

    # Memory verse (used by KeyVerseScreen)
    verse_out = out_dir / "memory_verse.mp3"
    if not verse_out.exists():
        verse_text = f"{memory_verse}. {verse_ref}."
        tasks.append(generate_scene(verse_text, verse_out))

    await asyncio.gather(*tasks)
    print(f"  Done ✓")


UI_PHRASES = {
    "find_the_missing_word": "Find the missing word!",
    "well_done": "Well done!",
    "keep_trying": "Keep trying — you can do it!",
    "game_complete": "Amazing! You finished all the games!",
    "colour_time": "Time to colour! Tap the shapes to fill them.",
    "verse_intro": "Let's learn this verse together.",
}


async def generate_ui_audio() -> None:
    out_dir = AUDIO_DIR / "_ui"
    out_dir.mkdir(parents=True, exist_ok=True)
    print("\n🎮 UI phrases")
    tasks = []
    for key, text in UI_PHRASES.items():
        out = out_dir / f"{key}.mp3"
        if out.exists():
            print(f"  – {key}.mp3 already exists, skipping")
        else:
            tasks.append(generate_scene(text, out))
    await asyncio.gather(*tasks)


async def main() -> None:
    if not STORIES_DIR.exists():
        print("Run this script from the Little_Bible project root.")
        return

    story_files = sorted(STORIES_DIR.glob("*.json"))
    if not story_files:
        print("No story JSON files found.")
        return

    print(f"Generating audio for {len(story_files)} stories using {VOICE}...")
    for path in story_files:
        await process_story(path)

    await generate_ui_audio()

    print("\n✅ All audio generated.")
    print(f"Output: {AUDIO_DIR.resolve()}")
    print("\nNext: ensure assets/audio/ paths are declared in pubspec.yaml, then rebuild.")


if __name__ == "__main__":
    asyncio.run(main())
