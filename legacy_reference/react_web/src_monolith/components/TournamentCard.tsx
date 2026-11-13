import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import {
  Trophy, Coins, Clock, Target, Play, Users,
  CheckCircle2, Calendar, AlertCircle, FileText,
  Radio, Share2, FlaskConical, TrendingUp, Star
} from 'lucide-react';
import { Test, UserProfile } from '../types';
import { shareContent, getTestShareLink } from '../utils/shareUtils';
import { useToast } from './Toast';
import { db, auth } from '../firebase';
import { collection, query, where, getDocs, limit } from 'firebase/firestore';

const normalizeDate = (d: any): Date | null => {
  if (!d) return null;
  if (typeof d.toDate === 'function') return d.toDate();
  if (d && typeof d === 'object' && 'seconds' in d) return new Date(d.seconds * 1000);
  const parsed = new Date(d);
  return isNaN(parsed.getTime()) ? null : parsed;
};

interface ContestCardProps {
  key?: any;
  test: Test;
  profile: UserProfile | null;
  onJoin: (test: Test) => void;
  onViewResult?: (attemptId: string) => void;
}

export default function ContestCard({ test, profile, onJoin, onViewResult }: ContestCardProps) {
  const [timeLeft, setTimeLeft] = useState<{ hours: number; minutes: number; seconds: number } | null>(null);
  const [status, setStatus] = useState<'upcoming' | 'live' | 'ended'>('upcoming');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [isCheckingAttempt, setIsCheckingAttempt] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    const checkAttempt = async () => {
      const currentUserId = profile?.userId || auth.currentUser?.uid;
      if (!currentUserId || !test.testId) return;
      setIsCheckingAttempt(true);
      try {
        const q = query(
          collection(db, 'attempts'),
          where('userId', '==', currentUserId),
          where('testId', '==', test.testId),
          limit(1)
        );
        const snap = await getDocs(q);
        if (!snap.empty) {
          setIsSubmitted(true);
          setAttemptId(snap.docs[0].id);
        }
      } catch (err) {
        console.error("Error checking attempt:", err);
      } finally {
        setIsCheckingAttempt(false);
      }
    };
    checkAttempt();
  }, [profile, test.testId]);

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const startTime = normalizeDate(test.scheduledStartTime);
      const endTime = normalizeDate(test.scheduledEndTime);

      if (test.isResultDeclared) {
        setStatus('ended');
        setTimeLeft(null);
      } else if (startTime && now < startTime) {
        setStatus('upcoming');
        const diff = +startTime - +now;
        setTimeLeft({
          hours: Math.floor(diff / (1000 * 60 * 60)),
          minutes: Math.floor((diff / 1000 / 60) % 60),
          seconds: Math.floor((diff / 1000) % 60)
        });
      } else if (endTime && now < endTime) {
        setStatus('live');
        const diff = +endTime - +now;
        setTimeLeft({
          hours: Math.floor(diff / (1000 * 60 * 60)),
          minutes: Math.floor((diff / 1000 / 60) % 60),
          seconds: Math.floor((diff / 1000) % 60)
        });
      } else {
        setStatus('ended');
        setTimeLeft(null);
      }
    }, 1000);

    return () => clearInterval(timer);
  }, [test.scheduledStartTime, test.scheduledEndTime, test.isResultDeclared]);

  const entryFee = test.entryFee || 0;
  const participants = test.totalParticipants || 0;
  const commission = test.adminCommissionPercentage || 20;
  const prizePool = Math.floor((participants * entryFee) * (1 - commission / 100));

  const formatTime = (t: { hours: number; minutes: number; seconds: number }) => {
    return `${t.hours.toString().padStart(2, '0')}:${t.minutes.toString().padStart(2, '0')}:${t.seconds.toString().padStart(2, '0')}`;
  };

  const getStatusConfig = () => {
    if (isSubmitted) {
      return {
        label: 'SUBMITTED',
        timerLabel: '',
        colorClass: 'bg-emerald-50 text-emerald-600 border-emerald-100',
        dotClass: 'bg-emerald-500',
        timerClass: 'text-emerald-600',
        iconColor: 'text-emerald-500',
        hoverColorClass: 'group-hover:text-emerald-600',
        badgeBg: 'bg-emerald-50 border-emerald-100',
        badgeColor: 'bg-emerald-500',
        btnClass: 'bg-emerald-500 hover:bg-emerald-600 shadow-emerald-200',
        btnText: 'Show Result',
        btnIcon: <CheckCircle2 size={16} />
      };
    }

    switch (status) {
      case 'upcoming':
        return {
          label: 'UPCOMING',
          timerLabel: 'Starts in',
          colorClass: 'bg-amber-50 text-amber-600 border-amber-100',
          dotClass: 'bg-amber-500',
          timerClass: 'text-amber-600',
          iconColor: 'text-amber-500',
          hoverColorClass: 'group-hover:text-amber-500',
          badgeBg: 'bg-amber-50 border-amber-100',
          badgeColor: 'bg-amber-500',
          btnClass: 'bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 shadow-orange-100',
          btnText: 'Register Now',
          btnIcon: <Clock size={16} fill="currentColor" fillOpacity={0.2} />
        };
      case 'live':
        return {
          label: 'LIVE NOW',
          timerLabel: 'Ends in',
          colorClass: 'bg-red-50 text-red-500 border-red-100',
          dotClass: 'bg-red-500 animate-pulse',
          timerClass: 'text-red-500',
          iconColor: 'text-red-500',
          hoverColorClass: 'group-hover:text-red-500',
          badgeBg: 'bg-red-50 border-red-100',
          badgeColor: 'bg-red-500',
          btnClass: 'bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 shadow-red-100',
          btnText: 'Join & Win Coins',
          btnIcon: <Radio size={16} fill="currentColor" />
        };
      default:
        return {
          label: 'ENDED',
          timerLabel: '',
          colorClass: 'bg-slate-100 text-slate-500 border-slate-200',
          dotClass: 'bg-slate-400',
          timerClass: 'text-slate-400',
          iconColor: 'text-slate-400',
          hoverColorClass: 'group-hover:text-slate-600',
          badgeBg: 'bg-slate-50 border-slate-100',
          badgeColor: 'bg-slate-400',
          btnClass: 'bg-slate-100 text-slate-400 cursor-not-allowed',
          btnText: 'Contest Ended',
          btnIcon: <CheckCircle2 size={16} />
        };
    }
  };

  const config = getStatusConfig();
  const startTimeObj = test.scheduledStartTime ? new Date(test.scheduledStartTime) : null;

  const handleCardClick = () => {
    if (isSubmitted && attemptId && onViewResult) {
      onViewResult(attemptId);
      return;
    }
    if (status !== 'ended') {
      onJoin(test);
    }
  };

  const handleShare = async (e: React.MouseEvent) => {
    e.stopPropagation();
    const result = await shareContent({
      title: test.title,
      text: `Hey! Check out this ${status === 'live' ? 'Live' : 'Upcoming'} Test: "${test.title}" on Rankearn. Prize Pool: ${prizePool} Coins!`,
      url: getTestShareLink(test.testId),
      imageUrl: '/share-banner.png'
    });

    if (result.success) {
      showToast(
        result.method === 'native' ? 'Shared successfully!' : 'Link copied to clipboard!',
        'success'
      );
    }
  };


  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ y: -4 }}
      onClick={handleCardClick}
      className={`bg-white rounded-2xl border ${status === 'live' && !isSubmitted ? 'border-red-100' : status === 'upcoming' && !isSubmitted ? 'border-amber-100' : isSubmitted ? 'border-emerald-100' : 'border-slate-200'} shadow-sm transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full`}
    >
      {/* PRO ONLY Badge */}
      {test.isProOnly && (
        <div className="absolute top-4 right-0 z-20">
          <div className="bg-amber-500 text-white text-[9px] font-black px-3 py-1 rounded-l-lg shadow-lg flex items-center gap-1.5 border-y border-l border-amber-600/20">
            <Star size={10} fill="currentColor" />
            PRO ONLY
          </div>
        </div>
      )}

      {/* BACKGROUND TEXTURES (Inspired by Image) */}

      {/* Top-Left Status Wave (Matches Screenshot) */}
      <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
        <svg viewBox="0 0 100 100" className="w-full h-full">
          <defs>
            <linearGradient id={`cornerGradient-${test.testId}`} x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor={status === 'live' ? '#ef4444' : '#f97316'} />
              <stop offset="100%" stopColor={status === 'live' ? '#ef4444' : '#f97316'} />
            </linearGradient>
            <filter id={`cardShadow-${test.testId}`} x="-20%" y="-20%" width="140%" height="140%">
              <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
              <feOffset dx="1" dy="1" result="offsetblur" />
              <feComponentTransfer>
                <feFuncA type="linear" slope="0.3" />
              </feComponentTransfer>
              <feMerge>
                <feMergeNode />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>
          <path
            d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z"
            fill={`url(#cornerGradient-${test.testId})`}
            filter={`url(#cardShadow-${test.testId})`}
          />
        </svg>
      </div>

      {/* Top-Right Professional Dot Grid */}
      <div
        className="absolute top-0 right-0 w-36 h-36 opacity-[0.12] pointer-events-none z-0"
        style={{
          backgroundImage: 'radial-gradient(#64748b 1.2px, transparent 1.2px)',
          backgroundSize: '12px 12px',
          maskImage: 'radial-gradient(circle at top right, black, transparent 60%)',
          WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 60%)'
        }}
      ></div>

      {/* Bottom-Left Subtle Navy Corner */}
      <div className="absolute -bottom-12 -left-12 w-32 h-32 bg-slate-900/[0.03] rounded-full blur-xl pointer-events-none group-hover:bg-slate-900/[0.05] transition-colors"></div>

      <div className="relative z-10 p-5 flex-1 flex flex-col">
        {/* Title & Status Icon */}
        <div className="flex items-start gap-3 mb-4">
          <div className={`shrink-0 w-12 h-12 rounded-full flex items-center justify-center bg-white border border-slate-50 shadow-sm ${config.iconColor}`}>
            {status === 'live' && !isSubmitted ? <Radio size={24} /> :
              status === 'upcoming' ? <Trophy size={24} /> :
                <CheckCircle2 size={24} />}
          </div>
          <div className="flex-1">
            <h3 className={`text-base font-black text-slate-900 leading-tight transition-colors line-clamp-2 uppercase ${config.hoverColorClass}`}>
              {test.title}
            </h3>
            <p className="text-[10px] font-bold text-slate-400 mt-1 flex items-center gap-1 uppercase tracking-wider">
              <TrendingUp size={10} className="text-orange-500" />
              Test & Win Rewards!
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-6 mb-5 px-1">
          <div className="flex items-center gap-1.5 text-xs font-bold text-slate-500">
            <Target size={14} className={config.iconColor} />
            <span>{test.totalQuestions} Qs</span>
          </div>
          <div className="flex items-center gap-1.5 text-xs font-bold text-slate-500">
            <Clock size={14} className={config.iconColor} />
            <span>{test.duration} Mins</span>
          </div>
          <div className="flex items-center gap-1.5 text-xs font-bold text-slate-500">
            <Users size={14} className={config.iconColor} />
            <span>{participants} Joined</span>
          </div>
        </div>

        {/* Prize Pool, Fee & Timer: Redesigned to match image */}
        <div className="mb-6 bg-white rounded-xl border border-slate-100 shadow-sm p-3.5 relative overflow-hidden">
          <div className="grid grid-cols-[1fr_auto_1fr_auto_1fr] items-center">
            {/* Prize Pool Section */}
            <div className="flex flex-col items-center">
              <p className="text-[9px] font-black text-slate-800 uppercase tracking-wider mb-1.5">Prize Pool</p>
              <div className="flex items-center gap-1.5">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center p-0.5 border ${status === 'live' ? 'border-red-100 bg-red-50' : 'border-orange-100 bg-orange-50'}`}>
                  <div className={`w-full h-full rounded-full flex items-center justify-center text-white font-black text-[10px] shadow-sm ${status === 'live' ? 'bg-red-500' : 'bg-orange-500'}`}>
                    ₹
                  </div>
                </div>
                <div className="flex flex-col">
                  <span className={`text-xl font-black leading-none ${status === 'live' ? 'text-red-500' : 'text-orange-500'}`}>
                    {prizePool.toLocaleString()}
                  </span>
                  <span className={`text-[8px] font-black uppercase ${status === 'live' ? 'text-red-500' : 'text-orange-500'}`}>
                    Coins
                  </span>
                </div>
              </div>
            </div>

            {/* Divider */}
            <div className="w-[1px] h-8 bg-slate-100"></div>

            {/* Entry Fee Section */}
            <div className="flex flex-col items-center">
              <p className="text-[9px] font-black text-slate-800 uppercase tracking-wider mb-1.5">Entry Fee</p>
              <div className="flex items-center gap-1.5">
                {entryFee === 0 && <div className="text-emerald-400 font-bold text-[10px] leading-none opacity-80">›</div>}
                <div className={`text-xl font-black leading-none uppercase ${entryFee === 0 ? 'text-emerald-500' : 'text-slate-800'}`}>
                  {entryFee === 0 ? 'FREE' : `${entryFee}`}
                </div>
                {entryFee === 0 && <div className="text-emerald-400 font-bold text-[10px] leading-none opacity-80">‹</div>}
              </div>
              {entryFee > 0 && <span className="text-[8px] font-black text-slate-400 uppercase">Coins</span>}
            </div>

            {/* Divider */}
            <div className="w-[1px] h-8 bg-slate-100"></div>

            {/* Timer Section */}
            <div className="flex flex-col items-center">
              <p className="text-[9px] font-black text-slate-800 uppercase tracking-wider mb-1.5">
                {timeLeft ? config.timerLabel : 'Status'}
              </p>
              {timeLeft ? (
                <div className="flex flex-col items-center">
                  <div className={`text-lg font-black leading-none tracking-tight ${status === 'live' ? 'text-red-500' : 'text-orange-500'}`}>
                    {formatTime(timeLeft)}
                  </div>
                  <div className="flex items-center gap-2.5 mt-1">
                    <span className="text-[6.5px] font-black text-slate-500 uppercase">Hrs</span>
                    <span className="text-[6.5px] font-black text-slate-500 uppercase">Mins</span>
                    <span className="text-[6.5px] font-black text-slate-500 uppercase">Secs</span>
                  </div>
                </div>
              ) : (
                <div className={`text-xs font-black leading-none uppercase ${config.timerClass}`}>
                  {config.label}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Schedule Info & Status Badge */}
        {startTimeObj && (
          <div className="flex items-center justify-between gap-3 mb-6 px-1">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 border border-slate-100/50">
                <Calendar size={14} />
              </div>
              <div>
                <p className="text-[8px] font-black text-slate-400 uppercase leading-none mb-0.5">Starts:</p>
                <span className="text-[10px] font-bold text-slate-600">
                  {startTimeObj.toLocaleString('en-IN', {
                    day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', hour12: true
                  })}
                </span>
              </div>
            </div>

            <div className={`px-2.5 py-1 rounded-xl text-[8px] font-black flex items-center gap-1.5 border shadow-sm ${config.colorClass}`}>
              <span className={`w-1.5 h-1.5 rounded-full ${config.dotClass}`}></span>
              {config.label}
            </div>
          </div>
        )}

        <div className="mt-auto flex items-center gap-2">
          <button
            disabled={(status === 'ended' && !isSubmitted)}
            onClick={(e) => {
              e.stopPropagation();
              handleCardClick();
            }}
            className={`flex-1 py-3 text-white rounded-xl font-black text-sm shadow-sm transition-all active:scale-95 flex items-center justify-center gap-2 uppercase tracking-wider ${config.btnClass}`}
          >
            {config.btnText}
          </button>

          <button
            onClick={handleShare}
            className={`px-4 py-3 rounded-xl border border-slate-100 text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all active:scale-95 shadow-sm bg-white shrink-0 flex items-center justify-center gap-2`}
            title="Share Test"
          >
            <Share2 size={18} />
            <span className="text-[10px] font-black uppercase tracking-wider">Share</span>
          </button>
        </div>
      </div>
    </motion.div>
  );
}
