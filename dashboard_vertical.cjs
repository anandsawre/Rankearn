const fs = require('fs');

let dsCode = fs.readFileSync('src/components/Dashboard.tsx', 'utf8');

// 1. Update Imports
const newImports = `import { 
  Zap, 
  Trophy, 
  Clock, 
  Target, 
  ArrowUpRight, 
  Play,
  Calendar,
  Star,
  BookOpen,
  FileText,
  Lock,
  Globe
} from 'lucide-react';`;

// Regex to replace lucide imports safely
dsCode = dsCode.replace(/import\s*\{\s*Zap[^}]*\}\s*from\s*'lucide-react';/, newImports);

// 2. Update Grid Grid layout
dsCode = dsCode.replace(`<div className="grid sm:grid-cols-1 xl:grid-cols-2 gap-4">`, `<div className="grid sm:grid-cols-2 gap-6">`);

// 3. Update Card JSX
const cardRegex = /<div key=\{test\.testId\} className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-all flex items-center justify-between">[\s\S]*?<\/div>\s*<\/div>\s*\)\) : \(/;

const newCard = `<div 
                key={test.testId} 
                onClick={() => onStartTest(test.testId)}
                className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden h-full"
              >
                <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-emerald-50 to-white/0 z-0 opacity-80"></div>
                
                <div className="relative z-10 p-5 flex-1 flex flex-col">
                  <div className="flex justify-between items-start mb-4">
                    <div className="w-12 h-12 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 text-emerald-600">
                      <FileText size={20} />
                    </div>
                    {test.isPremium && profile?.subscriptionStatus !== 'premium' ? (
                      <div className="bg-white px-2.5 py-1 rounded-full shadow-sm border border-slate-100 text-[10px] font-bold text-amber-600 flex items-center gap-1 z-20">
                        <Lock size={10} fill="currentColor" /> PREMIUM
                      </div>
                    ) : (
                      <div className="bg-white px-2.5 py-1 rounded-full shadow-sm border border-slate-100 text-[10px] font-bold text-slate-500 uppercase z-20">
                        {test.examType || test.category || 'Test'}
                      </div>
                    )}
                  </div>
                  
                  <h3 className="text-[17px] font-bold text-slate-800 leading-snug mb-3 z-10 transition-colors line-clamp-2 group-hover:text-emerald-600">
                    {test.title}
                  </h3>
                  
                  <div className="text-[13px] font-medium mb-3 z-10 flex items-center gap-1">
                    <span className="text-slate-800">{test.totalQuestions} Questions</span>
                    <span className="text-emerald-500">| {test.duration} mins</span>
                  </div>
                  
                  <div className="flex items-center gap-1.5 text-[13px] font-medium mb-3 z-10 text-emerald-600">
                    <Globe size={14} />
                    English, Hindi
                  </div>
                  
                  <div className="w-full h-px bg-slate-100 mb-4 z-10"></div>
                  
                  <div className="space-y-2.5 text-[13px] text-slate-600 font-medium z-10 mb-6 flex-1">
                    <div className="flex items-center gap-2">
                      <div className="w-1.5 h-1.5 rounded-full bg-slate-400"></div>
                      <span><span className="text-emerald-500"><Target size={14} className="inline mr-1" /></span> Detailed Solutions</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <div className="w-1.5 h-1.5 rounded-full bg-slate-400"></div>
                      <span><span className="text-amber-500"><Zap size={14} className="inline mr-1" fill="currentColor" /></span> State & National Rank</span>
                    </div>
                  </div>
                  
                  <button
                    disabled={test.isPremium && profile?.subscriptionStatus !== 'premium'}
                    onClick={(e) => { e.stopPropagation(); onStartTest(test.testId); }}
                    className={\`
                      w-full py-2.5 rounded-lg font-bold text-sm shadow-sm transition-colors z-10 flex items-center justify-center gap-2
                      \${test.isPremium && profile?.subscriptionStatus !== 'premium'
                        ? 'bg-slate-100 text-slate-400 border border-slate-200 cursor-not-allowed'
                        : 'bg-emerald-500 text-white hover:bg-emerald-600'}
                    \`}
                  >
                    {test.isPremium && profile?.subscriptionStatus !== 'premium' ? (
                      <>Unlock Test</>
                    ) : (
                      <>
                        Start Test
                        <Play size={14} fill="currentColor" strokeWidth={0} />
                      </>
                    )}
                  </button>
                </div>
              </div>
            )) : (`

dsCode = dsCode.replace(cardRegex, newCard);

fs.writeFileSync('src/components/Dashboard.tsx', dsCode);
console.log('Dashboard Recent Tests converted to Vertical Card styled successfully.');
