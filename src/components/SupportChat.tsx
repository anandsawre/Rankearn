import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import {
  collection,
  addDoc,
  query,
  orderBy,
  onSnapshot,
  serverTimestamp,
  doc,
  setDoc,
  updateDoc,
  increment
} from 'firebase/firestore';
import { UserProfile, SupportMessage, SupportTicket } from '../types';
import { Send, MessageCircle, Clock, User, ShieldCheck, ArrowLeft } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { sendPushNotification } from '../utils/push-notifications';

interface SupportChatProps {
  profile: UserProfile;
}

const SupportChat: React.FC<SupportChatProps> = ({ profile }) => {
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [config, setConfig] = useState({ isEnabled: true, statusText: 'we usually reply within 24h' });
  const scrollRef = useRef<HTMLDivElement>(null);

  // Sync scroll to bottom when messages change
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  // Fetch Support Config
  useEffect(() => {
    const unsubscribe = onSnapshot(doc(db, 'configs', 'support_config'), (doc) => {
      if (doc.exists()) {
        setConfig(doc.data() as any);
      }
    });
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    if (!profile?.userId) return;

    // 1. Ensure the ticket exists for this user
    const ticketRef = doc(db, 'support_tickets', profile.userId);

    // 2. Subscribe to messages
    const messagesQuery = query(
      collection(db, 'support_tickets', profile.userId, 'messages'),
      orderBy('timestamp', 'asc')
    );

    const unsubscribe = onSnapshot(messagesQuery, (snapshot) => {
      const msgs = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as SupportMessage[];
      setMessages(msgs);
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, [profile?.userId]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim() || !profile?.userId) return;

    const text = newMessage.trim();
    setNewMessage('');

    try {
      // 1. Update or Create Ticket metadata
      const ticketRef = doc(db, 'support_tickets', profile.userId);
      await setDoc(ticketRef, {
        userId: profile.userId,
        userName: profile.name,
        userEmail: profile.email,
        userPhoto: profile.profilePhoto || '',
        lastMessage: text,
        lastUpdated: serverTimestamp(),
        status: 'open',
        unreadCount: increment(1)
      }, { merge: true });

      // 2. Add message to sub-collection
      await addDoc(collection(db, 'support_tickets', profile.userId, 'messages'), {
        senderId: profile.userId,
        senderName: profile.name,
        text: text,
        timestamp: serverTimestamp(),
        role: 'user'
      });

      // 3. Send Push Notification to Admin
      sendPushNotification(
        'admin',
        `New Support Message: ${profile.name}`,
        text,
        { actionUrl: '/admin?tab=support' }
      );

    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  return (
    <div className="flex flex-col h-[calc(100vh-10rem)] md:h-[calc(100vh-8rem)] bg-white rounded-2xl border border-slate-200 shadow-xl overflow-hidden">
      {/* Header */}
      <div className="px-6 py-4 bg-gradient-to-r from-emerald-500 to-emerald-600 text-white flex items-center justify-between shadow-md">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/30">
            <MessageCircle className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="font-bold text-lg leading-none">Support Chat</h2>
            <p className="text-[10px] text-emerald-100 mt-1.5 font-medium">{config.statusText}</p>
          </div>
        </div>
      </div>

      {!config.isEnabled ? (
        <div className="flex-1 flex flex-col items-center justify-center p-12 text-center bg-slate-50/50">
          <div className="w-20 h-20 bg-white rounded-3xl flex items-center justify-center mb-6 shadow-sm">
            <ShieldCheck size={40} className="text-slate-300" />
          </div>
          <h3 className="text-lg font-black text-slate-900 mb-2">Support is Offline</h3>
          <p className="text-sm text-slate-500 max-w-xs font-medium">
            Our support chat is currently disabled for maintenance. Please check back later or contact us via email.
          </p>
        </div>
      ) : (
        <>
          {/* Messages Area */}
          <div
            ref={scrollRef}
            className="flex-1 overflow-y-auto p-4 md:p-6 space-y-4 bg-slate-50/50 no-scrollbar"
          >
            {isLoading ? (
              <div className="flex flex-col items-center justify-center h-full gap-3 text-slate-400">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                  className="w-8 h-8 border-2 border-emerald-500 border-t-transparent rounded-full"
                />
                <p className="text-xs font-bold uppercase tracking-wider">Loading Conversation...</p>
              </div>
            ) : messages.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center px-8">
                <div className="w-16 h-16 bg-emerald-50 rounded-2xl flex items-center justify-center mb-4">
                  <ShieldCheck className="w-8 h-8 text-emerald-500" />
                </div>
                <h3 className="text-slate-900 font-bold text-lg mb-2">How can we help?</h3>
                <p className="text-slate-500 text-sm max-w-xs">
                  Send us a message about any problem you're facing. Our team will get back to you soon.
                </p>
              </div>
            ) : (
              messages.map((msg) => {
                const isMe = msg.senderId === profile.userId;
                return (
                  <motion.div
                    key={msg.id}
                    initial={{ opacity: 0, y: 10, scale: 0.95 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}
                  >
                    <div className={`max-w-[80%] md:max-w-[70%] ${isMe ? 'order-2' : 'order-1'}`}>
                      <div className={`
                    px-4 py-3 rounded-2xl text-sm leading-relaxed shadow-sm
                    ${isMe
                          ? 'bg-emerald-500 text-white rounded-tr-none'
                          : 'bg-white text-slate-800 border border-slate-200 rounded-tl-none'}
                  `}>
                        {msg.text}
                      </div>
                      <div className={`flex items-center gap-1.5 mt-1.5 px-1 ${isMe ? 'justify-end' : 'justify-start'}`}>
                        {!isMe && <span className="text-[10px] font-black text-emerald-600 uppercase tracking-tighter">Support</span>}
                        <span className="text-[9px] text-slate-400 font-medium">
                          {msg.timestamp?.toDate ? new Date(msg.timestamp.toDate()).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Sending...'}
                        </span>
                      </div>
                    </div>
                  </motion.div>
                );
              })
            )}
          </div>

          {/* Input Area */}
          <div className="p-4 bg-white border-t border-slate-100">
            <form onSubmit={handleSendMessage} className="flex items-center gap-2">
              <input
                type="text"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Type your message..."
                className="flex-1 bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 text-sm font-medium focus:border-emerald-500 outline-none transition-all"
              />
              <button
                type="submit"
                disabled={!newMessage.trim()}
            className="w-12 h-12 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 disabled:hover:bg-emerald-500 text-white rounded-lg flex items-center justify-center shadow-lg shadow-emerald-200 transition-all active:scale-95"
          >
            <Send className="w-5 h-5" />
          </button>
        </form>
      </div>
    </>
  )}
</div>
  );
};

export default SupportChat;
