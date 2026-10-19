import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'motion/react';
import { doc, runTransaction, serverTimestamp, collection, addDoc, getDocs, updateDoc, arrayUnion, getDoc, query, where, onSnapshot, deleteDoc, orderBy, limit, setDoc, increment } from 'firebase/firestore';
import { db } from '../../firebase';
import { useToast } from '../Toast';
import { UserProfile } from '../../types';
import {
  Swords, Zap, Trophy, X, Shield, ShieldCheck, Clock, Timer, IndianRupee, ArrowRight, User as UserIcon, AlertCircle, Coins, Check, RefreshCw, CheckCircle, ChevronRight, Share2
} from 'lucide-react';
import { getRandomBattleQuestions } from './battleQuestions';
import { BattleQuestion } from '../../types';
import confetti from 'canvas-confetti';
import { shareContent, getDomainFriendlyOrigin } from '../../utils/shareUtils';

interface BattleMainProps {
  user: any;
  profile: UserProfile | null;
  onClose?: () => void;
}

// Hardcoded fallback removed as we now use Firestore bots collection.

const getWorkerUrl = async (): Promise<string> => {
  let stored = localStorage.getItem('cfWorkerUrl');
  if (!stored) {
    try {
      const docSnap = await getDoc(doc(db, 'configs', 'ai_worker'));
      if (docSnap.exists()) {
        stored = docSnap.data()?.url;
        if (stored) {
          localStorage.setItem('cfWorkerUrl', stored);
        }
      }
    } catch (e) {
      console.error('Error fetching worker config from db:', e);
    }
  }
  return (stored || (import.meta as any).env?.VITE_WORKER_URL || 'https://rankearn.thesmartrankers.workers.dev').replace(/\/$/, '');
};


export default function BattleMain({ user, profile, onClose }: BattleMainProps) {
  const { showToast } = useToast();

  if (!user || !profile) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center min-h-[60vh] bg-white rounded-2xl border border-slate-100 p-8 shadow-sm">
        <div className="relative mb-6">
          <div className="w-16 h-16 border-4 border-slate-100 rounded-full" />
          <div className="absolute inset-0 w-16 h-16 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin" />
        </div>
        <h3 className="text-xl font-black text-slate-900 mb-2 uppercase tracking-tight">Syncing Battle Data</h3>
        <p className="text-slate-400 font-bold text-xs uppercase tracking-widest animate-pulse">Initializing 1v1 Environment...</p>
      </div>
    );
  }

  const [phase, setPhase] = useState<'lobby' | 'searching' | 'battle' | 'waiting' | 'result'>('lobby');
  const [entryFee, setEntryFee] = useState<number>(10);
  const [bot, setBot] = useState<any>(null);
  const { inviteId } = useParams<{ inviteId: string }>();
  const navigate = useNavigate();
  const [isInviting, setIsInviting] = useState(false);
  const [isInvitationWaiting, setIsInvitationWaiting] = useState(false);

  // Battle State
  const [questions, setQuestions] = useState<BattleQuestion[]>([]);
  const [currentQIndex, setCurrentQIndex] = useState(0);
  const [timeLeft, setTimeLeft] = useState(10);
  const [matchStartTime, setMatchStartTime] = useState<number | null>(null);
  const [userScore, setUserScore] = useState(0);
  const [botScore, setBotScore] = useState(0);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [isAnswerRevealed, setIsAnswerRevealed] = useState(false);
  const [matchResult, setMatchResult] = useState<'win' | 'loss' | 'draw' | null>(null);
  const [userAnswers, setUserAnswers] = useState<Record<string, number | null>>({});
  const [userTimes, setUserTimes] = useState<Record<string, number>>({});
  const [botCorrectCount, setBotCorrectCount] = useState(0);
  const [language, setLanguage] = useState<'en' | 'hi'>('hi');
  const [battleConfig, setBattleConfig] = useState({
    totalQuestions: 5,
    timePerQuestion: 10,
    botAccuracy: 0.65,
    entryStakes: [10, 50, 100],
    prizeMultiplier: 1.8
  });

  // Real Match State
  const [isBotMatch, setIsBotMatch] = useState(true);
  const isBotMatchRef = useRef(true); // Critical: using ref for immediate logic checks
  const isMatchFoundRef = useRef(false);
  const [battleId, setBattleId] = useState<string | null>(null);
  const [opponentData, setOpponentData] = useState<any>(null);
  const [matchmakingId, setMatchmakingId] = useState<string | null>(null);
  const hasJoinedInviteRef = useRef(false);

  const [isTransitioning, setIsTransitioning] = useState(false);
  const botTimerRef = useRef<any>(null);
  const userScoreRef = useRef(0);
  const botScoreRef = useRef(0);

  // Sync refs for score only
  useEffect(() => { userScoreRef.current = userScore; }, [userScore]);
  useEffect(() => { botScoreRef.current = botScore; }, [botScore]);

  // Sync Global Battle State for App Navigation
  useEffect(() => {
    const activePhases = ['searching', 'battle', 'waiting'];
    if (activePhases.includes(phase)) {
      (window as any).isBattleActive = true;
    } else {
      (window as any).isBattleActive = false;
    }
    return () => { (window as any).isBattleActive = false; };
  }, [phase]);

  // Fetch Global Battle Settings
  useEffect(() => {
    const fetchBattleConfig = async () => {
      try {
        const docRef = doc(db, 'configs', 'battle_settings');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          const data = docSnap.data();
          setBattleConfig({
            totalQuestions: Math.max(1, data.totalQuestions || 5),
            timePerQuestion: Math.max(5, data.timePerQuestion || 10),
            botAccuracy: Math.min(1, Math.max(0, data.botAccuracy || 0.65)),
            entryStakes: data.entryStakes || [10, 50, 100],
            prizeMultiplier: data.prizeMultiplier || 1.8
          });
          
          // Set default entry fee from the first available stake if not already set
          if (data.entryStakes && data.entryStakes.length > 0) {
             setEntryFee(data.entryStakes[0]);
          }
        }
      } catch (err) {
        console.error("Failed to fetch battle settings:", err);
      }
    };
    fetchBattleConfig();
  }, []);

  // Handle Invitation Link
  useEffect(() => {
    if (inviteId && profile && !hasJoinedInviteRef.current) {
      hasJoinedInviteRef.current = true;
      handleJoinInvite(inviteId);
    }
  }, [inviteId, !!profile]);

  const handleJoinInvite = async (invId: string) => {
    try {
      const bRef = doc(db, 'battles', invId);
      const bSnap = await getDoc(bRef);
      if (!bSnap.exists()) {
        showToast("Battle not found or expired", "error");
        navigate('/battle');
        return;
      }

      const data = bSnap.data();
      if (data.status !== 'waiting') {
        if (data.players.includes(user.uid)) {
           // We are the creator returning? If it's already live, rejoin
           if (data.status === 'live' && data.opponentInfo) {
              await startRealMatch(invId, data.opponentInfo, true);
              return;
           }
        }
        showToast("Battle is already full or finished", "error");
        navigate('/battle');
        return;
      }

      if (data.players.includes(user.uid)) {
        // We are the creator waiting
        setBattleId(invId);
        setPhase('searching');
        setIsInvitationWaiting(true);
        listenForPlayerTwo(invId);
        return;
      }

      // Try to join (Deduct coins first)
      if (profile.coins < data.entryFee) {
        showToast(`Insufficient coins! You need ${data.entryFee} coins.`, "error");
        navigate('/battle');
        return;
      }

      await runTransaction(db, async (tx) => {
        const uRef = doc(db, 'users', user.uid);
        const uDoc = await tx.get(uRef);
        if (!uDoc.exists()) throw "User not found";
        const currentCoins = uDoc.data().coins || 0;
        if (currentCoins < data.entryFee) throw "Insufficient coins";

        const bDoc = await tx.get(bRef);
        const bData = bDoc.data();
        
        // If user is already in this battle, don't throw error, just continue
        if (bData?.players?.includes(user.uid)) return;
        
        if (bData?.status !== 'waiting') throw "Battle already joined";

        const newBalance = currentCoins - data.entryFee;
        tx.update(uRef, { coins: newBalance });
        
        // Add Transaction Record
        const transRef = doc(collection(db, 'transactions'));
        tx.set(transRef, {
          userId: user.uid,
          amount: -data.entryFee,
          type: 'spend',
          category: 'battle_entry',
          testTitle: 'Joined 1v1 Battle',
          currentBalance: newBalance,
          timestamp: serverTimestamp()
        });

        tx.update(bRef, {
          status: 'live',
          players: arrayUnion(user.uid),
          [`scores.${user.uid}`]: 0,
          opponentInfo: {
            userId: user.uid,
            name: profile.name,
            avatar: profile.profilePhoto || `https://ui-avatars.com/api/?name=${profile.name}`
          }
        });
      });

      // Joined successfully!
      const opponentId = data.players[0];
      const oppDoc = await getDoc(doc(db, 'users', opponentId));
      const oppData = oppDoc.data() as UserProfile;

      await startRealMatch(invId, {
        userId: opponentId,
        name: oppData.name,
        avatar: oppData.profilePhoto || `https://ui-avatars.com/api/?name=${oppData.name}`
      }, false);

    } catch (e) {
      console.error("Join invite failed", e);
      showToast(typeof e === 'string' ? e : "Failed to join battle", "error");
      navigate('/battle');
    }
  };

  const listenForPlayerTwo = (bId: string) => {
    const unsub = onSnapshot(doc(db, 'battles', bId), async (snap) => {
      if (snap.exists()) {
        const data = snap.data();
        if (data.status === 'live' && data.players.length === 2 && data.opponentInfo) {
          unsub();
          await startRealMatch(bId, data.opponentInfo, true);
        }
      }
    });
    return unsub;
  };

  const handleCancelInvite = async () => {
    if (!battleId || !isInvitationWaiting) {
      setPhase('lobby');
      return;
    }

    try {
      await runTransaction(db, async (tx) => {
        const bRef = doc(db, 'battles', battleId);
        const uRef = doc(db, 'users', user.uid);
        
        const bSnap = await tx.get(bRef);
        if (!bSnap.exists()) return;
        
        const bData = bSnap.data();
        if (bData.status !== 'waiting') throw "Battle already started or finished";

        const uDoc = await tx.get(uRef);
        const currentCoins = uDoc.data().coins || 0;

        const newBalance = currentCoins + entryFee;
        tx.update(uRef, { coins: newBalance });

        // Add Transaction Record
        const transRef = doc(collection(db, 'transactions'));
        tx.set(transRef, {
          userId: user.uid,
          amount: entryFee,
          type: 'earn',
          category: 'battle_refund',
          testTitle: '1v1 Battle Refund',
          currentBalance: newBalance,
          timestamp: serverTimestamp()
        });

        tx.delete(bRef);
      });

      showToast("Invitation cancelled. Coins refunded!", "success");
      setPhase('lobby');
      setBattleId(null);
      setIsInvitationWaiting(false);
      hasJoinedInviteRef.current = false;
    } catch (e) {
      console.error("Cancel invite failed", e);
      showToast(typeof e === 'string' ? e : "Failed to cancel invitation", "error");
    }
  };

  const handleInviteFriend = async () => {
    if (profile.coins < entryFee) {
      showToast(`Insufficient coins! You need ${entryFee} coins.`, "error");
      return;
    }

    setIsInviting(true);
    try {
      const bId = `battle_inv_${user.uid.slice(0, 5)}_${Date.now()}`;
      const qList = getRandomBattleQuestions(); // Use the generator

      await runTransaction(db, async (tx) => {
        const uRef = doc(db, 'users', user.uid);
        const uDoc = await tx.get(uRef);
        if (!uDoc.exists()) throw "User not found";
        const currentCoins = uDoc.data().coins || 0;
        if (currentCoins < entryFee) throw "Insufficient coins";

        const newBalance = currentCoins - entryFee;
        tx.update(uRef, { coins: newBalance });

        // Add Transaction Record
        const transRef = doc(collection(db, 'transactions'));
        tx.set(transRef, {
          userId: user.uid,
          amount: -entryFee,
          type: 'spend',
          category: 'battle_entry',
          testTitle: '1v1 Battle Invitation',
          currentBalance: newBalance,
          timestamp: serverTimestamp()
        });

        tx.set(doc(db, 'battles', bId), {
          id: bId,
          status: 'waiting',
          creatorId: user.uid,
          players: [user.uid],
          questions: qList,
          entryFee,
          scores: { [user.uid]: 0 },
          createdAt: serverTimestamp()
        });
      });

      const inviteLink = `${getDomainFriendlyOrigin()}/battle/${bId}`;
      const result = await shareContent({
        title: "Challenge me in 1v1 Rapid Battle!",
        text: `Hey! I challenge you for a ${entryFee} Coin Battle on Rankearn. Join using my link:`,
        url: inviteLink
      });

      if (result.success) {
        showToast(result.method === 'native' ? "Invite sent!" : "Link copied!", "success");
        setBattleId(bId);
        setIsInvitationWaiting(true);
        setPhase('searching');
        listenForPlayerTwo(bId);
      } else {
        // If they cancelled sharing, we should probably refund or at least stay in lobby
        // but for now we just show the link copy option or stay put.
      }

    } catch (e) {
      console.error("Invite failed", e);
      showToast("Failed to create invitation", "error");
    } finally {
      setIsInviting(false);
    }
  };
  
  // Background-Safe Timer Sync
  useEffect(() => {
    if (phase !== 'battle' || isAnswerRevealed || isTransitioning) {
      if (phase !== 'battle') setMatchStartTime(null);
      return;
    }

    const syncGame = () => {
      if (!matchStartTime) {
        setMatchStartTime(Date.now());
        return;
      }

      const elapsed = (Date.now() - matchStartTime) / 1000;
      const actualTimeLeft = Math.max(0, Math.ceil(battleConfig.timePerQuestion - elapsed));
      
      setTimeLeft(actualTimeLeft);

      if (actualTimeLeft === 0 && !isAnswerRevealed) {
        handleTimeUp();
      }
    };

    const id = setInterval(syncGame, 1000);
    return () => clearInterval(id);
  }, [phase, isAnswerRevealed, isTransitioning, matchStartTime, battleConfig]);

  const handleTimeUp = () => {
    if (isAnswerRevealed || isTransitioning) return;
    setIsAnswerRevealed(true);
    
    // Save user's answer and time
    const currentQ = questions[currentQIndex];
    if (currentQ) {
      setUserAnswers(prev => ({ ...prev, [currentQ.id]: null }));
      setUserTimes(prev => ({ ...prev, [currentQ.id]: 0 }));
    }

    // Penalty for not answering
    setUserScore(prev => Math.max(0, prev - 25));
    
    setTimeout(() => {
      if (currentQIndex < battleConfig.totalQuestions - 1) {
        setCurrentQIndex(prev => prev + 1);
        startQuestionTimer();
      } else {
        finishBattle();
      }
    }, 1500);
  };



  // Sound effects (optional, can be added later)

  const isTransitioningRef = useRef(false);

  useEffect(() => {
    isTransitioningRef.current = isTransitioning;
  }, [isTransitioning]);

  const handleStartSearch = async () => {
    if (phase !== 'lobby' && phase !== 'result') return;

    if (!profile || profile.coins < entryFee) {
      showToast("Not enough coins to enter this battle!", "error");
      return;
    }

    // Reset States
    setBot(null);
    setOpponentData(null);
    setIsBotMatch(true);
    isBotMatchRef.current = true;
    isMatchFoundRef.current = false;
    setBattleId(null);
    setMatchResult(null);
    setUserScore(0);
    setBotScore(0);
    setCurrentQIndex(0);
    userScoreRef.current = 0;
    botScoreRef.current = 0;
    setIsAnswerRevealed(false);
    setSelectedOption(null);
    setUserAnswers({});
    setUserTimes({});
    setBotCorrectCount(0);
    setPhase('searching');
    isTransitioningRef.current = false;
    setIsTransitioning(false);

    let mmDocId: string | null = null;
    let isMatchFound = false;

    try {
      // 1. Deduct coins immediately
      await runTransaction(db, async (transaction) => {
        const userRef = doc(db, 'users', user.uid);
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists()) throw "User not found";
 
        const currentCoins = userDoc.data().coins || 0;
        if (currentCoins < entryFee) throw "Insufficient coins";

        const newBalance = currentCoins - entryFee;
        transaction.update(userRef, { coins: newBalance });
        
        // Add Transaction Record
        const transRef = doc(collection(db, 'transactions'));
        transaction.set(transRef, {
          userId: user.uid,
          amount: -entryFee,
          type: 'spend',
          category: 'battle_entry',
          testTitle: '1v1 Battle Entry Fee',
          currentBalance: newBalance,
          timestamp: serverTimestamp()
        });
      });

      // 2. Create Matchmaking Entry
      const mmRef = await addDoc(collection(db, 'matchmaking'), {
        userId: user.uid,
        name: profile.name,
        avatar: profile.profilePhoto || `https://ui-avatars.com/api/?name=${profile.name}`,
        entryFee,
        status: 'waiting',
        timestamp: serverTimestamp()
      });
      mmDocId = mmRef.id;
      setMatchmakingId(mmDocId);

      // 3. Set a 10s timeout for Bot Fallback
      const timeoutPromise = new Promise((resolve) => {
        setTimeout(async () => {
          if (!isMatchFoundRef.current) {
            console.log("Matchmaking timeout - switching to Bot");
            if (mmDocId) {
              await deleteDoc(doc(db, 'matchmaking', mmDocId)).catch(() => { });
            }
            resolve('timeout');
          }
        }, 10000);
      });

      // 4. Listen for Match (Someone else pairs with us)
      const unsubMM = onSnapshot(doc(db, 'matchmaking', mmDocId), async (snap) => {
        if (snap.exists() && snap.data().status === 'matched' && !isMatchFoundRef.current) {
          isMatchFoundRef.current = true;
          const data = snap.data();
          await startRealMatch(data.battleId, data.opponentInfo, false); // We are the "joined" one
          unsubMM();
        }
      });

      // 5. Try to find an existing waiting user
      const findMatch = async () => {
        if (isMatchFoundRef.current) return;
        const qMM = query(
          collection(db, 'matchmaking'),
          where('status', '==', 'waiting'),
          where('entryFee', '==', entryFee),
          orderBy('timestamp', 'asc'),
          limit(5)
        );

        const snapshot = await getDocs(qMM);
        for (const docSnap of snapshot.docs) {
          const otherUser = docSnap.data();
          if (docSnap.id !== mmDocId && otherUser.userId !== user.uid && !isMatchFoundRef.current) {
            const bId = `battle_${Date.now()}_${user.uid.slice(0, 5)}`;

            try {
              // Try to pair using transaction
              await runTransaction(db, async (transaction) => {
                const otherRef = doc(db, 'matchmaking', docSnap.id);
                const myRef = doc(db, 'matchmaking', mmDocId!);

                const otherSnap = await transaction.get(otherRef);
                if (otherSnap.data()?.status !== 'waiting') return; // Someone else got them first

                transaction.update(otherRef, {
                  status: 'matched',
                  battleId: bId,
                  opponentInfo: { userId: user.uid, name: profile.name, avatar: profile.profilePhoto || `https://ui-avatars.com/api/?name=${profile.name}` }
                });

                transaction.update(myRef, {
                  status: 'matched',
                  battleId: bId,
                  opponentInfo: { userId: otherUser.userId, name: otherUser.name, avatar: otherUser.avatar }
                });
              });

              isMatchFoundRef.current = true;
              unsubMM();
              await startRealMatch(bId, { userId: otherUser.userId, name: otherUser.name, avatar: otherUser.avatar }, true);
              break;
            } catch (e) {
              console.error("Match transaction failed", e);
            }
          }
        }
      };

      await findMatch();

      // If after finding and listening we still reach timeout
      const searchResult = await timeoutPromise;
      if (searchResult === 'timeout' && !isMatchFoundRef.current) {
        unsubMM();
        startBotMatch();
      }

    } catch (e: any) {
      console.error("Matchmaking Error:", e);
      showToast("Searching failed. Check console for index link.", "error");
      if (mmDocId) await deleteDoc(doc(db, 'matchmaking', mmDocId)).catch(() => { });
      setPhase('lobby');
    }
  };

  const startRealMatch = async (bId: string, opponent: any, isInitiator: boolean) => {
    // Kill all bot-related things immediately
    isBotMatchRef.current = false;
    setIsBotMatch(false);
    clearTimeout(botTimerRef.current);
    setBotScore(0);
    setUserScore(0);
    setBattleId(bId);
    setOpponentData(opponent);
    setBot(opponent); // Reuse bot state for UI consistency

    let battleQs: BattleQuestion[] = [];

    if (isInitiator) {
      // Initiator picks questions and saves to battle doc
      try {
        const qSnapshot = await getDocs(collection(db, 'battle_questions'));
        const allQs = qSnapshot.docs.map(d => ({ id: d.id, ...d.data() })) as BattleQuestion[];
        let unseenQs = allQs.filter(q => !(profile?.seenBattleQuestionIds || []).includes(q.id));
        if (unseenQs.length < battleConfig.totalQuestions) unseenQs = allQs;
        battleQs = unseenQs.sort(() => 0.5 - Math.random()).slice(0, battleConfig.totalQuestions);

        await setDoc(doc(db, 'battles', bId), {
          questions: battleQs,
          scores: {
            [user.uid]: 0,
            [opponent.userId]: 0
          },
          status: 'ongoing',
          timestamp: serverTimestamp()
        });
      } catch (err) {
        console.error("Failed to init battle doc", err);
      }
    } else {
      // Wait for initiator to save questions
      let retries = 0;
      while (retries < 10) {
        const bSnap = await getDoc(doc(db, 'battles', bId));
        if (bSnap.exists() && bSnap.data().questions) {
          battleQs = bSnap.data().questions;
          break;
        }
        await new Promise(r => setTimeout(r, 500));
        retries++;
      }
    }

    if (battleQs.length === 0) {
      console.warn("No questions found, using emergency fallback");
      battleQs = getRandomBattleQuestions(battleConfig.totalQuestions);
    }

    setQuestions(battleQs);

    // Ensure state is updated before starting
    setTimeout(() => {
      if (battleQs.length > 0) {
        setPhase('battle');
        startQuestionTimer();
      } else {
        console.error("Critical: Questions still empty after sync");
        setPhase('lobby');
        showToast("Failed to load battle questions.", "error");
      }
    }, 2000);
  };

  const startBotMatch = async () => {
    setIsBotMatch(true);
    let availableQs: BattleQuestion[] = [];
    try {
      const qSnapshot = await getDocs(collection(db, 'battle_questions'));
      const allQs = qSnapshot.docs.map(d => ({ id: d.id, ...d.data() })) as BattleQuestion[];
      let unseenQs = allQs.filter(q => !(profile?.seenBattleQuestionIds || []).includes(q.id));
      if (unseenQs.length < battleConfig.totalQuestions) unseenQs = allQs;
      availableQs = unseenQs.sort(() => 0.5 - Math.random()).slice(0, battleConfig.totalQuestions);
    } catch (fetchErr) {
      console.error("Failed to fetch dynamic battle questions:", fetchErr);
    }

    if (availableQs.length < battleConfig.totalQuestions) {
      availableQs = getRandomBattleQuestions(battleConfig.totalQuestions);
    }

    let selectedBot = { name: 'Aspirant_Rahul', avatar: 'https://i.pravatar.cc/150?u=rahul' };
    try {
      const botRef = collection(db, 'battle_bots');
      const q = query(botRef, where('isActive', '==', true));
      const botSnap = await getDocs(q);
      if (!botSnap.empty) {
        const activeBots = botSnap.docs.map(d => d.data());
        selectedBot = activeBots[Math.floor(Math.random() * activeBots.length)] as any;
      }
    } catch (botErr) {
      console.error("Failed to fetch active bots, using fallback", botErr);
    }

    setBot(selectedBot);
    setQuestions(availableQs);
    setTimeout(() => {
      setPhase('battle');
      startQuestionTimer();
    }, 2000);
  };

  const startQuestionTimer = () => {
    setTimeLeft(battleConfig.timePerQuestion);
    setSelectedOption(null);
    setIsAnswerRevealed(false);
    setIsTransitioning(false);
    setMatchStartTime(Date.now());

    // Bot Logic (Only if it's a bot match)
    clearTimeout(botTimerRef.current);
    if (isBotMatchRef.current) {
      const botReactionTime = Math.floor(Math.random() * (battleConfig.timePerQuestion * 600)) + 2000;
      botTimerRef.current = setTimeout(() => {
        const isCorrect = Math.random() < battleConfig.botAccuracy;
        if (isCorrect) {
          setBotCorrectCount(prev => prev + 1);
          setBotScore(prev => prev + 100 + Math.floor(Math.random() * 20));
        } else {
          setBotScore(prev => Math.max(0, prev - 25));
        }
      }, botReactionTime);
    }
  };



  const handleSelectOption = (idx: number) => {
    if (isTransitioning || isAnswerRevealed) return;

    setSelectedOption(idx);
    
    // Save user's answer and time
    const currentQ = questions[currentQIndex];
    if (currentQ) {
      setUserAnswers(prev => ({ ...prev, [currentQ.id]: idx }));
      setUserTimes(prev => ({ ...prev, [currentQ.id]: timeLeft }));
    }

    const isCorrect = idx === questions[currentQIndex].correctAnswer;
    if (isCorrect) {
      const speedBonus = Math.floor((timeLeft / battleConfig.timePerQuestion) * 50); // Up to 50 bonus
      setUserScore(prev => prev + 100 + speedBonus);
    } else {
      setUserScore(prev => Math.max(0, prev - 25));
    }

    revealAndNext();
  };

  const revealAndNext = () => {
    if (questions.length === 0 || isTransitioning) return;

    setIsAnswerRevealed(true);
    setIsTransitioning(true);
    clearTimeout(botTimerRef.current);

    setTimeout(() => {
      const nextIndex = currentQIndex + 1;
      
      if (nextIndex < questions.length) {
        setCurrentQIndex(nextIndex);
        startQuestionTimer();
      } else {
        setIsTransitioning(false);
        finishBattle();
      }
    }, 2000);
  };

  const finishBattle = async () => {
    try {
      // 1. Stop bot timer
      setIsTransitioning(false);

      // 2. Prepare scores
      const finalUserScore = userScoreRef.current;

      // 3. Bot Match Logic (Immediate Result)
      if (isBotMatchRef.current) {
        setPhase('waiting');
        
        try {
          const workerUrl = await getWorkerUrl();
          const response = await fetch(`${workerUrl}/submit-bot-battle`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              userId: user.uid,
              entryFee,
              userAnswers,
              userTimes,
              botCorrectCount,
              botScore: botScoreRef.current,
              questionIds: questions.map(q => q.id),
              opponentName: bot?.name
            })
          });

          if (response.ok) {
            const data = await response.json();
            if (data.success) {
              setMatchResult(data.matchResult);
              setUserScore(data.userScore);
              setBotScore(data.botScore);
              setPhase('result');
              setIsTransitioning(false);

              if (data.matchResult === 'win') {
                confetti({
                  particleCount: 150,
                  spread: 100,
                  origin: { y: 0.6 },
                  colors: ['#10b981', '#f59e0b', '#ffffff']
                });
              }
              return;
            }
          }
          throw new Error("Worker verification failed");
        } catch (workerErr) {
          console.warn("Falling back to client-side verification:", workerErr);
          const finalBotScore = botScoreRef.current;
          let result: 'win' | 'loss' | 'draw' = 'draw';
          if (finalUserScore > finalBotScore) result = 'win';
          else if (finalUserScore < finalBotScore) result = 'loss';

          setMatchResult(result);
          setPhase('result');
          setIsTransitioning(false);

          if (result === 'win') {
            handleWinReward(finalUserScore, bot?.name);
          }
        }
        return;
      }

      // 4. Real Match Logic (Wait for opponent)
      if (battleId) {
        setPhase('waiting');
        setIsTransitioning(false);

        const bRef = doc(db, 'battles', battleId);
        
        // Mark self as finished
        await updateDoc(bRef, {
          [`finished.${user.uid}`]: true,
          [`scores.${user.uid}`]: finalUserScore,
          [`finalScores.${user.uid}`]: finalUserScore
        }).catch(e => console.error("Final battle sync failed", e));

        // Listen for opponent finish is already handled in the Score Listener useEffect
      }

    } catch (err) {
      console.error("Critical error in finishBattle:", err);
      setPhase('result');
      setIsTransitioning(false);
    }
  };

  const handleWinReward = async (score: number, opponentName: string) => {
    const winAmount = Math.floor(entryFee * (battleConfig.prizeMultiplier || 1.8)); // Use dynamic multiplier from config
    try {
      await runTransaction(db, async (transaction) => {
        const userRef = doc(db, 'users', user.uid);
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists()) return;

        const currentCoins = userDoc.data().coins || 0;
        const newBalance = currentCoins + winAmount;
        transaction.update(userRef, { coins: newBalance });

        // Add Transaction Record
        const transRef = doc(collection(db, 'transactions'));
        transaction.set(transRef, {
          userId: user.uid,
          amount: winAmount,
          type: 'earn',
          category: 'battle_win',
          testTitle: `Won 1v1 Battle vs ${opponentName}`,
          currentBalance: newBalance,
          timestamp: serverTimestamp()
        });
      });

      confetti({
        particleCount: 150,
        spread: 100,
        origin: { y: 0.6 },
        colors: ['#10b981', '#f59e0b', '#ffffff']
      });
    } catch (e) {
      console.error("Error rewarding winner", e);
    }
  };

  // Sync own score to Firestore for real matches
  useEffect(() => {
    if (!isBotMatch && battleId && phase === 'battle') {
      updateDoc(doc(db, 'battles', battleId), {
        [`scores.${user.uid}`]: userScore
      }).catch(e => console.error("Score sync failed", e));
    }
  }, [userScore, isBotMatch, battleId, phase]);

  // Listen for opponent's score and finish status in real matches
  useEffect(() => {
    if (!isBotMatch && battleId && opponentData?.userId && (phase === 'battle' || phase === 'waiting')) {
      const unsub = onSnapshot(doc(db, 'battles', battleId), (snap) => {
        if (snap.exists()) {
          const data = snap.data();
          const scores = data.scores || {};
          const finished = data.finished || {};
          
          const oppScore = scores[opponentData.userId] || 0;
          setBotScore(oppScore); // Update score in UI

          // Check if both finished
          if (finished[opponentData.userId] && finished[user.uid] && phase === 'waiting') {
            const finalUserScore = userScoreRef.current;
            const finalOppScore = oppScore;

            let result: 'win' | 'loss' | 'draw' = 'draw';
            if (finalUserScore > finalOppScore) result = 'win';
            else if (finalUserScore < finalOppScore) result = 'loss';

            setMatchResult(result);
            setPhase('result');
            
            if (result === 'win') {
              handleWinReward(finalUserScore, opponentData.name);
            }
          }
        }
      });
      return () => unsub();
    }
  }, [isBotMatch, battleId, opponentData, phase]);

  // Cleanup timers and matchmaking
  useEffect(() => {
    return () => {
      clearTimeout(botTimerRef.current);
      if (matchmakingId) {
        deleteDoc(doc(db, 'matchmaking', matchmakingId)).catch(() => { });
      }
    };
  }, [matchmakingId]);

  return (
    <div
      className="w-full flex-1 flex flex-col pt-0 px-0"
    >
      {/* LOBBY PHASE */}
      {phase === 'lobby' && (
        <div className="flex-1 flex flex-col items-center justify-center relative bg-transparent overflow-hidden py-4 md:py-8">
          {/* Decorative Background Elements */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            {/* Dot Pattern */}
            <div className="absolute top-1/4 left-4 w-24 h-48 opacity-[0.02]" style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 1px)', backgroundSize: '8px 8px' }} />
            <div className="absolute bottom-1/4 right-4 w-24 h-48 opacity-[0.02]" style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 1px)', backgroundSize: '8px 8px' }} />
          </div>

          {/* Top Branding */}
          <div className="relative z-10 mb-4 md:mb-6 flex flex-col items-center">
            <div className="flex items-center gap-2 mb-4 scale-75 md:scale-90">
              <div className="w-8 h-8 bg-emerald-500 rounded-full flex items-center justify-center">
                <span className="text-white font-black text-xl leading-none">R</span>
              </div>
              <span className="text-xl font-black text-slate-900 tracking-tight">Rankearn</span>
            </div>

            <div className="text-center relative px-8">
              <div className="absolute -left-2 top-1/2 -translate-y-1/2 text-emerald-500 scale-50 md:scale-75">
                <Zap size={24} fill="currentColor" />
              </div>
              <div className="absolute -right-2 top-1/2 -translate-y-1/2 text-emerald-500 scale-50 md:scale-75">
                <Zap size={24} fill="currentColor" />
              </div>
              <h1 className="text-2xl md:text-5xl font-black text-slate-900 italic tracking-tighter leading-none mb-2 md:mb-3 whitespace-nowrap">
                1v1 RAPID BATTLE
              </h1>
              <div className="inline-flex items-center gap-2 px-4 py-1.5 bg-emerald-500 text-white rounded-full text-[8px] md:text-[10px] font-black uppercase tracking-widest shadow-lg shadow-emerald-500/20">
                <div className="w-3 h-px bg-white/40 rounded-full" />
                BATTLE REAL-TIME & WIN BIG COINS!
                <div className="w-3 h-px bg-white/40 rounded-full" />
              </div>
            </div>
          </div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="w-full max-w-lg relative z-10 px-4"
          >
            {/* Main Card */}
            <div className="bg-white rounded-2xl p-4 md:p-8 shadow-[0_0_50px_rgba(0,0,0,0.08)] border border-slate-50 relative">

              {/* Entry Stake Section */}
              <div className="mb-6 md:mb-8">
                <div className="flex items-center justify-between mb-6 relative">
                  <div className="flex-1 h-px bg-slate-100" />
                  <h3 className="px-4 text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Entry Stake</h3>
                  <div className="flex-1 h-px bg-slate-100" />

                  <div className="absolute right-0 top-1/2 -translate-y-1/2 flex items-center gap-1 px-2.5 py-1 bg-amber-50 text-amber-500 rounded-full text-[8px] font-black uppercase tracking-wider">
                    <Zap size={8} fill="currentColor" /> Blitz
                  </div>
                </div>

                <div className="flex justify-center items-end px-1 gap-4 flex-wrap">
                  {battleConfig.entryStakes.map(fee => (
                    <div key={fee} className="flex flex-col items-center gap-2 relative">
                      {fee === Math.max(...battleConfig.entryStakes) && battleConfig.entryStakes.length > 1 && (
                        <div className="absolute -top-6 left-1/2 -translate-x-1/2 z-20">
                          <span className="bg-emerald-500 text-white text-[7px] font-black px-2.5 py-0.5 rounded-full uppercase tracking-widest shadow-sm">Hot</span>
                        </div>
                      )}

                      <button
                        onClick={() => setEntryFee(fee)}
                        className={`group relative w-16 h-16 md:w-20 md:h-20 rounded-full flex items-center justify-center transition-all duration-300 ${entryFee === fee
                            ? 'bg-amber-500 text-white shadow-[0_15px_30px_rgba(245,158,11,0.2)] ring-[4px] ring-white ring-offset-0 scale-105 z-10'
                            : 'bg-white text-slate-400 border-2 border-slate-100 hover:border-slate-200 shadow-sm'
                          }`}
                      >
                        <div className="flex flex-col items-center">
                          <span className="font-black text-base md:text-xl tracking-tighter leading-none">{fee}</span>
                          <p className="text-[7px] md:text-[9px] font-black uppercase mt-0.5 opacity-60 tracking-widest">Coins</p>
                        </div>

                        {entryFee === fee && (
                          <div className="absolute bottom-0 right-0 w-6 h-6 md:w-7 md:h-7 bg-emerald-500 border-[3px] border-white rounded-full flex items-center justify-center shadow-lg">
                            <Check size={10} strokeWidth={4} className="text-white" />
                          </div>
                        )}
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Potential Prize Box */}
              <div className="bg-[#f2faf5] rounded-xl p-4 mb-6 flex items-center gap-4 border border-emerald-100/50">
                <div className="w-10 h-10 md:w-12 md:h-12 bg-white rounded-lg flex items-center justify-center text-emerald-500 shadow-sm shrink-0">
                  <div className="relative">
                    <Coins size={20} className="md:w-6 md:h-6" />
                  </div>
                </div>
                <div>
                  <p className="text-[8px] font-black text-slate-400 uppercase tracking-[0.15em] mb-0.5 leading-none">Potential Prize</p>
                  <p className="text-xl font-black text-emerald-600 tracking-tight leading-none">{Math.floor(entryFee * (battleConfig.prizeMultiplier || 1.8))} Coins</p>
                </div>
              </div>

              {/* Find Opponent Button */}
              <div className="grid grid-cols-2 gap-3 w-full">
                <button
                  onClick={handleStartSearch}
                  className="bg-amber-500 hover:bg-amber-600 text-white py-3 rounded-xl font-black text-xs md:text-sm transition-all flex items-center justify-center relative shadow-[0_10px_20px_rgba(245,158,11,0.2)] active:scale-[0.98] group"
                >
                  <span className="tracking-tight">Find Opponent</span>
                </button>
                <button
                  onClick={handleInviteFriend}
                  disabled={isInviting}
                  className="bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-xl font-black text-xs md:text-sm transition-all flex items-center justify-center gap-2 shadow-[0_10px_20px_rgba(16,185,129,0.1)] active:scale-[0.98] disabled:opacity-50"
                >
                  {isInviting ? <RefreshCw size={14} className="animate-spin" /> : <Share2 size={14} />}
                  <span className="tracking-tight">Invite Friend</span>
                </button>
              </div>
            </div>

            {/* Verified Matchmaking Footer */}
            <div className="mt-4 flex items-center justify-center gap-3">
              <div className="h-px w-8 bg-slate-200" />
              <div className="flex items-center gap-1.5 text-slate-400">
                <div className="flex items-center justify-center text-emerald-500">
                  <ShieldCheck size={12} strokeWidth={3} />
                </div>
                <span className="text-[8px] font-black uppercase tracking-[0.2em]">Verified 1v1 Matchmaking</span>
              </div>
              <div className="h-px w-8 bg-slate-200" />
            </div>

            {/* Features Bar */}
            <div className="mt-4 bg-white/80 border border-slate-100 rounded-xl p-3 md:p-4 flex items-center justify-between shadow-sm backdrop-blur-sm">
              <div className="flex items-center gap-2 md:gap-3 flex-1">
                <div className="w-8 h-8 rounded-full flex items-center justify-center text-emerald-500 bg-emerald-50 shrink-0">
                  <CheckCircle size={16} />
                </div>
                <div className="text-left">
                  <p className="text-[8px] font-black text-emerald-500 uppercase leading-none mb-0.5">Fair Play</p>
                  <p className="text-[6px] font-bold text-slate-400 uppercase leading-none">100% Fair</p>
                </div>
              </div>
              <div className="w-px h-8 bg-slate-100 mx-1.5" />
              <div className="flex items-center gap-2 md:gap-3 flex-1">
                <div className="w-8 h-8 rounded-full flex items-center justify-center text-emerald-500 bg-emerald-50 shrink-0">
                  <ShieldCheck size={16} />
                </div>
                <div className="text-left">
                  <p className="text-[8px] font-black text-emerald-500 uppercase leading-none mb-0.5">Secure</p>
                  <p className="text-[6px] font-bold text-slate-400 uppercase leading-none">Safe & Trusted</p>
                </div>
              </div>
              <div className="w-px h-8 bg-slate-100 mx-1.5" />
              <div className="flex items-center gap-2 md:gap-3 flex-1">
                <div className="w-8 h-8 rounded-full flex items-center justify-center text-emerald-500 bg-emerald-50 shrink-0">
                  <Trophy size={16} />
                </div>
                <div className="text-left">
                  <p className="text-[8px] font-black text-emerald-500 uppercase leading-none mb-0.5">Rewards</p>
                  <p className="text-[6px] font-bold text-slate-400 uppercase leading-none">Win & Earn</p>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      )}

      {/* SEARCHING PHASE */}
      {phase === 'searching' && (
        <div className="flex-1 flex flex-col items-center justify-center relative bg-transparent overflow-hidden">
          {/* Same Decorative Background as Lobby */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <div className="absolute top-1/4 left-4 w-24 h-48 opacity-[0.02]" style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 1px)', backgroundSize: '8px 8px' }} />
            <div className="absolute bottom-1/4 right-4 w-24 h-48 opacity-[0.02]" style={{ backgroundImage: 'radial-gradient(#000 1px, transparent 1px)', backgroundSize: '8px 8px' }} />
          </div>

          <div className="w-full max-w-2xl px-4 relative z-20 flex flex-col items-center scale-[0.85] md:scale-100">
            {/* Top Branding */}
            <div className="flex items-center gap-2 mb-10">
              <div className="w-8 h-8 bg-emerald-500 rounded-full flex items-center justify-center">
                <span className="text-white font-black text-xl leading-none">R</span>
              </div>
              <span className="text-2xl font-black text-slate-900 tracking-tight">Rankearn</span>
            </div>

            {/* Main Title */}
            <div className="text-center mb-12">
              <h1 className="text-[40px] md:text-[70px] font-black text-slate-900 leading-[0.85] tracking-tighter italic uppercase">
                1v1 RAPID <span className="text-emerald-500">BATTLE</span>
              </h1>
              <div className="flex items-center justify-center gap-3 mt-4">
                <div className="h-px w-8 bg-slate-200" />
                <p className="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] animate-pulse">
                  {isInvitationWaiting ? "Waiting for friend to join..." : "Finding a fair opponent..."}
                </p>
                <div className="h-px w-8 bg-slate-200" />
              </div>
            </div>

            {/* Battle Slots */}
            <div className="flex items-center justify-center gap-3 md:gap-8 mb-10 w-full relative">
              {/* User Slot */}
              <motion.div
                initial={{ x: -60, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                className="flex-1"
              >
                <div className="bg-white border-2 border-emerald-500/30 rounded-2xl py-8 px-4 md:py-10 md:px-6 shadow-[0_0_40px_rgba(16,185,129,0.08)] min-h-[195px] md:min-h-[235px] flex flex-col items-center justify-center relative">
                  <div className="flex flex-col items-center">
                    <div className="relative mb-4">
                      <div className="w-24 h-24 md:w-32 md:h-32 rounded-full border-4 border-emerald-500 p-0.5 shadow-lg">
                        <img
                          src={profile?.profilePhoto || `https://ui-avatars.com/api/?name=${profile?.name || 'U'}`}
                          className="w-full h-full rounded-full object-cover"
                        />
                      </div>
                      <div className="absolute bottom-0 right-0 bg-emerald-500 text-white p-1.5 rounded-full border-2 border-white shadow-md">
                        <Check size={12} strokeWidth={4} />
                      </div>
                    </div>
                    <span className="text-[8px] font-black text-emerald-500 uppercase tracking-widest mb-1 px-3 py-0.5 bg-emerald-50 rounded-full border border-emerald-100">You</span>
                    <h3 className="text-slate-900 font-black text-sm md:text-lg uppercase tracking-tighter text-center mt-1">
                      {profile?.name?.split(' ')[0]}
                    </h3>
                  </div>
                </div>
              </motion.div>

              {/* VS Divider */}
              <div className="relative z-30 flex flex-col items-center gap-2">
                <span className="text-4xl md:text-6xl font-black text-slate-900 italic tracking-tighter leading-none">VS</span>
                <div className="w-1 h-8 bg-slate-100 rounded-full" />
              </div>

              {/* Opponent Slot */}
              <motion.div
                initial={{ x: 60, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                className="flex-1"
              >
                <AnimatePresence mode="wait">
                  {bot ? (
                    // Opponent Found!
                    <motion.div
                      key="found"
                      initial={{ scale: 0.8, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      className="bg-white border-2 border-emerald-500/30 rounded-2xl py-8 px-4 md:py-10 md:px-6 shadow-[0_0_40px_rgba(16,185,129,0.08)] min-h-[195px] md:min-h-[235px] flex flex-col items-center justify-center relative"
                    >
                      <div className="flex flex-col items-center">
                        <div className="relative mb-4">
                          <div className="w-24 h-24 md:w-32 md:h-32 rounded-full border-4 border-emerald-500 p-0.5 shadow-lg">
                            <img src={bot.avatar} className="w-full h-full rounded-full object-cover" />
                          </div>
                          <motion.div
                            initial={{ scale: 0 }}
                            animate={{ scale: 1 }}
                            transition={{ type: 'spring', stiffness: 400 }}
                            className="absolute bottom-0 right-0 bg-emerald-500 text-white p-1.5 rounded-full border-2 border-white shadow-md"
                          >
                            <Check size={12} strokeWidth={4} />
                          </motion.div>
                        </div>
                        <motion.span
                          initial={{ opacity: 0, y: 4 }}
                          animate={{ opacity: 1, y: 0 }}
                          className="text-[8px] font-black text-emerald-500 uppercase tracking-widest mb-1 px-3 py-0.5 bg-emerald-50 rounded-full border border-emerald-100"
                        >
                          Found!
                        </motion.span>
                        <h3 className="text-slate-900 font-black text-sm md:text-lg uppercase tracking-tighter text-center mt-1">
                          {bot.name?.split(' ')[0]}
                        </h3>
                      </div>
                    </motion.div>
                  ) : (
                    // Still searching
                    <motion.div
                      key="searching"
                      exit={{ scale: 0.8, opacity: 0 }}
                      className="bg-white border-2 border-dashed border-slate-200 rounded-2xl py-8 px-4 md:py-10 md:px-6 relative overflow-hidden min-h-[195px] md:min-h-[235px] flex flex-col items-center justify-center"
                    >
                      <div className="flex flex-col items-center">
                        <div className="relative mb-4">
                          <div className="w-24 h-24 md:w-32 md:h-32 rounded-full border-4 border-dashed border-slate-200 flex items-center justify-center bg-slate-50 relative overflow-hidden">
                            {isInvitationWaiting ? (
                              <div className="flex flex-col items-center">
                                <UserIcon className="text-emerald-500 animate-pulse" size={32} />
                              </div>
                            ) : (
                              <>
                                <motion.div
                                  animate={{ rotate: 360 }}
                                  transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                                  className="absolute inset-0 border-t-4 border-emerald-400/50 rounded-full"
                                />
                                <RefreshCw className="text-slate-300" size={28} />
                              </>
                            )}
                          </div>
                        </div>
                        <span className="text-[8px] font-black text-slate-400 uppercase tracking-widest mb-2 px-3 py-0.5 bg-slate-50 rounded-full border border-slate-100">
                          {isInvitationWaiting ? "Friend" : "Opponent"}
                        </span>
                        <div className="flex items-center gap-1">
                          {[0, 1, 2].map(i => (
                            <motion.div
                              key={i}
                              animate={{ scaleY: [0.4, 1, 0.4] }}
                              transition={{ duration: 0.8, repeat: Infinity, delay: i * 0.15 }}
                              className="w-1 h-4 bg-emerald-400/60 rounded-full origin-bottom"
                            />
                          ))}
                        </div>
                      </div>

                      {!isInvitationWaiting && (
                        <motion.div
                          animate={{ x: ['-100%', '200%'] }}
                          transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
                          className="absolute inset-0 bg-gradient-to-r from-transparent via-emerald-500/5 to-transparent pointer-events-none"
                        />
                      )}
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            </div>

            {/* Entry Fee + Cancel */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="w-full max-w-sm"
            >
              {/* Stake Info Card */}
              <div className="bg-white border border-slate-100 rounded-xl p-4 shadow-[0_0_30px_rgba(0,0,0,0.04)] flex items-center gap-4 mb-6">
                <div className="w-10 h-10 bg-emerald-50 rounded-lg flex items-center justify-center text-emerald-500 shrink-0">
                  <Coins size={18} />
                </div>
                <div>
                  <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest leading-none mb-0.5">Entry Fee</p>
                  <p className="text-lg font-black text-slate-900 leading-none">{entryFee} Coins</p>
                </div>
                <div className="ml-auto">
                  <p className="text-[8px] font-black text-slate-400 uppercase tracking-widest leading-none mb-0.5">Prize</p>
                  <p className="text-lg font-black text-emerald-500 leading-none">{Math.floor(entryFee * 1.8)} Coins</p>
                </div>
              </div>

              <button
                onClick={() => {
                  if (isInvitationWaiting) {
                    handleCancelInvite();
                  } else {
                    setPhase('lobby');
                    if (matchmakingId) deleteDoc(doc(db, 'matchmaking', matchmakingId));
                  }
                }}
                className="w-full py-3.5 rounded-xl bg-white/90 border border-slate-200 text-slate-700 font-bold text-xs md:text-sm uppercase tracking-wider hover:bg-white hover:text-slate-900 transition-all active:scale-[0.98] shadow-sm backdrop-blur-sm"
              >
                {isInvitationWaiting ? "Cancel & Refund" : "Cancel Search"}
              </button>
            </motion.div>
          </div>
        </div>
      )}


      {/* BATTLE PHASE */}
      {phase === 'battle' && questions.length > 0 && (
        <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="flex-1 flex flex-col max-w-2xl mx-auto w-full">
          {/* Professional Header Scoreboard */}
          {/* Compact Scoreboard for Mobile */}
          <div className="bg-white rounded-xl p-3 md:p-5 shadow-sm mb-3 md:mb-6 flex items-center justify-between border border-slate-100 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-r from-emerald-500/5 via-transparent to-rose-500/5 opacity-40" />

            {/* User Info */}
            <div className="flex items-center gap-2 md:gap-4 relative z-10">
              <div className="relative">
                <img src={profile?.profilePhoto || `https://ui-avatars.com/api/?name=${profile?.name || 'U'}`} className="w-14 h-14 md:w-16 md:h-16 rounded-full border-2 border-white object-cover shadow-sm" />
                <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-emerald-500 border-2 border-white rounded-full" />
              </div>
              <div>
                <p className="text-[7px] md:text-[10px] text-slate-400 font-black uppercase tracking-widest leading-none mb-1">You</p>
                <p className="text-lg md:text-2xl font-black text-slate-900 tabular-nums leading-none">{userScore}</p>
              </div>
            </div>

            <div className="relative z-10 flex items-center justify-center px-4">
              <div className="w-8 h-8 rounded-full bg-slate-50 border border-slate-100 flex items-center justify-center shadow-inner relative">
                <span className="text-[10px] font-black text-slate-400 italic tracking-tighter">VS</span>
                <div className="absolute -top-3 w-px h-3 bg-slate-100" />
                <div className="absolute -bottom-3 w-px h-3 bg-slate-100" />
              </div>
            </div>

            {/* Bot Info */}
            <div className="flex items-center gap-2 md:gap-4 relative z-10 text-right">
              <div>
                <p className="text-[7px] md:text-[10px] text-slate-400 font-black uppercase tracking-widest leading-none mb-1 truncate max-w-[50px] md:max-w-none">{bot?.name?.split(' ')[0]}</p>
                <p className="text-lg md:text-2xl font-black text-slate-900 tabular-nums leading-none">{botScore}</p>
              </div>
              <div className="relative">
                <img src={bot?.avatar} className="w-14 h-14 md:w-16 md:h-16 rounded-full border-2 border-white object-cover shadow-sm" />
                <div className="absolute -bottom-0.5 -left-0.5 w-3 h-3 bg-rose-500 border-2 border-white rounded-full" />
              </div>
            </div>
          </div>

          {/* Clean Progress Indicators */}
          <div className="flex gap-2 mb-3 md:mb-6 px-2">
            <div className="flex-1 h-1.5 bg-slate-100 rounded-full overflow-hidden flex justify-end">
              <motion.div className="h-full bg-emerald-500" initial={{ width: 0 }} animate={{ width: `${Math.min(100, (userScore / 750) * 100)}%` }} />
            </div>
            <div className="flex-1 h-1.5 bg-slate-100 rounded-full overflow-hidden">
              <motion.div className="h-full bg-rose-500" initial={{ width: 0 }} animate={{ width: `${Math.min(100, (botScore / 750) * 100)}%` }} />
            </div>
          </div>

          <div className="bg-white rounded-xl md:rounded-2xl p-6 md:py-10 md:px-14 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.05)] border border-slate-100 flex flex-col relative overflow-hidden min-h-[300px]">
            {/* Only show blur during final calculation or finding opponent, not during answer reveal */}
            {isTransitioning && currentQIndex >= questions.length - 1 && isAnswerRevealed && (
              <div className="absolute inset-0 bg-white/60 backdrop-blur-sm z-50 flex flex-col items-center justify-center gap-4">
                <RefreshCw size={32} className="animate-spin text-slate-400" />
                <p className="font-black uppercase tracking-widest text-[10px] text-slate-500">Calculating Final Scores...</p>
              </div>
            )}

            {/* Compact Question Card Header */}
            <div className="flex items-center justify-between mb-6 pb-3 border-b border-slate-50 relative z-20">
              {/* Left: Q Number (Compact) */}
              <div className="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center shadow-md">
                <span className="text-xs font-black text-white">{Math.min(currentQIndex + 1, questions.length)}</span>
              </div>

              {/* Center: Timer (Compact) */}
              <div className="absolute left-1/2 -translate-x-1/2">
                <div className={`h-8 flex items-center gap-1.5 px-3.5 rounded-lg border transition-all duration-300 ${timeLeft <= 3
                  ? 'border-rose-500 bg-rose-500 text-white shadow-lg shadow-rose-500/30'
                  : 'border-emerald-500 bg-white text-slate-800 shadow-sm'
                  }`}>
                  <Timer size={12} className={timeLeft <= 3 ? 'animate-pulse' : 'text-emerald-500'} />
                  <span className={`font-black text-sm tabular-nums ${timeLeft <= 3 ? 'text-white' : 'text-slate-800'}`}>{timeLeft < 10 ? `0${timeLeft}` : timeLeft}</span>
                </div>
              </div>

              {/* Right: Language Toggle (Compact) */}
              <div className="h-8 flex bg-slate-50 rounded-lg p-0.5 border border-slate-100 items-center">
                <button
                  onClick={() => setLanguage('en')}
                  className={`h-full px-2.5 rounded-md text-[9px] font-black transition-all ${language === 'en' ? 'bg-emerald-500 text-white shadow-md' : 'text-slate-400'}`}
                >
                  EN
                </button>
                <button
                  onClick={() => setLanguage('hi')}
                  className={`h-full px-2.5 rounded-md text-[9px] font-black transition-all ${language === 'hi' ? 'bg-emerald-500 text-white shadow-md' : 'text-slate-400'}`}
                >
                  HI
                </button>
              </div>
            </div>

            {questions[currentQIndex] ? (
              <>
                <h2 
                  className="text-lg md:text-3xl font-bold font-tiro text-slate-900 mb-6 md:mb-10 text-center leading-[1.4] md:leading-[1.5] tracking-tight px-2"
                >
                  {language === 'hi' && questions[currentQIndex]?.textHindi
                    ? questions[currentQIndex].textHindi
                    : questions[currentQIndex]?.text}
                </h2>

                <div className="grid grid-cols-1 gap-2.5 md:gap-3">
                  {questions[currentQIndex]?.options?.map((opt, idx) => {
                    const isCorrect = idx === questions[currentQIndex].correctAnswer;
                    const isSelected = idx === selectedOption;

                    let btnClass = "bg-slate-50 border-slate-100 text-slate-600 hover:bg-white hover:border-slate-300 hover:shadow-xl hover:shadow-slate-200/40";

                    if (isAnswerRevealed) {
                      if (isCorrect) btnClass = "bg-emerald-50 border-emerald-500 text-emerald-700 shadow-lg shadow-emerald-500/10";
                      else if (isSelected && !isCorrect) btnClass = "bg-rose-50 border-rose-500 text-rose-700 shadow-lg shadow-rose-500/10";
                      else btnClass = "bg-slate-50 border-slate-100 text-slate-400 opacity-40";
                    } else if (isSelected) {
                      btnClass = "bg-amber-500 border-amber-500 text-slate-900 shadow-xl shadow-amber-500/20";
                    }

                    return (
                      <button
                        key={idx}
                        onClick={() => handleSelectOption(idx)}
                        disabled={isAnswerRevealed || selectedOption !== null}
                        className={`group relative p-3.5 md:p-6 rounded-md md:rounded-lg border-2 text-left font-bold text-xs md:text-lg transition-all flex items-center gap-3 md:gap-5 ${btnClass}`}
                      >
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center text-xs md:text-sm font-black shrink-0 transition-all ${isAnswerRevealed && isCorrect ? 'bg-emerald-500 text-white' :
                          isAnswerRevealed && isSelected && !isCorrect ? 'bg-rose-500 text-white' :
                            isSelected ? 'bg-white/40 text-slate-900' : 'bg-white shadow-sm text-slate-400'
                          }`}>
                          {String.fromCharCode(65 + idx)}
                        </div>
                        <span className="flex-1 leading-tight font-tiro">
                          {language === 'hi' && questions[currentQIndex]?.optionsHindi?.[idx]
                            ? questions[currentQIndex].optionsHindi[idx]
                            : opt}
                        </span>
                        {isAnswerRevealed && isCorrect && <Check size={18} className="text-emerald-500 shrink-0" strokeWidth={4} />}
                      </button>
                    );
                  })}
                </div>
              </>
            ) : (
              <div className="flex-1 flex flex-col items-center justify-center text-slate-300 gap-6">
                <RefreshCw size={48} className="animate-spin opacity-10" />
                <p className="font-black uppercase tracking-[0.2em] text-[10px]">Processing results...</p>
              </div>
            )}
          </div>
        </motion.div>
      )}

      {/* WAITING PHASE */}
      {phase === 'waiting' && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="flex-1 flex flex-col items-center justify-center p-6 text-center"
        >
          <div className="relative mb-8">
            <div className="w-24 h-24 rounded-full border-4 border-slate-100 flex items-center justify-center overflow-hidden">
               <img src={bot?.avatar} className="w-full h-full object-cover opacity-50" />
            </div>
            <div className="absolute inset-0 w-24 h-24 border-4 border-[#00a86b] border-t-transparent rounded-full animate-spin" />
          </div>
          
          <h2 className="text-2xl font-black text-slate-900 mb-2 uppercase tracking-tight">Finishing Up...</h2>
          <p className="text-slate-500 font-bold text-sm uppercase tracking-widest mb-6">Waiting for <span className="text-[#00a86b]">{bot?.name?.split(' ')[0]}</span> to complete the last question</p>
          
          <div className="bg-slate-50 rounded-2xl p-6 w-full max-w-xs border border-slate-100 shadow-sm">
            <div className="flex justify-between items-center mb-4">
              <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Your Score</span>
              <span className="text-2xl font-black text-[#00a86b]">{userScore}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{bot?.name}'s Score</span>
              <span className="text-2xl font-black text-slate-900">{botScore}</span>
            </div>
          </div>
        </motion.div>
      )}

      {/* RESULT PHASE */}
      {phase === 'result' && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="flex-1 flex flex-col items-center justify-center text-center max-w-xl mx-auto w-full px-4"
        >
          {/* Main Glassmorphic Result Card with reduced roundness */}
          <div className="bg-white/95 backdrop-blur-md rounded-xl p-6 md:p-10 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.1)] border border-slate-100/80 w-full relative overflow-hidden">
            {/* Ambient Background Glow inside the card */}
            <div className="absolute -top-24 -left-24 w-48 h-48 rounded-full bg-emerald-500/5 blur-3xl pointer-events-none" />
            <div className="absolute -bottom-24 -right-24 w-48 h-48 rounded-full bg-amber-500/5 blur-3xl pointer-events-none" />

            <div className="mb-6 md:mb-8 flex flex-col items-center">
              {/* Header Icon Ring */}
              <div className={`w-20 h-20 md:w-24 md:h-24 rounded-full flex items-center justify-center mb-4 md:mb-5 relative shadow-inner ${
                matchResult === 'win'
                  ? 'bg-emerald-50 border-[6px] border-emerald-100 text-emerald-500 shadow-emerald-500/5'
                  : matchResult === 'loss'
                  ? 'bg-rose-50 border-[6px] border-rose-100 text-rose-500 shadow-rose-500/5'
                  : 'bg-slate-50 border-[6px] border-slate-100 text-slate-500 shadow-slate-500/5'
              }`}>
                {matchResult === 'win' ? (
                  <Trophy size={40} className="md:w-12 md:h-12 drop-shadow-md animate-bounce" style={{ animationDuration: '3s' }} />
                ) : matchResult === 'loss' ? (
                  <X size={44} className="md:w-14 md:h-14 drop-shadow-sm text-rose-600" strokeWidth={3} />
                ) : (
                  <Shield size={40} className="md:w-12 md:h-12" />
                )}
              </div>

              {/* Title & Subtext */}
              <h1 className="text-3xl md:text-4xl font-extrabold text-slate-900 mb-2 tracking-tight">
                {matchResult === 'win' ? (
                  <span className="bg-gradient-to-r from-emerald-600 to-teal-500 bg-clip-text text-transparent">Victory!</span>
                ) : matchResult === 'loss' ? (
                  <span className="text-rose-600">Better luck</span>
                ) : (
                  <span className="text-slate-800">Match Drawn</span>
                )}
              </h1>
              <p className="text-slate-500 font-semibold text-xs md:text-sm tracking-wide">
                {matchResult === 'win' ? 'Outstanding performance!' :
                  matchResult === 'loss' ? 'Keep practicing to get better!' : 'A close, hard-fought match!'}
              </p>
            </div>

            {/* Polished Stats Card (Versus Grid) with reduced roundness */}
            <div className="grid grid-cols-5 items-center bg-slate-50/70 border border-slate-100 rounded-xl p-4 md:p-6 mb-6 md:mb-8 relative shadow-sm">
              {/* User Side */}
              <div className="col-span-2 flex flex-col items-center">
                <div className="relative mb-3">
                  <div className={`w-20 h-20 md:w-24 md:h-24 rounded-full p-1 border-4 ${
                    matchResult === 'win' ? 'border-emerald-500/30' : matchResult === 'loss' ? 'border-rose-500/30' : 'border-slate-200/50'
                  } shadow-md overflow-hidden bg-white`}>
                    <img
                      src={profile?.profilePhoto || `https://ui-avatars.com/api/?name=${profile?.name || 'U'}`}
                      className="w-full h-full rounded-full object-cover"
                    />
                  </div>
                </div>
                <span className="text-[10px] md:text-xs font-bold text-slate-400 uppercase tracking-wider mb-1 truncate max-w-[80px] inline-flex items-center gap-1">
                  {matchResult === 'win' && (
                    <Trophy size={10} className="text-amber-500 shrink-0" fill="currentColor" />
                  )}
                  {profile?.name?.split(' ')[0] || 'You'}
                </span>
                <span className={`text-2xl md:text-3xl font-black tracking-tight ${
                  matchResult === 'win' ? 'text-emerald-600' : matchResult === 'loss' ? 'text-rose-600' : 'text-slate-800'
                }`}>
                  {userScore}
                </span>
              </div>

              {/* VS Badge */}
              <div className="col-span-1 flex flex-col items-center justify-center">
                <div className="w-9 h-9 rounded-full bg-white border border-slate-150 flex items-center justify-center shadow-md relative z-10">
                  <span className="text-[10px] font-black text-slate-400 italic">VS</span>
                </div>
                <div className="absolute h-[60%] w-px bg-slate-200/70 left-1/2 -translate-x-1/2" />
              </div>

              {/* Bot / Opponent Side */}
              <div className="col-span-2 flex flex-col items-center">
                <div className="relative mb-3">
                  <div className={`w-20 h-20 md:w-24 md:h-24 rounded-full p-1 border-4 ${
                    matchResult === 'loss' ? 'border-emerald-500/30' : matchResult === 'win' ? 'border-rose-500/30' : 'border-slate-200/50'
                  } shadow-md overflow-hidden bg-white`}>
                    <img
                      src={bot?.avatar}
                      className="w-full h-full rounded-full object-cover"
                    />
                  </div>
                </div>
                <span className="text-[10px] md:text-xs font-bold text-slate-400 uppercase tracking-wider mb-1 truncate max-w-[80px] inline-flex items-center gap-1">
                  {matchResult === 'loss' && (
                    <Trophy size={10} className="text-amber-500 shrink-0" fill="currentColor" />
                  )}
                  {bot?.name?.split(' ')[0]}
                </span>
                <span className={`text-2xl md:text-3xl font-black tracking-tight ${
                  matchResult === 'loss' ? 'text-emerald-600' : matchResult === 'win' ? 'text-rose-600' : 'text-slate-800'
                }`}>
                  {botScore}
                </span>
              </div>
            </div>

            {/* Payout Summary with reduced roundness */}
            {matchResult === 'win' ? (
              <div className="bg-emerald-500/10 text-emerald-700 py-3.5 px-6 rounded-xl flex items-center justify-center gap-2.5 font-bold text-sm md:text-base mb-6 md:mb-8 border border-emerald-500/20 shadow-[0_4px_20px_rgba(16,185,129,0.05)]">
                <Coins size={18} className="text-emerald-600 animate-pulse" />
                <span>You Won <strong className="font-extrabold">{Math.floor(entryFee * 1.8)} Coins</strong></span>
              </div>
            ) : matchResult === 'loss' ? (
              <div className="bg-rose-500/10 text-rose-700 py-3.5 px-6 rounded-xl flex items-center justify-center gap-2.5 font-bold text-sm md:text-base mb-6 md:mb-8 border border-rose-500/20 shadow-[0_4px_20px_rgba(244,63,94,0.05)]">
                <AlertCircle size={18} className="text-rose-600" />
                <span>Stakes Lost (<strong className="font-extrabold">{entryFee} Coins</strong>)</span>
              </div>
            ) : (
              <div className="bg-slate-500/10 text-slate-700 py-3.5 px-6 rounded-xl flex items-center justify-center gap-2.5 font-bold text-sm md:text-base mb-6 md:mb-8 border border-slate-500/20 shadow-[0_4px_20px_rgba(100,116,139,0.05)]">
                <RefreshCw size={18} className="text-slate-600" />
                <span>Stakes Returned (<strong className="font-extrabold">{entryFee} Coins</strong>)</span>
              </div>
            )}

            {/* Buttons with reduced roundness and icon removed */}
            <div className="grid grid-cols-2 gap-4">
              <button
                onClick={() => setPhase('lobby')}
                className="py-3.5 rounded-xl font-bold text-xs md:text-sm uppercase tracking-wider text-slate-600 bg-slate-100 hover:bg-slate-200 active:scale-[0.98] transition-all duration-200 border border-slate-200 shadow-sm"
              >
                Exit Game
              </button>
              <button
                onClick={handleStartSearch}
                className="py-3.5 rounded-xl font-bold text-xs md:text-sm uppercase tracking-wider text-white bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 active:scale-[0.98] transition-all duration-200 shadow-lg shadow-amber-500/25 text-center"
              >
                Play Rematch
              </button>
            </div>
          </div>
        </motion.div>
      )}

    </div>
  );
};

// Dummy SearchIcon component for the radar
const SearchIcon = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className={className}>
    <circle cx="11" cy="11" r="8"></circle>
    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
  </svg>
);

