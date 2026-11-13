import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import { 
  collection, 
  query, 
  orderBy, 
  onSnapshot, 
  doc, 
  updateDoc, 
  addDoc, 
  serverTimestamp, 
  setDoc,
  limit,
  where,
  getDoc,
  getDocs,
  writeBatch,
  deleteDoc
} from 'firebase/firestore';
import { SupportTicket, SupportMessage } from '../types';
import { MessageCircle, Search, Clock, User, CheckCircle2, Send, ShieldCheck, Mail, MoreVertical, Trash2, AlertTriangle, X, ArrowLeft, Check, CheckCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { sendPushNotification } from '../utils/push-notifications';

const AdminSupport = () => {
  const [tickets, setTickets] = useState<SupportTicket[]>([]);
  const [selectedTicket, setSelectedTicket] = useState<SupportTicket | null>(null);
  const [messages, setMessages] = useState<SupportMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [config, setConfig] = useState({ isEnabled: true, statusText: 'we usually reply within 24h' });
  const [isSavingConfig, setIsSavingConfig] = useState(false);
  const [isConfigOpen, setIsConfigOpen] = useState(false);
  const [searchMode, setSearchMode] = useState<'tickets' | 'users'>('tickets');
  const [allUsers, setAllUsers] = useState<any[]>([]);
  const [showClearConfirm, setShowClearConfirm] = useState(false);
  const [isClearing, setIsClearing] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Close config menu on click outside
  useEffect(() => {
    const handleClickOutside = () => setIsConfigOpen(false);
    if (isConfigOpen) {
      window.addEventListener('click', handleClickOutside);
    }
    return () => window.removeEventListener('click', handleClickOutside);
  }, [isConfigOpen]);

  // Fetch Support Config
  useEffect(() => {
    const unsubscribe = onSnapshot(doc(db, 'configs', 'support_config'), (doc) => {
      if (doc.exists()) {
        setConfig(doc.data() as any);
      }
    });
    return () => unsubscribe();
  }, []);

  // Fetch tickets or users (Server-side Search)
  useEffect(() => {
    setIsLoading(true);
    let q;
    const search = searchQuery.trim();

    if (searchMode === 'users') {
      if (search.length >= 3) {
        // Search all users only when at least 3 chars are typed
        q = query(
          collection(db, 'users'),
          where('name', '>=', search),
          where('name', '<=', search + '\uf8ff'),
          limit(20)
        );
      } else {
        setAllUsers([]);
        setIsLoading(false);
        return;
      }

      const unsubscribe = onSnapshot(q, (snapshot) => {
        const fetchedUsers = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setAllUsers(fetchedUsers);
        setIsLoading(false);
      });
      return () => unsubscribe();
    } else {
      // Search existing tickets
      if (search) {
        q = query(
          collection(db, 'support_tickets'),
          where('userName', '>=', search),
          where('userName', '<=', search + '\uf8ff'),
          limit(20)
        );
      } else {
        q = query(
          collection(db, 'support_tickets'), 
          orderBy('lastUpdated', 'desc'), 
          limit(50)
        );
      }

      const unsubscribe = onSnapshot(q, (snapshot) => {
        const fetchedTickets = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        })) as SupportTicket[];
        setTickets(fetchedTickets);
        setIsLoading(false);
      }, (error) => {
        console.error("Search error:", error);
        setIsLoading(false);
      });

      return () => unsubscribe();
    }
  }, [searchQuery, searchMode]);

  // Fetch messages for selected ticket
  useEffect(() => {
    if (!selectedTicket) return;

    const q = query(
      collection(db, 'support_tickets', selectedTicket.id, 'messages'),
      orderBy('timestamp', 'asc')
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgs = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as SupportMessage[];
      setMessages(msgs);

      // Clear unread count when admin opens the chat
      if (selectedTicket.unreadCount > 0) {
        updateDoc(doc(db, 'support_tickets', selectedTicket.id), {
          unreadCount: 0
        });
      }
    });
    return () => unsubscribe();
  }, [selectedTicket?.id]);

  // Fetch user photo if missing from ticket (Auto-sync)
  useEffect(() => {
    if (selectedTicket && !selectedTicket.userPhoto) {
      getDoc(doc(db, 'users', selectedTicket.userId)).then(userDoc => {
        if (userDoc.exists()) {
          const userData = userDoc.data();
          if (userData.profilePhoto) {
            setSelectedTicket(prev => prev ? { ...prev, userPhoto: userData.profilePhoto } : null);
            // Optionally update the ticket in Firestore too
            updateDoc(doc(db, 'support_tickets', selectedTicket.id), {
              userPhoto: userData.profilePhoto
            });
          }
        }
      });
    }
  }, [selectedTicket?.id]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedTicket) return;

    const text = newMessage.trim();
    setNewMessage('');

    try {
      await addDoc(collection(db, 'support_tickets', selectedTicket.id, 'messages'), {
        senderId: 'admin',
        senderName: 'Support Team',
        text: text,
        timestamp: serverTimestamp(),
        role: 'admin'
      });

      await updateDoc(doc(db, 'support_tickets', selectedTicket.id), {
        lastMessage: text,
        lastUpdated: serverTimestamp(),
        status: 'open'
      });

      sendPushNotification(
        selectedTicket.userId,
        'Support Team',
        text,
        { actionUrl: '/support' }
      );
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  const handleCloseTicket = async (ticketId: string) => {
    try {
      await updateDoc(doc(db, 'support_tickets', ticketId), {
        status: 'closed',
        lastMessage: 'Ticket closed by support'
      });
      if (selectedTicket?.id === ticketId) {
        setSelectedTicket(prev => prev ? { ...prev, status: 'closed', lastMessage: 'Ticket closed by support' } : null);
      }
    } catch (error) {
      console.error('Error closing ticket:', error);
    }
  };

  const handleClearChat = async () => {
    if (!selectedTicket) return;
    
    setIsClearing(true);
    try {
      const messagesRef = collection(db, 'support_tickets', selectedTicket.id, 'messages');
      const snapshot = await getDocs(messagesRef);
      
      const batch = writeBatch(db);
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      
      await batch.commit();
      
      await updateDoc(doc(db, 'support_tickets', selectedTicket.id), {
        lastMessage: 'Chat history cleared',
        lastUpdated: serverTimestamp()
      });

      setMessages([]);
      setSelectedTicket(prev => prev ? { ...prev, lastMessage: 'Chat history cleared' } : null);
      setShowClearConfirm(false);
    } catch (error) {
      console.error('Error clearing chat:', error);
    } finally {
      setIsClearing(false);
    }
  };

  const handleSaveConfig = async (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsSavingConfig(true);
    try {
      await setDoc(doc(db, 'configs', 'support_config'), config);
      setIsConfigOpen(false);
    } catch (error) {
      console.error('Error saving config:', error);
    }
    setIsSavingConfig(false);
  };

  const handleSelectUser = async (user: any) => {
    try {
      const ticketDoc = await getDoc(doc(db, 'support_tickets', user.id));
      
      if (ticketDoc.exists()) {
        setSelectedTicket({ id: ticketDoc.id, ...ticketDoc.data() } as SupportTicket);
      } else {
        const newTicket = {
          userName: user.name || 'Unknown User',
          userEmail: user.email || '',
          userId: user.id,
          userPhoto: user.profilePhoto || '',
          status: 'open',
          lastMessage: 'Conversation started by Admin',
          lastUpdated: serverTimestamp(),
          unreadCount: 0
        };
        await setDoc(doc(db, 'support_tickets', user.id), newTicket);
        setSelectedTicket({ id: user.id, ...newTicket } as any);
      }
      setSearchMode('tickets');
      setSearchQuery('');
    } catch (error) {
      console.error('Error selecting user:', error);
    }
  };

  return (
    <>
    <div className="flex h-[calc(100vh-8rem)] bg-[#F0F4F2] rounded-2xl border border-emerald-100 shadow-2xl overflow-hidden relative">
      {/* Sidebar: Ticket List */}
      <div className={`
        ${selectedTicket ? 'hidden lg:flex' : 'flex'}
        w-full lg:w-[400px] border-r border-slate-200 flex-col bg-white shrink-0
      `}>
        {/* Sidebar Header */}
        <div className="p-4 bg-[#F0F4F2] border-b border-emerald-100">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-emerald-500 flex items-center justify-center text-white border border-emerald-600/10">
                 <MessageCircle size={20} />
              </div>
              <h2 className="font-bold text-slate-800 text-sm">Chat Support</h2>
            </div>
            
            <div className="flex items-center gap-2">
              <button 
                onClick={(e) => { e.stopPropagation(); setIsConfigOpen(!isConfigOpen); }}
                className={`p-2 rounded-full transition-all ${isConfigOpen ? 'bg-slate-200 text-slate-900' : 'text-slate-500 hover:bg-slate-200'}`}
              >
                <MoreVertical size={20} />
              </button>

              {/* Config Dropdown */}
              <AnimatePresence>
                {isConfigOpen && (
                  <motion.div
                    initial={{ opacity: 0, scale: 0.95, y: 10 }}
                    animate={{ opacity: 1, scale: 1, y: 0 }}
                    exit={{ opacity: 0, scale: 0.95, y: 10 }}
                    onClick={(e) => e.stopPropagation()}
                    className="absolute right-4 top-16 w-72 bg-white border border-slate-200 shadow-2xl rounded-2xl p-5 z-50 overflow-hidden"
                  >
                    <div className="space-y-5">
                      <div className="flex items-center justify-between border-b border-slate-50 pb-3">
                        <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Settings</span>
                        <div className="flex items-center gap-2">
                          <span className={`text-[9px] font-black uppercase transition-colors ${config.isEnabled ? 'text-emerald-500' : 'text-slate-400'}`}>
                            {config.isEnabled ? 'Active' : 'Offline'}
                          </span>
                          <button
                            onClick={() => setConfig({ ...config, isEnabled: !config.isEnabled })}
                            className={`relative inline-flex h-4 w-8 items-center rounded-full transition-all ${config.isEnabled ? 'bg-emerald-500' : 'bg-slate-300'}`}
                          >
                            <span className={`inline-block h-2.5 w-2.5 transform rounded-full bg-white transition-transform ${config.isEnabled ? 'translate-x-5' : 'translate-x-0.5'}`} />
                          </button>
                        </div>
                      </div>

                      <div className="space-y-2">
                        <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Status Text</label>
                        <input 
                          type="text" 
                          value={config.statusText}
                          onChange={(e) => setConfig({ ...config, statusText: e.target.value.toLowerCase() })}
                          className="w-full bg-slate-50 border border-slate-100 rounded-xl px-3 py-2 text-xs font-bold focus:border-emerald-500 outline-none transition-all no-capitalize"
                        />
                      </div>

                      <button
                        onClick={handleSaveConfig}
                        disabled={isSavingConfig}
                        className="w-full py-3 bg-slate-900 text-white font-black text-[10px] uppercase tracking-wider rounded-xl hover:bg-slate-800 transition-all active:scale-95 disabled:opacity-50 shadow-lg shadow-slate-200"
                      >
                        {isSavingConfig ? 'Saving...' : 'Save Changes'}
                      </button>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>

          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={searchMode === 'tickets' ? "Search or start new chat" : "Search all users..."}
              className="w-full pl-11 pr-4 py-2 bg-white border-none rounded-lg text-sm focus:ring-0 outline-none placeholder:text-slate-400 shadow-sm"
            />
          </div>

          <div className="flex items-center gap-1 mt-3 p-1 bg-slate-200/50 rounded-lg">
            <button 
              onClick={() => setSearchMode('tickets')}
              className={`flex-1 py-1.5 text-[10px] font-black uppercase tracking-wider rounded-md transition-all ${searchMode === 'tickets' ? 'bg-white text-emerald-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
            >
              Chats
            </button>
            <button 
              onClick={() => setSearchMode('users')}
              className={`flex-1 py-1.5 text-[10px] font-black uppercase tracking-wider rounded-md transition-all ${searchMode === 'users' ? 'bg-white text-emerald-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
            >
              Contacts
            </button>
          </div>
        </div>

        {/* Tickets Scroll Area */}
        <div className="flex-1 overflow-y-auto bg-white">
          {isLoading ? (
            <div className="p-8 text-center text-slate-400 font-bold uppercase text-[10px] tracking-widest">
              <div className="w-6 h-6 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin mx-auto mb-2" />
              Loading...
            </div>
          ) : searchMode === 'users' ? (
            searchQuery.trim().length < 3 ? (
              <div className="p-12 text-center text-slate-400">
                <Search size={40} className="mx-auto mb-3 opacity-20" />
                <p className="text-xs font-bold">Type 3+ characters to search users</p>
              </div>
            ) : allUsers.length === 0 ? (
              <div className="p-12 text-center text-slate-400">
                <User size={40} className="mx-auto mb-3 opacity-20" />
                <p className="text-xs font-bold">No users found</p>
              </div>
            ) : (
              allUsers.map((user) => (
                <button
                  key={user.id}
                  onClick={() => handleSelectUser(user)}
                  className="w-full text-left p-4 border-b border-slate-50 transition-all hover:bg-slate-50 flex items-center gap-4"
                >
                  <div className="w-12 h-12 rounded-full bg-slate-100 flex items-center justify-center shrink-0 border border-slate-200 overflow-hidden">
                    <img 
                      src={user.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.name || 'U')}&background=random`} 
                      alt="" 
                      className="w-full h-full object-cover" 
                    />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="font-bold text-slate-900 truncate text-sm">{user.name || 'Unknown'}</p>
                    <p className="text-xs text-slate-400 truncate">{user.email}</p>
                  </div>
                </button>
              ))
            )
          ) : tickets.length === 0 ? (
            <div className="p-12 text-center text-slate-400">
              <MessageCircle size={40} className="mx-auto mb-3 opacity-20" />
              <p className="text-xs font-bold">No active conversations</p>
            </div>
          ) : (
            tickets.map((ticket) => (
              <button
                key={ticket.id}
                onClick={() => setSelectedTicket(ticket)}
                className={`w-full text-left p-4 border-b border-slate-50 transition-all hover:bg-slate-50 flex items-center gap-4 relative
                  ${selectedTicket?.id === ticket.id ? 'bg-slate-100' : ''}
                `}
              >
                <div className="w-12 h-12 rounded-full bg-emerald-50 flex items-center justify-center shrink-0 border border-emerald-100 overflow-hidden">
                  <img 
                    src={ticket.userPhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(ticket.userName || 'U')}&background=random`} 
                    alt="" 
                    className="w-full h-full object-cover" 
                  />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2 mb-1">
                    <p className="font-bold text-slate-900 truncate text-sm flex-1">{ticket.userName}</p>
                    <span className={`text-[10px] whitespace-nowrap ${ticket.unreadCount > 0 ? 'text-emerald-500 font-bold' : 'text-slate-400'}`}>
                      {ticket.lastUpdated?.toDate ? 
                        (() => {
                          const d = ticket.lastUpdated.toDate();
                          const now = new Date();
                          const isToday = d.toDateString() === now.toDateString();
                          if (isToday) return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                          return d.toLocaleDateString([], { day: '2-digit', month: 'short' });
                        })() : ''
                      }
                    </span>
                  </div>
                  <div className="flex items-center justify-between gap-2">
                    <p className="text-xs text-slate-500 truncate flex-1 leading-tight">
                      {ticket.lastMessage}
                    </p>
                    {ticket.unreadCount > 0 && (
                      <span className="min-w-[18px] h-[18px] bg-emerald-500 text-white text-[10px] font-black rounded-full flex items-center justify-center px-1 shrink-0">
                        {ticket.unreadCount}
                      </span>
                    )}
                  </div>
                </div>
              </button>
            ))
          )}
        </div>
      </div>

      {/* Main Chat Area */}
      <div className={`
        ${selectedTicket ? 'flex' : 'hidden lg:flex'}
        flex-1 flex-col bg-[#D9E2D5] relative min-w-0
      `}>
        {selectedTicket ? (
          <>
            {/* WhatsApp Doodle Background Pattern */}
            <div className="absolute inset-0 opacity-[0.06] pointer-events-none" 
                 style={{ backgroundImage: `url('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded51.png')` }} />

            {/* Chat Header */}
            <div className="px-4 py-2.5 bg-[#F0F4F2] border-b border-emerald-100 flex items-center justify-between shadow-sm z-10 shrink-0">
              <div className="flex items-center gap-3">
                <button 
                  onClick={() => setSelectedTicket(null)}
                  className="lg:hidden p-1 text-slate-500 hover:bg-slate-200 rounded-full"
                >
                  <ArrowLeft size={20} />
                </button>
                <div className="w-10 h-10 rounded-full bg-emerald-500 flex items-center justify-center text-white font-bold text-lg border border-emerald-600/10 overflow-hidden">
                  <img 
                    src={selectedTicket.userPhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(selectedTicket.userName || 'U')}&background=random`} 
                    alt="" 
                    className="w-full h-full object-cover" 
                  />
                </div>
                <div className="min-w-0">
                  <h3 className="font-bold text-slate-900 leading-tight truncate">{selectedTicket.userName}</h3>
                  <p className="text-[11px] text-emerald-600 font-medium">online</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setShowClearConfirm(true)}
                  className="p-2 text-slate-500 hover:text-rose-500 transition-colors"
                  title="Clear Chat"
                >
                  <Trash2 size={18} />
                </button>

                {selectedTicket.status === 'open' ? (
                  <button
                    onClick={() => handleCloseTicket(selectedTicket.id)}
                    className="px-3 py-1.5 text-xs font-bold text-rose-600 border border-rose-200 bg-white hover:bg-rose-50 rounded-lg transition-all"
                  >
                    Close
                  </button>
                ) : (
                  <span className="px-3 py-1.5 text-[10px] font-black text-slate-500 bg-slate-200/50 rounded-lg uppercase tracking-wider">
                    Resolved
                  </span>
                )}
              </div>
            </div>

            {/* Messages Area */}
            <div 
              ref={scrollRef}
              className="flex-1 overflow-y-auto p-4 lg:p-8 space-y-2 relative z-10 no-scrollbar"
            >
              {messages.map((msg, idx) => {
                const isAdmin = msg.role === 'admin';
                const nextMsg = messages[idx + 1];
                const isLastInGroup = !nextMsg || nextMsg.role !== msg.role;
                
                return (
                  <div key={msg.id} className={`flex ${isAdmin ? 'justify-end' : 'justify-start'} mb-1`}>
                    <div className={`
                      min-w-[85px] max-w-[85%] lg:max-w-[70%] relative px-3 py-1.5 shadow-sm
                      ${isAdmin 
                        ? 'bg-[#DCF8C6] text-slate-800 rounded-lg rounded-tr-none' 
                        : 'bg-white text-slate-800 rounded-lg rounded-tl-none'}
                    `}>
                      <p className="text-sm leading-relaxed pr-14 pb-1">{msg.text}</p>
                      <div className="absolute bottom-1 right-2 flex items-center gap-1">
                        <span className="text-[9px] text-slate-400 font-medium uppercase">
                          {msg.timestamp?.toDate ? new Date(msg.timestamp.toDate()).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true }) : '...'}
                        </span>
                        {isAdmin && (
                           <CheckCheck size={12} className="text-sky-500" />
                        )}
                      </div>
                      
                      {/* Tail Decor */}
                      {isLastInGroup && (
                        <div className={`
                          absolute top-0 w-3 h-3
                          ${isAdmin 
                            ? 'right-[-8px] bg-[#DCF8C6]' 
                            : 'left-[-8px] bg-white'}
                        `} style={{ clipPath: isAdmin ? 'polygon(0 0, 0% 100%, 100% 0)' : 'polygon(100% 0, 100% 100%, 0 0)' }} />
                      )}
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Input Bar */}
            <div className="p-3 bg-[#F0F4F2] z-10">
              <form onSubmit={handleSendMessage} className="flex items-center gap-2 max-w-4xl mx-auto">
                <div className="flex-1 bg-white rounded-full px-4 py-2 flex items-center shadow-sm border border-slate-200">
                  <input
                    type="text"
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    placeholder="Type a message"
                    className="flex-1 bg-transparent border-none text-sm focus:ring-0 outline-none py-1"
                  />
                </div>
                <button
                  type="submit"
                  disabled={!newMessage.trim()}
                  className="w-12 h-12 bg-[#00A884] hover:bg-[#008F6F] disabled:bg-slate-300 text-white rounded-full flex items-center justify-center shadow-md transition-all active:scale-95 shrink-0"
                >
                  <Send className="w-5 h-5" />
                </button>
              </form>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center text-center p-12 text-slate-400 relative z-10">
            <div className="w-32 h-32 bg-white rounded-full flex items-center justify-center mb-8 shadow-xl border-t-4 border-emerald-500">
              <ShieldCheck size={64} className="text-emerald-500 opacity-80" />
            </div>
            <h3 className="text-2xl font-black text-slate-800 mb-2">Rankearn Support</h3>
            <p className="text-sm max-w-xs font-medium text-slate-500 leading-relaxed">
              Select a conversation to start chatting. <br/> Manage all user queries in real-time.
            </p>
            <div className="mt-12 flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest bg-white/50 px-4 py-2 rounded-full">
               <Clock size={14} />
               End-to-end Encrypted
            </div>
          </div>
        )}
      </div>
    </div>
    
    {/* Custom Confirmation Modal */}
    <AnimatePresence>
      {showClearConfirm && (
        <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="bg-white rounded-3xl shadow-2xl w-full max-w-sm overflow-hidden border border-slate-100"
          >
            <div className="p-8 text-center space-y-6">
              <div className="w-20 h-20 bg-rose-50 text-rose-500 rounded-3xl flex items-center justify-center mx-auto shadow-sm">
                <AlertTriangle size={40} />
              </div>

              <div className="space-y-2">
                <h3 className="text-xl font-black text-slate-900 uppercase tracking-tight">Clear Chat?</h3>
                <p className="text-xs text-slate-500 font-bold leading-relaxed px-4">
                  Permanently delete all messages for <span className="text-slate-900 font-black">{selectedTicket?.userName}</span>?
                </p>
              </div>

              <div className="flex flex-col gap-3">
                <button
                  onClick={handleClearChat}
                  disabled={isClearing}
                  className="w-full py-4 bg-rose-500 hover:bg-rose-600 text-white font-black rounded-2xl transition-all shadow-lg shadow-rose-100 uppercase tracking-widest text-xs flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  {isClearing ? 'Clearing...' : 'Clear Everything'}
                </button>
                <button
                  onClick={() => setShowClearConfirm(false)}
                  disabled={isClearing}
                  className="w-full py-4 bg-slate-100 text-slate-500 hover:bg-slate-200 font-black rounded-2xl text-xs uppercase tracking-widest transition-all"
                >
                  Cancel
                </button>
              </div>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  </>
);
};

export default AdminSupport;
