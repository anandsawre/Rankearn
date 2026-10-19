const fs = require('fs');
let code = fs.readFileSync('src/components/TestSeries.tsx', 'utf8');

// 1. Update ViewState type
code = code.replace(
  "type ViewState = 'exam-categories' | 'mode-selection' | 'mock-tests' | 'sectional-subjects' | 'sectional-topics' | 'sectional-tests';",
  "type ViewState = 'exam-categories' | 'mode-selection' | 'mock-tests' | 'sectional-subjects' | 'sectional-topics' | 'sectional-tests' | 'previous-year-tests';"
);

// 2. Filter dynamic exam categories
code = code.replace(
  "const dynamicExamCategories = [...examCategories];",
  "const dynamicExamCategories = examCategories.filter(c => c.isPublished !== false);"
);

// 3. Add getFilteredPreviousYearTests
code = code.replace(
  "const getFilteredSectionalTests = () => {",
  `const getFilteredPreviousYearTests = () => {
    if (!selectedExamCategory) return [];
    return tests.filter(t => 
      getTestMatches(t, selectedExamCategory, 'previous-year') &&
      t.title.toLowerCase().includes(search.toLowerCase())
    );
  };

  const getFilteredSectionalTests = () => {`
);

// 4. Update activeTests
code = code.replace(
  "const activeTests = view === 'mock-tests' ? getFilteredMockTests() : getFilteredSectionalTests();",
  "const activeTests = view === 'mock-tests' ? getFilteredMockTests() : view === 'previous-year-tests' ? getFilteredPreviousYearTests() : getFilteredSectionalTests();"
);

// 5. Update handleBack
code = code.replace(
  "case 'mock-tests':\n      case 'sectional-subjects':",
  "case 'mock-tests':\n      case 'previous-year-tests':\n      case 'sectional-subjects':"
);

// 6. TestCard identify previous year
code = code.replace(
  "const isSectional = test.testMode === 'sectional' || test.examType === 'Sectional';",
  "const isSectional = test.testMode === 'sectional' || test.examType === 'Sectional';\n    const isPYQ = test.testMode === 'previous-year';"
);

code = code.replace(
  "{isSectional ? <BookOpen size={20} /> : <FileText size={20} />}",
  "{isSectional ? <BookOpen size={20} /> : isPYQ ? <Clock size={20} /> : <FileText size={20} />}"
);

// Color adjustments for PYQ card
code = code.replace(
  "{`absolute top-0 left-0 right-0 h-32 bg-gradient-to-b ${isSectional ? 'from-blue-50' : 'from-emerald-50'} to-white/0 z-0 opacity-80`}",
  "{`absolute top-0 left-0 right-0 h-32 bg-gradient-to-b ${isSectional ? 'from-blue-50' : isPYQ ? 'from-purple-50' : 'from-emerald-50'} to-white/0 z-0 opacity-80`}"
);

code = code.replace(
  "{`w-12 h-12 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 ${isSectional ? 'text-blue-600' : 'text-emerald-600'}`}",
  "{`w-12 h-12 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10 ${isSectional ? 'text-blue-600' : isPYQ ? 'text-purple-600' : 'text-emerald-600'}`}"
);

// 7. Update attempts and languages in Exam Category map
code = code.replace(
  "const attempts = (mockCount + secCount) * 1250 + 430;",
  "const attempts = cat.usersCountOverride || ((mockCount + secCount) * 1250 + 430);"
);

code = code.replace(
  "English, Hindi",
  "{cat.languages || 'English, Hindi'}"
);

// 8. Add 3rd card to mode-selection
const pyqCard = `
            <div 
              onClick={() => setView('previous-year-tests')}
              className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden"
            >
              <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-purple-50 to-white/0 z-0 opacity-80"></div>
              
              <div className="relative z-10 p-6 flex-1 flex flex-col">
                <div className="flex items-center gap-4 mb-5">
                  <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10">
                    <Clock size={24} className="text-purple-600" />
                  </div>
                  <h3 className="text-xl font-bold text-slate-800 leading-tight z-10">
                    Previous Year
                  </h3>
                </div>
                
                <p className="text-sm font-medium text-slate-600 mb-6 z-10 line-clamp-2">
                  Official past year question papers to help you understand the exact exam pattern and difficulty.
                </p>

                <div className="w-full h-px bg-slate-100 mb-5 z-10"></div>
                
                <div className="space-y-4 text-[13px] text-slate-600 font-medium z-10 mb-6 flex-1">
                  <div className="flex items-center gap-2">
                    <Clock size={16} className="text-purple-500" />
                    <span>{tests.filter(t => getTestMatches(t, selectedExamCategory!, 'previous-year')).length} Papers Available</span>
                  </div>
                   <div className="flex items-center gap-2">
                     <Lock size={16} className="text-amber-500" /> 
                     <span>Premium & Free options</span>
                   </div>
                </div>
                
                <button className="w-full py-2.5 bg-purple-500 text-white rounded-lg font-bold text-sm shadow-sm hover:bg-purple-600 transition-colors z-10">
                  Explore Past Papers
                </button>
              </div>
            </div>
`;

code = code.replace(
  "Explore Sectional Tests\n                </button>\n              </div>\n            </div>",
  "Explore Sectional Tests\n                </button>\n              </div>\n            </div>\n" + pyqCard
);

// 9. Update VIEW 5 to include previous-year-tests
code = code.replace(
  "{(view === 'mock-tests' || view === 'sectional-tests') && (",
  "{(view === 'mock-tests' || view === 'sectional-tests' || view === 'previous-year-tests') && ("
);

code = code.replace(
  "{view === 'mock-tests' ? 'Mock Tests' : `${selectedTopic} Tests`}",
  "{view === 'mock-tests' ? 'Mock Tests' : view === 'previous-year-tests' ? `Previous Year Papers - ${selectedExamCategory}` : `${selectedTopic} Tests`}"
);

code = code.replace(
  "We couldn't find any {view === 'mock-tests' ? 'mock' : 'topic'} tests matching your criteria.",
  "We couldn't find any {view === 'mock-tests' ? 'mock' : view === 'previous-year-tests' ? 'previous year' : 'topic'} tests matching your criteria."
);


fs.writeFileSync('src/components/TestSeries.tsx', code);
console.log('TestSeries.tsx fully updated successfully.');
