import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'motion/react';
import { CheckCircle2, Coins, Loader2, Play, AlertTriangle, X, FileText, Trophy, User, ArrowRight, Star } from 'lucide-react';
import { db, auth } from '../firebase';
import { doc, getDoc, runTransaction, query, where, collection, limit, getDocs, serverTimestamp } from 'firebase/firestore';
import { Test, UserProfile } from '../types';
import { useToast } from './Toast';

const normalizeDate = (d: any): Date | null => {
  if (!d) return null;
  if (typeof d.toDate === 'function') return d.toDate();
  if (d && typeof d === 'object' && 'seconds' in d) return new Date(d.seconds * 1000);
  const parsed = new Date(d);
  return isNaN(parsed.getTime()) ? null : parsed;
};

interface ContestJoinModalProps {
  test: Test;
  profile: UserProfile | null;
  onClose: () => void;
  onJoinSuccess: () => void;
  onViewResult?: (attemptId: string) => void;
}

export default function ContestJoinModal({ test, profile, onClose, onJoinSuccess, onViewResult }: ContestJoinModalProps) {
  const [isChecking, setIsChecking] = useState(true);
  const [hasJoined, setHasJoined] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [attemptId, setAttemptId] = useState<string | null>(null);
  const [isJoining, setIsJoining] = useState(false);
  const [subConfig, setSubConfig] = useState({ contestDiscount: 50 });
  const { showToast } = useToast();

  useEffect(() => {
    const fetchSubConfig = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'subscription_settings'));
        if (snap.exists()) {
          setSubConfig(prev => ({ ...prev, ...snap.data() as any }));
        }
      } catch (e) {
        console.error("Error fetching sub config:", e);
      }
    };
    fetchSubConfig();
  }, []);

  const subEndDate = normalizeDate(profile?.subscriptionEndDate);
  const isPro = profile?.subscriptionStatus === 'premium' && 
                (!profile?.subscriptionEndDate || (subEndDate && subEndDate > new Date()));
                
  const entryFee = test.entryFee || 0;
  const discountedFee = isPro ? Math.floor(entryFee * (1 - (subConfig.contestDiscount / 100))) : entryFee;

  useEffect(() => {
    const checkParticipation = async () => {
      const currentUserId = profile?.userId || auth.currentUser?.uid;
      if (!currentUserId) return;
      try {
        // First check if they have submitted
        const attemptQuery = query(
          collection(db, 'attempts'),
          where('userId', '==', currentUserId),
          where('testId', '==', test.testId),
          limit(1)
        );
        const attemptSnap = await getDocs(attemptQuery);
        if (!attemptSnap.empty) {
          setIsSubmitted(true);
          setHasJoined(true);
          setAttemptId(attemptSnap.docs[0].id);
          setIsChecking(false);
          return;
        }

        // Then check if they have joined (paid)
        const participantRef = doc(db, 'tests', test.testId, 'participants', currentUserId);
        const snap = await getDoc(participantRef);
        if (snap.exists()) {
          setHasJoined(true);
          const start = normalizeDate(test.scheduledStartTime);
          const isUpcoming = start && new Date() < start;
          if (!isUpcoming) {
            onJoinSuccess(); // Auto proceed if already joined AND test has started
          }
        }
      } catch (error) {
        console.error("Error checking participation", error);
      } finally {
        setIsChecking(false);
      }
    };
    checkParticipation();
  }, [test.testId, profile, test.scheduledStartTime, onJoinSuccess]);

  const handleJoin = async () => {
    if (test.isProOnly && !isPro) {
      showToast('This contest is exclusive for Rankearn PRO users', 'error');
      return;
    }

    const currentUserId = profile?.userId || auth.currentUser?.uid;
    if (!currentUserId) {
      showToast('Please login to join contest', 'error');
      return;
    }

    const start = normalizeDate(test.scheduledStartTime);
    const end = normalizeDate(test.scheduledEndTime);
    const now = new Date();
    const isEnded = end ? now > end : false;

    if (isEnded) {
      showToast('This contest has already ended!', 'error');
      return;
    }
    
    const finalFee = discountedFee;
    
    if ((profile?.coins || 0) < finalFee) {
      showToast('Not enough coins to join this contest', 'error');
      return;
    }

    setIsJoining(true);
    try {
      const userRef = doc(db, 'users', currentUserId);
      const testRef = doc(db, 'tests', test.testId);
      const participantRef = doc(db, 'tests', test.testId, 'participants', currentUserId);

      await runTransaction(db, async (transaction) => {
        // 1. All READS must come first
        const userDoc = await transaction.get(userRef);
        const testDoc = await transaction.get(testRef);

        if (!userDoc.exists()) throw new Error("User not found!");
        
        if (testDoc.exists()) {
          const testData = testDoc.data();
          if (testData?.isTournament && testData?.scheduledEndTime) {
            const testEnd = normalizeDate(testData.scheduledEndTime);
            if (testEnd && new Date() > testEnd) {
              throw new Error("This contest has already ended!");
            }
          }
        }

        const currentCoins = userDoc.data()?.coins || 0;
        if (currentCoins < entryFee) throw new Error("Insufficient coins");

        const latestTotalParticipants = testDoc.exists() ? (testDoc.data()?.totalParticipants || 0) : 0;

        // 2. All WRITES follow
        if (finalFee > 0) {
          const userData = userDoc.data();
          const currentTotalSpent = userData?.totalSpent || 0;
          transaction.update(userRef, { 
            coins: currentCoins - finalFee,
            totalSpent: currentTotalSpent + finalFee
          });
          
          // Log the transaction in the transactions collection
          const transactionRef = doc(collection(db, 'transactions'));
          transaction.set(transactionRef, {
            userId: currentUserId,
            amount: finalFee,
            type: 'spend',
            category: 'tournament_entry',
            referenceId: test.testId,
            testTitle: test.title,
            timestamp: serverTimestamp(),
            currentBalance: currentCoins - finalFee
          });
        }
        
        // Add participant metadata
        transaction.set(participantRef, {
          userId: currentUserId,
          joinedAt: new Date().toISOString(),
          entryFeePaid: finalFee
        });

        // Increment total participants count on test document using latest server data
        transaction.update(testRef, {
          totalParticipants: latestTotalParticipants + 1
        });
      });

      setHasJoined(true);
      const isUpcoming = start && new Date() < start;
      
      if (!isUpcoming) {
        showToast(`Successfully joined! Deducted ${finalFee} coins.`, 'success');
        onJoinSuccess();
      } else {
        showToast(`Registered successfully! Test will start at scheduled time.`, 'success');
      }
    } catch (error: any) {
      console.error("Error joining contest", error);
      showToast(error.message || 'Failed to join contest. Please try again.', 'error');
    } finally {
      setIsJoining(false);
    }
  };

  if (isChecking) {
    return createPortal(
      <div className="fixed inset-0 z-[110] bg-slate-900/50 backdrop-blur-sm flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-white animate-spin" />
      </div>
    , document.body);
  }

  // If already submitted
  if (isSubmitted) {
    return createPortal(
      <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          className="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden relative flex flex-col max-h-[90vh]"
        >
          <div className="bg-gradient-to-r from-blue-600 to-indigo-600 p-6 relative overflow-hidden text-center shrink-0">
            <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
            <div className="w-16 h-16 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center border border-white/30 text-white shadow-inner mx-auto mb-4">
              <CheckCircle2 size={32} strokeWidth={3} />
            </div>
            <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Already Joined</h2>
            <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">Submission Confirmed</p>
          </div>

          <div className="p-8 text-center space-y-6 overflow-y-auto flex-1 no-scrollbar">
            <p className="text-sm font-bold text-slate-500 leading-relaxed">
              You have already submitted your attempt for <span className="text-indigo-600 font-black">{test.title}</span>.
            </p>
            
            <div className="flex flex-col gap-3">
              {attemptId && onViewResult && (
                <button
                  onClick={() => onViewResult(attemptId)}
                  className="w-full py-4 bg-gradient-to-r from-indigo-600 to-violet-600 text-white rounded-xl font-black text-[11px] uppercase tracking-widest shadow-lg shadow-indigo-100 flex items-center justify-center gap-2 hover:from-indigo-700 hover:to-violet-700 transition-all active:scale-95"
                >
                  <FileText size={18} strokeWidth={3} />
                  View Your Result
                </button>
              )}
              <button
                onClick={onClose}
                className="w-full py-4 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    , document.body);
  }

  const startTimeNormalized = normalizeDate(test.scheduledStartTime);
  const isUpcoming = startTimeNormalized && new Date() < startTimeNormalized;
  const startTimeObj = startTimeNormalized || new Date();

  const endTimeNormalized = normalizeDate(test.scheduledEndTime);
  const isEnded = endTimeNormalized ? new Date() > endTimeNormalized : false;

  // If already joined but not submitted
  if (hasJoined) {
    if (!isUpcoming) return null; // will be handled by onJoinSuccess
    
    return createPortal(
      <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          className="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden relative flex flex-col max-h-[90vh]"
        >
          <div className="bg-gradient-to-r from-emerald-600 to-teal-600 p-6 relative overflow-hidden text-center shrink-0">
            <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
            <div className="w-16 h-16 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center border border-white/30 text-white shadow-inner mx-auto mb-4">
              <CheckCircle2 size={32} strokeWidth={3} />
            </div>
            <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Registration Confirmed</h2>
            <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">You're on the list!</p>
          </div>

          <div className="p-8 text-center space-y-6 overflow-y-auto flex-1 no-scrollbar">
            <p className="text-sm font-bold text-slate-500 leading-relaxed px-4">
              You have successfully joined <span className="text-emerald-600 font-black">{test.title}</span>.
            </p>

            {test.syllabus && (
              <div className="bg-amber-50/50 border border-amber-200/50 rounded-xl p-4 text-left shadow-sm">
                 <p className="text-[10px] font-black text-amber-600 uppercase tracking-widest mb-2 flex items-center gap-1.5">
                    <FileText size={12} />
                    Contest Syllabus
                 </p>
                 <p className="text-xs font-medium text-slate-700 leading-relaxed whitespace-pre-wrap">
                    {test.syllabus}
                 </p>
              </div>
            )}
            
            <div className="bg-slate-50 border border-slate-100 rounded-xl p-5 shadow-sm">
              <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Contest Starts At</p>
              <p className="text-base font-black text-indigo-600 uppercase">
                {startTimeObj.toLocaleString('en-IN', { 
                  day: '2-digit', month: 'short', year: 'numeric', 
                  hour: '2-digit', minute: '2-digit', hour12: true 
                })}
              </p>
            </div>

            <button
              onClick={onClose}
              className="w-full py-4 bg-slate-900 text-white font-black rounded-xl text-[11px] uppercase tracking-widest shadow-lg hover:bg-slate-800 transition-all active:scale-95"
            >
              Got it, I'll be back
            </button>
          </div>
        </motion.div>
      </div>
    , document.body);
  }

  const canAfford = (profile?.coins || 0) >= discountedFee;
  const isProOnly = test.isProOnly && !isPro;

  return createPortal(
    <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        className="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden relative flex flex-col max-h-[90vh]"
      >
        <div className="bg-gradient-to-r from-amber-500 to-orange-500 p-6 relative overflow-hidden shrink-0">
           {/* Decorative background circle */}
           <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
           
           <div className="flex items-center gap-4 relative z-10">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-lg flex items-center justify-center border border-white/30 text-white shadow-inner">
                 <Trophy size={28} strokeWidth={3} />
              </div>
              <div>
                 <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">{isUpcoming ? 'Pre-Register' : 'Entry Ticket'}</h2>
                 <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">{isUpcoming ? 'Reserve Your Slot' : 'Paid Contest Entry'}</p>
              </div>
           </div>

           <button 
            onClick={onClose} 
            className="absolute top-6 right-6 p-2 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20 backdrop-blur-md z-20"
           >
              <X size={18} />
           </button>
        </div>
        
        <div className="p-6 text-center space-y-6 overflow-y-auto flex-1 no-scrollbar">
          {/* User Info Card */}
          <div className="bg-slate-50 border border-slate-100 rounded-xl p-4 flex items-center gap-4 text-left shadow-sm">
             <div className="w-12 h-12 bg-amber-500 rounded-lg flex items-center justify-center text-white font-black text-lg shadow-md shadow-amber-100 uppercase">
                {profile?.name?.charAt(0) || <User size={20} />}
             </div>
             <div className="flex-1 min-w-0">
                <h4 className="text-sm font-black text-slate-900 truncate">{profile?.name || 'User'}</h4>
                <p className="text-[10px] text-slate-400 font-bold truncate">{profile?.email}</p>
             </div>
             <div className="text-right">
                <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">Balance</p>
                <p className="text-lg font-black text-amber-600 leading-none">{profile?.coins?.toLocaleString() || 0}</p>
             </div>
          </div>

          <div className="space-y-2">
             <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">Contest Title</p>
             <h3 className="text-sm font-black text-slate-900 px-4 leading-relaxed">{test.title}</h3>
          </div>

          {test.syllabus && (
            <div className="bg-amber-50/50 border border-amber-200/50 rounded-xl p-4 text-left shadow-sm">
               <p className="text-[10px] font-black text-amber-600 uppercase tracking-widest mb-2 flex items-center gap-1.5">
                  <FileText size={12} />
                  Contest Syllabus
               </p>
               <p className="text-xs font-medium text-slate-700 leading-relaxed whitespace-pre-wrap">
                  {test.syllabus}
               </p>
            </div>
          )}

          <div className="p-5 bg-amber-50 rounded-xl border-2 border-dashed border-amber-200/50 flex items-center justify-between relative overflow-hidden text-left">
             <div className="relative z-10">
                <p className="text-[10px] font-black text-amber-600 uppercase tracking-widest mb-1.5 flex items-center gap-2">
                   Entry Fee
                   {isPro && (
                     <span className="bg-amber-600 text-white text-[8px] px-1.5 py-0.5 rounded-full animate-pulse">
                        PRO {subConfig.contestDiscount}% OFF
                     </span>
                   )}
                </p>
                <div className="flex items-center gap-3">
                   <p className="text-3xl font-black text-amber-700 leading-none flex items-center gap-1">
                      <Coins size={24} className="text-amber-400" />
                      {discountedFee.toLocaleString()}
                   </p>
                   {isPro && entryFee !== discountedFee && (
                     <p className="text-sm font-bold text-amber-400 line-through mt-2">
                        {entryFee.toLocaleString()}
                     </p>
                   )}
                </div>
             </div>
             <div className="w-14 h-14 bg-amber-100/50 rounded-full flex items-center justify-center text-amber-400 relative z-10 shadow-inner">
                <Star size={28} />
             </div>
             <div className="absolute -right-2 -bottom-2 w-12 h-12 bg-white/20 rounded-full" />
          </div>

          {isUpcoming && (
            <div className="flex items-center justify-center gap-2 py-2 px-4 bg-amber-50 text-amber-700 font-black text-[9px] rounded-lg border border-amber-100 uppercase tracking-widest">
               <Star size={12} className="fill-amber-400 stroke-none" />
               Starts: {startTimeObj.toLocaleString('en-IN', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}
            </div>
          )}

          {isEnded && (
            <div className="flex items-start gap-3 p-4 bg-red-50 rounded-xl text-left border border-red-100">
              <AlertTriangle className="text-red-500 shrink-0 mt-0.5" size={18} />
              <p className="text-[10px] text-red-700 font-bold leading-relaxed uppercase">
                This contest has already ended! You cannot join or pay for this contest.
              </p>
            </div>
          )}

          {!isEnded && !canAfford && (
            <div className="flex items-start gap-3 p-4 bg-red-50 rounded-xl text-left border border-red-100">
              <AlertTriangle className="text-red-500 shrink-0 mt-0.5" size={18} />
              <p className="text-[10px] text-red-700 font-bold leading-relaxed uppercase">
                Insufficient coins. Please recharge your wallet to join this contest.
              </p>
            </div>
          )}

          {isProOnly && (
            <div className="flex items-start gap-3 p-4 bg-amber-50 rounded-xl text-left border border-amber-100">
              <Star className="text-amber-500 shrink-0 mt-0.5 fill-amber-500" size={18} />
              <p className="text-[10px] text-amber-700 font-bold leading-relaxed uppercase">
                This is a PRO-only contest. Please upgrade your account to participate.
              </p>
            </div>
          )}

          <div className="flex gap-4">
            <button
              onClick={onClose}
              className="flex-1 py-4 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleJoin}
              disabled={isJoining || !canAfford || isProOnly || isEnded}
              className={`flex-1 py-4 font-black rounded-xl text-[11px] uppercase tracking-widest shadow-lg flex items-center justify-center gap-2 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed
                ${(!canAfford || isJoining || isProOnly || isEnded) 
                  ? 'bg-slate-200 text-slate-400' 
                  : 'bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-amber-100 hover:from-amber-600 hover:to-orange-600'}`}
            >
              {isJoining ? (
                <Loader2 size={18} className="animate-spin" />
              ) : isEnded ? (
                'Contest Ended'
              ) : (
                <>
                  {isUpcoming ? 'Pre-Register' : 'Pay & Join'}
                </>
              )}
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  , document.body);
}
