import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Trophy, X, ArrowRight, Radio, Bell, Clock, Zap } from 'lucide-react';
import { db, auth } from '../firebase';
import { collection, query, where, getDocs, limit, doc, getDoc, orderBy } from 'firebase/firestore';
import { Test, UserProfile } from '../types';

const normalizeDate = (d: any): Date | null => {
  if (!d) return null;
  if (typeof d.toDate === 'function') return d.toDate();
  if (d && typeof d === 'object' && 'seconds' in d) return new Date(d.seconds * 1000);
  const parsed = new Date(d);
  return isNaN(parsed.getTime()) ? null : parsed;
};

interface LiveTestAlertProps {
  profile: UserProfile | null;
  onJoin: (test: Test) => void;
}

export default function LiveTestAlert({ profile, onJoin }: LiveTestAlertProps) {
  const [activeContest, setActiveContest] = useState<Test | null>(null);
  const [isVisible, setIsVisible] = useState(false);
  const [lastNotifiedId, setLastNotifiedId] = useState<string | null>(null);

  useEffect(() => {
    const checkForContests = async () => {
      const currentUserId = profile?.userId || auth.currentUser?.uid;
      if (!currentUserId) return;

      try {
        const now = new Date();
        const tournamentQuery = query(
          collection(db, 'tests'),
          where('isTournament', '==', true),
          orderBy('createdAt', 'desc'),
          limit(10)
        );

        const snap = await getDocs(tournamentQuery);
        let bestContest: Test | null = null;

        for (const d of snap.docs) {
          const t = { testId: d.id, ...d.data() } as Test;
          if (t.isResultDeclared || t.status === 'unpublished') continue;

          const start = normalizeDate(t.scheduledStartTime);
          const end = normalizeDate(t.scheduledEndTime);

          if (!start) continue;

          // Check if Live or Upcoming (within next 1 hour)
          const isLive = now >= start && (!end || now <= end);
          const isSoon = now < start && (start.getTime() - now.getTime()) < 3600000;

          if (isLive || isSoon) {
            // Check if user already joined
            const partRef = doc(db, 'tests', t.testId, 'participants', currentUserId);
            const partSnap = await getDoc(partRef);
            
            if (!partSnap.exists()) {
              bestContest = t;
              break; 
            }
          }
        }

        if (bestContest) {
          setActiveContest(bestContest);
          setIsVisible(true);

          // Browser Notification
          if (bestContest.testId !== lastNotifiedId && Notification.permission === 'granted') {
            const bestStart = normalizeDate(bestContest.scheduledStartTime);
            const isLive = bestStart ? new Date() >= bestStart : false;
            new Notification(isLive ? '🔴 LIVE NOW: Contest Alert!' : '🕒 UPCOMING: Join Soon!', {
              body: `${bestContest.title} is ${isLive ? 'live now' : 'starting soon'}. Prize pool: ${((bestContest.totalParticipants || 0) * (bestContest.entryFee || 0) * 0.8).toFixed(0)} Coins!`,
              icon: '/pwa-192x192.png'
            });
            setLastNotifiedId(bestContest.testId);
          }
        } else {
          setIsVisible(false);
        }
      } catch (err) {
        console.error("Error checking for live contests:", err);
      }
    };

    // Check every 2 minutes
    const interval = setInterval(checkForContests, 120000);
    checkForContests();

    return () => clearInterval(interval);
  }, [profile?.userId, lastNotifiedId]);

  if (!isVisible || !activeContest) return null;

  const activeStart = normalizeDate(activeContest.scheduledStartTime);
  const isLive = activeStart ? new Date() >= activeStart : false;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, y: 100, scale: 0.9 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        exit={{ opacity: 0, y: 100, scale: 0.9 }}
        className="fixed bottom-20 md:bottom-6 right-4 left-4 md:left-auto md:w-96 z-50"
      >
        <div className="bg-white rounded-2xl shadow-2xl border border-slate-100 overflow-hidden">
          {/* Header */}
          <div className={`p-3 flex items-center justify-between ${isLive ? 'bg-red-500' : 'bg-amber-500'}`}>
            <div className="flex items-center gap-2 text-white">
              <div className="bg-white/20 p-1.5 rounded-lg backdrop-blur-sm">
                {isLive ? <Radio size={16} className="animate-pulse" /> : <Clock size={16} />}
              </div>
              <span className="text-[10px] font-black uppercase tracking-widest">
                {isLive ? 'Live Contest Now' : 'Upcoming Contest'}
              </span>
            </div>
            <button 
              onClick={() => setIsVisible(false)}
              className="text-white/80 hover:text-white transition-colors"
            >
              <X size={16} />
            </button>
          </div>

          <div className="p-4 flex gap-4">
            <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${isLive ? 'bg-red-50 text-red-500' : 'bg-amber-50 text-amber-500'}`}>
              <Trophy size={28} />
            </div>
            <div className="flex-1 min-w-0">
              <h4 className="text-sm font-black text-slate-800 truncate uppercase">{activeContest.title}</h4>
              <p className="text-[10px] text-slate-500 font-bold mt-1 line-clamp-1">
                Entry: {activeContest.entryFee || 0} Coins • Win Big Rewards!
              </p>
              
              <div className="flex items-center gap-2 mt-3">
                <button
                  onClick={() => {
                    onJoin(activeContest);
                    setIsVisible(false);
                  }}
                  className={`flex-1 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider text-white shadow-md flex items-center justify-center gap-2 transition-all active:scale-95 ${isLive ? 'bg-red-500 hover:bg-red-600 shadow-red-100' : 'bg-amber-500 hover:bg-amber-600 shadow-amber-100'}`}
                >
                  <Zap size={12} fill="currentColor" />
                  Join Now
                  <ArrowRight size={12} />
                </button>
              </div>
            </div>
          </div>

          {/* Progress Bar (Visual Only) */}
          <div className="h-1 w-full bg-slate-50">
            <motion.div 
              initial={{ width: "0%" }}
              animate={{ width: "100%" }}
              transition={{ duration: 120, ease: "linear" }}
              className={`h-full ${isLive ? 'bg-red-500' : 'bg-amber-500'}`}
            />
          </div>
        </div>
      </motion.div>
    </AnimatePresence>
  );
}
