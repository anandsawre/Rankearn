import React, { useState, useEffect, useRef } from 'react';
import { motion, useAnimation, PanInfo } from 'motion/react';
import { RefreshCw } from 'lucide-react';

interface PullToRefreshProps {
  onRefresh: () => Promise<void>;
  children: React.ReactNode;
}

export default function PullToRefresh({ onRefresh, children }: PullToRefreshProps) {
  const [pullDistance, setPullDistance] = useState(0);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const PULL_THRESHOLD = 80;
  const scrollRef = useRef<HTMLDivElement>(null);

  const handlePan = (_: any, info: PanInfo) => {
    if (isRefreshing) return;
    
    // Only allow pull if we are at the very top of our scroll container
    if (scrollRef.current && scrollRef.current.scrollTop > 0) {
      if (pullDistance > 0) setPullDistance(0);
      return;
    }

    if (info.offset.y > 0) {
      // Resistance effect: pulling gets harder as it goes down
      const distance = Math.min(info.offset.y * 0.4, 100);
      setPullDistance(distance);
    } else {
      setPullDistance(0);
    }
  };

  const handlePanEnd = async () => {
    if (isRefreshing) return;

    if (pullDistance >= PULL_THRESHOLD) {
      setIsRefreshing(true);
      setPullDistance(PULL_THRESHOLD);
      
      try {
        await onRefresh();
      } catch (error) {
        console.error('Refresh failed:', error);
      } finally {
        // Smoothly close after a short delay
        setTimeout(() => {
          setIsRefreshing(false);
          setPullDistance(0);
        }, 800);
      }
    } else {
      setPullDistance(0);
    }
  };

  return (
    <div className="relative w-full h-full flex flex-col overflow-hidden">
      {/* Pull Indicator Layer */}
      <div 
        className="absolute left-0 right-0 flex justify-center pointer-events-none z-[100]"
        style={{ 
          height: pullDistance, 
          top: 0,
          opacity: Math.min(pullDistance / (PULL_THRESHOLD * 0.8), 1)
        }}
      >
        <div className="flex items-center justify-center mt-2">
          <div className={`
            p-2.5 rounded-full bg-white shadow-xl border border-slate-100 flex items-center justify-center
            ${isRefreshing ? 'animate-spin shadow-emerald-100' : 'shadow-slate-200'}
          `}
          style={{ transform: !isRefreshing ? `rotate(${pullDistance * 4}deg) scale(${Math.min(pullDistance / PULL_THRESHOLD, 1)})` : 'none' }}
          >
            <RefreshCw 
              size={18} 
              className={isRefreshing ? 'text-emerald-500' : 'text-slate-400'} 
              strokeWidth={3}
            />
          </div>
        </div>
      </div>

      {/* Scrollable Content */}
      <motion.div
        onPan={handlePan}
        onPanEnd={handlePanEnd}
        animate={{ y: isRefreshing ? PULL_THRESHOLD : pullDistance }}
        transition={{ type: "spring", stiffness: 400, damping: 40 }}
        className="flex-1 flex flex-col h-full overflow-hidden"
      >
        <div 
          ref={scrollRef}
          className="flex-1 overflow-y-auto overscroll-none"
        >
          {children}
        </div>
      </motion.div>
    </div>
  );
}
