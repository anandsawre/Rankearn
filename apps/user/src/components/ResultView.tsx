import React, { useState, useEffect, useRef } from 'react';
import { Attempt, Question, Test } from '../types';
import { useNavigate } from 'react-router-dom';
import MathText from './MathText';
import { calculateAttemptMetrics, formatTimeTaken } from '../utils/attemptStats';
import { 
  Trophy, 
  CheckCircle2, 
  XCircle, 
  Clock, 
  Target, 
  ArrowRight,
  TrendingUp,
  Zap,
  ChevronLeft,
  ChevronRight,
  RotateCcw,
  Eye,
  BarChart2,
  AlertCircle,
  Globe,
  Coins,
  IndianRupee,
  Medal,
  PartyPopper,
  CreditCard,
  Crown,
  Sparkles,
  Star,
  Share2
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import Leaderboard from './Leaderboard';
import { shareContent, getResultShareLink } from '../utils/shareUtils';
import { useToast } from './Toast';

interface ResultViewProps {
  attempt: Attempt;
  questions: Question[];
  negativeMarking?: number;
  test?: Test | null;
  onClose: () => void;
  onWalletClick?: () => void;
  onReattemptWrong?: (wrongQuestionIds: string[]) => void;
}

// ─── Confetti Particle ───────────────────────────────────────────────────────
interface Particle {
  id: number;
  x: number;
  color: string;
  delay: number;
  duration: number;
  size: number;
  shape: 'circle' | 'square' | 'star';
}

function ConfettiCanvas() {
  const particles: Particle[] = Array.from({ length: 60 }, (_, i) => ({
    id: i,
    x: Math.random() * 100,
    color: [
      '#f59e0b', '#10b981', '#6366f1', '#ec4899',
      '#f97316', '#8b5cf6', '#14b8a6', '#fbbf24'
    ][Math.floor(Math.random() * 8)],
    delay: Math.random() * 2,
    duration: 2.5 + Math.random() * 2,
    size: 6 + Math.random() * 8,
    shape: (['circle', 'square', 'star'] as const)[Math.floor(Math.random() * 3)],
  }));

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {particles.map((p) => (
        <motion.div
          key={p.id}
          className="absolute top-0"
          style={{ left: `${p.x}%` }}
          initial={{ y: -20, opacity: 1, rotate: 0 }}
          animate={{
            y: '110vh',
            opacity: [1, 1, 0],
            rotate: Math.random() > 0.5 ? 360 : -360,
          }}
          transition={{
            duration: p.duration,
            delay: p.delay,
            ease: 'linear',
            repeat: Infinity,
            repeatDelay: Math.random() * 2,
          }}
        >
          {p.shape === 'circle' && (
            <div style={{ width: p.size, height: p.size, backgroundColor: p.color, borderRadius: '50%' }} />
          )}
          {p.shape === 'square' && (
            <div style={{ width: p.size, height: p.size, backgroundColor: p.color, borderRadius: 2 }} />
          )}
          {p.shape === 'star' && (
            <Star size={p.size} style={{ color: p.color }} fill="currentColor" />
          )}
        </motion.div>
      ))}
    </div>
  );
}

// ─── Rank Styling ────────────────────────────────────────────────────────────
function getRankConfig(rank: number) {
  if (rank === 1) return {
    icon: Crown,
    label: 'TOP CHAMPION',
    text: 'text-amber-600',
    border: 'border-amber-100',
    bg: 'bg-amber-50',
    iconBg: 'bg-amber-500'
  };
  if (rank === 2) return {
    icon: Medal,
    label: 'SECOND PLACE',
    text: 'text-slate-600',
    border: 'border-slate-100',
    bg: 'bg-slate-50',
    iconBg: 'bg-slate-400'
  };
  if (rank === 3) return {
    icon: Medal,
    label: 'THIRD PLACE',
    text: 'text-orange-600',
    border: 'border-orange-100',
    bg: 'bg-orange-50',
    iconBg: 'bg-orange-500'
  };
  return {
    icon: Trophy,
    label: `RANKED #${rank}`,
    text: 'text-emerald-600',
    border: 'border-emerald-100',
    bg: 'bg-emerald-50',
    iconBg: 'bg-emerald-500'
  };
}

// ─── Contest Prize Banner ─────────────────────────────────────────────────
interface ContestPrizeBannerProps {
  coinsEarned: number;
  rank: number;
  testTitle?: string;
  onWalletClick?: () => void;
}

function ContestPrizeBanner({ coinsEarned, rank, testTitle, onWalletClick }: ContestPrizeBannerProps) {
  const cfg = getRankConfig(rank);
  const RankIcon = cfg.icon;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="relative bg-white rounded-2xl border border-slate-200 shadow-xl overflow-hidden group"
    >
      <ConfettiCanvas />

      {/* 
        Subtle Background Pattern 
        Adding a very faint grid/dot pattern to make the card feel 'high-end'
      */}
      <div className="absolute inset-0 opacity-[0.03] pointer-events-none" 
           style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 1px)', backgroundSize: '24px 24px' }} />

      {/* App-theme background glow like Dashboard cards */}
      <div className={`absolute top-0 left-0 right-0 h-40 bg-gradient-to-b ${cfg.bg} to-white/0 opacity-60 pointer-events-none`} />

      <div className="relative z-10 p-4 md:p-8 flex flex-col md:flex-row items-center gap-8">
        {/* Left: Medal Icon matching app style */}
        <div className="shrink-0 relative">
          <div className={`w-24 h-24 md:w-32 md:h-32 rounded-full ${cfg.bg} border-4 ${cfg.border} flex items-center justify-center`}>
            <RankIcon className={cfg.text} size={rank === 1 ? 50 : 40} />
          </div>
          <div className={`absolute -bottom-2 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full ${cfg.iconBg} text-white text-xs font-black shadow-md whitespace-nowrap`}>
            RANK #{rank}
          </div>
        </div>

        {/* Center: Content */}
        <div className="flex-1 text-center md:text-left">
          <div className="flex flex-wrap items-center justify-center md:justify-start gap-2 mb-3">
             <div className={`px-2.5 py-1 rounded-md ${cfg.bg} ${cfg.text} text-[10px] font-black uppercase tracking-widest`}>
               {cfg.label}
             </div>
             <div className="px-2.5 py-1 rounded-md bg-slate-100 text-slate-600 text-[10px] font-black uppercase tracking-widest">
               CONTEST COMPLETED
             </div>
          </div>
          
          <h2 className="text-2xl md:text-3xl font-black text-slate-900 mb-2">
            Congratulations on your win!
          </h2>
          <p className="text-slate-500 font-medium">
            You successfully earned <span className={`font-black ${cfg.text}`}>{coinsEarned.toLocaleString()} Coins</span> in the <b>{testTitle || 'Contest'}</b>.
          </p>
        </div>

        {/* Right: Prize & Action Card - Glassmorphism style */}
        <div className="shrink-0 w-full md:w-auto">
          <div className="relative group/reward">
            {/* Animated Glow behind the reward card */}
            <div className="absolute -inset-1 bg-gradient-to-r from-amber-400/20 via-emerald-400/20 to-amber-400/20 rounded-2xl blur-lg opacity-0 group-hover/reward:opacity-100 transition-opacity duration-700" />
            
            <div className="relative bg-white/60 backdrop-blur-xl rounded-2xl p-6 border border-white shadow-[0_8px_32px_rgba(0,0,0,0.04)] flex flex-col gap-5 min-w-[200px]">
               <div className="flex items-center gap-4">
                  {/* The enhanced Coin Icon we just built */}
                  <div className="relative overflow-visible shrink-0">
                    <div className="absolute inset-0 bg-amber-400/30 blur-2xl rounded-full scale-110 animate-pulse" />
                    <motion.div 
                      animate={{ rotateY: [0, 15, -15, 0] }}
                      transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                      className="relative w-14 h-14 bg-gradient-to-br from-amber-300 via-amber-500 to-amber-700 rounded-full flex items-center justify-center shadow-[0_8px_20px_rgba(245,158,11,0.4)] border-2 border-amber-200/50 z-10"
                    >
                      {/* Inner clipping layer for shimmer ONLY */}
                      <div className="absolute inset-0 rounded-full overflow-hidden pointer-events-none">
                        <motion.div 
                          animate={{ x: ['-200%', '200%'] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut", repeatDelay: 1 }}
                          className="absolute inset-0 w-1/2 bg-gradient-to-r from-transparent via-white/40 to-transparent -skew-x-20 z-10"
                        />
                      </div>

                      <div className="absolute inset-1 rounded-full border border-amber-100/30 pointer-events-none" />
                      <IndianRupee className="text-white drop-shadow-[0_2px_4px_rgba(0,0,0,0.3)] z-20" size={28} />
                    </motion.div>
                  </div>
                  <div>
                     <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] leading-none mb-1.5">Prize Earned</p>
                     <p className="text-2xl font-black text-slate-900 leading-none tabular-nums">{coinsEarned.toLocaleString()} Coins</p>
                  </div>
               </div>
               
               {onWalletClick && (
                 <button
                   onClick={onWalletClick}
                   className="w-full px-6 py-3 bg-emerald-600 text-white rounded-xl font-bold text-xs hover:bg-emerald-700 transition-all flex items-center justify-center gap-2 shadow-lg shadow-emerald-200/50 active:scale-95 group/btn"
                 >
                   <span>View in Wallet</span>
                   <ArrowRight size={14} className="group-hover/btn:translate-x-1 transition-transform" />
                 </button>
               )}
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

// ─── Main ResultView ──────────────────────────────────────────────────────────
export default function ResultView({ attempt, questions, negativeMarking = 0, test, onClose, onWalletClick, onReattemptWrong }: ResultViewProps) {
  const navigate = useNavigate();
  const { showToast } = useToast();
  const metrics = calculateAttemptMetrics(attempt, questions, negativeMarking);
  const correct = metrics.correct;
  const wrongQuestions = questions.filter(q => attempt.answers?.[q.questionId] !== undefined && attempt.answers?.[q.questionId] !== q.correctAnswer);
  const wrong = metrics.wrong;
  const skipped = metrics.skipped;

  const isContestWin = attempt.isTournament && attempt.status === 'declared' && (attempt.tournamentRank || 0) > 0;
  const rank = attempt.tournamentRank || 0;

  // Section-wise analysis
  const sections = Array.from(new Set(questions.map(q => q.subject || 'General')));
  const sectionStats = sections.map(sec => {
    const secQuestions = questions.filter(q => (q.subject || 'General') === sec);
    const secCorrect = secQuestions.filter(q => attempt.answers?.[q.questionId] === q.correctAnswer).length;
    const secTotal = secQuestions.length;
    const percentage = (secCorrect / secTotal) * 100;
    
    let rating = 'Poor';
    let color = 'text-red-500';
    let bg = 'bg-red-50';
    
    if (percentage >= 90) { rating = 'Excellent'; color = 'text-emerald-500'; bg = 'bg-emerald-50'; }
    else if (percentage >= 75) { rating = 'Best'; color = 'text-blue-500'; bg = 'bg-blue-50'; }
    else if (percentage >= 50) { rating = 'Good'; color = 'text-amber-500'; bg = 'bg-amber-50'; }

    return { name: sec, correct: secCorrect, total: secTotal, rating, color, bg, percentage };
  });

  const stats = [
    { label: 'Total Score', value: metrics.score.toFixed(2), icon: Trophy, color: 'text-amber-500', bg: 'bg-amber-50' },
    { label: 'Accuracy', value: `${metrics.accuracy.toFixed(1)}%`, icon: Target, color: 'text-blue-500', bg: 'bg-blue-50' },
    { label: 'Time Taken', value: formatTimeTaken(attempt.timeTaken), icon: Clock, color: 'text-purple-500', bg: 'bg-purple-50' },
    { label: 'Correct', value: correct, icon: CheckCircle2, color: 'text-emerald-500', bg: 'bg-emerald-50' },
  ];

  const handleShareResult = async () => {
    const text = attempt.isTournament && attempt.status === 'declared'
      ? `I ranked #${rank} in the "${test?.title || 'Contest'}" on Rankearn! 🏆 Score: ${metrics.score.toFixed(2)}, Accuracy: ${metrics.accuracy.toFixed(1)}%. Can you beat me?`
      : `I scored ${metrics.score.toFixed(2)} with ${metrics.accuracy.toFixed(1)}% accuracy in "${test?.title || 'Test'}" on Rankearn! 🎯 Check out my results.`;
    
    const result = await shareContent({
      title: 'My Rankearn Result',
      text,
      url: getResultShareLink(attempt.attemptId!)
    });

    if (result.success) {
      showToast(
        result.method === 'native' ? 'Result shared!' : 'Result link copied!',
        'success'
      );
    }
  };


  return (
    <div className="bg-transparent px-0 py-4 md:pb-12 md:pt-0 overflow-y-auto">
      <div className="max-w-7xl mx-auto space-y-4 pt-0">

        {/* ── Contest Prize Banner (only shown for winners) ── */}
        {isContestWin && (
          <ContestPrizeBanner
            coinsEarned={attempt.coinsEarned!}
            rank={rank}
            testTitle={test?.title}
            onWalletClick={onWalletClick}
          />
        )}



        {/* ── Integrated Analysis Card ── */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-[0_8px_40px_rgba(0,0,0,0.06)] overflow-hidden">
          {/* Card Header (Finance Style) */}
          <div className="p-4 md:p-5 border-b border-slate-100 bg-slate-50/30 flex flex-col md:flex-row md:items-center justify-between gap-6 relative">
            <div className="flex items-center gap-5">
              <div className="w-12 h-12 bg-emerald-500 text-white rounded-2xl flex items-center justify-center shadow-[0_10px_25px_-5px_rgba(16,185,129,0.4),0_8px_10px_-6px_rgba(16,185,129,0.4)] shrink-0">
                <BarChart2 size={24} strokeWidth={3} />
              </div>
              <div>
                <h3 className="text-xl md:text-2xl font-black text-slate-900 leading-none">Result Analysis</h3>
                <p className="text-xs text-slate-500 font-medium mt-1.5">
                  Performance insights
                </p>
              </div>
            </div>
            
            <div className="absolute top-6 right-6 md:static">
              <button 
                onClick={handleShareResult}
                className="flex items-center gap-2 px-3 py-2 md:px-4 md:py-2 bg-emerald-50 text-emerald-600 rounded-lg font-bold text-xs md:text-sm border border-emerald-100 hover:bg-emerald-100 transition-all active:scale-95"
              >
                <Share2 size={16} />
                <span className="hidden xs:inline">Share Result</span>
                <span className="xs:hidden">Share</span>
              </button>
            </div>
          </div>

          {/* Top Stats Grid (Inside Card) */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-px bg-slate-200 border-b border-slate-200">
            {stats.map((stat, i) => (
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: i * 0.1 }}
                key={i} 
                className="bg-white p-4 md:p-6 text-center hover:bg-slate-50 transition-colors group"
              >
                <div className={`w-12 h-12 md:w-16 md:h-16 ${stat.bg} ${stat.color} rounded-2xl flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform shadow-sm`}>
                  <stat.icon size={28} className="md:w-8 md:h-8" />
                </div>
                <p className="text-[10px] md:text-xs font-black text-slate-400 uppercase tracking-widest mb-1.5">{stat.label}</p>
                <p className="text-2xl md:text-3xl font-black text-slate-900 tracking-tighter">{stat.value}</p>
              </motion.div>
            ))}
          </div>

          <div className="p-4 md:p-8">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl md:text-2xl font-bold text-slate-900 flex items-center gap-4">
                <div className="w-1.5 h-8 bg-emerald-600 rounded-full shadow-sm" />
                Section-wise Analysis
              </h3>
            </div>
          <div className="grid gap-4">
            {sectionStats.map((sec, i) => (
              <motion.div 
                initial={{ x: -20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ delay: i * 0.1 }}
                key={i} 
                className="flex flex-col md:flex-row md:items-center justify-between p-4 md:p-6 bg-slate-50 rounded-xl border border-slate-100 gap-4 hover:bg-slate-100/50 transition-all group/sec"
              >
                <div className="flex items-center gap-5">
                  <div className={`w-14 h-14 ${sec.bg} ${sec.color} rounded-xl flex items-center justify-center font-black text-lg shadow-sm group-hover/sec:scale-105 transition-transform`}>
                    {sec.percentage.toFixed(0)}%
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-900 text-lg">{sec.name}</h4>
                    <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest">{sec.correct} / {sec.total} Correct</p>
                  </div>
                </div>
                <div className="flex items-center justify-between md:justify-end gap-8">
                  <div className="text-right">
                    <p className={`font-black uppercase tracking-tighter text-xl ${sec.color}`}>{sec.rating}</p>
                    <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Performance</p>
                  </div>
                  <div className="w-24 h-2.5 bg-slate-200 rounded-full overflow-hidden shadow-inner">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: `${sec.percentage}%` }}
                      transition={{ duration: 1.5, ease: "easeOut" }}
                      className={`h-full ${sec.bg.replace('bg-', 'bg-').replace('-50', '-500')} shadow-[0_0_10px_rgba(0,0,0,0.1)]`} 
                    />
                  </div>
                </div>
              </motion.div>
            ))}
            </div>
          </div>

          {/* ── Action Buttons (Inside Card Footer) ── */}
          <div className="px-4 py-6 md:px-10 md:py-8 bg-slate-50 border-t border-slate-100">
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <button 
                onClick={() => navigate(`/review/${attempt.attemptId}`)}
                className="flex items-center justify-center gap-2 py-3 px-6 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all shadow-md shadow-blue-100 active:scale-95 text-sm"
              >
                <Eye size={20} />
                Review Questions
              </button>
              
              <button 
                onClick={() => onReattemptWrong?.(wrongQuestions.map(q => q.questionId))}
                disabled={wrong === 0}
                className="flex items-center justify-center gap-2 py-3 px-6 bg-amber-500 text-white rounded-xl font-bold hover:bg-amber-600 transition-all shadow-md shadow-amber-100 disabled:opacity-50 active:scale-95 text-sm"
              >
                <RotateCcw size={20} />
                Re-attempt
              </button>

              {isContestWin && onWalletClick ? (
                <button 
                  onClick={onWalletClick}
                  className="flex items-center justify-center gap-2 py-3 px-6 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 transition-all shadow-md shadow-emerald-100 active:scale-95 text-sm"
                >
                  <Coins size={20} />
                  View Wallet
                </button>
              ) : (
                 <div className="hidden lg:block"></div> 
              )}
    
              <button 
                onClick={onClose}
                className="flex items-center justify-center gap-2 py-3 px-6 bg-slate-900 text-white rounded-xl font-bold hover:bg-slate-800 transition-all shadow-md shadow-slate-200 active:scale-95 text-sm"
              >
                Back to Dashboard
              </button>
            </div>
          </div>
        </div>



      </div>

      {/* ── Leaderboard Section ── */}
      <div className="max-w-7xl mx-auto mt-12">
        <Leaderboard 
          testId={attempt.testId} 
          isContest={test?.isTournament} 
        />
      </div>
    </div>
  );
}
