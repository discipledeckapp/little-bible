import { ImageResponse } from 'next/og';

export const size = { width: 180, height: 180 };
export const contentType = 'image/png';

export default function AppleIcon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: 180,
          height: 180,
          borderRadius: 40,
          background: 'linear-gradient(145deg, #78350F 0%, #92400E 30%, #B45309 65%, #D97706 100%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 8,
        }}
      >
        {/* Cross */}
        <div style={{ position: 'relative', width: 36, height: 46, display: 'flex' }}>
          <div style={{
            position: 'absolute',
            left: 15,
            top: 0,
            width: 6,
            height: 46,
            background: '#FDE68A',
            borderRadius: 3,
            opacity: 0.92,
          }} />
          <div style={{
            position: 'absolute',
            left: 0,
            top: 13,
            width: 36,
            height: 6,
            background: '#FDE68A',
            borderRadius: 3,
            opacity: 0.92,
          }} />
        </div>

        {/* Open book */}
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 0 }}>
          <div
            style={{
              width: 54,
              height: 67,
              background: 'rgba(255,255,255,0.97)',
              borderRadius: '9px 2px 2px 9px',
              display: 'flex',
              flexDirection: 'column',
              padding: '9px 8px',
              gap: 5,
            }}
          >
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.35)', borderRadius: 2, width: '80%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.22)', borderRadius: 2, width: '100%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.20)', borderRadius: 2, width: '70%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.18)', borderRadius: 2, width: '90%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.15)', borderRadius: 2, width: '62%' }} />
          </div>
          <div style={{ width: 6, height: 70, background: 'rgba(120,53,15,0.28)', borderRadius: 0 }} />
          <div
            style={{
              width: 54,
              height: 67,
              background: 'rgba(255,255,255,0.78)',
              borderRadius: '2px 9px 9px 2px',
              display: 'flex',
              flexDirection: 'column',
              padding: '9px 8px',
              gap: 5,
            }}
          >
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.25)', borderRadius: 2, width: '92%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.18)', borderRadius: 2, width: '75%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.16)', borderRadius: 2, width: '100%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.14)', borderRadius: 2, width: '63%' }} />
            <div style={{ height: 3.5, background: 'rgba(120,53,15,0.12)', borderRadius: 2, width: '82%' }} />
          </div>
        </div>
      </div>
    ),
    { ...size }
  );
}
