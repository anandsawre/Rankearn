import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, Mail, Lock, User as UserIcon, ArrowRight, Github, Trophy, Check, Eye, EyeOff } from 'lucide-react';
import { capitalizeWords } from '../utils/textFormat';

interface AuthModalProps {
  isOpen: boolean;
  onClose: () => void;
  onLogin: (email: string, pass: string) => Promise<void>;
  onSignup: (name: string, email: string, pass: string, referralCode?: string) => Promise<void>;
  onGoogleLogin: () => Promise<void>;
  onResetPassword?: (email: string) => Promise<void>;
  isLoading?: boolean;
  message?: string;
  initialReferralCode?: string;
  showCloseButton?: boolean;
}

export default function AuthModal({ 
  isOpen, 
  onClose, 
  onLogin, 
  onSignup, 
  onGoogleLogin, 
  isLoading,
  message,
  initialReferralCode,
  onResetPassword,
  showCloseButton = true
}: AuthModalProps) {
  const [isLogin, setIsLogin] = useState(true);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [referralCode, setReferralCode] = useState('');
  const [agreed, setAgreed] = useState(false);
  const [isReset, setIsReset] = useState(false);
  const [resetSent, setResetSent] = useState(false);
  const [error, setError] = useState('');

  // Reset state when modal opens/closes
  React.useEffect(() => {
    if (isOpen) {
      setError('');
      setPassword('');
      setResetSent(false);
      setIsReset(false);
      if (initialReferralCode) {
        setReferralCode(initialReferralCode);
        setIsLogin(false); // Default to signup if referral code is present
      }
    }
  }, [isOpen, isLogin, initialReferralCode]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    // Only require terms for non-reset flows
    if (!isReset && !agreed) {
      setError('Please agree to the Terms and Privacy Policy');
      return;
    }
    
    if (isReset) {
      if (!email) {
        setError('Please enter your email');
        return;
      }
    } else if (!email || !password || (!isLogin && !name)) {
      setError('Please fill in all fields');
      return;
    }

    try {
      if (isReset) {
        if (!email) throw new Error('Please enter your email');
        if (onResetPassword) await onResetPassword(email);
        setResetSent(true);
      } else if (isLogin) {
        await onLogin(email, password);
        onClose();
      } else {
        await onSignup(name, email, password, referralCode);
        onClose();
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed. Please try again.');
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[100] flex items-start sm:items-center justify-center p-4 sm:p-6 overflow-y-auto no-scrollbar">
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={showCloseButton ? onClose : undefined}
            className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm"
          />
          
          <motion.div 
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            transition={{ type: "spring", duration: 0.5, bounce: 0.3 }}
            className="relative w-full max-w-md bg-white rounded-xl shadow-2xl overflow-hidden border border-slate-100 my-auto max-h-[calc(100vh-2rem)] flex flex-col"
          >
            {showCloseButton && (
              <button 
                onClick={onClose}
                className="absolute top-4 right-4 p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors z-20"
              >
                <X size={20} />
              </button>
            )}

            {/* Premium Header */}
            <div className="relative bg-slate-50/50 border-b border-slate-100 overflow-hidden pt-10 pb-6 px-8 text-center">
              {/* Animated Background Decoration */}
              <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none -z-10">
                <div className="absolute -top-10 -right-10 w-40 h-40 bg-emerald-500/5 rounded-full blur-3xl" />
                <div className="absolute top-10 -left-10 w-32 h-32 bg-blue-500/5 rounded-full blur-3xl" />
              </div>

              <motion.div 
                initial={{ scale: 0.5, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                className="inline-flex items-center justify-center w-14 h-14 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-2xl text-white font-black text-2xl mb-4 shadow-lg shadow-emerald-200 ring-4 ring-white"
              >
                R
              </motion.div>

              <motion.h2 
                initial={{ y: 10, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.1 }}
                className="text-2xl font-black text-slate-900 tracking-tight"
              >
                {isLogin ? 'Welcome back' : 'Start your journey'}
              </motion.h2>

              <motion.p 
                initial={{ y: 10, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.2 }}
                className="text-slate-500 mt-1.5 text-xs font-medium"
              >
                {!message && (
                  isReset 
                    ? 'Enter your email to receive a reset link' 
                    : (isLogin ? 'Sign in to access your dashboard' : 'Join thousands of successful aspirants')
                )}
              </motion.p>

              {/* Special Highlight for Share Link Message */}
              {message && (
                <motion.div
                  initial={{ scale: 0.95, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: 0.3, type: "spring" }}
                  className="mt-4 bg-white border border-emerald-100 p-3 rounded-xl flex items-center gap-3 text-left shadow-sm"
                >
                  <div className="w-8 h-8 bg-emerald-500 rounded-lg flex items-center justify-center text-white shrink-0">
                    <Trophy size={16} />
                  </div>
                  <p className="text-xs font-bold text-emerald-800 leading-tight">
                    {message}
                  </p>
                </motion.div>
              )}
            </div>

            <div className="p-8 pt-6 overflow-y-auto flex-1 no-scrollbar">

              {/* Unified Auth Row */}
              <div className="flex p-1 bg-slate-100/80 backdrop-blur-sm rounded-xl mb-6 relative gap-1">
                <motion.div 
                  className="absolute inset-y-1 bg-white rounded-lg shadow-sm"
                  initial={false}
                  animate={{ 
                    left: isReset ? '4px' : (isLogin ? '4px' : 'calc(33.33% + 2px)'),
                    right: isReset ? 'calc(66.66% + 2px)' : (isLogin ? 'calc(66.66% + 2px)' : 'calc(33.33% + 2px)'),
                    width: 'calc(33.33% - 4px)'
                  }}
                  style={{ display: (isReset || isLogin || (!isLogin && !isReset)) && !isReset ? 'block' : (isReset ? 'block' : 'none') }}
                  transition={{ type: "spring", stiffness: 300, damping: 30 }}
                />
                
                {/* Override display:none for isReset case to show on first tab */}
                {isReset && (
                   <div className="absolute inset-y-1 left-[4px] w-[calc(33.33%-4px)] bg-white rounded-lg shadow-sm z-0" />
                )}
                {!isReset && !isLogin && (
                   <motion.div 
                     layoutId="auth-tab"
                     className="absolute inset-y-1 left-[calc(33.33%+2px)] w-[calc(33.33%-4px)] bg-white rounded-lg shadow-sm z-0"
                     transition={{ type: "spring", stiffness: 300, damping: 30 }}
                   />
                )}
                {!isReset && isLogin && (
                   <motion.div 
                     layoutId="auth-tab"
                     className="absolute inset-y-1 left-[4px] w-[calc(33.33%-4px)] bg-white rounded-lg shadow-sm z-0"
                     transition={{ type: "spring", stiffness: 300, damping: 30 }}
                   />
                )}

                <button
                  type="button"
                  onClick={() => { setIsLogin(true); setIsReset(false); setResetSent(false); }}
                  className={`flex-1 py-2.5 text-xs font-black rounded-lg relative z-10 transition-colors ${
                    isLogin || isReset ? 'text-emerald-600' : 'text-slate-500'
                  }`}
                >
                  Sign In
                </button>
                <button
                  type="button"
                  onClick={() => { setIsLogin(false); setIsReset(false); setResetSent(false); }}
                  className={`flex-1 py-2.5 text-xs font-black rounded-lg relative z-10 transition-colors ${
                    !isLogin && !isReset ? 'text-emerald-600' : 'text-slate-500'
                  }`}
                >
                  Sign Up
                </button>
                <button 
                  type="button"
                  onClick={async () => {
                    setError('');
                    if (!agreed) {
                      setError('Please agree to the Terms and Privacy Policy');
                      return;
                    }
                    try {
                      await onGoogleLogin();
                      onClose();
                    } catch (err: any) {
                      setError(err.message || 'Google Auth failed');
                    }
                  }}
                  disabled={isLoading}
                  className="flex-1 py-2.5 flex items-center justify-center rounded-lg relative z-10 hover:bg-white/50 transition-all disabled:opacity-50"
                  title="Sign in with Google"
                >
                  <span className="text-xs font-black text-slate-500">Google</span>
                </button>
              </div>

              {isReset && resetSent ? (
                <motion.div 
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="text-center py-6"
                >
                  <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                    <Mail size={32} />
                  </div>
                  <h3 className="text-xl font-bold text-slate-900 mb-2">Check your email</h3>
                  <p className="text-slate-500 text-sm mb-8">We've sent a password reset link to <br/><span className="font-bold text-slate-900">{email}</span></p>
                  <button 
                    onClick={() => { setIsReset(false); setResetSent(false); }}
                    className="w-full bg-slate-900 text-white rounded-xl py-3.5 font-bold hover:bg-slate-800 transition-all"
                  >
                    Back to Sign In
                  </button>
                </motion.div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-4">
                  <AnimatePresence mode="popLayout">
                    {isReset ? (
                      <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        className="space-y-4"
                      >
                        <div>
                          <div className="relative">
                            <Mail size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-500" />
                            <input 
                              type="email" 
                              value={email}
                              onChange={(e) => setEmail(e.target.value)}
                              placeholder="Email Address"
                              className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 pl-10 pr-4 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium"
                            />
                          </div>
                        </div>
                        <button 
                          type="submit"
                          disabled={isLoading}
                          className="w-full bg-slate-900 text-white rounded-xl py-4 font-black hover:bg-slate-800 transition-all active:scale-[0.98] disabled:opacity-50 mt-4"
                        >
                          {isLoading ? 'Sending...' : 'Send Reset Link'}
                        </button>
                        <button 
                          type="button"
                          onClick={() => setIsReset(false)}
                          className="w-full text-slate-500 py-2 text-sm font-bold hover:text-slate-700 transition-colors"
                        >
                          Back to Sign In
                        </button>
                      </motion.div>
                    ) : (
                      <motion.div 
                        key="auth-content"
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        className="space-y-4"
                      >
                        <AnimatePresence mode="popLayout">
                  {!isLogin && (
                    <div className="space-y-4 mb-4">
                      <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="relative"
                      >
                        <div className="relative">
                          <UserIcon size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-500" />
                          <input 
                            type="text" 
                            value={name}
                            onChange={(e) => setName(capitalizeWords(e.target.value))}
                            placeholder="Full Name"
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 pl-10 pr-4 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium"
                          />
                        </div>
                      </motion.div>

                      <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="relative"
                      >
                        <div className="relative">
                          <Trophy size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-500" />
                          <input 
                            type="text" 
                            value={referralCode}
                            onChange={(e) => setReferralCode(e.target.value.toUpperCase())}
                            placeholder="Referral Code (Optional)"
                            className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 pl-10 pr-4 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium"
                          />
                        </div>
                      </motion.div>
                    </div>
                  )}
                </AnimatePresence>

                <div>
                  <div className="relative">
                    <Mail size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-500" />
                    <input 
                      type="email" 
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Email Address"
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 pl-10 pr-4 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium"
                    />
                  </div>
                </div>

                <div>
                  {isLogin && (
                    <div className="flex items-center justify-end mb-1">
                      <button 
                        type="button" 
                        onClick={() => setIsReset(true)}
                        className="text-xs font-semibold text-emerald-600 hover:text-emerald-700"
                      >
                        Forgot?
                      </button>
                    </div>
                  )}
                  <div className="relative">
                    <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-emerald-500" />
                    <input 
                      type={showPassword ? "text" : "password"} 
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Password"
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl py-2.5 pl-10 pr-12 text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 text-emerald-500 hover:text-emerald-600 hover:bg-emerald-50 rounded-lg transition-all active:scale-95"
                    >
                      {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>
                </div>

                <div 
                  onClick={() => setAgreed(!agreed)}
                  className="flex items-start gap-3 pt-2 cursor-pointer group"
                >
                  <div className={`
                    w-5 h-5 rounded-lg border-2 shrink-0 flex items-center justify-center transition-all duration-200 mt-0.5
                    ${agreed 
                      ? 'bg-emerald-500 border-emerald-500 shadow-lg shadow-emerald-200/50' 
                      : 'bg-slate-50 border-slate-200 group-hover:border-emerald-400 group-hover:bg-white'}
                  `}>
                    {agreed && <Check size={12} className="text-white" strokeWidth={4} />}
                  </div>
                  <p className="text-[11px] md:text-xs text-slate-500 leading-relaxed cursor-pointer select-none">
                    I have read and agree to the <a href="/termsofuse" target="_blank" className="text-emerald-600 font-black hover:underline" onClick={e => e.stopPropagation()}>Terms of Use</a> and <a href="/privacypolicy" target="_blank" className="text-emerald-600 font-black hover:underline" onClick={e => e.stopPropagation()}>Privacy Policy</a>.
                  </p>
                </div>

                {error && (
                  <motion.p 
                    initial={{ opacity: 0, y: -10 }} 
                    animate={{ opacity: 1, y: 0 }} 
                    className="text-rose-500 text-sm font-medium text-center p-2 bg-rose-50 rounded-lg"
                  >
                    {error}
                  </motion.p>
                )}

                <button 
                  type="submit"
                  disabled={isLoading}
                  className="group w-full bg-emerald-600 text-white rounded-xl py-3.5 font-bold hover:bg-emerald-700 transition-all active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center shadow-lg shadow-slate-200 mt-8 overflow-hidden relative text-sm"
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-emerald-500/0 via-white/10 to-emerald-500/0 -translate-x-full group-hover:translate-x-full transition-transform duration-1000" />
                  <span className="relative">
                    {isLoading ? 'Authenticating...' : (isLogin ? 'Sign In Now' : 'Create My Account')}
                  </span>
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </form>
      )}
    </div>
  </motion.div>
</div>
)}
</AnimatePresence>
);
}
