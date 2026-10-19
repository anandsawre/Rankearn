import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Mail, RefreshCw, LogOut, CheckCircle2, ArrowRight, ExternalLink, Send, ShieldCheck } from 'lucide-react';
import { auth } from '../firebase';
import { signOut, sendEmailVerification } from 'firebase/auth';
import { useToast } from './Toast';

interface VerifyEmailScreenProps {
  userEmail: string;
}

const VerifyEmailScreen: React.FC<VerifyEmailScreenProps> = ({ userEmail }) => {
  const [isResending, setIsResending] = useState(false);
  const [countdown, setCountdown] = useState(0);
  const { showToast } = useToast();

  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (countdown > 0) {
      timer = setTimeout(() => setCountdown(countdown - 1), 1000);
    }
    return () => clearTimeout(timer);
  }, [countdown]);

  const handleResend = async () => {
    if (countdown > 0 || !auth.currentUser) return;
    
    setIsResending(true);
    try {
      await sendEmailVerification(auth.currentUser);
      showToast('Verification email sent! Check your inbox.', 'success');
      setCountdown(60);
    } catch (error: any) {
      console.error('Error resending verification:', error);
      showToast(error.message || 'Failed to send email.', 'error');
    } finally {
      setIsResending(false);
    }
  };

  const handleRefresh = () => {
    window.location.reload();
  };

  const handleLogout = () => {
    signOut(auth);
    window.location.href = '/';
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-start sm:justify-center p-4 sm:p-6 font-sans overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="max-w-md w-full bg-white rounded-2xl shadow-2xl shadow-emerald-900/10 overflow-hidden border border-emerald-100 my-2 sm:my-4"
      >
        {/* Header Section - Premium Emerald Theme */}
        <div className="bg-emerald-600 p-6 sm:p-8 text-center relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl" />
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-emerald-500/30 rounded-full -ml-8 -mb-8 blur-xl" />
          
          <motion.div
            initial={{ scale: 0.5, rotate: -20 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ type: 'spring', damping: 10 }}
            className="w-14 h-14 sm:w-16 sm:h-16 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center mx-auto mb-3 sm:mb-4 border border-white/30 shadow-2xl"
          >
            <Mail size={28} className="text-white sm:w-8 sm:h-8" />
          </motion.div>
          
          <h1 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tighter mb-1">
            Verify Your Identity
          </h1>
          <p className="text-emerald-100 text-[9px] font-bold uppercase tracking-[0.2em]">Secure Access Required</p>
        </div>

        {/* Content Section */}
        <div className="p-5 sm:p-8 space-y-5 sm:space-y-6">
          <div className="space-y-4">
            <div className="bg-slate-50 rounded-2xl p-4 sm:p-5 border border-slate-100 shadow-inner relative overflow-hidden group">
              <div className="absolute top-0 left-0 w-1 h-full bg-emerald-500" />
              <div className="relative">
                <div className="flex items-center gap-2 mb-2">
                  <CheckCircle2 size={10} className="text-emerald-500" />
                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block">Sent To Email</label>
                </div>
                <p className="text-slate-800 font-bold text-sm sm:text-base leading-snug px-1 truncate">
                  {userEmail}
                </p>
              </div>
            </div>
          </div>

          <div className="text-center">
            <p className="text-[11px] sm:text-xs text-slate-500 font-medium leading-relaxed px-4">
              We've sent a secure link to your inbox. Please click the link to confirm your ownership and unlock full access to Rankearn.
            </p>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-1 gap-2.5 pt-1 sm:pt-2">
            <button
              onClick={handleRefresh}
              className="w-full py-3.5 sm:py-4 bg-slate-900 text-white font-black rounded-xl hover:bg-slate-800 transition-all flex items-center justify-center gap-3 shadow-xl active:scale-[0.98] text-[11px] sm:text-xs uppercase tracking-widest"
            >
              <RefreshCw size={16} />
              I've Verified
            </button>
            
            <button
              onClick={handleResend}
              disabled={countdown > 0 || isResending}
              className="w-full py-3.5 sm:py-4 bg-white text-slate-600 font-black rounded-xl border-2 border-slate-100 hover:bg-slate-50 transition-all flex items-center justify-center gap-3 active:scale-[0.98] text-[11px] sm:text-xs uppercase tracking-widest disabled:opacity-50"
            >
              {isResending ? <RefreshCw className="animate-spin" size={16} /> : <Send size={16} />}
              {countdown > 0 ? `Resend in ${countdown}s` : 'Resend Link'}
            </button>
            
            <button
              onClick={handleLogout}
              className="w-full py-2.5 text-slate-400 font-bold hover:text-rose-500 transition-all flex items-center justify-center gap-2 active:scale-[0.95] text-[10px] uppercase tracking-widest"
            >
              <LogOut size={14} />
              Sign out
            </button>
          </div>

          <div className="pt-4 border-t border-slate-50 flex items-center justify-center gap-6">
            <div className="flex items-center gap-1.5 text-[9px] font-bold text-slate-400 uppercase tracking-widest">
              <ShieldCheck size={12} className="text-emerald-500" />
              Verified Access Only
            </div>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

export default VerifyEmailScreen;
