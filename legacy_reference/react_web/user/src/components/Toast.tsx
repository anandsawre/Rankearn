import React, { createContext, useContext, useState, useCallback, ReactNode, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { CheckCircle2, AlertCircle, Info, AlertTriangle, X, ArrowRight } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info' | 'warning';

interface ToastMessage {
  id: string;
  message: string;
  type: ToastType;
  duration?: number;
  actionUrl?: string;
  onClick?: () => void;
}

interface ToastContextType {
  showToast: (message: string, type?: ToastType, duration?: number, actionUrl?: string, onClick?: () => void) => void;
  removeToast: (id: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export const useToast = () => {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
};

export const ToastProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const showToast = useCallback((message: string, type: ToastType = 'info', duration: number = 4000, actionUrl?: string, onClick?: () => void) => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { id, message, type, duration, actionUrl, onClick }]);

    if (duration !== Infinity) {
      setTimeout(() => {
        removeToast(id);
      }, duration);
    }
  }, [removeToast]);

  return (
    <ToastContext.Provider value={{ showToast, removeToast }}>
      {children}
      <div className="fixed top-6 left-1/2 -translate-x-1/2 md:left-auto md:right-6 md:translate-x-0 z-[10000] flex flex-col gap-3 pointer-events-none w-full max-w-[380px] px-4 md:px-0">
        <AnimatePresence mode="popLayout">
          {toasts.map((toast) => (
            <ToastItem key={toast.id} toast={toast} onRemove={removeToast} />
          ))}
        </AnimatePresence>
      </div>
    </ToastContext.Provider>
  );
};

const ToastItem: React.FC<{ toast: ToastMessage; onRemove: (id: string) => void }> = ({ toast, onRemove }) => {
  const [progress, setProgress] = useState(100);

  useEffect(() => {
    if (!toast.duration || toast.duration === Infinity) return;
    
    const interval = 10;
    const step = (interval / toast.duration) * 100;
    
    const timer = setInterval(() => {
      setProgress((prev) => Math.max(0, prev - step));
    }, interval);

    return () => clearInterval(timer);
  }, [toast.duration]);

  const config = {
    success: {
      icon: <CheckCircle2 className="text-emerald-500" size={18} />,
      bg: 'bg-emerald-50/90',
      border: 'border-emerald-200/50',
      bar: 'bg-emerald-500',
      shadow: 'shadow-emerald-500/10'
    },
    error: {
      icon: <AlertCircle className="text-rose-500" size={18} />,
      bg: 'bg-rose-50/90',
      border: 'border-rose-200/50',
      bar: 'bg-rose-500',
      shadow: 'shadow-rose-500/10'
    },
    info: {
      icon: <Info className="text-blue-500" size={18} />,
      bg: 'bg-blue-50/90',
      border: 'border-blue-200/50',
      bar: 'bg-blue-500',
      shadow: 'shadow-blue-500/10'
    },
    warning: {
      icon: <AlertTriangle className="text-amber-500" size={18} />,
      bg: 'bg-amber-50/90',
      border: 'border-amber-200/50',
      bar: 'bg-amber-500',
      shadow: 'shadow-amber-500/10'
    },
  };

  const style = config[toast.type as keyof typeof config] || config.info;

  const handleClick = () => {
    if (toast.onClick) {
      toast.onClick();
    }
    if (toast.actionUrl) {
      if (toast.actionUrl.startsWith('http')) {
        window.open(toast.actionUrl, '_blank');
      } else {
        window.location.href = toast.actionUrl;
      }
      onRemove(toast.id);
    }
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, x: 20, scale: 0.9 }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9, transition: { duration: 0.15 } }}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={handleClick}
      className={`
        pointer-events-auto relative overflow-hidden group
        backdrop-blur-xl border ${style.border} ${style.bg} ${style.shadow}
        rounded-2xl p-4 flex items-center gap-4 shadow-2xl transition-all
        ${toast.actionUrl ? 'cursor-pointer' : ''}
      `}
    >
      <div className={`shrink-0 w-10 h-10 rounded-full bg-white flex items-center justify-center shadow-sm`}>
        {style.icon}
      </div>
      
      <div className="flex-1 min-w-0">
        <p className="text-slate-900 text-sm font-bold leading-tight line-clamp-2">
          {toast.message}
        </p>
        {toast.actionUrl && (
          <div className="flex items-center gap-1 mt-1 text-[10px] font-black text-slate-500 uppercase tracking-widest">
            Click to view <ArrowRight size={10} />
          </div>
        )}
      </div>

      <button
        onClick={(e) => {
          e.stopPropagation();
          onRemove(toast.id);
        }}
        className="shrink-0 w-8 h-8 flex items-center justify-center rounded-xl hover:bg-black/5 text-slate-400 hover:text-slate-600 transition-colors"
      >
        <X size={16} />
      </button>

      {/* Progress Bar */}
      {toast.duration !== Infinity && (
        <div className="absolute bottom-0 left-0 right-0 h-[3px] bg-black/5">
          <motion.div 
            className={`h-full ${style.bar}`}
            style={{ width: `${progress}%` }}
          />
        </div>
      )}
    </motion.div>
  );
};
