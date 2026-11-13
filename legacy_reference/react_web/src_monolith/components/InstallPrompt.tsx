import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Download, X } from 'lucide-react';

export default function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [showPrompt, setShowPrompt] = useState(false);

  useEffect(() => {
    const handler = (e: any) => {
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault();
      // Stash the event so it can be triggered later.
      setDeferredPrompt(e);
      
      // Show the prompt after a short delay
      setTimeout(() => setShowPrompt(true), 3000);
    };

    window.addEventListener('beforeinstallprompt', handler);

    return () => {
      window.removeEventListener('beforeinstallprompt', handler);
    };
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;

    // Show the install prompt
    deferredPrompt.prompt();

    // Wait for the user to respond to the prompt
    const { outcome } = await deferredPrompt.userChoice;
    console.log(`User response to the install prompt: ${outcome}`);

    // We've used the prompt, and can't use it again, throw it away
    setDeferredPrompt(null);
    setShowPrompt(false);
  };

  const handleDismiss = () => {
    setShowPrompt(false);
  };

  return (
    <AnimatePresence>
      {showPrompt && (
        <motion.div
          initial={{ opacity: 0, y: 50, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.9 }}
          className="fixed bottom-6 left-6 right-6 md:left-auto md:right-8 md:w-96 z-[100]"
        >
          <div className="bg-white rounded-xl shadow-2xl border border-emerald-100 p-5 flex items-center gap-4 relative overflow-hidden">
            {/* Background Decoration */}
            <div className="absolute top-0 right-0 w-24 h-24 bg-emerald-50 rounded-full -mr-12 -mt-12 blur-2xl opacity-50" />
            
            <img
              src="/icon.png"
              alt="Rankearn app icon"
              className="w-14 h-14 rounded-xl shrink-0 shadow-lg shadow-emerald-100"
            />
            
            <div className="flex-1 min-w-0">
              <h4 className="font-bold text-slate-900 text-sm md:text-base">Install Rankearn App</h4>
              <p className="text-slate-500 text-xs md:text-sm line-clamp-1">Get the best experience on your phone!</p>
              
              <div className="flex gap-3 mt-3">
                <button
                  onClick={handleInstall}
                  className="bg-emerald-500 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-emerald-600 transition-all flex items-center gap-2 shadow-md shadow-emerald-100 active:scale-95"
                >
                  <Download size={14} />
                  Install Now
                </button>
                <button
                  onClick={handleDismiss}
                  className="text-slate-400 hover:text-slate-600 px-2 py-2 text-xs font-bold transition-colors active:scale-95"
                >
                  Maybe Later
                </button>
              </div>
            </div>

            <button 
              onClick={handleDismiss}
              className="absolute top-3 right-3 p-1 text-slate-300 hover:text-slate-500 transition-colors active:scale-95"
            >
              <X size={16} />
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
