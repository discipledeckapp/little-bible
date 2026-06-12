'use client';

type PazState = 'resting' | 'flying' | 'perching';

interface PazSparrowProps {
  state?: PazState;
  className?: string;
  size?: number;
}

export default function PazSparrow({ state = 'resting', className = '', size = 40 }: PazSparrowProps) {
  return (
    <svg
      viewBox="0 0 40 32"
      width={size}
      height={size * 0.8}
      fill="none"
      className={`${className} ${state === 'flying' ? 'sparrow-fly' : ''}`}
      aria-label="Paz the sparrow"
      role="img"
    >
      {state === 'resting'   && <PazResting />}
      {state === 'flying'    && <PazFlying />}
      {state === 'perching'  && <PazPerching />}
    </svg>
  );
}

function PazResting() {
  return (
    <>
      {/* Body */}
      <ellipse cx="20" cy="20" rx="10" ry="8" fill="#92400E" />
      {/* Breast */}
      <ellipse cx="20" cy="22" rx="7" ry="5" fill="#D4A574" />
      {/* Head */}
      <circle cx="28" cy="14" r="7" fill="#78350F" />
      {/* Golden primary feather — Paz's signature */}
      <path d="M10 18 Q4 22 6 28 Q12 24 14 20Z" fill="#F59E0B" />
      {/* Wing detail */}
      <path d="M12 16 Q16 12 22 14" stroke="#57280A" strokeWidth="1" strokeLinecap="round" fill="none" />
      <path d="M11 19 Q15 15 21 17" stroke="#57280A" strokeWidth="0.8" strokeLinecap="round" fill="none" />
      {/* Tail */}
      <path d="M10 22 Q6 26 8 30 Q12 28 12 24Z" fill="#78350F" />
      {/* Eye */}
      <circle cx="30" cy="13" r="2.2" fill="#1C0D00" />
      <circle cx="30.6" cy="12.4" r="0.7" fill="white" />
      {/* Beak */}
      <path d="M35 14 L38 13 L36 15Z" fill="#C9860E" />
      {/* Feet */}
      <line x1="18" y1="27" x2="16" y2="30" stroke="#C9860E" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="22" y1="27" x2="20" y2="30" stroke="#C9860E" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="16" y1="30" x2="14" y2="31" stroke="#C9860E" strokeWidth="1" strokeLinecap="round" />
      <line x1="16" y1="30" x2="16" y2="32" stroke="#C9860E" strokeWidth="1" strokeLinecap="round" />
      <line x1="16" y1="30" x2="18" y2="31" stroke="#C9860E" strokeWidth="1" strokeLinecap="round" />
    </>
  );
}

function PazFlying() {
  return (
    <>
      {/* Body */}
      <ellipse cx="20" cy="18" rx="9" ry="6" fill="#92400E" />
      {/* Breast */}
      <ellipse cx="20" cy="20" rx="6" ry="4" fill="#D4A574" />
      {/* Head */}
      <circle cx="28" cy="12" r="6" fill="#78350F" />
      {/* Wings spread — upswept */}
      <path d="M12 16 Q6 8 10 4 Q16 10 18 16Z" fill="#78350F" />
      <path d="M10 4 Q14 2 18 6" stroke="#57280A" strokeWidth="0.8" fill="none" />
      <path d="M28 16 Q34 8 30 4 Q24 10 22 16Z" fill="#92400E" />
      {/* Golden feather — visible in flight */}
      <path d="M8 16 Q2 14 4 20 Q10 18 12 16Z" fill="#F59E0B" />
      {/* Tail */}
      <path d="M12 20 Q8 24 10 28 Q14 25 14 20Z" fill="#78350F" />
      {/* Eye */}
      <circle cx="30" cy="11" r="2" fill="#1C0D00" />
      <circle cx="30.5" cy="10.5" r="0.6" fill="white" />
      {/* Beak */}
      <path d="M34 12 L37 11 L35 13Z" fill="#C9860E" />
    </>
  );
}

function PazPerching() {
  return (
    <>
      {/* Same as resting but head tilted toward viewer — more curious */}
      <ellipse cx="20" cy="20" rx="10" ry="8" fill="#92400E" />
      <ellipse cx="20" cy="22" rx="7" ry="5" fill="#D4A574" />
      {/* Head tilted */}
      <circle cx="27" cy="13" r="7" fill="#78350F" />
      {/* Golden feather */}
      <path d="M10 18 Q4 22 6 28 Q12 24 14 20Z" fill="#F59E0B" />
      {/* Wing detail */}
      <path d="M12 16 Q16 12 22 14" stroke="#57280A" strokeWidth="1" strokeLinecap="round" fill="none" />
      {/* Tail */}
      <path d="M10 22 Q6 26 8 30 Q12 28 12 24Z" fill="#78350F" />
      {/* Eye — slightly larger, direct gaze */}
      <circle cx="29" cy="12" r="2.5" fill="#1C0D00" />
      <circle cx="29.7" cy="11.4" r="0.8" fill="white" />
      {/* Beak — open slightly */}
      <path d="M34 13 L37 12 L36 14Z" fill="#C9860E" />
      <path d="M34 13 L36 14" stroke="#C9860E" strokeWidth="0.5" />
      {/* Feet on perch line */}
      <line x1="18" y1="27" x2="16" y2="30" stroke="#C9860E" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="22" y1="27" x2="20" y2="30" stroke="#C9860E" strokeWidth="1.2" strokeLinecap="round" />
    </>
  );
}
