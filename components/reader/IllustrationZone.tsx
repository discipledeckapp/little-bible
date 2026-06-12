'use client';

import { useState } from 'react';
import { getVerseScene, getIllustrationPath } from '@/lib/illustrations';

interface IllustrationZoneProps {
  bookSlug: string;
  chapter: number;
  verse: number;
  keywords: string[];
  lang?: string;
  illustrationPrompt?: string;
}

export default function IllustrationZone({
  bookSlug,
  chapter,
  verse,
  keywords,
  lang = 'en',
  illustrationPrompt,
}: IllustrationZoneProps) {
  const [imgError, setImgError] = useState(false);
  const svgPath = getIllustrationPath(bookSlug, chapter, verse, lang);
  const emojiScene = getVerseScene(keywords);

  return (
    <div
      className="w-full bg-gradient-to-br from-amber-50 to-amber-100 rounded-3xl overflow-hidden border border-amber-100"
      aria-hidden={!illustrationPrompt}
      aria-label={illustrationPrompt || undefined}
    >
      <div className="h-44 sm:h-52 flex items-center justify-center">
        {!imgError ? (
          <img
            src={svgPath}
            alt=""
            className="w-full h-full object-contain p-6"
            onError={() => setImgError(true)}
          />
        ) : (
          <div className="flex flex-col items-center justify-center gap-1 select-none">
            <div className="text-6xl sm:text-7xl leading-none">
              {emojiScene.split('').slice(0, 2).join('')}
            </div>
            <div className="text-4xl sm:text-5xl leading-none opacity-70">
              {emojiScene.split('').slice(2).join('')}
            </div>
          </div>
        )}
      </div>
      {illustrationPrompt && (
        <p className="text-center text-amber-600 text-xs font-semibold px-4 pb-3 -mt-1 italic">
          {illustrationPrompt}
        </p>
      )}
    </div>
  );
}
