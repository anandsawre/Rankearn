import React, { useState, useEffect } from 'react';
import { db, auth } from '../firebase';
import { doc, getDoc, updateDoc, setDoc } from 'firebase/firestore';
import { UserProfile, ReferralSystemConfig } from '../types';
import { useToast } from './Toast';
import { generateUniqueReferralCode } from '../utils/referral';
import { getDomainFriendlyOrigin, shareContent } from '../utils/shareUtils';
import { 
  Users, 
  Copy, 
  Share2, 
  Gift, 
  Trophy, 
  ChevronRight, 
  Coins, 
  ArrowUpRight, 
  CheckCircle2, 
  Info,
  Loader2,
  AlertCircle,
  Zap
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export default function ReferralSection() {
  const { showToast } = useToast();
  const [user, setUser] = useState<UserProfile | null>(null);
  const [config, setConfig] = useState<ReferralSystemConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [copying, setCopying] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      if (!auth.currentUser) return;
      
      try {
        // Fetch User
        const userDoc = await getDoc(doc(db, 'users', auth.currentUser.uid));
        if (userDoc.exists()) {
          const userData = userDoc.data() as UserProfile;
          setUser(userData);

          // Generate referral code if missing
          if (!userData.referralCode) {
            const newCode = await generateUniqueReferralCode(db);
            await updateDoc(doc(db, 'users', auth.currentUser.uid), {
              referralCode: newCode,
              referralStats: {
                totalReferrals: 0,
                totalEarnings: 0,
                pendingEarnings: 0
              }
            });
            setUser(prev => prev ? { ...prev, referralCode: newCode } : null);
          }
        }

        // Fetch Config
        const configDoc = await getDoc(doc(db, 'configs', 'referral_system'));
        if (configDoc.exists()) {
          setConfig(configDoc.data() as ReferralSystemConfig);
        }
      } catch (error) {
        console.error("Error fetching referral data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleCopyCode = () => {
    if (!user?.referralCode) return;
    navigator.clipboard.writeText(user.referralCode);
    setCopying(true);
    showToast('Referral code copied!', 'success');
    setTimeout(() => setCopying(false), 2000);
  };

  const handleShare = async () => {
    if (!user?.referralCode) return;
    const referralUrl = `${getDomainFriendlyOrigin()}?ref=${user.referralCode}`;
    const shareText = `Hey! Join Rankearn and start Learning with Earning. Use my referral code ${user.referralCode} to get ${config?.refereeReward || 100} bonus coins! 🚀`;
    
    const result = await shareContent({
      title: 'Join Rankearn',
      text: shareText,
      url: referralUrl
    });

    if (result.success) {
      showToast(result.method === 'native' ? 'Invite sent!' : 'Link copied!', 'success');
    }
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] text-slate-400">
        <Loader2 className="animate-spin mb-4" size={40} />
        <p className="font-bold text-sm uppercase tracking-widest">Loading Referral Program...</p>
      </div>
    );
  }

  if (config && !config.isActive) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] p-6 text-center">
        <div className="w-20 h-20 bg-slate-100 rounded-full flex items-center justify-center mb-6">
          <AlertCircle size={40} className="text-slate-400" />
        </div>
        <h2 className="text-2xl font-black text-slate-900 mb-2">Referral Program is Paused</h2>
        <p className="text-slate-500 max-w-md">Our referral program is currently undergoing maintenance. Please check back later for exciting rewards!</p>
      </div>
    );
  }

  return (
    <div className="w-full space-y-6 pb-12">
      {/* Hero Section */}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="relative overflow-hidden bg-emerald-600 rounded-xl p-8 text-white shadow-xl shadow-emerald-100"
      >
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center">
              <Gift size={24} />
            </div>
            <span className="font-black text-sm uppercase tracking-[0.2em]">Refer & Earn</span>
          </div>
          <h1 className="text-3xl md:text-4xl font-black mb-2 leading-tight">Invite Friends & Earn <span className="text-yellow-400">Coins</span></h1>
          <p className="text-emerald-50/80 text-sm md:text-base font-medium max-w-xs md:max-w-none">Share your code with friends and get rewarded when they join the arena.</p>
        </div>

        {/* Decorative Elements */}
        <div className="absolute top-0 right-0 w-48 h-48 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/4 blur-3xl" />
        <div className="absolute bottom-0 right-10 w-32 h-32 bg-emerald-400/20 rounded-full blur-2xl" />
        <Users className="absolute -bottom-6 -right-6 w-48 h-48 text-white/5 rotate-12" />
      </motion.div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { 
            label: 'Total Referrals', 
            value: (user?.referralStats?.totalReferrals || 0).toLocaleString(), 
            icon: Users, 
            gradient: 'from-blue-500 to-indigo-600',
            shadow: 'shadow-blue-200/50'
          },
          { 
            label: 'Total Earnings', 
            value: (user?.referralStats?.totalEarnings || 0).toLocaleString(), 
            icon: Coins, 
            gradient: 'from-amber-500 to-orange-600',
            shadow: 'shadow-amber-200/50'
          },
          { 
            label: 'Pending Rewards', 
            value: (user?.referralStats?.pendingEarnings || 0).toLocaleString(), 
            icon: Zap, 
            gradient: 'from-emerald-500 to-teal-600',
            shadow: 'shadow-emerald-200/50'
          },
          { 
            label: 'Commission', 
            value: `${config?.commissionRate ?? 5}%`, 
            icon: Trophy, 
            gradient: 'from-violet-500 to-purple-600',
            shadow: 'shadow-violet-200/50'
          }
        ].map((stat, i) => (
          <motion.div 
            key={i}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.1 * i }}
            className={`relative overflow-hidden bg-gradient-to-br ${stat.gradient} p-4 rounded-xl border border-white/10 shadow-lg ${stat.shadow} flex items-center gap-3 group transition-all duration-300`}
          >
            {/* Glossy Overlay */}
            <div className="absolute inset-0 bg-gradient-to-tr from-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            
            {/* Icon Box */}
            <div className="w-10 h-10 shrink-0 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center shadow-inner text-white relative z-10 border border-white/10">
              <stat.icon size={20} strokeWidth={2.5} />
            </div>
            
            {/* Textstack */}
            <div className="flex-1 min-w-0 text-left relative z-10">
              <p className="text-[10px] md:text-[12px] font-bold text-white/80 mb-0.5 leading-none">
                {stat.label}
              </p>
              <p className="text-xl font-black text-white drop-shadow-sm leading-tight">
                {stat.value}
              </p>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Referral Code Card */}
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm text-center space-y-6"
      >
        <div>
          <p className="text-xs font-black text-slate-400 uppercase tracking-widest mb-4">Your Unique Referral Code</p>
          <div className="flex flex-col md:flex-row items-stretch justify-center gap-2">
            <div className="flex items-stretch justify-center gap-2">
              <div className="bg-slate-50 border-2 border-dashed border-slate-200 rounded-xl px-4 md:px-6 py-4 md:py-2.5 min-w-[140px] md:min-w-[160px] flex items-center justify-center">
                <span className="text-2xl md:text-2xl font-black bg-gradient-to-br from-slate-900 to-slate-600 bg-clip-text text-transparent tracking-[0.1em] md:tracking-[0.12em] font-sans">
                  {user?.referralCode}
                </span>
              </div>
              <button 
                onClick={handleCopyCode}
                className={`px-5 md:px-5 rounded-xl transition-all active:scale-90 flex items-center justify-center gap-2 ${copying ? 'bg-emerald-500 text-white shadow-emerald-100' : 'bg-slate-100 text-slate-400 hover:bg-slate-200'} shadow-md`}
              >
                {copying ? <CheckCircle2 size={20} className="md:w-4 md:h-4" /> : <Copy size={20} className="md:w-4 md:h-4" />}
                <span className="hidden md:inline font-black text-[10px] uppercase tracking-widest">
                  {copying ? 'Copied' : 'Copy'}
                </span>
              </button>
            </div>

            <button 
              onClick={handleShare}
              className="w-full md:w-max md:px-8 bg-slate-900 text-white py-4 md:py-0 rounded-xl font-black flex items-center justify-center gap-2.5 hover:bg-slate-800 transition-all shadow-lg active:scale-95"
            >
              <Share2 size={20} className="md:w-4 md:h-4" />
              <span className="text-sm md:text-xs">Invite Friends Now</span>
            </button>
          </div>
        </div>
      </motion.div>



      {/* How it Works */}
      <div className="bg-white rounded-xl border border-slate-100 overflow-hidden">
        <div className="p-5 border-b border-slate-50">
          <h3 className="text-lg font-black text-slate-900 leading-none">How it works?</h3>
        </div>
        <div className="divide-y divide-slate-50">
          {[
            { icon: Share2, title: 'Share Code', desc: 'Share your code with friends via WhatsApp or Social Media.', color: 'text-blue-500', bg: 'bg-blue-50' },
            { icon: Users, title: 'Friend Joins', desc: `They get ${config?.refereeReward || 100} Coins bonus on successful signup.`, color: 'text-indigo-500', bg: 'bg-indigo-50' },
            { icon: Trophy, title: 'Get Rewarded', desc: `You get ${config?.referrerReward || 50} Coins instantly for every friend.`, color: 'text-emerald-500', bg: 'bg-emerald-50' },
            { icon: ArrowUpRight, title: 'Winning Commission', desc: `Earn ${config?.commissionRate ?? 5}% commission on their every contest win!`, color: 'text-amber-500', bg: 'bg-amber-50' }
          ].map((step, idx) => (
            <div 
              key={idx}
              className="p-4 flex items-center gap-4 group hover:bg-slate-50 transition-all"
            >
              <div className={`w-12 h-12 ${step.bg} ${step.color} rounded-full flex items-center justify-center shrink-0`}>
                <step.icon size={24} />
              </div>
              <div className="flex-1">
                <h4 className="font-black text-slate-900 text-sm leading-none mb-1">{step.title}</h4>
                <p className="text-xs text-slate-500 font-medium">{step.desc}</p>
              </div>
              <div className="opacity-0 group-hover:opacity-100 transition-opacity">
                <ChevronRight size={18} className="text-slate-300" />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Terms Note */}
      <div className="p-4 bg-amber-50 rounded-xl border border-amber-100 flex items-start gap-3">
        <Info size={16} className="text-amber-500 mt-0.5 shrink-0" />
        <p className="text-xs text-amber-800 font-medium leading-relaxed">
          Rewards are credited once your friend verifies their mobile or email. Terms and conditions apply. 
          Minimum withdrawal for referral earnings is {config?.minWithdrawal || 2000} coins.
        </p>
      </div>
    </div>
  );
}
