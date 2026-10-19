import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { collection, getDocs, addDoc, deleteDoc, doc, writeBatch, updateDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { useToast } from './Toast';
import { Swords, Plus, Trash2, RefreshCw, Upload, Sparkles, X, Check, Save, Users, CheckCircle, Edit2 } from 'lucide-react';
import { BattleQuestion } from '../types';
import { Type } from '@google/genai';

interface AdminBattleQuestionsProps {
  storedCfWorkerUrl: string;
}

export default function AdminBattleQuestions({ storedCfWorkerUrl }: AdminBattleQuestionsProps) {
  const { showToast } = useToast();
  const [questions, setQuestions] = useState<BattleQuestion[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [selectedBotIds, setSelectedBotIds] = useState<Set<string>>(new Set());
  const [isDeletingBulk, setIsDeletingBulk] = useState(false);
  const [isProcessingBots, setIsProcessingBots] = useState(false);
  const [editingBot, setEditingBot] = useState<any | null>(null);
  const [deleteConfirm, setDeleteConfirm] = useState<{ show: boolean, type: 'single' | 'bulk' | 'bot' | 'bot_bulk', id?: string }>({ show: false, type: 'single' });
  
  // UI States
  const [activeTab, setActiveTab] = useState<'list' | 'add_manual' | 'add_json' | 'add_ai' | 'settings' | 'bots'>('list');
  const [isGenerating, setIsGenerating] = useState(false);
  const [isSavingConfig, setIsSavingConfig] = useState(false);
  
  // Bots State
  const [bots, setBots] = useState<any[]>([]);
  const [newBot, setNewBot] = useState({ name: '', avatar: '', isActive: true });
  
  // Battle Config States
  const [config, setConfig] = useState({
    totalQuestions: 5,
    timePerQuestion: 10,
    botAccuracy: 0.65,
    entryStakes: [10, 50, 100],
    prizeMultiplier: 1.8
  });

  // Form States
  const [aiTopic, setAiTopic] = useState('');
  const [aiDifficulty, setAiDifficulty] = useState('medium');
  const [aiCount, setAiCount] = useState(10);
  const [generationMode, setGenerationMode] = useState<'topic' | 'text'>('topic');
  const [sourceText, setSourceText] = useState('');
  const [sourceTitle, setSourceTitle] = useState('');
  const [jsonInput, setJsonInput] = useState('');
  
  // Manual Add Form
  const [newQuestion, setNewQuestion] = useState<Partial<BattleQuestion>>({
    text: '',
    textHindi: '',
    options: ['', '', '', ''],
    optionsHindi: ['', '', '', ''],
    correctAnswer: 0,
    topic: '',
    difficulty: 'medium'
  });

  useEffect(() => {
    fetchQuestions();
    fetchConfig();
    fetchBots();
  }, []);

  const fetchBots = async () => {
    try {
      const qSnapshot = await getDocs(collection(db, 'battle_bots'));
      const bList = qSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setBots(bList);
    } catch (err) {
      console.error("Failed to fetch bots", err);
    }
  };

  const handleAddBot = async () => {
    if (!newBot.name || !newBot.avatar) {
      showToast('Please fill all fields', 'error');
      return;
    }
    try {
      const docRef = await addDoc(collection(db, 'battle_bots'), {
        ...newBot,
        createdAt: new Date().toISOString()
      });
      setBots(prev => [...prev, { ...newBot, id: docRef.id }]);
      setNewBot({ name: '', avatar: '', isActive: true });
      showToast('Bot added successfully', 'success');
    } catch (err: any) {
      showToast(`Add failed: ${err.message}`, 'error');
    }
  };

  const handleUpdateBot = async () => {
    if (!editingBot || !newBot.name || !newBot.avatar) return;
    try {
      await updateDoc(doc(db, 'battle_bots', editingBot.id), {
        name: newBot.name,
        avatar: newBot.avatar,
        isActive: newBot.isActive,
        updatedAt: new Date().toISOString()
      });
      setBots(prev => prev.map(b => b.id === editingBot.id ? { ...b, name: newBot.name, avatar: newBot.avatar } : b));
      setEditingBot(null);
      setNewBot({ name: '', avatar: '', isActive: true });
      showToast('Bot updated successfully', 'success');
    } catch (err: any) {
      showToast(`Update failed: ${err.message}`, 'error');
    }
  };

  const startEditBot = (bot: any) => {
    setEditingBot(bot);
    setNewBot({ name: bot.name, avatar: bot.avatar, isActive: bot.isActive });
    // Scroll to form
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const toggleBotStatus = async (bot: any) => {
    try {
      await updateDoc(doc(db, 'battle_bots', bot.id), {
        isActive: !bot.isActive
      });
      setBots(prev => prev.map(b => b.id === bot.id ? { ...b, isActive: !b.isActive } : b));
      showToast('Bot status updated', 'success');
    } catch (err: any) {
      showToast(`Update failed: ${err.message}`, 'error');
    }
  };

  const handleDeleteBot = (id: string) => {
    setDeleteConfirm({ show: true, type: 'bot', id });
  };

  const handleBulkBotDelete = () => {
    if (selectedBotIds.size === 0) return;
    setDeleteConfirm({ show: true, type: 'bot_bulk' });
  };

  const handleBulkBotStatus = async (status: boolean) => {
    if (selectedBotIds.size === 0) return;
    setIsProcessingBots(true);
    try {
      const batch = writeBatch(db);
      selectedBotIds.forEach(id => {
        batch.update(doc(db, 'battle_bots', id), { isActive: status });
      });
      await batch.commit();
      
      setBots(prev => prev.map(b => selectedBotIds.has(b.id) ? { ...b, isActive: status } : b));
      showToast(`Successfully ${status ? 'enabled' : 'disabled'} ${selectedBotIds.size} bots`, 'success');
      setSelectedBotIds(new Set());
    } catch (err: any) {
      showToast(`Bulk update failed: ${err.message}`, 'error');
    } finally {
      setIsProcessingBots(false);
    }
  };

  const toggleSelectAllBots = () => {
    if (selectedBotIds.size === bots.length) {
      setSelectedBotIds(new Set());
    } else {
      setSelectedBotIds(new Set(bots.map(b => b.id)));
    }
  };

  const toggleSelectBot = (id: string) => {
    setSelectedBotIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const fetchConfig = async () => {
    try {
      const { doc, getDoc } = await import('firebase/firestore');
      const docSnap = await getDoc(doc(db, 'configs', 'battle_settings'));
      if (docSnap.exists()) {
        setConfig(docSnap.data() as any);
      }
    } catch (err) {
      console.error("Failed to fetch battle config", err);
    }
  };

  const handleSaveConfig = async () => {
    setIsSavingConfig(true);
    try {
      const { doc, setDoc } = await import('firebase/firestore');
      await setDoc(doc(db, 'configs', 'battle_settings'), {
        ...config,
        updatedAt: new Date().toISOString()
      });
      showToast('Settings updated successfully', 'success');
    } catch (err: any) {
      showToast(`Update failed: ${err.message}`, 'error');
    } finally {
      setIsSavingConfig(false);
    }
  };

  const fetchQuestions = async () => {
    setLoading(true);
    try {
      const qSnapshot = await getDocs(collection(db, 'battle_questions'));
      const qList = qSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as BattleQuestion[];
      setQuestions(qList.sort((a, b) => a.text.localeCompare(b.text)));
    } catch (err: any) {
      showToast(`Failed to fetch questions: ${err.message}`, 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = (id: string) => {
    setDeleteConfirm({ show: true, type: 'single', id });
  };

  const handleBulkDelete = () => {
    if (selectedIds.size === 0) return;
    setDeleteConfirm({ show: true, type: 'bulk' });
  };

  const executeDelete = async () => {
    const { type, id } = deleteConfirm;
    setDeleteConfirm({ show: false, type: 'single' });

    if (type === 'single' && id) {
      try {
        await deleteDoc(doc(db, 'battle_questions', id));
        setQuestions(prev => prev.filter(q => q.id !== id));
        setSelectedIds(prev => {
          const next = new Set(prev);
          next.delete(id);
          return next;
        });
        showToast('Question deleted successfully', 'success');
      } catch (err: any) {
        showToast(`Delete failed: ${err.message}`, 'error');
      }
    } else if (type === 'bulk') {
      setIsDeletingBulk(true);
      try {
        const batch = writeBatch(db);
        selectedIds.forEach(id => {
          batch.delete(doc(db, 'battle_questions', id));
        });
        await batch.commit();

        setQuestions(prev => prev.filter(q => !selectedIds.has(q.id)));
        showToast(`Successfully deleted ${selectedIds.size} questions`, 'success');
        setSelectedIds(new Set());
      } catch (err: any) {
        showToast(`Bulk delete failed: ${err.message}`, 'error');
      } finally {
        setIsDeletingBulk(false);
      }
    } else if (type === 'bot' && id) {
      try {
        await deleteDoc(doc(db, 'battle_bots', id));
        setBots(prev => prev.filter(b => b.id !== id));
        setSelectedBotIds(prev => {
          const next = new Set(prev);
          next.delete(id);
          return next;
        });
        showToast('Bot deleted successfully', 'success');
      } catch (err: any) {
        showToast(`Delete failed: ${err.message}`, 'error');
      }
    } else if (type === 'bot_bulk') {
      setIsProcessingBots(true);
      try {
        const batch = writeBatch(db);
        selectedBotIds.forEach(id => {
          batch.delete(doc(db, 'battle_bots', id));
        });
        await batch.commit();

        setBots(prev => prev.filter(b => !selectedBotIds.has(b.id)));
        showToast(`Successfully deleted ${selectedBotIds.size} bots`, 'success');
        setSelectedBotIds(new Set());
      } catch (err: any) {
        showToast(`Bulk delete failed: ${err.message}`, 'error');
      } finally {
        setIsProcessingBots(false);
      }
    }
  };

  const toggleSelectAll = () => {
    if (selectedIds.size === questions.length) {
      setSelectedIds(new Set());
    } else {
      setSelectedIds(new Set(questions.map(q => q.id)));
    }
  };

  const toggleSelect = (id: string) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const handleManualAdd = async () => {
    if (!newQuestion.text || newQuestion.options?.some(o => !o.trim())) {
      showToast('Please fill all fields', 'error');
      return;
    }
    try {
      const docRef = await addDoc(collection(db, 'battle_questions'), {
        ...newQuestion,
        createdAt: new Date().toISOString()
      });
      setQuestions(prev => [{ ...newQuestion, id: docRef.id } as BattleQuestion, ...prev]);
      setActiveTab('list');
      setNewQuestion({ text: '', textHindi: '', options: ['', '', '', ''], optionsHindi: ['', '', '', ''], correctAnswer: 0, topic: '', difficulty: 'medium' });
      showToast('Question added successfully', 'success');
    } catch (err: any) {
      showToast(`Add failed: ${err.message}`, 'error');
    }
  };

  const handleJsonUpload = async () => {
    try {
      const parsed = JSON.parse(jsonInput);
      if (!Array.isArray(parsed)) throw new Error('Input must be a JSON array');
      
      let added = 0;
      const batch = writeBatch(db);
      
      parsed.forEach((q: any) => {
        if (q.text && q.options?.length === 4 && typeof q.correctAnswer === 'number') {
          const newDocRef = doc(collection(db, 'battle_questions'));
          batch.set(newDocRef, {
            text: q.text,
            textHindi: q.textHindi || '',
            options: q.options,
            optionsHindi: q.optionsHindi || [],
            correctAnswer: q.correctAnswer,
            topic: q.topic || 'General',
            difficulty: q.difficulty || 'medium',
            createdAt: new Date().toISOString()
          });
          added++;
        }
      });

      if (added > 0) {
        await batch.commit();
        showToast(`Successfully added ${added} questions`, 'success');
        setJsonInput('');
        fetchQuestions();
        setActiveTab('list');
      } else {
        showToast('No valid questions found in JSON', 'warning');
      }
    } catch (err: any) {
      showToast(`Invalid JSON: ${err.message}`, 'error');
    }
  };

  const handleAiGenerate = async () => {
    if (generationMode === 'topic' && !aiTopic.trim()) {
      showToast('Please enter a topic', 'error');
      return;
    }
    if (generationMode === 'text' && !sourceText.trim()) {
      showToast('Please enter source text content', 'error');
      return;
    }
    
    if (!storedCfWorkerUrl) {
      showToast('Cloudflare Worker URL is not configured in settings', 'error');
      return;
    }

    setIsGenerating(true);
    try {
      const promptText = generationMode === 'topic' 
        ? `Generate ${aiCount} multiple-choice questions for a rapid-fire 1v1 trivia battle game.
Topic: ${aiTopic}
Difficulty: ${aiDifficulty}

Output strictly as a JSON array matching this exact schema:
[{
  "text": "Question text in English?",
  "textHindi": "Question text in Hindi?",
  "options": ["Option 1 EN", "Option 2 EN", "Option 3 EN", "Option 4 EN"],
  "optionsHindi": ["Option 1 HI", "Option 2 HI", "Option 3 HI", "Option 4 HI"],
  "correctAnswer": 0,
  "topic": "${aiTopic}",
  "difficulty": "${aiDifficulty}"
}]`
        : `Generate ${aiCount} multiple-choice questions based on the following text for a rapid-fire 1v1 trivia battle game.
Text: ${sourceText}
Difficulty: ${aiDifficulty}

Output strictly as a JSON array matching this exact schema:
[{
  "text": "Question text in English?",
  "textHindi": "Question text in Hindi?",
  "options": ["Option 1 EN", "Option 2 EN", "Option 3 EN", "Option 4 EN"],
  "optionsHindi": ["Option 1 HI", "Option 2 HI", "Option 3 HI", "Option 4 HI"],
  "correctAnswer": 0,
  "topic": "${sourceTitle || 'Text Based'}",
  "difficulty": "${aiDifficulty}"
}]`;

      const requestBody = {
        model: "gemini-2.5-flash",
        contents: [{ role: "user", parts: [{ text: promptText }] }],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                text: { type: Type.STRING },
                textHindi: { type: Type.STRING },
                options: { type: Type.ARRAY, items: { type: Type.STRING } },
                optionsHindi: { type: Type.ARRAY, items: { type: Type.STRING } },
                correctAnswer: { type: Type.INTEGER },
                topic: { type: Type.STRING },
                difficulty: { type: Type.STRING }
              },
              required: ["text", "textHindi", "options", "optionsHindi", "correctAnswer", "topic", "difficulty"]
            }
          }
        }
      };

      const aiResponse = await fetch(storedCfWorkerUrl.trim(), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody)
      });

      if (!aiResponse.ok) throw new Error('Failed to connect to AI Service');

      const geminiResponse = await aiResponse.json();
      
      let cleanText = '[]';
      if (geminiResponse.candidates && geminiResponse.candidates.length > 0) {
        cleanText = geminiResponse.candidates[0].content.parts[0].text;
      } else {
         throw new Error(geminiResponse.error?.message || 'Unknown AI Error');
      }

      cleanText = cleanText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const generatedQs = JSON.parse(cleanText);

      // Auto-save generated questions to Firestore via Batch
      const batch = writeBatch(db);
      generatedQs.forEach((q: any) => {
        const newDocRef = doc(collection(db, 'battle_questions'));
        batch.set(newDocRef, { ...q, createdAt: new Date().toISOString() });
      });
      await batch.commit();

      showToast(`Successfully generated and added ${generatedQs.length} questions!`, 'success');
      setAiTopic('');
      setSourceTitle('');
      setSourceText('');
      fetchQuestions();
      setActiveTab('list');

    } catch (err: any) {
      showToast(`AI Generation failed: ${err.message}`, 'error');
    } finally {
      setIsGenerating(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white p-6 rounded-xl shadow-sm border border-slate-100">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-rose-50 rounded-xl flex items-center justify-center">
            <Swords size={24} className="text-rose-500" />
          </div>
          <div>
            <h2 className="text-2xl font-black text-slate-900">Manage Battle</h2>
            <p className="text-slate-500 font-medium">Manage the question pool and settings for 1v1 Battles</p>
          </div>
        </div>
        <div className="flex bg-slate-100 p-1 rounded-xl overflow-x-auto no-scrollbar scroll-smooth">
          <button onClick={() => setActiveTab('list')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all whitespace-nowrap ${activeTab === 'list' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}>List</button>
          <button onClick={() => setActiveTab('add_ai')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === 'add_ai' ? 'bg-indigo-500 text-white shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}><Sparkles size={16}/> AI Gen</button>
          <button onClick={() => setActiveTab('add_manual')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all whitespace-nowrap ${activeTab === 'add_manual' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}>Manual</button>
          <button onClick={() => setActiveTab('add_json')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all whitespace-nowrap ${activeTab === 'add_json' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}>JSON</button>
          <button onClick={() => setActiveTab('bots')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === 'bots' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}><Users size={16}/> Manage Bots</button>
          <button onClick={() => setActiveTab('settings')} className={`px-4 py-2 rounded-lg font-bold text-sm transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === 'settings' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}><RefreshCw size={16}/> Settings</button>
        </div>
      </div>

      <AnimatePresence mode="wait">
        {activeTab === 'list' && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50">
              <div className="flex items-center gap-4">
                <h3 className="font-bold text-slate-900 flex items-center gap-2">
                  Total Pool: <span className="bg-rose-100 text-rose-600 px-3 py-1 rounded-full text-sm">{questions.length}</span>
                </h3>
                {selectedIds.size > 0 && (
                  <div className="flex items-center gap-3 animate-in fade-in slide-in-from-left-2">
                    <div className="h-6 w-px bg-slate-200" />
                    <span className="text-sm font-black text-indigo-600 uppercase tracking-wider">{selectedIds.size} Selected</span>
                    <button 
                      onClick={handleBulkDelete}
                      disabled={isDeletingBulk}
                      className="flex items-center gap-2 px-3 py-1.5 bg-rose-500 hover:bg-rose-600 text-white text-xs font-black rounded-lg shadow-sm transition-all disabled:opacity-50"
                    >
                      {isDeletingBulk ? <RefreshCw size={12} className="animate-spin" /> : <Trash2 size={12} />}
                      Delete Selected
                    </button>
                    <button 
                      onClick={() => setSelectedIds(new Set())}
                      className="text-xs font-bold text-slate-400 hover:text-slate-600"
                    >
                      Clear
                    </button>
                  </div>
                )}
              </div>
              <button onClick={fetchQuestions} className="p-2 bg-white rounded-xl text-slate-400 hover:text-slate-600 shadow-sm border border-slate-200 w-max">
                <RefreshCw size={18} className={loading ? "animate-spin" : ""} />
              </button>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-white border-b border-slate-100">
                    <th className="p-4 w-10">
                      <input 
                        type="checkbox" 
                        checked={questions.length > 0 && selectedIds.size === questions.length} 
                        onChange={toggleSelectAll}
                        className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                      />
                    </th>
                    <th className="p-4 font-bold text-slate-400 text-xs uppercase tracking-wider">Question</th>
                    <th className="p-4 font-bold text-slate-400 text-xs uppercase tracking-wider">Topic/Diff</th>
                    <th className="p-4 font-bold text-slate-400 text-xs uppercase tracking-wider text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50">
                  {loading && questions.length === 0 ? (
                    <tr><td colSpan={4} className="p-8 text-center text-slate-400">Loading...</td></tr>
                  ) : questions.map(q => (
                    <tr key={q.id} className={`hover:bg-slate-50 transition-colors ${selectedIds.has(q.id) ? 'bg-indigo-50/30' : ''}`}>
                      <td className="p-4">
                        <input 
                          type="checkbox" 
                          checked={selectedIds.has(q.id)} 
                          onChange={() => toggleSelect(q.id)}
                          className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                        />
                      </td>
                      <td className="p-4">
                        <div className="space-y-2">
                          <div>
                            <p className="font-bold text-slate-800 text-sm">{q.text}</p>
                            <div className="mt-1 flex flex-wrap gap-1">
                              {q.options.map((opt, i) => (
                                <span key={i} className={`px-2 py-0.5 rounded text-[10px] ${i === q.correctAnswer ? 'bg-emerald-100 text-emerald-700 font-bold border border-emerald-200' : 'bg-slate-100 text-slate-600'}`}>{opt}</span>
                              ))}
                            </div>
                          </div>
                          {q.textHindi && (
                            <div className="pt-2 border-t border-slate-50">
                              <p className="font-bold text-indigo-800 text-sm">{q.textHindi}</p>
                              <div className="mt-1 flex flex-wrap gap-1">
                                {q.optionsHindi?.map((opt, i) => (
                                  <span key={i} className={`px-2 py-0.5 rounded text-[10px] ${i === q.correctAnswer ? 'bg-emerald-100 text-emerald-700 font-bold border border-emerald-200' : 'bg-indigo-50 text-indigo-600'}`}>{opt}</span>
                                ))}
                              </div>
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="p-4">
                        <span className="block text-xs font-bold text-indigo-600 bg-indigo-50 px-2 py-1 rounded-md mb-1 w-max">{q.topic || 'General'}</span>
                        <span className="block text-xs font-bold text-amber-600 bg-amber-50 px-2 py-1 rounded-md w-max">{q.difficulty || 'medium'}</span>
                      </td>
                      <td className="p-4 text-right">
                        <button onClick={() => handleDelete(q.id)} className="p-2 text-rose-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors">
                          <Trash2 size={18} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </motion.div>
        )}

        {activeTab === 'add_ai' && (
           <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="bg-white rounded-xl p-8 shadow-sm border border-slate-100 relative overflow-hidden">
             <div className="max-w-2xl mx-auto">
               <div className="flex items-center gap-4 mb-8">
                 <div className="w-16 h-16 bg-indigo-50 rounded-xl flex items-center justify-center shrink-0">
                   <Sparkles size={32} className="text-indigo-500" />
                 </div>
                 <div>
                   <h3 className="text-2xl font-black text-slate-900 leading-tight">AI Question Generator</h3>
                   <p className="text-slate-500 text-sm font-medium">Generate high-quality rapid-fire questions instantly using Gemini AI.</p>
                 </div>
               </div>

               <div className="space-y-6">
                 <div className="flex bg-slate-100 p-1 rounded-xl mb-6">
                   <button 
                     onClick={() => setGenerationMode('topic')} 
                     className={`flex-1 py-2 rounded-lg font-bold text-sm transition-all ${generationMode === 'topic' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500'}`}
                   >
                     Generate by Topic
                   </button>
                   <button 
                     onClick={() => setGenerationMode('text')} 
                     className={`flex-1 py-2 rounded-lg font-bold text-sm transition-all ${generationMode === 'text' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500'}`}
                   >
                     Generate from Text
                   </button>
                 </div>

                 {generationMode === 'topic' ? (
                   <div>
                     <label className="block text-sm font-bold text-slate-700 mb-2">Topic / Subject</label>
                     <input 
                       type="text" 
                       value={aiTopic} 
                       onChange={e => setAiTopic(e.target.value)} 
                       placeholder="e.g. Indian History, Science, Bollywood 90s..." 
                       className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-medium focus:border-indigo-500 focus:bg-white outline-none" 
                     />
                   </div>
                 ) : (
                   <div className="space-y-4">
                     <div>
                       <label className="block text-sm font-bold text-slate-700 mb-2">Title / Topic Name</label>
                       <input 
                         type="text" 
                         value={sourceTitle} 
                         onChange={e => setSourceTitle(e.target.value)} 
                         placeholder="e.g. Budget 2024 Highlights, Solar System..." 
                         className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-medium focus:border-indigo-500 focus:bg-white outline-none" 
                       />
                     </div>
                     <div>
                       <label className="block text-sm font-bold text-slate-700 mb-2">Source Text / Content</label>
                       <textarea 
                         value={sourceText} 
                         onChange={e => setSourceText(e.target.value)} 
                         placeholder="Paste the article or text content here to generate questions from it..." 
                         className="w-full h-40 bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-medium focus:border-indigo-500 focus:bg-white outline-none resize-none" 
                       />
                     </div>
                   </div>
                 )}

                 <div className="grid grid-cols-2 gap-4">
                   <div>
                     <label className="block text-sm font-bold text-slate-700 mb-2">Number of Questions</label>
                     <input 
                       type="number" 
                       min="1" 
                       max="50" 
                       value={aiCount} 
                       onChange={e => setAiCount(Math.max(1, parseInt(e.target.value) || 1))} 
                       className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-medium focus:border-indigo-500 focus:bg-white outline-none" 
                     />
                   </div>
                   <div>
                     <label className="block text-sm font-bold text-slate-700 mb-2">Difficulty</label>
                     <select value={aiDifficulty} onChange={e => setAiDifficulty(e.target.value)} className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 font-medium focus:border-indigo-500 focus:bg-white outline-none">
                       <option value="easy">Easy (High Success Rate)</option>
                       <option value="medium">Medium (Balanced)</option>
                       <option value="hard">Hard (Low Success Rate)</option>
                     </select>
                   </div>
                 </div>
                 
                 <button 
                   onClick={handleAiGenerate} 
                   disabled={isGenerating || (generationMode === 'topic' ? !aiTopic.trim() : !sourceText.trim())} 
                   className="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-indigo-500/30 transition-all"
                 >
                   {isGenerating ? <RefreshCw size={20} className="animate-spin" /> : <Sparkles size={20} />}
                   {isGenerating ? 'Generating & Saving...' : `Generate ${aiCount} Questions`}
                 </button>
               </div>
             </div>
          </motion.div>
        )}

        {activeTab === 'add_manual' && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="bg-white rounded-xl p-8 shadow-sm border border-slate-100">
             <div className="max-w-2xl mx-auto space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">Question Text (English)</label>
                    <input type="text" value={newQuestion.text} onChange={e => setNewQuestion({...newQuestion, text: e.target.value})} className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-indigo-500" />
                  </div>
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">सवल (Hindi)</label>
                    <input type="text" value={newQuestion.textHindi} onChange={e => setNewQuestion({...newQuestion, textHindi: e.target.value})} className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-orange-500" />
                  </div>
                </div>
                
                <div className="space-y-4">
                  <label className="block text-sm font-bold text-slate-700">Options</label>
                  {[0, 1, 2, 3].map(idx => (
                    <div key={idx} className="p-4 bg-slate-50 rounded-xl border border-slate-100">
                      <div className="flex items-center gap-4 mb-3">
                        <input type="radio" checked={newQuestion.correctAnswer === idx} onChange={() => setNewQuestion({...newQuestion, correctAnswer: idx})} className="w-5 h-5 text-emerald-500" />
                        <span className="font-bold text-slate-700">Option {idx + 1} {newQuestion.correctAnswer === idx && <span className="text-emerald-500 text-xs ml-2">(Correct Answer)</span>}</span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <input type="text" placeholder="English version" value={newQuestion.options?.[idx]} onChange={e => {
                          const newOpts = [...(newQuestion.options || [])];
                          newOpts[idx] = e.target.value;
                          setNewQuestion({...newQuestion, options: newOpts});
                        }} className="w-full bg-white border-2 border-slate-200 rounded-xl px-4 py-2 outline-none focus:border-indigo-500" />
                        <input type="text" placeholder="Hindi version" value={newQuestion.optionsHindi?.[idx]} onChange={e => {
                          const newOpts = [...(newQuestion.optionsHindi || [])];
                          newOpts[idx] = e.target.value;
                          setNewQuestion({...newQuestion, optionsHindi: newOpts});
                        }} className="w-full bg-white border-2 border-slate-200 rounded-xl px-4 py-2 outline-none focus:border-orange-500" />
                      </div>
                    </div>
                  ))}
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">Topic (Optional)</label>
                    <input type="text" value={newQuestion.topic} onChange={e => setNewQuestion({...newQuestion, topic: e.target.value})} placeholder="e.g. Geography" className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none" />
                  </div>
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">Difficulty</label>
                    <select value={newQuestion.difficulty} onChange={e => setNewQuestion({...newQuestion, difficulty: e.target.value})} className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none">
                      <option value="easy">Easy</option>
                      <option value="medium">Medium</option>
                      <option value="hard">Hard</option>
                    </select>
                  </div>
                </div>

                <button onClick={handleManualAdd} className="w-full bg-slate-900 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-800 transition-colors mt-8">
                  <Plus size={20} /> Add Question
                </button>
             </div>
          </motion.div>
        )}

        {activeTab === 'add_json' && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="bg-white rounded-xl p-8 shadow-sm border border-slate-100">
             <div className="max-w-4xl mx-auto space-y-6">
               <div className="flex items-center gap-3 mb-6">
                 <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center">
                   <Upload size={24} className="text-blue-500" />
                 </div>
                 <div>
                    <h3 className="text-2xl font-black text-slate-900">Bulk JSON Upload</h3>
                    <p className="text-slate-500">Paste an array of objects to import instantly.</p>
                 </div>
               </div>

               <div className="bg-slate-800 rounded-xl p-4 text-emerald-400 font-mono text-sm overflow-x-auto">
                 <p className="text-slate-400 mb-2">// Required JSON Format:</p>
                 <pre>
{`[
  {
    "text": "What is 2+2?",
    "options": ["3", "4", "5", "6"],
    "correctAnswer": 1,
    "topic": "Math",
    "difficulty": "easy"
  }
]`}
                 </pre>
               </div>

               <textarea 
                 value={jsonInput} 
                 onChange={e => setJsonInput(e.target.value)} 
                 placeholder="Paste JSON array here..." 
                 className="w-full h-64 bg-slate-50 border-2 border-slate-100 rounded-xl p-4 font-mono text-sm outline-none focus:border-blue-500 focus:bg-white"
               />

               <button onClick={handleJsonUpload} disabled={!jsonInput.trim()} className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-blue-500/30 transition-all">
                 <Save size={20} /> Import JSON
               </button>
             </div>
          </motion.div>
        )}
        {activeTab === 'settings' && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="bg-white rounded-xl p-8 shadow-sm border border-slate-100">
             <div className="max-w-2xl mx-auto space-y-8">
                <div className="flex items-center gap-4 mb-4">
                   <div className="w-12 h-12 bg-slate-900 text-white rounded-xl flex items-center justify-center">
                      <RefreshCw size={24} />
                   </div>
                   <div>
                      <h3 className="text-xl font-black text-slate-900">Battle Configuration</h3>
                      <p className="text-slate-500 font-medium">Set global rules for 1v1 Battles</p>
                   </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                   <div className="space-y-2">
                      <label className="block text-sm font-bold text-slate-700">Questions per Match</label>
                      <input 
                        type="number" 
                        value={config.totalQuestions} 
                        onChange={e => setConfig({...config, totalQuestions: parseInt(e.target.value) || 5})}
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-slate-900 font-bold"
                      />
                      <p className="text-xs text-slate-400">Default: 5 questions</p>
                   </div>

                   <div className="space-y-2">
                      <label className="block text-sm font-bold text-slate-700">Timer per Question (Seconds)</label>
                      <input 
                        type="number" 
                        value={config.timePerQuestion} 
                        onChange={e => setConfig({...config, timePerQuestion: parseInt(e.target.value) || 10})}
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-slate-900 font-bold"
                      />
                      <p className="text-xs text-slate-400">Default: 10 seconds</p>
                   </div>

                   <div className="space-y-2">
                      <label className="block text-sm font-bold text-slate-700">Bot Accuracy (0.1 to 1.0)</label>
                      <input 
                        type="number" 
                        step="0.1"
                        min="0.1"
                        max="1"
                        value={config.botAccuracy} 
                        onChange={e => setConfig({...config, botAccuracy: parseFloat(e.target.value) || 0.6})}
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-slate-900 font-bold"
                      />
                      <p className="text-xs text-slate-400">0.65 = 65% correct rate. Higher = Harder bot.</p>
                   </div>

                   <div className="space-y-2">
                      <label className="block text-sm font-bold text-slate-700">Stake Options (Comma Separated)</label>
                      <input 
                        type="text" 
                        value={config.entryStakes?.join(', ') || '10, 50, 100'} 
                        onChange={e => {
                          const val = e.target.value;
                          const stakes = val.split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n));
                          setConfig({...config, entryStakes: stakes});
                        }}
                        placeholder="10, 50, 100"
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-slate-900 font-bold"
                      />
                      <p className="text-xs text-slate-400">Available coin stakes (e.g. 10, 20, 50)</p>
                   </div>

                   <div className="space-y-2">
                      <label className="block text-sm font-bold text-slate-700">Platform Fee (%)</label>
                      <input 
                        type="number" 
                        value={Math.round((2 - (config.prizeMultiplier || 1.8)) / 2 * 100)} 
                        onChange={e => {
                          const fee = parseFloat(e.target.value) || 0;
                          setConfig({...config, prizeMultiplier: 2 * (1 - (fee / 100))});
                        }}
                        className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-slate-900 font-bold"
                      />
                      <p className="text-xs text-slate-400">Example: 10% fee means Admin keeps 10% of total pool. Winner gets 1.8x.</p>
                   </div>
                </div>

                <button 
                  onClick={handleSaveConfig} 
                  disabled={isSavingConfig}
                  className="w-full bg-slate-900 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 hover:bg-slate-800 transition-all disabled:opacity-50"
                >
                  {isSavingConfig ? <RefreshCw size={20} className="animate-spin" /> : <Check size={20} />}
                  {isSavingConfig ? 'Saving...' : 'Save Configuration'}
                </button>
             </div>
          </motion.div>
        )}
        {activeTab === 'bots' && (
          <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }} className="space-y-6">
             <div className="bg-white rounded-xl p-8 shadow-sm border border-slate-100">
                <h3 className="text-xl font-black text-slate-900 mb-6 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Users className="text-indigo-500" /> {editingBot ? 'Edit Bot' : 'Add New Bot'}
                  </div>
                  {editingBot && (
                    <button 
                      onClick={() => {
                        setEditingBot(null);
                        setNewBot({ name: '', avatar: '', isActive: true });
                      }}
                      className="text-xs font-bold text-slate-400 hover:text-rose-500 flex items-center gap-1"
                    >
                      <X size={14} /> Cancel Edit
                    </button>
                  )}
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">Bot Name</label>
                    <input 
                      type="text" 
                      value={newBot.name} 
                      onChange={e => setNewBot({...newBot, name: e.target.value})}
                      placeholder="e.g. Master_Mind"
                      className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-indigo-500 font-medium"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-2">Avatar URL</label>
                    <input 
                      type="text" 
                      value={newBot.avatar} 
                      onChange={e => setNewBot({...newBot, avatar: e.target.value})}
                      placeholder="https://i.pravatar.cc/150?u=bot"
                      className="w-full bg-slate-50 border-2 border-slate-100 rounded-xl px-4 py-3 outline-none focus:border-indigo-500 font-medium"
                    />
                  </div>
                </div>
                <button 
                  onClick={editingBot ? handleUpdateBot : handleAddBot}
                  className={`mt-6 w-full ${editingBot ? 'bg-indigo-600' : 'bg-slate-900'} text-white font-black py-4 rounded-xl flex items-center justify-center gap-2 hover:opacity-90 transition-all shadow-lg ${editingBot ? 'shadow-indigo-100' : 'shadow-slate-100'}`}
                >
                  {editingBot ? <Save size={20} /> : <Plus size={20} />}
                  {editingBot ? 'Update Bot Profile' : 'Add Bot to System'}
                </button>
             </div>

             <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
                <div className="p-6 border-b border-slate-100 bg-slate-50 flex flex-col md:flex-row md:items-center justify-between gap-4">
                   <div className="flex items-center gap-4">
                     <h3 className="font-bold text-slate-900">Existing Bots Pool ({bots.length})</h3>
                     {selectedBotIds.size > 0 && (
                       <div className="flex items-center gap-2 animate-in fade-in slide-in-from-left-2">
                         <div className="h-6 w-px bg-slate-200" />
                         <span className="text-sm font-black text-indigo-600 uppercase tracking-wider">{selectedBotIds.size} Selected</span>
                         <button 
                           onClick={() => handleBulkBotStatus(true)}
                           disabled={isProcessingBots}
                           className="px-3 py-1.5 bg-emerald-500 text-white text-[10px] font-black rounded-lg shadow-sm hover:bg-emerald-600 transition-all flex items-center gap-1.5 uppercase"
                         >
                           {isProcessingBots ? <RefreshCw size={12} className="animate-spin" /> : <CheckCircle size={12} />}
                           Enable
                         </button>
                         <button 
                           onClick={() => handleBulkBotStatus(false)}
                           disabled={isProcessingBots}
                           className="px-3 py-1.5 bg-slate-400 text-white text-[10px] font-black rounded-lg shadow-sm hover:bg-slate-500 transition-all flex items-center gap-1.5 uppercase"
                         >
                           {isProcessingBots ? <RefreshCw size={12} className="animate-spin" /> : <X size={12} />}
                           Disable
                         </button>
                         <button 
                           onClick={handleBulkBotDelete}
                           disabled={isProcessingBots}
                           className="px-3 py-1.5 bg-rose-500 text-white text-[10px] font-black rounded-lg shadow-sm hover:bg-rose-600 transition-all flex items-center gap-1.5 uppercase"
                         >
                           <Trash2 size={12} />
                           Delete
                         </button>
                         <button onClick={() => setSelectedBotIds(new Set())} className="text-xs font-bold text-slate-400 hover:text-slate-600">Clear</button>
                       </div>
                     )}
                   </div>
                </div>
                <div className="overflow-x-auto">
                   <table className="w-full text-left border-collapse">
                      <thead>
                        <tr className="bg-white border-b border-slate-100">
                          <th className="p-4 w-10">
                            <input 
                              type="checkbox" 
                              checked={bots.length > 0 && selectedBotIds.size === bots.length} 
                              onChange={toggleSelectAllBots}
                              className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                            />
                          </th>
                          <th className="p-4 font-bold text-slate-400 text-xs uppercase">Bot</th>
                          <th className="p-4 font-bold text-slate-400 text-xs uppercase">Status</th>
                          <th className="p-4 font-bold text-slate-400 text-xs uppercase text-right">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-50">
                        {bots.length === 0 ? (
                          <tr><td colSpan={4} className="p-8 text-center text-slate-400 font-medium">No bots found in system.</td></tr>
                        ) : bots.map(bot => (
                          <tr key={bot.id} className={`hover:bg-slate-50 transition-colors ${selectedBotIds.has(bot.id) ? 'bg-indigo-50/30' : ''}`}>
                            <td className="p-4">
                              <input 
                                type="checkbox" 
                                checked={selectedBotIds.has(bot.id)} 
                                onChange={() => toggleSelectBot(bot.id)}
                                className="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500"
                              />
                            </td>
                            <td className="p-4">
                              <div className="flex items-center gap-3">
                                <img src={bot.avatar} alt="" className="w-10 h-10 rounded-full border-2 border-white shadow-sm" />
                                <span className="font-bold text-slate-700">{bot.name}</span>
                              </div>
                            </td>
                            <td className="p-4">
                               <button 
                                 onClick={() => toggleBotStatus(bot)}
                                 className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${bot.isActive ? 'bg-emerald-100 text-emerald-600' : 'bg-slate-100 text-slate-400'}`}
                               >
                                 {bot.isActive ? 'Active' : 'Inactive'}
                               </button>
                            </td>
                            <td className="p-4 text-right">
                               <div className="flex items-center justify-end gap-2">
                                 <button 
                                   onClick={() => startEditBot(bot)}
                                   className="p-2 text-indigo-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
                                   title="Edit Bot"
                                 >
                                   <Edit2 size={18} />
                                 </button>
                                 <button 
                                   onClick={() => handleDeleteBot(bot.id)}
                                   className="p-2 text-rose-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                                   title="Delete Bot"
                                 >
                                   <Trash2 size={18} />
                                 </button>
                               </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                   </table>
                </div>
             </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Delete Confirmation Modal */}
      <AnimatePresence>
        {deleteConfirm.show && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setDeleteConfirm({ show: false, type: 'single' })}
              className="absolute inset-0 bg-slate-950/60 backdrop-blur-sm"
            />
            <motion.div
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="relative w-full max-w-sm bg-white rounded-2xl p-8 shadow-2xl text-center overflow-hidden"
            >
              <div className="absolute -top-10 -right-10 w-32 h-32 bg-rose-50 rounded-full blur-3xl opacity-50" />
              
              <div className="relative z-10">
                <div className="w-20 h-20 bg-rose-50 text-rose-500 rounded-xl flex items-center justify-center mx-auto mb-6">
                  <Trash2 size={40} className="animate-pulse" />
                </div>
                
                <h3 className="text-2xl font-black text-slate-900 mb-2 uppercase tracking-tight">Confirm Delete</h3>
                <p className="text-[10px] font-black text-rose-500 uppercase tracking-widest mb-6">Action cannot be undone</p>
                
                <div className="bg-slate-50 rounded-xl p-4 mb-8 border border-slate-100">
                  <p className="text-slate-500 font-bold text-xs leading-relaxed">
                    Are you sure you want to delete {deleteConfirm.type.includes('bulk') ? <span className="text-rose-500 font-black">{deleteConfirm.type === 'bot_bulk' ? selectedBotIds.size : selectedIds.size} {deleteConfirm.type === 'bot_bulk' ? 'bots' : 'questions'}</span> : (deleteConfirm.type === 'bot' ? 'this bot' : 'this question')} from the pool?
                  </p>
                </div>

                <div className="flex flex-col gap-3">
                  <button
                    onClick={executeDelete}
                    className="w-full py-4 bg-rose-500 text-white font-black rounded-xl shadow-lg shadow-rose-100 hover:bg-rose-600 transition-all active:scale-95 uppercase tracking-widest text-xs"
                  >
                    Yes, Delete Now
                  </button>
                  <button
                    onClick={() => setDeleteConfirm({ show: false, type: 'single' })}
                    className="w-full py-3 text-slate-400 font-bold text-[10px] uppercase tracking-widest hover:text-slate-600 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
