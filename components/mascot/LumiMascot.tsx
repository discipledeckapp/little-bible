export type LumiStage = 'seed' | 'sprout' | 'sapling' | 'young-tree' | 'tree-of-life';

export function getLumiStage(seeds: number): LumiStage {
  if (seeds >= 201) return 'tree-of-life';
  if (seeds >= 101) return 'young-tree';
  if (seeds >= 51)  return 'sapling';
  if (seeds >= 21)  return 'sprout';
  return 'seed';
}

export function getLumiLabel(stage: LumiStage): string {
  switch (stage) {
    case 'seed':         return 'Wisdom Seed';
    case 'sprout':       return 'Wisdom Sprout';
    case 'sapling':      return 'Young Sapling';
    case 'young-tree':   return 'Growing Tree';
    case 'tree-of-life': return 'Tree of Life';
  }
}

interface LumiMascotProps {
  stage?: LumiStage;
  className?: string;
  animate?: boolean;
  drooping?: boolean;   // shows absence/drooping state
  mode?: 'read' | 'discuss' | 'pray' | 'remember' | 'do';  // shifts glow color
}

export default function LumiMascot({ stage = 'seed', className = '', animate = false, drooping = false, mode }: LumiMascotProps) {
  const modeGlow: Record<string, string> = {
    read:     '#F59E0B',
    discuss:  '#0EA5E9',
    pray:     '#7C3AED',
    remember: '#16A34A',
    do:       '#EA580C',
  };
  const glowColor = mode ? modeGlow[mode] : '#F59E0B';

  return (
    <svg
      viewBox="0 0 80 96"
      fill="none"
      className={`${className} ${animate ? 'lumi-grow' : ''} ${drooping ? 'lumi-droop' : ''}`}
      aria-hidden="true"
      role="img"
      style={{ '--lumi-glow': glowColor } as React.CSSProperties}
    >
      {stage === 'seed'         && <LumiSeed drooping={drooping} />}
      {stage === 'sprout'       && <LumiSprout drooping={drooping} />}
      {stage === 'sapling'      && <LumiSapling drooping={drooping} />}
      {stage === 'young-tree'   && <LumiYoungTree drooping={drooping} />}
      {stage === 'tree-of-life' && <LumiTreeOfLife drooping={drooping} />}
    </svg>
  );
}

function LumiSeed({ drooping }: { drooping?: boolean }) {
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
      {/* Smile or drooping */}
      {drooping ? (
        <>
          <path d="M34 67 Q40 69 46 67" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
          {/* Fallen leaf near base */}
          <path d="M22 80 Q18 76 20 72 Q26 74 22 80Z" fill="#34D399" opacity="0.6" />
        </>
      ) : (
        <path d="M34 67 Q40 72 46 67" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
      )}
      {/* Sparkles */}
      <circle cx="26" cy="50" r="2.2" fill="#FEF3C7" opacity="0.85" />
      <circle cx="55" cy="48" r="1.6" fill="#FEF3C7" opacity="0.75" />
      <circle cx="22" cy="62" r="1.4" fill="#FEF3C7" opacity="0.6" />
    </>
  );
}

function LumiSprout({ drooping }: { drooping?: boolean }) {
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
      {/* Smile or drooping */}
      {drooping ? (
        <>
          <path d="M34 78 Q40 80 46 78" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
          <path d="M20 88 Q16 84 18 80 Q24 82 20 88Z" fill="#34D399" opacity="0.6" />
        </>
      ) : (
        <path d="M34 78 Q40 83.5 46 78" stroke="#78350F" strokeWidth="2" strokeLinecap="round" fill="none" />
      )}
      {/* Sparkles */}
      <circle cx="24" cy="58" r="2" fill="#FEF3C7" opacity="0.85" />
      <circle cx="57" cy="55" r="1.6" fill="#FEF3C7" opacity="0.75" />
    </>
  );
}

function LumiSapling({ drooping }: { drooping?: boolean }) {
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
      {/* Small fruit bud */}
      <circle cx="26" cy="13" r="4" fill="#FCD34D" />
      <circle cx="55" cy="9"  r="3.5" fill="#FDE68A" />
      <circle cx="29" cy="12" r="2.5" fill="#F87171" opacity="0.8" />
      {/* Body */}
      <ellipse cx="40" cy="76" rx="18" ry="19" fill="#FBBF24" />
      <ellipse cx="40" cy="70" rx="18" ry="13" fill="#F59E0B" />
      {/* Eyes */}
      <circle cx="33.5" cy="73" r="2.8" fill="#78350F" />
      <circle cx="46.5" cy="73" r="2.8" fill="#78350F" />
      <circle cx="34.2" cy="72.2" r="0.9" fill="white" />
      <circle cx="47.2" cy="72.2" r="0.9" fill="white" />
      {/* Big happy smile or drooping */}
      {drooping ? (
        <>
          <path d="M32 81 Q40 83 48 81" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
          <path d="M12 88 Q8 84 10 80 Q16 82 12 88Z" fill="#34D399" opacity="0.6" />
        </>
      ) : (
        <path d="M32 81 Q40 88 48 81" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      )}
      {/* Sparkles */}
      <circle cx="14" cy="50" r="2.2" fill="#FEF3C7" opacity="0.8" />
      <circle cx="66" cy="46" r="1.8" fill="#FEF3C7" opacity="0.7" />
      <circle cx="10" cy="64" r="1.5" fill="#FEF3C7" opacity="0.6" />
    </>
  );
}

function LumiYoungTree({ drooping }: { drooping?: boolean }) {
  return (
    <>
      {/* Glow */}
      <ellipse cx="40" cy="60" rx="36" ry="32" fill="#FCD34D" opacity="0.22" />
      <ellipse cx="40" cy="60" rx="28" ry="24" fill="#FDE68A" opacity="0.28" />
      {/* Trunk */}
      <rect x="37" y="48" width="6" height="40" rx="3" fill="#92400E" />
      {/* Crown */}
      <circle cx="40" cy="30" r="20" fill="#34D399" />
      <circle cx="40" cy="26" r="16" fill="#4ADE80" />
      <circle cx="30" cy="33" r="10" fill="#6EE7B7" />
      <circle cx="50" cy="33" r="10" fill="#4ADE80" />
      {/* First fruits — just 2 small ones */}
      <circle cx="32" cy="24" r="3.5" fill="#F87171" />
      <circle cx="49" cy="22" r="3.5" fill="#FCA5A5" />
      {/* One small bird visiting */}
      <ellipse cx="58" cy="26" rx="4" ry="2.5" fill="#78350F" />
      <ellipse cx="60" cy="24.5" rx="2" ry="1.5" fill="#78350F" />
      {/* Face on trunk */}
      <circle cx="34.5" cy="57" r="2.5" fill="#78350F" />
      <circle cx="45.5" cy="57" r="2.5" fill="#78350F" />
      <circle cx="35.1" cy="56.4" r="0.8" fill="white" />
      <circle cx="46.1" cy="56.4" r="0.8" fill="white" />
      {/* Drooping eye override */}
      {drooping && (
        <path d="M33.5 55 Q34.5 57.5 35.5 55" stroke="#78350F" strokeWidth="1.5" fill="none" strokeLinecap="round" />
      )}
      {drooping ? (
        <path d="M32.5 64 Q40 66 47.5 64" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      ) : (
        <path d="M32.5 64 Q40 69.5 47.5 64" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      )}
      {/* Stars */}
      <circle cx="10" cy="36" r="2" fill="#FEF3C7" opacity="0.85" />
      <circle cx="70" cy="32" r="1.6" fill="#FEF3C7" opacity="0.75" />
    </>
  );
}

function LumiTreeOfLife({ drooping }: { drooping?: boolean }) {
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
      {drooping ? (
        <>
          <path d="M32 63 Q40 65 48 63" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
          <path d="M6 78 Q2 74 4 70 Q10 72 6 78Z" fill="#34D399" opacity="0.6" />
        </>
      ) : (
        <path d="M32 63 Q40 69 48 63" stroke="#78350F" strokeWidth="2.2" strokeLinecap="round" fill="none" />
      )}
      {/* Stars around tree */}
      <circle cx="8"  cy="28" r="2.2" fill="#FEF3C7" opacity="0.9" />
      <circle cx="72" cy="24" r="1.8" fill="#FEF3C7" opacity="0.8" />
      <circle cx="6"  cy="48" r="1.6" fill="#FEF3C7" opacity="0.7" />
      <circle cx="74" cy="44" r="1.4" fill="#FEF3C7" opacity="0.7" />
    </>
  );
}
