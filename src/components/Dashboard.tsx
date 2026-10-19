import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import {
  Zap,
  Trophy,
  Clock,
  Target,
  ArrowUpRight,
  Play,
  FileText,
  Lock,
  LockKeyhole,
  Globe,
  Award,
  Users,
  Coins,
  Star,
  User,
  Radio,
  Calendar,
  Share2,
  FlaskConical,
  BookOpen,
  CheckCircle2,
  TrendingUp,
  Swords,
  Gift,
  ArrowRight,
  Sparkles,
  MessageCircle,
  Mail,
  X,
  Phone,
  MessageSquare
} from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { doc, getDoc, collection, query, limit, getDocs, orderBy, where, updateDoc, increment } from 'firebase/firestore';
import { Test, UserProfile, AppBanner } from '../types';
import ContestJoinModal from './TournamentJoinModal';
import { AnimatePresence } from 'motion/react';
import ContestCard from './TournamentCard';
import { shareContent, getTestShareLink } from '../utils/shareUtils';
import { useToast } from './Toast';
import TestPurchaseModal from './TestPurchaseModal';
import PollWidget from './PollWidget';


// A unified type for carousel items — either a real AppBanner or a virtual tournament banner
type CarouselSlide =
  | { type: 'banner'; data: AppBanner }
  | { type: 'contest'; data: Test; status: 'live' | 'upcoming' };

// Contest Banner Slide — fills the same aspect-ratio container as admin image banners
function ContestBannerSlide({
  contest,
  status,
  onJoin,
  showToast,
}: {
  contest: Test;
  status: 'live' | 'upcoming';
  onJoin: (t: Test) => void;
  showToast: (msg: string, type: 'success' | 'error') => void;
}) {
  const entryFee = contest.entryFee || 0;
  const participants = contest.totalParticipants || 0;
  const commission = contest.adminCommissionPercentage || 20;
  const prizePool = Math.floor(participants * entryFee * (1 - commission / 100));
  const isLive = status === 'live';
  const themeColor = isLive ? 'red' : 'orange';
  const themeHex = isLive ? '#ef4444' : '#f97316';

  const normalizeDate = React.useCallback((d: any) => {
    if (!d) return null;
    if (typeof d.toDate === 'function') return d.toDate();
    return new Date(d);
  }, []);

  const startTime = React.useMemo(() => normalizeDate(contest.scheduledStartTime) || new Date(), [contest.scheduledStartTime, normalizeDate]);
  const endTime = React.useMemo(() => {
    const explicitEnd = normalizeDate(contest.scheduledEndTime);
    if (explicitEnd) return explicitEnd;
    if (startTime && contest.duration) {
      return new Date(startTime.getTime() + contest.duration * 60000);
    }
    return null;
  }, [contest.scheduledEndTime, contest.duration, startTime, normalizeDate]);

  const [timeLeft, setTimeLeft] = React.useState('');

  React.useEffect(() => {
    const calculateTime = () => {
      const now = new Date().getTime();
      const targetDate = isLive ? endTime : startTime;

      if (!targetDate) {
        setTimeLeft('--:--:--');
        return;
      }

      const target = targetDate.getTime();
      const difference = target - now;

      if (difference <= 0) {
        setTimeLeft('00:00:00');
        return;
      }

      const h = Math.floor((difference / (1000 * 60 * 60)));
      const m = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
      const s = Math.floor((difference % (1000 * 60)) / 1000);

      setTimeLeft(
        `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
      );
    };

    calculateTime();
    const interval = setInterval(calculateTime, 1000);
    return () => clearInterval(interval);
  }, [startTime, endTime, isLive]);

  return (
    <div className="absolute inset-0 bg-white overflow-hidden cursor-pointer group">
      {/* === VISUAL ATMOSPHERE === */}
      <div className="absolute inset-0 pointer-events-none">
        {/* Top Left corner triangle */}
        <div className="absolute top-0 left-0 w-0 h-0" style={{
          borderTop: `90px solid ${isLive ? '#ef4444' : '#f97316'}`,
          borderRight: '90px solid transparent'
        }} />
        <div className="absolute top-0 left-0 w-0 h-0" style={{
          borderTop: `68px solid ${isLive ? '#dc2626' : '#ea580c'}`,
          borderRight: '68px solid transparent',
          opacity: 0.6
        }} />

        {/* Bottom Right corner triangle */}
        <div className="absolute bottom-0 right-0 w-0 h-0" style={{
          borderBottom: `70px solid ${isLive ? '#fecaca' : '#fed7aa'}`,
          borderLeft: '70px solid transparent',
          opacity: 0.5
        }} />

        {/* Soft center glow */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[60%] h-[80%] rounded-full blur-[80px]"
          style={{ background: isLive ? 'rgba(239,68,68,0.06)' : 'rgba(249,115,22,0.07)' }} />

        {/* Top-right dot grid texture */}
        <div className="absolute top-0 right-0 w-52 h-52 opacity-[0.07]" style={{
          backgroundImage: `radial-gradient(${themeHex} 1.5px, transparent 1.5px)`,
          backgroundSize: '16px 16px',
          maskImage: 'radial-gradient(circle at top right, black, transparent 75%)',
          WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 75%)'
        }} />

        {/* Bottom-left dot grid texture */}
        <div className="absolute bottom-0 left-0 w-40 h-40 opacity-[0.05]" style={{
          backgroundImage: `radial-gradient(${themeHex} 1.5px, transparent 1.5px)`,
          backgroundSize: '14px 14px',
          maskImage: 'radial-gradient(circle at bottom left, black, transparent 75%)',
          WebkitMaskImage: 'radial-gradient(circle at bottom left, black, transparent 75%)'
        }} />

        {/* Animated floating particles */}
        {[...Array(6)].map((_, i) => (
          <motion.div
            key={`p-${i}`}
            className="absolute rounded-full"
            style={{
              width: `${4 + (i % 3) * 3}px`,
              height: `${4 + (i % 3) * 3}px`,
              background: themeHex,
              opacity: 0.15,
              left: `${10 + i * 15}%`,
              top: `${20 + (i % 2) * 50}%`,
            }}
            animate={{ y: [0, -12, 0], opacity: [0.1, 0.25, 0.1] }}
            transition={{ duration: 2.5 + i * 0.5, repeat: Infinity, delay: i * 0.4, ease: 'easeInOut' }}
          />
        ))}
      </div>

      {/* Content Container */}
      <div className="relative z-10 h-full flex flex-col p-3 md:px-10 md:py-2">
        {/* Header: Title & Stats */}
        <div className="flex flex-row items-center justify-between gap-4 mb-0.5 md:mb-2">
          {/* PRO ONLY badge */}
          {contest.isProOnly && (
            <div className="absolute top-2 right-2 md:top-4 md:right-4 z-20">
              <div className="bg-amber-500 text-white text-[8px] md:text-[11px] font-black px-2 py-1 md:px-4 md:py-1.5 rounded-full shadow-lg flex items-center gap-1.5 border border-amber-600/20">
                <Star size={10} className="md:size-[14px]" fill="currentColor" />
                PRO ONLY
              </div>
            </div>
          )}

          {/* Left: Icon & Title Area */}
          <div className="flex items-center gap-4 md:gap-6">
            <div className={`w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center bg-white shadow-md border border-slate-100 text-${themeColor}-500 z-10`}>
              {isLive ? <Radio size={20} className="md:size-8" /> : <Trophy size={20} className="md:size-8" />}
            </div>
            <div className="flex flex-col">
              <h1 className={`text-base md:text-lg font-black leading-none uppercase tracking-tight ${isLive ? 'text-red-600' : 'text-orange-500'}`}>
                {contest.title}
              </h1>
              <p className="text-[7px] md:text-[9px] font-bold text-slate-400 mt-0.5 uppercase tracking-widest flex items-center gap-1.5">
                <span className={`w-3 md:w-5 h-px bg-slate-200`}></span>
                Test Your Knowledge. Win Rewards!
                <span className={`w-3 md:w-5 h-px bg-slate-200`}></span>
              </p>
            </div>
          </div>

          {/* Right: Refined Stats Section */}
          <div className="hidden md:flex items-center bg-slate-50/50 backdrop-blur-sm px-6 py-2 rounded-2xl border border-slate-100/50 gap-8">
            <div className="flex flex-col items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center bg-${themeColor}-50 text-${themeColor}-500 mb-0.5`}>
                <Target size={16} />
              </div>
              <span className="text-sm font-black text-slate-900 leading-none">{contest.totalQuestions} Qs</span>
              <span className="text-[8px] font-bold text-slate-400 uppercase">Questions</span>
            </div>
            <div className="w-px h-8 bg-slate-200/60"></div>
            <div className="flex flex-col items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center bg-${themeColor}-50 text-${themeColor}-500 mb-0.5`}>
                <Clock size={16} />
              </div>
              <span className="text-sm font-black text-slate-900 leading-none">{contest.duration} Mins</span>
              <span className="text-[8px] font-bold text-slate-400 uppercase">Duration</span>
            </div>
            <div className="w-px h-8 bg-slate-200/60"></div>
            <div className="flex flex-col items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center bg-${themeColor}-50 text-${themeColor}-500 mb-0.5`}>
                <Users size={16} />
              </div>
              <span className="text-sm font-black text-slate-900 leading-none">{participants} Joined</span>
              <span className="text-[8px] font-bold text-slate-400 uppercase">Participants</span>
            </div>
          </div>
        </div>

        {/* Middle: Prize Pool Box (Centered & Sharp) */}
        <div className="bg-white/90 backdrop-blur-md rounded-lg border border-slate-100 shadow-md p-2 md:px-4 md:py-3 my-auto mx-auto w-[92%] md:w-full max-w-xl">
          <div className="grid grid-cols-[1fr_auto_1fr_auto_1fr] items-center">
            <div className="flex flex-col items-center">
              <p className="text-[8px] md:text-[10px] font-black text-slate-800 uppercase tracking-wider mb-0.5">Prize Pool</p>
              <div className="flex items-center gap-2">
                <div className={`w-7 h-7 md:w-10 md:h-10 rounded-full flex items-center justify-center p-0.5 border ${isLive ? 'border-red-100 bg-red-50' : 'border-orange-100 bg-orange-50'}`}>
                  <div className={`w-full h-full rounded-full flex items-center justify-center text-white font-black text-xs md:text-sm shadow-sm ${isLive ? 'bg-red-500' : 'bg-orange-500'}`}>
                    ₹
                  </div>
                </div>
                <div className="flex flex-col">
                  <span className={`text-lg md:text-2xl font-black leading-none text-${themeColor}-500`}>
                    {prizePool.toLocaleString()}
                  </span>
                  <span className={`text-[8px] md:text-[10px] font-black uppercase text-${themeColor}-500`}>
                    Coins
                  </span>
                </div>
              </div>
            </div>
            <div className="w-px h-10 md:h-12 bg-slate-100 mx-1.5 md:mx-4"></div>
            <div className="flex flex-col items-center">
              <p className="text-[8px] md:text-[10px] font-black text-slate-800 uppercase tracking-wider mb-0.5">Entry Fee</p>
              <div className="flex items-center gap-1.5">
                {entryFee === 0 && <span className="text-emerald-500 font-bold text-base">›</span>}
                <div className={`text-lg md:text-3xl font-black leading-none uppercase ${entryFee === 0 ? 'text-emerald-500' : 'text-slate-800'}`}>
                  {entryFee === 0 ? 'FREE' : `${entryFee}`}
                </div>
                {entryFee === 0 && <span className="text-emerald-500 font-bold text-base">‹</span>}
              </div>
              {entryFee > 0 && <span className="text-[8px] md:text-[10px] font-black text-slate-400 uppercase">Coins</span>}
            </div>
            <div className="w-px h-10 md:h-12 bg-slate-100 mx-1.5 md:mx-4"></div>
            <div className="flex flex-col items-center">
              <p className="text-[8px] md:text-[10px] font-black text-slate-800 uppercase tracking-wider mb-0.5">
                {isLive ? 'Ends In' : 'Starts In'}
              </p>
              <div className="flex flex-col items-center">
                <div className={`text-lg md:text-2xl font-black leading-none tracking-tight text-${themeColor}-500`}>
                  {timeLeft || '--:--:--'}
                </div>
                <div className="flex items-center gap-2.5 mt-0.5">
                  <span className="text-[6px] md:text-[8px] font-black text-slate-500 uppercase">Hrs</span>
                  <span className="text-[6px] md:text-[8px] font-black text-slate-500 uppercase">Mins</span>
                  <span className="text-[6px] md:text-[8px] font-black text-slate-500 uppercase">Secs</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer: Calendar, Status, Action */}
        <div className="mt-2 flex flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <div className={`w-8 h-8 md:w-10 md:h-10 rounded-full bg-white border border-slate-100 shadow-sm flex items-center justify-center text-${themeColor}-500`}>
              <Calendar size={16} />
            </div>
            <div className="text-left">
              <p className="text-[7px] md:text-[8px] font-black text-slate-400 uppercase leading-none mb-0.5">Starts:</p>
              <p className="text-[10px] md:text-sm font-black text-slate-800">
                {startTime.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })} <span className="text-slate-400 font-bold ml-1 text-[8px] md:text-[10px]">
                  {startTime.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }).toLowerCase()}
                </span>
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 md:mr-12">
            <div className={`hidden md:flex px-3 py-1 rounded-full text-[9px] font-black items-center gap-1.5 border shadow-sm ${isLive ? 'bg-red-50 text-red-600 border-red-100' : 'bg-orange-50 text-orange-600 border-orange-100'}`}>
              <span className={`w-1 h-1 rounded-full ${isLive ? 'bg-red-500 animate-pulse' : 'bg-orange-500'}`}></span>
              {isLive ? 'LIVE' : 'UPCOMING'}
            </div>

            <button
              onClick={(e) => { e.stopPropagation(); onJoin(contest); }}
              className={`px-5 md:px-7 py-2 md:py-2.5 rounded-lg md:rounded-xl font-black text-xs md:text-sm text-white shadow-md transition-all active:scale-95 flex items-center gap-2 bg-gradient-to-r from-${themeColor}-500 to-${themeColor}-600 hover:from-${themeColor}-600 hover:to-${themeColor}-700`}
            >
              <span className="uppercase tracking-tight">{isLive ? 'Join Now' : 'Pre-Register'}</span>
              <Clock size={16} className="md:size-5" />
            </button>

            <button
              onClick={(e) => {
                e.stopPropagation();
                shareContent({
                  title: contest.title,
                  text: `Join this tournament!`,
                  url: getTestShareLink(contest.testId)
                });
              }}
              className="hidden md:flex px-5 md:px-7 py-2 md:py-2.5 rounded-lg md:rounded-xl border border-slate-200 bg-white text-slate-600 items-center justify-center gap-2 shadow-sm hover:bg-slate-50 transition-all active:scale-95"
            >
              <span className="text-xs md:text-sm font-black uppercase tracking-tight">Share</span>
              <Share2 size={16} className="md:size-5" />
            </button>
          </div>
        </div>
      </div>

    </div>
  );
}

// Spotlight Banner Slide
function SpotlightBannerSlide({
  banner,
  onNavigate
}: {
  banner: AppBanner;
  onNavigate: (page: string) => void;
}) {
  const data = banner.spotlightData;
  if (!data) return null;

  return (
    <div className="absolute inset-0 overflow-hidden cursor-pointer bg-[#FFFDF5] selection:bg-emerald-100">
      {/* Emerald Corner Triangles - exactly like reference image */}
      <div className="absolute inset-0 pointer-events-none">
        {/* Top Left */}
        <div className="absolute top-0 left-0 w-0 h-0" style={{ borderTop: '120px solid #047857', borderRight: '120px solid transparent' }} />
        <div className="absolute top-0 left-0 w-0 h-0" style={{ borderTop: '95px solid #065f46', borderRight: '95px solid transparent', opacity: 0.7 }} />
        {/* Bottom Right */}
        <div className="absolute bottom-0 right-0 w-0 h-0" style={{ borderBottom: '120px solid #047857', borderLeft: '120px solid transparent' }} />
        <div className="absolute bottom-0 right-0 w-0 h-0" style={{ borderBottom: '95px solid #065f46', borderLeft: '95px solid transparent', opacity: 0.7 }} />
        
        {/* Subtle dot pattern */}
        <div className="absolute inset-0 opacity-[0.07]" style={{ backgroundImage: 'radial-gradient(#d97706 1px, transparent 1px)', backgroundSize: '20px 20px' }} />
        
        {/* Soft glows */}
        <div className="absolute top-1/3 left-1/3 w-72 h-72 bg-amber-100/40 rounded-full blur-[80px]" />
      </div>

      {/* Gold inner border frame */}
      <div className="absolute inset-3 md:inset-5 border border-amber-300/30 rounded-2xl pointer-events-none" />

      {/* Confetti */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(14)].map((_, i) => {
          const colors = ['#10b981', '#f59e0b', '#f97316', '#3b82f6', '#a3e635'];
          const color = colors[i % colors.length];
          const shapes = [
            <div key={i} className="w-2 h-2 rounded-sm" style={{ background: color, opacity: 0.7 }} />,
            <div key={i} className="w-1.5 h-3 rounded-sm transform rotate-45" style={{ background: color, opacity: 0.7 }} />,
          ];
          return (
            <motion.div
              key={`c-${i}`}
              className="absolute"
              style={{ left: `${(i * 7.2) % 100}%` }}
              initial={{ top: '-5%', rotate: 0 }}
              animate={{ top: '105%', rotate: 360 * (i % 2 === 0 ? 1 : -1) }}
              transition={{ duration: 3 + (i % 3), repeat: Infinity, delay: i * 0.4, ease: 'linear' }}
            >
              {shapes[i % 2]}
            </motion.div>
          );
        })}
      </div>

      {/* Main Layout */}
      <div className="relative z-10 h-full flex items-center px-4 md:px-10">
        <div className="flex flex-row items-center gap-5 md:gap-14 w-full">
          
          {/* LEFT: Avatar Column */}
          <div className="relative shrink-0 flex flex-col items-center ml-6 md:ml-14" style={{ paddingTop: '24px', paddingBottom: '32px' }}>

            {/* Star ornaments around photo */}
            {[
              { top: '20%', left: '-18px', size: 14 },
              { top: '20%', right: '-18px', size: 14 },
              { bottom: '28%', left: '-12px', size: 9 },
              { bottom: '28%', right: '-12px', size: 9 },
            ].map((pos, i) => (
              <motion.div
                key={i}
                className="absolute text-amber-400 z-20"
                style={pos as any}
                animate={{ scale: [1, 1.3, 1], opacity: [0.8, 1, 0.8] }}
                transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.3 }}
              >
                <Star size={pos.size} fill="currentColor" />
              </motion.div>
            ))}

            {/* Profile Ring */}
            <div className="w-[88px] h-[88px] md:w-[176px] md:h-[176px] rounded-full relative z-10"
              style={{ background: 'linear-gradient(135deg, #fbbf24, #f59e0b, #fde68a, #f59e0b)', padding: '3px' }}
            >
              <div className="w-full h-full rounded-full bg-white p-[3px]">
                <div className="w-full h-full rounded-full overflow-hidden bg-slate-100">
                  <img 
                    src={data.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(data.userName || 'User')}&background=fef3c7&color=d97706&bold=true`} 
                    className="w-full h-full object-cover"
                    alt={data.userName}
                  />
                </div>
              </div>
            </div>

            {/* Rank Badge with Laurels */}
            <div className="relative mt-2 z-20">
              <svg viewBox="0 0 120 28" className="absolute w-full h-auto" style={{ width: 'calc(100% + 48px)', left: '-24px', top: '-6px' }}>
                <path d="M5 20 C 0 12, 8 4, 22 10" stroke="#047857" strokeWidth="2" fill="none" strokeLinecap="round"/>
                <path d="M10 24 C 6 18, 12 10, 25 15" stroke="#047857" strokeWidth="1.5" fill="none" strokeLinecap="round"/>
                <path d="M115 20 C 120 12, 112 4, 98 10" stroke="#047857" strokeWidth="2" fill="none" strokeLinecap="round"/>
                <path d="M110 24 C 114 18, 108 10, 95 15" stroke="#047857" strokeWidth="1.5" fill="none" strokeLinecap="round"/>
              </svg>
              <div className="text-white px-4 md:px-8 py-1 md:py-2 rounded-lg shadow-xl flex items-center justify-center"
                style={{ background: 'linear-gradient(to bottom, #047857, #065f46)', border: '1.5px solid rgba(16,185,129,0.3)' }}>
                <span className="text-[10px] md:text-sm font-black uppercase tracking-widest">RANK #{data.rank || '1'}</span>
              </div>
            </div>
          </div>

          {/* RIGHT: Text Content */}
          <div className="flex-1 flex flex-col items-center justify-center gap-1.5 md:gap-3 min-w-0 py-2">
            {/* Pill Badges */}
            <div className="flex items-center gap-2 md:gap-3">
              <div className="flex items-center gap-1 md:gap-2 px-2 md:px-4 py-1 md:py-1.5 bg-white rounded-full border border-amber-100 shadow-sm shadow-amber-100 whitespace-nowrap">
                <Trophy size={10} className="text-amber-500 shrink-0 md:size-[11px]" fill="#f59e0b" />
                <span className="text-[8px] md:text-[11px] font-black uppercase tracking-wider text-slate-700">Top Champion</span>
              </div>
              <div className="flex items-center gap-1 md:gap-2 px-2 md:px-4 py-1 md:py-1.5 bg-white rounded-full border border-blue-100 shadow-sm shadow-blue-100 whitespace-nowrap">
                <Star size={10} className="text-blue-500 shrink-0 md:size-[11px]" fill="#3b82f6" />
                <span className="text-[8px] md:text-[11px] font-black uppercase tracking-wider text-slate-700">Contest Star</span>
              </div>
            </div>

            {/* Congratulations with green chevrons */}
            <div className="flex items-center justify-center gap-1.5 md:gap-2">
              <span className="text-emerald-500 font-black leading-none" style={{ fontSize: 'clamp(16px, 2.5vw, 32px)' }}>›</span>
              <span className="font-black text-slate-800 leading-none text-center" style={{ fontSize: 'clamp(14px, 2.2vw, 28px)' }}>Congratulations!</span>
              <span className="text-emerald-500 font-black leading-none" style={{ fontSize: 'clamp(16px, 2.5vw, 32px)' }}>‹</span>
            </div>

            {/* Giant Name */}
            <div style={{ lineHeight: 1 }} className="text-center">
              <span
                className="font-black uppercase"
                style={{
                  fontSize: 'clamp(30px, 6.5vw, 88px)',
                  background: 'linear-gradient(90deg, #dc2626, #ea580c, #f97316, #fbbf24)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text',
                  letterSpacing: '-0.02em',
                  lineHeight: 1.05,
                }}
              >
                {data.userName}
              </span>
            </div>

            {/* Star divider */}
            <div className="flex items-center gap-2 w-full max-w-xs md:max-w-md">
              <div className="flex-1 h-px bg-gradient-to-r from-transparent to-amber-300" />
              <Star size={10} className="text-amber-400 shrink-0" fill="currentColor" />
              <div className="flex-1 h-px bg-gradient-to-l from-transparent to-amber-300" />
            </div>

            {/* Coins row */}
            <div className="flex items-center justify-center gap-2 md:gap-3">
              <div 
                className="shrink-0 rounded-full flex items-center justify-center shadow-md"
                style={{ width: 'clamp(24px, 3vw, 40px)', height: 'clamp(24px, 3vw, 40px)', background: 'linear-gradient(135deg, #f59e0b, #ea580c)' }}
              >
                <Coins className="text-white" style={{ width: 'clamp(12px, 1.5vw, 20px)', height: 'clamp(12px, 1.5vw, 20px)' }} />
              </div>
              <p className="font-semibold text-slate-600 text-center" style={{ fontSize: 'clamp(11px, 1.8vw, 22px)', lineHeight: 1.3 }}>
                <span className="font-black text-orange-500">{data.score || '85'} Coins</span>
                {' '}in the{' '}
                <span className="font-black text-emerald-700">{data.examName || 'CGL Topper Test'}.</span>
              </p>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}


interface DashboardProps {
  onStartTest: (id: string) => void;
  onNavigate: (page: string) => void;
  profile: UserProfile | null;
}

export default function Dashboard({ onStartTest, onNavigate, profile }: DashboardProps) {
  const [recentTests, setRecentTests] = useState<Test[]>([]);
  const [joiningContest, setJoiningContest] = useState<Test | null>(null);
  const [purchasingTest, setPurchasingTest] = useState<Test | null>(null);
  const [isContactModalOpen, setIsContactModalOpen] = useState(false);
  const [unlockedTestIds, setUnlockedTestIds] = useState<Set<string>>(new Set());
  const [slides, setSlides] = useState<CarouselSlide[]>([]);
  const [currentBannerIdx, setCurrentBannerIdx] = useState(0);
  const [userStats, setUserStats] = useState({
    avgScore: '--',
    accuracy: '--',
    globalRank: '--',
    testsDone: '--'
  });
  const { showToast } = useToast();
  const location = useLocation();
  const navigate = useNavigate();

  // Handle automatic join link
  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const joinId = params.get('join');
    if (joinId && !joiningContest && !purchasingTest) {
      const fetchTestForLink = async () => {
        try {
          const testRef = doc(db, 'tests', joinId);
          const testSnap = await getDoc(testRef);
          if (testSnap.exists()) {
            const testData = { testId: testSnap.id, ...testSnap.data() } as Test;
            const isTournament = testData.isTournament || (testData.entryFee && testData.entryFee > 0);
            
            if (isTournament) {
              setJoiningContest(testData);
            } else if (testData.isPremium && profile?.subscriptionStatus !== 'premium' && !unlockedTestIds.has(testData.testId)) {
              setPurchasingTest(testData);
            } else {
              onStartTest(testData.testId);
            }
            
            // Clear search params using navigate to ensure React state is updated
            navigate(location.pathname, { replace: true });
          }
        } catch (err) {
          console.error("Error fetching test for shared link:", err);
        }
      };
      fetchTestForLink();
    }
  }, [location.search, joiningContest, purchasingTest, navigate, unlockedTestIds, profile]);

  // Fetch unlocked tests
  useEffect(() => {
    const fetchUnlocked = async () => {
      if (!profile?.userId) {
        setUnlockedTestIds(new Set());
        return;
      }
      try {
        const snap = await getDocs(collection(db, 'users', profile.userId, 'unlockedTests'));
        setUnlockedTestIds(new Set(snap.docs.map(d => d.id)));
      } catch (err) {
        console.error("Error fetching unlocked tests:", err);
      }
    };
    fetchUnlocked();
  }, [profile?.userId]);

  // Fetch both admin banners and tournaments together
  useEffect(() => {
    const fetchCarouselData = async () => {
      try {
        const now = new Date();
        const normalizeDate = (d: any) => {
          if (!d) return null;
          if (typeof d.toDate === 'function') return d.toDate();
          return new Date(d);
        };

        // Fetch active admin banners
        const bannerSnap = await getDocs(query(collection(db, 'app_banners')));
        const adminBanners: CarouselSlide[] = bannerSnap.docs
          .map(d => ({ id: d.id, ...d.data() } as AppBanner))
          .filter(b => {
            if (!b.isActive) return false;
            if (b.scheduledAt && new Date(b.scheduledAt) > now) return false;
            return true;
          })
          .sort((a, b) => (a.priority || 0) - (b.priority || 0))
          .map(b => ({ type: 'banner' as const, data: b }));

        // Fetch live/upcoming tournaments
        // Fetch recent tests to find tournaments
        const tournamentSnap = await getDocs(
          query(collection(db, 'tests'), orderBy('createdAt', 'desc'), limit(50))
        );
        const tournamentSlides: CarouselSlide[] = [];
        tournamentSnap.docs.forEach(d => {
          const t = { testId: d.id, ...d.data() } as Test;
          const isTournament = t.isTournament || t.testMode === 'tournament';
          if (!isTournament || t.isResultDeclared || t.status === 'unpublished') return;

          const start = normalizeDate(t.scheduledStartTime);
          let end = normalizeDate(t.scheduledEndTime);

          if (!end && start && t.duration) {
            end = new Date(start.getTime() + t.duration * 60000);
          }

          if (end && end < now) return; // already ended

          if (start && now >= start && (!end || now <= end)) {
            tournamentSlides.push({ type: 'contest', data: t, status: 'live' });
          } else if (start && now < start) {
            tournamentSlides.push({ type: 'contest', data: t, status: 'upcoming' });
          }
        });

        // Priority sort for tournaments (Live first)
        tournamentSlides.sort((a, b) => {
          const aS = (a as any).status;
          const bS = (b as any).status;
          if (aS === 'live' && bS !== 'live') return -1;
          if (aS !== 'live' && bS === 'live') return 1;
          return 0;
        });

        // Set slides: Tournaments first, then admin banners
        setSlides([...tournamentSlides, ...adminBanners]);
      } catch (error) {
        console.error('Error fetching carousel data:', error);
      }
    };
    fetchCarouselData();
  }, []);

  // Auto-play carousel
  useEffect(() => {
    if (slides.length <= 1) return;
    const interval = setInterval(() => {
      setCurrentBannerIdx(prev => (prev + 1) % slides.length);
    }, 5000);
    return () => clearInterval(interval);
  }, [slides]);

  const handleBannerClickWithTracking = async (slide: CarouselSlide) => {
    if (slide.type === 'banner') {
      const banner = slide.data as AppBanner;
      
      // Tracking
      try {
        await updateDoc(doc(db, 'app_banners', banner.id), {
          clicks: increment(1)
        });
      } catch (err) {
        console.error("Error tracking banner click:", err);
      }

      if (!banner.link) return;
      if (banner.link.startsWith('http')) {
        window.open(banner.link, '_blank');
      } else {
        onNavigate(banner.link.startsWith('/') ? banner.link.substring(1) : banner.link);
      }
    } else {
      setJoiningContest(slide.data as Test);
    }
  };

  useEffect(() => {
    const fetchTests = async () => {
      try {
        // 1. Fetch user's submitted test IDs
        const submittedIds = new Set<string>();
        if (profile?.userId) {
          const attemptSnap = await getDocs(query(
            collection(db, 'attempts'),
            where('userId', '==', profile.userId)
          ));
          attemptSnap.docs.forEach(d => submittedIds.add(d.data().testId));
        }

        // 2. Fetch a pool of recent tests
        const q = query(collection(db, 'tests'), orderBy('createdAt', 'desc'), limit(40));
        const querySnapshot = await getDocs(q);
        const allTests = querySnapshot.docs.map(doc => ({ testId: doc.id, ...doc.data() } as Test));

        const now = new Date();

        // Helper to handle both Firestore Timestamps and ISO strings
        const normalizeDate = (d: any) => {
          if (!d) return null;
          if (typeof d.toDate === 'function') return d.toDate();
          return new Date(d);
        };

        // 3. Filter out submitted and ended tests
        const eligibleTests = allTests.filter(t => {
          // Rule 1: Never show already submitted tests
          if (submittedIds.has(t.testId)) return false;

          // Rule 2: For tournaments, hide if ended or results declared
          if (t.isTournament || t.testMode === 'tournament') {
            if (t.isResultDeclared) return false;
            const start = normalizeDate(t.scheduledStartTime);
            let end = normalizeDate(t.scheduledEndTime);

            // If end time missing, calculate from duration
            if (!end && start && t.duration) {
              end = new Date(start.getTime() + t.duration * 60000);
            }

            if (end && end < now) return false;
          }

          // Rule 3: Hide if unpublished
          if (t.status === 'unpublished') return false;

          return true;
        });

        // 4. Priority Sorting Logic
        const getPriority = (t: Test) => {
          const isTournament = t.isTournament || t.testMode === 'tournament';
          if (!isTournament) return 3;

          const startTime = normalizeDate(t.scheduledStartTime);
          let endTime = normalizeDate(t.scheduledEndTime);

          if (!endTime && startTime && t.duration) {
            endTime = new Date(startTime.getTime() + t.duration * 60000);
          }

          if (startTime && now >= startTime && (!endTime || now <= endTime)) return 1; // Live
          if (startTime && now < startTime) return 2; // Upcoming
          return 3;
        };

        const sortedTests = eligibleTests.sort((a, b) => {
          const pA = getPriority(a);
          const pB = getPriority(b);
          if (pA !== pB) return pA - pB;
          return normalizeDate(b.createdAt).getTime() - normalizeDate(a.createdAt).getTime();
        });

        setRecentTests(sortedTests.slice(0, 3));
      } catch (err) {
        console.error("Error fetching recommended tests:", err);
      }
    };

    fetchTests();
  }, [profile?.userId]);

  // Fetch Real Stats for Cards
  useEffect(() => {
    if (!profile?.userId) return;

    const fetchRealStats = async () => {
      try {
        // 1. Fetch Attempts for Tests Done, Avg Score, Accuracy
        const attemptsSnap = await getDocs(query(
          collection(db, 'attempts'),
          where('userId', '==', profile.userId)
        ));
        
        const attempts = attemptsSnap.docs.map(doc => doc.data());
        const testsDoneCount = new Set(attempts.map(a => a.testId)).size;
        
        let totalAccuracy = 0;
        let validAttempts = 0;

        attempts.forEach(a => {
          if (typeof a.accuracy === 'number') {
            totalAccuracy += a.accuracy;
            validAttempts++;
          }
        });

        const avgAcc = validAttempts > 0 ? Math.round(totalAccuracy / validAttempts) : 0;

        // 2. Fetch Global Rank (Based on Coins)
        // We fetch top 100 to avoid massive reads, if not in top 100, show 100+
        const usersSnap = await getDocs(query(
          collection(db, 'users'),
          orderBy('coins', 'desc'),
          limit(100)
        ));
        
        let rank = '100+';
        const rankIdx = usersSnap.docs.findIndex(d => d.id === profile.userId);
        if (rankIdx !== -1) {
          rank = `#${rankIdx + 1}`;
        }

        setUserStats({
          avgScore: `${avgAcc}%`, // Accuracy is a good proxy for score performance
          accuracy: `${avgAcc}%`,
          globalRank: rank,
          testsDone: testsDoneCount.toString()
        });
      } catch (err) {
        console.error("Error fetching real stats:", err);
      }
    };

    fetchRealStats();
  }, [profile?.userId, profile?.coins]);

  const stats = [
    { label: 'Avg Score', value: userStats.avgScore, icon: Target, gradient: 'from-indigo-500 to-blue-600', shadow: 'shadow-indigo-200/50' },
    { label: 'Accuracy', value: userStats.accuracy, icon: Zap, gradient: 'from-emerald-500 to-teal-600', shadow: 'shadow-emerald-200/50' },
    { label: 'Global Rank', value: userStats.globalRank, icon: Trophy, gradient: 'from-orange-400 to-amber-600', shadow: 'shadow-amber-200/50' },
    { label: 'Tests Done', value: userStats.testsDone, icon: Clock, gradient: 'from-rose-500 to-purple-600', shadow: 'shadow-rose-200/50' },
  ];

  const currentSlide = slides[currentBannerIdx];

  return (
    <div className="space-y-6 md:space-y-8">
      {/* Dynamic Banner Carousel */}
      {slides.length > 0 && currentSlide && (
        <div className="space-y-3">
          <div className="relative w-full aspect-[21/11] md:aspect-[21/8.8] rounded-xl overflow-hidden bg-slate-100 shadow-sm border border-slate-100">
            <AnimatePresence mode="wait">
              <motion.div
                key={currentBannerIdx}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.4, ease: "easeOut" }}
                className="absolute inset-0 cursor-grab active:cursor-grabbing touch-none"
                drag="x"
                dragConstraints={{ left: 0, right: 0 }}
                dragElastic={0.7}
                onDragEnd={(_, info) => {
                  const swipeThreshold = 50;
                  const velocityThreshold = 500;

                  if (info.offset.x < -swipeThreshold || info.velocity.x < -velocityThreshold) {
                    // Swiped Left -> Next
                    setCurrentBannerIdx(prev => (prev + 1) % slides.length);
                  } else if (info.offset.x > swipeThreshold || info.velocity.x > velocityThreshold) {
                    // Swiped Right -> Previous
                    setCurrentBannerIdx(prev => (prev - 1 + slides.length) % slides.length);
                  }
                }}
                onClick={() => handleBannerClickWithTracking(currentSlide)}
              >
                {currentSlide.type === 'banner' ? (
                  currentSlide.data.type === 'spotlight' ? (
                    <SpotlightBannerSlide banner={currentSlide.data} onNavigate={onNavigate} />
                  ) : (
                    <div
                      className="absolute inset-0 cursor-pointer overflow-hidden group"
                      onClick={() => handleBannerClickWithTracking(currentSlide)}
                    >
                      <img
                        src={currentSlide.data.imageUrl}
                        alt={currentSlide.data.title || 'App Banner'}
                        className="w-full h-full object-cover transition-transform duration-700 ease-in-out group-hover:scale-105"
                      />
                      {currentSlide.data.title && (
                        <div className="absolute inset-x-0 bottom-0 top-1/2 bg-gradient-to-t from-slate-900/90 via-slate-900/40 to-transparent flex items-end p-5 md:p-8">
                          <h2 className="text-xl md:text-3xl font-black text-white leading-tight drop-shadow-md transform translate-y-2 opacity-90 transition-all duration-300 group-hover:translate-y-0 group-hover:opacity-100">
                            {currentSlide.data.title}
                          </h2>
                        </div>
                      )}
                    </div>
                  )
                ) : (
                  <ContestBannerSlide
                    contest={currentSlide.data as Test}
                    status={(currentSlide as Extract<CarouselSlide, { type: 'contest' }>).status}
                    onJoin={(t) => setJoiningContest(t)}
                    showToast={showToast}
                  />
                )}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Carousel Dot Indicators — horizontally centered below the banner */}
          {slides.length > 1 && (
            <div className="flex items-center justify-center gap-2">
              {slides.map((slide, idx) => (
                <button
                  key={idx}
                  onClick={() => setCurrentBannerIdx(idx)}
                  className={`h-2 rounded-full transition-all duration-300 ${idx === currentBannerIdx
                    ? 'w-6 bg-slate-600'
                    : slide.type === 'contest'
                      ? (slide as Extract<CarouselSlide, { type: 'contest' }>).status === 'live'
                        ? 'w-2 bg-red-400'
                        : 'w-2 bg-amber-400'
                      : 'w-2 bg-slate-300'
                    }`}
                />
              ))}
            </div>
          )}
        </div>
      )}

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6">
        {stats.map((stat, i) => (
          <div
            key={i}
            className={`relative overflow-hidden bg-gradient-to-br ${stat.gradient} p-3 md:p-5 rounded-xl border border-white/10 flex items-center gap-2.5 md:gap-4 group hover:scale-[1.02] transition-all duration-300`}
          >
            {/* Glossy Overlay Effect */}
            <div className="absolute inset-0 bg-gradient-to-tr from-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

            {/* Background Decoration Circle */}
            <div className="absolute -right-4 -top-4 w-16 h-16 bg-white/10 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-700" />

            <div className="w-9 h-9 md:w-12 md:h-12 shrink-0 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform duration-300 relative z-10 text-white">
              <stat.icon size={18} className="md:w-[22px] md:h-[22px]" />
            </div>

            <div className="flex-1 min-w-0 text-left relative z-10">
              <p className="text-[9px] md:text-[11px] font-bold text-white/80 mb-0.5 uppercase tracking-widest leading-none">{stat.label}</p>
              <p className="text-base md:text-xl font-black text-white drop-shadow-sm leading-tight">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      <PollWidget profile={profile} />

      
      {/* Quick Action Hub - Single Horizontal Card */}
      <div className="bg-white rounded-xl border border-slate-100 shadow-sm p-1 md:p-1.5 flex flex-row items-stretch overflow-hidden">
        {[
          { 
            label: 'Battle', 
            desc: '1v1', 
            icon: Swords, 
            path: '/battle', 
            text: 'text-rose-500',
            bg: 'hover:bg-rose-50/50',
            iconBg: 'bg-rose-50'
          },
          { 
            label: 'Ranking', 
            desc: 'Global', 
            icon: Trophy, 
            path: '/earn/leaderboard', 
            text: 'text-amber-500',
            bg: 'hover:bg-amber-50/50',
            iconBg: 'bg-amber-50'
          },
          { 
            label: 'Refer', 
            desc: 'Earn', 
            icon: Gift, 
            path: '/refer', 
            text: 'text-emerald-500',
            bg: 'hover:bg-emerald-50/50',
            iconBg: 'bg-emerald-50'
          },
        ].map((action, i) => (
          <React.Fragment key={i}>
            <button
              onClick={() => onNavigate(action.path.startsWith('/') ? action.path.substring(1) : action.path)}
              className={`flex-1 flex flex-col md:flex-row items-center justify-center gap-1.5 md:gap-4 py-3 md:py-6 px-2 rounded-lg transition-all duration-300 ${action.bg} group`}
            >
              <div className={`w-10 h-10 md:w-14 md:h-14 flex items-center justify-center rounded-full ${action.iconBg} transition-transform group-hover:scale-110 group-hover:rotate-3 ${action.text}`}>
                <action.icon size={22} className="md:w-7 md:h-7" />
              </div>
              <div className="text-center md:text-left">
                <h4 className="text-[10px] md:text-sm font-black text-slate-900 leading-none uppercase tracking-tight">{action.label}</h4>
                <p className="hidden md:block text-[8px] md:text-[10px] font-bold text-slate-400 mt-1 uppercase tracking-widest">{action.desc}</p>
              </div>
            </button>
            {i < 2 && <div className="w-px bg-slate-100 my-3 md:my-4" />}
          </React.Fragment>
        ))}
      </div>


      <div className="grid lg:grid-cols-3 gap-8">
        {/* Recommended Section */}
        <div className="lg:col-span-2 xl:col-span-3 space-y-6">
          <div className="flex items-center justify-between">
            <h3 className="text-xl font-bold text-slate-900">Recommended for You</h3>
            <button
              onClick={() => onNavigate('tests')}
              className="text-emerald-600 font-semibold text-sm hover:underline"
            >
              View All
            </button>
          </div>

          <div className="grid sm:grid-cols-2 xl:grid-cols-3 gap-6">
            {recentTests.length > 0 ? recentTests.map((test) => {
              if (test.isTournament) {
                return (
                  <ContestCard
                    key={test.testId}
                    test={test}
                    profile={profile}
                    onJoin={(t) => setJoiningContest(t)}
                    onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
                  />
                );
              }
              const testExamCat = test.examCategory || test.category || test.examType || 'General';
              return (
                <div
                  key={test.testId}
                  onClick={() => {
                    const isUnlocked = unlockedTestIds.has(test.testId);
                    const isPro = profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date());
                    const isPremiumAndLocked = test.isPremium && !isPro && !isUnlocked;
                    if (isPremiumAndLocked) {
                      setPurchasingTest(test);
                    } else {
                      onStartTest(test.testId);
                    }
                  }}
                  className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full"
                >
                  {(() => {
                    const isPYQ = test.testMode === 'previous-year';
                    const isSectional = test.testMode === 'sectional';
                    const themeColor = isSectional ? '#3b82f6' : isPYQ ? '#a855f7' : '#10b981';

                    return (
                      <>
                        {/* Decorative SVG Wave (Top-Left) */}
                        <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                          <svg viewBox="0 0 100 100" className="w-full h-full">
                            <defs>
                              <linearGradient id={`recCornerGradient-${test.testId}`} x1="0%" y1="0%" x2="100%" y2="100%">
                                <stop offset="0%" stopColor={themeColor} />
                                <stop offset="100%" stopColor={themeColor} />
                              </linearGradient>
                              <filter id={`recCardShadow-${test.testId}`} x="-20%" y="-20%" width="140%" height="140%">
                                <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                                <feOffset dx="1" dy="1" result="offsetblur" />
                                <feMerge>
                                  <feMergeNode />
                                  <feMergeNode in="SourceGraphic" />
                                </feMerge>
                              </filter>
                            </defs>
                            <path
                              d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z"
                              fill={`url(#recCornerGradient-${test.testId})`}
                              filter={`url(#recCardShadow-${test.testId})`}
                            />
                          </svg>
                        </div>

                        {/* Top-Right Professional Dot Grid */}
                        <div
                          className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                          style={{
                            backgroundImage: `radial-gradient(${themeColor} 1.2px, transparent 1.2px)`,
                            backgroundSize: '12px 12px',
                            maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                            WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                          }}
                        ></div>

                        <div className="relative z-10 p-5 flex-1 flex flex-col">
                          <div className="flex items-start gap-3 mb-4">
                            <div className={`w-11 h-11 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center shrink-0 relative z-10 ${isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}`}>
                              {isSectional ? <BookOpen size={20} /> : isPYQ ? <Clock size={20} /> : <FileText size={20} />}
                            </div>
                            <div className="flex-1">
                              <h3 className={`text-[16px] font-black text-slate-800 leading-tight z-10 transition-colors line-clamp-2 uppercase ${isSectional ? 'group-hover:text-blue-600' : 'group-hover:text-emerald-600'}`}>
                                {test.title}
                              </h3>
                              {test.isPremium && profile?.subscriptionStatus !== 'premium' && !unlockedTestIds.has(test.testId) && (
                                <div className="mt-2 inline-flex bg-amber-50 px-2 py-0.5 rounded border border-amber-200 text-[9px] font-black text-amber-600 items-center gap-1 shadow-sm uppercase tracking-wider">
                                  <LockKeyhole size={10} strokeWidth={3} /> PREMIUM
                                </div>
                              )}
                            </div>
                          </div>

                          <div className="flex flex-wrap items-center gap-3 mb-4 z-10">
                            <div className="text-[11px] font-black text-slate-500 flex items-center gap-2 uppercase bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
                              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                                <Award size={14} className="text-slate-400" />
                              </div>
                              {testExamCat}
                            </div>
                            <div className="flex items-center gap-2 text-[12px] font-bold text-slate-600 bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
                              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                                <Target size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
                              </div>
                              <span>{test.totalQuestions} Qs</span>
                            </div>
                            <div className="flex items-center gap-2 text-[12px] font-bold text-slate-600 bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
                              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                                <Clock size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
                              </div>
                              <span>{test.duration} mins</span>
                            </div>
                          </div>

                          <div className="space-y-3 text-[12px] text-slate-600 font-medium z-10 mb-6 flex-1 tracking-tight">
                            <div className="flex items-center gap-3">
                              <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                                <CheckCircle2 size={14} className={isSectional ? 'text-blue-500' : isPYQ ? 'text-purple-500' : 'text-emerald-500'} />
                              </div>
                              <span>Detailed Solutions & Analytics</span>
                            </div>
                            <div className="flex items-center gap-3">
                              <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                                <TrendingUp size={14} className={isSectional ? 'text-blue-500' : isPYQ ? 'text-purple-500' : 'text-emerald-500'} />
                              </div>
                              <span>State & National Leaderboard</span>
                            </div>
                            <div className={`flex items-center gap-2 text-[11px] font-bold mt-2 pt-2 border-t border-slate-50 z-10 uppercase tracking-tight ${isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}`}>
                              <div className={`w-6 h-6 rounded-full shadow-sm flex items-center justify-center ${isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                                <Globe size={14} />
                              </div>
                              English, Hindi
                            </div>
                          </div>

                          <div className="mt-auto flex items-center gap-2 z-10">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                const isUnlocked = unlockedTestIds.has(test.testId);
                                const isPro = profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date());
                                const isPremiumAndLocked = test.isPremium && !isPro && !isUnlocked;
                                
                                if (isPremiumAndLocked) {
                                  setPurchasingTest(test);
                                } else {
                                  onStartTest(test.testId);
                                }
                              }}
                              className={`
                                flex-1 py-3 rounded-xl font-black text-sm shadow-sm transition-all flex items-center justify-center gap-2 active:scale-95 uppercase tracking-wider
                                ${test.isPremium && profile?.subscriptionStatus !== 'premium' && !unlockedTestIds.has(test.testId)
                                  ? 'bg-amber-500 text-white hover:bg-amber-600 shadow-amber-100'
                                  : isSectional ? 'bg-blue-500 text-white hover:bg-blue-600 shadow-blue-100' : 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-emerald-100'}
                              `}
                            >
                              {test.isPremium && profile?.subscriptionStatus !== 'premium' && !unlockedTestIds.has(test.testId) ? (
                                <>Unlock Now <LockKeyhole size={16} strokeWidth={3} /></>
                              ) : (
                                <>Practice Now</>
                              )}
                            </button>

                            <button
                              onClick={async (e) => {
                                e.stopPropagation();
                                const result = await shareContent({
                                  title: test.title,
                                  text: `Hey! Check out this ${test.isTournament ? 'Tournament' : 'Test'}: "${test.title}" on Rankearn. Start practicing and winning!`,
                                  url: getTestShareLink(test.testId),
                                  imageUrl: '/share-banner.png'
                                });
                                if (result.success) {
                                  showToast(result.method === 'native' ? 'Shared successfully!' : 'Link copied to clipboard!', 'success');
                                }
                              }}
                              className="px-4 py-3 rounded-xl border border-slate-100 text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all active:scale-95 shadow-sm bg-white shrink-0 flex items-center justify-center gap-2"
                              title="Share Test"
                            >
                              <Share2 size={18} />
                              <span className="text-[10px] font-black uppercase tracking-wider">Share</span>
                            </button>
                          </div>
                        </div>
                      </>
                    );
                  })()}
                </div>
              );
            }) : (
              <div className="col-span-full bg-white p-10 rounded-xl border border-dashed border-slate-200 text-center">
                <p className="text-slate-500">No tests available yet. Check back soon!</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Support & Help Hub - Horizontal Card */}
      <div className="bg-white rounded-xl border border-slate-100 shadow-sm p-1 md:p-1.5 flex flex-row items-stretch overflow-hidden">
        {[
          { 
            label: 'Support', 
            desc: 'Chat Support', 
            icon: MessageCircle, 
            path: '/support', 
            text: 'text-indigo-500',
            bg: 'hover:bg-indigo-50/50',
            iconBg: 'bg-indigo-50'
          },
          { 
            label: 'Feedback', 
            desc: 'Give Feedback', 
            icon: Star, 
            path: '/feedback', 
            text: 'text-amber-500',
            bg: 'hover:bg-amber-50/50',
            iconBg: 'bg-amber-50'
          },
          { 
            label: 'Contact Us', 
            desc: 'Get in Touch', 
            icon: Mail, 
            path: '/contactus', 
            text: 'text-teal-500',
            bg: 'hover:bg-teal-50/50',
            iconBg: 'bg-teal-50'
          },
        ].map((action, i) => (
          <React.Fragment key={i}>
            <button
              onClick={() => {
                if (action.path === '/contactus') {
                  setIsContactModalOpen(true);
                } else {
                  onNavigate(action.path.startsWith('/') ? action.path.substring(1) : action.path);
                }
              }}
              className={`flex-1 flex flex-col md:flex-row items-center justify-center gap-1.5 md:gap-4 py-3 md:py-6 px-2 rounded-lg transition-all duration-300 ${action.bg} group`}
            >
              <div className={`w-10 h-10 md:w-14 md:h-14 flex items-center justify-center rounded-full ${action.iconBg} transition-transform group-hover:scale-110 group-hover:rotate-3 ${action.text}`}>
                <action.icon size={22} className="md:w-7 md:h-7" />
              </div>
              <div className="text-center md:text-left">
                <h4 className="text-[10px] md:text-sm font-black text-slate-900 leading-none uppercase tracking-tight">{action.label}</h4>
                <p className="hidden md:block text-[8px] md:text-[10px] font-bold text-slate-400 mt-1 uppercase tracking-widest">{action.desc}</p>
              </div>
            </button>
            {i < 2 && <div className="w-px bg-slate-100 my-3 md:my-4" />}
          </React.Fragment>
        ))}
      </div>

      <AnimatePresence>
        {joiningContest && (
          <ContestJoinModal
            test={joiningContest}
            profile={profile}
            onClose={() => setJoiningContest(null)}
            onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
            onJoinSuccess={() => {
              const testId = joiningContest.testId;
              setJoiningContest(null);
              onStartTest(testId);
            }}
          />
        )}

        {purchasingTest && (
          <TestPurchaseModal
            test={purchasingTest}
            profile={profile}
            onClose={() => setPurchasingTest(null)}
            onPurchaseSuccess={() => {
              const testId = purchasingTest.testId;
              setUnlockedTestIds(prev => new Set([...prev, testId]));
              setPurchasingTest(null);
              onStartTest(testId);
            }}
          />
        )}

        {/* Contact Us Modal */}
        {isContactModalOpen && (
          <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsContactModalOpen(false)}
              className="absolute inset-0 bg-slate-950/60 backdrop-blur-sm"
            />
            {/* Modal Body */}
            <motion.div
              initial={{ scale: 0.95, opacity: 0, y: 15 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.95, opacity: 0, y: 15 }}
              transition={{ duration: 0.25, ease: "easeOut" }}
              className="relative w-full max-w-[360px] bg-white rounded-2xl p-6 shadow-2xl overflow-hidden border border-slate-100"
            >
              {/* Top Gradient Header Decoration */}
              <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-emerald-500 via-teal-500 to-indigo-500" />

              {/* Close Button */}
              <button
                onClick={() => setIsContactModalOpen(false)}
                className="absolute top-4 right-4 p-1.5 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-50 transition-colors"
              >
                <X size={18} />
              </button>

              <div className="flex flex-col items-center text-center mb-6 pt-2">
                <div className="w-12 h-12 bg-emerald-50 rounded-2xl flex items-center justify-center text-emerald-600 mb-3 shadow-inner border border-emerald-100/50">
                  <MessageCircle size={24} />
                </div>
                <h3 className="text-xl font-black text-slate-900 leading-tight uppercase tracking-tight">Contact Us</h3>
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-1">Choose your preferred channel</p>
              </div>

              {/* Contact Options List */}
              <div className="space-y-4">
                {/* Option 1: WhatsApp */}
                <a
                  href="https://wa.me/917766863787"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-4 p-3.5 bg-emerald-50/60 hover:bg-emerald-50 rounded-xl border border-emerald-100/50 transition-all duration-300 group hover:scale-[1.02] active:scale-[0.98]"
                >
                  <div className="w-10 h-10 rounded-xl bg-emerald-500 text-white flex items-center justify-center shadow-md shadow-emerald-500/10 shrink-0">
                    <MessageSquare size={20} />
                  </div>
                  <div className="flex-1 text-left">
                    <p className="text-[10px] font-black text-emerald-600 uppercase tracking-wider leading-none mb-1">WhatsApp Support</p>
                    <p className="text-sm font-black text-slate-800 leading-tight">+91 7766863787</p>
                    <p className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">Fastest Response</p>
                  </div>
                </a>

                {/* Option 2: Call Support */}
                <a
                  href="tel:+917766863787"
                  className="flex items-center gap-4 p-3.5 bg-purple-50/60 hover:bg-purple-50 rounded-xl border border-purple-100/50 transition-all duration-300 group hover:scale-[1.02] active:scale-[0.98]"
                >
                  <div className="w-10 h-10 rounded-xl bg-purple-500 text-white flex items-center justify-center shadow-md shadow-purple-500/10 shrink-0">
                    <Phone size={20} />
                  </div>
                  <div className="flex-1 text-left">
                    <p className="text-[10px] font-black text-purple-600 uppercase tracking-wider leading-none mb-1">Call Support</p>
                    <p className="text-sm font-black text-slate-800 leading-tight">+91 7766863787</p>
                    <p className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">Mon-Sat, 10 AM to 6 PM IST</p>
                  </div>
                </a>

                {/* Option 3: Email Support */}
                <a
                  href="mailto:rankearnhelp@gmail.com"
                  className="flex items-center gap-4 p-3.5 bg-indigo-50/60 hover:bg-indigo-50 rounded-xl border border-indigo-100/50 transition-all duration-300 group hover:scale-[1.02] active:scale-[0.98]"
                >
                  <div className="w-10 h-10 rounded-xl bg-indigo-500 text-white flex items-center justify-center shadow-md shadow-indigo-500/10 shrink-0">
                    <Mail size={20} />
                  </div>
                  <div className="flex-1 text-left">
                    <p className="text-[10px] font-black text-indigo-600 uppercase tracking-wider leading-none mb-1">Email Support</p>
                    <p className="text-sm font-black text-slate-800 leading-tight break-all">rankearnhelp@gmail.com</p>
                    <p className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">Queries & Account Help</p>
                  </div>
                </a>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}