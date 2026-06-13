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
          borderRadius: 112,
          background: 'linear-gradient(145deg, #92400E 0%, #B45309 40%, #F59E0B 100%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 0,
        }}
      >
        {/* Open book — two pages + spine */}
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, marginBottom: 8 }}>
          {/* Left page */}
          <div
            style={{
              width: 148,
              height: 188,
              background: 'rgba(255,255,255,0.97)',
              borderRadius: '20px 6px 6px 20px',
              display: 'flex',
              flexDirection: 'column',
              padding: '28px 22px',
              gap: 14,
            }}
          >
            <div style={{ height: 10, background: 'rgba(146,64,14,0.35)', borderRadius: 6, width: '85%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.22)', borderRadius: 6, width: '100%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.22)', borderRadius: 6, width: '72%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.22)', borderRadius: 6, width: '90%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.18)', borderRadius: 6, width: '60%' }} />
          </div>

          {/* Spine */}
          <div
            style={{
              width: 14,
              height: 196,
              background: 'rgba(120,50,8,0.55)',
              borderRadius: 7,
            }}
          />

          {/* Right page */}
          <div
            style={{
              width: 148,
              height: 188,
              background: 'rgba(255,255,255,0.82)',
              borderRadius: '6px 20px 20px 6px',
              display: 'flex',
              flexDirection: 'column',
              padding: '28px 22px',
              gap: 14,
            }}
          >
            <div style={{ height: 10, background: 'rgba(146,64,14,0.25)', borderRadius: 6, width: '90%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.18)', borderRadius: 6, width: '78%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.18)', borderRadius: 6, width: '100%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.15)', borderRadius: 6, width: '65%' }} />
            <div style={{ height: 10, background: 'rgba(146,64,14,0.15)', borderRadius: 6, width: '85%' }} />
          </div>
        </div>

        {/* Warm glow dot below book */}
        <div
          style={{
            width: 36,
            height: 36,
            borderRadius: 18,
            background: 'rgba(255,255,255,0.30)',
            marginTop: 12,
          }}
        />
      </div>
    ),
    { ...size }
  );
}
