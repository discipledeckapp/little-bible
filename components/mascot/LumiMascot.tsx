export type LumiStage = 'seed' | 'sprout' | 'plant' | 'tree';

export function getLumiStage(seeds: number): LumiStage {
  if (seeds >= 100) return 'tree';
  if (seeds >= 51)  return 'plant';
  if (seeds >= 21)  return 'sprout';
  return 'seed';
}

export function getLumiLabel(stage: LumiStage): string {
  switch (stage) {
    case 'seed':   return 'Wisdom Seed';
    case 'sprout': return 'Wisdom Sprout';
    case 'plant':  return 'Wisdom Plant';
    case 'tree':   return 'Wisdom Tree';
  }
}

interface LumiMascotProps {
  stage?: LumiStage;
  className?: string;
  animate?: boolean;
}

export default function LumiMascot({ stage = 'seed', className = '', animate = false }: LumiMascotProps) {
  return (
    <svg
      viewBox="0 0 80 96"
      fill="none"
      className={`${className} ${animate ? 'animate-bounce' : ''}`}
      aria-hidden="true"
      role="img"
    >
      {stage === 'seed'   && <LumiSeed />}
      {stage === 'sprout' && <LumiSprout />}
      {stage === 'plant'  && <LumiPlant />}
      {stage === 'tree'   && <LumiTree />}
    </svg>
  );
}

function LumiSeed() {
  return (
    <>
      {/* Outer glow */}
      <ellipse cx="40" cy="60" rx="32" ry="30" fill="#FCD34D" opacity="0.18" />
      <ellipse cx="40" cy="60" rx="24" ry="22" fill="#FDE68A" opacity="0.22" />
      {/* Seed body */}
      <ellipse cx="40" cy="62" rx="20" ry="23" fill="#FBBF24" />
      <ellipse cx="40" cy="55" rx="20" ry="16" fill="#F59E0B" />
      {/* Single leaf */}
      <path d="M40 34 Q30 22 34 14 Q46 18 40 34Z" fill="#34D399" />
      <path d="M40 34 Q37 24 39 16" stroke="#10B981" strokeWidth="1.2" strokeLinecap="round" />
      {/* Eyes */}
      <circle cx="33.5" cy="58" r="2.8" fill="#78350F" />
      <circle cx="46.5" cy="58" r="2.8" fill="#78350F" />
      <circle cx="34.2" cy="57.2" r="0.9" fill="white" />
      <circle cx="47.2" cy="57.2" r="0.9" fill="white" />
      {/* Smile */}
      <path d="M34 67 Q40 72 46 67" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
      {/* Sparkles */}
      <circle cx="26" cy="50" r="2.2" fill="#FEF3C7" opacity="0.85" />
      <circle cx="55" cy="48" r="1.6" fill="#FEF3C7" opacity="0.75" />
      <circle cx="22" cy="62" r="1.4" fill="#FEF3C7" opacity="0.6" />
    </>
  );
}

function LumiSprout() {
  return (
    <>
      {/* Glow */}
      <ellipse cx="40" cy="66" rx="32" ry="28" fill="#FCD34D" opacity="0.2" />
      <ellipse cx="40" cy="66" rx="24" ry="20" fill="#FDE68A" opacity="0.25" />
      {/* Stem */}
      <rect x="37.5" y="28" width="5" height="28" rx="2.5" fill="#34D399" />
      {/* Left leaf */}
      <path d="M40 42 Q20 32 22 20 Q38 22 40 42Z" fill="#4ADE80" />
      {/* Right leaf */}
      <path d="M40 48 Q60 38 58 26 Q42 28 40 48Z" fill="#34D399" />
      {/* Body */}
      <ellipse cx="40" cy="72" rx="19" ry="20" fill="#FBBF24" />
      <ellipse cx="40" cy="66" rx="19" ry="14" fill="#F59E0B" />
      {/* Eyes */}
      <circle cx="33.5" cy="70" r="2.8" fill="#78350F" />
      <circle cx="46.5" cy="70" r="2.8" fill="#78350F" />
      <circle cx="34.2" cy="69.2" r="0.9" fill="white" />
      <circle cx="47.2" cy="69.2" r="0.9" fill="white" />
      {/* Smile */}
      <path d="M34 78 Q40 83.5 46 78" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
      {/* Sparkles */}
      <circle cx="24" cy="58" r="2" fill="#FEF3C7" opacity="0.85" />
      <circle cx="57" cy="55" r="1.6" fill="#FEF3C7" opacity="0.75" />
    </>
  );
}

function LumiPlant() {
  return (
    <>
      {/* Glow */}
      <ellipse cx="40" cy="68" rx="34" ry="28" fill="#FCD34D" opacity="0.22" />
      <ellipse cx="40" cy="68" rx="26" ry="20" fill="#FDE68A" opacity="0.28" />
      {/* Stem */}
      <rect x="37.5" y="22" width="5" height="38" rx="2.5" fill="#34D399" />
      {/* Lower leaves */}
      <path d="M40 50 Q18 42 18 28 Q36 28 40 50Z" fill="#4ADE80" />
      <path d="M40 56 Q62 48 62 34 Q44 34 40 56Z" fill="#34D399" />
      {/* Upper leaves */}
      <path d="M40 36 Q24 26 26 14 Q40 16 40 36Z" fill="#6EE7B7" />
      <path d="M40 30 Q56 20 54 10 Q40 12 40 30Z" fill="#4ADE80" />
      {/* Tiny flower buds */}
      <circle cx="26" cy="13" r="4" fill="#FCD34D" />
      <circle cx="55" cy="9"  r="3.5" fill="#FDE68A" />
      {/* Body */}
      <ellipse cx="40" cy="76" rx="18" ry="19" fill="#FBBF24" />
      <ellipse cx="40" cy="70" rx="18" ry="13" fill="#F59E0B" />
      {/* Eyes */}
      <circle cx="33.5" cy="73" r="2.8" fill="#78350F" />
      <circle cx="46.5" cy="73" r="2.8" fill="#78350F" />
      <circle cx="34.2" cy="72.2" r="0.9" fill="white" />
      <circle cx="47.2" cy="72.2" r="0.9" fill="white" />
      {/* Big happy smile */}
      <path d="M32 81 Q40 88 48 81" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      {/* Sparkles */}
      <circle cx="14" cy="50" r="2.2" fill="#FEF3C7" opacity="0.8" />
      <circle cx="66" cy="46" r="1.8" fill="#FEF3C7" opacity="0.7" />
      <circle cx="10" cy="64" r="1.5" fill="#FEF3C7" opacity="0.6" />
    </>
  );
}

function LumiTree() {
  return (
    <>
      {/* Large glow */}
      <ellipse cx="40" cy="60" rx="38" ry="36" fill="#FCD34D" opacity="0.2" />
      <ellipse cx="40" cy="60" rx="30" ry="28" fill="#FDE68A" opacity="0.25" />
      {/* Trunk */}
      <rect x="36" y="44" width="8" height="44" rx="4" fill="#92400E" />
      {/* Crown — layered circles */}
      <circle cx="40" cy="28" r="22" fill="#34D399" />
      <circle cx="40" cy="24" r="18" fill="#4ADE80" />
      <circle cx="28" cy="30" r="12" fill="#6EE7B7" />
      <circle cx="52" cy="30" r="12" fill="#4ADE80" />
      <circle cx="40" cy="14" r="12" fill="#6EE7B7" />
      {/* Fruit */}
      <circle cx="30" cy="22" r="4" fill="#F87171" />
      <circle cx="50" cy="20" r="4" fill="#FCA5A5" />
      <circle cx="40" cy="34" r="4" fill="#F87171" />
      <circle cx="24" cy="34" r="3" fill="#FCD34D" />
      <circle cx="56" cy="32" r="3" fill="#FCD34D" />
      {/* Face on trunk */}
      <circle cx="34" cy="55" r="2.5" fill="#78350F" />
      <circle cx="46" cy="55" r="2.5" fill="#78350F" />
      <circle cx="34.6" cy="54.4" r="0.8" fill="white" />
      <circle cx="46.6" cy="54.4" r="0.8" fill="white" />
      <path d="M32 63 Q40 69 48 63" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      {/* Stars around tree */}
      <circle cx="8"  cy="28" r="2.2" fill="#FEF3C7" opacity="0.9" />
      <circle cx="72" cy="24" r="1.8" fill="#FEF3C7" opacity="0.8" />
      <circle cx="6"  cy="48" r="1.6" fill="#FEF3C7" opacity="0.7" />
      <circle cx="74" cy="44" r="1.4" fill="#FEF3C7" opacity="0.7" />
    </>
  );
}
