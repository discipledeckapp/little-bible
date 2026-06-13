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
          background: 'linear-gradient(145deg, #92400E 0%, #B45309 40%, #F59E0B 100%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 3 }}>
          <div
            style={{
              width: 52,
              height: 66,
              background: 'rgba(255,255,255,0.97)',
              borderRadius: '8px 2px 2px 8px',
              display: 'flex',
              flexDirection: 'column',
              padding: '10px 8px',
              gap: 5,
            }}
          >
            <div style={{ height: 4, background: 'rgba(146,64,14,0.35)', borderRadius: 2, width: '85%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.22)', borderRadius: 2, width: '100%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.22)', borderRadius: 2, width: '72%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.22)', borderRadius: 2, width: '90%' }} />
          </div>
          <div style={{ width: 5, height: 68, background: 'rgba(120,50,8,0.55)', borderRadius: 3 }} />
          <div
            style={{
              width: 52,
              height: 66,
              background: 'rgba(255,255,255,0.82)',
              borderRadius: '2px 8px 8px 2px',
              display: 'flex',
              flexDirection: 'column',
              padding: '10px 8px',
              gap: 5,
            }}
          >
            <div style={{ height: 4, background: 'rgba(146,64,14,0.25)', borderRadius: 2, width: '90%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.18)', borderRadius: 2, width: '78%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.18)', borderRadius: 2, width: '100%' }} />
            <div style={{ height: 4, background: 'rgba(146,64,14,0.15)', borderRadius: 2, width: '65%' }} />
          </div>
        </div>
        <div style={{ width: 14, height: 14, borderRadius: 7, background: 'rgba(255,255,255,0.30)', marginTop: 4 }} />
      </div>
    ),
    { ...size }
  );
}
