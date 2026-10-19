import React from 'react';
import { motion } from 'motion/react';
import { ShieldAlert, LogOut, MessageSquare, ExternalLink, ShieldX } from 'lucide-react';
import { auth } from '../firebase';
import { signOut } from 'firebase/auth';

interface SuspendedScreenProps {
  reason: string;
  status: 'suspended' | 'banned';
  banUntil?: string;
}

const SuspendedScreen: React.FC<SuspendedScreenProps> = ({ reason, status, banUntil }) => {
  const handleLogout = () => {
    signOut(auth);
    window.location.href = '/';
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-GB', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-start sm:justify-center p-4 sm:p-6 font-sans overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="max-w-md w-full bg-white rounded-2xl shadow-2xl shadow-rose-900/10 overflow-hidden border border-rose-100 my-2 sm:my-4"
      >
        {/* Header Section - Compact on Desktop */}
        <div className="bg-rose-600 p-6 sm:p-6 text-center relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 blur-2xl" />
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-rose-500/30 rounded-full -ml-8 -mb-8 blur-xl" />
          
          <motion.div
            initial={{ scale: 0.5, rotate: -20 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ type: 'spring', damping: 10 }}
            className="w-14 h-14 sm:w-16 sm:h-16 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center mx-auto mb-3 sm:mb-4 border border-white/30 shadow-2xl"
          >
            <ShieldX size={28} className="text-white sm:w-8 sm:h-8" />
          </motion.div>
          
          <h1 className="text-xl sm:text-2xl font-black text-white uppercase tracking-tighter mb-1">
            Access {status === 'banned' ? 'Revoked' : 'Suspended'}
          </h1>
          <p className="text-rose-100 text-[9px] font-bold uppercase tracking-[0.2em]">Safety & Policy Enforcement</p>
        </div>

        {/* Content Section - Tighter spacing */}
        <div className="p-5 sm:p-6 space-y-4 sm:space-y-5">
          <div className="space-y-3">
            <div className="bg-slate-50 rounded-2xl p-4 sm:p-5 border border-slate-100 shadow-inner relative overflow-hidden group">
              <div className="absolute top-0 left-0 w-1 h-full bg-rose-500" />
              <div className="relative">
                <div className="flex items-center gap-2 mb-2">
                  <ShieldAlert size={10} className="text-slate-400" />
                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block">Violation Detail</label>
                </div>
                <p className="text-slate-800 font-bold text-sm sm:text-base leading-snug px-1">
                  {reason || 'No specific reason provided'}
                </p>
              </div>
            </div>

            {status === 'suspended' && banUntil && (
              <div className="bg-amber-50 rounded-xl p-3 sm:p-4 border border-amber-100 flex items-center gap-3">
                <div className="w-8 h-8 sm:w-10 sm:h-10 bg-amber-500 text-white rounded-lg flex items-center justify-center shadow-lg shadow-amber-200 shrink-0">
                  <ShieldAlert size={18} className="sm:w-5 sm:h-5" />
                </div>
                <div>
                  <label className="text-[8px] font-black text-amber-600 uppercase tracking-widest block">Restored On</label>
                  <p className="text-amber-900 font-black text-[11px] sm:text-xs">{formatDate(banUntil)}</p>
                </div>
              </div>
            )}
          </div>

          <div className="text-center">
            <p className="text-[11px] sm:text-xs text-slate-500 font-medium leading-relaxed px-2">
              Our system detected activity violating our <span className="text-slate-900 font-bold underline cursor-pointer">Terms</span>. To maintain fairness, access has been restricted.
            </p>
          </div>

          {/* Action Buttons - More compact */}
          <div className="grid grid-cols-1 gap-2.5 pt-1 sm:pt-2">
            <button
              onClick={() => window.open('mailto:support@rankearn.in', '_blank')}
              className="w-full py-3 sm:py-3.5 bg-slate-900 text-white font-black rounded-xl hover:bg-slate-800 transition-all flex items-center justify-center gap-3 shadow-xl active:scale-[0.98] text-[11px] sm:text-xs uppercase tracking-widest"
            >
              <MessageSquare size={16} />
              Appeal Suspension
            </button>
            
            <button
              onClick={handleLogout}
              className="w-full py-3 sm:py-3.5 bg-white text-slate-600 font-black rounded-xl border-2 border-slate-100 hover:bg-slate-50 transition-all flex items-center justify-center gap-3 active:scale-[0.98] text-[11px] sm:text-xs uppercase tracking-widest"
            >
              <LogOut size={16} />
              Logout from Device
            </button>
          </div>

          <div className="pt-4 border-t border-slate-50 flex items-center justify-center gap-6">
            <a href="/terms" className="text-[9px] font-bold text-slate-400 hover:text-slate-600 uppercase tracking-widest flex items-center gap-1.5 transition-colors">
              Terms <ExternalLink size={10} />
            </a>
            <a href="/privacy" className="text-[9px] font-bold text-slate-400 hover:text-slate-600 uppercase tracking-widest flex items-center gap-1.5 transition-colors">
              Privacy <ExternalLink size={10} />
            </a>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

export default SuspendedScreen;
