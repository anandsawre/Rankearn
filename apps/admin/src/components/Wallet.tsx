import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { QRCodeSVG } from 'qrcode.react';
import { 
  Coins, 
  ArrowUpRight, 
  ArrowDownLeft, 
  History, 
  Plus, 
  Trophy, 
  CreditCard, 
  ShieldCheck, 
  Zap,
  TrendingUp,
  Clock,
  Loader2,
  AlertCircle,
  IndianRupee,
  ChevronRight,
  User,
  ArrowRight,
  Star,
  RefreshCw,
  Landmark,
  Wallet as WalletIcon,
  Mail,
  Gift
} from 'lucide-react';
import { db, auth } from '../firebase';
import { sendEmailVerification } from 'firebase/auth';
import { collection, query, where, getDocs, orderBy, limit, doc, runTransaction, serverTimestamp, getDoc, setDoc, onSnapshot, startAfter } from 'firebase/firestore';
import { UserProfile } from '../types';
import { useToast } from './Toast';
import { X } from 'lucide-react';

interface WalletProps {
  profile: UserProfile | null;
  onUpdateProfile: () => void;
}

interface Transaction {
  id: string;
  amount: number;
  type: 'earn' | 'spend';
  category: string;
  testTitle?: string;
  timestamp: any;
  currentBalance?: number;
}

export default function Wallet({ profile, onUpdateProfile }: WalletProps) {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isTopUpModalOpen, setIsTopUpModalOpen] = useState(false);
  const [topUpAmount, setTopUpAmount] = useState<number>(500);
  const [isProcessing, setIsProcessing] = useState(false);
  const [modalStep, setModalStep] = useState<'amount' | 'payment' | 'verification'>('amount');
  const [utr, setUtr] = useState('');
  const [paymentConfig, setPaymentConfig] = useState<{ upiId: string; merchantName: string; qrNote: string; coinsPerRupee: number } | null>(null);
  const [lastDoc, setLastDoc] = useState<any>(null);
  const [hasMore, setHasMore] = useState(true);
  const [isMoreLoading, setIsMoreLoading] = useState(false);
  
  // Withdrawal States
  const [isWithdrawModalOpen, setIsWithdrawModalOpen] = useState(false);
  const [withdrawStep, setWithdrawStep] = useState<'amount' | 'details' | 'confirm'>('amount');
  const [withdrawAmount, setWithdrawAmount] = useState<number>(0);
  const [paymentMethod, setPaymentMethod] = useState<'upi' | 'bank'>('upi');
  const [upiId, setUpiId] = useState('');
  const [bankDetails, setBankDetails] = useState({ holderName: '', accountNumber: '', ifsc: '' });
  const [withdrawalSettings, setWithdrawalSettings] = useState({
    minCoins: 1000,
    isUPIEnabled: true,
    isBankEnabled: true,
    feePercentage: 0,
    withdrawalNote: '',
    coinsPerRupee: 20
  });
  const [isWithdrawing, setIsWithdrawing] = useState(false);
  const [saveForFuture, setSaveForFuture] = useState(true);
  const [upiHolderName, setUpiHolderName] = useState('');
  
  // Verification check for withdrawal
  const [showVerifyWithdrawModal, setShowVerifyWithdrawModal] = useState(false);
  const [isResendingInWallet, setIsResendingInWallet] = useState(false);

  const { showToast } = useToast();

  useEffect(() => {
    const fetchConfigs = async () => {
      try {
        const paymentRef = doc(db, 'configs', 'payment_settings');
        const paymentSnap = await getDoc(paymentRef);
        if (paymentSnap.exists()) {
          setPaymentConfig(prev => ({ ...prev, ...paymentSnap.data() } as any));
        }

        const withdrawalRef = doc(db, 'configs', 'withdrawal_settings');
        const withdrawalSnap = await getDoc(withdrawalRef);
        if (withdrawalSnap.exists()) {
          setWithdrawalSettings(prev => ({ ...prev, ...withdrawalSnap.data() } as any));
        }
      } catch (error) {
        console.error("Error fetching configs:", error);
      }
    };
    fetchConfigs();
  }, []);

  const fetchTransactions = async (isLoadMore = false) => {
    const currentUid = auth.currentUser?.uid;
    if (!currentUid) return;

    if (!isLoadMore) {
      setIsLoading(true);
      setLastDoc(null);
      setHasMore(true);
    } else {
      setIsMoreLoading(true);
    }

    try {
      let q = query(
        collection(db, 'transactions'),
        where('userId', '==', currentUid),
        orderBy('timestamp', 'desc'),
        limit(20)
      );

      if (isLoadMore && lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      const snap = await getDocs(q);
      const fetched = snap.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Transaction[];
      
      if (isLoadMore) {
        setTransactions(prev => [...prev, ...fetched]);
      } else {
        setTransactions(fetched);
      }

      setLastDoc(snap.docs[snap.docs.length - 1]);
      setHasMore(snap.docs.length === 20);
    } catch (error) {
      console.error("Error fetching transactions:", error);
    } finally {
      setIsLoading(false);
      setIsMoreLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [profile?.userId]);

  // Handle Auto-fill from saved details
  useEffect(() => {
    if (isWithdrawModalOpen && profile?.savedPaymentDetails) {
      const saved = profile.savedPaymentDetails;
      if (saved.lastMethod) setPaymentMethod(saved.lastMethod);
      if (saved.upiId) setUpiId(saved.upiId);
      if (saved.holderName) {
        setUpiHolderName(saved.holderName);
        setBankDetails(prev => ({ ...prev, holderName: saved.holderName || '' }));
      }
      if (saved.accountNumber) setBankDetails(prev => ({ ...prev, accountNumber: saved.accountNumber || '' }));
      if (saved.ifsc) setBankDetails(prev => ({ ...prev, ifsc: saved.ifsc || '' }));
    }
  }, [isWithdrawModalOpen, profile]);

  const handleTopUp = async () => {
    if (!profile) return;
    
    if (modalStep === 'amount') {
      if (!paymentConfig?.upiId) {
        showToast('Payments are currently disabled by admin.', 'error');
        return;
      }
      setModalStep('payment');
      return;
    }

    if (modalStep === 'payment') {
      setModalStep('verification');
      return;
    }

    if (!utr.trim() || utr.length < 12) {
      showToast('Please enter a valid 12-digit UTR/Transaction ID', 'error');
      return;
    }

    setIsProcessing(true);
    try {
      const cleanUtr = utr.trim();
      const lockRef = doc(db, 'submitted_utrs', cleanUtr);
      const requestRef = doc(collection(db, 'topup_requests'));

      await runTransaction(db, async (transaction) => {
        // 1. Check if UTR is already locked
        const lockSnap = await transaction.get(lockRef);
        if (lockSnap.exists()) {
          throw new Error('duplicate-utr');
        }

        // 2. Create the lock document
        transaction.set(lockRef, {
          userId: profile.userId,
          amount: topUpAmount,
          timestamp: serverTimestamp()
        });

        // 3. Create the top-up request
        transaction.set(requestRef, {
          userId: profile.userId,
          amount: topUpAmount,
          utr: cleanUtr,
          status: 'pending',
          timestamp: new Date().toISOString(),
          userName: profile.name,
          userEmail: profile.email,
          userPhone: profile.phone || 'N/A',
          userPhoto: profile.profilePhoto || ''
        });
      });

      showToast(`Request submitted! Coins will be added after verification.`, 'success');
      setIsTopUpModalOpen(false);
      setModalStep('amount');
      setUtr('');
    } catch (error: any) {
      console.error("Submission failed:", error);
      if (error.message === 'duplicate-utr') {
        showToast('This Transaction ID has already been submitted. Please check and try again.', 'error');
      } else {
        showToast('Failed to submit request. Please try again.', 'error');
      }
    } finally {
      setIsProcessing(false);
    }
  };

  const handleWithdrawalRequest = async () => {
    if (!profile) return;

    if (withdrawStep === 'amount') {
      if (withdrawAmount < (withdrawalSettings.minCoins || 1000)) {
        showToast(`Minimum withdrawal is ${withdrawalSettings.minCoins || 1000} Coins`, 'error');
        return;
      }
      if (withdrawAmount > (profile.coins || 0)) {
        showToast('Insufficient balance', 'error');
        return;
      }
      setWithdrawStep('details');
      return;
    }

    if (withdrawStep === 'details') {
      if (paymentMethod === 'upi') {
        if (!upiId.includes('@')) {
          showToast('Please enter a valid UPI ID', 'error');
          return;
        }
        if (!upiHolderName.trim()) {
          showToast('Please enter account holder name', 'error');
          return;
        }
      }
      if (paymentMethod === 'bank' && (!bankDetails.accountNumber || !bankDetails.ifsc || !bankDetails.holderName)) {
        showToast('Please fill all bank details', 'error');
        return;
      }
      setWithdrawStep('confirm');
      return;
    }

    setIsWithdrawing(true);
    try {
      const requestId = `WITHDRAW_${Date.now()}`;
      const requestRef = doc(db, 'withdrawal_requests', requestId);
      const userRef = doc(db, 'users', profile.userId);
      const transactionRef = doc(collection(db, 'transactions'));

      await runTransaction(db, async (transaction) => {
        const userSnap = await transaction.get(userRef);
        if (!userSnap.exists()) throw new Error('User not found');
        const currentCoins = userSnap.data().coins || 0;

        if (currentCoins < withdrawAmount) {
          throw new Error('insufficient-funds');
        }

        const userData = userSnap.data();
        const currentTotalSpent = userData.totalSpent || 0;
        const currentWithdrawable = userData.withdrawableBalance || 0;

        // 1. Deduct coins and log transaction
        transaction.update(userRef, {
          coins: currentCoins - withdrawAmount,
          totalSpent: currentTotalSpent + withdrawAmount,
          withdrawableBalance: Math.max(0, currentWithdrawable - withdrawAmount)
        });

        transaction.set(transactionRef, {
          userId: profile.userId,
          amount: -withdrawAmount,
          type: 'spend',
          category: 'withdrawal_request',
          requestId: requestId,
          timestamp: serverTimestamp(),
          currentBalance: currentCoins - withdrawAmount
        });

        // 2. Create withdrawal request
        transaction.set(requestRef, {
          userId: profile.userId,
          userName: profile.name,
          userPhone: profile.phone || 'N/A',
          userPhoto: profile.profilePhoto || '',
          amount: withdrawAmount,
          inRupees: (withdrawAmount / (withdrawalSettings.coinsPerRupee || 20)) * (1 - (withdrawalSettings.feePercentage / 100)),
          feePercentage: withdrawalSettings.feePercentage,
          paymentMethod,
          paymentDetails: paymentMethod === 'upi' ? { upiId, holderName: upiHolderName } : bankDetails,
          status: 'pending',
          timestamp: new Date().toISOString()
        });

        // 3. Save details for future if checked
        if (saveForFuture) {
          const savedDetails = paymentMethod === 'upi' 
            ? { upiId, holderName: upiHolderName, lastMethod: 'upi' }
            : { ...bankDetails, lastMethod: 'bank' };
          
          transaction.update(userRef, {
            savedPaymentDetails: savedDetails
          });
        }
      });

      showToast('Withdrawal request submitted successfully!', 'success');
      setIsWithdrawModalOpen(false);
      onUpdateProfile();
      setWithdrawStep('amount');
      setWithdrawAmount(0);
    } catch (error: any) {
      console.error("Withdrawal failed:", error);
      showToast(error.message === 'insufficient-funds' ? 'Insufficient funds!' : 'Failed to submit request', 'error');
    } finally {
      setIsWithdrawing(false);
    }
  };


  const getUPILink = () => {
    if (!paymentConfig) return '';
    const { upiId, merchantName, qrNote } = paymentConfig;
    return `upi://pay?pa=${upiId}&pn=${encodeURIComponent(merchantName)}&am=${topUpAmount}&cu=INR&tn=${encodeURIComponent(qrNote || 'Wallet Topup')}`;
  };

  const handleWithdrawClick = () => {
    // Check for email verification
    const currentUser = auth.currentUser;
    const isGoogleUser = currentUser?.providerData.some(p => p.providerId === 'google.com');
    
    if (currentUser && !currentUser.emailVerified && !isGoogleUser) {
      setShowVerifyWithdrawModal(true);
      return;
    }

    setWithdrawAmount(Math.max(withdrawalSettings.minCoins, 0));
    setWithdrawStep('amount');
    setIsWithdrawModalOpen(true);
  };

  const stats = [
    { 
      label: 'Balance', 
      value: (profile?.coins || 0).toLocaleString(), 
      icon: IndianRupee, 
      gradient: 'from-orange-400 to-amber-600',
      shadow: 'shadow-orange-200/50',
      isCoin: true,
      description: 'Available for tests',
      action: {
        icon: Plus,
        onClick: () => setIsTopUpModalOpen(true),
        label: 'Add Coins'
      }
    },
    { 
      label: 'Total Earned', 
      value: (profile?.totalEarned !== undefined 
        ? profile.totalEarned 
        : transactions.filter(t => t.type === 'earn').reduce((acc, t) => acc + t.amount, 0)
      ).toLocaleString(), 
      icon: TrendingUp, 
      gradient: 'from-blue-500 to-cyan-600',
      shadow: 'shadow-blue-200/50',
      description: 'Lifetime rewards'
    },
    { 
      label: 'Total Spent', 
      value: (profile?.totalSpent !== undefined
        ? profile.totalSpent
        : Math.abs(transactions.filter(t => t.type === 'spend').reduce((acc, t) => acc + t.amount, 0))
      ).toLocaleString(), 
      icon: Clock, 
      gradient: 'from-rose-500 to-fuchsia-600',
      shadow: 'shadow-rose-200/50',
      description: 'Contest entries'
    },
    { 
      label: 'Withdraw', 
      value: `₹${(
        (profile?.withdrawableBalance !== undefined
          ? profile.withdrawableBalance
          : transactions.filter(t => t.category === 'tournament_prize').reduce((acc, t) => acc + t.amount, 0)
        ) / (withdrawalSettings.coinsPerRupee || 20)
      ).toLocaleString()}`, 
      icon: IndianRupee, 
      gradient: 'from-violet-600 to-indigo-700',
      shadow: 'shadow-violet-200/50',
      isCoin: true,
      coinColor: 'bg-violet-500',
      description: 'Winnings for bank',
      action: {
        icon: ArrowUpRight,
        onClick: handleWithdrawClick,
        label: 'Withdraw'
      }
    }
  ];

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'tournament_prize': return <Trophy size={16} className="text-amber-500" />;
      case 'tournament_entry': return <Plus size={16} className="text-blue-500 rotate-45" />;
      case 'top_up': return <CreditCard size={16} className="text-emerald-500" />;
      case 'admin_credit': return <ShieldCheck size={16} className="text-indigo-500" />;
      case 'reward': return <Zap size={16} className="text-purple-500" />;
      case 'lucky_wheel_win': return <Star size={16} className="text-amber-500" />;
      case 'lucky_wheel_spin': return <RefreshCw size={16} className="text-slate-500" />;
      case 'subscription': return <Zap size={16} className="text-amber-500" />;
      case 'admin_debit': return <ArrowDownLeft size={16} className="text-rose-500" />;
      case 'referral': return <Gift size={16} className="text-emerald-500" />;
      case 'referral_commission': return <TrendingUp size={16} className="text-amber-500" />;
      default: return <Coins size={16} className="text-slate-400" />;
    }
  };

  return (
    <div className="space-y-3 md:space-y-6 -mt-3 md:-mt-5 py-4 px-1 md:px-0">
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-6">
        {stats.map((stat, i) => (
          <div 
            key={i} 
            onClick={() => {
              if (stat.action) {
                // Balance and Withdraw cards are only clickable on Desktop
                const isMobile = typeof window !== 'undefined' && window.innerWidth < 768;
                if (isMobile && (stat.label === 'Balance' || stat.label === 'Withdraw')) return;
                stat.action.onClick();
              }
            }}
            className={`relative overflow-hidden bg-gradient-to-br ${stat.gradient} p-3 md:p-5 rounded-xl border border-white/10 flex items-center gap-2.5 md:gap-4 group transition-all duration-300 
              ${stat.action ? (
                (stat.label === 'Balance' || stat.label === 'Withdraw') 
                  ? 'md:cursor-pointer md:active:scale-95 cursor-default' 
                  : 'cursor-pointer active:scale-95'
              ) : ''}`}
          >
            {/* Glossy Overlay Effect */}
            <div className="absolute inset-0 bg-gradient-to-tr from-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            
            {/* Background Decoration Circle */}
            <div className="absolute -right-4 -top-4 w-16 h-16 bg-white/10 rounded-full blur-2xl group-hover:scale-150 transition-transform duration-700" />
            
            {/* Left: Icon Box */}
            <div className="w-9 h-9 md:w-12 md:h-12 shrink-0 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center shadow-inner group-hover:rotate-6 transition-transform duration-300 text-white relative z-10 border border-white/10">
              <stat.icon size={18} className="md:w-[22px] md:h-[22px]" strokeWidth={2.5} />
            </div>
            
            {/* Center: Textstack */}
            <div className="flex-1 min-w-0 text-left relative z-10">
              <p className="text-[9px] md:text-[11px] font-bold text-white/80 mb-0.5 uppercase tracking-widest leading-none">
                {stat.label}
              </p>
              <p className="text-base md:text-xl font-black text-white drop-shadow-sm leading-tight">
                {stat.value}
              </p>
            </div>
          </div>
        ))}

        {/* Mobile Action Buttons (Part of same grid for equal spacing) */}
        <button 
          onClick={() => setIsTopUpModalOpen(true)}
          className="lg:hidden relative overflow-hidden bg-gradient-to-br from-emerald-500 to-emerald-600 p-3 rounded-xl border border-white/10 flex items-center gap-2.5 active:scale-95 transition-all group"
        >
          <div className="w-9 h-9 shrink-0 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center text-white shadow-inner">
            <Plus size={18} strokeWidth={3} />
          </div>
          <div className="text-left">
            <p className="text-[9px] font-bold text-white/80 mb-0.5 uppercase tracking-widest leading-none">Wallet</p>
            <p className="text-sm font-black text-white uppercase tracking-tight leading-none">Add Coins</p>
          </div>
        </button>

        <button 
          onClick={handleWithdrawClick}
          className="lg:hidden relative overflow-hidden bg-gradient-to-br from-orange-500 to-orange-600 p-3 rounded-xl border border-white/10 flex items-center gap-2.5 active:scale-95 transition-all group"
        >
          <div className="w-9 h-9 shrink-0 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center text-white shadow-inner">
            <ArrowUpRight size={18} strokeWidth={3} />
          </div>
          <div className="text-left">
            <p className="text-[9px] font-bold text-white/80 mb-0.5 uppercase tracking-widest leading-none">Payout</p>
            <p className="text-sm font-black text-white uppercase tracking-tight leading-none">Withdraw</p>
          </div>
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-slate-50 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-slate-50 rounded-lg flex items-center justify-center text-slate-400">
              <History size={18} />
            </div>
            <h3 className="text-lg font-black text-slate-900 leading-none">Transactions</h3>
          </div>
          <div className="flex items-center gap-2">
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-wider">Recent</p>
            <button 
              onClick={() => fetchTransactions(false)}
              disabled={isLoading}
              className={`p-1.5 rounded-lg transition-all ${isLoading ? 'bg-slate-50 text-slate-300' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 active:scale-95'}`}
              title="Refresh"
            >
              <RefreshCw size={12} className={isLoading ? 'animate-spin' : ''} />
            </button>
          </div>
        </div>

        {isLoading ? (
          <div className="py-20 text-center">
            <Loader2 className="w-8 h-8 text-indigo-500 animate-spin mx-auto mb-4" />
            <p className="text-sm font-medium text-slate-500">Fetching history...</p>
          </div>
        ) : transactions.length > 0 ? (
          <div className="divide-y divide-slate-50">
            {transactions.map((tx) => (
              <div key={tx.id} className="p-4 flex items-center justify-between hover:bg-slate-50/50 transition-colors">
                <div className="flex items-center gap-3">
                  <div className={`w-9 h-9 rounded-lg flex items-center justify-center ${tx.type === 'earn' ? 'bg-emerald-50' : 'bg-rose-50'}`}>
                    {getCategoryIcon(tx.category)}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-[14px] font-black text-slate-900 leading-none">
                        {tx.category === 'tournament_entry' ? 'Joined Contest' : 
                         tx.category === 'tournament_prize' ? 'Contest Prize' : 
                         tx.category === 'top_up' ? 'Wallet Top-up' :
                          tx.category === 'admin_credit' ? 'Admin Credit' : 
                          tx.category === 'admin_debit' ? 'Admin Debit' :
                          tx.category === 'subscription' ? 'PRO Subscription' :
                          tx.category === 'lucky_wheel_spin' ? 'Lucky Wheel Fee' :
                          tx.category === 'lucky_wheel_win' ? 'Wheel Jackpot Win' :
                          tx.category === 'referral' ? 'Referral Bonus' :
                          tx.category === 'referral_commission' ? 'Friend Win Commission' :
                          tx.category.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
                      </span>
                    </div>
                    {tx.testTitle && (
                      <p className="text-xs text-slate-400 font-medium mt-0.5">{tx.testTitle}</p>
                    )}
                    <p className="text-[10px] text-slate-400 font-bold flex items-center gap-1.5 mt-1">
                      <Clock size={10} strokeWidth={3} />
                      {tx.timestamp ? (
                        (tx.timestamp.toDate ? tx.timestamp.toDate() : new Date(tx.timestamp)).toLocaleString('en-IN', { 
                          day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' 
                        })
                      ) : 'Processing...'}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-lg font-black leading-none ${tx.type === 'earn' ? 'text-emerald-600' : 'text-rose-600'}`}>
                    {tx.type === 'earn' ? '+' : '-'}{Math.abs(tx.amount).toLocaleString()}
                  </p>
                  {tx.currentBalance !== undefined && (
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-wider mt-1">
                      Bal: {tx.currentBalance.toLocaleString()}
                    </p>
                  )}
                </div>
              </div>
            ))}

            {hasMore && (
              <div className="p-4 border-t border-slate-50">
                <button
                  onClick={() => fetchTransactions(true)}
                  disabled={isMoreLoading}
                  className="w-full py-3 bg-slate-50 hover:bg-slate-100 text-slate-500 font-black text-[10px] uppercase tracking-widest rounded-xl transition-all flex items-center justify-center gap-2 active:scale-[0.98] disabled:opacity-50"
                >
                  {isMoreLoading ? (
                    <>
                      <Loader2 size={14} className="animate-spin" />
                      Loading...
                    </>
                  ) : (
                    <>
                      <Plus size={14} />
                      View More Transactions
                    </>
                  )}
                </button>
              </div>
            )}
          </div>
        ) : (
          <div className="py-20 text-center space-y-4">
            <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto text-slate-300">
              <History size={32} />
            </div>
            <div className="space-y-1">
              <p className="text-lg font-bold text-slate-900">No Transactions Yet</p>
              <p className="text-sm text-slate-500">Your coin history will appear here once you perform an activity.</p>
            </div>
          </div>
        )}
      </div>

      {/* Top-up Modal */}
      <AnimatePresence>
        {isTopUpModalOpen && (
          <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur-md flex items-start md:items-center justify-center p-4 pt-10 pb-32 md:pt-4 md:pb-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden relative max-h-[90vh] flex flex-col"
            >
              <div className="bg-gradient-to-r from-emerald-500 to-emerald-400 p-4 relative overflow-hidden">
                 {/* Decorative background circle */}
                 <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
                 
                 <div className="flex items-center gap-4 relative z-10">
                    <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-lg flex items-center justify-center border border-white/30 text-white shadow-inner">
                       <WalletIcon size={28} strokeWidth={3} />
                    </div>
                    <div>
                       <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Top-up Wallet</h2>
                       <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">Add Coins</p>
                    </div>
                 </div>

                 <button 
                  onClick={() => setIsTopUpModalOpen(false)} 
                  className="absolute top-6 right-6 p-2 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20 backdrop-blur-md z-20"
                 >
                    <X size={18} />
                 </button>
              </div>

              <div className="flex-1 overflow-y-auto no-scrollbar p-4 pt-3 space-y-3">
                {/* Dynamic Content based on Step */}
                <ModalContent 
                  step={modalStep} 
                  amount={topUpAmount} 
                  utr={utr} 
                  setUtr={setUtr} 
                  upiLink={getUPILink()} 
                  paymentConfig={paymentConfig}
                  profile={profile}
                />

                {modalStep === 'amount' && (
                  <div className="grid grid-cols-3 gap-3">
                    {[100, 500, 1000].map(amt => (
                      <button
                        key={amt}
                        onClick={() => setTopUpAmount(amt)}
                        className={`py-3 rounded-lg font-black text-sm border-2 transition-all ${
                          topUpAmount === amt 
                            ? 'bg-emerald-50 border-emerald-500 text-emerald-600 shadow-sm' 
                            : 'bg-white border-slate-100 text-slate-400 hover:border-slate-200'
                        }`}
                      >
                        {amt}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <div className="p-4 pt-0 flex gap-3">
                  <button
                    onClick={() => {
                      if (modalStep === 'amount') {
                        setIsTopUpModalOpen(false);
                      } else if (modalStep === 'payment') {
                        setModalStep('amount');
                      } else {
                        setModalStep('payment');
                      }
                    }}
                    className="flex-1 py-3.5 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
                  >
                    {modalStep === 'amount' ? 'Cancel' : 'Back'}
                  </button>
                  <button
                    onClick={handleTopUp}
                    disabled={isProcessing}
                    className="flex-1 py-3.5 bg-gradient-to-r from-emerald-500 to-emerald-400 text-white font-black rounded-xl text-[11px] uppercase tracking-widest shadow-lg shadow-emerald-100 flex items-center justify-center gap-2 hover:from-emerald-600 hover:to-emerald-500 transition-all active:scale-95 disabled:opacity-50"
                  >
                    {isProcessing ? <Loader2 size={18} className="animate-spin" /> : (
                      <>
                        {modalStep === 'verification' ? <ShieldCheck size={16} strokeWidth={3} /> : <ArrowRight size={16} strokeWidth={3} />}
                        {modalStep === 'amount' ? 'Proceed' : modalStep === 'payment' ? 'I Have Paid' : 'Submit'}
                      </>
                    )}
                  </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Withdrawal Modal */}
      <AnimatePresence>
        {isWithdrawModalOpen && (
          <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur-md flex items-start md:items-center justify-center p-4 pt-10 pb-32 md:pt-4 md:pb-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden relative max-h-[90vh] flex flex-col"
            >
              <div className="bg-gradient-to-r from-orange-500 to-orange-400 p-4 relative overflow-hidden">
                 {/* Decorative background circle */}
                 <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
                 
                 <div className="flex items-center gap-4 relative z-10">
                    <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-lg flex items-center justify-center border border-white/30 text-white shadow-inner">
                        <Landmark size={28} strokeWidth={3} />
                    </div>
                    <div>
                       <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Withdraw Funds</h2>
                       <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">Request Payout</p>
                    </div>
                 </div>

                 <button 
                  onClick={() => setIsWithdrawModalOpen(false)} 
                  className="absolute top-4 right-4 p-2 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20 backdrop-blur-md z-20"
                 >
                    <X size={18} />
                 </button>
              </div>

              <div className="flex-1 overflow-y-auto no-scrollbar p-4 pt-3 space-y-3">
                {withdrawStep === 'amount' && (
                  <div className="space-y-4">
                    {/* User Info Card */}
                    <div className="bg-slate-50 border border-slate-100 rounded-xl p-4 flex items-center gap-4 text-left shadow-sm">
                       <div className="w-12 h-12 bg-orange-500 rounded-lg flex items-center justify-center text-white font-black text-lg shadow-md shadow-orange-100 uppercase">
                          {profile?.name?.charAt(0) || <User size={20} />}
                       </div>
                       <div className="flex-1 min-w-0">
                          <h4 className="text-sm font-black text-slate-900 truncate">{profile?.name || 'User'}</h4>
                          <p className="text-[10px] text-slate-400 font-bold truncate">{profile?.email}</p>
                       </div>
                       <div className="text-right">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">Balance</p>
                          <p className="text-lg font-black text-orange-500 leading-none">{profile?.coins?.toLocaleString() || 0}</p>
                       </div>
                    </div>

                    <div className="space-y-3">
                       <div className="text-left flex items-center justify-between px-1">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Select Amount</label>
                          <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Min. {withdrawalSettings.minCoins} Coins</p>
                       </div>
                       
                       <div className="grid grid-cols-4 gap-2">
                          {[500, 1000, 2000, 5000].map(amt => (
                            <button
                              key={amt}
                              onClick={() => setWithdrawAmount(amt)}
                              className={`py-2.5 rounded-lg font-black text-xs transition-all border-2 ${
                                withdrawAmount === amt 
                                  ? 'bg-orange-50 border-orange-500 text-orange-600 shadow-sm' 
                                  : 'bg-white border-slate-100 text-slate-400 hover:border-slate-200'
                              }`}
                            >
                              {amt}
                            </button>
                          ))}
                       </div>
                    </div>

                    <div className="space-y-1.5 text-left">
                       <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Amount (Coins)</label>
                       <div className="relative">
                          <input 
                            type="number"
                            value={withdrawAmount || ''}
                            onChange={(e) => setWithdrawAmount(parseInt(e.target.value) || 0)}
                            placeholder="0"
                            className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl py-4 px-12 text-left text-2xl font-black text-slate-900 outline-none focus:border-orange-500 transition-all no-spinner"
                          />
                          <div className="absolute left-4 top-1/2 -translate-y-1/2 text-orange-500 font-black">
                             <Coins size={22} />
                          </div>
                          {withdrawalSettings.feePercentage > 0 && (
                            <div className="absolute right-4 top-1/2 -translate-y-1/2">
                               <span className="bg-orange-100 text-orange-600 px-2 py-0.5 rounded text-[8px] font-black uppercase">-{withdrawalSettings.feePercentage}% Fee</span>
                            </div>
                          )}
                       </div>
                    </div>

                    <div className="p-3 bg-amber-50 rounded-xl border-2 border-dashed border-amber-200/50 flex items-center justify-between relative overflow-hidden">
                       <div className="relative z-10 text-left">
                          <p className="text-[9px] font-black text-amber-600 uppercase tracking-widest mb-1">You Receive</p>
                          <p className="text-2xl font-black text-amber-700 leading-none">₹{(withdrawAmount / (withdrawalSettings.coinsPerRupee || 20) * (1 - (withdrawalSettings.feePercentage / 100))).toLocaleString()}</p>
                       </div>
                       <div className="w-11 h-11 bg-amber-100/50 rounded-full flex items-center justify-center text-amber-400 relative z-10 shadow-inner">
                          <Trophy size={22} />
                       </div>
                       {/* Decorative patterns */}
                       <div className="absolute -right-2 -bottom-2 w-12 h-12 bg-white/20 rounded-full" />
                    </div>

                    {withdrawalSettings.withdrawalNote && (
                      <div className="p-3 bg-blue-50/50 rounded-xl border border-blue-100/50 text-left">
                        <p className="text-[9px] text-blue-900/60 font-black tracking-tight leading-relaxed">
                            <span className="text-blue-600 mr-1.5 uppercase tracking-widest">Note:</span> 
                            {withdrawalSettings.withdrawalNote}
                        </p>
                      </div>
                    )}
                  </div>
                )}

                {withdrawStep === 'details' && (
                   <div className="space-y-4">
                      <div className="bg-slate-100 p-1.5 rounded-xl flex gap-1 border border-slate-200/50 shadow-inner">
                         {withdrawalSettings.isUPIEnabled && (
                           <button 
                            onClick={() => setPaymentMethod('upi')}
                            className={`flex-1 flex items-center justify-center gap-2 py-2.5 text-xs font-black uppercase rounded-lg transition-all shadow-sm ${paymentMethod === 'upi' ? 'bg-white text-slate-900 ring-1 ring-slate-200' : 'text-slate-400'}`}
                           >
                              <Zap size={14} className={paymentMethod === 'upi' ? 'text-orange-500' : 'text-slate-300'} />
                              UPI
                           </button>
                         )}
                         {withdrawalSettings.isBankEnabled && (
                           <button 
                            onClick={() => setPaymentMethod('bank')}
                            className={`flex-1 flex items-center justify-center gap-2 py-2.5 text-xs font-black uppercase rounded-xl transition-all shadow-sm ${paymentMethod === 'bank' ? 'bg-white text-slate-900 ring-1 ring-slate-200' : 'text-slate-400'}`}
                           >
                              <CreditCard size={14} className={paymentMethod === 'bank' ? 'text-orange-500' : 'text-slate-300'} />
                              Bank
                           </button>
                         )}
                      </div>

                      <div className="space-y-4 text-left">
                         {paymentMethod === 'upi' ? (
                           <div className="space-y-4">
                              <div className="space-y-1.5">
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Banking Name (A/C Holder)</label>
                                <input 
                                  type="text"
                                  value={upiHolderName}
                                  onChange={(e) => setUpiHolderName(e.target.value)}
                                  placeholder="Full Name as per Bank"
                                  className="w-full bg-slate-50 border-2 border-slate-100 rounded-lg px-4 py-4 text-sm font-bold text-slate-700 outline-none focus:border-orange-500 transition-all"
                                />
                              </div>
                              <div className="space-y-1.5">
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">UPI ID (VPA)</label>
                                <input 
                                  type="text"
                                  value={upiId}
                                  onChange={(e) => setUpiId(e.target.value)}
                                  placeholder="name@upi"
                                  className="w-full bg-slate-50 border-2 border-slate-100 rounded-lg px-4 py-4 text-sm font-bold text-slate-700 outline-none focus:border-orange-500 transition-all"
                                />
                              </div>
                           </div>
                         ) : (
                           <div className="space-y-3">
                              <div className="space-y-1.5">
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Account Holder Name</label>
                                <input 
                                  type="text"
                                  value={bankDetails.holderName}
                                  onChange={(e) => setBankDetails({...bankDetails, holderName: e.target.value})}
                                  placeholder="Full Name"
                                  className="w-full bg-slate-50 border-2 border-slate-100 rounded-lg px-4 py-4 text-sm font-bold text-slate-700 outline-none focus:border-orange-500 transition-all"
                                />
                              </div>
                              <div className="space-y-1.5">
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Account Number</label>
                                <input 
                                  type="text"
                                  value={bankDetails.accountNumber}
                                  onChange={(e) => setBankDetails({...bankDetails, accountNumber: e.target.value})}
                                  placeholder="00000000000"
                                  className="w-full bg-slate-50 border-2 border-slate-100 rounded-lg px-4 py-4 text-sm font-bold text-slate-700 outline-none focus:border-orange-500 transition-all"
                                />
                              </div>
                              <div className="space-y-1.5">
                                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">IFSC Code</label>
                                <input 
                                  type="text"
                                  value={bankDetails.ifsc}
                                  onChange={(e) => setBankDetails({...bankDetails, ifsc: e.target.value.toUpperCase()})}
                                  placeholder="IFSC00001"
                                  className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 py-4 text-sm font-bold text-slate-700 outline-none uppercase focus:border-orange-500 transition-all"
                                />
                              </div>
                           </div>
                         )}
                      </div>

                      {/* Save for future checkbox */}
                      <div className="pt-2 text-left">
                        <label className="flex items-center gap-3 cursor-pointer group bg-slate-50 p-3 rounded-xl border border-slate-200/50">
                           <div className="relative">
                              <input 
                                type="checkbox"
                                checked={saveForFuture}
                                onChange={(e) => setSaveForFuture(e.target.checked)}
                                className="peer hidden"
                              />
                              <div className="w-5 h-5 border-2 border-slate-200 rounded-md peer-checked:bg-orange-500 peer-checked:border-orange-500 transition-all flex items-center justify-center">
                                 <svg className={`w-3.5 h-3.5 text-white ${saveForFuture ? 'scale-100' : 'scale-0'} transition-transform`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={4}>
                                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                                 </svg>
                              </div>
                           </div>
                           <span className="text-xs font-bold text-slate-600 group-hover:text-slate-900 transition-colors">Save details for future use</span>
                        </label>
                      </div>
                   </div>
                )}

                {withdrawStep === 'confirm' && (
                  <div className="space-y-4">
                     <div className="w-20 h-20 bg-amber-50 text-amber-600 rounded-3xl flex items-center justify-center mx-auto shadow-inner ring-4 ring-amber-500/10">
                        <ShieldCheck size={40} strokeWidth={3} />
                     </div>
                     <div className="space-y-2 text-center">
                        <h2 className="text-xl font-black text-slate-900 uppercase tracking-tight leading-none">Confirm Request</h2>
                        <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Verify payout details</p>
                     </div>

                     <div className="bg-slate-50 p-5 rounded-xl border border-slate-100 text-left space-y-4">
                        <div className="flex justify-between items-center pb-3 border-b border-slate-200/50">
                           <span className="text-[10px] font-black text-slate-400 uppercase">Debiting Coins</span>
                           <span className="text-sm font-black text-orange-600 flex items-center gap-1"><Coins size={14} /> {withdrawAmount.toLocaleString()}</span>
                        </div>
                        <div className="flex justify-between items-center pb-3 border-b border-slate-200/50">
                           <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Mode</span>
                           <span className="text-xs font-black text-slate-900 uppercase px-2 py-0.5 bg-white rounded-lg border border-slate-200">{paymentMethod}</span>
                        </div>
                        <div className="space-y-1">
                           <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Payout To</span>
                           <p className="text-sm font-black text-slate-800 truncate">
                              {paymentMethod === 'upi' ? `${upiHolderName} (${upiId})` : `${bankDetails.holderName} - ${bankDetails.accountNumber}`}
                           </p>
                        </div>
                     </div>

                     <div className="bg-amber-50 border-2 border-amber-200/50 p-4 rounded-xl flex items-center gap-3 text-left">
                        <AlertCircle className="text-amber-600 shrink-0" size={18} />
                        <p className="text-[9px] text-amber-800 font-black leading-relaxed">
                           * Transfer completes within 24-48 business hours after admin verification.
                        </p>
                     </div>
                  </div>
                )}
              </div>

              <div className="p-4 pt-0 flex gap-3">
                   <button 
                    onClick={() => {
                      if (withdrawStep === 'amount') setIsWithdrawModalOpen(false);
                      else if (withdrawStep === 'details') setWithdrawStep('amount');
                      else setWithdrawStep('details');
                    }}
                    className="flex-1 py-3.5 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
                   >
                    {withdrawStep === 'amount' ? 'Cancel' : 'Back'}
                   </button>
                   <button 
                    onClick={handleWithdrawalRequest}
                    disabled={isWithdrawing}
                    className="flex-1 py-3.5 bg-gradient-to-r from-orange-500 to-orange-400 text-white font-black rounded-xl text-[11px] uppercase tracking-widest shadow-lg shadow-orange-100 flex items-center justify-center gap-2 hover:from-orange-600 hover:to-orange-500 transition-all active:scale-95 disabled:opacity-50"
                   >
                    {isWithdrawing ? <Loader2 size={16} className="animate-spin" /> : (
                      <>
                        {withdrawStep === 'confirm' ? <ShieldCheck size={16} strokeWidth={3} /> : <ArrowRight size={16} strokeWidth={3} />}
                        {withdrawStep === 'confirm' ? 'Submit' : 'Next Step'}
                      </>
                    )}
                   </button>
                </div>
            </motion.div>
          </div>
        )}

        {/* Email Verification Required Modal for Withdrawals */}
        {showVerifyWithdrawModal && (
          <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 pb-20 md:pb-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowVerifyWithdrawModal(false)}
              className="absolute inset-0 bg-slate-950/60 backdrop-blur-md"
            />
            <motion.div
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="relative w-full max-w-[360px] bg-white rounded-3xl overflow-hidden shadow-2xl border border-slate-100"
            >
              {/* Header */}
              <div className="bg-emerald-600 p-5 text-center relative">
                <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-full -mr-16 -mt-16 blur-2xl" />
                <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center mx-auto mb-3 shadow-xl">
                  <Mail size={28} className="text-emerald-600" />
                </div>
                <h3 className="text-xl font-black text-white uppercase tracking-tight">Verify Email First</h3>
                <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-1">Security Requirement</p>
              </div>

              {/* Content */}
              <div className="p-6 space-y-5">
                <p className="text-xs text-slate-500 font-medium text-center leading-relaxed">
                  To ensure secure transactions and prevent fraud, <span className="text-slate-900 font-bold">Email Verification</span> is required before withdrawing coins to your bank or UPI.
                </p>

                <div className="space-y-2">
                  <button
                    onClick={async () => {
                      if (!auth.currentUser) return;
                      setIsResendingInWallet(true);
                      try {
                        await auth.currentUser.reload();
                        if (auth.currentUser.emailVerified) {
                          setShowVerifyWithdrawModal(false);
                          showToast('Email verified successfully!', 'success');
                        } else {
                          showToast('Email not verified yet. Please check your inbox.', 'warning');
                        }
                      } catch (error) {
                        showToast('Failed to refresh status.', 'error');
                      } finally {
                        setIsResendingInWallet(false);
                      }
                    }}
                    disabled={isResendingInWallet}
                    className="w-full py-3.5 bg-emerald-600 text-white font-black rounded-xl text-[11px] uppercase tracking-widest shadow-xl flex items-center justify-center gap-2 hover:bg-emerald-700 transition-all active:scale-95 disabled:opacity-50"
                  >
                    {isResendingInWallet ? <Loader2 size={16} className="animate-spin" /> : <RefreshCw size={16} />}
                    I've Verified (Check Status)
                  </button>

                  <button
                    onClick={async () => {
                      if (isResendingInWallet || !auth.currentUser) return;
                      setIsResendingInWallet(true);
                      try {
                        await sendEmailVerification(auth.currentUser);
                        showToast('Verification email sent! Please check your inbox.', 'success');
                      } catch (error: any) {
                        showToast(error.message || 'Failed to send email.', 'error');
                      } finally {
                        setIsResendingInWallet(false);
                      }
                    }}
                    disabled={isResendingInWallet}
                    className="w-full py-3.5 bg-white text-emerald-600 border-2 border-emerald-100 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-emerald-50 transition-all active:scale-95 disabled:opacity-50"
                  >
                    Send New Link
                  </button>
                  <button
                    onClick={() => setShowVerifyWithdrawModal(false)}
                    className="w-full py-3.5 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
                  >
                    Maybe Later
                  </button>
                </div>

                <div className="pt-3 border-t border-slate-50 flex items-center justify-center gap-2">
                  <ShieldCheck size={14} className="text-emerald-500" />
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Secure Withdrawal System</span>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}

// Sub-component for Step content to keep main clean
function ModalContent({ step, amount, utr, setUtr, upiLink, paymentConfig, profile }: any) {
  if (step === 'amount') {
    return (
      <div className="space-y-3">
        {/* User Info Card */}
        <div className="bg-slate-50 border border-slate-100 rounded-xl p-4 flex items-center gap-4 text-left shadow-sm">
           <div className="w-12 h-12 bg-emerald-500 rounded-lg flex items-center justify-center text-white font-black text-lg shadow-md shadow-emerald-100 uppercase">
              {profile?.name?.charAt(0) || <User size={20} />}
           </div>
           <div className="flex-1 min-w-0">
              <h4 className="text-sm font-black text-slate-900 truncate">{profile?.name || 'User'}</h4>
              <p className="text-[10px] text-slate-400 font-bold truncate">{profile?.email}</p>
           </div>
           <div className="text-right">
              <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">Balance</p>
              <p className="text-lg font-black text-emerald-500 leading-none">{profile?.coins?.toLocaleString() || 0}</p>
           </div>
        </div>

        <div className="space-y-2 text-left">
           <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Amount (Coins)</label>
           <div className="relative">
              <input 
                type="number"
                value={amount || ''}
                readOnly
                className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl py-4 px-12 text-left text-2xl font-black text-slate-900 outline-none no-spinner"
              />
              <div className="absolute left-4 top-1/2 -translate-y-1/2 text-emerald-500 font-black">
                 <Coins size={22} />
              </div>
           </div>
        </div>

        <div className="p-5 bg-emerald-50 rounded-xl border-2 border-dashed border-emerald-200/50 flex items-center justify-between relative overflow-hidden text-left">
           <div className="relative z-10">
              <p className="text-[10px] font-black text-emerald-600 uppercase tracking-widest mb-1.5">You Pay</p>
              <p className="text-3xl font-black text-emerald-700 leading-none">₹{(amount / (paymentConfig?.coinsPerRupee || 10)).toLocaleString()}</p>
           </div>
           <div className="w-14 h-14 bg-emerald-100/50 rounded-full flex items-center justify-center text-emerald-400 relative z-10 shadow-inner">
              <CreditCard size={28} />
           </div>
           <div className="absolute -right-2 -bottom-2 w-12 h-12 bg-white/20 rounded-full" />
        </div>
      </div>
    );
  }

  if (step === 'payment') {
    return (
      <div className="space-y-3">
        <div className="w-48 h-48 bg-white p-4 rounded-2xl border-2 border-slate-100 mx-auto flex items-center justify-center shadow-sm">
          <QRCodeSVG value={upiLink} size={160} level="H" />
        </div>
        <div className="space-y-1.5">
          <h2 className="text-xl font-black text-slate-900 uppercase tracking-tight">Scan to Pay</h2>
          <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest px-4">Scan QR with GPay, PhonePe, or Paytm.</p>
        </div>
        <a 
          href={upiLink} 
          className="md:hidden block w-full py-3 bg-emerald-50 text-emerald-600 font-black rounded-xl border border-emerald-100 text-sm"
        >
          Open UPI App Directly
        </a>
        <div className="flex items-center gap-3 p-4 bg-amber-50 rounded-xl text-left border border-amber-100">
          <Clock className="text-amber-500 shrink-0" size={20} />
          <p className="text-[10px] text-amber-800 font-bold leading-relaxed">
            Please complete the payment in your UPI app first, then click "I Have Paid" to submit verification.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <div className="w-20 h-20 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center mx-auto shadow-inner ring-4 ring-emerald-500/10">
        <ShieldCheck size={40} strokeWidth={3} />
      </div>
      <div className="space-y-1.5">
        <h2 className="text-xl font-black text-slate-900 uppercase tracking-tight">Verify Payment</h2>
        <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest">Enter the 12-digit UTR/Transaction ID.</p>
      </div>
      <input 
        type="text"
        value={utr}
        onChange={(e) => setUtr(e.target.value.replace(/\D/g, '').slice(0, 12))}
        placeholder="Enter 12-digit Ref No."
        className="w-full px-4 py-4 bg-slate-50 border-2 border-slate-100 rounded-xl text-center font-black text-lg tracking-widest outline-none focus:border-emerald-500 transition-colors"
      />
      <div className="p-4 bg-slate-50 rounded-xl text-left border border-slate-100">
        <p className="text-[10px] text-slate-500 font-bold leading-relaxed">
          * Find the Ref No. / UTR in your payment app history after successful payment. Balance will be updated after admin approval.
        </p>
      </div>
    </div>
  );
}
