import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { X, ExternalLink, Sparkles, ArrowRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface ImageBannerModalProps {
  isOpen: boolean;
  onClose: () => void;
  imageUrl: string;
  title: string;
  message: string;
  actionUrl?: string;
  actionLabel?: string;
  onActionClick?: () => void;
}

const ImageBannerModal: React.FC<ImageBannerModalProps> = ({
  isOpen,
  onClose,
  imageUrl,
  title,
  message,
  actionUrl,
  actionLabel,
  onActionClick
}) => {
  const navigate = useNavigate();

  if (!isOpen) return null;

  const handleAction = () => {
    if (onActionClick) onActionClick();
    if (actionUrl) {
      if (actionUrl.startsWith('http')) {
        window.open(actionUrl, '_blank');
      } else {
        navigate(actionUrl);
      }
    }
    onClose();
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-[10000] flex items-center justify-center p-4 sm:p-6">
        {/* Backdrop */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-slate-950/40 backdrop-blur-md"
        />

        {/* Modal Container */}
        <motion.div
          initial={{ scale: 0.9, opacity: 0, y: 40 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          exit={{ scale: 0.9, opacity: 0, y: 40 }}
          transition={{ type: 'spring', damping: 25, stiffness: 300 }}
          className="relative w-full max-w-[550px] bg-white rounded-2xl overflow-hidden shadow-[0_32px_64px_-12px_rgba(0,0,0,0.2)] border border-white flex flex-col max-h-[95vh] overflow-y-auto no-scrollbar"
        >
          {/* Header Image Section */}
          <div className="relative w-full bg-slate-50 border-b border-slate-100">
            <img 
              src={imageUrl} 
              alt={title} 
              className="w-full h-auto block"
            />
            
            {/* Global Close Button */}
            <button
              onClick={onClose}
              className="absolute top-3 right-3 w-8 h-8 rounded-full bg-black/40 hover:bg-black/60 backdrop-blur-md border border-white/20 flex items-center justify-center text-white transition-all active:scale-90 z-20"
            >
              <X size={16} />
            </button>
          </div>

          {/* Content Section */}
          <div className="relative flex-1 p-6 sm:p-8 flex flex-col justify-center">

            <div className="text-center md:text-left mb-8">
              <motion.h3 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="text-2xl sm:text-3xl font-black text-slate-900 leading-tight mb-4"
              >
                {title}
              </motion.h3>
              
              <motion.p 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="text-slate-500 text-sm sm:text-base leading-relaxed font-medium whitespace-pre-wrap max-h-[150px] overflow-y-auto no-scrollbar"
                style={{ wordBreak: 'normal', overflowWrap: 'break-word' }}
              >
                {message}
              </motion.p>
            </div>

            {/* Actions */}
            <div className="flex flex-col gap-3">
              {actionUrl ? (
                <button
                  onClick={handleAction}
                  className="group relative w-full h-[56px] inline-flex items-center justify-center gap-3 rounded-xl bg-slate-900 hover:bg-emerald-600 text-white font-black text-lg transition-all shadow-[0_20px_40px_-12px_rgba(0,0,0,0.2)] active:scale-[0.98]"
                >
                  <span>{actionLabel || 'Open Now'}</span>
                  <ArrowRight size={22} className="group-hover:translate-x-1 transition-transform" />
                </button>
              ) : (
                <button
                  onClick={onClose}
                  className="w-full h-[56px] rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-900 font-black text-lg transition-all active:scale-[0.98]"
                >
                  Dismiss
                </button>
              )}
              
              <button 
                onClick={onClose}
                className="text-slate-400 text-xs font-bold hover:text-slate-600 transition-colors py-2 text-center md:text-left"
              >
                Remind me later
              </button>
            </div>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};

export default ImageBannerModal;
