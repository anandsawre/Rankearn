import React, { useState } from 'react';
import { db } from '../firebase';
import { collection, addDoc, serverTimestamp } from 'firebase/firestore';
import { UserProfile } from '../types';
import { Star, Send, CheckCircle2, MessageSquare } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { useToast } from './Toast';

interface FeedbackProps {
  profile: UserProfile;
}

const Feedback: React.FC<FeedbackProps> = ({ profile }) => {
  const [rating, setRating] = useState(0);
  const [hoveredRating, setHoveredRating] = useState(0);
  const [comment, setComment] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const { showToast } = useToast();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (rating === 0) {
      showToast('Please select a rating', 'warning');
      return;
    }
    if (!comment.trim()) {
      showToast('Please enter a comment', 'warning');
      return;
    }

    setIsSubmitting(true);
    try {
      await addDoc(collection(db, 'feedbacks'), {
        userId: profile.userId,
        userName: profile.name,
        rating,
        comment: comment.trim(),
        timestamp: serverTimestamp()
      });
      setIsSubmitted(true);
      showToast('Thank you for your feedback!', 'success');
    } catch (error) {
      console.error('Error submitting feedback:', error);
      showToast('Failed to submit feedback', 'error');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isSubmitted) {
    return (
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-white rounded-3xl p-12 text-center shadow-xl border border-slate-100 flex flex-col items-center justify-center min-h-[400px]"
      >
        <div className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mb-6 shadow-inner">
          <CheckCircle2 className="w-10 h-10 text-emerald-600" />
        </div>
        <h2 className="text-2xl font-black text-slate-900 mb-2">Feedback Received!</h2>
        <p className="text-slate-500 max-w-xs mx-auto mb-8">
          Your feedback helps us make Rankearn better for everyone. We appreciate your time!
        </p>
        <button
          onClick={() => {
            setRating(0);
            setComment('');
            setIsSubmitted(false);
          }}
          className="px-8 py-3 bg-slate-100 text-slate-600 font-bold rounded-xl hover:bg-slate-200 transition-all"
        >
          Send More Feedback
        </button>
      </motion.div>
    );
  }

  return (
    <div className="bg-white rounded-3xl shadow-xl border border-slate-100 overflow-hidden">
      <div className="bg-emerald-500 p-8 text-center text-white relative overflow-hidden">
        {/* Decorative elements */}
        <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full blur-3xl -mr-16 -mt-16" />
        <div className="absolute bottom-0 left-0 w-32 h-32 bg-emerald-400/20 rounded-full blur-3xl -ml-16 -mb-16" />
        
        <div className="relative">
          <div className="w-16 h-16 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center mx-auto mb-4 border border-white/30">
            <MessageSquare className="w-8 h-8 text-white" />
          </div>
          <h2 className="text-2xl font-black mb-1">Share Your Feedback</h2>
          <p className="text-emerald-100/80 text-sm font-medium">How is your experience with Rankearn?</p>
        </div>
      </div>

      <div className="p-8 md:p-12">
        <form onSubmit={handleSubmit} className="space-y-8">
          {/* Rating Section */}
          <div className="text-center">
            <label className="block text-slate-400 text-[10px] font-black uppercase tracking-widest mb-4">Rate your experience</label>
            <div className="flex items-center justify-center gap-3">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onMouseEnter={() => setHoveredRating(star)}
                  onMouseLeave={() => setHoveredRating(0)}
                  onClick={() => setRating(star)}
                  className="transition-all transform hover:scale-110 active:scale-95"
                >
                  <Star
                    size={40}
                    className={`transition-all ${
                      (hoveredRating || rating) >= star 
                        ? 'fill-amber-400 text-amber-400 drop-shadow-[0_0_8px_rgba(245,158,11,0.3)]' 
                        : 'text-slate-200 fill-slate-50'
                    }`}
                  />
                </button>
              ))}
            </div>
            <div className="mt-3">
              <span className="text-sm font-bold text-slate-600">
                {rating === 1 && "Terrible 😞"}
                {rating === 2 && "Bad 😕"}
                {rating === 3 && "Okay 😐"}
                {rating === 4 && "Good 🙂"}
                {rating === 5 && "Excellent! 😍"}
              </span>
            </div>
          </div>

          {/* Comment Section */}
          <div className="space-y-3">
            <label className="block text-slate-400 text-[10px] font-black uppercase tracking-widest px-1">Your comments</label>
            <textarea
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Tell us what you like or how we can improve..."
              className="w-full h-32 bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-slate-700 font-medium focus:border-emerald-500 outline-none transition-all resize-none no-scrollbar"
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 text-white py-4 rounded-2xl font-black text-lg shadow-lg shadow-emerald-200 transition-all flex items-center justify-center gap-3 active:scale-[0.98]"
          >
            {isSubmitting ? (
              <>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                  className="w-5 h-5 border-2 border-white border-t-transparent rounded-full"
                />
                Submitting...
              </>
            ) : (
              <>
                <Send className="w-5 h-5" />
                Submit Feedback
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Feedback;
