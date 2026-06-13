import { ImageResponse } from 'next/og';

export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';
export const alt = "Little Bible — God's Word for Little Hearts";

export default function OGImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: 1200,
          height: 630,
          background: 'linear-gradient(135deg, #78350F 0%, #92400E 30%, #B45309 65%, #D97706 100%)',
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '60px 80px',
          fontFamily: 'serif',
        }}
      >
        {/* Left: text content */}
        <div style={{ display: 'flex', flexDirection: 'column', flex: 1, gap: 0 }}>
          {/* Badge */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              background: 'rgba(255,255,255,0.12)',
              borderRadius: 32,
              padding: '8px 20px',
              marginBottom: 32,
              width: 'fit-content',
            }}
          >
            <div style={{ fontSize: 18, color: '#FCD34D' }}>📖</div>
            <div style={{ fontSize: 15, color: '#FDE68A', fontWeight: 700, letterSpacing: 2 }}>
              CHILDREN'S BIBLE · AGES 4–7
            </div>
          </div>

          {/* Main headline */}
          <div
            style={{
              fontSize: 80,
              fontWeight: 800,
              color: 'white',
              lineHeight: 1.0,
              marginBottom: 8,
            }}
          >
            Little Bible
          </div>
          <div
            style={{
              fontSize: 40,
              fontWeight: 600,
              color: '#FCD34D',
              lineHeight: 1.2,
              marginBottom: 32,
            }}
          >
            God&apos;s Word for Little Hearts
          </div>

          {/* Description */}
          <div
            style={{
              fontSize: 22,
              color: 'rgba(255,255,255,0.75)',
              lineHeight: 1.5,
              maxWidth: 560,
              marginBottom: 40,
            }}
          >
            All 66 books of Scripture — every verse faithfully adapted
            so children ages 4–7 can read, understand, and love God&apos;s Word.
          </div>

          {/* Stats row */}
          <div style={{ display: 'flex', gap: 24 }}>
            {[
              { label: '66 books', sub: 'Genesis to Revelation' },
              { label: 'Every verse', sub: 'Nothing skipped' },
              { label: 'Free forever', sub: 'No subscription' },
            ].map(item => (
              <div
                key={item.label}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  background: 'rgba(255,255,255,0.10)',
                  borderRadius: 16,
                  padding: '14px 20px',
                }}
              >
                <div style={{ fontSize: 18, fontWeight: 800, color: 'white' }}>{item.label}</div>
                <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.55)', marginTop: 2 }}>{item.sub}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Right: large book icon */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginLeft: 60,
          }}
        >
          <div
            style={{
              width: 280,
              height: 280,
              borderRadius: 64,
              background: 'rgba(255,255,255,0.12)',
              border: '2px solid rgba(255,255,255,0.20)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 0,
            }}
          >
            {/* Open book */}
            <div style={{ display: 'flex', alignItems: 'flex-end', gap: 5 }}>
              <div
                style={{
                  width: 90,
                  height: 116,
                  background: 'rgba(255,255,255,0.95)',
                  borderRadius: '14px 4px 4px 14px',
                  display: 'flex',
                  flexDirection: 'column',
                  padding: '18px 14px',
                  gap: 9,
                }}
              >
                <div style={{ height: 7, background: 'rgba(146,64,14,0.4)', borderRadius: 4, width: '85%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.25)', borderRadius: 4, width: '100%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.25)', borderRadius: 4, width: '72%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.22)', borderRadius: 4, width: '90%' }} />
              </div>
              <div style={{ width: 9, height: 122, background: 'rgba(255,255,255,0.3)', borderRadius: 5 }} />
              <div
                style={{
                  width: 90,
                  height: 116,
                  background: 'rgba(255,255,255,0.75)',
                  borderRadius: '4px 14px 14px 4px',
                  display: 'flex',
                  flexDirection: 'column',
                  padding: '18px 14px',
                  gap: 9,
                }}
              >
                <div style={{ height: 7, background: 'rgba(146,64,14,0.28)', borderRadius: 4, width: '90%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.18)', borderRadius: 4, width: '78%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.18)', borderRadius: 4, width: '100%' }} />
                <div style={{ height: 7, background: 'rgba(146,64,14,0.15)', borderRadius: 4, width: '65%' }} />
              </div>
            </div>
            <div
              style={{
                width: 22,
                height: 22,
                borderRadius: 11,
                background: 'rgba(255,255,255,0.25)',
                marginTop: 10,
              }}
            />
          </div>
        </div>
      </div>
    ),
    { ...size }
  );
}
