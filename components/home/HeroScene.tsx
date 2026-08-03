'use client';

import LumiMascot from '@/components/mascot/LumiMascot';
import type { LumiStage } from '@/components/mascot/LumiMascot';

// Static star positions — no Math.random() to avoid hydration mismatch
const STARS = [
  { x: 7,  y: 5,  r: 1.8, op: 0.90, delay: 0.0 },
  { x: 21, y: 12, r: 1.1, op: 0.70, delay: 0.8 },
  { x: 37, y: 4,  r: 2.0, op: 0.85, delay: 1.5 },
  { x: 54, y: 9,  r: 1.4, op: 0.75, delay: 0.4 },
  { x: 68, y: 4,  r: 1.9, op: 0.80, delay: 1.1 },
  { x: 82, y: 13, r: 1.2, op: 0.65, delay: 0.6 },
  { x: 91, y: 7,  r: 1.6, op: 0.88, delay: 1.8 },
  { x: 14, y: 20, r: 1.0, op: 0.60, delay: 2.2 },
  { x: 47, y: 17, r: 1.5, op: 0.72, delay: 0.3 },
  { x: 76, y: 22, r: 0.9, op: 0.55, delay: 1.4 },
  { x: 30, y: 8,  r: 1.3, op: 0.78, delay: 2.0 },
  { x: 61, y: 15, r: 1.0, op: 0.62, delay: 0.9 },
];

// Floating seed sparkles
const SEEDS = [
  { x: 12, y: 45, delay: 0.0, dur: 3.2 },
  { x: 88, y: 38, delay: 1.1, dur: 2.8 },
  { x: 24, y: 62, delay: 0.6, dur: 3.6 },
  { x: 78, y: 58, delay: 1.8, dur: 3.0 },
  { x: 6,  y: 30, delay: 2.4, dur: 2.6 },
  { x: 94, y: 50, delay: 0.3, dur: 4.0 },
];

interface HeroSceneProps {
  lumiStage?: LumiStage;
}

export default function HeroScene({ lumiStage = 'sapling' }: HeroSceneProps) {
  return (
    <div className="relative w-full h-full min-h-[380px] lg:min-h-[440px] rounded-3xl overflow-hidden select-none">

      {/* ── Sky gradient ── */}
      <div
        className="absolute inset-0"
        style={{
          background:
            'linear-gradient(to bottom, #3B1201 0%, #6B2800 18%, #92400E 40%, #B45309 62%, #D97706 82%, #F59E0B 100%)',
        }}
        aria-hidden="true"
      />

      {/* ── Ambient glow emanating from Lumi ── */}
      <div
        className="absolute inset-0"
        style={{
          background:
            'radial-gradient(ellipse 65% 55% at 50% 42%, rgba(251,191,36,0.28) 0%, rgba(251,191,36,0.08) 50%, transparent 75%)',
        }}
        aria-hidden="true"
      />

      {/* ── Stars ── */}
      {STARS.map((s, i) => (
        <div
          key={i}
          className="absolute rounded-full bg-amber-100"
          style={{
            left: `${s.x}%`,
            top:  `${s.y}%`,
            width:   `${s.r * 2}px`,
            height:  `${s.r * 2}px`,
            opacity: s.op,
            animation: `twinkle 2.8s ${s.delay}s ease-in-out infinite alternate`,
          }}
          aria-hidden="true"
        />
      ))}

      {/* ── Floating seed sparkles ── */}
      {SEEDS.map((s, i) => (
        <div
          key={i}
          className="absolute"
          style={{
            left: `${s.x}%`,
            top:  `${s.y}%`,
            animation: `prayerRise ${s.dur}s ${s.delay}s ease-in-out infinite`,
          }}
          aria-hidden="true"
        >
          <div
            className="w-2 h-2 rounded-full bg-amber-300"
            style={{ opacity: 0.55, boxShadow: '0 0 6px 2px rgba(251,191,36,0.4)' }}
          />
        </div>
      ))}

      {/* ── Lumi — the hero ── */}
      <div
        className="absolute left-1/2 -translate-x-1/2"
        style={{ top: '12%' }}
        aria-label="Lumi — Little Bible mascot"
      >
        <LumiMascot
          stage={lumiStage}
          className="w-36 h-36 sm:w-44 sm:h-44"
          animate
        />
      </div>

      {/* ── Lumi speech bubble ── */}
      <div
        className="absolute"
        style={{ top: '8%', right: '10%' }}
        aria-hidden="true"
      >
        <div className="bg-white/92 backdrop-blur-sm rounded-2xl rounded-bl-none px-3 py-2 shadow-lg max-w-[128px] border border-white/60">
          <p className="text-amber-900 text-[11px] font-extrabold leading-snug text-center font-sans">
            Let&apos;s read God&apos;s Word!
          </p>
          <div className="flex justify-center gap-0.5 mt-1" aria-hidden="true">
            <span className="text-amber-400 text-[10px]">✦</span>
            <span className="text-amber-300 text-[9px]">✦</span>
            <span className="text-amber-400 text-[10px]">✦</span>
          </div>
        </div>
        {/* Bubble tail */}
        <div
          className="w-0 h-0"
          style={{
            borderLeft:  '6px solid transparent',
            borderRight: '6px solid transparent',
            borderTop:   '8px solid rgba(255,255,255,0.92)',
            marginLeft:  '8px',
          }}
        />
      </div>

      {/* ── Rolling hills — three depth layers ── */}
      <svg
        className="absolute w-full"
        style={{ bottom: '96px' }}
        viewBox="0 0 400 90"
        preserveAspectRatio="none"
        aria-hidden="true"
      >
        {/* Farthest hills */}
        <path
          d="M0,90 Q50,38 100,58 Q152,22 200,48 Q252,16 300,44 Q352,22 400,38 L400,90 Z"
          fill="#78350F"
          opacity="0.40"
        />
        {/* Mid hills */}
        <path
          d="M0,90 Q62,44 124,60 Q186,28 248,54 Q304,32 364,52 Q384,44 400,48 L400,90 Z"
          fill="#78350F"
          opacity="0.65"
        />
        {/* Front hills */}
        <path
          d="M0,90 Q84,54 168,66 Q252,44 336,60 Q368,52 400,57 L400,90 Z"
          fill="#92400E"
        />
      </svg>

      {/* ── Parent + child reading silhouette ── */}
      <svg
        className="absolute left-1/2 -translate-x-1/2"
        style={{ bottom: 0 }}
        width="210"
        height="100"
        viewBox="0 0 210 100"
        aria-label="Parent and child reading together"
      >
        {/* Ground shadow */}
        <ellipse cx="108" cy="97" rx="88" ry="6" fill="#3B1201" opacity="0.45" />

        {/* Parent figure */}
        <circle cx="138" cy="24" r="19" fill="#78350F" />
        <path
          d="M116,42 Q111,58 108,92 L168,92 Q165,58 160,42 Z"
          fill="#78350F"
        />
        {/* Parent arm wrapping around child */}
        <path
          d="M116,56 Q96,52 82,46"
          stroke="#78350F"
          strokeWidth="17"
          strokeLinecap="round"
          fill="none"
        />

        {/* Child figure */}
        <circle cx="70" cy="36" r="14" fill="#92400E" />
        <path
          d="M56,50 Q54,64 53,87 L88,87 Q87,64 84,50 Z"
          fill="#92400E"
        />

        {/* Glowing Bible/book between them */}
        <rect x="84" y="68" width="32" height="22" rx="5" fill="#FCD34D" opacity="0.92" />
        <rect
          x="84"
          y="68"
          width="32"
          height="22"
          rx="5"
          fill="#F59E0B"
          style={{ filter: 'blur(3px)', opacity: 0.35 }}
        />
        {/* Book spine line */}
        <line x1="100" y1="71" x2="100" y2="87" stroke="#D97706" strokeWidth="1.2" opacity="0.7" />
        {/* Book pages lines */}
        <line x1="103" y1="73" x2="114" y2="73" stroke="#D97706" strokeWidth="0.8" opacity="0.5" />
        <line x1="103" y1="77" x2="114" y2="77" stroke="#D97706" strokeWidth="0.8" opacity="0.5" />
        <line x1="103" y1="81" x2="114" y2="81" stroke="#D97706" strokeWidth="0.8" opacity="0.5" />
      </svg>

      {/* ── Bottom info chip ── */}
      <div
        className="absolute left-1/2 -translate-x-1/2 bottom-2.5 whitespace-nowrap z-10"
        aria-hidden="true"
      >
        <div className="flex items-center gap-1.5 bg-black/20 backdrop-blur-sm rounded-full px-3.5 py-1.5 border border-white/12">
          <span className="text-[11px]">🌐</span>
          <span className="text-white/85 text-[10px] font-semibold tracking-wide">Free on the web</span>
          <span className="text-amber-300/70 text-[10px] font-medium">· Now on Google Play</span>
        </div>
      </div>

    </div>
  );
}
