import React, { Suspense, lazy, useEffect, useState, useRef } from 'react';
import { App as CapacitorApp } from '@capacitor/app';
import { Capacitor } from '@capacitor/core';
import { SplashScreen } from '@capacitor/splash-screen';
import { auth, db, googleProvider, UserProfile, ReferralSystemConfig, generateUniqueReferralCode, requestNotificationPermission, onMessageListener } from '@rankearn/shared';
import { onAuthStateChanged, signInWithPopup, signOut, createUserWithEmailAndPassword, signInWithEmailAndPassword, updateProfile as updateFirebaseProfile, User as FirebaseUser, sendPasswordResetEmail, sendEmailVerification, signInWithCredential, GoogleAuthProvider } from 'firebase/auth';
import { GoogleAuth } from '@codetrix-studio/capacitor-google-auth';
import { doc, getDoc, setDoc, query, collection, where, onSnapshot, limit, getDocs, updateDoc, increment, addDoc, serverTimestamp } from 'firebase/firestore';
import {
  Home,
  BookOpen,
  Trophy,
  User,
  LogOut,
  Menu,
  X,
  Zap,
  ShieldCheck,
  Bell,
  CreditCard,
  Target,
  Star,
  Calendar,
  Award,
  FileText,
  IndianRupee,
  LayoutDashboard,
  Users,
  Layout,
  BrainCircuit,
  Image as ImageIcon,
  Settings,
  RefreshCw,
  Mail,
  Gift,
  RotateCcw,
  Wallet as WalletIcon,
  Coins,
  MessageCircle,
  Swords,
  BarChart3
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { Routes, Route, useNavigate, useLocation, Navigate } from 'react-router-dom';
import confetti from 'canvas-confetti';

// Pages
import LandingPage from './components/LandingPage';
import InstallPrompt from './components/InstallPrompt';
import AuthModal from './components/AuthModal';
import { useToast } from './components/Toast';
import NotificationCenter from './components/NotificationCenter';
import ImageBannerModal from './components/ImageBannerModal';
import ReviewPage from './components/ReviewPage';
import Wallet from './components/Wallet';
import LuckyWheel from './components/LuckyWheel';
import ReferralSection from './components/ReferralSection';
import Updates from './components/Updates';
import LiveTestAlert from './components/LiveTestAlert';
import ContestJoinModal from './components/TournamentJoinModal';
import SuspendedScreen from './components/SuspendedScreen';
import VerifyEmailScreen from './components/VerifyEmailScreen';

import { seedData } from './seed';

import Dashboard from './components/Dashboard';
import TestSeries from './components/TestSeries';
import QuizInterface from './components/QuizInterface';
import Profile from './components/Profile';
import Subscription from './components/Subscription';
import Earn from './components/Earn';
import ResultsPage from './components/ResultsPage';
import SupportChat from './components/SupportChat';
import Feedback from './components/Feedback';
import BattleMain from './components/battle/BattleMain';

// Legal Pages
const PrivacyPolicy = lazy(() => import('./components/legal/PrivacyPolicy'));
const TermsOfUse = lazy(() => import('./components/legal/TermsOfUse'));
const RefundPolicy = lazy(() => import('./components/legal/RefundPolicy'));
const ContactUs = lazy(() => import('./components/legal/ContactUs'));
const AboutUs = lazy(() => import('./components/legal/AboutUs'));
import PullToRefresh from './components/PullToRefresh';
import VisualAtmosphere from './components/VisualAtmosphere';

const AppLoadingState = ({ fullScreen = false }: { fullScreen?: boolean }) => (
  <div className={`${fullScreen ? 'min-h-screen' : 'min-h-[60vh]'} bg-transparent flex flex-col items-center justify-center`} style={{ background: fullScreen ? '#F8FAF9' : undefined }}>
    <motion.div
      initial={{ scale: 0.8, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      className="relative mb-8"
    >
      <div className="w-24 h-24 bg-emerald-500 rounded-full flex items-center justify-center">
        <span className="text-white text-5xl font-black">R</span>
      </div>
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
        className="absolute -inset-4 border-2 border-emerald-500 border-t-transparent rounded-full opacity-20"
      />
    </motion.div>
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.2 }}
      className="text-center"
    >
      <h2 className="text-2xl font-black text-slate-900 tracking-tight">Rankearn</h2>
      <motion.p
        className="text-[10px] font-black uppercase tracking-[0.3em] text-emerald-600 mt-1 flex justify-center"
      >
        {"Start Learning with Earning".split('').map((char, i) => (
          <motion.span
            key={i}
            initial={{ opacity: 0, filter: 'blur(4px)', y: 5 }}
            animate={{ opacity: 1, filter: 'blur(0px)', y: 0 }}
            transition={{ 
              delay: 0.5 + (i * 0.04), 
              duration: 0.4,
              ease: "easeOut"
            }}
            style={{ display: 'inline-block', whiteSpace: char === ' ' ? 'pre' : 'normal' }}
          >
            {char}
          </motion.span>
        ))}
      </motion.p>
      <div className="flex items-center justify-center gap-1 mt-4">
        <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
        <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
        <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
      </div>
    </motion.div>
  </div>
);

// Lock to prevent onSnapshot race condition during email signup
let isCreatingProfile = false;

const WelcomeBonusModal = ({ amount, onClose }: { amount: number; onClose: () => void }) => {
  useEffect(() => {
    const duration = 3500;
    const animationEnd = Date.now() + duration;
    const colors = ['#10b981', '#f59e0b', '#ffffff', '#34d399', '#fbbf24'];

    const randomInRange = (min: number, max: number) => Math.random() * (max - min) + min;

    const interval: any = setInterval(() => {
      const timeLeft = animationEnd - Date.now();
      if (timeLeft <= 0) return clearInterval(interval);

      const particleCount = 40 * (timeLeft / duration);
      confetti({
        particleCount,
        startVelocity: 35,
        spread: 80,
        origin: { x: randomInRange(0.2, 0.4), y: -0.1 },
        colors,
        ticks: 80,
        zIndex: 10001,
        scalar: 0.9,
      });
      confetti({
        particleCount,
        startVelocity: 35,
        spread: 80,
        origin: { x: randomInRange(0.6, 0.8), y: -0.1 },
        colors,
        ticks: 80,
        zIndex: 10001,
        scalar: 0.9,
      });
    }, 300);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="absolute inset-0 bg-slate-950/80 backdrop-blur-md"
      />

      {/* Modal Card */}
      <motion.div
        initial={{ scale: 0.85, opacity: 0, y: 30 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        exit={{ scale: 0.85, opacity: 0, y: 30 }}
        transition={{ type: 'spring', stiffness: 300, damping: 25 }}
        className="relative w-full max-w-[360px] rounded-3xl overflow-hidden shadow-2xl"
        style={{ background: 'linear-gradient(160deg, #0f172a 0%, #1e293b 60%, #0c1a2e 100%)' }}
      >
        {/* Top glow */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-64 h-32 rounded-full blur-3xl opacity-30"
          style={{ background: 'radial-gradient(circle, #10b981, transparent)' }} />

        {/* Decorative dots grid */}
        <div className="absolute inset-0 opacity-[0.04]"
          style={{ backgroundImage: 'radial-gradient(circle, #ffffff 1px, transparent 1px)', backgroundSize: '20px 20px' }} />

        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 z-10 w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white/70 hover:text-white transition-all"
        >
          <X size={16} />
        </button>

        <div className="relative px-8 pt-10 pb-8 text-center">
          {/* Coin Icon */}
          <div className="relative inline-block mb-6">
            {/* Outer glow ring */}
            <motion.div
              animate={{ scale: [1, 1.15, 1], opacity: [0.4, 0.7, 0.4] }}
              transition={{ duration: 2.5, repeat: Infinity, ease: 'easeInOut' }}
              className="absolute inset-0 rounded-full blur-xl"
              style={{ background: 'radial-gradient(circle, #f59e0b, transparent)' }}
            />
            <motion.div
              animate={{ rotate: [0, 5, -5, 0] }}
              transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              className="relative w-24 h-24 rounded-full flex items-center justify-center shadow-xl"
              style={{ background: 'linear-gradient(135deg, #f59e0b, #fbbf24, #d97706)' }}
            >
              <Coins className="w-12 h-12 text-white drop-shadow-lg" />
            </motion.div>

            {/* Sparkles */}
            {[
              { top: '-8px', right: '-4px', delay: 0 },
              { top: '4px', left: '-12px', delay: 0.4 },
              { bottom: '-4px', right: '-10px', delay: 0.8 },
            ].map((pos, i) => (
              <motion.div
                key={i}
                animate={{ scale: [0, 1, 0], opacity: [0, 1, 0] }}
                transition={{ duration: 1.5, delay: pos.delay, repeat: Infinity, repeatDelay: 1 }}
                className="absolute w-5 h-5 text-yellow-300"
                style={pos as any}
              >
                <Star size={16} fill="currentColor" />
              </motion.div>
            ))}
          </div>

          {/* Title */}
          <motion.h2
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-2xl font-black text-white mb-1 tracking-tight"
          >
            Welcome Bonus! 🎁
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="text-slate-400 text-sm mb-7"
          >
            Your account is ready. Here's a gift from us!
          </motion.p>

          {/* Coin Amount Card */}
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.4, type: 'spring' }}
            className="relative rounded-2xl p-5 mb-7 overflow-hidden"
            style={{ background: 'linear-gradient(135deg, rgba(16,185,129,0.15), rgba(16,185,129,0.05))', border: '1px solid rgba(16,185,129,0.25)' }}
          >
            <div className="absolute inset-0 opacity-10"
              style={{ background: 'radial-gradient(circle at 80% 20%, #10b981, transparent 60%)' }} />

            <div className="relative flex items-center justify-center gap-3">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center"
                style={{ background: 'rgba(16,185,129,0.2)', border: '1px solid rgba(16,185,129,0.3)' }}>
                <Coins className="w-6 h-6 text-emerald-400" />
              </div>
              <div className="text-left">
                <div className="text-[11px] text-emerald-400 font-bold uppercase tracking-widest">Credited to wallet</div>
                <div className="text-4xl font-black text-emerald-300 leading-none">
                  +{amount}
                </div>
                <div className="text-[11px] text-emerald-500 font-semibold mt-0.5">Coins</div>
              </div>
            </div>
          </motion.div>

          {/* Info Row */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="flex items-center justify-center gap-1.5 text-slate-500 text-xs mb-7"
          >
            <Zap size={12} className="text-emerald-500" />
            <span>Available instantly in your wallet</span>
          </motion.div>

          {/* CTA Button */}
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.55 }}
            whileHover={{ scale: 1.03 }}
            whileTap={{ scale: 0.97 }}
            onClick={onClose}
            className="w-full py-4 rounded-2xl font-bold text-white text-sm tracking-wide shadow-lg transition-all"
            style={{ background: 'linear-gradient(135deg, #059669, #10b981)', boxShadow: '0 8px 24px rgba(16,185,129,0.35)' }}
          >
            Start Learning & Earning →
          </motion.button>
        </div>
      </motion.div>
    </div>
  );
};

export default function App() {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [authSettings, setAuthSettings] = useState<{ requireEmailVerification: boolean }>({ requireEmailVerification: false });
  const [isLoggingIn, setIsLoggingIn] = useState(false);

  // Fetch Global Auth Settings
  useEffect(() => {
    const fetchAuthSettings = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'auth_settings'));
        if (snap.exists()) {
          setAuthSettings({ requireEmailVerification: !!snap.data().requireEmailVerification });
        }
      } catch (e) {
        console.error("Error fetching global auth settings", e);
      }
    };
    fetchAuthSettings();
  }, []);

  // Fetch Feature Flags
  const [featureFlags, setFeatureFlags] = useState<{ showSubscriptionTab: boolean }>({ showSubscriptionTab: true });
  useEffect(() => {
    const fetchFeatureFlags = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'feature_flags'));
        if (snap.exists()) {
          const data = snap.data();
          setFeatureFlags({ showSubscriptionTab: data.showSubscriptionTab !== false }); // default true
        }
      } catch (e) {
        console.error("Error fetching feature flags", e);
      }
    };
    fetchFeatureFlags();
  }, []);
  const navigate = useNavigate();
  const location = useLocation();
  const currentPagePath = location.pathname.substring(1) || 'dashboard';
  const [activeTest, setActiveTest] = useState<string | null>(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authMessage, setAuthMessage] = useState<string | undefined>(undefined);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);
  const [unreadNotifications, setUnreadNotifications] = useState(0);
  const [showWelcomeBonus, setShowWelcomeBonus] = useState<number | null>(null);
  const [joiningContestFromAlert, setJoiningContestFromAlert] = useState<any | null>(null);
  const [headerAction, setHeaderAction] = useState<React.ReactNode>(null);
  const [activeBanner, setActiveBanner] = useState<{ id?: string, imageUrl: string, title: string, message: string, actionUrl?: string, actionLabel?: string } | null>(null);
  const { showToast } = useToast();
  const hasLoadedInitialNotifs = useRef(false);


  const [initialReferralCode, setInitialReferralCode] = useState<string | undefined>(undefined);
  const [inviteChallenge, setInviteChallenge] = useState<string | null>(null);
  const [pendingNavPath, setPendingNavPath] = useState<string | null>(null);

  const handleSafeNavigate = (path: string) => {
    if ((window as any).isBattleActive) {
      setPendingNavPath(path);
    } else {
      navigate(path);
      setIsSidebarOpen(false);
    }
  };

  // Handle Battle Invitation and Referral Links
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const referralCode = params.get('ref');
    if (referralCode) {
      setInitialReferralCode(referralCode.toUpperCase());
      setAuthMessage("You've been invited! Signup now to claim your welcome bonus coins. 🎁");
    }

    // Check for battle invitation in URL path
    const pathParts = location.pathname.split('/');
    if (pathParts[1] === 'battle' && pathParts[2] && !user) {
      const inviteId = pathParts[2];
      setIsAuthModalOpen(true);

      // Fetch inviter name
      const fetchInviter = async () => {
        try {
          const bRef = doc(db, 'battles', inviteId);
          const bSnap = await getDoc(bRef);
          if (bSnap.exists()) {
            const data = bSnap.data();
            const creatorId = data.creatorId;
            const uSnap = await getDoc(doc(db, 'users', creatorId));
            if (uSnap.exists()) {
              const inviterName = uSnap.data().name?.split(' ')[0];
              setInviteChallenge(`⚔️ ${inviterName} has challenged you to a 1v1 Battle! Login to accept.`);
            }
          }
        } catch (e) {
          console.error("Error fetching inviter:", e);
        }
      };
      fetchInviter();
    }
  }, [user?.uid, location.pathname]);

  // Auto-open Auth Modal if user is not logged in and has a join link
  useEffect(() => {
    if (!loading && !user) {
      const params = new URLSearchParams(location.search);
      const joinParam = params.get('join');

      if (joinParam) {
        setAuthMessage("Login or Signup to participate in this test and win rewards!");
        setIsAuthModalOpen(true);
      }
    }
  }, [loading, user, location.search]);

  // Hardware Back Button Handling
  useEffect(() => {
    const backListener = CapacitorApp.addListener('backButton', ({ canGoBack }) => {
      if (canGoBack) {
        window.history.back();
      } else {
        CapacitorApp.exitApp();
      }
    });

    return () => {
      backListener.then(l => l.remove());
    };
  }, []);

  // Handle native push notification clicks
  useEffect(() => {
    const handlePushClick = (e: any) => {
      if (e.detail?.url) {
        // Simple heuristic to remove domain if it's a full URL of the same app
        let path = e.detail.url;
        if (path.startsWith('http')) {
          try {
            const urlObj = new URL(path);
            path = urlObj.pathname + urlObj.search;
          } catch (err) { }
        }
        navigate(path);
      }
    };
    window.addEventListener('push-notification-click', handlePushClick);
    return () => window.removeEventListener('push-notification-click', handlePushClick);
  }, [navigate]);

  // Handle Deep Linking (App Links / Universal Links)
  useEffect(() => {
    const handleAppUrl = (event: any) => {
      try {
        const urlObj = new URL(event.url);
        const path = urlObj.pathname + urlObj.search;
        navigate(path);
      } catch (err) {
        console.error('Error parsing app URL:', err);
      }
    };

    const urlListener = CapacitorApp.addListener('appUrlOpen', handleAppUrl);

    return () => {
      urlListener.then(l => l.remove());
    };
  }, [navigate]);

  // 1. Auth Listener
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (u) => {
      setUser(u);
      if (!u) {
        setProfile(null);
        setLoading(false);
      }
      // Hide Splash Screen once auth is determined
      setTimeout(() => {
        SplashScreen.hide().catch(() => { });
      }, 500);
    });
    return () => unsubscribe();
  }, []);

  const processReferral = async (newUser: FirebaseUser, newName: string, referralCode?: string) => {
    try {
      const configSnap = await getDoc(doc(db, 'configs', 'referral_system'));
      if (!configSnap.exists()) return { initialCoins: 100, referredBy: '' };

      const config = configSnap.data() as ReferralSystemConfig;
      let initialCoins = config.refereeReward !== undefined ? config.refereeReward : 100;
      let referredBy = '';

      if (config.isActive && referralCode && referralCode.trim()) {
        const usersRef = collection(db, 'users');
        const q = query(usersRef, where('referralCode', '==', referralCode.trim().toUpperCase()));
        const querySnapshot = await getDocs(q);

        if (!querySnapshot.empty) {
          const referrerDoc = querySnapshot.docs[0];
          referredBy = referrerDoc.id;

          // Credit referrer
          await updateDoc(doc(db, 'users', referredBy), {
            coins: increment(config.referrerReward || 0),
            withdrawableBalance: increment(config.referrerReward || 0),
            'referralStats.totalReferrals': increment(1),
            'referralStats.totalEarnings': increment(config.referrerReward || 0)
          });

          // Notification for referrer
          await addDoc(collection(db, 'notifications'), {
            userId: referredBy,
            title: 'Referral Bonus! 🎁',
            message: `${newName} joined using your code. You earned ${config.referrerReward} coins!`,
            type: 'referral',
            read: false,
            createdAt: new Date().toISOString()
          });

          // Transaction for referrer
          await addDoc(collection(db, 'transactions'), {
            userId: referredBy,
            amount: config.referrerReward || 0,
            type: 'earn',
            category: 'referral',
            testTitle: `Referral Bonus: ${newName}`,
            timestamp: serverTimestamp()
          });
        }
      }

      // Create transaction for new user (Welcome Bonus)
      await addDoc(collection(db, 'transactions'), {
        userId: newUser.uid,
        amount: initialCoins,
        type: 'earn',
        category: 'bonus',
        testTitle: 'Welcome Bonus',
        timestamp: serverTimestamp()
      });

      return { initialCoins, referredBy };
    } catch (err) {
      console.error("Referral processing error:", err);
      return { initialCoins: 100, referredBy: '' };
    }
  };

  // 2. Profile Listener (Real-time)
  useEffect(() => {
    if (!user?.uid) return;

    const docRef = doc(db, 'users', user.uid);
    const unsubscribe = onSnapshot(docRef, (docSnap) => {
      if (docSnap.exists()) {
        const profileData = docSnap.data() as UserProfile;
        setProfile(profileData);
        setLoading(false);
      } else {
        // If profile doesn't exist, we don't auto-create it here anymore
        // to avoid race conditions and overwriting data.
        // Profiles are now created explicitly in login/signup handlers.
        setLoading(false);
      }
    }, (error) => {
      console.error('Profile listener error:', error);
      setLoading(false);
    });

    // Check admin claim and seed data
    user.getIdTokenResult().then(res => {
      if (res.claims.admin) {
        seedData().catch(console.error);
      }
    });

    return () => unsubscribe();
  }, [user?.uid, initialReferralCode]);

  // Ref for the notifications snapshot to allow re-evaluation
  const currentNotificationsRef = useRef<any[]>([]);

  // Notification permission and unread count listener
  useEffect(() => {
    if (!profile?.userId) return;

    // Request permissions
    requestNotificationPermission(profile.userId, profile.role === 'admin');

    // Listen for unread count - Server-side filter to MINIMIZE READS (Requires Composite Index)
    const cutoffDate = profile.notificationLastClearedAt || (profile.createdAt ? new Date(profile.createdAt) : new Date('2024-01-01'));
    const q = query(
      collection(db, 'notifications'),
      where('userId', 'in', [profile.userId, 'global']),
      where('read', '==', false),
      where('createdAt', '>', cutoffDate),
      limit(100) // Cap reads for safety
    );

    const evaluateUnread = () => {
      const now = new Date();
      const unread = currentNotificationsRef.current.filter(doc => {
        const data = doc.data();
        
        // Scheduling Filter
        if (data.scheduledAt && new Date(data.scheduledAt) > now) return false;

        // Segment Filter
        if (data.userId === 'global') {
          const isPro = profile.subscriptionStatus === 'premium';
          if (data.targetSegment === 'pro' && !isPro) return false;
          if (data.targetSegment === 'free' && isPro) return false;
          
          return !profile.readNotifications?.includes(doc.id);
        }
        return true;
      });
      setUnreadNotifications(unread.length);
    };

    const unsubscribe = onSnapshot(q, (snapshot) => {
      currentNotificationsRef.current = snapshot.docs;
      evaluateUnread();

      // Trigger Live Pop-ups / Banners for NEWly added notifications
      if (hasLoadedInitialNotifs.current) {
        snapshot.docChanges().forEach((change) => {
          if (change.type === 'added') {
            const data = change.doc.data();
            const isGlobal = data.userId === 'global';
            const isReadGlobally = isGlobal && profile.readNotifications?.includes(change.doc.id);

            if (!data.read && !isReadGlobally) {
              // If it's marked as a banner, show the Image Modal
              if (data.showAsBanner && data.imageUrl) {
                // Double check filters for live trigger
                const isPro = profile.subscriptionStatus === 'premium';
                if (data.targetSegment === 'pro' && !isPro) return;
                if (data.targetSegment === 'free' && isPro) return;
                if (data.scheduledAt && new Date(data.scheduledAt) > new Date()) return;

                setActiveBanner({
                  id: change.doc.id,
                  imageUrl: data.imageUrl,
                  title: data.title || 'New Announcement',
                  message: data.message || '',
                  actionUrl: data.actionUrl,
                  actionLabel: data.actionLabel
                });
              } else {
                // Show standard Toast
                const title = data.title || 'New Notification';

                // Skip self-notifications for admin
                if (profile?.role === 'admin' && title === 'Support Team') return;

                // Skip ALL support-related notifications if already on support page
                // This covers both User receiving from Admin and Admin receiving from User
                if (location.pathname === '/support') {
                  const supportKeywords = ['support', 'team', 'ticket', 'message', 'chat'];
                  const lowerTitle = title.toLowerCase();
                  if (supportKeywords.some(kw => lowerTitle.includes(kw))) return;
                }

                // Check filters for live toast
                const isPro = profile.subscriptionStatus === 'premium';
                if (data.targetSegment === 'pro' && !isPro) return;
                if (data.targetSegment === 'free' && isPro) return;
                if (data.scheduledAt && new Date(data.scheduledAt) > new Date()) return;

                showToast(
                  title,
                  data.type as any || 'info',
                  5000,
                  data.actionUrl || data.link,
                  () => {
                    updateDoc(doc(db, 'notifications', change.doc.id), { clicks: increment(1) }).catch(console.error);
                  }
                );
              }
            }
          }
        });
      } else {
        hasLoadedInitialNotifs.current = true;
      }
    }, (error) => {
      console.error("Unread listener error:", error);
    });

    // Trigger re-evaluation every 30 seconds to handle scheduled notifications becoming "due"
    const reEvalInterval = setInterval(evaluateUnread, 30000);

    // Foreground Push Listener
    const unsubscribePush = onMessageListener((payload: any) => {
      if (payload) {
        console.log('[App] Foreground push received:', payload);
        const title = payload.notification?.title || payload.data?.title || 'New Notification';
        const body = payload.notification?.body || payload.data?.body || payload.data?.message;
        const url = payload.data?.actionUrl || payload.data?.link;

        // Skip "Support Team" notifications for admins (prevents self-notifications)
        if (profile?.role === 'admin' && title === 'Support Team') return;

        // Skip ALL support-related notifications if already on support page
        if (location.pathname === '/support') {
          const supportKeywords = ['support', 'team', 'ticket', 'message', 'chat'];
          const lowerTitle = title.toLowerCase();
          if (supportKeywords.some(kw => lowerTitle.includes(kw))) return;
        }

        showToast(
          `${title}: ${body}`,
          'success',
          10000,
          url
        );
      }
    });

    return () => {
      unsubscribe();
      if (reEvalInterval) clearInterval(reEvalInterval);
      if (typeof unsubscribePush === 'function') unsubscribePush();
      hasLoadedInitialNotifs.current = false;
    };
  }, [profile?.userId, profile?.notificationLastClearedAt, profile?.readNotifications, profile?.subscriptionStatus, showToast, location.pathname]);

  const handleGoogleLogin = async () => {
    setIsLoggingIn(true);
    try {
      let u;

      if (Capacitor.isNativePlatform()) {
        try {
          await GoogleAuth.initialize();
        } catch (initErr) {
          console.warn('GoogleAuth already initialized or failed to init:', initErr);
        }
        const googleUser = await GoogleAuth.signIn();
        const credential = GoogleAuthProvider.credential(googleUser.authentication.idToken);
        const result = await signInWithCredential(auth, credential);
        u = result.user;
      } else {
        const result = await signInWithPopup(auth, googleProvider);
        u = result.user;
      }

      if (!u) {
        throw new Error('No user returned from Google authentication');
      }

      // Explicitly check and create profile for Google users
      const docRef = doc(db, 'users', u.uid);
      const docSnap = await getDoc(docRef);

      if (!docSnap.exists()) {
        const { initialCoins, referredBy } = await processReferral(u, u.displayName || 'User', initialReferralCode);

        const newProfile: UserProfile = {
          userId: u.uid,
          name: u.displayName || 'User',
          email: u.email || '',
          profilePhoto: u.photoURL || '',
          coins: initialCoins,
          badges: [],
          subscriptionStatus: 'free',
          createdAt: new Date().toISOString(),
          role: 'user',
          referredBy: referredBy,
          referralCode: await generateUniqueReferralCode(db),
          readNotifications: [],
          referralStats: {
            totalReferrals: 0,
            totalEarnings: 0,
            pendingEarnings: 0
          }
        };
        await setDoc(docRef, newProfile);

        // Welcome Notification
        await addDoc(collection(db, 'notifications'), {
          userId: u.uid,
          title: 'Welcome to Rankearn! 🎓',
          message: `Congratulations! You've received ${initialCoins} coins as a welcome bonus. Start practicing and winning!`,
          type: 'welcome',
          read: false,
          createdAt: new Date().toISOString()
        });
        setShowWelcomeBonus(initialCoins);
      }

      setIsAuthModalOpen(false);
    } catch (error: any) {
      if (error.code !== 'auth/cancelled-popup-request') {
        console.error('Google login failed', error);
        showToast(error.message || 'Google Login failed', 'error');
      }
    } finally {
      setIsLoggingIn(false);
    }
  };

  const handleEmailSignUp = async (name: string, email: string, pass: string, referralCode?: string) => {
    setIsLoggingIn(true);
    isCreatingProfile = true;
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, pass);
      await updateFirebaseProfile(userCredential.user, { displayName: name });

      // Send verification email if globally enabled
      try {
        const authSnap = await getDoc(doc(db, 'configs', 'auth_settings'));
        if (authSnap.exists() && authSnap.data().requireEmailVerification) {
          await sendEmailVerification(userCredential.user);
        }
      } catch (e) {
        console.error("Error sending verification email", e);
      }

      const { initialCoins, referredBy } = await processReferral(userCredential.user, name, referralCode || initialReferralCode);

      const docRef = doc(db, 'users', userCredential.user.uid);
      const newProfile: UserProfile = {
        userId: userCredential.user.uid,
        name: name,
        email: email,
        profilePhoto: '',
        coins: initialCoins,
        badges: [],
        subscriptionStatus: 'free',
        createdAt: new Date().toISOString(),
        role: 'user',
        referredBy: referredBy,
        referralCode: await generateUniqueReferralCode(db),
        readNotifications: [],
        referralStats: {
          totalReferrals: 0,
          totalEarnings: 0,
          pendingEarnings: 0
        }
      };
      await setDoc(docRef, newProfile);

      setProfile(newProfile);

      // Create welcome notification
      try {
        await addDoc(collection(db, 'notifications'), {
          userId: userCredential.user.uid,
          title: 'Welcome to Rankearn! 🎓',
          message: `Congratulations! You've received ${initialCoins} coins as a welcome bonus. Start practicing and winning!`,
          type: 'welcome',
          read: false,
          createdAt: new Date().toISOString()
        });
        setShowWelcomeBonus(initialCoins);
      } catch (nErr) {
        console.error("Welcome notification error:", nErr);
        setShowWelcomeBonus(initialCoins);
      }

      setIsAuthModalOpen(false);
    } catch (error: any) {
      console.error('Email sign up failed', error);
      throw error;
    } finally {
      setIsLoggingIn(false);
      isCreatingProfile = false;
    }
  };

  const handleEmailSignIn = async (email: string, pass: string) => {
    setIsLoggingIn(true);
    try {
      await signInWithEmailAndPassword(auth, email, pass);
      setIsAuthModalOpen(false);
    } catch (error: any) {
      console.error('Email sign in failed', error);
      if (error.code === 'auth/invalid-credential') {
        throw new Error('Invalid email or password');
      }
      throw error;
    } finally {
      setIsLoggingIn(false);
    }
  };

  const handleResetPassword = async (email: string) => {
    setIsLoggingIn(true);
    try {
      await sendPasswordResetEmail(auth, email);
    } catch (error: any) {
      console.error('Reset password failed', error);
      throw error;
    } finally {
      setIsLoggingIn(false);
    }
  };

  const handleLogout = () => {
    signOut(auth);
  };

  const updateProfile = async (updatedData: Partial<UserProfile>) => {
    if (!user || !profile) return;

    const safeUpdates: Partial<UserProfile> = {};

    if (typeof updatedData.name === 'string' && updatedData.name.trim()) {
      safeUpdates.name = updatedData.name.trim();
    }
    if (typeof updatedData.phone === 'string') {
      safeUpdates.phone = updatedData.phone.trim();
    }
    if (typeof updatedData.state === 'string') {
      safeUpdates.state = updatedData.state.trim();
    }
    if (typeof updatedData.examPreparingFor === 'string') {
      safeUpdates.examPreparingFor = updatedData.examPreparingFor.trim();
    }
    if (typeof updatedData.profilePhoto === 'string') {
      safeUpdates.profilePhoto = updatedData.profilePhoto.trim();
    }
    if (updatedData.notificationLastClearedAt) {
      safeUpdates.notificationLastClearedAt = updatedData.notificationLastClearedAt;
    }
    if (Array.isArray(updatedData.readNotifications)) {
      safeUpdates.readNotifications = updatedData.readNotifications;
    }

    if (Object.keys(safeUpdates).length === 0) return;

    try {
      const docRef = doc(db, 'users', user.uid);
      const stateUpdates = { ...safeUpdates };
      // Prevent serverTimestamp sentinel from entering local state and crashing queries
      if (stateUpdates.notificationLastClearedAt) {
        stateUpdates.notificationLastClearedAt = new Date();
      }
      const newProfile = { ...profile, ...stateUpdates };

      // Optimistic UI update to remove 'glitch/delay'
      setProfile(newProfile);

      await setDoc(docRef, safeUpdates, { merge: true });
    } catch (error) {
      console.error('Error updating profile', error);
    }
  };

  const refreshProfile = async () => {
    if (!user) return;
    try {
      const docRef = doc(db, 'users', user.uid);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setProfile(docSnap.data() as UserProfile);
      }
    } catch (error) {
      console.error('Error refreshing profile', error);
    }
  };

  if (loading) {
    return <AppLoadingState fullScreen />;
  }

  const isLegalPage = ['/privacypolicy', '/termsofuse', '/refundpolicy', '/contactus', '/aboutus'].includes(location.pathname);

  if (isLegalPage) {
    return (
      <Suspense fallback={<AppLoadingState fullScreen />}>
        <Routes>
          <Route path="/privacypolicy" element={<PrivacyPolicy />} />
          <Route path="/termsofuse" element={<TermsOfUse />} />
          <Route path="/refundpolicy" element={<RefundPolicy />} />
          <Route path="/contactus" element={<ContactUs />} />
          <Route path="/aboutus" element={<AboutUs />} />
        </Routes>
      </Suspense>
    );
  }

  if (!user) {
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches || (window.navigator as any).standalone === true;
    const isNative = Capacitor.isNativePlatform();

    if (isStandalone || isNative) {
      return (
        <div className="min-h-screen flex items-center justify-center p-4 relative" style={{ background: '#F8FAF9' }}>
          <VisualAtmosphere />
          <div className="relative z-10 w-full flex items-center justify-center">
            <AuthModal
              isOpen={true}
              onClose={() => { }} // User must login in PWA mode
              onLogin={handleEmailSignIn}
              onSignup={handleEmailSignUp}
              onGoogleLogin={handleGoogleLogin}
              onResetPassword={handleResetPassword}
              isLoading={isLoggingIn}
              message={authMessage}
              initialReferralCode={initialReferralCode}
              showCloseButton={false}
            />
          </div>
        </div>
      );
    }

    return (
      <>
        <LandingPage
          onLogin={() => setIsAuthModalOpen(true)}
          isLoggingIn={isLoggingIn}
        />
        <AnimatePresence>
          {(isAuthModalOpen || location.pathname.includes('/battle/')) && (
            <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
              <AuthModal
                isOpen={true}
                onClose={() => {
                  if (location.pathname.includes('/battle/')) {
                    navigate('/'); // Go home if they close the mandatory challenge login
                  }
                  setIsAuthModalOpen(false);
                }}
                onLogin={handleEmailSignIn}
                onSignup={handleEmailSignUp}
                onGoogleLogin={handleGoogleLogin}
                onResetPassword={handleResetPassword}
                isLoading={isLoggingIn}
                message={inviteChallenge || authMessage}
                initialReferralCode={initialReferralCode}
                showCloseButton={!isNative && !isStandalone && !location.pathname.includes('/battle/')}
              />
            </div>
          )}
        </AnimatePresence>
      </>
    );
  }

  // Check for email verification if enabled
  if (authSettings.requireEmailVerification && user && !user.emailVerified) {
    const isGoogleUser = user.providerData.some(p => p.providerId === 'google.com');
    if (!isGoogleUser) {
      return <VerifyEmailScreen userEmail={user.email || ''} />;
    }
  }

  // Check for account suspension
  if (profile && (profile.status === 'suspended' || profile.status === 'banned')) {
    return (
      <SuspendedScreen
        reason={profile.banReason || 'Policy Violation'}
        status={profile.status}
        banUntil={profile.banUntil}
      />
    );
  }

  const navItems = [
    { id: 'dashboard', icon: Home, label: 'Dashboard' },
    { id: 'tests', icon: BookOpen, label: 'Test Series' },
    { id: 'battle', icon: Swords, label: '1v1 Battle' },
    { id: 'earn', icon: IndianRupee, label: 'Earn' },
    { id: 'updates', icon: Bell, label: 'Updates' },
    { id: 'leaderboard', icon: Trophy, label: 'Leaderboard' },
    { id: 'wheel', icon: RotateCcw, label: 'Lucky Wheel' },
    { id: 'refer', icon: Gift, label: 'Refer & Earn' },
    { id: 'wallet', icon: WalletIcon, label: 'Wallet' },
    ...(featureFlags.showSubscriptionTab ? [{ id: 'subscription', icon: CreditCard, label: 'Subscription' }] : []),
    { id: 'profile', icon: User, label: 'Profile' },
  ];

  // Removed old admin link as it's now integrated

  const getCurrentTitle = () => {
    if (currentPagePath === '' || currentPagePath === 'dashboard') return 'Dashboard';
    if (currentPagePath.startsWith('results/')) return 'Result';
    if (currentPagePath.startsWith('review/')) return 'Review';
    if (currentPagePath.startsWith('updates/')) return 'Updates';
    if (currentPagePath === 'fortune-wheel') return 'Fortune Wheel';

    // Return the first part of the path (before any /)
    const basePage = currentPagePath.split('/')[0];
    return basePage.replace(/-/g, ' ');
  };

  return (
    <>
      <VisualAtmosphere />
      <div className="min-h-screen bg-transparent flex overflow-hidden lg:grid lg:grid-cols-[250px_minmax(0,1fr)]" style={{ position: 'relative', zIndex: 1 }}>
        <AnimatePresence>
          {isSidebarOpen && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsSidebarOpen(false)}
              className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-30 lg:hidden"
            />
          )}
        </AnimatePresence>

        {/* Left Sidebar */}
        <aside className={`
        fixed inset-y-0 left-0 z-40 w-[250px] border-r border-slate-200/60 transform transition-transform duration-300 ease-in-out
        lg:translate-x-0 lg:static lg:block lg:w-[250px] lg:h-screen shrink-0
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}
          style={{ background: 'rgba(248,250,249,0.92)', backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)' }}>
          <div className="h-full flex flex-col">
            <div className="h-16 bg-emerald-500 border-b border-emerald-600 px-4 flex items-center justify-between shrink-0">
              <div className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-3 min-w-0">
                  <img src="/logo.png" alt="Rankearn Logo" className="w-10 h-10 rounded-xl shadow-sm" />
                  <div className="min-w-0">
                    <p className="font-bold text-lg tracking-tight text-white leading-none mb-1">Rankearn</p>
                    <p className="text-[10px] font-medium text-emerald-100/80 leading-none">Learning with Earning</p>
                  </div>
                </div>

                <button
                  onClick={() => setIsSidebarOpen(false)}
                  className="lg:hidden p-2 -mr-2 rounded-lg text-emerald-100 hover:text-white hover:bg-white/10 transition-colors"
                >
                  <X size={18} strokeWidth={2.5} />
                </button>
              </div>
            </div>

            <div className="flex-1 flex flex-col p-4 overflow-y-auto no-scrollbar">
              <nav className="flex-1 space-y-2">
                {navItems.map((item) => {
                  const isActive = currentPagePath === item.id || (currentPagePath === '' && item.id === 'dashboard');
                  return (
                    <button
                      key={item.id}
                      onClick={() => handleSafeNavigate(`/${item.id}`)}
                      className={`
                    w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all
                    ${isActive
                          ? 'bg-emerald-50 text-emerald-600 font-semibold'
                          : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'}
                  `}
                    >
                      <item.icon size={20} />
                      {item.label}
                    </button>
                  )
                })}
              </nav>

              <div className="pt-6 border-t border-slate-100">
                {/* Stats - Visible on mobile sidebar, hidden on desktop sidebar if right sidebar exists */}
                <div className="xl:hidden bg-slate-50 rounded-xl p-4 mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2 text-sm font-medium text-slate-600">
                      <Zap size={16} className="text-amber-500" />
                      <span>{profile?.coins || 0} Coins</span>
                      {profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date()) && (
                        <Star size={14} className="text-amber-500 fill-amber-500" />
                      )}
                    </div>
                    <span className="text-[10px] font-bold text-emerald-600 bg-emerald-100 px-1.5 py-0.5 rounded uppercase">Level 4</span>
                  </div>
                  <div className="w-full bg-slate-200 h-1.5 rounded-full overflow-hidden">
                    <div className="bg-amber-500 h-full w-2/3" />
                  </div>
                </div>

                <div className="space-y-1 mb-4">
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 mb-2">Help & Feedback</p>
                  <button
                    onClick={() => handleSafeNavigate('/support')}
                    className={`w-full flex items-center gap-3 px-4 py-2 transition-all text-sm font-medium ${location.pathname === '/support' ? 'text-emerald-600 bg-emerald-50 rounded-xl' : 'text-slate-500 hover:text-emerald-600'}`}
                  >
                    <MessageCircle size={16} />
                    Support Chat
                  </button>
                  <button
                    onClick={() => handleSafeNavigate('/feedback')}
                    className={`w-full flex items-center gap-3 px-4 py-2 transition-all text-sm font-medium ${location.pathname === '/feedback' ? 'text-emerald-600 bg-emerald-50 rounded-xl' : 'text-slate-500 hover:text-emerald-600'}`}
                  >
                    <Star size={16} />
                    Give Feedback
                  </button>
                  <button
                    onClick={() => handleSafeNavigate('/contactus')}
                    className="w-full flex items-center gap-3 px-4 py-2 text-slate-500 hover:text-emerald-600 transition-all text-sm font-medium"
                  >
                    <Mail size={16} />
                    Contact Us
                  </button>
                  <button
                    onClick={() => handleSafeNavigate('/aboutus')}
                    className="w-full flex items-center gap-3 px-4 py-2 text-slate-500 hover:text-emerald-600 transition-all text-sm font-medium"
                  >
                    <Users size={16} />
                    About Us
                  </button>
                  <button
                    onClick={() => handleSafeNavigate('/privacypolicy')}
                    className="w-full flex items-center gap-3 px-4 py-2 text-slate-500 hover:text-emerald-600 transition-all text-sm font-medium"
                  >
                    <ShieldCheck size={16} />
                    Privacy Policy
                  </button>
                  <button
                    onClick={() => handleSafeNavigate('/termsofuse')}
                    className="w-full flex items-center gap-3 px-4 py-2 text-slate-500 hover:text-emerald-600 transition-all text-sm font-medium"
                  >
                    <FileText size={16} />
                    Terms of Use
                  </button>
                </div>

                <button
                  onClick={handleLogout}
                  className="w-full flex items-center gap-3 px-4 py-3 text-slate-500 hover:text-red-600 transition-colors"
                >
                  <LogOut size={20} />
                  Logout
                </button>
              </div>
            </div>
          </div>
        </aside>

        {/* Main Content Wrapper */}
        <div className="flex-1 flex flex-col min-w-0 h-screen overflow-hidden" style={{ background: 'transparent' }}>
          <header className="h-16 bg-emerald-500 border-b border-emerald-600 px-4 md:px-6 flex items-center justify-between shrink-0 z-30">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                className="lg:hidden p-2 -ml-2 text-emerald-100 hover:text-white transition-colors"
              >
                {isSidebarOpen ? <X size={20} strokeWidth={2.5} /> : <Menu size={20} strokeWidth={2.5} />}
              </button>
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1">
                  {headerAction}
                  <h1 className="hidden lg:block text-lg font-semibold text-white capitalize truncate">
                    {getCurrentTitle()}
                  </h1>
                  <h1 className="block lg:hidden text-lg font-black text-white tracking-tight">
                    Rankearn
                  </h1>
                </div>
              </div>
            </div>
            <div className="flex items-center gap-2 md:gap-4">
              <div className="relative">
                <button
                  onClick={() => setIsNotificationOpen(!isNotificationOpen)}
                  className={`p-2 transition-colors relative rounded-lg ${isNotificationOpen ? 'bg-white/10 text-white' : 'text-emerald-100 hover:text-white'}`}
                >
                  <Bell size={22} />
                  {unreadNotifications > 0 && (
                    <span className="absolute top-1 right-1 min-w-[16px] h-4 bg-rose-500 text-white text-[9px] font-black flex items-center justify-center rounded-full border-2 border-emerald-500 px-0.5 shadow-sm">
                      {unreadNotifications > 9 ? '9+' : unreadNotifications}
                    </span>
                  )}
                </button>

                <NotificationCenter
                  profile={profile}
                  isOpen={isNotificationOpen}
                  onClose={() => setIsNotificationOpen(false)}
                  onNavigate={(path) => handleSafeNavigate(path)}
                  onUpdateProfile={updateProfile}
                />
              </div>
              <div className="flex items-center gap-3 pl-2 md:pl-4 border-l border-emerald-600">
                <div className="text-right hidden sm:block">
                  <div className="flex items-center justify-end gap-2">
                    {profile?.role === 'admin' && (
                      <span className="text-[10px] font-bold text-emerald-900 bg-white/90 px-1.5 py-0.5 rounded uppercase tracking-wider">Admin</span>
                    )}
                    <p className="text-sm font-semibold text-white leading-none truncate max-w-[120px]">{profile?.name}</p>
                    {profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date()) && (
                      <div className="bg-white/20 p-0.5 rounded text-amber-300">
                        <Star size={10} fill="currentColor" />
                      </div>
                    )}
                  </div>
                  <p className="text-xs text-emerald-100 mt-1 flex items-center justify-end gap-1">
                    {profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date()) ? (
                      <>
                        <ShieldCheck size={10} /> PRO Member
                      </>
                    ) : 'Free Plan'}
                  </p>
                </div>
                <button
                  onClick={() => handleSafeNavigate('/profile')}
                  className="relative active:scale-95 transition-transform hover:opacity-90"
                >
                  <img
                    src={profile?.profilePhoto || `https://ui-avatars.com/api/?name=${profile?.name}`}
                    alt="Profile"
                    className="w-10 h-10 rounded-full border-2 border-white/20 shadow-sm shrink-0 object-cover"
                  />
                </button>
              </div>
            </div>
          </header>

          <div className="flex-1 flex flex-col overflow-hidden relative">
            <AnimatePresence mode="wait">
              <motion.div
                key={location.pathname}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.15, ease: "easeOut" }}
                className="flex-1 flex flex-col h-full w-full"
                style={{ transform: 'translateZ(0)' }}
              >
                <PullToRefresh onRefresh={async () => { window.location.reload(); }}>
                  <div className="px-4 pt-4 pb-[calc(6rem+env(safe-area-inset-bottom))] md:px-8 md:pt-8 md:pb-8 min-h-full">
                    <Suspense fallback={<AppLoadingState />}>
                      <Routes location={location}>
                        <Route path="/updates" element={<Updates setHeaderAction={setHeaderAction} />} />
                        <Route path="/updates/:slug" element={<Updates setHeaderAction={setHeaderAction} />} />
                        <Route path="/" element={<Dashboard onStartTest={(id) => setActiveTest(id)} onNavigate={(p) => handleSafeNavigate(`/${p}`)} profile={profile} />} />
                        <Route path="/dashboard" element={<Dashboard onStartTest={(id) => setActiveTest(id)} onNavigate={(p) => handleSafeNavigate(`/${p}`)} profile={profile} />} />
                        <Route path="/tests" element={<TestSeries onStartTest={(id) => setActiveTest(id)} onNavigate={(p) => handleSafeNavigate(`/${p}`)} profile={profile} setHeaderAction={setHeaderAction} />} />
                        <Route path="/earn" element={<Earn onStartTest={(id) => setActiveTest(id)} onNavigate={(p) => handleSafeNavigate(`/${p}`)} profile={profile} />} />
                        <Route path="/earn/:tab" element={<Earn onStartTest={(id) => setActiveTest(id)} onNavigate={(p) => handleSafeNavigate(`/${p}`)} profile={profile} />} />
                        <Route path="/leaderboard" element={<Navigate to="/earn/leaderboard" replace />} />
                        <Route path="/battle" element={<BattleMain user={user} profile={profile} />} />
                        <Route path="/battle/:inviteId" element={<BattleMain user={user} profile={profile} />} />
                        <Route path="/subscription" element={<Subscription profile={profile} />} />
                        <Route path="/wallet" element={<Wallet profile={profile} onUpdateProfile={refreshProfile} />} />
                        <Route path="/refer" element={<ReferralSection />} />
                        <Route path="/profile" element={<Profile profile={profile} onLogout={handleLogout} onUpdate={updateProfile} />} />
                        <Route path="/admin" element={<Navigate to="/dashboard" replace />} />
                        <Route path="/wheel" element={<LuckyWheel profile={profile} onCoinsUpdate={(coins) => setProfile(prev => prev ? { ...prev, coins } : null)} />} />
                        <Route path="/results/:attemptId" element={<ResultsPage />} />
                        <Route path="/review/:attemptId" element={<ReviewPage setHeaderAction={setHeaderAction} />} />
                        <Route path="/support" element={<SupportChat profile={profile} />} />
                        <Route path="/feedback" element={<Feedback profile={profile} />} />
                        <Route path="*" element={<Navigate to="/" replace />} />
                      </Routes>
                    </Suspense>
                  </div>
                </PullToRefresh>
              </motion.div>
            </AnimatePresence>
          </div>



          {/* Mobile Bottom Navigation Navbar */}
          <div className="md:hidden fixed bottom-0 left-0 right-0 h-16 border-t border-slate-200/60 z-40 flex items-center justify-around px-2 pb-safe" style={{ background: 'rgba(248,250,249,0.93)', backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)', boxShadow: '0 -4px 24px rgba(0,177,106,0.06)' }}>
            {[
              { id: 'dashboard', icon: Home, label: 'Home' },
              { id: 'tests', icon: BookOpen, label: 'Tests' },
              { id: 'earn', icon: IndianRupee, label: 'Earn' },
              { id: 'wheel', icon: RotateCcw, label: 'Spin' },
              { id: 'wallet', icon: WalletIcon, label: 'Wallet' },
              { id: 'profile', icon: User, label: 'Profile' }
            ].map((item) => {
              const isActive = currentPagePath === item.id || (currentPagePath === '' && item.id === 'dashboard');
              return (
                <button
                  key={item.id}
                  onClick={() => handleSafeNavigate(`/${item.id}`)}
                  className={`flex flex-col items-center justify-center w-16 h-full gap-1 transition-colors
                    ${isActive ? 'text-emerald-600' : 'text-slate-500 hover:text-slate-800'}`}
                >
                  <item.icon size={22} className={isActive ? 'opacity-100' : 'opacity-70'} />
                  <span className={`text-[10px] font-medium leading-none ${isActive ? 'opacity-100' : 'opacity-70'}`}>
                    {item.label}
                  </span>
                </button>
              );
            })}
          </div>

        </div>
      </div>
      <InstallPrompt />

      <AnimatePresence>
        {showWelcomeBonus !== null && (
          <WelcomeBonusModal
            amount={showWelcomeBonus}
            onClose={() => setShowWelcomeBonus(null)}
          />
        )}
        {activeBanner && (
          <ImageBannerModal
            isOpen={!!activeBanner}
            onClose={() => setActiveBanner(null)}
            imageUrl={activeBanner.imageUrl}
            title={activeBanner.title}
            message={activeBanner.message}
            actionUrl={activeBanner.actionUrl}
            actionLabel={activeBanner.actionLabel}
            onActionClick={() => {
              if (activeBanner.id) {
                updateDoc(doc(db, 'notifications', activeBanner.id), { clicks: increment(1) }).catch(console.error);
              }
            }}
          />
        )}
        {/* Global Join Modal for Alert */}
        {joiningContestFromAlert && (
          <ContestJoinModal
            test={joiningContestFromAlert}
            profile={profile}
            onClose={() => setJoiningContestFromAlert(null)}
            onJoinSuccess={() => {
              const testId = joiningContestFromAlert.testId;
              setJoiningContestFromAlert(null);
              setActiveTest(testId);
            }}
          />
        )}
      </AnimatePresence>

      {/* Global Live Test Alert Overlay */}
      <LiveTestAlert
        profile={profile}
        onJoin={(t) => setJoiningContestFromAlert(t)}
      />

      {activeTest && (
        <QuizInterface
          testId={activeTest}
          onExit={() => setActiveTest(null)}
          profile={profile}
        />
      )}

      {/* Global Battle Exit Confirmation Modal */}
      <AnimatePresence>
        {pendingNavPath && (
          <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setPendingNavPath(null)}
              className="absolute inset-0 bg-slate-950/80 backdrop-blur-md"
            />
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="relative w-full max-w-[340px] bg-white rounded-2xl p-8 shadow-2xl text-center overflow-hidden"
            >
              <div className="absolute -top-10 -right-10 w-32 h-32 bg-rose-50 rounded-full blur-3xl opacity-50" />

              <div className="relative z-10">
                <div className="w-20 h-20 bg-rose-50 text-rose-500 rounded-xl flex items-center justify-center mx-auto mb-6">
                  <Swords size={40} className="animate-pulse" />
                </div>
                <h3 className="text-2xl font-black text-slate-900 mb-2 uppercase tracking-tighter italic">Leave Match?</h3>
                <p className="text-[10px] font-black text-rose-500 uppercase tracking-widest mb-6">Match is in progress</p>

                <div className="bg-slate-50 rounded-xl p-4 mb-8 border border-slate-100">
                  <p className="text-slate-500 font-bold text-xs leading-relaxed uppercase tracking-wide">
                    Leaving now will cause you to <span className="text-rose-500">LOSE YOUR COINS</span> and forfeit the battle.
                  </p>
                </div>

                <div className="flex flex-col gap-3">
                  <button
                    onClick={() => setPendingNavPath(null)}
                    className="w-full py-4 bg-emerald-500 text-white font-black rounded-xl shadow-xl shadow-emerald-100 hover:bg-emerald-600 transition-all active:scale-95 uppercase tracking-widest text-xs"
                  >
                    Stay & Win
                  </button>
                  <button
                    onClick={() => {
                      const path = pendingNavPath;
                      setPendingNavPath(null);
                      (window as any).isBattleActive = false;
                      navigate(path);
                      setIsSidebarOpen(false);
                    }}
                    className="w-full py-3 text-slate-400 font-bold text-[9px] uppercase tracking-widest hover:text-rose-500 transition-colors"
                  >
                    I Understand, Leave
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </>
  );
}
