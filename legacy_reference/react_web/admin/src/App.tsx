import React, { useEffect, useState } from 'react';
import { auth, db, googleProvider, UserProfile } from '@rankearn/shared';
import { onAuthStateChanged, signInWithEmailAndPassword, signInWithPopup, signOut, User as FirebaseUser } from 'firebase/auth';
import { doc, getDoc, updateDoc, setDoc } from 'firebase/firestore';
import AdminPanel from './components/AdminPanel';
import { ToastProvider, useToast } from './components/Toast';
import {
  LayoutDashboard, BookOpen, Users, Layout, BrainCircuit, IndianRupee, Trophy,
  ImageIcon, Bell, RotateCcw, BarChart3, Gift, FileText, MessageCircle, Star,
  Swords, Radio, Settings, ShieldCheck, LogIn, Loader2, UserCheck, ShieldAlert,
  LogOut, Menu, X
} from 'lucide-react';

type AdminTab = 'overview' | 'tests' | 'users' | 'patterns' | 'ai-creator' | 'finance' | 'contests' | 'settings' | 'banners' | 'notifications' | 'wheel' | 'leaderboard' | 'referrals' | 'posts' | 'support' | 'feedback' | 'battle_qs' | 'polls';

const adminNavItems = [
  { id: 'overview', label: 'Overview', icon: LayoutDashboard, tabId: 'overview' },
  { id: 'tests', label: 'Test Series', icon: BookOpen, tabId: 'tests' },
  { id: 'users', label: 'Users', icon: Users, tabId: 'users' },
  { id: 'patterns', label: 'Exam Patterns', icon: Layout, tabId: 'patterns' },
  { id: 'ai-creator', label: 'AI Test Creator', icon: BrainCircuit, tabId: 'ai-creator' },
  { id: 'finance', label: 'Finance', icon: IndianRupee, tabId: 'finance' },
  { id: 'contests', label: 'Contests', icon: Trophy, tabId: 'contests' },
  { id: 'banners', label: 'Banners', icon: ImageIcon, tabId: 'banners' },
  { id: 'notifications', label: 'Notifications', icon: Bell, tabId: 'notifications' },
  { id: 'wheel', label: 'Lucky Wheel', icon: RotateCcw, tabId: 'wheel' },
  { id: 'leaderboard', label: 'Leaderboard', icon: BarChart3, tabId: 'leaderboard' },
  { id: 'referrals', label: 'Referrals', icon: Gift, tabId: 'referrals' },
  { id: 'posts', label: 'Updates', icon: FileText, tabId: 'posts' },
  { id: 'support', label: 'Support Chat', icon: MessageCircle, tabId: 'support' },
  { id: 'feedback', label: 'Give Feedback', icon: Star, tabId: 'feedback' },
  { id: 'battle_qs', label: 'Battle Questions', icon: Swords, tabId: 'battle_qs' },
  { id: 'polls', label: 'Community Polls', icon: Radio, tabId: 'polls' },
  { id: 'settings', label: 'Settings', icon: Settings, tabId: 'settings' }
];

function AdminAppContent() {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loginError, setLoginError] = useState('');
  const [adminActiveTab, setAdminActiveTab] = useState<AdminTab>('overview');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      setUser(currentUser);
      if (currentUser) {
        try {
          const userRef = doc(db, 'users', currentUser.uid);
          const userDoc = await getDoc(userRef);
          if (userDoc.exists()) {
            const data = userDoc.data() as UserProfile;
            setProfile(data);
          } else {
            const newProfile: Partial<UserProfile> = {
              userId: currentUser.uid,
              name: currentUser.displayName || currentUser.email?.split('@')[0] || 'Admin',
              email: currentUser.email || '',
              role: 'admin',
              coins: 0,
              badges: [],
              subscriptionStatus: 'free',
              createdAt: new Date().toISOString()
            };
            await setDoc(userRef, newProfile);
            setProfile(newProfile as UserProfile);
          }
        } catch (err) {
          console.error('Error fetching admin profile:', err);
        }
      } else {
        setProfile(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleMakeAdmin = async () => {
    if (!user) return;
    try {
      await updateDoc(doc(db, 'users', user.uid), { role: 'admin' });
      setProfile((prev) => prev ? { ...prev, role: 'admin' } : null);
      showToast('Account upgraded to Admin!', 'success');
    } catch (err: any) {
      showToast(err.message || 'Failed to update role', 'error');
    }
  };

  const handleEmailLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError('');
    try {
      await signInWithEmailAndPassword(auth, email, password);
      showToast('Logged in to Admin Portal!', 'success');
    } catch (err: any) {
      setLoginError(err.message || 'Failed to login');
    }
  };

  const handleGoogleLogin = async () => {
    setLoginError('');
    try {
      await signInWithPopup(auth, googleProvider);
      showToast('Logged in to Admin Portal!', 'success');
    } catch (err: any) {
      setLoginError(err.message || 'Google Login failed');
    }
  };

  const handleLogout = async () => {
    await signOut(auth);
    showToast('Logged out', 'info');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F8FAF9] flex flex-col items-center justify-center">
        <div className="w-20 h-20 bg-emerald-500 rounded-full flex items-center justify-center mb-4">
          <span className="text-white text-4xl font-black">R</span>
        </div>
        <Loader2 size={32} className="animate-spin text-emerald-500 mb-2" />
        <p className="text-slate-500 font-bold text-xs uppercase tracking-widest">Loading...</p>
      </div>
    );
  }

  // Auth Screen
  if (!user) {
    return (
      <div className="min-h-screen bg-[#F8FAF9] flex items-center justify-center p-4">
        <div className="w-full max-w-md bg-white border border-slate-200/80 rounded-2xl p-8 shadow-xl">
          <div className="flex flex-col items-center mb-8">
            <div className="w-16 h-16 bg-emerald-500 text-white rounded-full flex items-center justify-center mb-4 shadow-lg shadow-emerald-500/20 font-black text-3xl">
              R
            </div>
            <h1 className="text-2xl font-black text-slate-900 tracking-tight">Rankearn Admin</h1>
            <p className="text-slate-500 text-xs mt-1">Management Portal Login</p>
          </div>

          <form onSubmit={handleEmailLogin} className="space-y-4">
            {loginError && (
              <div className="p-3 bg-rose-50 border border-rose-200 text-rose-600 text-xs rounded-xl text-center font-bold">
                {loginError}
              </div>
            )}

            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Admin Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="admin@rankearn.com"
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-1">Password</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder="••••••••"
                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-900 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all"
              />
            </div>

            <button
              type="submit"
              className="w-full py-3.5 bg-emerald-500 hover:bg-emerald-600 text-white font-black rounded-xl transition-all shadow-lg shadow-emerald-500/25 flex items-center justify-center gap-2 uppercase tracking-wider text-xs active:scale-95"
            >
              <LogIn size={18} />
              Sign In to Admin
            </button>

            <div className="relative my-6 text-center">
              <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-slate-200" /></div>
              <span className="relative px-3 bg-white text-slate-400 text-xs font-medium">OR</span>
            </div>

            <button
              type="button"
              onClick={handleGoogleLogin}
              className="w-full py-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl transition-colors flex items-center justify-center gap-2 text-xs uppercase tracking-wider"
            >
              Sign In with Google
            </button>
          </form>
        </div>
      </div>
    );
  }

  // Upgrade Role Screen if logged in as user
  if (profile && profile.role !== 'admin') {
    return (
      <div className="min-h-screen bg-[#F8FAF9] flex items-center justify-center p-4">
        <div className="w-full max-w-md bg-white border border-slate-200/80 rounded-2xl p-8 shadow-xl text-center">
          <div className="w-16 h-16 bg-amber-50 text-amber-500 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-amber-200">
            <ShieldAlert size={32} />
          </div>
          <h2 className="text-xl font-black text-slate-900 mb-2">Admin Privilege Needed</h2>
          <p className="text-slate-600 text-xs mb-6 leading-relaxed">
            Account <span className="text-emerald-600 font-bold">{user.email}</span> is currently registered with role <span className="text-amber-600 font-bold">'{profile.role || 'user'}'</span>.
          </p>

          <div className="space-y-3">
            <button
              onClick={handleMakeAdmin}
              className="w-full py-3.5 bg-emerald-500 hover:bg-emerald-600 text-white font-black rounded-xl transition-all flex items-center justify-center gap-2 uppercase tracking-wider text-xs shadow-lg shadow-emerald-500/25 active:scale-95"
            >
              <UserCheck size={18} />
              Set Admin Role & Enter Dashboard
            </button>

            <button
              onClick={handleLogout}
              className="w-full py-3 bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold rounded-xl text-xs uppercase tracking-wider transition-colors"
            >
              Sign Out & Switch Account
            </button>
          </div>
        </div>
      </div>
    );
  }

  const currentTabLabel = adminNavItems.find(i => i.tabId === adminActiveTab)?.label || 'Overview';

  return (
    <div className="h-screen w-screen overflow-hidden flex flex-col bg-[#F8FAF9] font-sans">
      {/* FULL-WIDTH FIXED TOP HEADER BAR */}
      <header className="h-16 bg-emerald-500 border-b border-emerald-600 px-4 md:px-6 flex items-center justify-between shrink-0 z-50 shadow-md text-white w-full sticky top-0">
        {/* Left Section: Mobile Menu + Logo Box + Rankearn Title + Subtitle + Divider + Page Title */}
        <div className="flex items-center">
          <button
            onClick={() => setIsSidebarOpen(!isSidebarOpen)}
            className="lg:hidden p-2 -ml-2 text-emerald-100 hover:text-white transition-colors mr-2"
          >
            {isSidebarOpen ? <X size={20} strokeWidth={2.5} /> : <Menu size={20} strokeWidth={2.5} />}
          </button>

          {/* Logo & Brand Details */}
          <div className="flex items-center gap-3 pr-5 border-r border-white/25">
            <div className="w-10 h-10 bg-emerald-800/40 border border-white/20 rounded-xl flex items-center justify-center shadow-inner overflow-hidden shrink-0">
              <span className="text-white font-black text-xl">R</span>
            </div>
            <div>
              <h1 className="font-bold text-white text-base leading-tight tracking-tight">Rankearn</h1>
              <p className="text-[10px] text-emerald-100 leading-none mt-0.5 font-medium tracking-wide">Learning with Earning</p>
            </div>
          </div>

          {/* Active Tab Page Title */}
          <div className="pl-5 flex items-center">
            <h1 className="text-lg font-bold text-white capitalize truncate">
              {currentTabLabel}
            </h1>
          </div>
        </div>

        {/* Right Section: Bell + Divider + ADMIN Badge + User Name + Subtitle + Profile Photo */}
        <div className="flex items-center gap-2 md:gap-4">
          <div className="relative">
            <button className="p-2 text-emerald-100 hover:text-white transition-colors relative rounded-lg">
              <Bell size={22} />
            </button>
          </div>

          <div className="flex items-center gap-3 pl-3 md:pl-4 border-l border-white/25">
            <div className="text-right hidden sm:block">
              <div className="flex items-center justify-end gap-2">
                <span className="text-[10px] font-extrabold text-emerald-900 bg-white px-1.5 py-0.5 rounded uppercase tracking-wider shadow-sm">
                  ADMIN
                </span>
                <p className="text-sm font-bold text-white leading-none truncate max-w-[140px]">
                  {profile?.name || 'Anand Sawre'}
                </p>
              </div>
              <p className="text-xs text-emerald-100 mt-1 font-medium">
                {profile?.subscriptionStatus === 'premium' ? 'PRO Member' : 'Free Plan'}
              </p>
            </div>

            <button onClick={handleLogout} title="Click to Logout" className="relative active:scale-95 transition-transform hover:opacity-90">
              <img
                src={profile?.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(profile?.name || 'Anand Sawre')}&background=00b16a&color=fff`}
                alt="Profile"
                className="w-10 h-10 rounded-full border-2 border-white/30 shadow-sm shrink-0 object-cover"
              />
            </button>
          </div>
        </div>
      </header>

      {/* BODY AREA BELOW HEADER */}
      <div className="flex-1 flex h-[calc(100vh-4rem)] min-h-0 relative overflow-hidden">
        {/* Mobile Sidebar Overlay */}
        {isSidebarOpen && (
          <div
            onClick={() => setIsSidebarOpen(false)}
            className="lg:hidden fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-40"
          />
        )}

        {/* Left Sidebar Navigation */}
        <aside className={`
          fixed lg:static top-0 bottom-0 left-0 z-40
          w-64 bg-white border-r border-slate-100 flex flex-col h-full
          transition-transform duration-300 ease-in-out shrink-0
          ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}>
          <div className="flex-1 px-4 py-4 overflow-y-auto no-scrollbar flex flex-col justify-between">
            <div>
              <nav className="space-y-1">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-4 mb-2">Management</p>
                {adminNavItems.map((item) => {
                  const isActive = adminActiveTab === item.tabId;
                  const Icon = item.icon;

                  return (
                    <button
                      key={item.id}
                      onClick={() => {
                        setAdminActiveTab(item.tabId as any);
                        setIsSidebarOpen(false);
                      }}
                      className={`
                        w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all text-sm font-medium text-left
                        ${isActive
                          ? 'bg-emerald-50 text-emerald-600 font-semibold shadow-sm'
                          : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'}
                      `}
                    >
                      <Icon size={20} className={isActive ? 'text-emerald-600' : 'text-slate-500'} />
                      <span className="truncate">{item.label}</span>
                    </button>
                  );
                })}
              </nav>
            </div>

            <div className="pt-6 border-t border-slate-100">
              <button
                onClick={handleLogout}
                className="w-full flex items-center gap-3 px-4 py-3 text-slate-500 hover:text-red-600 transition-colors text-sm font-medium"
              >
                <LogOut size={20} />
                Logout
              </button>
            </div>
          </div>
        </aside>

        {/* Main Panel View Area (Only Content Area Scrolls) */}
        <main className="flex-1 flex flex-col min-w-0 h-full overflow-y-auto bg-[#F8FAF9] p-4 md:p-8">
          <AdminPanel
            activeTab={adminActiveTab}
            onTabChange={setAdminActiveTab}
          />
        </main>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <ToastProvider>
      <AdminAppContent />
    </ToastProvider>
  );
}
