import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { db, handleFirestoreError, OperationType } from '../firebase';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import { Attempt, Test, Question } from '../types';
import ResultView from './ResultView';
import { Loader2, AlertCircle, ChevronLeft } from 'lucide-react';
import { motion } from 'motion/react';

export default function ResultsPage() {
  const { attemptId } = useParams<{ attemptId: string }>();
  const navigate = useNavigate();
  const [attempt, setAttempt] = useState<Attempt | null>(null);
  const [test, setTest] = useState<Test | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchResults = async () => {
      if (!attemptId) return;
      setLoading(true);
      try {
        // Fetch Attempt
        const attemptSnap = await getDoc(doc(db, 'attempts', attemptId));
        if (!attemptSnap.exists()) {
          setError('Attempt not found.');
          setLoading(false);
          return;
        }
        const attemptData = { attemptId: attemptSnap.id, ...attemptSnap.data() } as Attempt;
        setAttempt(attemptData);

        // Fetch Test
        const testSnap = await getDoc(doc(db, 'tests', attemptData.testId));
        if (testSnap.exists()) {
          setTest({ testId: testSnap.id, ...testSnap.data() } as Test);
        }

        // Fetch Questions
        const qSnap = await getDocs(collection(db, 'tests', attemptData.testId, 'questions'));
        setQuestions(qSnap.docs.map(d => ({ questionId: d.id, ...d.data() } as Question)));

      } catch (err) {
        console.error('Error fetching results:', err);
        setError('Failed to load results. Please try again.');
        handleFirestoreError(err, OperationType.GET, `attempts/${attemptId}`);
      } finally {
        setLoading(false);
      }
    };

    fetchResults();
  }, [attemptId]);

  if (loading) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center min-h-[60vh]">
        <motion.div 
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
        >
          <Loader2 className="w-12 h-12 text-emerald-500" />
        </motion.div>
        <p className="mt-4 text-slate-500 font-medium font-sans">Analyzing your performance...</p>
      </div>
    );
  }

  if (error || !attempt) {
    return (
      <div className="flex-1 flex flex-col items-center justify-center min-h-[60vh] p-6 text-center">
        <AlertCircle className="w-16 h-16 text-rose-500 mb-4" />
        <h3 className="text-xl font-bold text-slate-900 mb-2">Error Loading Results</h3>
        <p className="text-slate-500 mb-6">{error || 'Something went wrong.'}</p>
        <button 
          onClick={() => navigate('/dashboard')}
          className="px-6 py-2 bg-slate-900 text-white rounded-xl font-bold hover:bg-slate-800 transition-all flex items-center gap-2"
        >
          <ChevronLeft size={18} />
          Back to Dashboard
        </button>
      </div>
    );
  }

  return (
    <div className="flex-1 flex flex-col min-h-0 overflow-hidden font-sans">
      <ResultView 
        attempt={attempt} 
        questions={questions} 
        negativeMarking={test?.negativeMarking || 0}
        test={test}
        onClose={() => navigate('/dashboard')}
        onWalletClick={() => navigate('/wallet')}
        onReattemptWrong={(wrongIds) => {
          navigate('/tests', { state: { reattemptTestId: attempt.testId, wrongIds } });
        }}
      />
    </div>
  );
}
