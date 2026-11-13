import React from 'react';

/**
 * VisualAtmosphere
 * ─────────────────
 * A fixed/absolute, full-screen decorative background layer.
 * Renders behind ALL app content (z-index: 0 via pointer-events-none).
 * Does NOT affect layout, scroll, or any interactive element.
 *
 * Color Palette:
 *   Emerald Green  #00B16A
 *   Mint Green     #BFF6DA
 *   Soft White     #F8FAF9
 *   Light Gray     #EAEFF2
 *   Dark Navy Text #0F172A
 */
interface VisualAtmosphereProps {
  fixed?: boolean;
}

export default function VisualAtmosphere({ fixed = true }: VisualAtmosphereProps) {
  return (
    <div
      aria-hidden="true"
      className="inset-0 pointer-events-none overflow-hidden select-none"
      style={{
        position: fixed ? 'fixed' : 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: fixed ? 0 : undefined,
        minHeight: fixed ? undefined : '100%',
        zIndex: 0,
        width: '100%',
      }}
    >
      {/* ── Scoped CSS Keyframe Animations for Fluid Movements ── */}
      <style>{`
        @keyframes float-orb-primary {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          33% { transform: translate3d(50px, -60px, 0) scale(1.15); }
          66% { transform: translate3d(-40px, 40px, 0) scale(0.9); }
        }
        @keyframes float-orb-secondary {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1.1); }
          50% { transform: translate3d(-70px, 50px, 0) scale(0.88); }
        }
        @keyframes float-orb-tertiary {
          0%, 100% { transform: translate3d(0, 0, 0) scale(0.95); }
          40% { transform: translate3d(45px, 70px, 0) scale(1.12); }
          80% { transform: translate3d(-50px, -30px, 0) scale(0.85); }
        }
        @keyframes sway-waves {
          0%, 100% { transform: translate3d(0, 0, 0) scaleY(1); }
          50% { transform: translate3d(-20px, 8px, 0) scaleY(1.05); }
        }
        @keyframes subtle-pulse-glow {
          0%, 100% { opacity: 0.2; transform: scale(1); }
          50% { opacity: 0.38; transform: scale(1.06); }
        }
        @keyframes spin-slow-cw {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        @keyframes spin-slow-ccw {
          0% { transform: rotate(360deg); }
          100% { transform: rotate(0deg); }
        }
        @keyframes sparkle-pulse-fast {
          0%, 100% { opacity: 0.15; transform: scale(0.8) translate3d(0, 0, 0); }
          50% { opacity: 0.6; transform: scale(1.3) translate3d(0, -8px, 0); }
        }
        @keyframes sparkle-pulse-slow {
          0%, 100% { opacity: 0.1; transform: scale(1.1) translate3d(0, 0, 0); }
          50% { opacity: 0.5; transform: scale(0.7) translate3d(8px, 4px, 0); }
        }

        @media (min-width: 1024px) {
          .animate-orb-primary { animation: float-orb-primary 28s ease-in-out infinite; }
          .animate-orb-secondary { animation: float-orb-secondary 32s ease-in-out infinite; }
          .animate-orb-tertiary { animation: float-orb-tertiary 26s ease-in-out infinite; }
          .animate-sway-waves { animation: sway-waves 22s ease-in-out infinite; }
          .animate-subtle-pulse { animation: subtle-pulse-glow 12s ease-in-out infinite; }
          .animate-spin-cw { animation: spin-slow-cw 50s linear infinite; }
          .animate-spin-ccw { animation: spin-slow-ccw 45s linear infinite; }
          .animate-sparkle-1 { animation: sparkle-pulse-fast 5s ease-in-out infinite; }
          .animate-sparkle-2 { animation: sparkle-pulse-slow 7s ease-in-out infinite; }
        }
      `}</style>

      {/* ── Base Gradient Canvas ── */}
      <div
        className="absolute inset-0"
        style={{
          background: `
            radial-gradient(ellipse 130% 90% at 50% -25%, #BFF6DA66 0%, transparent 65%),
            radial-gradient(ellipse 90% 70% at 100% 115%, #00B16A22 0%, transparent 60%),
            radial-gradient(ellipse 80% 60% at -10% 95%,  #BFF6DA33 0%, transparent 60%),
            linear-gradient(135deg, #F8FAF9 0%, #EEF7F2 40%, #F5FAF7 75%, #F8FAF9 100%)
          `,
        }}
      />

      {/* ── Floating Glow Orbs (Dynamic Aurora) ── */}
      <div
        className="absolute -top-40 -left-40 w-[600px] h-[600px] rounded-full opacity-40 animate-orb-primary"
        style={{
          background: 'radial-gradient(circle at 45% 45%, #00B16A55 0%, #BFF6DA33 50%, transparent 75%)',
          filter: 'blur(70px)',
        }}
      />

      <div
        className="absolute -bottom-48 -right-48 w-[650px] h-[650px] rounded-full opacity-35 animate-orb-secondary"
        style={{
          background: 'radial-gradient(circle at 55% 55%, #00B16A44 0%, #BFF6DA22 55%, transparent 75%)',
          filter: 'blur(90px)',
        }}
      />

      <div
        className="absolute top-[35%] left-[25%] w-[450px] h-[450px] rounded-full opacity-20 animate-orb-tertiary"
        style={{
          background: 'radial-gradient(circle, #BFF6DA44 0%, #00B16A11 40%, transparent 70%)',
          filter: 'blur(60px)',
        }}
      />

      {/* ── Soft Mid-Screen Horizontal Glow Band ── */}
      <div
        className="absolute left-0 right-0 opacity-25 animate-subtle-pulse"
        style={{
          top: '35%',
          height: '280px',
          background: 'radial-gradient(ellipse 85% 100% at 50% 50%, #00B16A28 0%, transparent 75%)',
          filter: 'blur(50px)',
        }}
      />

      {/* ── Flowing Waves Top ── */}
      <div className="absolute top-0 left-0 w-full animate-sway-waves" style={{ height: '45%' }}>
        <svg
          className="w-full h-full opacity-45"
          viewBox="0 0 1440 320"
          preserveAspectRatio="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <defs>
            <linearGradient id="glowWaveGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#00B16A" stopOpacity="0.14" />
              <stop offset="50%" stopColor="#BFF6DA" stopOpacity="0.24" />
              <stop offset="100%" stopColor="#00B16A" stopOpacity="0.08" />
            </linearGradient>
            <linearGradient id="glowWaveGrad2" x1="100%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stopColor="#BFF6DA" stopOpacity="0.18" />
              <stop offset="60%" stopColor="#00B16A" stopOpacity="0.12" />
              <stop offset="100%" stopColor="#BFF6DA" stopOpacity="0.06" />
            </linearGradient>
          </defs>
          <path
            d="M0,90 C180,180 380,30 580,110 C780,190 980,20 1180,100 C1300,150 1380,120 1440,90 L1440,0 L0,0 Z"
            fill="url(#glowWaveGrad1)"
          />
          <path
            d="M0,170 C160,230 340,110 520,180 C700,250 880,100 1060,160 C1180,200 1340,140 1440,170 L1440,0 L0,0 Z"
            fill="url(#glowWaveGrad2)"
          />
        </svg>
      </div>

      {/* ── Flowing Waves Bottom ── */}
      <div className="absolute bottom-0 left-0 w-full animate-sway-waves" style={{ height: '40%', transform: 'scaleY(-1)' }}>
        <svg
          className="w-full h-full opacity-35"
          viewBox="0 0 1440 320"
          preserveAspectRatio="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M0,110 C220,200 460,50 680,140 C900,230 1140,70 1360,160 L1440,200 L1440,320 L0,320 Z"
            fill="url(#glowWaveGrad1)"
          />
          <path
            d="M0,190 C180,260 420,130 640,220 C860,300 1120,160 1340,240 L1440,270 L1440,320 L0,320 Z"
            fill="url(#glowWaveGrad2)"
          />
        </svg>
      </div>

      {/* ── Concentric Rotating Glass Rings (Top Right) ── */}
      <div className="absolute top-[12%] right-[5%] w-[260px] h-[260px] opacity-25 animate-spin-cw">
        <svg className="w-full h-full" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#00B16A" stopOpacity="0.4" />
              <stop offset="100%" stopColor="#BFF6DA" stopOpacity="0.05" />
            </linearGradient>
          </defs>
          <circle cx="100" cy="100" r="95" fill="none" stroke="url(#ringGrad)" strokeWidth="1.2" strokeDasharray="6 4" />
          <circle cx="100" cy="100" r="75" fill="none" stroke="#00B16A" strokeWidth="0.8" strokeOpacity="0.3" />
          <circle cx="100" cy="100" r="55" fill="none" stroke="#BFF6DA" strokeWidth="1.5" strokeOpacity="0.4" strokeDasharray="40 10 5 10" />
          <circle cx="100" cy="100" r="35" fill="none" stroke="#00B16A" strokeWidth="0.5" strokeOpacity="0.2" />
        </svg>
      </div>

      {/* ── Concentric Rotating Glass Rings (Bottom Left) ── */}
      <div className="absolute bottom-[8%] left-[3%] w-[200px] h-[200px] opacity-20 animate-spin-ccw">
        <svg className="w-full h-full" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
          <circle cx="100" cy="100" r="90" fill="none" stroke="#00B16A" strokeWidth="1" strokeOpacity="0.25" strokeDasharray="10 8" />
          <circle cx="100" cy="100" r="65" fill="none" stroke="#BFF6DA" strokeWidth="1.2" strokeOpacity="0.3" />
          <circle cx="100" cy="100" r="40" fill="none" stroke="#00B16A" strokeWidth="0.6" strokeOpacity="0.2" />
        </svg>
      </div>

      {/* ── Gamified Floating Sparkles & Particles ── */}
      {/* Sparkle 1 (Top Left) */}
      <div className="absolute top-[18%] left-[10%] w-6 h-6 opacity-30 animate-sparkle-1">
        <svg className="w-full h-full text-[#00B16A]" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12,2L14.8,9.2L22,12L14.8,14.8L12,22L9.2,14.8L2,12L9.2,9.2Z" />
        </svg>
      </div>

      {/* Sparkle 2 (Center Right) */}
      <div className="absolute top-[48%] right-[12%] w-5 h-5 opacity-25 animate-sparkle-2">
        <svg className="w-full h-full text-[#00B16A]" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12,2L14.8,9.2L22,12L14.8,14.8L12,22L9.2,14.8L2,12L9.2,9.2Z" />
        </svg>
      </div>

      {/* Sparkle 3 (Bottom Left) */}
      <div className="absolute bottom-[28%] left-[15%] w-7 h-7 opacity-20 animate-sparkle-2" style={{ animationDelay: '1.5s' }}>
        <svg className="w-full h-full text-[#BFF6DA]" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12,2L14.8,9.2L22,12L14.8,14.8L12,22L9.2,14.8L2,12L9.2,9.2Z" />
        </svg>
      </div>

      {/* Sparkle 4 (Bottom Right) */}
      <div className="absolute bottom-[15%] right-[6%] w-4 h-4 opacity-35 animate-sparkle-1" style={{ animationDelay: '3s' }}>
        <svg className="w-full h-full text-[#00B16A]" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12,2L14.8,9.2L22,12L14.8,14.8L12,22L9.2,14.8L2,12L9.2,9.2Z" />
        </svg>
      </div>

      {/* Floating Rank-Point Nodes (Micro bubbles) */}
      <div className="absolute top-[28%] left-[30%] w-2 h-2 rounded-full bg-[#00B16A]/40 animate-sparkle-1" style={{ animationDuration: '7s' }} />
      <div className="absolute top-[60%] left-[8%] w-1.5 h-1.5 rounded-full bg-[#BFF6DA]/70 animate-sparkle-2" style={{ animationDuration: '9s' }} />
      <div className="absolute bottom-[40%] right-[22%] w-2.5 h-2.5 rounded-full bg-[#00B16A]/30 animate-sparkle-1" style={{ animationDuration: '5s', animationDelay: '2s' }} />
      <div className="absolute top-[75%] right-[32%] w-2 h-2 rounded-full bg-[#BFF6DA]/60 animate-sparkle-2" style={{ animationDuration: '8s', animationDelay: '1s' }} />

      {/* ── Blueprint Grid Patterns ── */}
      <div
        className="absolute top-[7%] left-[4%] w-[120px] h-[120px] opacity-15"
        style={{
          backgroundImage: 'radial-gradient(#00B16A 1.5px, transparent 1.5px)',
          backgroundSize: '20px 20px',
        }}
      />
      <div
        className="absolute bottom-[12%] right-[5%] w-[120px] h-[120px] opacity-15"
        style={{
          backgroundImage: 'radial-gradient(#00B16A 1.5px, transparent 1.5px)',
          backgroundSize: '20px 20px',
        }}
      />

      {/* ── Diagonal Detail Sweeps ── */}
      <svg
        className="absolute opacity-10"
        style={{ top: '22%', left: '-20px', width: '120px', height: '350px' }}
        viewBox="0 0 120 350"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M10,10 L100,340 M30,10 L120,340" stroke="#00B16A" strokeWidth="1" fill="none" />
      </svg>
      <svg
        className="absolute opacity-10"
        style={{ top: '30%', right: '-20px', width: '120px', height: '350px' }}
        viewBox="0 0 120 350"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M110,10 L20,340 M90,10 L0,340" stroke="#00B16A" strokeWidth="1" fill="none" />
      </svg>

      {/* ── Glassmorphism thin horizontal glow line ── */}
      <div
        className="absolute opacity-40"
        style={{
          top: '6%',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '260px',
          height: '6px',
          borderRadius: '999px',
          background: 'linear-gradient(90deg, transparent, #00B16A44, #BFF6DA88, #00B16A44, transparent)',
          filter: 'blur(4px)',
        }}
      />

      {/* ── Top Neumorphic Inner Highlight line ── */}
      <div
        className="absolute top-0 left-0 right-0 opacity-40"
        style={{
          height: '1px',
          background: 'linear-gradient(90deg, transparent 0%, #ffffff 20%, #BFF6DA 50%, #ffffff 80%, transparent 100%)',
        }}
      />

      {/* ── Premium Mesh Grid Overlay ── */}
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage: `
            linear-gradient(0deg, transparent 24%, rgba(0,177,106,0.3) 25%, rgba(0,177,106,0.3) 26%, transparent 27%, transparent 74%, rgba(0,177,106,0.3) 75%, rgba(0,177,106,0.3) 76%, transparent 77%),
            linear-gradient(90deg, transparent 24%, rgba(0,177,106,0.3) 25%, rgba(0,177,106,0.3) 26%, transparent 27%, transparent 74%, rgba(0,177,106,0.3) 75%, rgba(0,177,106,0.3) 76%, transparent 77%)
          `,
          backgroundSize: '80px 80px',
        }}
      />
    </div>
  );
}
