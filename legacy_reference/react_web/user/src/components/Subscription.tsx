import React, { useState, useEffect } from 'react';
import { UserProfile } from '../types';
import { CheckCircle2, Trophy, Star, Coins, Loader2, ShieldCheck, Zap } from 'lucide-react';
import { doc, getDoc, writeBatch, serverTimestamp, collection } from 'firebase/firestore';
import { db } from '../firebase';
import { useToast } from './Toast';

interface SubscriptionProps {
  profile: UserProfile | null;
}

export default function Subscription({ profile }: SubscriptionProps) {
  const [config, setConfig] = useState({ priceInCoins: 5000, durationDays: 30, isActive: true });
  const [loading, setLoading] = useState(true);
  const [isProcessing, setIsProcessing] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'subscription_settings'));
        if (snap.exists()) {
          setConfig(prev => ({ ...prev, ...snap.data() as any }));
        }
      } catch (e) {
        console.error("Error fetching subscription config:", e);
      } finally {
        setLoading(false);
      }
    };
    fetchConfig();
  }, []);

  const isPro = profile?.subscriptionStatus === 'premium' && 
                (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date());
                
  const calculateDaysLeft = () => {
    if (!profile?.subscriptionEndDate) return 'Lifetime';
    const diff = new Date(profile.subscriptionEndDate).getTime() - new Date().getTime();
    const days = Math.ceil(diff / (1000 * 3600 * 24));
    return days > 0 ? `${days} Days Left` : 'Expired';
  };

  const handleUpgrade = async () => {
    if (!profile) return;
    if (profile.coins < config.priceInCoins) {
      showToast(`Insufficient coins! You need ${config.priceInCoins} coins to upgrade.`, 'error');
      return;
    }

    setIsProcessing(true);
    try {
      const batch = writeBatch(db);
      
      // 1. Update Profile
      const userRef = doc(db, 'users', profile.userId);
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + config.durationDays);
      
      batch.update(userRef, {
        coins: profile.coins - config.priceInCoins,
        subscriptionStatus: 'premium',
        subscriptionEndDate: endDate.toISOString(),
        totalSpent: (profile.totalSpent || 0) + config.priceInCoins
      });

      // 2. Add Transaction
      const txRef = doc(collection(db, 'transactions'));
      batch.set(txRef, {
        userId: profile.userId,
        amount: -config.priceInCoins,
        type: 'spend',
        category: 'subscription',
        testTitle: `Rankearn PRO - ${config.durationDays} Days`,
        status: 'completed',
        timestamp: serverTimestamp(),
        currentBalance: profile.coins - config.priceInCoins,
        description: `Purchased Rankearn PRO Pass for ${config.durationDays} days`
      });

      await batch.commit();
      showToast('Welcome to Rankearn PRO! 🎉', 'success');
    } catch (error) {
      console.error("Upgrade error:", error);
      showToast('Transaction failed. Please try again.', 'error');
    } finally {
      setIsProcessing(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[60vh]">
        <Loader2 size={40} className="animate-spin text-amber-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-8 px-1 md:px-0">
      <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 overflow-visible flex flex-col min-h-[600px]">
        {/* Master Header */}
        <div className="p-4 lg:p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row items-start lg:items-center lg:justify-between gap-4 lg:gap-6 rounded-t-xl text-left">
          <div className="flex items-center gap-3 lg:gap-4">
            <div className="p-2.5 lg:p-3 bg-amber-500 text-white rounded-lg shadow-md shadow-amber-900/20">
              <Zap size={20} className="lg:w-6 lg:h-6" strokeWidth={3} />
            </div>
            <div>
              <h3 className="text-lg lg:text-xl font-black text-slate-900 leading-none">Rankearn PRO</h3>
              <p className="text-[9px] lg:text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1 lg:mt-1.5 flex items-center justify-start gap-2">
                Unlock Exclusive PRO Benefits & Perks
              </p>
            </div>
          </div>
        </div>

        <div className="p-6 lg:p-8 flex-1 flex flex-col items-center justify-center">
          {!config.isActive && !isPro ? (
            <div className="flex flex-col items-center justify-center text-center space-y-4">
              <div className="w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center text-slate-400">
                <ShieldCheck size={32} />
              </div>
              <h2 className="text-2xl font-bold text-slate-900">PRO Pass is Currently Unavailable</h2>
              <p className="text-slate-500">Please check back later for new subscription plans.</p>
            </div>
          ) : (
            <div className="w-full max-w-2xl mx-auto">
              <div className="grid md:grid-cols-2 gap-8 items-center">
                {/* Left side: Benefits */}
                <div className="space-y-6">
                  <div className="space-y-2">
                    <h2 className="text-3xl font-black text-slate-900">Experience <span className="text-amber-500">Premium</span></h2>
                    <p className="text-slate-500 font-medium">Join the elite circle of Rankearn users and enjoy exclusive advantages.</p>
                  </div>
                  
                  <div className="space-y-4">
                    {[
                      'Unlimited Premium Mock Tests',
                      'Huge Discounts on Tournaments',
                      'Exclusive PRO-only Contests',
                      'VIP Badge on Profile & Leaderboard',
                      'Ad-Free Experience'
                    ].map((feature, j) => (
                      <div key={j} className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-emerald-50 text-emerald-500 flex items-center justify-center shrink-0">
                          <CheckCircle2 size={18} strokeWidth={2.5} />
                        </div>
                        <span className="text-slate-700 font-bold text-sm">{feature}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Right side: Purchase Card */}
                <div className="relative">
                  <div className="absolute inset-0 bg-amber-500/10 blur-3xl rounded-full"></div>
                  <div className="relative bg-white rounded-2xl border-2 border-amber-500 p-6 md:p-8 shadow-xl text-center">
                    {isPro && (
                      <div className="inline-flex items-center gap-1.5 bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest mb-4">
                        <CheckCircle2 size={12} /> Active PRO
                      </div>
                    )}
                    
                    <h3 className="text-xl font-black text-slate-900 mb-1">{config.durationDays}-Day Pass</h3>
                    <div className="flex items-center justify-center gap-2 mb-6">
                      <Coins size={28} className="text-amber-500" fill="currentColor" />
                      <span className="text-4xl font-black text-slate-900">{config.priceInCoins}</span>
                      <span className="text-slate-400 font-bold text-xs self-end mb-1 uppercase">Coins</span>
                    </div>

                    {isPro ? (
                      <div className="space-y-2 py-4 bg-slate-50 rounded-xl border border-slate-100">
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Valid For</p>
                        <p className="text-xl font-black text-emerald-600">{calculateDaysLeft()}</p>
                      </div>
                    ) : (
                      <button 
                        onClick={handleUpgrade}
                        disabled={isProcessing}
                        className="w-full py-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-black shadow-lg shadow-amber-200 transition-all flex items-center justify-center gap-2 active:scale-95 disabled:opacity-70"
                      >
                        {isProcessing ? <Loader2 size={20} className="animate-spin" /> : (
                          <>
                            <Star size={18} fill="currentColor" />
                            UPGRADE NOW
                          </>
                        )}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
