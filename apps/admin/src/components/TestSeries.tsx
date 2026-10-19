import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, getDocs, query, where, limit, getCountFromServer, startAfter, orderBy, DocumentData, QueryDocumentSnapshot } from 'firebase/firestore';
import { Test, UserProfile, Category, ExamCategory } from '../types';
import { Search, Clock, Target, Lock, LockKeyhole, Play, ChevronRight, Layers, FileText, BookOpen, ChevronLeft, Users, Zap, Globe, Megaphone, Award, CheckCircle2, Coins, TrendingUp, Share2, ShoppingBag } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import {
  cleanExamCategoryName,
  findExamCategoryGroupByName,
  groupExamCategories
} from '../utils/examCategories';
import ContestJoinModal from './TournamentJoinModal';
import ContestCard from './TournamentCard';
import TestPurchaseModal from './TestPurchaseModal';
import { useToast } from './Toast';
import { shareContent, getTestShareLink } from '../utils/shareUtils';

interface TestSeriesProps {
  onStartTest: (id: string) => void;
  onNavigate: (page: string) => void;
  profile: UserProfile | null;
  setHeaderAction?: (node: React.ReactNode) => void;
}

type ViewState = 'exam-categories' | 'mode-selection' | 'mock-tests' | 'sectional-subjects' | 'sectional-topics' | 'sectional-tests' | 'previous-year-tests' | 'purchased-tests';

export default function TestSeries({ onStartTest, onNavigate, profile, setHeaderAction }: TestSeriesProps) {
  const { showToast } = useToast();
  const [view, setView] = useState<ViewState>('exam-categories');
  const [selectedExamCategory, setSelectedExamCategory] = useState<string | null>(null);
  const [selectedSubject, setSelectedSubject] = useState<string | null>(null);
  const [selectedTopic, setSelectedTopic] = useState<string | null>(null);
  const [joiningContest, setJoiningContest] = useState<Test | null>(null);

  const [tests, setTests] = useState<Test[]>([]);
  const [sectionalCatalogTests, setSectionalCatalogTests] = useState<Test[]>([]);
  const [loadedSectionalCatalogFor, setLoadedSectionalCatalogFor] = useState<string | null>(null);
  const [examCategories, setExamCategories] = useState<ExamCategory[]>([]);
  const [subjectsData, setSubjectsData] = useState<Category[]>([]);
  const [counts, setCounts] = useState<Record<string, { mock: number; sectional: number }>>({});
  const [lastDoc, setLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [isLoadingTests, setIsLoadingTests] = useState(false);
  const [isLoadingSectionalCatalog, setIsLoadingSectionalCatalog] = useState(false);
  const [search, setSearch] = useState('');
  const [categorySearch, setCategorySearch] = useState('');
  const [subjectSearch, setSubjectSearch] = useState('');
  const [topicSearch, setTopicSearch] = useState('');
  const [isSearchingCategories, setIsSearchingCategories] = useState(false);
  const [unlockedTestIds, setUnlockedTestIds] = useState<Set<string>>(new Set());
  const [purchasedCategories, setPurchasedCategories] = useState<Set<string>>(new Set());
  const [purchasingTest, setPurchasingTest] = useState<Test | null>(null);
  const [showOnlyPurchased, setShowOnlyPurchased] = useState(false);
  const [purchasedTestsList, setPurchasedTestsList] = useState<Test[]>([]);
  const [isLoadingPurchased, setIsLoadingPurchased] = useState(false);

  useEffect(() => {
    const fetchUnlockedTests = async () => {
      if (!profile?.userId) {
        setUnlockedTestIds(new Set());
        setPurchasedCategories(new Set());
        return;
      }
      try {
        const snap = await getDocs(collection(db, 'users', profile.userId, 'unlockedTests'));
        const ids = snap.docs.map(doc => doc.id);
        setUnlockedTestIds(new Set(ids));

        // Fetch category info for these tests to filter categories view
        if (ids.length > 0) {
          const categories = new Set<string>();
          const fetchedTests: Test[] = [];
          // Process in chunks of 30 for Firestore 'in' query
          for (let i = 0; i < ids.length; i += 30) {
            const chunk = ids.slice(i, i + 30);
            const q = query(collection(db, 'tests'), where('__name__', 'in', chunk));
            const testSnap = await getDocs(q);
            testSnap.forEach(doc => {
              const data = doc.data();
              fetchedTests.push({ testId: doc.id, ...data } as Test);
              const cat = data.examCategory || data.category || data.examType;
              if (cat) categories.add(normalizeText(cat));
            });
          }
          setPurchasedCategories(categories);
          setPurchasedTestsList(fetchedTests);
        } else {
          setPurchasedTestsList([]);
        }
      } catch (err) {
        console.error("Error fetching unlocked tests:", err);
      } finally {
        setIsLoadingPurchased(false);
      }
    };
    fetchUnlockedTests();
  }, [profile?.userId]);

  const onTestUnlocked = (testId: string) => {
    setUnlockedTestIds(prev => new Set([...prev, testId]));
    setPurchasingTest(null);
  };

  const normalizeText = (value?: string | null) => value?.trim().toLowerCase() || '';
  const looselyMatchesText = (left?: string | null, right?: string | null) =>
    normalizeText(left) === normalizeText(right);
  const groupedExamCategories = groupExamCategories(examCategories);

  const fetchCategories = async () => {
    setIsSearchingCategories(true);
    try {
      const q = query(collection(db, 'examCategories'), limit(100));
      const snap = await getDocs(q);
      const fetched = snap.docs.map(d => ({ id: d.id, ...(d.data() as object) } as ExamCategory));
      setExamCategories(fetched);
    } catch (err) {
      console.error("Error fetching categories:", err);
    } finally {
      setIsSearchingCategories(false);
    }
  };

  const fetchCounts = async (categories: ExamCategory[]) => {
    try {
      const groups = groupExamCategories(categories);
      const countsPromises = groups.map(async (cat) => {
        if (cat.isPublished === false) return null;
        
        const examNames = Array.from(new Set(
          cat.rawCategories.map((category) => cleanExamCategoryName(category.name)).filter(Boolean)
        ));

        const [mockResults, sectionalResults] = await Promise.all([
          Promise.all(examNames.map((examName) => getCountFromServer(query(
            collection(db, 'tests'),
            where('examCategory', '==', examName),
            where('testMode', '==', 'mock'),
            where('status', '==', 'published')
          )))),
          Promise.all(examNames.map((examName) => getCountFromServer(query(
            collection(db, 'tests'),
            where('examCategory', '==', examName),
            where('testMode', '==', 'sectional'),
            where('status', '==', 'published')
          ))))
        ]);

        return {
          name: cat.name,
          mock: mockResults.reduce((total, snap) => total + snap.data().count, 0),
          sectional: sectionalResults.reduce((total, snap) => total + snap.data().count, 0)
        };
      });

      const results = await Promise.all(countsPromises);
      const newCounts: Record<string, { mock: number; sectional: number }> = {};
      results.forEach(res => {
        if (res) newCounts[res.name] = { mock: res.mock, sectional: res.sectional };
      });
      
      setCounts(prev => ({ ...prev, ...newCounts }));
    } catch (err) {
      console.error("Error fetching counts:", err);
    }
  };

  const fetchSectionalCatalogTests = async (examCategoryName: string | null) => {
    if (!examCategoryName) {
      setSectionalCatalogTests([]);
      setLoadedSectionalCatalogFor(null);
      return;
    }

    setIsLoadingSectionalCatalog(true);
    try {
      const examCategoryGroup = findExamCategoryGroupByName(examCategories, examCategoryName);
      const examNames = Array.from(new Set(
        (examCategoryGroup?.rawCategories || [{ name: examCategoryName } as ExamCategory])
          .map((category) => cleanExamCategoryName(category.name))
          .filter(Boolean)
      ));

      const currentSchemaSnaps = await Promise.all(examNames.map((examName) => getDocs(query(
        collection(db, 'tests'),
        where('examCategory', '==', examName),
        where('testMode', '==', 'sectional'),
        limit(50) // Limit loading items to prevent memory issues
      ))));

      let fetchedTests = currentSchemaSnaps.flatMap((snap) =>
        snap.docs.map((doc) => ({ testId: doc.id, ...(doc.data() as object) } as Test))
      );

      // Fallback for older sectional tests
      if (fetchedTests.length === 0) {
        const legacySnaps = await Promise.all(examNames.map((examName) => getDocs(query(
          collection(db, 'tests'),
          where('examCategory', '==', examName),
          limit(50)
        ))));

        fetchedTests = legacySnaps
          .flatMap((snap) => snap.docs.map((doc) => ({ testId: doc.id, ...(doc.data() as object) } as Test)))
          .filter(test => getTestMatches(test, examNames, 'sectional'));
      }

      setSectionalCatalogTests(fetchedTests.filter(test => test.status !== 'unpublished'));
      setLoadedSectionalCatalogFor(examCategoryName);
    } catch (err) {
      console.error('Error fetching sectional catalog tests:', err);
      setSectionalCatalogTests([]);
      setLoadedSectionalCatalogFor(null);
    } finally {
      setIsLoadingSectionalCatalog(false);
    }
  };

  const fetchTests = async (reset = false) => {
    if (isLoadingTests || (!hasMore && !reset)) return;
    setIsLoadingTests(true);
    
    try {
      let q;
      
      // Server-side Search requires inequality filters to be the first orderBy
      // If we are searching, we sort by title_lowercase to satisfy Firestore requirements
      if (search.trim()) {
        const searchLower = search.toLowerCase();
        q = query(
          collection(db, 'tests'),
          where('title_lowercase', '>=', searchLower),
          where('title_lowercase', '<=', searchLower + '\uf8ff'),
          orderBy('title_lowercase')
        );
      } else {
        q = query(collection(db, 'tests'), orderBy('createdAt', 'desc'));
      }

      // Filter by Exam Category (Group-Aware)
      if (selectedExamCategory) {
        const examCategoryGroup = findExamCategoryGroupByName(examCategories, selectedExamCategory);
        const examNames = Array.from(new Set(
          (examCategoryGroup?.rawCategories || [{ name: selectedExamCategory } as ExamCategory])
            .map((category) => cleanExamCategoryName(category.name))
            .filter(Boolean)
        ));

        if (examNames.length > 1) {
          q = query(q, where('examCategory', 'in', examNames.slice(0, 10)));
        } else if (examNames.length === 1) {
          q = query(q, where('examCategory', '==', examNames[0]));
        }
      }

      // Filter by Mode
      const mode = view === 'mock-tests' ? 'mock' : view === 'previous-year-tests' ? 'previous-year' : view === 'sectional-tests' ? 'sectional' : null;
      if (mode) {
        q = query(q, where('testMode', '==', mode));
      }

      // Filter by Subject/Topic for Sectional
      if (view === 'sectional-tests') {
        if (selectedSubject) q = query(q, where('subject', '==', selectedSubject));
        if (selectedTopic) q = query(q, where('topic', '==', selectedTopic));
      }

      // Pagination
      if (!reset && lastDoc) {
        q = query(q, startAfter(lastDoc));
      }

      q = query(q, limit(12));

      const snap = await getDocs(q);
      const allFetched = snap.docs.map(doc => ({ testId: doc.id, ...(doc.data() as object) } as Test));
      const fetchedTests = allFetched.filter(t => t.status !== 'unpublished');

      if (reset) {
        setTests(fetchedTests);
      } else {
        setTests(prev => [...prev, ...fetchedTests]);
      }

      setLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMore(snap.docs.length === 12);
    } catch (err) {
      console.error("Error fetching tests:", err);
    } finally {
      setIsLoadingTests(false);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [subSnap, categoriesSnap] = await Promise.all([
          getDocs(query(collection(db, 'categories'), limit(100))),
          getDocs(query(collection(db, 'examCategories'), limit(100)))
        ]);

        const fetchedSubjects = subSnap.docs.map(d => ({ id: d.id, ...d.data() } as Category));
        const fetchedExamCategories = categoriesSnap.docs.map(d => ({ id: d.id, ...d.data() } as ExamCategory));
        
        setSubjectsData(fetchedSubjects);
        setExamCategories(fetchedExamCategories);
        
        // Fetch counts for the home screen after basic data is loaded
        fetchCounts(fetchedExamCategories);
      } catch (err) {
        console.error("Error in TestSeries initial fetch:", err);
      }
    };
    fetchData();
  }, []);

  // Reset and fetch tests when category or view changes
  useEffect(() => {
    if (view === 'mock-tests' || view === 'previous-year-tests') {
      fetchTests(true);
    }
  }, [selectedExamCategory, view, selectedSubject, selectedTopic]);

  // Debounced search
  useEffect(() => {
    const timer = setTimeout(() => {
      if (view === 'mock-tests' || view === 'previous-year-tests') {
        fetchTests(true);
      }
    }, 500);
    return () => clearTimeout(timer);
  }, [search]);

  // No longer needed: Debounced search for categories removed in favor of local case-insensitive search

  // Helper to determine if a test belongs to an exam category and matches mode
  const getTestMatches = (test: Test, allowedExamNames: string[], mode: 'mock' | 'sectional' | 'previous-year') => {
    const isModeMatch = test.testMode 
      ? test.testMode === mode 
      : (mode === 'sectional' ? !!(test.subject && test.topic) : !test.subject);
    
    // Some old tests might have exam tag in `category` or `examType`.
    const testExamCat = test.examCategory || test.category || test.examType || 'General';
    const normalizedTestCat = normalizeText(testExamCat);
    
    const isCatMatch = allowedExamNames.some(name => normalizeText(name) === normalizedTestCat) || 
                      (testExamCat === 'General' && allowedExamNames.some(name => normalizeText(name) === 'general'));
    
    return isModeMatch && isCatMatch;
  };

  const matchesSectionalSubject = (test: Test, subjectName: string) =>
    looselyMatchesText(test.subject, subjectName) || looselyMatchesText(test.category, subjectName);

  const matchesSectionalTopic = (test: Test, topicName: string) =>
    looselyMatchesText(test.topic, topicName);

  const activeTests = ((view === 'sectional-tests' && sectionalCatalogTests.length > 0)
    ? sectionalCatalogTests.filter(t => 
        matchesSectionalSubject(t, selectedSubject || '') && 
        matchesSectionalTopic(t, selectedTopic || '') &&
        (!search.trim() || t.title.toLowerCase().includes(search.toLowerCase()))
      )
    : view === 'purchased-tests' ? purchasedTestsList.filter(t => !search.trim() || t.title.toLowerCase().includes(search.toLowerCase()))
    : tests).filter(t => {
      if (!showOnlyPurchased && view !== 'purchased-tests') return true;
      const isUnlocked = unlockedTestIds.has(t.testId);
      const isPremiumSubscriber = profile?.subscriptionStatus === 'premium';
      return isUnlocked || (t.isPremium && isPremiumSubscriber);
    }); 

  const hasMoreAvailable = view === 'sectional-tests' ? false : hasMore;

  useEffect(() => {
    if (view === 'sectional-subjects' || view === 'sectional-topics') {
      if (loadedSectionalCatalogFor === selectedExamCategory) return;
      fetchSectionalCatalogTests(selectedExamCategory);
    }
  }, [loadedSectionalCatalogFor, selectedExamCategory, view]);

  const handleBack = () => {
    setSearch('');
    switch (view) {
      case 'mode-selection':
        setView('exam-categories');
        setSelectedExamCategory(null);
        setCategorySearch('');
        break;
      case 'mock-tests':
      case 'previous-year-tests':
        setView('mode-selection');
        setSearch('');
        break;
      case 'sectional-subjects':
        setView('mode-selection');
        setSelectedSubject(null);
        setSubjectSearch('');
        break;
      case 'sectional-topics':
        setView('sectional-subjects');
        setSelectedTopic(null);
        setTopicSearch('');
        break;
      case 'sectional-tests':
        setView('sectional-topics');
        setSearch('');
        break;
      case 'purchased-tests':
        setView('exam-categories');
        setSearch('');
        setShowOnlyPurchased(false);
        break;
      default:
        break;
    }
  };

  // Filter categories based on search (Case-Insensitive)
  const filteredExamCategories = groupedExamCategories.filter(cat => {
    if (cat.isPublished === false) return false;
    
    // Search filter
    const matchesSearch = cat.name.toLowerCase().includes(categorySearch.trim().toLowerCase());
    if (!matchesSearch) return false;

    // Purchased filter
    if (showOnlyPurchased) {
      // Premium users see all categories as they have access to everything
      if (profile?.subscriptionStatus === 'premium') return true;
      
      // Free users only see categories where they have at least one purchased test
      // We check if any of the category's aliases or raw names match our purchased set
      const catNames = [
        normalizeText(cat.name),
        ...(cat.rawCategories?.map(r => normalizeText(r.name)) || [])
      ];
      return catNames.some(name => purchasedCategories.has(name));
    }

    return true;
  });

  const TestCard = ({ test }: { test: Test; key?: any }) => {
    if (test.isTournament) {
      return (
        <ContestCard 
          test={test} 
          profile={profile} 
          onJoin={(t) => setJoiningContest(t)}
          onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
        />
      );
    }

    const isPYQ = test.testMode === 'previous-year';
    const isSectional = test.testMode === 'sectional';
    const testExamCat = test.examCategory || test.category || test.examType || 'General';
    const isUnlocked = unlockedTestIds.has(test.testId);
    const isPro = profile?.subscriptionStatus === 'premium' && (!profile?.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date());
    const isPremiumAndLocked = test.isPremium && !isPro && !isUnlocked;
    
    // Theme Colors based on test mode
    const themeColor = isSectional ? '#3b82f6' : isPYQ ? '#a855f7' : '#10b981';
    const themeShadow = isSectional ? 'shadow-blue-100' : isPYQ ? 'shadow-purple-100' : 'shadow-emerald-100';

    return (
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        whileHover={{ y: -4 }}
        onClick={() => {
          if (isPremiumAndLocked) {
            setPurchasingTest(test);
          } else {
            onStartTest(test.testId);
          }
        }}
        className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full"
      >
        {/* Decorative SVG Wave (Top-Left) */}
        <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
          <svg viewBox="0 0 100 100" className="w-full h-full">
            <defs>
              <linearGradient id={`testCornerGradient-${test.testId}`} x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor={themeColor} />
                <stop offset="100%" stopColor={themeColor} />
              </linearGradient>
              <filter id={`testCardShadow-${test.testId}`} x="-20%" y="-20%" width="140%" height="140%">
                <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                <feOffset dx="1" dy="1" result="offsetblur" />
                <feComponentTransfer>
                  <feFuncA type="linear" slope="0.3" />
                </feComponentTransfer>
                <feMerge>
                  <feMergeNode />
                  <feMergeNode in="SourceGraphic" />
                </feMerge>
              </filter>
            </defs>
            <path 
              d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" 
              fill={`url(#testCornerGradient-${test.testId})`}
              filter={`url(#testCardShadow-${test.testId})`}
            />
          </svg>
        </div>

        {/* Top-Right Professional Dot Grid */}
        <div 
          className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
          style={{
            backgroundImage: `radial-gradient(${themeColor} 1.2px, transparent 1.2px)`,
            backgroundSize: '12px 12px',
            maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
            WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
          }}
        ></div>

        <div className="relative z-10 p-5 flex-1 flex flex-col">
          <div className="flex items-start gap-3 mb-4">
            <div className={`w-11 h-11 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center shrink-0 relative z-10 ${isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}`}>
              {isSectional ? <BookOpen size={20} /> : isPYQ ? <Clock size={20} /> : <FileText size={20} />}
            </div>
            <div className="flex-1">
              <h3 className={`text-[16px] font-black text-slate-800 leading-tight z-10 transition-colors line-clamp-2 uppercase ${isPremiumAndLocked ? 'group-hover:text-amber-600' : isSectional ? 'group-hover:text-blue-600' : 'group-hover:text-emerald-600'}`}>
                {test.title}
              </h3>
              {isPremiumAndLocked && (
                <div className="mt-2 inline-flex bg-amber-50 px-2 py-0.5 rounded border border-amber-200 text-[9px] font-black text-amber-600 items-center gap-1 shadow-sm uppercase tracking-wider">
                  <LockKeyhole size={10} strokeWidth={3} /> PREMIUM
                </div>
              )}
              {test.isPremium && (isUnlocked || profile?.subscriptionStatus === 'premium') && (
                <div className="mt-2 inline-flex bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100 text-[9px] font-black text-emerald-600 items-center gap-1 shadow-sm uppercase tracking-wider">
                  <CheckCircle2 size={10} /> PREMIUM UNLOCKED
                </div>
              )}
            </div>
          </div>
          
          <div className="flex flex-wrap items-center gap-3 mb-4 z-10">
            <div className="text-[11px] font-black text-slate-500 flex items-center gap-2 uppercase bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                <Award size={14} className="text-slate-400" />
              </div>
              {testExamCat}
            </div>
            <div className="flex items-center gap-2 text-[12px] font-bold text-slate-600 bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                <Target size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
              </div>
              <span>{test.totalQuestions} Qs</span>
            </div>
            <div className="flex items-center gap-2 text-[12px] font-bold text-slate-600 bg-slate-50/80 pl-1 pr-2.5 py-1 rounded-lg">
              <div className="w-6 h-6 rounded-full bg-white shadow-sm flex items-center justify-center">
                <Clock size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
              </div>
              <span>{test.duration} mins</span>
            </div>
          </div>
          
          <div className="space-y-3 text-[12px] text-slate-600 font-medium z-10 mb-6 flex-1 tracking-tight">
            <div className="flex items-center gap-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                <CheckCircle2 size={14} className={isSectional ? 'text-blue-500' : isPYQ ? 'text-purple-500' : 'text-emerald-500'} />
              </div>
              <span>Detailed Solutions & Analytics</span>
            </div>
            <div className="flex items-center gap-3">
              <div className={`w-6 h-6 rounded-full flex items-center justify-center ${isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                <TrendingUp size={14} className={isSectional ? 'text-blue-500' : isPYQ ? 'text-purple-500' : 'text-emerald-500'} />
              </div>
              <span>State & National Leaderboard</span>
            </div>
            <div className={`flex items-center gap-2 text-[11px] font-bold mt-2 pt-2 border-t border-slate-50 z-10 uppercase tracking-tight ${isPremiumAndLocked ? 'text-amber-600' : isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}`}>
              <div className={`w-6 h-6 rounded-full shadow-sm flex items-center justify-center ${isPremiumAndLocked ? 'bg-amber-50' : isSectional ? 'bg-blue-50' : isPYQ ? 'bg-purple-50' : 'bg-emerald-50'}`}>
                <Globe size={14} />
              </div>
              {findExamCategoryGroupByName(examCategories, testExamCat)?.languages || 'English, Hindi'}
            </div>
          </div>
          <div className="mt-auto flex items-center gap-2 z-10">
            <button
              onClick={(e) => { 
                e.stopPropagation(); 
                if (isPremiumAndLocked) {
                  setPurchasingTest(test);
                } else if (test.isTournament) {
                  setJoiningContest(test);
                } else {
                  onStartTest(test.testId); 
                }
              }}
              className={`
                flex-1 py-3 rounded-xl font-black text-sm shadow-sm transition-all flex items-center justify-center gap-2 active:scale-95 uppercase tracking-wider
                ${isPremiumAndLocked
                  ? 'bg-amber-500 text-white hover:bg-amber-600 shadow-amber-100'
                  : test.isTournament 
                    ? (test.scheduledStartTime && new Date() < new Date(test.scheduledStartTime) 
                        ? 'bg-amber-500 text-white hover:bg-amber-600' 
                        : 'bg-indigo-600 text-white hover:bg-indigo-700')
                    : isSectional ? 'bg-blue-500 text-white hover:bg-blue-600 shadow-blue-100' : 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-emerald-100'}
              `}
            >
              {isPremiumAndLocked ? (
                <>
                  Unlock Now <LockKeyhole size={16} strokeWidth={3} />
                </>
              ) : test.isTournament ? (
                <>Join Contest <Play size={14} fill="currentColor" strokeWidth={0}/></>
              ) : (
                <>Practice Now <Play size={14} fill="currentColor" strokeWidth={0}/></>
              )}
            </button>
            
            <button
              onClick={async (e) => {
                e.stopPropagation();
                const result = await shareContent({
                  title: test.title,
                  text: `Hey! Check out this ${test.isTournament ? 'Tournament' : 'Test'}: "${test.title}" on Rankearn. Start practicing and winning!`,
                  url: getTestShareLink(test.testId),
                  imageUrl: '/share-banner.png'
                });
                if (result.success) {
                  showToast(result.method === 'native' ? 'Shared successfully!' : 'Link copied to clipboard!', 'success');
                }
              }}
              className="px-4 py-3 rounded-xl border border-slate-100 text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all active:scale-95 shadow-sm bg-white shrink-0 flex items-center justify-center gap-2"
              title="Share Test"
            >
              <Share2 size={18} />
              <span className="text-[10px] font-black uppercase tracking-wider">Share</span>
            </button>
          </div>
        </div>
      </motion.div>
    );
  };

  useEffect(() => {
    if (setHeaderAction) {
      if (view !== 'exam-categories') {
        setHeaderAction(
          <button 
            onClick={handleBack}
            className="flex items-center gap-1 text-white hover:text-emerald-100 transition-colors text-sm font-bold ml-2"
          >
            <ChevronLeft size={18} /> Back
          </button>
        );
      } else {
        setHeaderAction(null);
      }
    }
    
    // Cleanup on unmount
    return () => {
      if (setHeaderAction) setHeaderAction(null);
    };
  }, [view, setHeaderAction]);

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <AnimatePresence mode="wait">
        {/* VIEW 1: EXAM CATEGORIES */}
        {view === 'exam-categories' && (
          <motion.div 
            key="v-exam-categories"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="space-y-6"
          >
            {/* Search Bar for Categories - Full Width */}
            <div className="flex items-center gap-2 mb-8">
              <button
                onClick={() => {
                  setView('purchased-tests');
                  setShowOnlyPurchased(true);
                }}
                className={`flex items-center justify-center gap-2 px-3 sm:px-6 py-3 rounded-xl font-black text-[10px] sm:text-xs uppercase tracking-widest transition-all shadow-sm border shrink-0 ${
                  showOnlyPurchased 
                    ? 'bg-amber-500 text-white border-amber-600 shadow-amber-100' 
                    : 'bg-white text-slate-600 border-slate-200 hover:border-emerald-500 hover:text-emerald-600'
                }`}
                title={showOnlyPurchased ? 'Showing Purchased' : 'My Tests'}
              >
                <ShoppingBag size={18} />
                <span className="inline">{showOnlyPurchased ? 'Purchased' : 'My Tests'}</span>
              </button>

              <div className="relative group flex-1">
                <div className="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
                  <div className={`w-9 h-9 rounded-lg flex items-center justify-center transition-all ${isSearchingCategories ? 'bg-emerald-50' : 'bg-slate-50 group-focus-within:bg-emerald-50'}`}>
                    <Search size={18} className={`transition-colors ${isSearchingCategories ? 'text-emerald-500 animate-pulse' : 'text-slate-400 group-focus-within:text-emerald-500'}`} />
                  </div>
                </div>
                <input
                  type="text"
                  value={categorySearch}
                  onChange={(e) => setCategorySearch(e.target.value)}
                  placeholder="Search Exam (e.g. SSC, BPSC...)"
                  className="block w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-xl text-sm font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all shadow-sm"
                />
                {isSearchingCategories && (
                  <div className="absolute inset-y-0 right-0 pr-3.5 flex items-center">
                    <div className="w-4 h-4 border-2 border-emerald-500/30 border-t-emerald-500 rounded-full animate-spin"></div>
                  </div>
                )}
              </div>
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredExamCategories.map(cat => {
                const catCount = counts[cat.name] || { mock: 0, sectional: 0 };
                const mockCount = catCount.mock;
                const secCount = catCount.sectional;
                const attempts = cat.usersCountOverride || ((mockCount + secCount) * 1250 + 430); 

                return (
                  <div 
                    key={cat.id} 
                    className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full" 
                    onClick={() => { setSelectedExamCategory(cat.name); setView('mode-selection'); }}
                  >
                    {/* Decorative SVG Wave (Top-Left) */}
                    <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                      <svg viewBox="0 0 100 100" className="w-full h-full">
                        <defs>
                          <linearGradient id={`catCornerGradient-${cat.id}`} x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#10b981" />
                            <stop offset="100%" stopColor="#10b981" />
                          </linearGradient>
                          <filter id={`catCardShadow-${cat.id}`} x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                            <feOffset dx="1" dy="1" result="offsetblur" />
                            <feComponentTransfer>
                              <feFuncA type="linear" slope="0.3" />
                            </feComponentTransfer>
                            <feMerge>
                              <feMergeNode />
                              <feMergeNode in="SourceGraphic" />
                            </feMerge>
                          </filter>
                        </defs>
                        <path 
                          d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" 
                          fill={`url(#catCornerGradient-${cat.id})`}
                          filter={`url(#catCardShadow-${cat.id})`}
                        />
                      </svg>
                    </div>

                    {/* Top-Right Professional Dot Grid */}
                    <div 
                      className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                      style={{
                        backgroundImage: 'radial-gradient(#10b981 1.2px, transparent 1.2px)',
                        backgroundSize: '12px 12px',
                        maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                        WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                      }}
                    ></div>
                    
                    <div className="relative z-10 p-5 flex-1 flex flex-col">
                      <div className="flex items-start gap-4 mb-5">
                        <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-emerald-600 overflow-hidden">
                          {cat.iconUrl ? (
                            <img src={cat.iconUrl} alt={cat.name} className="w-full h-full object-cover" />
                          ) : (
                            <Layers size={24} />
                          )}
                        </div>
                        <div className="flex-1">
                          <h3 className="text-xl font-black text-slate-800 leading-tight z-10 transition-colors group-hover:text-emerald-600 uppercase">
                            {cat.name} Series
                          </h3>
                          <div className="text-[10px] font-black text-slate-400 mt-1 uppercase tracking-wider flex items-center gap-1.5">
                            <span className="w-3 h-px bg-emerald-200"></span>
                            Premium Mock Tests
                          </div>
                        </div>
                      </div>
                      
                      <div className="flex flex-wrap items-center justify-center gap-3 mb-4 z-10">
                        <div className="flex items-center gap-1.5 text-[12px] font-bold text-slate-600 bg-slate-50/80 px-2 py-1 rounded-md">
                          <Target size={14} className="text-emerald-500" />
                          <span>{mockCount + secCount} Tests</span>
                        </div>
                        <div className="flex items-center gap-1.5 text-[12px] font-bold text-slate-600 bg-slate-50/80 px-2 py-1 rounded-md">
                          <Globe size={14} className="text-emerald-500" />
                          <span>Bilingual</span>
                        </div>
                        <div className="flex items-center gap-1.5 text-[12px] font-bold text-slate-600 bg-slate-50/80 px-2 py-1 rounded-md">
                          <Users size={14} className="text-emerald-500" />
                          <span>{(attempts / 1000).toFixed(1)}k Users</span>
                        </div>
                      </div>
                      
                      <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>
                      
                      <div className="space-y-3 text-[12px] text-slate-600 font-medium z-10 mb-6 flex-1 tracking-tight">
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-emerald-50 flex items-center justify-center">
                            <Target size={14} className="text-emerald-500" />
                          </div>
                          <span>{mockCount} Full Mock Tests</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-blue-50 flex items-center justify-center">
                            <BookOpen size={14} className="text-blue-500" />
                          </div>
                          <span>{secCount} Sectional Practice Tests</span>
                        </div>
                      </div>
                    
                    <button className="w-full py-3 bg-emerald-500 text-white rounded-xl font-black text-sm shadow-sm hover:bg-emerald-600 transition-colors z-10 uppercase tracking-wider active:scale-95">
                      Explore Test Series
                    </button>
                  </div>
                </div>
              );
            })}
            </div>
          </motion.div>
        )}

        {/* VIEW 2: MOCK OR SECTIONAL SELECTION */}
        {view === 'mode-selection' && selectedExamCategory && (
          <motion.div 
            key="v-mode-selection"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {(() => {
                const catCount = counts[selectedExamCategory] || { mock: 0, sectional: 0 };
                const mockCount = catCount.mock;
                const secCount = catCount.sectional;
                // We need a separate count for PYQs if we want to show it precisely, 
                // for now we'll fetch it on demand or leave it as a general count.
                const pyqCount = tests.filter(t => t.testMode === 'previous-year').length; 

              return (
                <>
                   <div onClick={() => setView('mock-tests')} className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full">
                    {/* Decorative SVG Wave (Top-Left) */}
                    <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                      <svg viewBox="0 0 100 100" className="w-full h-full">
                        <defs>
                          <linearGradient id="mockCornerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#10b981" />
                            <stop offset="100%" stopColor="#10b981" />
                          </linearGradient>
                          <filter id="mockCardShadow" x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                            <feOffset dx="1" dy="1" result="offsetblur" />
                            <feMerge>
                              <feMergeNode />
                              <feMergeNode in="SourceGraphic" />
                            </feMerge>
                          </filter>
                        </defs>
                        <path d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" fill="url(#mockCornerGradient)" filter="url(#mockCardShadow)" />
                      </svg>
                    </div>

                    <div 
                      className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                      style={{
                        backgroundImage: 'radial-gradient(#10b981 1.2px, transparent 1.2px)',
                        backgroundSize: '12px 12px',
                        maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                        WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                      }}
                    ></div>

                    <div className="relative z-10 p-6 flex-1 flex flex-col">
                      <div className="flex items-start gap-4 mb-5">
                        <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-emerald-600">
                          <FileText size={24} />
                        </div>
                        <div className="flex-1">
                          <h3 className="text-xl font-black text-slate-800 leading-tight z-10 uppercase transition-colors group-hover:text-emerald-600">Mock Tests</h3>
                          <p className="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-tight">Full Length Papers</p>
                        </div>
                      </div>
                      
                      <p className="text-[13px] font-medium text-slate-500 mb-5 z-10 leading-relaxed">Full length mock tests based on latest actual exam patterns with detailed solutions and ranking.</p>

                      <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>

                      <div className="space-y-3 mb-6 z-10 text-[12px] font-bold text-slate-600 uppercase tracking-tight">
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-emerald-50 flex items-center justify-center">
                            <CheckCircle2 size={14} className="text-emerald-500" />
                          </div>
                          <span>{mockCount} Tests Available</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-amber-50 flex items-center justify-center">
                            <Lock size={14} className="text-amber-500" />
                          </div>
                          <span>Premium & Free options</span>
                        </div>
                      </div>

                      <button className="w-full py-3 bg-emerald-500 text-white rounded-xl font-black text-sm shadow-sm hover:bg-emerald-600 transition-colors z-10 uppercase tracking-wider active:scale-95">Explore Mock Tests</button>
                    </div>
                  </div>

                  <div onClick={() => setView('sectional-subjects')} className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full">
                    {/* Decorative SVG Wave (Top-Left) */}
                    <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                      <svg viewBox="0 0 100 100" className="w-full h-full">
                        <defs>
                          <linearGradient id="secCornerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#3b82f6" />
                            <stop offset="100%" stopColor="#3b82f6" />
                          </linearGradient>
                          <filter id="secCardShadow" x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                            <feOffset dx="1" dy="1" result="offsetblur" />
                            <feMerge>
                              <feMergeNode />
                              <feMergeNode in="SourceGraphic" />
                            </feMerge>
                          </filter>
                        </defs>
                        <path d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" fill="url(#secCornerGradient)" filter="url(#secCardShadow)" />
                      </svg>
                    </div>

                    <div 
                      className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                      style={{
                        backgroundImage: 'radial-gradient(#3b82f6 1.2px, transparent 1.2px)',
                        backgroundSize: '12px 12px',
                        maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                        WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                      }}
                    ></div>

                    <div className="relative z-10 p-6 flex-1 flex flex-col">
                      <div className="flex items-start gap-4 mb-5">
                        <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-blue-600">
                          <BookOpen size={24} />
                        </div>
                        <div className="flex-1">
                          <h3 className="text-xl font-black text-slate-800 leading-tight z-10 uppercase transition-colors group-hover:text-blue-600">Sectional Tests</h3>
                          <p className="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-tight">Subject & Topic Wise</p>
                        </div>
                      </div>

                      <p className="text-[13px] font-medium text-slate-500 mb-5 z-10 leading-relaxed">Subject and Topic-wise practice tests to master specific areas and build a strong foundation.</p>

                      <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>

                      <div className="space-y-3 mb-6 z-10 text-[12px] font-bold text-slate-600 uppercase tracking-tight">
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-blue-50 flex items-center justify-center">
                            <Layers size={14} className="text-blue-500" />
                          </div>
                          <span>{secCount} Tests Available</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-amber-50 flex items-center justify-center">
                            <Lock size={14} className="text-amber-500" />
                          </div>
                          <span>Premium & Free options</span>
                        </div>
                      </div>

                      <button className="w-full py-3 bg-blue-500 text-white rounded-xl font-black text-sm shadow-sm hover:bg-blue-600 transition-colors z-10 uppercase tracking-wider active:scale-95">Explore Sectional Tests</button>
                    </div>
                  </div>

                  <div onClick={() => setView('previous-year-tests')} className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full">
                    {/* Decorative SVG Wave (Top-Left) */}
                    <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                      <svg viewBox="0 0 100 100" className="w-full h-full">
                        <defs>
                          <linearGradient id="pyqCornerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#a855f7" />
                            <stop offset="100%" stopColor="#a855f7" />
                          </linearGradient>
                          <filter id="pyqCardShadow" x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                            <feOffset dx="1" dy="1" result="offsetblur" />
                            <feMerge>
                              <feMergeNode />
                              <feMergeNode in="SourceGraphic" />
                            </feMerge>
                          </filter>
                        </defs>
                        <path d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" fill="url(#pyqCornerGradient)" filter="url(#pyqCardShadow)" />
                      </svg>
                    </div>

                    <div 
                      className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                      style={{
                        backgroundImage: 'radial-gradient(#a855f7 1.2px, transparent 1.2px)',
                        backgroundSize: '12px 12px',
                        maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                        WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                      }}
                    ></div>

                    <div className="relative z-10 p-6 flex-1 flex flex-col">
                      <div className="flex items-start gap-4 mb-5">
                        <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-purple-600">
                          <Clock size={24} />
                        </div>
                        <div className="flex-1">
                          <h3 className="text-xl font-black text-slate-800 leading-tight z-10 uppercase transition-colors group-hover:text-purple-600">Previous Year</h3>
                          <p className="text-[11px] font-bold text-slate-500 mt-1 uppercase tracking-tight">Actual Exam Papers</p>
                        </div>
                      </div>

                      <p className="text-[13px] font-medium text-slate-500 mb-5 z-10 leading-relaxed">Practice with original previous year question papers to understand the real exam difficulty and pattern.</p>

                      <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>

                      <div className="space-y-3 mb-6 z-10 text-[12px] font-bold text-slate-600 uppercase tracking-tight">
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-purple-50 flex items-center justify-center">
                            <Clock size={14} className="text-purple-500" />
                          </div>
                          <span>{pyqCount} Papers Available</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="w-6 h-6 rounded-full bg-amber-50 flex items-center justify-center">
                            <Lock size={14} className="text-amber-500" />
                          </div>
                          <span>Verified Solutions</span>
                        </div>
                      </div>

                      <button className="w-full py-3 bg-purple-600 text-white rounded-xl font-black text-sm shadow-sm hover:bg-purple-700 transition-colors z-10 uppercase tracking-wider active:scale-95">Explore PYQ Tests</button>
                    </div>
                  </div>
                </>
              );
            })()}
          </motion.div>
        )}

        {/* VIEW 3: SECTIONAL SUBJECTS */}
        {view === 'sectional-subjects' && selectedExamCategory && (
          <motion.div 
            key="v-sectional-subjects"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="space-y-6"
          >
            {/* Search Bar for Subjects - Full Width */}
            <div className="relative group w-full">
              <div className="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
                <div className="w-9 h-9 bg-slate-50 rounded-lg flex items-center justify-center group-focus-within:bg-blue-50 transition-colors">
                  <Search size={18} className="text-slate-400 group-focus-within:text-blue-500 transition-colors" />
                </div>
              </div>
              <input
                type="text"
                value={subjectSearch}
                onChange={(e) => setSubjectSearch(e.target.value)}
                placeholder="Search Subjects (e.g. Science, Maths...)"
                className="block w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-xl text-sm font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all shadow-sm"
              />
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {(() => {
              const selectedExamGroup = findExamCategoryGroupByName(examCategories, selectedExamCategory);
              const selectedExamIds = selectedExamGroup?.aliasIds || [];
              const examNames = Array.from(new Set(
                (selectedExamGroup?.rawCategories || [{ name: selectedExamCategory } as ExamCategory])
                  .map((category) => cleanExamCategoryName(category.name))
                  .filter(Boolean)
              ));

              // 1. Start with predefined subjects that match the exam
              const subjectsFromGlobal = subjectsData.filter(subject => 
                !subject.parentExamId || selectedExamIds.includes(subject.parentExamId)
              );

              // 2. Discover subjects directly from the tests
              const subjectsFromTests = Array.from(new Set(
                sectionalCatalogTests.map(t => t.subject || t.category).filter(Boolean)
              ));

              // 3. Merge both lists
              const allSubjectNames = Array.from(new Set([
                ...subjectsFromGlobal.map(s => s.name),
                ...subjectsFromTests
              ]));

              const subjectsWithTests = allSubjectNames.map(subjName => {
                const globalInfo = subjectsFromGlobal.find(s => looselyMatchesText(s.name, subjName));
                const count = sectionalCatalogTests.filter(
                  t => getTestMatches(t, examNames, 'sectional') && matchesSectionalSubject(t, subjName)
                ).length;
                
                return { 
                  id: globalInfo?.id || `dynamic-${subjName}`,
                  name: subjName,
                  count 
                };
              }).filter(s => s.count > 0);

              const searchedSubjects = subjectsWithTests.filter(s => 
                s.name.toLowerCase().includes(subjectSearch.trim().toLowerCase())
              );

              if (isLoadingSectionalCatalog) {
                return (
                  <div className="col-span-full py-20 text-center bg-white rounded-xl border border-slate-100">
                    <div className="w-12 h-12 border-2 border-blue-500/30 border-t-blue-500 rounded-full animate-spin mx-auto mb-6"></div>
                    <p className="text-slate-500 max-w-sm mx-auto">Loading subjects for {selectedExamCategory}...</p>
                  </div>
                );
              }

              if (searchedSubjects.length === 0) {
                return (
                  <div className="col-span-full py-20 text-center bg-white rounded-xl border border-slate-100">
                    <div className="w-24 h-24 bg-slate-50 rounded-xl flex items-center justify-center mx-auto mb-6 text-slate-300">
                      <BookOpen size={40} />
                    </div>
                    <h3 className="text-xl font-bold text-slate-900 mb-2">No subjects found</h3>
                    <p className="text-slate-500 max-w-sm mx-auto">No subjects matching "{subjectSearch}" for this exam.</p>
                  </div>
                );
              }

              return searchedSubjects.map(subject => {
                return (
                  <div key={subject.id} onClick={() => { setSelectedSubject(subject.name); setView('sectional-topics'); }} className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full">
                    {/* Decorative SVG Wave (Top-Left) */}
                    <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                      <svg viewBox="0 0 100 100" className="w-full h-full">
                        <defs>
                          <linearGradient id={`subjCornerGradient-${subject.id}`} x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#3b82f6" />
                            <stop offset="100%" stopColor="#3b82f6" />
                          </linearGradient>
                          <filter id={`subjCardShadow-${subject.id}`} x="-20%" y="-20%" width="140%" height="140%">
                            <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                            <feOffset dx="1" dy="1" result="offsetblur" />
                            <feComponentTransfer>
                              <feFuncA type="linear" slope="0.3" />
                            </feComponentTransfer>
                            <feMerge>
                              <feMergeNode />
                              <feMergeNode in="SourceGraphic" />
                            </feMerge>
                          </filter>
                        </defs>
                        <path 
                          d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" 
                          fill={`url(#subjCornerGradient-${subject.id})`}
                          filter={`url(#subjCardShadow-${subject.id})`}
                        />
                      </svg>
                    </div>

                    {/* Top-Right Professional Dot Grid */}
                    <div 
                      className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                      style={{
                        backgroundImage: 'radial-gradient(#3b82f6 1.2px, transparent 1.2px)',
                        backgroundSize: '12px 12px',
                        maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                        WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                      }}
                    ></div>

                    <div className="relative z-10 p-6 flex-1 flex flex-col">
                      <div className="flex items-center gap-4 mb-5">
                        <div className="w-14 h-14 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-blue-600">
                          <BookOpen size={24} />
                        </div>
                        <div className="flex-1">
                          <h3 className="text-xl font-black text-slate-800 leading-tight z-10 transition-colors group-hover:text-blue-600 uppercase">{subject.name}</h3>
                          <div className="text-[10px] font-black text-slate-400 mt-1 uppercase tracking-wider flex items-center gap-1.5">
                            <span className="w-3 h-px bg-blue-200"></span>
                            Sectional Subject
                          </div>
                        </div>
                      </div>

                      <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>

                      <div className="space-y-2.5 mb-5 z-10 text-[12px] font-bold text-slate-500 uppercase tracking-tight">
                        <div className="flex items-center gap-2">
                          <BookOpen size={16} className="text-blue-500" />
                          <span>{subject.count} Total Tests Available</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Lock size={16} className="text-amber-500" />
                          <span>Premium & Free options</span>
                        </div>
                      </div>

                      <button className="w-full py-2.5 bg-blue-500 text-white rounded-lg font-black text-xs shadow-sm hover:bg-blue-600 transition-colors z-10 flex items-center justify-center gap-2 uppercase tracking-wider active:scale-95">
                        View Topics <ChevronRight size={16} />
                      </button>
                    </div>
                  </div>
                );
              });
            })()}
            </div>
          </motion.div>
        )}

        {/* VIEW 4: SECTIONAL TOPICS */}
        {view === 'sectional-topics' && selectedSubject && (
          <motion.div 
            key="v-sectional-topics"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="space-y-6"
          >
            {/* Search Bar for Topics - Full Width */}
            <div className="relative group w-full">
              <div className="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
                <div className="w-9 h-9 bg-slate-50 rounded-lg flex items-center justify-center group-focus-within:bg-emerald-50 transition-colors">
                  <Search size={18} className="text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
                </div>
              </div>
              <input
                type="text"
                value={topicSearch}
                onChange={(e) => setTopicSearch(e.target.value)}
                placeholder="Search Topics (e.g. Percentage, History...)"
                className="block w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-xl text-sm font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all shadow-sm"
              />
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {(() => {
              const subjectInfo = subjectsData.find(s => looselyMatchesText(s.name, selectedSubject));
              const examCategoryGroup = findExamCategoryGroupByName(examCategories, selectedExamCategory!);
              const examNames = Array.from(new Set(
                (examCategoryGroup?.rawCategories || [{ name: selectedExamCategory! } as ExamCategory])
                  .map((category) => cleanExamCategoryName(category.name))
                  .filter(Boolean)
              ));

              // Discover topics directly from tests associated with this subject
              const topicsFromTests = Array.from(new Set(
                sectionalCatalogTests
                  .filter(t => matchesSectionalSubject(t, selectedSubject))
                  .map(t => t.topic)
                  .filter(Boolean)
              ));

              // Topics from global subjectsData
              const topicsFromGlobal = subjectInfo?.topics || [];

              const allTopics = Array.from(new Set([...topicsFromGlobal, ...topicsFromTests]));

              const validTopics = allTopics.filter(topic => {
                return sectionalCatalogTests.filter(
                  t => getTestMatches(t, examNames, 'sectional') &&
                    matchesSectionalSubject(t, selectedSubject) &&
                    matchesSectionalTopic(t, topic)
                ).length > 0;
              });

              const searchedTopics = validTopics.filter(t => 
                t.toLowerCase().includes(topicSearch.trim().toLowerCase())
              );

              if (isLoadingSectionalCatalog) {
                return (
                  <div className="col-span-full py-12 text-center bg-white rounded-xl border border-slate-100">
                    <div className="w-12 h-12 border-2 border-emerald-500/30 border-t-emerald-500 rounded-full animate-spin mx-auto mb-4"></div>
                    <p className="text-slate-500 font-bold">Loading topics for {selectedSubject}...</p>
                  </div>
                );
              }

              if (searchedTopics.length === 0) {
                return (
                  <div className="col-span-full py-12 text-center bg-white rounded-xl border border-slate-100">
                    <Layers size={40} className="mx-auto text-slate-200 mb-4" />
                    <p className="text-slate-500 font-bold">No topics matching "{topicSearch}" found for {selectedSubject}.</p>
                  </div>
                );
              }

                return searchedTopics.map(topic => {
                  const count = sectionalCatalogTests.filter(
                    t => matchesSectionalSubject(t, selectedSubject) && matchesSectionalTopic(t, topic)
                  ).length;
                  return (
                     <div key={topic} onClick={() => { setSelectedTopic(topic); setView('sectional-tests'); }} className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full">
                      {/* Decorative SVG Wave (Top-Left) */}
                      <div className="absolute top-0 left-0 w-24 h-24 pointer-events-none z-0 overflow-hidden">
                        <svg viewBox="0 0 100 100" className="w-full h-full">
                          <defs>
                            <linearGradient id={`topicCornerGradient-${topic.replace(/\s+/g, '-')}`} x1="0%" y1="0%" x2="100%" y2="100%">
                              <stop offset="0%" stopColor="#10b981" />
                              <stop offset="100%" stopColor="#10b981" />
                            </linearGradient>
                            <filter id={`topicCardShadow-${topic.replace(/\s+/g, '-')}`} x="-20%" y="-20%" width="140%" height="140%">
                              <feGaussianBlur in="SourceAlpha" stdDeviation="3" />
                              <feOffset dx="1" dy="1" result="offsetblur" />
                              <feComponentTransfer>
                                <feFuncA type="linear" slope="0.3" />
                              </feComponentTransfer>
                              <feMerge>
                                <feMergeNode />
                                <feMergeNode in="SourceGraphic" />
                              </feMerge>
                            </filter>
                          </defs>
                          <path 
                            d="M 0 0 L 100 0 C 80 0 0 80 0 100 Z" 
                            fill={`url(#topicCornerGradient-${topic.replace(/\s+/g, '-')})`}
                            filter={`url(#topicCardShadow-${topic.replace(/\s+/g, '-')})`}
                          />
                        </svg>
                      </div>

                      {/* Top-Right Professional Dot Grid */}
                      <div 
                        className="absolute top-0 right-0 w-32 h-32 opacity-[0.1] pointer-events-none z-0"
                        style={{
                          backgroundImage: 'radial-gradient(#10b981 1.2px, transparent 1.2px)',
                          backgroundSize: '12px 12px',
                          maskImage: 'radial-gradient(circle at top right, black, transparent 70%)',
                          WebkitMaskImage: 'radial-gradient(circle at top right, black, transparent 70%)'
                        }}
                      ></div>

                      <div className="relative z-10 p-6 flex-1 flex flex-col">
                        <div className="flex items-center gap-4 mb-5">
                          <div className="w-14 h-14 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-emerald-600">
                            <Layers size={24} />
                          </div>
                          <div className="flex-1">
                            <h3 className="text-xl font-black text-slate-800 leading-tight z-10 transition-colors group-hover:text-emerald-600 uppercase">{topic}</h3>
                            <div className="text-[10px] font-black text-slate-400 mt-1 uppercase tracking-wider flex items-center gap-1.5">
                              <span className="w-3 h-px bg-emerald-200"></span>
                              Practice Topic
                            </div>
                          </div>
                        </div>

                        <div className="w-full h-px bg-slate-100 mb-4 z-10 opacity-60"></div>

                        <div className="space-y-2.5 mb-5 z-10 text-[12px] font-bold text-slate-500 uppercase tracking-tight">
                          <div className="flex items-center gap-2">
                            <Zap size={16} className="text-emerald-500" />
                            <span>{count} Total Tests Available</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Lock size={16} className="text-amber-500" />
                            <span>Premium & Free options</span>
                          </div>
                        </div>

                        <button className="w-full py-2.5 bg-emerald-500 text-white rounded-lg font-black text-xs shadow-sm hover:bg-emerald-600 transition-colors z-10 flex items-center justify-center gap-2 uppercase tracking-wider active:scale-95">
                          Practice Now <Play size={14} fill="currentColor" strokeWidth={0}/>
                        </button>
                      </div>
                    </div>
                );
              });
            })()}
            </div>
          </motion.div>
        )}

        {/* VIEW 5: TESTS GRID */}
        {(view === 'mock-tests' || view === 'sectional-tests' || view === 'previous-year-tests') && (
          <motion.div
            key={`v-${view}`}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
          >
            <div className="flex items-center gap-2 mb-8">
              <button
                onClick={() => setShowOnlyPurchased(!showOnlyPurchased)}
                className={`flex items-center justify-center gap-2 px-3 sm:px-6 py-3 rounded-xl font-black text-[10px] sm:text-xs uppercase tracking-widest transition-all shadow-sm border shrink-0 ${
                  showOnlyPurchased 
                    ? 'bg-amber-500 text-white border-amber-600 shadow-amber-100' 
                    : 'bg-white text-slate-600 border-slate-200 hover:border-emerald-500 hover:text-emerald-600'
                }`}
                title={showOnlyPurchased ? 'Showing Purchased' : 'My Tests'}
              >
                <ShoppingBag size={18} />
                <span className="inline">{showOnlyPurchased ? 'Purchased' : 'My Tests'}</span>
              </button>

              <div className="relative group flex-1">
                <div className="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
                  <div className="w-9 h-9 bg-slate-50 rounded-lg flex items-center justify-center group-focus-within:bg-emerald-50 transition-colors">
                    <Search size={18} className="text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
                  </div>
                </div>
                <input 
                  type="text" 
                  placeholder="Search tests..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="block w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-xl text-sm font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all shadow-sm"
                />
              </div>
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {activeTests.map(test => (
                <TestCard key={test.testId} test={test} />
              ))}
            </div>

            {hasMoreAvailable && (
              <div className="mt-8 flex justify-center">
                <button
                  onClick={() => fetchTests()}
                  disabled={isLoadingTests}
                  className="px-8 py-3 bg-white border border-slate-200 rounded-xl font-bold text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-all shadow-sm flex items-center gap-2"
                >
                  {isLoadingTests ? (
                    <>
                      <div className="w-4 h-4 border-2 border-emerald-500/30 border-t-emerald-500 rounded-full animate-spin"></div>
                      Loading...
                    </>
                  ) : (
                    <>Load More Tests</>
                  )}
                </button>
              </div>
            )}

            {activeTests.length === 0 && !isLoadingTests && (
              <div className="col-span-full py-20 text-center bg-white rounded-xl border border-slate-100">
                    <div className="w-24 h-24 bg-slate-50 rounded-xl flex items-center justify-center mx-auto mb-6 text-slate-300">
                  {view === 'previous-year-tests' ? <Clock size={40} /> : view === 'mock-tests' ? <FileText size={40} /> : <Search size={40} />}
                </div>
                <h3 className="text-xl font-bold text-slate-900 mb-2">
                  {view === 'previous-year-tests' ? 'No papers found' : view === 'mock-tests' ? 'No mock tests found' : 'No tests found'}
                </h3>
                <p className="text-slate-500 max-w-sm mx-auto">
                  {search 
                    ? `No tests found matching "${search}" for this category.`
                    : view === 'previous-year-tests' 
                      ? `Official past year papers for ${selectedExamCategory} have not been published yet.` 
                      : `Tests for this category have not been added yet. Please check back later.`}
                </p>
              </div>
            )}
          </motion.div>
        )}

        {/* VIEW 6: PURCHASED TESTS ONLY */}
        {view === 'purchased-tests' && (
          <motion.div
            key="v-purchased-tests"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
          >
            <div className="flex items-center justify-between mb-8">
               <div className="flex items-center gap-3">
                  <button 
                    onClick={handleBack}
                    className="p-2.5 bg-white border border-slate-200 rounded-xl text-slate-500 hover:text-emerald-600 hover:border-emerald-200 transition-all shadow-sm"
                  >
                    <ChevronLeft size={20} />
                  </button>
                  <div>
                    <h2 className="text-xl font-black text-slate-800 uppercase tracking-tight">My Purchased Tests</h2>
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-0.5">Tests you have unlocked</p>
                  </div>
               </div>
            </div>

            <div className="flex items-center gap-2 mb-8">
               <div className="relative group flex-1">
                <div className="absolute inset-y-0 left-0 pl-1.5 flex items-center pointer-events-none">
                  <div className="w-9 h-9 bg-slate-50 rounded-lg flex items-center justify-center group-focus-within:bg-emerald-50 transition-colors">
                    <Search size={18} className="text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
                  </div>
                </div>
                <input 
                  type="text" 
                  placeholder="Search your tests..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="block w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-xl text-sm font-medium placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all shadow-sm"
                />
              </div>
            </div>

            {activeTests.length > 0 ? (
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {activeTests.map(test => (
                  <TestCard key={test.testId} test={test} />
                ))}
              </div>
            ) : (
              <div className="bg-white rounded-3xl border border-slate-100 p-12 text-center shadow-sm">
                <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-6">
                   <ShoppingBag size={40} className="text-slate-300" />
                </div>
                <h3 className="text-xl font-black text-slate-800 uppercase tracking-tight mb-2">No Tests Found</h3>
                <p className="text-sm text-slate-500 font-medium max-w-xs mx-auto leading-relaxed">
                  {search ? `No tests matching "${search}" found in your collection.` : "You haven't purchased any tests yet. Explore categories to unlock premium content."}
                </p>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {joiningContest && (
          <ContestJoinModal
            test={joiningContest}
            profile={profile}
            onClose={() => setJoiningContest(null)}
            onViewResult={(attemptId) => onNavigate(`results/${attemptId}`)}
            onJoinSuccess={() => {
              const testId = joiningContest.testId;
              setJoiningContest(null);
              onStartTest(testId);
            }}
          />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {purchasingTest && (
          <TestPurchaseModal
            test={purchasingTest}
            profile={profile}
            onClose={() => setPurchasingTest(null)}
            onPurchaseSuccess={() => onTestUnlocked(purchasingTest.testId)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
