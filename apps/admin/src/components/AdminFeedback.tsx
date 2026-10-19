import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, orderBy, onSnapshot, limit } from 'firebase/firestore';
import { Feedback } from '../types';
import { Star, MessageSquare, User, Clock, Search, TrendingUp } from 'lucide-react';
import { motion } from 'motion/react';

const AdminFeedback = () => {
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [stats, setStats] = useState({
    average: 0,
    total: 0,
    fiveStars: 0
  });

  useEffect(() => {
    const q = query(collection(db, 'feedbacks'), orderBy('timestamp', 'desc'), limit(100));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetched = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Feedback[];
      setFeedbacks(fetched);
      
      // Calculate basic stats
      if (fetched.length > 0) {
        const total = fetched.length;
        const sum = fetched.reduce((acc, f) => acc + f.rating, 0);
        const fiveStars = fetched.filter(f => f.rating === 5).length;
        setStats({
          average: Number((sum / total).toFixed(1)),
          total,
          fiveStars
        });
      }
      setIsLoading(false);
    });
    return () => unsubscribe();
  }, []);

  return (
    <div className="space-y-6">
      {/* Stats Section */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center gap-4">
          <div className="w-14 h-14 bg-amber-50 rounded-2xl flex items-center justify-center">
            <Star className="text-amber-500 fill-amber-500" size={28} />
          </div>
          <div>
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Avg. Rating</p>
            <p className="text-2xl font-black text-slate-900">{stats.average} / 5.0</p>
          </div>
        </div>
        <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center gap-4">
          <div className="w-14 h-14 bg-emerald-50 rounded-2xl flex items-center justify-center">
            <MessageSquare className="text-emerald-500" size={28} />
          </div>
          <div>
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Total Reviews</p>
            <p className="text-2xl font-black text-slate-900">{stats.total}</p>
          </div>
        </div>
        <div className="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center gap-4">
          <div className="w-14 h-14 bg-blue-50 rounded-2xl flex items-center justify-center">
            <TrendingUp className="text-blue-500" size={28} />
          </div>
          <div>
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Perfect 5s</p>
            <p className="text-2xl font-black text-slate-900">{stats.fiveStars}</p>
          </div>
        </div>
      </div>

      {/* Feedback List */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xl overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-xl font-black text-slate-900 flex items-center gap-2">
            <Star className="text-amber-500" />
            User Feedback
          </h2>
          <div className="flex items-center gap-4">
             <div className="hidden md:flex items-center gap-2 px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl">
               <Search size={14} className="text-slate-400" />
               <input type="text" placeholder="Search comments..." className="bg-transparent border-none outline-none text-xs font-medium w-40" />
             </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-100">
              <tr>
                <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">User</th>
                <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Rating</th>
                <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Comment</th>
                <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-right">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {isLoading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-20 text-center text-slate-400 font-bold uppercase tracking-widest text-xs">
                    Loading Feedbacks...
                  </td>
                </tr>
              ) : feedbacks.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-20 text-center text-slate-400">
                    No feedback received yet.
                  </td>
                </tr>
              ) : (
                feedbacks.map((f) => (
                  <tr key={f.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center">
                          <User size={14} className="text-slate-500" />
                        </div>
                        <span className="font-bold text-slate-800 text-sm">{f.userName}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1">
                        {[1, 2, 3, 4, 5].map((s) => (
                          <Star 
                            key={s} 
                            size={12} 
                            className={`${s <= f.rating ? 'text-amber-500 fill-amber-500' : 'text-slate-200 fill-slate-100'}`} 
                          />
                        ))}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs text-slate-600 font-medium max-w-md line-clamp-2 italic">
                        "{f.comment}"
                      </p>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className="text-[10px] font-bold text-slate-400 flex items-center justify-end gap-1.5">
                        <Clock size={12} />
                        {f.timestamp?.toDate ? 
                          (() => {
                            const d = f.timestamp.toDate();
                            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            const day = String(d.getDate()).padStart(2, '0');
                            const month = months[d.getMonth()];
                            const year = String(d.getFullYear()).slice(-2);
                            return `${day} ${month} ${year}`;
                          })() : 'Just now'}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default AdminFeedback;
