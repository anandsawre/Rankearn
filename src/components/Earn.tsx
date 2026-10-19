import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { db, auth } from '../firebase';
import { collection, query, where, getDocs, orderBy } from 'firebase/firestore';
import { Test, UserProfile } from '../types';
import { Trophy, Coins, Clock, Target, Play, Medal, Users, CheckCircle2, Star, History, Calendar, Radio, RefreshCw, ChevronDown } from 'lucide-react';
import ContestJoinModal from './TournamentJoinModal';
import Leaderboard from './Leaderboard';
import ContestCard from './TournamentCard';
import LuckyWheel from './LuckyWheel';

import { useParams } from 'react-router-dom';

const normalizeDate = (d: any): Date | null => {
  if (!d) return null;
  if (typeof d.toDate === 'function') return d.toDate();
  if (d && typeof d === 'object' && 'seconds' in d) return new Date(d.seconds * 1000);
  const parsed = new Date(d);
  return isNaN(parsed.getTime()) ? null : parsed;
};

interface EarnProps {
  onStartTest: (id: string) => void;
  onNavigate: (page: string) => void;
  profile: UserProfile | null;
}

type EarnTab = 'live' | 'upcoming' | 'past' | 'leaderboard' | 'wheel';

export default function Earn({ onStartTest, onNavigate, profile }: EarnProps) {
  const { tab } = useParams<{ tab: string }>();
  const [contests, setContests] = useState<Test[]>([]);
  const [userAttemptedIds, setUserAttemptedIds] = useState<Set<string>>(new Set());
  const [isLoading, setIsLoading] = useState(true);
  const [joiningContest, setJoiningContest] = useState<Test | null>(null);
  const [activeTab, setActiveTab] = useState<EarnTab>((tab as EarnTab) || 'live');
  const [isNavOpen, setIsNavOpen] = useState(false);

  // Also update tab if URL parameter changes
  useEffect(() => {
    if (tab && ['live', 'upcoming', 'past', 'leaderboard', 'wheel'].includes(tab)) {
      setActiveTab(tab as EarnTab);
    }
  }, [tab]);

  useEffect(() => {
    const fetchContests = async () => {
      try {
        // 1. Fetch contests
        const q = query(
          collection(db, 'tests'),
          where('isTournament', '==', true),
          where('status', '==', 'published')
        );
        const snap = await getDocs(q);
        const fetched = snap.docs.map(doc => ({ testId: doc.id, ...doc.data() } as Test));
        
        // 2. Fetch user attempts if logged in
        const currentUserId = profile?.userId || auth.currentUser?.uid;
        if (currentUserId) {
          const attemptsQ = query(
            collection(db, 'attempts'),
            where('userId', '==', currentUserId),
            where('isTournament', '==', true)
          );
          const attemptsSnap = await getDocs(attemptsQ);
          const attemptedIds = new Set(attemptsSnap.docs.map(doc => doc.data().testId));
          setUserAttemptedIds(attemptedIds);
        }

        // Sort manually
        fetched.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        setContests(fetched);
      } catch (error) {
        console.error("Error fetching contests:", error);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchContests();
  }, [profile]);

  const now = new Date();
  
  const upcomingContests = contests.filter(t => {
    const startTime = normalizeDate(t.scheduledStartTime) || now;
    return startTime > now;
  });

  const liveContests = contests.filter(t => {
    const startTime = normalizeDate(t.scheduledStartTime) || now;
    const endTime = normalizeDate(t.scheduledEndTime);
    const isPast = t.isResultDeclared || 
                   userAttemptedIds.has(t.testId) || 
                   (endTime && now > endTime);
    
    return startTime <= now && !isPast;
  });

  const pastContests = contests.filter(t => {
    const endTime = normalizeDate(t.scheduledEndTime);
    const isPast = t.isResultDeclared || 
                   userAttemptedIds.has(t.testId) || 
                   (endTime && now > endTime);
    return isPast;
  });

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-8">
      <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 overflow-visible flex flex-col min-h-[650px]">
        {/* Master Header */}
        <div className="p-4 lg:p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row items-start lg:items-center lg:justify-between gap-4 lg:gap-6 rounded-t-xl text-left">
          <div className="flex items-center gap-3 lg:gap-4">
            <div className="p-2.5 lg:p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
              <Trophy size={20} className="lg:w-6 lg:h-6" strokeWidth={3} />
            </div>
            <div>
              <h3 className="text-lg lg:text-xl font-black text-slate-900 leading-none">Champion Arena</h3>
              <p className="text-[9px] lg:text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1 lg:mt-1.5 flex items-center justify-start gap-2">
                Play Now & Win Big Rewards
              </p>
            </div>
          </div>

          {/* Mobile Dropdown (Visible only on mobile/tablet) */}
          <div className="relative mx-auto lg:hidden">
            <button 
              onClick={() => setIsNavOpen(!isNavOpen)}
              className="flex items-center gap-3 px-6 py-3.5 bg-white border border-slate-200 rounded-lg shadow-sm text-xs font-black uppercase tracking-widest text-slate-700 hover:border-emerald-500/50 transition-all active:scale-95 group min-w-[200px] justify-between"
            >
              <div className="flex items-center gap-3">
                {(() => {
                  const activeItem = [
                    { id: 'live', label: 'Live Now', icon: Radio },
                    { id: 'upcoming', label: 'Upcoming', icon: Calendar },
                    { id: 'past', label: 'History', icon: History },
                    { id: 'leaderboard', label: 'Rankings', icon: Trophy }
                  ].find(i => i.id === activeTab);
                  const Icon = activeItem?.icon || Radio;
                  return (
                    <>
                      <Icon size={18} className="text-emerald-500" />
                      <span>{activeItem?.label || 'Select Category'}</span>
                    </>
                  );
                })()}
              </div>
              <ChevronDown 
                size={18} 
                className={`text-slate-400 transition-transform duration-300 ${isNavOpen ? 'rotate-180' : ''}`} 
              />
            </button>

            <AnimatePresence>
              {isNavOpen && (
                <>
                  <div 
                    className="fixed inset-0 z-[60]" 
                    onClick={() => setIsNavOpen(false)} 
                  />
                  <motion.div
                    initial={{ opacity: 0, y: 15, scale: 0.95 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: 15, scale: 0.95 }}
                    className="absolute left-0 mt-1.5 w-full bg-white rounded-lg border border-slate-100 shadow-2xl shadow-slate-900/10 z-[70] overflow-hidden p-2"
                  >
                    {[
                      { id: 'live', label: 'Live Now', icon: Radio, desc: 'Play active contests' },
                      { id: 'upcoming', label: 'Upcoming', icon: Calendar, desc: 'Scheduled tournaments' },
                      { id: 'past', label: 'History', icon: History, desc: 'Past performance' },
                      { id: 'leaderboard', label: 'Rankings', icon: Trophy, desc: 'Global leaderboard' }
                    ].map((tabItem) => (
                      <button 
                        key={tabItem.id}
                        onClick={() => {
                          setActiveTab(tabItem.id as EarnTab);
                          setIsNavOpen(false);
                        }}
                        className={`w-full flex items-center gap-3.5 px-3 py-2.5 rounded-lg transition-all active:scale-[0.98] ${
                          activeTab === tabItem.id 
                            ? 'bg-emerald-500 text-white' 
                            : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'
                        }`}
                      >
                        <div className={`p-2 rounded-lg ${activeTab === tabItem.id ? 'bg-white/20' : 'bg-slate-50'}`}>
                          <tabItem.icon size={16} />
                        </div>
                        <div className="text-left">
                          <p className="text-[11px] font-black uppercase tracking-wider leading-none">{tabItem.label}</p>
                          <p className={`text-[9px] font-bold mt-1 opacity-70 ${activeTab === tabItem.id ? 'text-white' : 'text-slate-400'}`}>
                            {tabItem.desc}
                          </p>
                        </div>
                      </button>
                    ))}
                  </motion.div>
                </>
              )}
            </AnimatePresence>
          </div>

          {/* Desktop Tabs (Visible only on desktop) */}
          <div className="hidden lg:flex items-center gap-1.5 bg-white/80 p-1 rounded-xl border border-slate-100 shadow-sm overflow-x-auto no-scrollbar">
            {[
              { id: 'live', label: 'Live Now', icon: Radio },
              { id: 'upcoming', label: 'Upcoming', icon: Calendar },
              { id: 'past', label: 'History', icon: History },
              { id: 'leaderboard', label: 'Rankings', icon: Trophy }
            ].map((tabItem) => (
              <button 
                key={tabItem.id}
                onClick={() => {
                  setActiveTab(tabItem.id as EarnTab);
                }}
                className={`flex items-center gap-2.5 px-6 py-3 rounded-xl text-xs font-black uppercase tracking-wider transition-all active:scale-90 whitespace-nowrap ${
                  activeTab === tabItem.id 
                    ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-900/20' 
                    : 'text-slate-400 hover:text-slate-900 hover:bg-white'
                }`}
              >
                <tabItem.icon 
                  size={16} 
                  strokeWidth={activeTab === tabItem.id ? 3 : 2.5} 
                  className={tabItem.id === 'wheel' ? 'animate-spin-slow' : (tabItem.id === 'live' && activeTab === 'live' ? 'animate-pulse' : '')} 
                />
                {tabItem.label}
              </button>
            ))}
          </div>
        </div>

        <div className="p-6 lg:p-8 flex-1 flex flex-col">
          {isLoading ? (
            <div className="flex-1 flex flex-col items-center justify-center py-20">
              <div className="w-12 h-12 border-4 border-emerald-500/10 border-t-emerald-500 rounded-full animate-spin mb-4"></div>
              <p className="text-slate-400 font-black text-[10px] uppercase tracking-widest">Synchronizing Arena...</p>
            </div>
          ) : (
        <AnimatePresence mode="wait">
          {activeTab === 'live' && (
            <motion.div
              key="live"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="space-y-6"
            >

              
              {liveContests.length > 0 ? (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                  {liveContests.map(test => (
                    <ContestCard 
                      key={test.testId} 
                      test={test} 
                      profile={profile} 
                      onJoin={(t) => setJoiningContest(t)}
                      onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
                    />
                  ))}
                </div>
              ) : (
                <div className="bg-slate-50 rounded-2xl border border-dashed border-slate-200 p-12 text-center flex flex-col items-center justify-center min-h-[300px]">
                  <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-slate-200 mb-4 shadow-sm border border-slate-100">
                    <Trophy size={32} strokeWidth={1.5} />
                  </div>
                  <h4 className="text-sm font-black text-slate-900 uppercase tracking-tight">Arena is Silent</h4>
                  <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-2 max-w-[240px]">No live championships are running at this moment.</p>
                </div>
              )}
            </motion.div>
          )}

          {activeTab === 'upcoming' && (
            <motion.div
              key="upcoming"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="space-y-6"
            >

              
              {upcomingContests.length > 0 ? (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                  {upcomingContests.map(test => (
                    <ContestCard 
                      key={test.testId} 
                      test={test} 
                      profile={profile} 
                      onJoin={(t) => setJoiningContest(t)}
                      onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
                    />
                  ))}
                </div>
              ) : (
                <div className="bg-slate-50 rounded-2xl border border-dashed border-slate-200 p-12 text-center flex flex-col items-center justify-center min-h-[300px]">
                  <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-slate-200 mb-4 shadow-sm border border-slate-100">
                    <Calendar size={32} strokeWidth={1.5} />
                  </div>
                  <h4 className="text-sm font-black text-slate-900 uppercase tracking-tight">Calendar is Open</h4>
                  <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-2 max-w-[240px]">Stay tuned! New contests are scheduled regularly.</p>
                </div>
              )}
            </motion.div>
          )}

          {activeTab === 'past' && (
            <motion.div
              key="past"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="space-y-6"
            >

              {pastContests.length > 0 ? (
                <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                  {pastContests.map(test => (
                    <ContestCard 
                      key={test.testId} 
                      test={test} 
                      profile={profile} 
                      onJoin={(t) => setJoiningContest(t)}
                      onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
                    />
                  ))}
                </div>
              ) : (
                <div className="bg-slate-50 rounded-2xl border border-dashed border-slate-200 p-12 text-center flex flex-col items-center justify-center min-h-[300px]">
                  <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-slate-200 mb-4 shadow-sm border border-slate-100">
                    <History size={32} strokeWidth={1.5} />
                  </div>
                  <h4 className="text-sm font-black text-slate-900 uppercase tracking-tight">Archive Empty</h4>
                  <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-2 max-w-[240px]">History of completed contests will appear here.</p>
                </div>
              )}
            </motion.div>
          )}

          {activeTab === 'leaderboard' && (
            <motion.div
              key="leaderboard"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="w-full"
            >
              <Leaderboard />
            </motion.div>
          )}


        </AnimatePresence>
      )}
      </div>
      </div>

      {/* Join Modal */}
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
      </AnimatePresence>
    </div>
  );
}
