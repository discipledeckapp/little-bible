import { ImageResponse } from 'next/og';

export const size = { width: 512, height: 512 };
export const contentType = 'image/png';

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: 512,
          height: 512,
          borderRadius: 114,
          background: 'linear-gradient(145deg, #78350F 0%, #92400E 30%, #B45309 65%, #D97706 100%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 24,
        }}
      >
        {/* Cross */}
        <div style={{ position: 'relative', width: 100, height: 130, display: 'flex' }}>
          {/* Vertical arm */}
          <div style={{
            position: 'absolute',
            left: 41,
            top: 0,
            width: 18,
            height: 130,
            background: '#FDE68A',
            borderRadius: 9,
            opacity: 0.92,
          }} />
          {/* Horizontal arm — at upper third to form a Christian cross */}
          <div style={{
            position: 'absolute',
            left: 0,
            top: 35,
            width: 100,
            height: 18,
            background: '#FDE68A',
            borderRadius: 9,
            opacity: 0.92,
          }} />
        </div>

        {/* Open book */}
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 0 }}>
          {/* Left page */}
          <div
            style={{
              width: 155,
              height: 190,
              background: 'rgba(255,255,255,0.97)',
              borderRadius: '26px 5px 5px 26px',
              display: 'flex',
              flexDirection: 'column',
              padding: '26px 22px',
              gap: 14,
            }}
          >
            <div style={{ height: 10, background: 'rgba(120,53,15,0.35)', borderRadius: 6, width: '80%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.22)', borderRadius: 6, width: '100%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.20)', borderRadius: 6, width: '70%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.18)', borderRadius: 6, width: '90%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.15)', borderRadius: 6, width: '62%' }} />
          </div>

          {/* Spine */}
          <div style={{
            width: 18,
            height: 198,
            background: 'rgba(120,53,15,0.28)',
            borderRadius: 0,
          }} />

          {/* Right page */}
          <div
            style={{
              width: 155,
              height: 190,
              background: 'rgba(255,255,255,0.78)',
              borderRadius: '5px 26px 26px 5px',
              display: 'flex',
              flexDirection: 'column',
              padding: '26px 22px',
              gap: 14,
            }}
          >
            <div style={{ height: 10, background: 'rgba(120,53,15,0.25)', borderRadius: 6, width: '92%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.18)', borderRadius: 6, width: '75%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.16)', borderRadius: 6, width: '100%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.14)', borderRadius: 6, width: '63%' }} />
            <div style={{ height: 10, background: 'rgba(120,53,15,0.12)', borderRadius: 6, width: '82%' }} />
          </div>
        </div>
      </div>
    ),
    { ...size }
  );
}
