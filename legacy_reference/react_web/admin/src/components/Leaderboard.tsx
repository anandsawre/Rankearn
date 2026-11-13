import React, { useState, useEffect, useRef, useCallback } from 'react';
import { db } from '../firebase';
import { Trophy, Medal, Star, TrendingUp, MapPin, Target, CheckCircle2, Clock, Coins, ChevronDown, Calendar, Download } from 'lucide-react';
import { collection, query, orderBy, limit, getDocs, where } from 'firebase/firestore';
import { LeaderboardEntry } from '../types';
import { motion, AnimatePresence } from 'motion/react';

interface LeaderboardProps {
  testId?: string;
  isContest?: boolean;
}

export default function Leaderboard({ testId, isContest }: LeaderboardProps) {
  const [entries, setEntries] = useState<LeaderboardEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [type, setType] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [showDropdown, setShowDropdown] = useState(false);
  const [downloadingId, setDownloadingId] = useState<string | null>(null);
  const cardRefs = useRef<Record<string, HTMLDivElement | null>>({});

  const handleDownload = useCallback(async (entry: LeaderboardEntry) => {
    // node = outer wrapper div (includes pt-5 padding for badge)
    const node = cardRefs.current[entry.userId];
    if (!node) return;
    setDownloadingId(entry.userId);
    try {
      // Pre-fetch profile image → dataURL to avoid CORS blank/blur
      const imgEl = node.querySelector('img') as HTMLImageElement | null;
      let originalSrc = '';
      if (imgEl?.src) {
        originalSrc = imgEl.src;
        try {
          const resp = await fetch(imgEl.src, { mode: 'cors' });
          const blob = await resp.blob();
          const du = await new Promise<string>((res) => {
            const r = new FileReader();
            r.onload = () => res(r.result as string);
            r.readAsDataURL(blob);
          });
          imgEl.src = du;
          await new Promise((res) => setTimeout(res, 60));
        } catch { /* keep original */ }
      }

      // Hide download button before capture
      const dlBtn = node.querySelector('[title="Download as PNG"]') as HTMLElement | null;
      if (dlBtn) dlBtn.style.display = 'none';

      const { toPng } = await import('html-to-image');
      // Capture the outer wrapper directly — pt-5 ensures badge is inside bounds
      const dataUrl = await toPng(node, {
        cacheBust: true,
        pixelRatio: 3,
        backgroundColor: '#ffffff',
      });

      // Restore
      if (dlBtn) dlBtn.style.display = '';
      if (imgEl && originalSrc) imgEl.src = originalSrc;

      const link = document.createElement('a');
      link.download = `rankearn-${entry.userName.replace(/\s+/g, '-').toLowerCase()}-rank${entry.rank}.png`;
      link.href = dataUrl;
      link.click();
    } catch (err) {
      console.error('Download failed:', err);
    } finally {
      setDownloadingId(null);
    }
  }, []);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      setLoading(true);
      try {
        if (testId) {
          // Fetch the test config to get leaderboardLimit
          const { getDoc, doc } = await import('firebase/firestore');
          const testDoc = await getDoc(doc(db, 'tests', testId));
          const testData = testDoc.exists() ? testDoc.data() : null;
          const limitValue = testData?.leaderboardLimit || 20;

          // Fetch Rankings for a specific Test/Tournament
          // We remove orderBy from Firestore query to avoid index requirements
          const q = query(
            collection(db, 'attempts'),
            where('testId', '==', testId)
          );
          const querySnapshot = await getDocs(q);
          
          // Get unique users and their best performance (Best Score, then Least Time)
          const userScoresMap = new Map<string, any>();
          querySnapshot.docs.forEach(doc => {
            const d = doc.data();
            const attemptScore = d.score !== undefined ? d.score : 0;
            const attemptTime = d.timeTaken !== undefined ? d.timeTaken : Infinity;
            
            const existing = userScoresMap.get(d.userId);
            
            const isBetter = !existing || 
              attemptScore > existing.score || 
              (attemptScore === existing.score && attemptTime < (existing.timeTaken || Infinity));

            if (isBetter) {
              userScoresMap.set(d.userId, { 
                userId: d.userId, 
                score: attemptScore, 
                timeTaken: attemptTime === Infinity ? 0 : attemptTime,
                endTime: d.endTime || new Date().toISOString(),
                coinsEarned: d.coinsEarned || 0
              });
            }
          });

          // Sort and slice by the admin-defined limit
          const sortedResults = Array.from(userScoresMap.values())
            .sort((a, b) => {
              if (b.score !== a.score) return b.score - a.score;
              if (a.timeTaken !== b.timeTaken) return a.timeTaken - b.timeTaken;
              // Tertiary tie-breaker: Submission Time (Earlier is better)
              return new Date(a.endTime).getTime() - new Date(b.endTime).getTime();
            })
            .slice(0, limitValue);

          const topUserIds = sortedResults.map(u => u.userId);
          const usersMap = new Map();

          if (topUserIds.length > 0) {
            // Fetch User Profiles for these users
            // Firestore 'in' query supports max 30 IDs. If limit is > 30, we might need multiple fetches or just show placeholders.
            // For now, most limits will be < 30.
            const chunkedIds = [];
            for (let i = 0; i < topUserIds.length; i += 30) {
              chunkedIds.push(topUserIds.slice(i, i + 30));
            }

            for(const chunk of chunkedIds) {
              const usersSnap = await getDocs(query(collection(db, 'users'), where('userId', 'in', chunk)));
              usersSnap.forEach(u => usersMap.set(u.id, u.data()));
            }

            const formattedEntries: LeaderboardEntry[] = sortedResults.map((u, idx) => {
                const userData = usersMap.get(u.userId);
                const isPro = userData?.subscriptionStatus === 'premium' && 
                              (!userData?.subscriptionEndDate || new Date(userData.subscriptionEndDate) > new Date());

                return {
                  userId: u.userId,
                  userName: userData?.name || 'Anonymous Aspirant',
                  profilePhoto: userData?.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(userData?.name || 'U')}`,
                  score: Math.round(u.score * 100) / 100,
                  rank: idx + 1,
                  state: userData?.state || '',
                  type: 'test-wise',
                  testId,
                  timeTaken: u.timeTaken,
                  coinsEarned: u.coinsEarned,
                  isPro
                };
              });
            
            setEntries(formattedEntries);
          } else {
            setEntries([]);
          }
        } else {
          // Fetch Global Leaderboard directly from Users collection for real-time rankings
          // Only show users who are marked as eligible (participated in tournament / won coins)
          const q = query(
            collection(db, 'users'), 
            where('isLeaderboardEligible', '==', true),
            orderBy('coins', 'desc'), 
            limit(20)
          );
          const querySnapshot = await getDocs(q);
          const data: LeaderboardEntry[] = querySnapshot.docs.map((doc, idx) => {
            const userData = doc.data();
            const isPro = userData?.subscriptionStatus === 'premium' && 
                          (!userData?.subscriptionEndDate || new Date(userData.subscriptionEndDate) > new Date());
            return {
              userId: userData.userId || doc.id,
              userName: userData.name || 'Anonymous Aspirant',
              profilePhoto: userData.profilePhoto || `https://ui-avatars.com/api/?name=${userData.name || 'U'}`,
              score: userData.coins || 0,
              rank: idx + 1,
              state: userData.state || '',
              type: 'monthly',
              isPro
            };
          });
          setEntries(data);
        }
      } catch (error) {
        console.error('Error fetching leaderboard:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchLeaderboard();
  }, [type, testId]);

  if (loading) {
    return (
      <div className="w-full py-12 flex justify-center items-center">
         <div className="w-8 h-8 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (entries.length === 0) {
    return (
      <div className="bg-white rounded-2xl p-12 text-center border border-slate-100 shadow-sm">
        <Trophy size={48} className="mx-auto text-slate-200 mb-4" />
        <h3 className="text-lg font-bold text-slate-900">No rankings yet</h3>
        <p className="text-slate-500 text-sm">Be the first one to appear on the leaderboard!</p>
      </div>
    );
  }

  const displayEntries = entries;

  return (
    <div className="w-full space-y-8 pb-12">
      <div className="w-full space-y-6">
        <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
          {/* Unified Header */}
          <div className="py-4 px-6 md:px-8 bg-slate-50/50 border-b border-slate-100 flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="w-full md:w-auto flex flex-col items-start text-left">
              <div className="flex items-center gap-2 mb-1">
                <Trophy className="text-amber-500" size={20} />
                <h2 className="text-xl font-bold text-slate-900">{testId ? 'Test Leaderboard' : 'Global Leaderboard'}</h2>
              </div>
              <p className="text-slate-500 text-xs pl-7">{testId ? 'Participant Rankings' : 'Global Rankings'}</p>
            </div>
            
            {!testId && (
              <div className="relative">
                <button
                  onClick={() => setShowDropdown(!showDropdown)}
                  className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 rounded-md shadow-sm text-xs font-bold text-slate-700 hover:bg-slate-50 transition-all active:scale-95"
                >
                  <Calendar size={14} className="text-emerald-500" />
                  <span className="capitalize">{type} Rankings</span>
                  <ChevronDown 
                    size={14} 
                    className={`transition-transform duration-300 ${showDropdown ? 'rotate-180' : ''}`} 
                  />
                </button>

                <AnimatePresence>
                  {showDropdown && (
                    <>
                      {/* Backdrop to close on outside click */}
                      <div 
                        className="fixed inset-0 z-10" 
                        onClick={() => setShowDropdown(false)} 
                      />
                      
                      <motion.div
                        initial={{ opacity: 0, y: 10, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: 10, scale: 0.95 }}
                        className="absolute right-0 mt-2 w-40 bg-white rounded-md border border-slate-100 shadow-xl z-20 overflow-hidden"
                      >
                        {(['daily', 'weekly', 'monthly'] as const).map((t) => (
                          <button
                            key={t}
                            onClick={() => {
                              setType(t);
                              setShowDropdown(false);
                            }}
                            className={`w-full text-left px-4 py-3 text-xs font-bold transition-all flex items-center justify-between ${type === t ? 'bg-emerald-50 text-emerald-600' : 'text-slate-600 hover:bg-slate-50'}`}
                          >
                            <span className="capitalize">{t} Rankings</span>
                            {type === t && <CheckCircle2 size={12} className="text-emerald-500" />}
                          </button>
                        ))}
                      </motion.div>
                    </>
                  )}
                </AnimatePresence>
              </div>
            )}
          </div>

          {/* Top 5 Rankings - Uniform Design */}
          <div className="px-6 md:px-8 pt-10 pb-8 border-b border-slate-50 bg-gradient-to-b from-slate-50/50 to-white">
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4 md:gap-5">
              {[0, 1, 2, 3, 4].map((idx) => {
                const entry = displayEntries[idx];
                if (!entry) return null;

                const rankColors = {
                  1: { border: 'border-amber-400', bg: 'bg-amber-50', text: 'text-amber-600', label: 'CHAMPION', icon: Trophy, medal: 'bg-amber-500', boxBg: 'bg-amber-100', boxBorder: 'border-amber-200' },
                  2: { border: 'border-slate-300', bg: 'bg-slate-50', text: 'text-slate-600', label: 'SILVER', icon: Medal, medal: 'bg-slate-400', boxBg: 'bg-slate-100', boxBorder: 'border-slate-200' },
                  3: { border: 'border-orange-200', bg: 'bg-orange-50', text: 'text-orange-700', label: 'BRONZE', icon: Medal, medal: 'bg-orange-500', boxBg: 'bg-orange-100', boxBorder: 'border-orange-200' },
                  4: { border: 'border-blue-200', bg: 'bg-blue-50', text: 'text-blue-600', label: 'ELITE', icon: Star, medal: 'bg-blue-500', boxBg: 'bg-blue-100', boxBorder: 'border-blue-200' },
                  5: { border: 'border-indigo-200', bg: 'bg-indigo-50', text: 'text-indigo-600', label: 'PRO', icon: Star, medal: 'bg-indigo-500', boxBg: 'bg-indigo-100', boxBorder: 'border-indigo-200' }
                }[entry.rank]!;

                const Icon = rankColors.icon;

                return (
                  // Outer wrapper: pt-5 ensures the -top-3 badge stays inside capture bounds
                  <div
                    key={entry.userId}
                    ref={el => { cardRefs.current[entry.userId] = el; }}
                    className="pt-5 group"
                  >
                  <div 
                    className={`relative p-4 md:p-5 rounded-xl border ${rankColors.border} ${rankColors.bg} shadow-sm hover:shadow-md transition-all z-0 flex flex-col items-center text-center`}
                  >
                    {/* Download Button — visible on hover */}
                    <button
                      onClick={() => handleDownload(entry)}
                      disabled={downloadingId === entry.userId}
                      className="absolute top-2 right-2 z-10 w-7 h-7 rounded-full bg-white/80 hover:bg-white border border-slate-200 shadow-sm flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-200 hover:scale-110 active:scale-95 disabled:opacity-50"
                      title="Download as PNG"
                    >
                      {downloadingId === entry.userId
                        ? <div className="w-3.5 h-3.5 border-2 border-slate-400 border-t-transparent rounded-full animate-spin" />
                        : <Download size={12} className="text-slate-500" />}
                    </button>
                    {/* Rank Badge — label + rank number combined */}
                    <div className={`absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-1 ${rankColors.medal} text-white text-[10px] font-black rounded-full shadow-md whitespace-nowrap flex items-center gap-1`}>
                      <span>{rankColors.label}</span>
                      <span className="opacity-80">#{entry.rank}</span>
                    </div>

                    <div className="flex flex-col items-center text-center space-y-4">
                      <div className="relative">
                        <img 
                          src={entry.profilePhoto} 
                          className="w-20 h-20 rounded-full object-cover border-2 border-white shadow-md group-hover:scale-105 transition-transform shrink-0" 
                          alt={entry.userName} 
                        />
                      </div>

                      <div>
                        <div className="flex items-center justify-center gap-1.5 mb-0.5">
                          <h3 className="font-bold text-slate-900 group-hover:text-emerald-600 transition-colors truncate">{entry.userName}</h3>
                          {entry.isPro && (
                            <div className="bg-amber-100 text-amber-600 p-0.5 rounded shadow-sm border border-amber-200">
                              <Star size={10} fill="currentColor" />
                            </div>
                          )}
                        </div>
                        <div className="flex items-center justify-center gap-1.5 text-slate-500 text-[10px] font-bold mt-0.5">
                          <MapPin size={10} className="text-slate-400" />
                          <span>{entry.state || 'N/A'}</span>
                        </div>
                      </div>

                      <div className={`w-full py-2.5 px-4 rounded-lg border ${rankColors.boxBorder} ${rankColors.boxBg} flex flex-col items-center justify-center gap-0.5`}>
                        <span className={`text-[9px] font-black ${rankColors.text} uppercase tracking-[0.18em]`}>
                          {testId ? 'Total Score' : 'Total Coins'}
                        </span>
                        <span className="text-lg font-black text-slate-900 uppercase tracking-tight leading-none">
                          {entry.score} <span className="text-[10px] font-bold text-emerald-500 ml-1">{testId ? 'pts' : 'Coins'}</span>
                        </span>
                      </div>

                      {testId && (
                        <div className="flex items-center gap-4 w-full justify-center">
                          <div className="flex flex-col items-center">
                             <div className="flex items-center gap-1 text-slate-500">
                               <Clock size={10} />
                               <span className="text-[10px] font-bold">{entry.timeTaken}s</span>
                             </div>
                             <p className="text-[8px] font-black text-slate-400 uppercase">Time</p>
                          </div>
                          {(entry.coinsEarned || 0) > 0 && (
                            <div className="flex flex-col items-center">
                               <div className="flex items-center gap-1 text-orange-500">
                                 <Coins size={10} />
                                 <span className="text-[10px] font-bold">{entry.coinsEarned}</span>
                               </div>
                               <p className="text-[8px] font-black text-slate-400 uppercase">Won</p>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* List Headers */}
          <div className="px-8 py-4 bg-slate-50/30 border-b border-slate-50 flex items-center justify-between text-[10px] font-bold text-slate-400 uppercase tracking-widest">
            <div className="flex items-center gap-8">
              <span className="w-8">Rank</span>
              <span>Aspirant</span>
            </div>
            <div className="flex items-center gap-12">
              <span className="w-16 text-right">{testId ? 'Score' : 'Coins'}</span>
              <span className="w-16 text-right">Trend</span>
            </div>
          </div>

          <div className="divide-y divide-slate-50">
            {displayEntries.slice(5).map((entry, i) => (
              <motion.div 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.03 }}
                key={entry.userId} 
                className="px-8 py-5 flex items-center justify-between hover:bg-slate-50 transition-all group"
              >
                <div className="flex items-center gap-8">
                  <span className="w-8 font-bold text-slate-400 group-hover:text-slate-600 transition-colors">#{i + 6}</span>
                  <div className="flex items-center gap-4">
                    <img src={entry.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(entry.userName || 'User')}`} className="w-10 h-10 rounded-xl object-cover shadow-sm group-hover:scale-105 transition-transform shrink-0" alt="" />
                    <div className="flex flex-col">
                      <div className="flex items-center gap-1.5">
                        <span className="font-bold text-slate-700 group-hover:text-slate-900 transition-colors uppercase tracking-tight">{entry.userName}</span>
                        {entry.isPro && (
                          <div className="bg-amber-100 text-amber-600 p-0.5 rounded shadow-sm border border-amber-200">
                            <Star size={10} fill="currentColor" />
                          </div>
                        )}
                      </div>
                      <span className="text-[8px] font-bold text-slate-400 uppercase tracking-widest">{entry.state || 'Aspirant'}</span>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-12">
                  <div className="flex flex-col items-end">
                    <span className="text-right font-bold text-emerald-600 tabular-nums leading-none">{entry.score} pts</span>
                    {testId && (
                      <div className="flex items-center gap-2 mt-1">
                         <span className="text-[9px] font-bold text-slate-400 flex items-center gap-0.5">
                           <Clock size={8} /> {entry.timeTaken}s
                         </span>
                         {(entry.coinsEarned || 0) > 0 && (
                           <span className="text-[9px] font-bold text-orange-500 flex items-center gap-0.5">
                             <Coins size={8} /> {entry.coinsEarned}
                           </span>
                         )}
                      </div>
                    )}
                  </div>
                  <div className="w-16 flex justify-end">
                    <div className={`p-1 rounded-lg ${i % 2 === 0 ? 'bg-emerald-50 text-emerald-500' : 'bg-blue-50 text-blue-500'}`}>
                      <Star size={12} fill="currentColor" />
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
