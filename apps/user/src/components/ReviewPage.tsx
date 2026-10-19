import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db, handleFirestoreError, OperationType } from '../firebase';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import { Attempt, Question, Test } from '../types';
import MathText from './MathText';
import { 
  CheckCircle2, 
  XCircle, 
  ChevronLeft, 
  ChevronRight, 
  Eye,
  Loader2,
  AlertCircle,
  Clock
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export default function ReviewPage({ setHeaderAction }: { setHeaderAction: (action: React.ReactNode) => void }) {
  const { attemptId } = useParams<{ attemptId: string }>();
  const navigate = useNavigate();
  
  const [attempt, setAttempt] = useState<Partial<Attempt> | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  const [reviewIdx, setReviewIdx] = useState(0);
  const [language, setLanguage] = useState<'english' | 'hindi'>('hindi');

  useEffect(() => {
    setHeaderAction(
      <button 
        onClick={() => navigate(-1)} 
        className="p-2 -ml-2 text-white hover:text-emerald-100 transition-colors active:scale-95"
        title="Back to Result"
      >
        <ChevronLeft size={24} />
      </button>
    );
    return () => setHeaderAction(null);
  }, [navigate]);

  useEffect(() => {
    const fetchResults = async () => {
      if (!attemptId) return;
      setLoading(true);
      try {
        const attemptSnap = await getDoc(doc(db, 'attempts', attemptId));
        if (!attemptSnap.exists()) {
          setError('Attempt not found.');
          return;
        }
        const attemptData = { attemptId: attemptSnap.id, ...attemptSnap.data() } as Attempt;
        setAttempt(attemptData);

        const qSnap = await getDocs(collection(db, 'tests', attemptData.testId, 'questions'));
        setQuestions(qSnap.docs.map(d => ({ questionId: d.id, ...d.data() } as Question)));
      } catch (err) {
        console.error('Error fetching review data:', err);
        setError('Failed to load review. Please try again.');
        handleFirestoreError(err, OperationType.GET, `attempts/${attemptId}`);
      } finally {
        setLoading(false);
      }
    };
    fetchResults();
  }, [attemptId]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <motion.div 
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
        >
          <Loader2 className="w-12 h-12 text-emerald-500" />
        </motion.div>
        <p className="mt-4 text-slate-500 font-medium font-sans">Loading questions...</p>
      </div>
    );
  }

  if (error || !attempt || questions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center p-6 text-center py-12">
        <AlertCircle className="w-16 h-16 text-rose-500 mb-4" />
        <h3 className="text-xl font-bold text-slate-900 mb-2">Error Loading Review</h3>
        <p className="text-slate-500 mb-6">{error || 'Something went wrong.'}</p>
        <button 
          onClick={() => navigate(-1)}
          className="px-6 py-2 bg-slate-900 text-white rounded-xl font-bold hover:bg-slate-800 transition-all flex items-center gap-2"
        >
          <ChevronLeft size={18} />
          Go Back
        </button>
      </div>
    );
  }

  const q = questions[reviewIdx];
  const userAns = attempt.answers?.[q.questionId];
  const isCorrect = userAns === q.correctAnswer;

  return (
    <div className="bg-transparent flex flex-col">
      <main className="flex-1 overflow-y-auto">
        <div className="max-w-5xl space-y-6">

          {/* Question Card */}
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            key={reviewIdx}
            className="bg-white rounded-xl p-6 md:p-8 border border-slate-200/60 shadow-xl shadow-slate-200/20 space-y-6"
          >
            {/* Inner Top Strip: Title & Language Toggle Horizontally Aligned */}
            <div className="flex items-center justify-between gap-2 pb-4 border-b border-slate-50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-emerald-100 text-emerald-600 rounded-lg flex items-center justify-center shadow-sm shrink-0">
                  <CheckCircle2 size={18} />
                </div>
                <h3 className="text-base font-bold text-slate-900 whitespace-nowrap">Question Review</h3>
              </div>

              {/* Language Toggle (Now on Far Right Edge) */}
              <div className="flex items-center justify-end">
                <div className="flex items-center gap-2 bg-slate-100 p-1 rounded-lg border border-slate-200 shadow-sm">
                  <button 
                    onClick={() => setLanguage('english')}
                    className={`px-3 py-1 rounded-md text-[10px] font-bold transition-all active:scale-95 ${language === 'english' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
                  >
                    EN
                  </button>
                  <button 
                    onClick={() => setLanguage('hindi')}
                    className={`px-3 py-1 rounded-md text-[10px] font-bold transition-all active:scale-95 ${language === 'hindi' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
                  >
                    HI
                  </button>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <span className={`px-3 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest ${isCorrect ? 'bg-emerald-100 text-emerald-600' : userAns === undefined ? 'bg-slate-100 text-slate-500' : 'bg-red-100 text-red-600'}`}>
                {isCorrect ? 'Correct' : userAns === undefined ? 'Skipped' : 'Incorrect'}
              </span>
              <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{q.subject}</span>
            </div>

            {/* Question Text with Number on Left */}
            <div className="flex gap-4 items-start pt-2">
              <div className="text-base font-black text-emerald-500 shrink-0 bg-emerald-50 w-8 h-8 rounded-lg flex items-center justify-center border border-emerald-100 shadow-sm mt-0.5">
                {reviewIdx + 1}
              </div>
              <MathText 
                className="text-lg md:text-xl font-medium text-slate-900 leading-relaxed pt-0.5"
                text={language === 'hindi' && q.questionTextHindi ? q.questionTextHindi : q.questionTextEnglish}
              />
            </div>

            <div className="grid gap-3">
              {q.options.map((opt, i) => {
                const isUserChoice = userAns === i;
                const isCorrectChoice = q.correctAnswer === i;
                
                let borderColor = 'border-slate-100';
                let bgColor = 'bg-white';
                let icon = null;

                if (isCorrectChoice) {
                  borderColor = 'border-emerald-500';
                  bgColor = 'bg-emerald-50';
                  icon = <CheckCircle2 size={18} className="text-emerald-500" />;
                } else if (isUserChoice && !isCorrect) {
                  borderColor = 'border-red-500';
                  bgColor = 'bg-red-50';
                  icon = <XCircle size={18} className="text-red-500" />;
                }

                return (
                  <div key={i} className={`flex items-center justify-between p-4 rounded-xl border-2 transition-all ${borderColor} ${bgColor}`}>
                    <div className="flex items-center gap-3">
                      <span className="font-bold text-slate-400 text-sm">({String.fromCharCode(65 + i)})</span>
                      <MathText 
                        className="text-slate-800 font-medium"
                        text={language === 'hindi' && opt.textHindi ? opt.textHindi : opt.textEnglish}
                      />
                    </div>
                    {icon}
                  </div>
                );
              })}
            </div>

            {/* Explanation */}
            <div className="mt-8 pt-8 border-t border-slate-100">
              <h4 className="flex items-center gap-2 text-blue-600 font-bold mb-3">
                <Eye size={18} />
                {language === 'hindi' ? 'व्याख्या' : 'Explanation'}
              </h4>
              <MathText 
                className="text-slate-600 leading-relaxed italic"
                text={language === 'hindi' 
                  ? (q.explanationHindi || q.explanation || 'इस प्रश्न के लिए कोई व्याख्या प्रदान नहीं की गई है।') 
                  : (q.explanation || 'No explanation provided for this question.')}
              />
            </div>
          
            {/* Navigation Buttons Inside Card */}
            <div className="grid grid-cols-2 gap-4 mt-8 pt-8 border-t border-slate-100">
              <button 
                disabled={reviewIdx === 0}
                onClick={() => setReviewIdx(prev => prev - 1)}
                className="flex-1 py-3 bg-white border border-slate-200 text-slate-700 rounded-xl font-bold hover:bg-slate-50 transition-all disabled:opacity-50 flex items-center justify-center gap-2 shadow-sm active:scale-95"
              >
                <ChevronLeft size={18} />
                {language === 'hindi' ? 'पिछला' : 'Previous'}
              </button>
              <button 
                disabled={reviewIdx === questions.length - 1}
                onClick={() => setReviewIdx(prev => prev + 1)}
                className="flex-1 py-3 bg-slate-900 text-white rounded-xl font-bold hover:bg-slate-800 transition-all disabled:opacity-50 flex items-center justify-center gap-2 shadow-lg shadow-slate-200 active:scale-95"
              >
                {language === 'hindi' ? 'अगला' : 'Next'}
                <ChevronRight size={18} />
              </button>
            </div>
          </motion.div>
        </div>
      </main>
    </div>
  );
}
