const fs = require('fs');

const tsPath = 'src/components/TestSeries.tsx';
let code = fs.readFileSync(tsPath, 'utf8');

// Update TestCard component inside TestSeries.tsx
const oldTestCardRegex = /const TestCard = \(\{ test \}: \{ test: Test \} \) => \{[\s\S]*?return \([\s\S]*?<motion\.div[\s\S]*?<\/motion\.div>\s*\);\s*\};/g;

// Since there's only one TestCard inside, we can try to replace the whole thing.
// But the content is complex. Let's try a more specific replacement for the internal JSX.

const newTestCardContent = `  const TestCard = ({ test }: { test: Test }) => {
    const isSectional = test.testMode === 'sectional' || test.examType === 'Sectional';
    const isPYQ = test.testMode === 'previous-year';
    const testExamCat = test.examCategory || test.category || test.examType || 'General';
    
    return (
      <motion.div 
        initial={{ opacity: 0, y: 15 }}
        animate={{ opacity: 1, y: 0 }}
        whileHover={{ y: -4 }}
        className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between relative overflow-hidden h-full"
      >
        <div className={\`absolute top-0 left-0 right-0 h-32 bg-gradient-to-b \${isSectional ? 'from-blue-50' : isPYQ ? 'from-purple-50' : 'from-emerald-50'} to-white/0 z-0 opacity-80\`}></div>
        
        <div className="relative z-10 p-5 flex-1 flex flex-col">
          <div className="flex items-center gap-3 mb-4">
            <div className={\`w-11 h-11 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center shrink-0 relative z-10 \${isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}\`}>
              {isSectional ? <BookOpen size={20} /> : isPYQ ? <Clock size={20} /> : <FileText size={20} />}
            </div>
            <h3 className={\`text-[16px] font-bold text-slate-800 leading-tight z-10 transition-colors line-clamp-2 \${isSectional ? 'group-hover:text-blue-600' : 'group-hover:text-emerald-600'}\`}>
              {test.title}
            </h3>
          </div>
          
          <div className="flex flex-wrap items-center gap-3 mb-3 z-10">
            <div className="bg-slate-50 px-2 py-0.5 rounded border border-slate-200 text-[11px] font-bold text-slate-500 flex items-center gap-1 uppercase">
              <Layers size={12} className="text-slate-400" />
              {testExamCat}
            </div>
            <div className="flex items-center gap-1 text-[12px] font-medium text-slate-600">
              <Target size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
              <span>{test.totalQuestions} Qs</span>
            </div>
            <div className="flex items-center gap-1 text-[12px] font-medium text-slate-600">
              <Clock size={14} className={isSectional ? 'text-blue-500' : 'text-emerald-500'} />
              <span>{test.duration} mins</span>
            </div>
            {test.isPremium && profile?.subscriptionStatus !== 'premium' && (
              <div className="ml-auto bg-amber-50 px-2 py-0.5 rounded border border-amber-200 text-[10px] font-bold text-amber-600 flex items-center gap-1">
                <Lock size={10} fill="currentColor" /> PREMIUM
              </div>
            )}
          </div>
          
          <div className={\`flex items-center gap-1.5 text-[12px] font-medium mb-3 z-10 \${isSectional ? 'text-blue-600' : 'text-emerald-600'}\`}>
            <Globe size={14} />
            {dynamicExamCategories.find(c => c.name.toLowerCase() === testExamCat.toLowerCase())?.languages || 'English, Hindi'}
          </div>
          
          <div className="w-full h-px bg-slate-100 mb-4 z-10"></div>
          
          <div className="space-y-2.5 text-[12px] text-slate-600 font-medium z-10 mb-6 flex-1">
            <div className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-slate-300"></div>
              <span>Detailed Solutions & Analytics</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-slate-300"></div>
              <span>State & National Leaderboard</span>
            </div>
          </div>
          
          <button
            disabled={test.isPremium && profile?.subscriptionStatus !== 'premium'}
            onClick={() => onStartTest(test.testId)}
            className={\`
              w-full py-2.5 rounded-lg font-bold text-sm shadow-sm transition-colors z-10 flex items-center justify-center gap-2
              \${test.isPremium && profile?.subscriptionStatus !== 'premium'
                ? 'bg-slate-100 text-slate-400 border border-slate-200 cursor-not-allowed'
                : isSectional ? 'bg-blue-500 text-white hover:bg-blue-600' : 'bg-emerald-500 text-white hover:bg-emerald-600'}
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
      </motion.div>
    );
  };`;

// Regex attempt: find the start of TestCard and the end of its function body.
// It's defined as a const at indentation level 2 (inside the default function).
const searchString = "  const TestCard = ({ test }: { test: Test }) => {";
// We'll find from this line to the end of the motion.div return block.
const startIndex = code.indexOf(searchString);
if (startIndex !== -1) {
    // Find the matching closing bracket for the component function.
    // In the current file at line 207:
    // 206:     );
    // 207:   };
    const endString = "    );\n  };";
    const endIndex = code.indexOf(endString, startIndex);
    if (endIndex !== -1) {
        const fullOldCard = code.substring(startIndex, endIndex + endString.length);
        code = code.replace(fullOldCard, newTestCardContent);
        fs.writeFileSync(tsPath, code);
        console.log('TestSeries Updated.');
    } else {
        console.log('Could not find end of TestCard');
    }
} else {
    console.log('Could not find Start of TestCard');
}
