import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { db, auth, handleFirestoreError, OperationType } from '../firebase';
import { doc, getDoc, setDoc, collection, getDocs, addDoc, query, where, limit, updateDoc, increment } from 'firebase/firestore';
import { Question, Test, Attempt, UserProfile } from '../types';
import MathText from './MathText';
import { useToast } from './Toast';
import { 
  ChevronLeft, 
  ChevronRight, 
  Flag, 
  Clock, 
  AlertCircle,
  CheckCircle2,
  X,
  Maximize2,
  Info,
  HelpCircle,
  User as UserIcon,
  Globe
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

const normalizeDate = (d: any): Date | null => {
  if (!d) return null;
  if (typeof d.toDate === 'function') return d.toDate();
  if (d && typeof d === 'object' && 'seconds' in d) return new Date(d.seconds * 1000);
  const parsed = new Date(d);
  return isNaN(parsed.getTime()) ? null : parsed;
};

interface QuizInterfaceProps {
  testId: string;
  onExit: () => void;
  profile: UserProfile | null;
}

enum QuestionStatus {
  NOT_VISITED = 'not_visited',
  NOT_ANSWERED = 'not_answered',
  ANSWERED = 'answered',
  MARKED_FOR_REVIEW = 'marked_for_review',
  ANSWERED_MARKED_FOR_REVIEW = 'answered_marked_for_review'
}

interface QuestionPaletteProps {
  questions: Question[];
  statusMap: Record<string, QuestionStatus>;
  activeSection: string;
  currentIdx: number;
  getStatusCount: (status: QuestionStatus) => number;
  jumpToQuestion: (idx: number, newSection?: string) => void;
  setShowMobileSidebar: (show: boolean) => void;
  setShowSubmitConfirm: (show: boolean) => void;
  profile: UserProfile | null;
}

const sidebarSubmitButtonClass = 'w-full inline-flex items-center justify-center px-4 md:px-6 py-2.5 text-xs md:text-sm font-bold rounded-xl bg-[#007bff] text-white hover:bg-[#0069d9] shadow-md transition-all uppercase tracking-wider active:scale-95';

const QuestionPalette = React.memo(({
  questions,
  statusMap,
  activeSection,
  currentIdx,
  getStatusCount,
  jumpToQuestion,
  setShowMobileSidebar,
  setShowSubmitConfirm,
  profile
}: QuestionPaletteProps) => (
  <div className="flex flex-col h-full overflow-hidden">
    <div className="p-4 bg-white border-b border-slate-300 flex items-center gap-3 shrink-0">
      <div className="w-10 h-10 md:w-11 md:h-11 rounded-full border-2 border-slate-100 p-0.5 shadow-sm">
        <div className="w-full h-full bg-slate-50 rounded-full flex items-center justify-center overflow-hidden">
          {profile?.profilePhoto ? (
            <img src={profile.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(profile.name || 'User')}`} alt="User" className="w-full h-full object-cover" />
          ) : auth.currentUser?.photoURL ? (
            <img src={auth.currentUser.photoURL || `https://ui-avatars.com/api/?name=${encodeURIComponent(auth.currentUser.displayName || 'User')}`} alt="User" className="w-full h-full object-cover" />
          ) : (
            <UserIcon size={20} className="text-slate-400" />
          )}
        </div>
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[10px] md:text-xs font-black text-slate-900 truncate uppercase tracking-tight">{profile?.name || auth.currentUser?.displayName || 'Candidate'}</p>
        <p className="text-[9px] md:text-[10px] text-slate-500 font-bold mt-0.5 truncate uppercase opacity-60">ID: {profile?.userId?.slice(0, 8) || auth.currentUser?.uid.slice(0, 8)}</p>
      </div>
    </div>

    {/* Status Summary */}
    <div className="p-3 grid grid-cols-2 gap-2 bg-white border-b border-slate-300">
      <div className="flex items-center gap-2">
        <div className="w-5 h-5 md:w-6 md:h-6 bg-[#28a745] text-white rounded flex items-center justify-center text-[9px] md:text-[10px] font-bold">{getStatusCount(QuestionStatus.ANSWERED)}</div>
        <span className="text-[9px] md:text-[10px] font-bold text-slate-600">Answered</span>
      </div>
      <div className="flex items-center gap-2">
        <div className="w-5 h-5 md:w-6 md:h-6 bg-[#dc3545] text-white rounded flex items-center justify-center text-[9px] md:text-[10px] font-bold">{getStatusCount(QuestionStatus.NOT_ANSWERED)}</div>
        <span className="text-[9px] md:text-[10px] font-bold text-slate-600">Not Answered</span>
      </div>
      <div className="flex items-center gap-2">
        <div className="w-5 h-5 md:w-6 md:h-6 bg-white border border-slate-400 text-slate-700 rounded flex items-center justify-center text-[9px] md:text-[10px] font-bold">{getStatusCount(QuestionStatus.NOT_VISITED)}</div>
        <span className="text-[9px] md:text-[10px] font-bold text-slate-600">Not Visited</span>
      </div>
      <div className="flex items-center gap-2">
        <div className="w-5 h-5 md:w-6 md:h-6 bg-[#6f42c1] text-white rounded flex items-center justify-center text-[9px] md:text-[10px] font-bold">{getStatusCount(QuestionStatus.MARKED_FOR_REVIEW)}</div>
        <span className="text-[9px] md:text-[10px] font-bold text-slate-600">Marked Review</span>
      </div>
      <div className="col-span-2 flex items-center gap-2">
        <div className="w-5 h-5 md:w-6 md:h-6 bg-[#6f42c1] text-white rounded-full flex items-center justify-center text-[9px] md:text-[10px] font-bold relative">
          {getStatusCount(QuestionStatus.ANSWERED_MARKED_FOR_REVIEW)}
          <div className="absolute -bottom-0.5 -right-0.5 w-1.5 h-1.5 md:w-2 md:h-2 bg-green-500 rounded-full border border-white" />
        </div>
        <span className="text-[9px] md:text-[10px] font-bold text-slate-600">Ans & Marked Review</span>
      </div>
    </div>

    {/* Palette Grid */}
    <div className="flex-1 overflow-y-auto p-3">
      <h3 className="text-[10px] md:text-[11px] font-bold text-slate-700 mb-3 uppercase tracking-wider">Choose a Question</h3>
      <div className="grid grid-cols-5 gap-2">
        {questions.map((q, i) => {
          const qSubject = q.subject || 'General';
          // Only show questions from the active section
          if (activeSection !== 'All' && qSubject !== activeSection) return null;

          const status = statusMap[q.questionId];
          let bgClass = 'bg-white border-slate-400 text-slate-700';
          let shapeClass = 'rounded';

          if (status === QuestionStatus.ANSWERED) bgClass = 'bg-[#28a745] border-[#28a745] text-white';
          else if (status === QuestionStatus.NOT_ANSWERED) bgClass = 'bg-[#dc3545] border-[#dc3545] text-white';
          else if (status === QuestionStatus.MARKED_FOR_REVIEW) bgClass = 'bg-[#6f42c1] border-[#6f42c1] text-white';
          else if (status === QuestionStatus.ANSWERED_MARKED_FOR_REVIEW) {
            bgClass = 'bg-[#6f42c1] border-[#6f42c1] text-white';
            shapeClass = 'rounded-full';
          }

          return (
            <button
              key={i}
              onClick={() => {
                jumpToQuestion(i);
                setShowMobileSidebar(false);
              }}
              className={`
                w-8 h-8 md:w-9 md:h-9 border text-[10px] md:text-xs font-bold transition-all flex items-center justify-center relative
                ${bgClass} ${shapeClass}
                ${currentIdx === i ? 'ring-2 ring-blue-600 ring-offset-1' : ''}
              `}
            >
              {i + 1}
              {status === QuestionStatus.ANSWERED_MARKED_FOR_REVIEW && (
                <div className="absolute -bottom-0.5 -right-0.5 w-2 md:w-2.5 h-2 md:h-2.5 bg-green-500 rounded-full border border-white" />
              )}
            </button>
          );
        })}
      </div>
    </div>

    {/* Submit Button */}
    <div className="p-4 md:h-16 md:px-4 md:py-3 bg-white border-t border-slate-300 shrink-0 md:flex md:items-center">
      <button 
        onClick={() => setShowSubmitConfirm(true)}
        className={sidebarSubmitButtonClass}
      >
        Submit Test
      </button>
    </div>
  </div>
));

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

export default function QuizInterface({ testId, onExit, profile }: QuizInterfaceProps) {
  const navigate = useNavigate();
  const { showToast } = useToast();
  const [test, setTest] = useState<Test | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [currentIdx, setCurrentIdx] = useState(0);
  const [answers, setAnswers] = useState<Record<string, number>>({});
  const [statusMap, setStatusMap] = useState<Record<string, QuestionStatus>>({});
  const [language, setLanguage] = useState<'english' | 'hindi'>('hindi');
  const [timeLeft, setTimeLeft] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [loading, setLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showWarning, setShowWarning] = useState(false);
  const [warningCount, setWarningCount] = useState(0);
  const [activeSection, setActiveSection] = useState('All');
  const [showMobileSidebar, setShowMobileSidebar] = useState(false);
  const [showSubmitConfirm, setShowSubmitConfirm] = useState(false);
  const [showInstructions, setShowInstructions] = useState(false);
  const startedAtRef = useRef<string | null>(null);

  // Helper to shuffle array
  const shuffleArray = <T,>(array: T[]): T[] => {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  };

  const handleSubmit = useCallback(async () => {
    if (isSubmitting) return;
    setIsSubmitting(true);
    
    try {
      const endTime = new Date().toISOString();
      const startTime = startedAtRef.current || endTime;
      const timeTaken = Math.max(0, (test?.duration || 0) * 60 - timeLeft);

      const workerUrl = await getWorkerUrl();
      const response = await fetch(`${workerUrl}/submit-test`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: auth.currentUser?.uid,
          testId,
          answers,
          startTime,
          endTime,
          timeTaken,
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(errorText || 'Server side quiz verification failed.');
      }

      const result = await response.json();
      
      if (result.alreadySubmitted && result.attemptId) {
        showToast('You have already submitted this contest test!', 'warning');
        navigate(`/results/${result.attemptId}`);
        onExit();
        return;
      }

      navigate(`/results/${result.attemptId}`);
      onExit();
    } catch (error: any) {
      console.error('Quiz submission failed:', error);
      showToast(error.message || 'Failed to submit quiz. Please try again.', 'error');
    } finally {
      setIsSubmitting(false);
    }
  }, [answers, isSubmitting, navigate, onExit, test?.duration, testId, timeLeft]);

  // Fetch Test and Questions
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setCurrentIdx(0);
      setAnswers({});
      setStatusMap({});
      setWarningCount(0);
      startedAtRef.current = new Date().toISOString();
      
      try {
        const testSnap = await getDoc(doc(db, 'tests', testId));
        if (!testSnap.exists()) return onExit();
        
        const testData = { testId: testSnap.id, ...testSnap.data() } as Test;
        
        // Security Check: Is the test published?
        if (testData.status === 'unpublished') {
          showToast('This test is not published yet.', 'error');
          onExit();
          return;
        }
        
        // Security Check: Has the user already submitted this test?
        if (testData.isTournament) {
          const attemptQuery = query(
            collection(db, 'attempts'),
            where('userId', '==', auth.currentUser?.uid),
            where('testId', '==', testId),
            limit(1)
          );
          const attemptSnap = await getDocs(attemptQuery);
          if (!attemptSnap.empty) {
            showToast('You have already submitted this contest test!', 'warning');
            const existingAttemptId = attemptSnap.docs[0].id;
            navigate(`/results/${existingAttemptId}`);
            onExit();
            return;
          }
        }
        
        // Safety Check for scheduled tournaments
        if (testData.isTournament) {
          const now = new Date();
          const start = normalizeDate(testData.scheduledStartTime);
          const end = normalizeDate(testData.scheduledEndTime);
          if (start && now < start) {
            showToast('Contest has not started yet!', 'error');
            onExit();
            return;
          }
          if (end && now > end) {
            showToast('Contest has already ended!', 'error');
            onExit();
            return;
          }
        }

        setTest(testData);
        setTimeLeft(testData.duration * 60);

        const qSnap = await getDocs(collection(db, 'tests', testId, 'questions'));
        let qs = qSnap.docs.map(d => ({ questionId: d.id, ...d.data() } as Question));
        
        // Randomize Questions
        qs = shuffleArray(qs);

        // Randomize Options for each question
        qs = qs.map(q => ({
          ...q,
          options: shuffleArray(q.options)
        }));

        setQuestions(qs);
        
        // Initialize status map
        const initialStatus: Record<string, QuestionStatus> = {};
        qs.forEach((q, idx) => {
          initialStatus[q.questionId] = idx === 0 ? QuestionStatus.NOT_ANSWERED : QuestionStatus.NOT_VISITED;
        });
        setStatusMap(initialStatus);
        
        setLoading(false);
      } catch (error) {
        console.error('Error fetching quiz data', error);
        showToast('Failed to load quiz. Please try again.', 'error');
        onExit();
      }
    };
    fetchData();
  }, [testId]);

  // Timer logic
  useEffect(() => {
    if (timeLeft <= 0 && !loading) {
      handleSubmit();
      return;
    }
    if (isPaused) return;

    const timer = setInterval(() => {
      // Check for Tournament End Time
      if (test?.isTournament && test?.scheduledEndTime) {
        const now = new Date();
        const endTime = normalizeDate(test.scheduledEndTime);
        if (endTime && now >= endTime) {
          showToast('Contest time is up! Auto-submitting...', 'warning');
          handleSubmit();
          clearInterval(timer);
          return;
        }
      }
      
      setTimeLeft(prev => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, loading, isPaused, test, handleSubmit]);

  // Anti-cheating: Tab switch detection and event blocking
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.hidden) {
        setShowWarning(true);
        setWarningCount(prev => {
          const nextWarningCount = prev + 1;
          if (nextWarningCount >= 3) {
            // Auto-flag user in Firestore for cheating attempt
            const userId = auth.currentUser?.uid;
            if (userId) {
              updateDoc(doc(db, 'users', userId), {
                violationCount: increment(1)
              }).catch(err => console.error("Error auto-flagging cheater:", err));
            }
            void handleSubmit();
          }
          return nextWarningCount;
        });
      }
    };

    const preventDefault = (e: Event) => e.preventDefault();
    
    // Disable right click, copy, and paste
    document.addEventListener('contextmenu', preventDefault);
    document.addEventListener('copy', preventDefault);
    document.addEventListener('paste', preventDefault);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      document.removeEventListener('contextmenu', preventDefault);
      document.removeEventListener('copy', preventDefault);
      document.removeEventListener('paste', preventDefault);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [handleSubmit]);

  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  };

  const handleOptionSelect = (optionIdx: number) => {
    if (!currentQ) return;
    const qId = currentQ.questionId;
    setAnswers(prev => ({ ...prev, [qId]: optionIdx }));
  };

  const clearResponse = () => {
    if (!currentQ) return;
    const qId = currentQ.questionId;
    const newAnswers = { ...answers };
    delete newAnswers[qId];
    setAnswers(newAnswers);
    
    setStatusMap(prev => ({
      ...prev,
      [qId]: QuestionStatus.NOT_ANSWERED
    }));
  };

  const markForReviewAndNext = () => {
    if (!currentQ) return;
    const qId = currentQ.questionId;
    const isAnswered = answers[qId] !== undefined;
    
    setStatusMap(prev => ({
      ...prev,
      [qId]: isAnswered ? QuestionStatus.ANSWERED_MARKED_FOR_REVIEW : QuestionStatus.MARKED_FOR_REVIEW
    }));
    
    moveToNext();
  };

  const saveAndNext = () => {
    if (!currentQ) return;
    const qId = currentQ.questionId;
    const isAnswered = answers[qId] !== undefined;
    
    setStatusMap(prev => ({
      ...prev,
      [qId]: isAnswered ? QuestionStatus.ANSWERED : QuestionStatus.NOT_ANSWERED
    }));
    
    moveToNext();
  };

  const moveToNext = () => {
    if (activeSection === 'All') {
      if (currentIdx < questions.length - 1) {
        jumpToQuestion(currentIdx + 1);
      }
    } else {
      // Find next question in the same section
      const nextIdx = questions.findIndex((q, i) => i > currentIdx && (q.subject || 'General') === activeSection);
      if (nextIdx !== -1) {
        jumpToQuestion(nextIdx);
      } else {
        // Optional: If no more questions in this section, maybe show a message or stay
        console.log('End of section');
      }
    }
  };

  const moveToPrevious = () => {
    if (activeSection === 'All') {
      if (currentIdx > 0) {
        jumpToQuestion(currentIdx - 1);
      }
    } else {
      // Find previous question in the same section
      for (let i = currentIdx - 1; i >= 0; i--) {
        if ((questions[i].subject || 'General') === activeSection) {
          jumpToQuestion(i);
          return;
        }
      }
    }
  };

  const jumpToQuestion = useCallback((idx: number, newSection?: string) => {
    const qId = questions[idx].questionId;
    if (statusMap[qId] === QuestionStatus.NOT_VISITED) {
      setStatusMap(prev => ({
        ...prev,
        [qId]: QuestionStatus.NOT_ANSWERED
      }));
    }
    setCurrentIdx(idx);
    
    // Update active section to match the question's subject
    const targetSection = newSection || activeSection;
    const q = questions[idx];
    if (q && targetSection !== 'All') {
      setActiveSection(q.subject || 'General');
    }
  }, [questions, statusMap, activeSection]);

  const getStatusCount = useCallback((status: QuestionStatus) => {
    return Object.values(statusMap).filter(s => s === status).length;
  }, [statusMap]);

  const handleSectionChange = useCallback((sec: string) => {
    setActiveSection(sec);
    if (sec === 'All') {
      jumpToQuestion(0, 'All');
    } else {
      const firstIdx = questions.findIndex(q => (q.subject || 'General') === sec);
      if (firstIdx !== -1) {
        jumpToQuestion(firstIdx, sec);
      }
    }
  }, [questions, jumpToQuestion]);

  if (loading) return (
    <div className="fixed inset-0 bg-white flex items-center justify-center z-[100]">
      <div className="text-center">
        <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
        <p className="text-slate-500 font-medium">Preparing Exam Environment...</p>
      </div>
    </div>
  );

  if (questions.length === 0) return (
    <div className="fixed inset-0 bg-white flex items-center justify-center z-[100]">
      <div className="text-center p-6 max-w-md">
        <AlertCircle size={48} className="text-red-500 mx-auto mb-4" />
        <h3 className="text-xl font-bold text-slate-900 mb-2">No Questions Found</h3>
        <p className="text-slate-500 mb-6">We couldn't find any questions for this test. Please contact the administrator.</p>
        <button 
          onClick={onExit}
          className="w-full py-3 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 transition-all"
        >
          Go Back
        </button>
      </div>
    </div>
  );

  const currentQ = questions[currentIdx];
  const sections: string[] = Array.from(new Set(questions.map(q => q.subject || 'General')));
  const examActionButtonClass = 'flex-1 md:flex-none inline-flex items-center justify-center px-4 md:px-6 py-2.5 text-xs md:text-sm font-bold rounded-xl transition-all active:scale-95';
  const examActionSecondaryButtonClass = `${examActionButtonClass} bg-white border border-slate-300 text-slate-700 hover:bg-slate-100`;
  const examActionPrimaryButtonClass = `${examActionButtonClass} md:w-40 shadow-md`;

  return (
    <div className="fixed inset-0 bg-[#f0f2f5] flex flex-col z-[100] overflow-hidden select-none font-sans text-sm">
      {/* Top Bar - TCS iON Style */}
      <header className="h-12 bg-[#2c3e50] text-white px-2 md:px-4 flex items-center justify-between shrink-0 shadow-md">
        <div className="flex items-center gap-2 md:gap-3">
          <div className="w-7 h-7 md:w-8 md:h-8 bg-white rounded-lg flex items-center justify-center">
            <span className="text-[#2c3e50] font-bold text-base md:text-lg">R</span>
          </div>
          <h2 className="font-bold text-[10px] md:text-sm tracking-wide uppercase truncate max-w-[120px] md:max-w-none">{test?.title}</h2>
        </div>

        <div className="flex items-center gap-1.5 md:gap-4">
          {!test?.isTournament && (
            <button 
              onClick={() => setIsPaused(true)}
              className="flex items-center gap-1 md:gap-2 bg-white/10 px-1.5 md:px-3 py-1 rounded-lg border border-white/10 hover:bg-white/20 transition-all active:scale-95"
            >
              <Clock size={12} className="text-yellow-400" />
              <span className="hidden sm:inline text-[10px] md:text-xs font-bold uppercase">Pause</span>
            </button>
          )}
          
          <div className="flex items-center gap-1 md:gap-2 bg-black/20 px-1.5 md:px-3 py-1 rounded-lg border border-white/10">
            <Clock size={12} className="text-blue-400" />
            <span className="font-mono text-xs sm:text-sm md:text-base font-bold">{formatTime(timeLeft)}</span>
          </div>
          <div className="flex items-center gap-1 bg-white/10 p-1 rounded-lg border border-white/10">
            <Globe size={14} className="hidden xs:block" />
            <button
              type="button"
              onClick={() => setLanguage('english')}
              className={`px-2 md:px-2.5 py-1 rounded-md text-[10px] md:text-xs font-bold transition-all active:scale-95 ${language === 'english' ? 'bg-white text-[#2c3e50] shadow-sm' : 'text-white/75 hover:text-white hover:bg-white/10'}`}
            >
              EN
            </button>
            <button
              type="button"
              onClick={() => setLanguage('hindi')}
              className={`px-2 md:px-2.5 py-1 rounded-md text-[10px] md:text-xs font-bold transition-all active:scale-95 ${language === 'hindi' ? 'bg-white text-[#2c3e50] shadow-sm' : 'text-white/75 hover:text-white hover:bg-white/10'}`}
            >
              HI
            </button>
          </div>
          <button 
            onClick={() => setShowMobileSidebar(true)}
            className="inline-flex lg:hidden items-center gap-1 bg-white/10 px-2 py-1 rounded-lg border border-white/10 text-[10px] md:text-xs font-bold uppercase tracking-wide active:scale-95"
          >
            <HelpCircle size={18} />
            <span className="hidden sm:inline">Palette</span>
          </button>
        </div>
      </header>

      {/* Section Tabs */}
      <div className="h-12 bg-[#e1e4e8] border-b border-slate-300 flex items-center px-2 md:px-4 shrink-0 overflow-x-auto no-scrollbar">
        <div className="flex h-full">
          {['All', ...sections].map((sec) => (
            <button
              key={sec}
              onClick={() => handleSectionChange(sec)}
              className={`
                px-5 md:px-8 h-full flex items-center text-xs md:text-sm font-bold transition-all border-r border-slate-300 whitespace-nowrap
                ${activeSection === sec 
                  ? 'bg-white text-blue-700 border-t-2 border-t-blue-600' 
                  : 'text-slate-600 hover:bg-slate-200'}
              `}
            >
              {sec.toUpperCase()}
            </button>
          ))}
        </div>
      </div>

      {/* Main Layout */}
      <div className="flex-1 flex overflow-hidden relative">
        {/* Left: Question Content */}
        <div className="flex-1 flex flex-col overflow-hidden bg-white border-r border-slate-300">
          <div className="h-12 bg-[#f8f9fa] border-b border-slate-200 flex items-center px-4 justify-between shrink-0">
            <div className="flex items-center gap-2">
              <span className="font-bold text-slate-700 text-sm md:text-base">Q. {currentIdx + 1}</span>
              <div className="flex items-center gap-1 md:gap-2 ml-2 md:ml-4">
                <span className="text-[10px] md:text-xs font-bold text-green-700 bg-green-50 px-2 py-0.5 rounded-md border border-green-200">+1.0</span>
                <span className="text-[10px] md:text-xs font-bold text-red-700 bg-red-50 px-2 py-0.5 rounded-md border border-red-200">-{test?.negativeMarking}</span>
              </div>
            </div>
            <button 
              type="button"
              onClick={() => setShowInstructions(true)}
              className="text-blue-600 hover:text-blue-700 hover:underline text-xs md:text-sm font-bold flex items-center gap-1 transition-colors cursor-pointer"
            >
              <Info size={14} />
              <span className="hidden sm:inline">View Instructions</span>
              <span className="sm:hidden">Info</span>
            </button>
          </div>

          <div className="flex-1 overflow-y-auto p-4 md:p-6">
            <div className="max-w-4xl mx-auto space-y-4 md:space-y-6">
              <div className="bg-slate-50 p-4 md:p-6 rounded-xl border border-slate-200">
                <MathText 
                  className="text-base md:text-lg font-medium text-slate-900 leading-relaxed"
                  text={language === 'hindi' && currentQ?.questionTextHindi ? currentQ.questionTextHindi : (currentQ?.questionTextEnglish || '')} 
                />
                {currentQ?.imageURL && (
                   <div className="mt-5">
                    <img src={currentQ.imageURL} alt="Question" className="max-h-60 md:max-h-80 w-auto rounded-xl border border-slate-300 shadow-sm" referrerPolicy="no-referrer" />
                  </div>
                )}
              </div>

              <div className="space-y-3 md:space-y-4">
                {currentQ?.options.map((opt, i) => {
                  const isSelected = currentQ && answers[currentQ.questionId] === i;
                  return (
                    <div
                      key={i}
                      onClick={() => handleOptionSelect(i)}
                      className={`
                        flex items-center gap-3 md:gap-4 p-3 md:p-4 rounded-xl border-2 cursor-pointer transition-all
                        ${isSelected 
                          ? 'border-blue-500 bg-blue-50 shadow-sm' 
                          : 'border-slate-100 hover:border-slate-200 hover:bg-slate-50'}
                      `}
                    >
                      <div className={`
                        w-7 h-7 md:w-8 md:h-8 rounded-full flex items-center justify-center font-bold text-[10px] md:text-xs leading-none transition-all shrink-0
                        ${isSelected 
                          ? 'bg-blue-600 text-white shadow-md' 
                          : 'bg-slate-100 text-slate-500 border border-slate-200'}
                      `}>
                        {String.fromCharCode(65 + i)}
                      </div>
                      <div className="flex-1 flex flex-col gap-1">
                        <div className="flex items-center gap-2 md:gap-3">
                          <MathText 
                            className="text-slate-800 font-medium text-sm md:text-base leading-relaxed"
                            text={language === 'hindi' && opt.textHindi ? opt.textHindi : opt.textEnglish}
                          />
                        </div>
                        {opt.image && <img src={opt.image} alt="Option" className="h-10 md:h-12 ml-auto" referrerPolicy="no-referrer" />}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Bottom Controls */}
          <div className="h-auto md:h-16 bg-[#f8f9fa] border-t border-slate-300 p-3 md:px-6 flex flex-col md:flex-row items-center justify-between shrink-0 gap-3">
            <div className="flex gap-3 w-full md:w-auto">
              <button 
                onClick={markForReviewAndNext}
                className={`${examActionSecondaryButtonClass} shadow-sm`}
              >
                Mark Review
              </button>
              <button 
                onClick={clearResponse}
                className={`${examActionSecondaryButtonClass} shadow-sm`}
              >
                Clear
              </button>
            </div>

            <div className="flex gap-3 w-full md:w-auto">
              <button 
                onClick={moveToPrevious}
                className={examActionSecondaryButtonClass}
              >
                Previous
              </button>
              {currentIdx === questions.length - 1 ? (
                <button 
                  onClick={() => {
                    if (currentQ) {
                      const qId = currentQ.questionId;
                      const isAnswered = answers[qId] !== undefined;
                      setStatusMap(prev => ({
                        ...prev,
                        [qId]: isAnswered ? QuestionStatus.ANSWERED : QuestionStatus.NOT_ANSWERED
                      }));
                    }
                    setShowSubmitConfirm(true);
                  }}
                  className={`${examActionPrimaryButtonClass} bg-[#007bff] text-white hover:bg-[#0069d9]`}
                >
                  Submit Test
                </button>
              ) : (
                <button 
                  onClick={saveAndNext}
                  disabled={activeSection !== 'All' && questions.findIndex((q, i) => i > currentIdx && (q.subject || 'General') === activeSection) === -1}
                  className={`${examActionPrimaryButtonClass} bg-[#28a745] text-white hover:bg-[#218838] disabled:opacity-50`}
                >
                  Save & Next
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Right: Sidebar Palette (Desktop) */}
        <div className="hidden lg:flex w-[280px] bg-[#e1e4e8] flex-col shrink-0 border-l border-slate-300">
          <QuestionPalette 
            questions={questions}
            statusMap={statusMap}
            activeSection={activeSection}
            currentIdx={currentIdx}
            getStatusCount={getStatusCount}
            jumpToQuestion={jumpToQuestion}
            setShowMobileSidebar={setShowMobileSidebar}
            setShowSubmitConfirm={setShowSubmitConfirm}
            profile={profile}
          />
        </div>

        {/* Mobile Sidebar Overlay */}
        <AnimatePresence>
          {showMobileSidebar && (
            <>
              <motion.div 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowMobileSidebar(false)}
                className="fixed inset-0 bg-black/50 z-[150] lg:hidden"
              />
              <motion.div 
                initial={{ x: '100%' }}
                animate={{ x: 0 }}
                exit={{ x: '100%' }}
                className="fixed top-0 right-0 bottom-0 w-[280px] bg-[#e1e4e8] z-[160] lg:hidden flex flex-col shadow-2xl"
              >
                <div className="h-12 bg-[#2c3e50] text-white flex items-center justify-between px-4 shrink-0">
                  <span className="font-bold text-xs uppercase">Question Palette</span>
                  <button onClick={() => setShowMobileSidebar(false)}>
                    <X size={20} />
                  </button>
                </div>
                <QuestionPalette 
                  questions={questions}
                  statusMap={statusMap}
                  activeSection={activeSection}
                  currentIdx={currentIdx}
                  getStatusCount={getStatusCount}
                  jumpToQuestion={jumpToQuestion}
                  setShowMobileSidebar={setShowMobileSidebar}
                  setShowSubmitConfirm={setShowSubmitConfirm}
                  profile={profile}
                />
              </motion.div>
            </>
          )}
        </AnimatePresence>
      </div>

      {/* Pause Modal */}
      <AnimatePresence>
        {isPaused && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/95 backdrop-blur-md flex items-center justify-center z-[300] p-6"
          >
            <motion.div 
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              className="bg-white rounded-xl p-6 max-w-sm w-full text-center shadow-2xl border-b-4 border-blue-600"
            >
              <div className="w-14 h-14 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center mx-auto mb-4">
                <Clock size={28} className="animate-pulse" />
              </div>
              <h3 className="text-xl font-black text-slate-900 mb-1 uppercase tracking-tight">Exam Paused</h3>
              <p className="text-slate-500 mb-6 text-xs font-medium leading-relaxed">
                Your exam timer is currently paused. Resume when you're ready. 
                <span className="block mt-1 text-blue-600 font-bold">Time Left: {formatTime(timeLeft)}</span>
              </p>
              <button 
                onClick={() => setIsPaused(false)}
                className="w-full bg-blue-600 text-white py-3 rounded-xl font-black text-base hover:bg-blue-700 transition-all shadow-lg shadow-blue-200 active:scale-95"
              >
                RESUME EXAM
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Warning Modal */}
      <AnimatePresence>
        {showWarning && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/80 backdrop-blur-sm flex items-center justify-center z-[200] p-6"
          >
            <motion.div 
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              className="bg-white rounded-xl p-8 max-w-md w-full text-center shadow-2xl border-t-4 border-red-600"
            >
              <div className="w-16 h-16 bg-red-100 text-red-600 rounded-xl flex items-center justify-center mx-auto mb-6">
                <AlertCircle size={32} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2">Security Warning!</h3>
              <p className="text-slate-600 mb-6 text-sm">
                Switching tabs or minimizing the browser is strictly prohibited. 
                Your exam will be automatically submitted after 3 warnings.
                <span className="block font-bold mt-3 text-red-600 text-lg">Warning {warningCount}/3</span>
              </p>
              <button 
                onClick={() => setShowWarning(false)}
                className="w-full bg-slate-900 text-white py-3 rounded-xl font-bold hover:bg-slate-800 transition-all active:scale-95"
              >
                I Understand, Resume Exam
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Submit Confirmation Modal */}
      <AnimatePresence>
        {showSubmitConfirm && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/80 backdrop-blur-sm flex items-center justify-center z-[200] p-6"
          >
            <motion.div 
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              className="bg-white rounded-xl p-8 max-w-md w-full text-center shadow-2xl"
            >
              <div className="w-16 h-16 bg-blue-100 text-blue-600 rounded-xl flex items-center justify-center mx-auto mb-6">
                <HelpCircle size={32} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2">Submit Test?</h3>
              <p className="text-slate-600 mb-8 text-sm">
                Are you sure you want to submit your test? You won't be able to change your answers after submission.
              </p>
              <div className="flex gap-4">
                <button 
                  onClick={() => setShowSubmitConfirm(false)}
                  className="flex-1 py-3 bg-slate-100 text-slate-700 font-bold rounded-xl hover:bg-slate-200 transition-all active:scale-95"
                >
                  Cancel
                </button>
                <button 
                  onClick={() => {
                    setShowSubmitConfirm(false);
                    handleSubmit();
                  }}
                  disabled={isSubmitting}
                  className="flex-1 py-3 bg-blue-600 text-white font-bold rounded-xl hover:bg-blue-700 transition-all disabled:opacity-50 active:scale-95"
                >
                  {isSubmitting ? 'Submitting...' : 'Yes, Submit'}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Instructions Modal */}
      <AnimatePresence>
        {showInstructions && (
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/80 backdrop-blur-sm flex items-center justify-center z-[200] p-6"
          >
            <motion.div 
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              className="bg-white rounded-xl max-w-2xl w-full shadow-2xl overflow-hidden flex flex-col max-h-[90vh]"
            >
              <div className="p-6 border-b border-slate-200 flex items-center justify-between bg-slate-50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center">
                    <Info size={24} />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-slate-900">Exam Instructions</h3>
                    <p className="text-xs text-slate-500 font-medium uppercase tracking-wider">Please read carefully</p>
                  </div>
                </div>
                <button 
                  onClick={() => setShowInstructions(false)}
                  className="p-2 hover:bg-slate-200 rounded-full transition-colors"
                >
                  <X size={24} className="text-slate-500" />
                </button>
              </div>
              
              <div className="p-6 overflow-y-auto flex-1 space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="p-4 bg-blue-50 rounded-xl border border-blue-100">
                    <p className="text-xs font-bold text-blue-600 uppercase mb-1">Duration</p>
                    <p className="text-lg font-bold text-slate-900">{test?.duration} Minutes</p>
                  </div>
                  <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-100">
                    <p className="text-xs font-bold text-emerald-600 uppercase mb-1">Total Questions</p>
                    <p className="text-lg font-bold text-slate-900">{questions.length} Questions</p>
                  </div>
                </div>

                <div className="space-y-4">
                  <h4 className="font-bold text-slate-900 flex items-center gap-2">
                    <div className="w-1.5 h-6 bg-blue-600 rounded-full" />
                    General Instructions
                  </h4>
                  <ul className="space-y-3">
                    {[
                      "The clock will be set at the server. The countdown timer in the top right corner of screen will display the remaining time available for you to complete the examination.",
                      "When the timer reaches zero, the examination will end by itself. You will not be required to end or submit your examination.",
                      "The Question Palette displayed on the right side of screen will show the status of each question.",
                      "You can click on the question number in the Question Palette to jump to that question directly.",
                      "Switching tabs or minimizing the browser is strictly prohibited and will lead to automatic submission."
                    ].map((text, i) => (
                      <li key={i} className="flex gap-3 text-sm text-slate-600 leading-relaxed">
                        <span className="flex-shrink-0 w-6 h-6 bg-slate-100 rounded-full flex items-center justify-center text-xs font-bold text-slate-500">{i + 1}</span>
                        {text}
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="space-y-4">
                  <h4 className="font-bold text-slate-900 flex items-center gap-2">
                    <div className="w-1.5 h-6 bg-emerald-600 rounded-full" />
                    Marking Scheme
                  </h4>
                  <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 space-y-3">
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-slate-600">Correct Answer</span>
                      <span className="text-sm font-bold text-emerald-600">+1.0 Mark</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-slate-600">Wrong Answer</span>
                      <span className="text-sm font-bold text-red-600">-{test?.negativeMarking} Mark</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-slate-600">Unattempted</span>
                      <span className="text-sm font-bold text-slate-400">0.0 Mark</span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="p-6 border-t border-slate-200 bg-slate-50">
                <button 
                  onClick={() => setShowInstructions(false)}
                  className="w-full py-3 bg-blue-600 text-white font-bold rounded-xl hover:bg-blue-700 shadow-lg shadow-blue-200 transition-all"
                >
                  I Have Read All Instructions
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
