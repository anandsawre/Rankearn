import React, { useState, useEffect, useCallback, useRef } from 'react';
import { motion, AnimatePresence, useMotionValue, animate } from 'motion/react';
import { db } from '../firebase';
import { doc, updateDoc, increment, getDoc, serverTimestamp, collection, addDoc, runTransaction } from 'firebase/firestore';
import { UserProfile, LuckyWheelConfig, WheelSlice, DEFAULT_SLICES } from '../types';
import { Coins, Zap, Trophy, RefreshCw, Star, Gift, Crown, ArrowDown, IndianRupee, ArrowLeft, Wallet } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import confetti from 'canvas-confetti';
import cashRegisterSound from '../cash_register.mp3';

interface LuckyWheelProps {
  profile: UserProfile | null;
  onCoinsUpdate?: (newCoins: number) => void;
}

export default function LuckyWheel({ profile, onCoinsUpdate }: LuckyWheelProps) {
  const [config, setConfig] = useState<LuckyWheelConfig | null>(null);
  const [isSpinning, setIsSpinning] = useState(false);
  const [result, setResult] = useState<WheelSlice | null>(null);
  const [rotation, setRotation] = useState(0);
  const [canSpinFree, setCanSpinFree] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();
  const rotationValue = useMotionValue(0);
  const pointerRotation = useMotionValue(0);
  const lastTickValue = useRef(0);

  // Web Audio Context for low-latency ticking
  const [audioCtx] = useState(() => {
    if (typeof window !== 'undefined') {
      const AudioContext = window.AudioContext || (window as any).webkitAudioContext;
      return AudioContext ? new AudioContext() : null;
    }
    return null;
  });

  const playTick = useCallback(() => {
    if (!audioCtx) return;
    try {
      if (audioCtx.state === 'suspended') audioCtx.resume();
      
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      
      osc.type = 'sine';
      osc.frequency.setValueAtTime(800, audioCtx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(150, audioCtx.currentTime + 0.04);
      
      gain.gain.setValueAtTime(0.06, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.04);
      
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      
      osc.start();
      osc.stop(audioCtx.currentTime + 0.04);

      // Bounce pointer
      animate(pointerRotation, [0, -18, 0], { duration: 0.08, ease: "easeOut" });
    } catch (e) {
      console.log('Audio error:', e);
    }
  }, [audioCtx]);

  const playBurstSound = useCallback(() => {
    if (!audioCtx) return;
    try {
      if (audioCtx.state === 'suspended') audioCtx.resume();
      const bufferSize = audioCtx.sampleRate * 0.1;
      const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) data[i] = Math.random() * 2 - 1;
      
      const noise = audioCtx.createBufferSource();
      noise.buffer = buffer;
      const filter = audioCtx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(1200, audioCtx.currentTime);
      filter.frequency.exponentialRampToValueAtTime(200, audioCtx.currentTime + 0.1);
      
      const gain = audioCtx.createGain();
      gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.1);
      
      noise.connect(filter);
      filter.connect(gain);
      gain.connect(audioCtx.destination);
      noise.start();
    } catch (e) { console.log('Burst audio error:', e); }
  }, [audioCtx]);

  const playSuccessChime = useCallback(() => {
    if (!audioCtx) return;
    try {
      if (audioCtx.state === 'suspended') audioCtx.resume();
      const now = audioCtx.currentTime;
      [523.25, 659.25, 783.99, 1046.50].forEach((freq, i) => {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, now + i * 0.1);
        gain.gain.setValueAtTime(0, now + i * 0.1);
        gain.gain.linearRampToValueAtTime(0.1, now + i * 0.1 + 0.05);
        gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.1 + 0.4);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start(now + i * 0.1);
        osc.stop(now + i * 0.1 + 0.4);
      });
    } catch (e) { console.log('Chime audio error:', e); }
  }, [audioCtx]);
  const playWhistleSound = useCallback(() => {
    if (!audioCtx) return;
    try {
      if (audioCtx.state === 'suspended') audioCtx.resume();
      const now = audioCtx.currentTime;
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(1200, now);
      osc.frequency.exponentialRampToValueAtTime(2500, now + 0.1);
      osc.frequency.exponentialRampToValueAtTime(1200, now + 0.2);
      osc.frequency.exponentialRampToValueAtTime(2500, now + 0.3);
      gain.gain.setValueAtTime(0, now);
      gain.gain.linearRampToValueAtTime(0.15, now + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
      osc.connect(gain);
      gain.connect(audioCtx.destination);
      osc.start(now);
      osc.stop(now + 0.4);
    } catch (e) { console.log('Whistle audio error:', e); }
  }, [audioCtx]);

  // Track rotation to trigger ticks
  useEffect(() => {
    const slicesCount = config?.slices.length || DEFAULT_SLICES.length;
    const sliceAngle = 360 / slicesCount;

    const unsubscribe = rotationValue.on('change', (latest) => {
      const currentTick = Math.floor(latest / sliceAngle);
      if (currentTick !== lastTickValue.current) {
        lastTickValue.current = currentTick;
        playTick();
      }
    });
    return () => unsubscribe();
  }, [rotationValue, config, playTick]);

  // Clean up Web Audio Context to prevent memory/resource leaks on mobile WebViews
  useEffect(() => {
    return () => {
      if (audioCtx) {
        audioCtx.close().catch(e => console.log('AudioContext close error:', e));
      }
    };
  }, [audioCtx]);

  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'lucky_wheel'));
        if (snap.exists()) {
          setConfig(snap.data() as LuckyWheelConfig);
        } else {
          setConfig({
            slices: DEFAULT_SLICES,
            isActive: true,
            spinCost: 10
          });
        }
      } catch (err) {
        console.error("Error fetching wheel config:", err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchConfig();
  }, []);

  useEffect(() => {
    if (profile) {
      if (!profile.lastSpinDate) {
        setCanSpinFree(true);
      } else {
        const lastSpin = profile.lastSpinDate.toDate ? profile.lastSpinDate.toDate() : new Date(profile.lastSpinDate);
        const now = new Date();
        const diffHours = (now.getTime() - lastSpin.getTime()) / (1000 * 60 * 60);
        setCanSpinFree(diffHours >= 24);
      }
    }
  }, [profile]);

  const spinWheel = async (isPaid: boolean) => {
    if (!profile || isSpinning || (!canSpinFree && !isPaid)) return;
    if (isPaid && (profile.coins || 0) < (config?.spinCost || 10)) return;

    setIsSpinning(true);
    setResult(null);

    const slices = config?.slices || DEFAULT_SLICES;
    
    // Determine winner based on probability
    const random = Math.random() * 100;
    let cumulativeProbability = 0;
    let winningIndex = 0;
    
    for (let i = 0; i < slices.length; i++) {
      cumulativeProbability += slices[i].probability;
      if (random <= cumulativeProbability) {
        winningIndex = i;
        break;
      }
    }

    const sliceAngle = 360 / slices.length;
    // Rotation logic: current rotation + (revolutions) + (landing offset)
    const extraRevolutions = 360 * 8; // More revolutions for better feel
    const currentRot = rotation % 360;
    const targetOffset = 360 - (winningIndex * sliceAngle + sliceAngle / 2);
    const targetRotation = rotation + extraRevolutions + (targetOffset - currentRot + 360) % 360;

    // Play user provided cash register sound - synced with the start of the wind-up
    const audio = new Audio(cashRegisterSound);
    audio.volume = 0.6;
    audio.play().catch(e => console.log('Audio play blocked:', e));

    // Phase 1: Wind-up (Anticlockwise anticipation)
    const startRotation = rotationValue.get();
    await animate(rotationValue, startRotation - 18, {
      duration: 0.5,
      ease: "easeOut"
    });
    
    // Phase 2: Main Spin (Clockwise)
    await animate(rotationValue, targetRotation, {
      duration: 6,
      ease: [0.15, 0, 0.1, 1]
    });

    const winner = slices[winningIndex];
    setResult(winner);
    setIsSpinning(false);
    setRotation(targetRotation);
    rotationValue.set(targetRotation);

    // Update Firestore using Atomic Transaction
    try {
      const userRef = doc(db, 'users', profile.userId);
      const spinFee = isPaid ? (config?.spinCost || 10) : 0;
      const winnings = winner.value;
      let finalBalance = (profile.coins || 0) + winnings - spinFee;

      await runTransaction(db, async (transaction) => {
        const userSnap = await transaction.get(userRef);
        if (!userSnap.exists()) throw new Error("User profile not found");
        
        const userData = userSnap.data();
        const currentCoins = userData.coins || 0;
        const currentTotalEarned = userData.totalEarned || 0;
        const currentTotalSpent = userData.totalSpent || 0;
        
        finalBalance = currentCoins + winnings - spinFee;

        // 1. Update User Balance
        transaction.update(userRef, {
          coins: finalBalance,
          totalSpent: isPaid ? currentTotalSpent + spinFee : currentTotalSpent,
          totalEarned: winnings > 0 ? currentTotalEarned + winnings : currentTotalEarned,
          lastSpinDate: serverTimestamp()
        });

        // 2. Log "Spend" Transaction (if paid)
        if (isPaid) {
          const spendTxRef = doc(collection(db, 'transactions'));
          transaction.set(spendTxRef, {
            userId: profile.userId,
            amount: -spinFee,
            type: 'spend',
            category: 'lucky_wheel_spin',
            timestamp: serverTimestamp(),
            testTitle: 'Lucky Wheel Spin Fee',
            currentBalance: currentCoins - spinFee
          });
        }

        // 3. Log "Earn" Transaction (if won)
        if (winnings > 0) {
          const earnTxRef = doc(collection(db, 'transactions'));
          transaction.set(earnTxRef, {
            userId: profile.userId,
            amount: winnings,
            type: 'earn',
            category: 'lucky_wheel_win',
            timestamp: serverTimestamp(),
            testTitle: `Won ${winner.label} from Lucky Wheel`,
            currentBalance: finalBalance
          });
        }
      });

      // --- CELEBRATION LOGIC ---
      if (winner.type !== 'nothing') {
        // 1. Play Victory Sounds (Safe Execution)
        try {
          if (audioCtx) {
            if (audioCtx.state === 'suspended') await audioCtx.resume();
            playSuccessChime();
            playBurstSound();
            playWhistleSound();
          }
        } catch (e) { console.error("Sound playback failed:", e); }

        // 2. High-Performance Premium Confetti
        const colors = ['#ff4757', '#2ed573', '#1e90ff', '#eccc68', '#ffa502', '#a55eea', '#2bcbba', '#ff6b6b', '#10ac84'];
        
        // Define professional smooth curly ribbon shape using SVG path
        const curlyRibbon = (confetti as any).shapeFromPath({
          path: 'M0 0 Q 6 5, 0 10 Q -6 15, 0 20 Q 6 25, 0 30 Q -6 35, 0 40 L 3 40 Q -3 35, 3 30 Q 9 25, 3 20 Q -3 15, 3 10 Q 9 5, 3 0 Z'
        });

        // Define small and clean gold coin shape using Emoji text (size reduced for mobile)
        const goldCoin = (confetti as any).shapeFromText({
          text: '🪙',
          scalar: 1.1
        });

        // Define golden sparkle/shine shape using Emoji text for chamak
        const sparkle = (confetti as any).shapeFromText({
          text: '✨',
          scalar: 1.0
        });

        // Weighted array: mostly professional ribbons, fewer coins, and sparkles for shine
        const celebratoryShapes = [
          curlyRibbon, curlyRibbon, curlyRibbon, 
          goldCoin, 
          sparkle, sparkle
        ];

        // Initial Burst
        confetti({
          particleCount: 150,
          spread: 70,
          origin: { y: 0.6 },
          colors: colors,
          shapes: celebratoryShapes,
          scalar: 1.8,
          ticks: 200
        });

        // Secondary Delayed Burst for "Wow" factor
        setTimeout(() => {
          try { if (audioCtx) playBurstSound(); } catch(e){}
          confetti({
            particleCount: 80,
            angle: 90,
            spread: 120,
            origin: { y: 0.7 },
            colors: colors,
            shapes: celebratoryShapes,
            scalar: 2.0,
            drift: 1,
            gravity: 0.8
          });
        }, 300);

        // Side Cannon Bursts (Continuos for 2 seconds)
        const duration = 2 * 1000;
        const animationEnd = Date.now() + duration;
        const frame = () => {
          const timeLeft = animationEnd - Date.now();
          if (timeLeft <= 0) return;

          const particleCount = 2;
          confetti({
            particleCount,
            angle: 60,
            spread: 55,
            origin: { x: 0, y: 0.8 },
            colors: colors,
            shapes: celebratoryShapes,
            scalar: 1.6
          });
          confetti({
            particleCount,
            angle: 120,
            spread: 55,
            origin: { x: 1, y: 0.8 },
            colors: colors,
            shapes: celebratoryShapes,
            scalar: 1.6
          });

          requestAnimationFrame(frame);
        };
        frame();
      }
      
      if (onCoinsUpdate) {
        onCoinsUpdate(finalBalance);
      }
      
      if (!isPaid) setCanSpinFree(false);
    } catch (err) {
      console.error("Error updating spin result:", err);
    }
  };

  const slices = config?.slices || DEFAULT_SLICES;
  const sliceAngle = 360 / slices.length;

  if (!isLoading && config && !config.isActive) {
    return (
      <div className="max-w-6xl mx-auto px-5 py-20 flex flex-col items-center justify-center text-center">
        <div className="w-24 h-24 bg-amber-50 rounded-3xl flex items-center justify-center mb-6 shadow-xl shadow-amber-500/10 border border-amber-100">
          <Zap className="text-amber-500 animate-pulse" size={48} />
        </div>
        <h2 className="text-3xl font-black text-slate-900 tracking-tight mb-2">Wheel is <span className="text-amber-500">Offline</span></h2>
        <p className="text-slate-500 font-medium max-w-md">The Lucky Wheel is currently undergoing maintenance or has been disabled by the administrator. Please check back later!</p>
        <button 
          onClick={() => navigate('/tests')}
          className="mt-8 px-8 py-3 bg-slate-900 text-white font-bold rounded-xl hover:bg-slate-800 transition-all active:scale-95 flex items-center gap-2"
        >
          <ArrowLeft size={18} />
          Back to Arena
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      {/* Header Section */}
      <div className="hidden md:block px-5 pt-0 pb-1 md:px-8 md:pt-0 md:pb-2 -mt-2 md:-mt-4">
        <div className="flex flex-col gap-1.5">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-2xl md:text-3xl font-black text-slate-900 tracking-tight leading-tight">
              Fortune <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-500 to-amber-600">Wheel</span>
            </h2>
            
            {/* Status Badge - Now horizontally aligned even on mobile */}
            <div className="hidden md:flex items-center gap-2 px-2.5 py-1.5 bg-white rounded-lg border border-slate-100 shadow-sm shrink-0">
              <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-ping" />
              <span className="text-[9px] font-bold text-slate-500 uppercase tracking-wider">2.4k Online</span>
            </div>
          </div>

          {/* Minimalist Divider */}
          <div className="h-px bg-slate-100 w-full" />

          <div className="space-y-2">
            <div className="hidden md:inline-flex items-center gap-2 px-3 py-1 bg-amber-500/10 border border-amber-500/20 rounded-full text-amber-600 text-[10px] font-black uppercase tracking-wider">
              <Crown size={12} />
              Exclusive Rewards • Premium Stakes
            </div>
            <p className="hidden md:block text-sm text-slate-500 font-medium">Spin daily and win exclusive lucky rewards!</p>
          </div>
        </div>
      </div>

      {/* Content Section - Tightened gaps and padding for mobile visibility */}
      <div className="flex flex-col lg:flex-row items-center justify-center gap-10 md:gap-12 lg:gap-20 pt-10 pb-4 px-5 md:p-12 relative">
        {/* Background Decorative Elements */}
        <div className="absolute inset-0 pointer-events-none opacity-40">
           <div className="absolute top-[-10%] left-[-5%] w-[40%] h-[40%] bg-amber-50 blur-[100px] rounded-full animate-pulse" />
           <div className="absolute bottom-[0%] right-[0%] w-[30%] h-[30%] bg-emerald-50 blur-[80px] rounded-full" />
        </div>

        {/* The Great Wheel */}
        <div className="flex-1 flex flex-col items-center z-10 w-full lg:max-w-md">
          <div className="relative w-full max-w-[280px] md:max-w-[440px] aspect-square group">

            {/* Outermost Gold Ring */}
            <div className="absolute inset-[-6px] md:inset-[-9px] rounded-full border-[2px] md:border-[3px] border-amber-500 shadow-sm pointer-events-none" />

            {/* Deep Orange Ring */}
            <div className="absolute inset-[-4px] md:inset-[-6px] rounded-full bg-orange-600 pointer-events-none" />

            {/* Golden Rim with Bulbs */}
            <div className="absolute inset-[-2px] md:inset-[-3px] rounded-full bg-gradient-to-br from-slate-50 via-white to-slate-200 border-[2px] md:border-[3px] border-white shadow-[0_15px_35px_rgba(0,0,0,0.06),inset_0_2px_4px_rgba(255,255,255,1)] flex items-center justify-center overflow-visible [--bulb-translate:-141px] md:[--bulb-translate:-222px]">
                {[...Array(24)].map((_, i) => (
                    <div 
                      key={i} 
                      className="absolute w-1.5 h-1.5 md:w-2 md:h-2 bg-yellow-100 rounded-full shadow-[0_0_6px_#fff,0_0_10px_#fbbf24] animate-bulb-css" 
                      style={{ 
                        '--bulb-rot': `${i * 15}deg`,
                        animationDelay: `${i * 0.08}s`
                      } as React.CSSProperties} 
                    />
                ))}
            </div>

            {/* Pointer - Optimized as a Premium Golden Needle */}
            <div className="absolute top-[2px] left-1/2 -translate-x-1/2 -translate-y-1/2 z-40">
               <motion.div 
                  style={{ rotate: pointerRotation }}
                  className="filter drop-shadow-[0_4px_8px_rgba(0,0,0,0.3)] origin-top"
                >
                  <div className="w-6 h-10 md:w-8 md:h-12 relative flex flex-col items-center">
                     {/* Needle Shape */}
                     <div className="w-full h-full bg-gradient-to-b from-amber-300 via-amber-500 to-amber-700 clip-pointer relative border border-white/20">
                        <div className="absolute inset-0 bg-gradient-to-r from-white/30 via-transparent to-black/20" />
                        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[2px] h-full bg-white/20 blur-[1px]" />
                     </div>
                     {/* Pinhead Base */}
                     <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1/2 w-3 h-3 bg-gradient-to-br from-amber-200 to-amber-600 rounded-full border border-white/50 shadow-sm" />
                  </div>
               </motion.div>
            </div>

            {/* The Wheel */}
            <motion.div 
              style={{ rotate: rotationValue }}
              initial={{ rotate: 0 }}
              className="w-full h-full rounded-full border-[2px] md:border-[3px] border-purple-600 relative overflow-hidden bg-slate-900"
            >
              <svg viewBox="0 0 100 100" className="w-full h-full rotate-[-90deg]">
                {slices.map((slice, i) => {
                  const startAngle = i * sliceAngle;
                  const endAngle = (i + 1) * sliceAngle;
                  const x1 = 50 + 50 * Math.cos((Math.PI * startAngle) / 180);
                  const y1 = 50 + 50 * Math.sin((Math.PI * startAngle) / 180);
                  const x2 = 50 + 50 * Math.cos((Math.PI * endAngle) / 180);
                  const y2 = 50 + 50 * Math.sin((Math.PI * endAngle) / 180);
                  const largeArcFlag = sliceAngle > 180 ? 1 : 0;
                  
                  return (
                    <g key={i} className="cursor-default">
                      <path 
                        d={`M 50 50 L ${x1} ${y1} A 50 50 0 ${largeArcFlag} 1 ${x2} ${y2} Z`}
                        fill={slice.color}
                        stroke="white"
                        strokeWidth="0.6"
                        className="transition-all duration-300"
                      />
                      <g transform={`rotate(${startAngle + sliceAngle / 2}, 50, 50)`}>
                        <text x="82" y="50" fill="white" fontSize="4.5" fontWeight="950" textAnchor="middle" className="select-none">{slice.value > 0 ? slice.value : '?'}</text>
                        <text x="68" y="50" fill="white" fontSize="2.2" fontWeight="700" textAnchor="middle" className="select-none opacity-90">{slice.type === 'coins' ? 'COINS' : 'TRY'}</text>
                      </g>
                    </g>
                  );
                })}
              </svg>
              
              {/* Center Hub */}
              <div className="absolute inset-0 m-auto w-20 h-20 md:w-28 md:h-28 bg-gradient-to-br from-slate-700 to-slate-900 rounded-full border-[5px] border-slate-600 shadow-xl flex items-center justify-center z-10">
                <div className="w-12 h-12 md:w-16 md:h-16 bg-gradient-to-tr from-amber-400 to-amber-500 rounded-full flex items-center justify-center shadow-lg">
                    <Star className="text-white" size={24} fill="white" />
                </div>
              </div>
            </motion.div>
          </div>
        </div>

        {/* Right Column: Control Panel */}
        <div className="flex-1 w-full max-w-sm z-10">
          <div className="bg-slate-100/50 backdrop-blur-sm p-2.5 md:p-6 rounded-2xl border border-white shadow-sm flex flex-col gap-2.5 md:gap-5">
            <AnimatePresence mode="wait">
              {result && !isSpinning ? (
                <motion.div 
                  initial={{ opacity: 0, scale: 0.9, y: 10 }}
                  animate={{ opacity: 1, scale: 1, y: 0 }}
                  className="bg-white p-2 md:p-3 rounded-2xl border border-amber-100 shadow-md text-center"
                >
                  <p className="text-[10px] font-bold text-amber-600 uppercase tracking-[0.2em] mb-1">
                    {result.type === 'nothing' ? 'Better Luck Next Time' : 'Congratulations! You Won'}
                  </p>
                  <div className="text-2xl font-black text-slate-900 flex items-center justify-center gap-3">
                    {result.type === 'nothing' ? 'Try Again' : (
                      <>
                        <div className="relative p-1 rounded-full bg-amber-50 border border-amber-100 shadow-inner">
                           <div className="w-8 h-8 bg-gradient-to-tr from-amber-500 to-amber-600 rounded-full flex items-center justify-center shadow-md">
                              <IndianRupee size={18} className="text-white" strokeWidth={3} />
                           </div>
                        </div>
                        <span className="tracking-tight">{result.label}</span>
                      </>
                    )}
                  </div>
                </motion.div>
              ) : (
                  <div className="flex flex-col items-center justify-center h-[40px] md:h-[52px] text-center px-4 bg-white/50 rounded-2xl border border-dashed border-slate-200">
                     <p className="text-slate-400 text-[10px] font-bold animate-pulse uppercase tracking-wider">Waiting for your lucky spin...</p>
                  </div> 
              )}
            </AnimatePresence>

            <button 
              onClick={() => navigate('/wallet')}
              className="flex items-center justify-center gap-3 py-2 md:py-3.5 bg-gradient-to-r from-amber-400 via-amber-500 to-amber-600 rounded-xl border border-amber-300 text-base font-bold text-white transition-all active:scale-[0.98] shadow-lg shadow-amber-500/20 group"
            >
               <div className="relative p-0.5 rounded-full bg-amber-50 border border-amber-100 shrink-0 group-hover:scale-110 transition-transform">
                  <div className="w-5 h-5 bg-gradient-to-tr from-amber-500 to-amber-600 rounded-full flex items-center justify-center shadow-sm">
                      <Wallet size={12} className="text-white" strokeWidth={3} />
                  </div>
               </div>
               <span className="text-white transition-colors">{profile?.coins || 0} Coins Available</span>
            </button>

            <div className="flex flex-col gap-4">
              <button
                disabled={isSpinning || !canSpinFree}
                onClick={() => spinWheel(false)}
                className={`w-full py-2 md:py-3.5 rounded-xl font-bold text-base transition-all flex items-center justify-center gap-2 shadow-sm active:scale-[0.98] relative overflow-hidden group ${canSpinFree && !isSpinning ? 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-emerald-500/20' : 'bg-slate-100 text-slate-400 cursor-not-allowed'}`}
              >
                {isSpinning ? <RefreshCw size={18} className="animate-spin" /> : (
                  <>{canSpinFree ? 'Spin For Free' : 'Free Spin in 24h'}</>
                )}
                {!isSpinning && canSpinFree && <div className="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000 skew-x-[-30deg]" />}
              </button>
              
              <button
                disabled={isSpinning || (profile?.coins || 0) < (config?.spinCost || 10)}
                onClick={() => spinWheel(true)}
                className={`w-full py-2 md:py-3.5 rounded-xl font-bold text-base transition-all flex items-center justify-center gap-3 border border-amber-100 shadow-sm active:scale-[0.98] relative overflow-hidden group ${!isSpinning && (profile?.coins || 0) >= (config?.spinCost || 10) ? 'bg-amber-50 text-amber-900 hover:bg-amber-100' : 'bg-slate-50 text-slate-300'}`}
              >
                <div className="relative p-1 rounded-full bg-white border border-amber-200 shadow-sm">
                    <div className="w-5 h-5 bg-gradient-to-tr from-amber-500 to-amber-600 rounded-full flex items-center justify-center shadow-sm">
                        <IndianRupee size={12} className="text-white" strokeWidth={3} />
                    </div>
                </div>
                <span>Spin for {config?.spinCost || 10} Coins</span>
              </button>
            </div>
          </div>
        </div>
      </div>
      <style dangerouslySetInnerHTML={{ __html: `
        .clip-pointer { clip-path: polygon(0% 0%, 100% 0%, 100% 45%, 50% 100%, 0% 45%); }
        @keyframes bulbGlow {
          0%, 100% { opacity: 0.3; transform: rotate(var(--bulb-rot)) translateY(var(--bulb-translate)) scale(1); }
          50% { opacity: 1; transform: rotate(var(--bulb-rot)) translateY(var(--bulb-translate)) scale(1.1); }
        }
        .animate-bulb-css {
          animation: bulbGlow 2s ease-in-out infinite;
        }
      ` }} />
    </div>
  );
}
