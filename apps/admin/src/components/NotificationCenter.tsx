import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  Bell, 
  X, 
  Trash2, 
  CheckCheck, 
  ExternalLink,
  Wallet,
  Trophy,
  Info,
  AlertTriangle,
  History
} from 'lucide-react';
import { db } from '../firebase';
import { 
  collection, 
  query, 
  where, 
  orderBy, 
  onSnapshot, 
  doc, 
  updateDoc, 
  writeBatch,
  getDocs,
  limit
} from 'firebase/firestore';
import { AppNotification, UserProfile } from '../types';
import { formatDistanceToNow } from 'date-fns';

interface NotificationCenterProps {
  profile: UserProfile | null;
  isOpen: boolean;
  onClose: () => void;
  onNavigate: (path: string) => void;
  onUpdateProfile?: (data: Partial<UserProfile>) => Promise<void>;
}

const getIcon = (type: string) => {
  switch (type) {
    case 'transaction': return <Wallet className="text-emerald-500" size={18} />;
    case 'contest':
    case 'tournament': return <Trophy className="text-amber-500" size={18} />;
    case 'warning': return <AlertTriangle className="text-rose-500" size={18} />;
    case 'announcement': return <Bell className="text-blue-500" size={18} />;
    case 'success': return <CheckCheck className="text-emerald-500" size={18} />;
    default: return <Info className="text-blue-500" size={18} />;
  }
};

export default function NotificationCenter({ profile, isOpen, onClose, onNavigate, onUpdateProfile }: NotificationCenterProps) {
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(true);
  const [showClearConfirm, setShowClearConfirm] = useState(false);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    if (!profile?.userId) return;

    const cutoffDate = profile.notificationLastClearedAt || (profile.createdAt ? new Date(profile.createdAt) : new Date('2024-01-01'));
    const q = query(
      collection(db, 'notifications'),
      where('userId', 'in', [profile.userId, 'global']),
      where('createdAt', '>', cutoffDate),
      orderBy('createdAt', 'desc'),
      limit(50)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetched = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as AppNotification));

      setNotifications(fetched);
      setLoading(false);
    }, (error) => {
      console.error("Notification listener error:", error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [profile?.userId, profile?.notificationLastClearedAt]);

  const markAllAsRead = async () => {
    if (!profile) return;
    const unread = notifications.filter(n => {
      if (n.userId === 'global') {
        return !profile.readNotifications?.includes(n.id);
      }
      return !n.read;
    });
    
    if (unread.length === 0) return;

    const batch = writeBatch(db);
    const globalReadIds: string[] = [...(profile.readNotifications || [])];

    unread.forEach(n => {
      if (n.userId !== 'global') {
        batch.update(doc(db, 'notifications', n.id), { read: true });
      } else {
        if (!globalReadIds.includes(n.id)) {
          globalReadIds.push(n.id);
        }
      }
    });

    if (onUpdateProfile && globalReadIds.length !== (profile.readNotifications?.length || 0)) {
      await onUpdateProfile({ readNotifications: globalReadIds });
    }
    
    await batch.commit();
  };

  const markAsRead = async (id: string) => {
    const notif = notifications.find(n => n.id === id);
    if (!notif) return;

    if (notif.userId !== 'global') {
      await updateDoc(doc(db, 'notifications', id), { read: true });
    } else if (profile && onUpdateProfile) {
      // For global notifications, track read status in the user's profile
      const currentRead = profile.readNotifications || [];
      if (!currentRead.includes(id)) {
        await onUpdateProfile({
          readNotifications: [...currentRead, id]
        });
      }
    }
  };

  const clearAll = async () => {
    if (!profile) return;
    setShowClearConfirm(false);
    
    // Optimistic UI clear immediately
    setNotifications([]); 
    
    try {
      // 1. Update user profile to set the clear timestamp (clears global instantly)
      if (onUpdateProfile) {
        await onUpdateProfile({ 
          notificationLastClearedAt: new Date() 
        });
      }

      // 2. Cleanup individual notifications from DB
      const batch = writeBatch(db);
      notifications.forEach(n => {
        if (n.userId !== 'global') {
          batch.delete(doc(db, 'notifications', n.id));
        }
      });
      await batch.commit();
      
      // Close the panel after clearing
      onClose();
      
    } catch (error) {
      console.error('Error clearing notifications:', error);
    }
  };

  const unreadCount = notifications.filter(n => {
    if (n.userId === 'global') {
      return !profile?.readNotifications?.includes(n.id);
    }
    return !n.read;
  }).length;

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop for mobile */}
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/20 backdrop-blur-sm z-[60] lg:hidden"
          />
          
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            className="fixed left-4 right-4 top-20 sm:absolute sm:left-auto sm:right-0 sm:top-14 sm:w-[350px] md:w-[400px] mx-auto bg-white rounded-2xl shadow-2xl border border-slate-200 overflow-hidden z-[70] flex flex-col max-h-[500px]"
          >
            {/* Header */}
            <div className="p-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <div className="flex items-center gap-2">
                <h3 className="font-black text-slate-800 tracking-tight">Notifications</h3>
                {unreadCount > 0 && (
                  <span className="bg-emerald-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                    {unreadCount} NEW
                  </span>
                )}
              </div>
              <div className="flex items-center gap-1">
                {notifications.length > 0 && (
                  <>
                    <button 
                      onClick={markAllAsRead}
                      className="p-2 text-slate-400 hover:text-emerald-600 transition-colors tooltip"
                      title="Mark all as read"
                    >
                      <CheckCheck size={18} />
                    </button>
                    <button 
                      onClick={() => setShowClearConfirm(true)}
                      className="p-2 text-slate-400 hover:text-rose-600 transition-colors"
                      title="Clear all"
                    >
                      <Trash2 size={16} />
                    </button>
                  </>
                )}
                <button 
                  onClick={onClose}
                  className="p-2 text-slate-400 hover:text-slate-600 transition-colors"
                >
                  <X size={18} />
                </button>
              </div>
            </div>

            {/* List */}
            <div className="flex-1 overflow-y-auto no-scrollbar">
              {loading ? (
                <div className="p-10 flex flex-col items-center justify-center gap-3">
                  <div className="w-8 h-8 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin" />
                  <p className="text-sm font-medium text-slate-500">Loading alerts...</p>
                </div>
              ) : notifications.length === 0 ? (
                <div className="p-10 flex flex-col items-center justify-center text-center">
                  <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-4">
                    <History className="text-slate-300" size={32} />
                  </div>
                  <h4 className="font-bold text-slate-800 mb-1">No notifications yet</h4>
                  <p className="text-xs text-slate-500 max-w-[200px]">
                    We'll notify you when something important happens!
                  </p>
                </div>
              ) : (
                <div className="divide-y divide-slate-50">
                  {notifications.map((notif) => (
                    <div 
                      key={notif.id}
                      onClick={() => {
                        if (!(notif.userId === 'global' ? profile?.readNotifications?.includes(notif.id) : notif.read)) {
                          markAsRead(notif.id);
                        }
                        
                        // Handle Navigation
                        const url = notif.actionUrl || notif.link;
                        if (url) {
                          if (url.startsWith('http')) {
                            window.open(url, '_blank');
                          } else {
                            onNavigate(url);
                          }
                          onClose();
                        } else {
                          setExpandedId(expandedId === notif.id ? null : notif.id);
                        }
                      }}
                      className={`
                        p-4 flex gap-4 transition-colors cursor-pointer relative group
                        ${(notif.userId === 'global' ? profile?.readNotifications?.includes(notif.id) : notif.read) ? 'bg-white' : 'bg-emerald-50/40 hover:bg-emerald-50/60'}
                      `}
                    >
                      {!(notif.userId === 'global' ? profile?.readNotifications?.includes(notif.id) : notif.read) && (
                        <div className="absolute left-0 top-0 bottom-0 w-1 bg-emerald-500" />
                      )}
                      
                      <div className={`
                        w-10 h-10 rounded-xl flex items-center justify-center shrink-0 shadow-sm
                        ${(notif.userId === 'global' ? profile?.readNotifications?.includes(notif.id) : notif.read) ? 'bg-slate-50' : 'bg-white'}
                      `}>
                        {getIcon(notif.type)}
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex gap-3">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between gap-2 mb-0.5">
                              <h5 className={`text-sm tracking-tight truncate ${(notif.userId === 'global' ? profile?.readNotifications?.includes(notif.id) : notif.read) ? 'font-semibold text-slate-700' : 'font-black text-slate-900'}`}>
                                {notif.title}
                              </h5>
                              <span className="text-[10px] font-medium text-slate-400 shrink-0 mt-0.5">
                                {(() => {
                                  try {
                                    const date = notif.createdAt?.toDate ? notif.createdAt.toDate() : new Date(notif.createdAt);
                                    return isNaN(date.getTime()) ? 'just now' : formatDistanceToNow(date, { addSuffix: true });
                                  } catch (e) {
                                    return 'just now';
                                  }
                                })()}
                              </span>
                            </div>
                            <p className={`text-xs text-slate-500 leading-relaxed transition-all ${expandedId === notif.id ? '' : 'line-clamp-2'}`}>
                              {notif.message}
                            </p>
                            
                            {notif.message.length > 80 && (
                              <button 
                                className="text-[10px] font-bold text-emerald-600 mt-1 hover:underline"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  setExpandedId(expandedId === notif.id ? null : notif.id);
                                }}
                              >
                                {expandedId === notif.id ? 'Show Less' : 'Read More...'}
                              </button>
                            )}
                            
                            {notif.actionUrl && (
                              <div className="mt-3 flex justify-end">
                                <button 
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    if (notif.actionUrl) {
                                      if (notif.actionUrl.startsWith('http')) {
                                        window.open(notif.actionUrl, '_blank');
                                      } else {
                                        onNavigate(notif.actionUrl);
                                      }
                                      onClose();
                                    }
                                  }}
                                  className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 rounded-lg text-[10px] font-black text-emerald-700 uppercase tracking-wider hover:bg-emerald-500 hover:text-white transition-all shadow-sm"
                                >
                                  <span>{notif.actionUrl.startsWith('http') ? 'View Link' : 'Open Page'}</span>
                                  <ExternalLink size={10} />
                                </button>
                              </div>
                            )}
                          </div>
                          
                          {notif.imageUrl && (
                            <div className="w-14 h-14 rounded-xl overflow-hidden shrink-0 border border-slate-100 shadow-sm ml-2">
                              <img src={notif.imageUrl} alt="" className="w-full h-full object-cover" />
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Footer */}
            {notifications.length > 0 && (
              <div className="p-3 bg-slate-50/50 border-t border-slate-100 text-center">
                <button 
                  onClick={onClose}
                  className="text-[11px] font-bold text-slate-400 hover:text-slate-600 transition-colors uppercase tracking-widest"
                >
                  Close Panel
                </button>
              </div>
            )}
          </motion.div>
          {showClearConfirm && (
            <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowClearConfirm(false)}
                className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm"
              />
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                className="relative bg-white rounded-2xl shadow-2xl p-6 w-full max-w-xs text-center overflow-hidden"
              >
                {/* Decorative circle */}
                <div className="absolute -right-4 -top-4 w-20 h-20 bg-rose-50 rounded-full blur-2xl" />

                <div className="w-16 h-16 bg-rose-50 text-rose-500 rounded-full flex items-center justify-center mx-auto mb-4 relative z-10">
                  <Trash2 size={32} />
                </div>
                <h4 className="text-lg font-black text-slate-800 mb-2 uppercase tracking-tight relative z-10">Clear Alerts?</h4>
                <p className="text-sm text-slate-500 mb-6 relative z-10">This will permanently delete all your notifications.</p>
                <div className="flex gap-3 relative z-10">
                  <button
                    onClick={() => setShowClearConfirm(false)}
                    className="flex-1 py-3 bg-slate-100 text-slate-600 font-bold rounded-xl text-[10px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={clearAll}
                    className="flex-1 py-3 bg-rose-500 text-white font-bold rounded-xl text-[10px] uppercase tracking-widest hover:bg-rose-600 transition-colors shadow-lg shadow-rose-100 active:scale-95 transition-all"
                  >
                    Clear All
                  </button>
                </div>
              </motion.div>
            </div>
          )}
        </>
      )}
    </AnimatePresence>
  );
}
