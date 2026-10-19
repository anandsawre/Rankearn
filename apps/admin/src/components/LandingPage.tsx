import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { 
  Shield, Zap, Trophy, BookOpen, ArrowRight, CheckCircle2, 
  Play, Star, TrendingUp, Sparkles, Target, 
  ChevronRight, ArrowUpRight, Wallet, Swords, Gift, Users, Coins, Lock,
  Facebook, Twitter, Instagram, Youtube, Linkedin, Send, Phone, MessageCircle,
  Smartphone, Download
} from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../firebase';
import WhatsAppIcon from './icons/WhatsAppIcon';
import VisualAtmosphere from './VisualAtmosphere';

interface LandingPageProps {
  onLogin: () => void;
  isLoggingIn?: boolean;
}

const RANK_FEATURES = [
  { 
    icon: Shield, 
    title: "Real Exam Experience", 
    desc: "Simulate the exact UI and pressure of actual competitive exams like SSC CGL, IBPS, and UPSC.",
    color: "from-blue-500 to-indigo-600",
    bgLight: "bg-blue-50",
    textLight: "text-blue-600"
  },
  { 
    icon: Zap, 
    title: "Smart Analytics Dashboard", 
    desc: "Track your progress with detailed subject-wise analysis, percentile scores, and time-management insights.",
    color: "from-emerald-400 to-emerald-600",
    bgLight: "bg-emerald-50",
    textLight: "text-emerald-600"
  },
  { 
    icon: BookOpen, 
    title: "Massive Test Library", 
    desc: "Access 10,000+ full-length mocks, sectional quizzes, and previous year papers.",
    color: "from-purple-500 to-purple-600",
    bgLight: "bg-purple-50",
    textLight: "text-purple-600"
  },
  {
    icon: Target,
    title: "Precision Targeting",
    desc: "Pinpoint accuracy in question selection based on the latest exam patterns and syllabus.",
    color: "from-rose-500 to-rose-600",
    bgLight: "bg-rose-50",
    textLight: "text-rose-600"
  }
];

const EARN_FEATURES = [
  { 
    icon: Swords, 
    title: "Live Contests", 
    desc: "Compete with thousands of aspirants nationwide and win real cash prize pools.",
    color: "from-amber-500 to-amber-600",
    bgLight: "bg-amber-50",
    textLight: "text-amber-600"
  },
  { 
    icon: Wallet, 
    title: "Smart Wallet", 
    desc: "Instant top-ups and lightning-fast withdrawals directly to your UPI or Bank Account.",
    color: "from-emerald-500 to-emerald-600",
    bgLight: "bg-emerald-50",
    textLight: "text-emerald-600"
  },
  { 
    icon: Gift, 
    title: "Daily Rewards", 
    desc: "Spin the Lucky Wheel, maintain daily streaks, and claim surprise bonus coins.",
    color: "from-pink-500 to-pink-600",
    bgLight: "bg-pink-50",
    textLight: "text-pink-600"
  },
  {
    icon: Users,
    title: "Refer & Earn",
    desc: "Invite friends to Rankearn and earn lucrative coin bonuses for every successful sign-up.",
    color: "from-blue-500 to-blue-600",
    bgLight: "bg-blue-50",
    textLight: "text-blue-600"
  }
];

export default function LandingPage({ onLogin, isLoggingIn }: LandingPageProps) {
  const [scrolled, setScrolled] = useState(false);
  const [socialLinks, setSocialLinks] = useState<any>(null);
  const [apkUrl, setApkUrl] = useState<string>('');
  const [showInstructionsModal, setShowInstructionsModal] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    const fetchSocialLinks = async () => {
      try {
        const docRef = doc(db, 'configs', 'social_links');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setSocialLinks(docSnap.data());
        }
      } catch (error) {
        console.error("Error fetching social links:", error);
      }
    };
    const fetchApkUrl = async () => {
      try {
        const docRef = doc(db, 'configs', 'app_settings');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setApkUrl(docSnap.data().apkUrl || '');
        }
      } catch (error) {
        console.error("Error fetching APK URL:", error);
      }
    };
    fetchSocialLinks();
    fetchApkUrl();
  }, []);

  return (
    <div className="min-h-screen font-sans selection:bg-emerald-500/20 selection:text-emerald-900 relative" style={{ background: '#F8FAF9' }}>
      <VisualAtmosphere fixed={false} />
      <Helmet>
        <title>Rankearn - Master Your Exams & Earn Rewards</title>
        <meta name="description" content="Prepare for BPSC, SSC CGL, IBPS, and UPSC with highly targeted mock tests. Compete in live contests, climb the leaderboard, and earn real cash rewards." />
        <meta name="keywords" content="rankearn, mock tests, earn money, bpsc preparation, ssc mock tests, ibps, expert generated tests, exam analytics, live contests" />
      </Helmet>

      {/* Dynamic Navbar */}
      <nav className={`fixed top-0 inset-x-0 z-50 transition-all duration-300 bg-emerald-600 py-5 ${
        scrolled ? 'shadow-md py-4' : ''
      }`}>
        <div className="max-w-7xl mx-auto px-4 md:px-6 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <img src="/logo.png" alt="Rankearn Logo" className="w-8 h-8 rounded-lg shadow-sm" />
            <span className="font-extrabold text-xl tracking-tight text-white">Rankearn</span>
          </div>

          <div className="hidden md:flex items-center gap-8 text-emerald-50 font-medium">
            <a href="#how-it-works" className="hover:text-white transition-colors">How it works</a>
            <a href="#features" className="hover:text-white transition-colors">Features</a>
            <a href="#earn" className="hover:text-white transition-colors">Contests & Earn</a>
          </div>

          <div className="flex items-center gap-3">
            <button 
              onClick={onLogin}
              disabled={isLoggingIn}
              className="hidden md:block text-emerald-50 hover:text-white font-semibold transition-colors disabled:opacity-50 px-4 py-2"
            >
              Log in
            </button>
            {apkUrl && (
              <button 
                onClick={() => setShowInstructionsModal(true)}
                className="hidden md:flex items-center gap-1.5 bg-emerald-700/50 hover:bg-emerald-700 text-white px-4 py-2 rounded-lg font-bold transition-all text-sm border border-emerald-500/30"
              >
                <Download size={14} />
                Download App
              </button>
            )}
            <button 
              onClick={onLogin}
              disabled={isLoggingIn}
              className="bg-white text-emerald-700 px-4 py-1.5 md:px-5 md:py-2 rounded-lg font-bold hover:bg-slate-50 transition-all shadow-md hover:shadow-lg hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none text-sm"
            >
              {isLoggingIn ? 'Connecting...' : 'Get Started'}
            </button>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-32 pb-16 md:pt-40 md:pb-32 overflow-hidden" style={{ background: 'transparent' }}>

        <div className="max-w-7xl mx-auto px-6 relative z-10 grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
            className="text-center lg:text-left pt-10 lg:pt-0"
          >
            <motion.div 
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.2 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-amber-50 border border-amber-100 text-amber-600 text-sm font-bold mb-8 mx-auto xl:mx-0"
            >
              <Trophy size={16} />
              <span>India's 1st Learning with Earning Platform</span>
            </motion.div>
            
            <h1 className="text-5xl sm:text-6xl lg:text-7xl font-extrabold text-slate-900 leading-[1.1] mb-6 tracking-tight">
              Master your exams.<br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-500 to-emerald-700">Earn while you learn.</span>
            </h1>
            
            <p className="text-lg md:text-xl text-slate-600 mb-10 leading-relaxed max-w-xl mx-auto lg:mx-0 font-medium">
              Elevate your scores with realistic exam simulations, compete in live nationwide contests, and win real cash rewards for your academic excellence.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <button 
                onClick={onLogin}
                disabled={isLoggingIn}
                className="bg-emerald-500 text-white px-8 py-4 rounded-xl font-bold text-lg hover:bg-emerald-600 transition-all flex items-center justify-center gap-3 disabled:opacity-50 group shadow-xl shadow-emerald-500/20 hover:shadow-emerald-500/40 hover:-translate-y-1"
              >
                {isLoggingIn ? 'Preparing Workspace...' : 'Start Playing Now'}
                <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
              </button>
              {apkUrl && (
                <button 
                  onClick={() => setShowInstructionsModal(true)}
                  className="bg-white text-slate-800 border border-slate-200 px-8 py-4 rounded-xl font-bold text-lg hover:bg-slate-50 transition-all flex items-center justify-center gap-3 shadow-lg hover:-translate-y-1"
                >
                  <Smartphone size={20} className="text-emerald-500" />
                  Download Android App
                </button>
              )}
            </div>

            <div className="mt-12 pt-8 border-t border-slate-100 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 sm:gap-6">
              <div className="flex -space-x-3">
                {[1, 2, 3, 4].map(i => (
                  <img 
                    key={i}
                    src={`https://i.pravatar.cc/100?img=${i + 30}`} 
                    className="w-10 h-10 rounded-full border-2 border-white shadow-sm"
                    alt="User"
                  />
                ))}
              </div>
              <div className="text-center sm:text-left">
                <div className="flex items-center justify-center sm:justify-start gap-1 mb-0.5">
                  {[1,2,3,4,5].map(star => <Star key={star} size={14} className="fill-amber-400 text-amber-400" />)}
                </div>
                <p className="text-slate-600 text-sm font-medium">Trusted by <span className="text-slate-900 font-bold">thousands of</span> serious aspirants</p>
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 1, delay: 0.2, ease: "easeOut" }}
            className="relative h-[500px] lg:h-[600px] hidden md:flex items-center justify-center w-full"
          >
            <div className="absolute inset-0 bg-gradient-to-tr from-emerald-100 to-amber-50 rounded-full blur-3xl opacity-60 mix-blend-multiply" />

            {/* Main Mockup Card */}
            <motion.div 
              animate={{ y: [-5, 5, -5] }}
              transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
              className="relative z-20 w-full max-w-sm bg-white/80 backdrop-blur-xl border border-white/50 rounded-xl p-6 shadow-2xl xl:ml-auto"
            >
              <div className="flex items-center justify-between mb-8 pb-4 border-b border-slate-100">
                <div>
                  <h3 className="text-slate-900 font-bold text-lg leading-tight">Mock Analysis</h3>
                  <p className="text-slate-500 text-sm font-medium">SSC CGL Tier 1 • Shift 2</p>
                </div>
                <div className="w-10 h-10 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500 shadow-inner">
                  <TrendingUp size={20} />
                </div>
              </div>

              <div className="space-y-5">
                {[
                  { text: 'Score', val: '145.5/200', pct: 85, color: 'bg-emerald-500' },
                  { text: 'Accuracy', val: '92%', pct: 92, color: 'bg-blue-500' },
                  { text: 'Percentile', val: '98.5', pct: 98, color: 'bg-indigo-500' }
                ].map((stat, i) => (
                  <div key={i} className="bg-slate-50 rounded-xl p-4 border border-slate-100">
                    <div className="flex justify-between text-sm mb-3">
                      <span className="text-slate-600 font-medium">{stat.text}</span>
                      <span className="text-slate-900 font-bold">{stat.val}</span>
                    </div>
                    <div className="h-1.5 w-full bg-slate-200 rounded-full overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: `${stat.pct}%` }}
                        transition={{ duration: 1, delay: 0.5 + (i * 0.2) }}
                        className={`h-full ${stat.color} rounded-full`} 
                      />
                    </div>
                  </div>
                ))}
              </div>

              <button className="w-full mt-6 bg-slate-900 hover:bg-slate-800 text-white py-3.5 rounded-xl font-semibold transition-colors flex items-center justify-center gap-2 shadow-lg shadow-slate-900/20 group">
                View Deep Insights <ArrowUpRight size={18} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
              </button>
            </motion.div>

            {/* Floating Elements Around */}
            <motion.div 
              animate={{ y: [0, -15, 0], rotate: [0, 2, 0] }}
              transition={{ duration: 6, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
              className="absolute -right-4 top-10 z-30 bg-white p-4 rounded-xl shadow-xl border border-slate-100 flex items-center gap-3"
            >
              <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center text-amber-600">
                <Coins size={20} />
              </div>
              <div>
                <p className="text-slate-900 font-bold text-sm">+500 Coins Won</p>
                <p className="text-slate-500 font-medium text-xs">Mega Contest</p>
              </div>
            </motion.div>

            <motion.div 
              animate={{ y: [0, 10, 0], x: [0, -5, 0] }}
              transition={{ duration: 7, repeat: Infinity, ease: "easeInOut", delay: 1 }}
              className="absolute -left-6 bottom-24 z-30 bg-white p-4 rounded-xl shadow-xl flex items-center gap-3 border border-slate-100"
            >
              <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center text-emerald-600">
                <CheckCircle2 size={20} />
              </div>
              <div>
                <p className="text-slate-900 font-bold text-sm">Target Met</p>
                <p className="text-slate-500 font-medium text-xs">Quant speed improved</p>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </section>

      {/* 
      <section className="bg-slate-900 py-12 relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-10 mix-blend-overlay" />
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8 relative z-10">
          {[
            { value: "50M+", label: "Questions Attempted", color: "text-blue-400" },
            { value: "₹10L+", label: "Rewards Distributed", color: "text-amber-400" },
            { value: "Top 1%", label: "Selection Rate", color: "text-emerald-400" },
            { value: "24/7", label: "Live Contests", color: "text-rose-400" }
          ].map((stat, i) => (
            <div key={i} className="text-center px-4">
              <h4 className={`text-4xl md:text-5xl font-black mb-2 ${stat.color}`}>{stat.value}</h4>
              <p className="text-slate-300 font-semibold text-sm tracking-wide uppercase">{stat.label}</p>
            </div>
          ))}
        </div>
      </section>
      */}

      {/* How it Works Flow */}
      <section id="how-it-works" className="py-24 relative" style={{ background: 'rgba(248,250,249,0.60)' }}>
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-sm font-bold tracking-widest text-emerald-600 uppercase mb-3">The Process</h2>
            <h3 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-6 leading-tight">
              3 steps to your dream career.
            </h3>
          </div>

          <div className="grid md:grid-cols-3 gap-8 relative">
            {/* Connecting lines for desktop */}
            <div className="hidden md:block absolute top-12 left-1/6 right-1/6 h-0.5 bg-slate-100 z-0">
              <div className="h-full bg-emerald-500 w-full opacity-20"></div>
            </div>

            {[
              { step: "01", title: "Practice & Improve", desc: "Take highly targeted mock tests curated based on the latest exam patterns and your weak areas.", icon: BookOpen, color: "emerald" },
              { step: "02", title: "Compete Live", desc: "Join weekend Mega Contests and compete against thousands of serious aspirants.", icon: Swords, color: "blue" },
              { step: "03", title: "Earn & Withdraw", desc: "Top the leaderboard to win coins. Instantly withdraw your winnings to UPI or Bank.", icon: Wallet, color: "amber" }
            ].map((item, i) => (
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ duration: 0.5, delay: i * 0.2 }}
                key={i} 
                className="relative z-10 flex flex-col items-center text-center"
              >
                <div className={`w-24 h-24 rounded-full bg-${item.color}-50 flex items-center justify-center text-${item.color}-500 mb-6 border-8 border-white shadow-sm`}>
                  <item.icon size={40} />
                </div>
                <div className="bg-slate-50 text-slate-400 font-black text-xl mb-3 px-3 py-1 rounded-lg">Step {item.step}</div>
                <h4 className="text-2xl font-bold text-slate-900 mb-3">{item.title}</h4>
                <p className="text-slate-600 leading-relaxed">{item.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid - Academic */}
      <section id="features" className="py-24 relative border-t border-emerald-100/60" style={{ background: 'rgba(255,255,255,0.50)' }}>
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <h2 className="text-sm font-bold tracking-widest text-emerald-600 uppercase mb-3">The Rank Advantage</h2>
            <h3 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-6 leading-tight">
              An unfair advantage for the <span className="text-emerald-600">ambitious.</span>
            </h3>
            <p className="text-lg text-slate-600 leading-relaxed font-medium">
              We've deconstructed the learning process and built tools that simulate real exams while adapting to your unique learning curve.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6 lg:gap-8">
            {RANK_FEATURES.map((feature, i) => (
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                key={i} 
                onClick={onLogin}
                className="group p-8 md:p-10 rounded-xl border border-slate-200/80 hover:border-emerald-500/40 hover:shadow-2xl hover:shadow-emerald-500/8 transition-all duration-300 cursor-pointer" style={{ background: 'rgba(255,255,255,0.82)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
              >
                <div className="flex gap-6 md:gap-8 h-full">
                  <div className={`w-14 h-14 shrink-0 rounded-xl ${feature.bgLight} ${feature.textLight} flex items-center justify-center shadow-sm group-hover:scale-110 group-hover:bg-gradient-to-br group-hover:${feature.color} group-hover:text-white transition-all duration-300 mt-1`}>
                    <feature.icon size={28} />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-2xl font-bold text-slate-900 mb-3 leading-tight">{feature.title}</h4>
                    <p className="text-slate-600 leading-relaxed text-lg mb-6">{feature.desc}</p>
                    
                    <div className="flex items-center text-slate-900 font-bold group-hover:text-emerald-600 transition-colors cursor-pointer">
                      Explore feature <ChevronRight size={20} className="ml-1 opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Gamification Grid - Earn Ecosystem */}
      <section id="earn" className="py-24 relative border-t border-emerald-100/60" style={{ background: 'rgba(248,255,252,0.55)' }}>
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <h2 className="text-sm font-bold tracking-widest text-amber-600 uppercase mb-3">The Earn Ecosystem</h2>
            <h3 className="text-4xl md:text-5xl font-extrabold text-slate-900 mb-6 leading-tight">
              Your hard work <span className="text-amber-500">pays off.</span> Literally.
            </h3>
            <p className="text-lg text-slate-600 leading-relaxed font-medium">
              Turn your study hours into tangible rewards. Rankearn's unique gamified ecosystem ensures you stay motivated every single day.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6 lg:gap-8">
            {EARN_FEATURES.map((feature, i) => (
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                key={i} 
                onClick={onLogin}
                className="group p-8 md:p-10 rounded-xl border border-slate-200/80 hover:border-amber-500/40 hover:shadow-2xl hover:shadow-amber-500/8 transition-all duration-300 cursor-pointer" style={{ background: 'rgba(255,255,255,0.80)', backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)' }}
              >
                <div className="flex gap-6 md:gap-8 h-full">
                  <div className={`w-14 h-14 shrink-0 rounded-xl ${feature.bgLight} ${feature.textLight} flex items-center justify-center shadow-sm group-hover:scale-110 group-hover:bg-gradient-to-br group-hover:${feature.color} group-hover:text-white transition-all duration-300 mt-1`}>
                    <feature.icon size={28} />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-2xl font-bold text-slate-900 mb-3 leading-tight">{feature.title}</h4>
                    <p className="text-slate-600 leading-relaxed text-lg mb-6">{feature.desc}</p>
                    
                    <div className="flex items-center text-slate-900 font-bold group-hover:text-amber-600 transition-colors cursor-pointer">
                      Start Earning <ChevronRight size={20} className="ml-1 opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Daily Rewards Teaser - The Lucky Wheel */}
      <section className="pt-12 pb-24 bg-amber-50/50 border-t border-slate-200 relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-5 mix-blend-overlay pointer-events-none" />
        
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto mb-4 md:mb-6">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-amber-100 border border-amber-200 text-amber-700 text-xs font-bold mb-2 mx-auto">
              <Gift size={16} />
              <span>Daily Rewards</span>
            </div>
            <h3 className="text-3xl md:text-4xl font-extrabold text-slate-900 mb-2 leading-tight">
              Test your luck.<br /> <span className="text-amber-500">Win huge jackpots.</span>
            </h3>
            <p className="text-sm md:text-base text-slate-600 leading-relaxed font-medium mb-0">
              Log in every day to claim your free spin. Win coins, contest passes, and exclusive power-ups.
            </p>
          </div>

          <div className="relative max-w-4xl mx-auto -mt-4 md:-mt-8">
            {/* High-Fidelity App Wheel Replica */}
            <div className="absolute inset-0 flex items-center justify-center opacity-40 pointer-events-none scale-[1.1] md:scale-110">
              <div className="relative w-[320px] h-[320px] md:w-[500px] md:h-[500px]">
                {/* Golden Rim with Bulbs */}
                <div className="absolute inset-[-15px] md:inset-[-25px] rounded-full bg-gradient-to-br from-slate-100 via-white to-slate-200 border-[8px] border-white shadow-2xl flex items-center justify-center">
                    {[...Array(12)].map((_, i) => (
                        <div 
                          key={i} 
                          className="absolute w-2 h-2 md:w-3 md:h-3 bg-amber-400 rounded-full shadow-[0_0_10px_#fbbf24]" 
                          style={{ transform: `rotate(${i * 30}deg) translateY(-170px) md:translateY(-260px)` }} 
                        />
                    ))}
                </div>

                {/* The Wheel with Slices */}
                <div className="w-full h-full rounded-full border-[10px] border-slate-900 shadow-2xl relative overflow-hidden bg-slate-900 animate-[spin_40s_linear_infinite]">
                  <svg viewBox="0 0 100 100" className="w-full h-full rotate-[-90deg]">
                    {[
                      { c: '#f59e0b', v: '50' }, { c: '#10b981', v: '10' }, 
                      { c: '#6366f1', v: '100' }, { c: '#f43f5e', v: '20' },
                      { c: '#8b5cf6', v: '500' }, { c: '#f59e0b', v: '10' },
                      { c: '#10b981', v: '200' }, { c: '#6366f1', v: '50' }
                    ].map((slice, i) => {
                      const angle = 360 / 8;
                      const startAngle = i * angle;
                      const endAngle = (i + 1) * angle;
                      const x1 = 50 + 50 * Math.cos((Math.PI * startAngle) / 180);
                      const y1 = 50 + 50 * Math.sin((Math.PI * startAngle) / 180);
                      const x2 = 50 + 50 * Math.cos((Math.PI * endAngle) / 180);
                      const y2 = 50 + 50 * Math.sin((Math.PI * endAngle) / 180);
                      return (
                        <g key={i}>
                          <path d={`M 50 50 L ${x1} ${y1} A 50 50 0 0 1 ${x2} ${y2} Z`} fill={slice.c} stroke="white" strokeWidth="0.5" />
                          <text x="75" y="50" fill="white" fontSize="5" fontWeight="900" textAnchor="middle" transform={`rotate(${startAngle + angle/2}, 50, 50)`}>{slice.v}</text>
                        </g>
                      );
                    })}
                  </svg>
                  
                  {/* Center Hub */}
                  <div className="absolute inset-0 m-auto w-16 h-16 md:w-24 md:h-24 bg-gradient-to-br from-slate-700 to-slate-900 rounded-full border-[5px] border-slate-600 shadow-xl flex items-center justify-center">
                    <div className="w-10 h-10 md:w-14 md:h-14 bg-gradient-to-tr from-amber-400 to-amber-500 rounded-full flex items-center justify-center shadow-lg">
                        <Star className="text-white" size={24} fill="white" />
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Locked Content Card - Positioned even lower for maximum wheel visibility */}
            <div className="relative z-40 flex flex-col items-center justify-center pt-[420px] md:pt-[400px] pb-12 md:pb-20 px-6">
              <div className="bg-white p-8 md:p-10 rounded-3xl text-center shadow-[0_20px_50px_rgba(0,0,0,0.15)] border border-amber-100 max-w-md relative z-10">
                 <div className="w-20 h-20 bg-gradient-to-br from-amber-50 to-amber-100 rounded-full flex items-center justify-center text-amber-600 mx-auto mb-8 shadow-inner border border-amber-200/50">
                    <Lock size={38} className="drop-shadow-sm" />
                 </div>
                 <h4 className="text-3xl font-black text-slate-900 mb-4 tracking-tight">Wheel is Locked</h4>
                 <p className="text-slate-600 mb-10 font-semibold text-lg leading-relaxed">
                   Create an account or log in to claim your first free spin today and start winning.
                 </p>
                 <button 
                   onClick={onLogin}
                   disabled={isLoggingIn}
                   className="w-full bg-gradient-to-r from-amber-500 to-amber-600 text-white px-8 py-5 rounded-2xl font-bold text-xl hover:from-amber-400 hover:to-amber-500 transition-all shadow-xl shadow-amber-500/20 hover:shadow-amber-500/40 hover:-translate-y-1 active:scale-95 disabled:opacity-50"
                 >
                   {isLoggingIn ? 'Logging in...' : 'Login to Spin Now'}
                 </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Minimal CTA Section */}
      <section className="py-24 bg-slate-900 border-t border-slate-800 relative z-10">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-emerald-500 text-white rounded-full mb-8 shadow-inner shadow-emerald-700/50">
            <Trophy size={40} />
          </div>
          <h2 className="text-4xl md:text-5xl font-extrabold text-white mb-6">
            Ready to secure your Dream Job?
          </h2>
          <p className="text-xl text-slate-400 mb-10 max-w-2xl mx-auto font-medium">
            Join the ranks of top achievers. Create your free account today, take your first mock test, and claim your sign-up bonus.
          </p>
          <button 
            onClick={onLogin}
            disabled={isLoggingIn}
            className="bg-emerald-500 text-white px-10 py-5 rounded-xl font-bold text-xl hover:bg-emerald-400 transition-all shadow-xl hover:shadow-2xl hover:shadow-emerald-500/20 hover:-translate-y-1 transform disabled:opacity-50 inline-flex items-center gap-3"
          >
            {isLoggingIn ? 'Authenticating...' : 'Start Prepared To Win'}
            <ArrowUpRight size={24} />
          </button>
        </div>
      </section>

      {/* Minimal Footer */}
      <footer className="border-t border-emerald-100/70 pt-16 pb-8 relative z-10" style={{ background: 'rgba(248,250,249,0.88)', backdropFilter: 'blur(10px)', WebkitBackdropFilter: 'blur(10px)' }}>
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-8 mb-12">
            <div className="flex flex-col items-center md:items-start gap-4">
              <div className="flex items-center gap-2">
                <img src="/logo.png" alt="Rankearn Logo" className="w-10 h-10 rounded-xl shadow-sm" />
                <span className="font-extrabold text-2xl tracking-tight text-slate-900">Rankearn</span>
              </div>
              <p className="text-slate-500 font-medium text-sm text-center md:text-left max-w-xs">
                Empowering millions of aspirants to achieve their dream careers through comprehensive practice and real cash rewards.
              </p>
            </div>

            {socialLinks && (
              <div className="flex items-center gap-4">
                {socialLinks.whatsapp && (
                  <a href={socialLinks.whatsapp} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-green-500 hover:bg-green-500 hover:text-white hover:border-green-500 transition-all hover:-translate-y-1 shadow-sm">
                    <WhatsAppIcon size={18} />
                  </a>
                )}
                {socialLinks.youtube && (
                  <a href={socialLinks.youtube} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-red-500 hover:bg-red-500 hover:text-white hover:border-red-500 transition-all hover:-translate-y-1 shadow-sm">
                    <Youtube size={18} />
                  </a>
                )}
                {socialLinks.twitter && (
                  <a href={socialLinks.twitter} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-900 hover:bg-slate-900 hover:text-white hover:border-slate-900 transition-all hover:-translate-y-1 shadow-sm">
                    <Twitter size={18} />
                  </a>
                )}
                {socialLinks.telegram && (
                  <a href={socialLinks.telegram} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-blue-500 hover:bg-blue-500 hover:text-white hover:border-blue-500 transition-all hover:-translate-y-1 shadow-sm">
                    <Send size={18} />
                  </a>
                )}
                {socialLinks.facebook && (
                  <a href={socialLinks.facebook} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-blue-600 hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all hover:-translate-y-1 shadow-sm">
                    <Facebook size={18} />
                  </a>
                )}
                {socialLinks.instagram && (
                  <a href={socialLinks.instagram} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-pink-600 hover:bg-pink-600 hover:text-white hover:border-pink-600 transition-all hover:-translate-y-1 shadow-sm">
                    <Instagram size={18} />
                  </a>
                )}
                {socialLinks.linkedin && (
                  <a href={socialLinks.linkedin} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-slate-50 border border-slate-200 flex items-center justify-center text-blue-700 hover:bg-blue-700 hover:text-white hover:border-blue-700 transition-all hover:-translate-y-1 shadow-sm">
                    <Linkedin size={18} />
                  </a>
                )}
              </div>
            )}
          </div>

          <div className="flex flex-col md:flex-row items-center justify-between gap-6 pt-8 border-t border-slate-100">
            <div className="flex flex-wrap items-center justify-center gap-x-8 gap-y-3 text-slate-500 font-medium text-sm">
              <a href="/aboutus" className="hover:text-emerald-600 transition-colors">About Us</a>
              <a href="/privacypolicy" className="hover:text-emerald-600 transition-colors">Privacy Policy</a>
              <a href="/termsofuse" className="hover:text-emerald-600 transition-colors">Terms of Use</a>
              <a href="/refundpolicy" className="hover:text-emerald-600 transition-colors">Refund Policy</a>
              <a href="/contactus" className="hover:text-emerald-600 transition-colors">Contact Us</a>
            </div>
            <div className="text-slate-400 font-medium text-sm text-center md:text-right">
              © {new Date().getFullYear()} Rankearn Education. All rights reserved.
            </div>
          </div>
        </div>
      </footer>

      {/* Installation Instructions Modal */}
      {showInstructionsModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Backdrop */}
          <div 
            className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm"
            onClick={() => setShowInstructionsModal(false)}
          />
          
          {/* Modal Container */}
          <div className="relative bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl border border-slate-100 z-10">
            {/* Header with gradient */}
            <div className="bg-gradient-to-r from-emerald-500 to-teal-600 px-6 py-7 text-white relative">
              <button 
                onClick={() => setShowInstructionsModal(false)}
                className="absolute top-4 right-4 w-8 h-8 rounded-full bg-black/10 hover:bg-black/20 flex items-center justify-center text-white transition-colors"
              >
                ✕
              </button>
              <div className="flex items-center gap-3 mb-2">
                <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center">
                  <Smartphone size={20} />
                </div>
                <h3 className="text-xl font-bold">Install on Android</h3>
              </div>
              <p className="text-emerald-100 text-xs">Follow these simple steps to install the Rankearn APK</p>
            </div>

            {/* Steps Content */}
            <div className="p-6 space-y-6">
              <div className="space-y-4">
                {/* Step 1 */}
                <div className="flex gap-4">
                  <div className="w-8 h-8 shrink-0 rounded-full bg-emerald-50 text-emerald-600 font-bold flex items-center justify-center text-sm border border-emerald-100">
                    1
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-800 text-sm">Download the APK file</h4>
                    <p className="text-xs text-slate-500 mt-0.5">
                      Click the download button below. If your browser shows a warning like "File might be harmful", tap <strong>Download anyway</strong>.
                    </p>
                  </div>
                </div>

                {/* Step 2 */}
                <div className="flex gap-4">
                  <div className="w-8 h-8 shrink-0 rounded-full bg-emerald-50 text-emerald-600 font-bold flex items-center justify-center text-sm border border-emerald-100">
                    2
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-800 text-sm">Allow Unknown Sources</h4>
                    <p className="text-xs text-slate-500 mt-0.5">
                      If prompted during open, allow installation of unknown apps for your browser (Chrome) in your settings.
                    </p>
                  </div>
                </div>

                {/* Step 3 */}
                <div className="flex gap-4">
                  <div className="w-8 h-8 shrink-0 rounded-full bg-emerald-50 text-emerald-600 font-bold flex items-center justify-center text-sm border border-emerald-100">
                    3
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-800 text-sm">Open & Install</h4>
                    <p className="text-xs text-slate-500 mt-0.5">
                      Open the downloaded file from your browser's Downloads or Notification bar and click <strong>Install</strong>.
                    </p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="pt-2 flex flex-col gap-3">
                <a
                  href={apkUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="w-full bg-emerald-500 hover:bg-emerald-600 text-white text-center py-3.5 rounded-xl font-bold transition-all shadow-lg shadow-emerald-500/20 hover:shadow-emerald-500/40 hover:-translate-y-0.5 flex items-center justify-center gap-2 text-sm"
                >
                  <Download size={16} />
                  Download APK Now
                </a>
                <button
                  onClick={() => setShowInstructionsModal(false)}
                  className="w-full text-slate-400 hover:text-slate-600 py-1 text-center text-sm font-semibold transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
