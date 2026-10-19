import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, getDocs, doc, updateDoc, arrayUnion, increment, onSnapshot, orderBy, limit } from 'firebase/firestore';
import { Poll, UserProfile } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { CheckCircle2, Users, Clock, AlertCircle } from 'lucide-react';

interface PollWidgetProps {
  profile: UserProfile | null;
}

const PollWidget: React.FC<PollWidgetProps> = ({ profile }) => {
  const [activePoll, setActivePoll] = useState<Poll | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasVoted, setHasVoted] = useState(false);
  const [isVoting, setIsVoting] = useState(false);
  const [showResults, setShowResults] = useState(false);
  const [votedOption, setVotedOption] = useState<number | null>(null);

  useEffect(() => {
    // Fetch the latest active poll
    const pollsRef = collection(db, 'polls');
    const q = query(
      pollsRef,
      where('isActive', '==', true),
      orderBy('createdAt', 'desc'),
      limit(1)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      if (!snapshot.empty) {
        const pollData = { id: snapshot.docs[0].id, ...snapshot.docs[0].data() } as Poll;
        
        // Check if poll has expired
        if (pollData.expiresAt && new Date(pollData.expiresAt) < new Date()) {
          setActivePoll(null);
        } else {
          setActivePoll(pollData);
          // Check if user has already voted
          if (profile && pollData.voters?.includes(profile.userId)) {
            setHasVoted(true);
            setShowResults(true);
            const savedVote = localStorage.getItem(`poll_vote_${profile.userId}_${pollData.id}`);
            if (savedVote !== null) {
              setVotedOption(parseInt(savedVote, 10));
            } else {
              // Smart fallback: if localStorage is empty but only one option has votes, assume it's the voted option (helps restore state for existing votes)
              const voteKeys = Object.keys(pollData.votes || {});
              const activeVotes = voteKeys.filter(k => (pollData.votes?.[parseInt(k, 10)] || 0) > 0);
              if (activeVotes.length === 1) {
                setVotedOption(parseInt(activeVotes[0], 10));
              } else {
                setVotedOption(null);
              }
            }
          } else {
            setHasVoted(false);
            setShowResults(false);
            setVotedOption(null);
          }
        }
      } else {
        setActivePoll(null);
      }
      setIsLoading(false);
    });

    return () => unsubscribe();
  }, [profile]);

  const handleVote = async (optionIndex: number) => {
    if (!profile || !activePoll || hasVoted || isVoting) return;

    setIsVoting(true);
    try {
      const pollRef = doc(db, 'polls', activePoll.id);
      
      // Atomic update: increment vote count and add user to voters list
      await updateDoc(pollRef, {
        [`votes.${optionIndex}`]: increment(1),
        voters: arrayUnion(profile.userId)
      });

      // Save user's vote locally with a user-specific key
      localStorage.setItem(`poll_vote_${profile.userId}_${activePoll.id}`, optionIndex.toString());
      setVotedOption(optionIndex);

      setHasVoted(true);
      setShowResults(true);
    } catch (error) {
      console.error("Error voting:", error);
    } finally {
      setIsVoting(false);
    }
  };

  if (isLoading) return null;
  if (!activePoll) return null;

  // Filter by target segment
  if (activePoll.targetSegment !== 'all') {
    if (activePoll.targetSegment === 'pro' && profile?.subscriptionStatus !== 'premium') return null;
    if (activePoll.targetSegment === 'free' && profile?.subscriptionStatus === 'premium') return null;
  }

  const totalVotes = (Object.values(activePoll.votes || {}) as number[]).reduce((a, b) => a + b, 0);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="w-full bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden"
    >
      <div className="p-6 md:p-8">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center">
              <Users size={20} />
            </div>
            <div>
              <h3 className="text-lg font-black text-slate-900 leading-none">Community Poll</h3>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1.5">Have your say</p>
            </div>
          </div>
          {activePoll.expiresAt && (
            <div className="flex items-center gap-1.5 px-3 py-1 bg-amber-50 text-amber-600 rounded-full border border-amber-100">
              <Clock size={12} />
              <span className="text-[10px] font-bold uppercase">
                Ends {new Date(activePoll.expiresAt).toLocaleDateString()}
              </span>
            </div>
          )}
        </div>
        <div className="h-px bg-slate-100 -mx-6 md:-mx-8 mb-6" />

        <h4 className="text-lg font-semibold font-tiro text-slate-800 mb-6 leading-tight">
          {activePoll.question}
        </h4>

        <div className="space-y-3">
          {activePoll.options.map((option, idx) => {
            const voteCount = activePoll.votes?.[idx] || 0;
            const percentage = totalVotes > 0 ? Math.round((voteCount / totalVotes) * 100) : 0;
            
            return (
              <button
                key={idx}
                disabled={hasVoted || isVoting}
                onClick={() => handleVote(idx)}
                className={`w-full relative group transition-all ${hasVoted ? 'cursor-default' : 'hover:scale-[1.01] active:scale-[0.99]'}`}
              >
                {/* Background Progress Bar */}
                {showResults && (
                  <div className="absolute inset-0 bg-slate-50 rounded-xl overflow-hidden">
                    <motion.div
                      initial={{ width: 0 }}
                      animate={{ width: `${percentage}%` }}
                      transition={{ duration: 1, ease: "easeOut" }}
                      className="h-full bg-emerald-500/10 border-r-2 border-emerald-500/20"
                    />
                  </div>
                )}

                <div className={`
                  relative z-10 flex items-center justify-between p-4 rounded-xl border-2 transition-all
                  ${hasVoted 
                    ? 'border-transparent' 
                    : 'border-slate-100 bg-white hover:border-emerald-500 group-hover:shadow-md group-hover:shadow-emerald-500/5'}
                `}>
                  <div className="flex items-center gap-3 min-w-0">
                    <div className={`
                      w-6 h-6 rounded-full flex items-center justify-center text-xs font-black shrink-0 transition-all
                      ${hasVoted 
                        ? (votedOption === idx ? 'bg-emerald-500 text-white' : 'bg-slate-100 text-black')
                        : 'bg-slate-100 text-black group-hover:bg-emerald-500 group-hover:text-white'}
                    `}>
                      {String.fromCharCode(65 + idx)}
                    </div>
                    <span className={`text-sm font-bold font-tiro truncate ${hasVoted ? 'text-slate-700' : 'text-slate-600'}`}>
                      {option}
                    </span>
                  </div>
                  
                  {showResults && (
                    <div className="flex items-center gap-3">
                      <span className="text-sm font-black text-emerald-600">{percentage}%</span>
                      {hasVoted && votedOption === idx && (
                        <CheckCircle2 size={16} className="text-emerald-500" />
                      )}
                    </div>
                  )}
                </div>
              </button>
            );
          })}
        </div>

        <div className="mt-6 pt-6 border-t border-slate-50 flex items-center justify-between">
          <div className="flex items-center gap-2 text-slate-400">
            <Users size={14} />
            <span className="text-[11px] font-bold uppercase tracking-wider">{totalVotes.toLocaleString()} Votes</span>
          </div>
          
          {hasVoted && (
            <button 
              onClick={() => setShowResults(!showResults)}
              className="text-[11px] font-black text-emerald-600 uppercase tracking-widest hover:underline"
            >
              {showResults ? 'Hide Results' : 'View Results'}
            </button>
          )}
        </div>
      </div>
    </motion.div>
  );
};

export default PollWidget;
