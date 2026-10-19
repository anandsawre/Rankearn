import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { motion } from 'motion/react';
import { CheckCircle2, Coins, Loader2, Play, AlertTriangle, X, LockKeyhole, Star, Info, User, FileText } from 'lucide-react';
import { db } from '../firebase';
import { doc, getDoc, runTransaction, collection, serverTimestamp } from 'firebase/firestore';
import { Test, UserProfile } from '../types';
import { useToast } from './Toast';

interface TestPurchaseModalProps {
  test: Test;
  profile: UserProfile | null;
  onClose: () => void;
  onPurchaseSuccess: () => void;
}

export default function TestPurchaseModal({ test, profile, onClose, onPurchaseSuccess }: TestPurchaseModalProps) {
  const [isChecking, setIsChecking] = useState(true);
  const [hasUnlocked, setHasUnlocked] = useState(false);
  const [isPurchasing, setIsPurchasing] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    const checkUnlockStatus = async () => {
      if (!profile) return;
      try {
        const unlockRef = doc(db, 'users', profile.userId, 'unlockedTests', test.testId);
        const snap = await getDoc(unlockRef);
        if (snap.exists()) {
          setHasUnlocked(true);
        }
      } catch (error) {
        console.error("Error checking unlock status", error);
      } finally {
        setIsChecking(false);
      }
    };
    checkUnlockStatus();
  }, [test.testId, profile]);

  const handlePurchase = async () => {
    if (!profile) {
      showToast('Please login to unlock this test', 'error');
      return;
    }
    
    const unlockPrice = test.unlockPrice || 0;
    
    if (profile.coins < unlockPrice) {
      showToast('Not enough coins to unlock this test', 'error');
      return;
    }

    setIsPurchasing(true);
    try {
      const userRef = doc(db, 'users', profile.userId);
      const unlockRef = doc(db, 'users', profile.userId, 'unlockedTests', test.testId);

      await runTransaction(db, async (transaction) => {
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists()) throw new Error("User not found!");
        
        const currentCoins = userDoc.data()?.coins || 0;
        if (currentCoins < unlockPrice) throw new Error("Insufficient coins");

        if (unlockPrice > 0) {
          const userData = userDoc.data();
          const currentTotalSpent = userData?.totalSpent || 0;
          
          transaction.update(userRef, { 
            coins: currentCoins - unlockPrice,
            totalSpent: currentTotalSpent + unlockPrice
          });
          
          const transactionRef = doc(collection(db, 'transactions'));
          transaction.set(transactionRef, {
            userId: profile.userId,
            amount: unlockPrice,
            type: 'spend',
            category: 'test_purchase',
            referenceId: test.testId,
            testTitle: test.title,
            timestamp: serverTimestamp(),
            currentBalance: currentCoins - unlockPrice
          });
        }
        
        transaction.set(unlockRef, {
          testId: test.testId,
          unlockedAt: new Date().toISOString(),
          pricePaid: unlockPrice
        });
      });

      setHasUnlocked(true);
      showToast(`Successfully unlocked! Deducted ${unlockPrice} coins.`, 'success');
      onPurchaseSuccess();
    } catch (error: any) {
      console.error("Error purchasing test", error);
      showToast(error.message || 'Failed to unlock test. Please try again.', 'error');
    } finally {
      setIsPurchasing(false);
    }
  };

  if (isChecking) {
    return createPortal(
      <div className="fixed inset-0 z-[110] bg-slate-900/50 backdrop-blur-sm flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-white animate-spin" />
      </div>
    , document.body);
  }

  // If already unlocked
  if (hasUnlocked) {
    return createPortal(
      <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          className="bg-white rounded-3xl shadow-2xl w-full max-w-sm overflow-hidden relative flex flex-col max-h-[90vh]"
        >
          <div className="bg-gradient-to-br from-emerald-600 to-teal-700 p-5 relative overflow-hidden text-center shrink-0">
            <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
            <div className="w-14 h-14 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/30 text-white shadow-inner mx-auto mb-3">
              <CheckCircle2 size={32} strokeWidth={3} />
            </div>
            <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Test Unlocked</h2>
            <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1.5">Lifetime Access Granted</p>
          </div>

          <div className="p-8 text-center space-y-6 overflow-y-auto flex-1 no-scrollbar">
            <p className="text-sm font-bold text-slate-500 leading-relaxed px-4">
              You have permanent access to <span className="text-emerald-600 font-black">{test.title}</span>.
            </p>
            
            <div className="flex flex-col gap-3">
              <button
                onClick={onPurchaseSuccess}
                className="w-full py-4 bg-emerald-600 text-white rounded-2xl font-black text-xs uppercase tracking-widest shadow-lg shadow-emerald-100 flex items-center justify-center gap-3 hover:bg-emerald-700 transition-all active:scale-95"
              >
                <Play size={18} fill="currentColor" strokeWidth={0} />
                Start Test Now
              </button>
              <button
                onClick={onClose}
                className="w-full py-4 bg-slate-100 text-slate-500 font-black rounded-2xl text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors"
              >
                Maybe Later
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    , document.body);
  }

  const unlockPrice = test.unlockPrice || 0;
  const canAfford = (profile?.coins || 0) >= unlockPrice;

  return createPortal(
    <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        className="bg-white rounded-xl shadow-2xl w-full max-w-sm overflow-hidden relative flex flex-col max-h-[90vh]"
      >
        <div className="bg-gradient-to-br from-amber-500 to-orange-600 p-5 relative overflow-hidden shrink-0">
           {/* Decorative background circle */}
           <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
           
           <div className="flex items-center gap-4 relative z-10">
              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/30 text-white shadow-inner">
                 <LockKeyhole size={24} strokeWidth={3} />
              </div>
              <div>
                 <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Unlock Test</h2>
                 <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1.5">Premium Content</p>
              </div>
           </div>

           <button 
            onClick={onClose} 
            className="absolute top-5 right-5 p-1.5 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20 backdrop-blur-md z-20"
           >
              <X size={16} />
           </button>
        </div>
        
        <div className="p-8 text-center space-y-6 overflow-y-auto flex-1 no-scrollbar">
          {/* User Info Card - Based on Withdrawal Popup */}
          <div className="bg-slate-50 border border-slate-100 rounded-lg p-4 flex items-center gap-4 text-left shadow-sm">
             <div className="w-12 h-12 bg-amber-500 rounded-full flex items-center justify-center text-white font-black text-lg shadow-md shadow-amber-100 uppercase overflow-hidden">
                {profile?.profilePhoto ? (
                  <img src={profile.profilePhoto} alt={profile.name} className="w-full h-full object-cover" />
                ) : (
                  profile?.name?.charAt(0) || <User size={20} />
                )}
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
             <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-none">Selected Test</p>
             <h3 className="text-sm font-black text-slate-900 px-2 leading-relaxed">{test.title}</h3>
          </div>

          {test.syllabus && (
            <div className="bg-amber-50/50 border border-amber-200/50 rounded-lg p-4 text-left shadow-sm">
               <p className="text-[10px] font-black text-amber-600 uppercase tracking-widest mb-2 flex items-center gap-1.5">
                  <FileText size={12} />
                  Test Syllabus
               </p>
               <p className="text-xs font-medium text-slate-700 leading-relaxed whitespace-pre-wrap">
                  {test.syllabus}
               </p>
            </div>
          )}

          {/* Price Box - Based on "You Receive" Box */}
          <div className="p-6 bg-amber-50 rounded-lg border-2 border-dashed border-amber-200/50 flex items-center justify-between relative overflow-hidden text-left">
             <div className="relative z-10">
                <p className="text-[10px] font-black text-amber-600 uppercase tracking-widest mb-2">Unlock Price</p>
                <p className="text-4xl font-black text-amber-700 leading-none flex items-center gap-2">
                   <Coins size={32} className="text-amber-500" />
                   {unlockPrice.toLocaleString()}
                </p>
             </div>
             <div className="w-16 h-16 bg-amber-100/50 rounded-full flex items-center justify-center text-amber-400 relative z-10 shadow-inner">
                <Star size={32} />
             </div>
             <div className="absolute -right-2 -bottom-2 w-12 h-12 bg-white/20 rounded-full" />
          </div>

          {!canAfford && (
            <div className="flex items-start gap-4 p-5 bg-rose-50 rounded-lg text-left border border-rose-100">
              <AlertTriangle className="text-rose-500 shrink-0 mt-0.5" size={20} />
              <p className="text-[11px] text-rose-700 font-bold leading-relaxed uppercase tracking-tight">
                Insufficient coins. Please earn or recharge coins to unlock this premium test.
              </p>
            </div>
          )}

          <div className="flex items-center justify-center gap-2 py-2 text-amber-600 bg-amber-50/50 rounded-lg border border-amber-100/50">
             <Info size={14} className="text-amber-500" />
             <p className="text-[10px] font-black uppercase tracking-widest leading-none">Non-refundable digital purchase</p>
          </div>

          <div className="flex gap-4">
            <button
              onClick={onClose}
              className="flex-1 py-4.5 bg-slate-100 text-slate-500 font-black rounded-lg text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handlePurchase}
              disabled={isPurchasing || !canAfford}
              className={`flex-1 py-4.5 font-black rounded-lg text-[11px] uppercase tracking-widest shadow-lg flex items-center justify-center gap-3 transition-all active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed
                ${(!canAfford || isPurchasing) 
                  ? 'bg-slate-200 text-slate-400' 
                  : 'bg-amber-500 text-white shadow-amber-100 hover:bg-amber-600'}`}
            >
              {isPurchasing ? (
                <Loader2 size={20} className="animate-spin" />
              ) : (
                <>
                   Unlock Now
                </>
              )}
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  , document.body);
}
