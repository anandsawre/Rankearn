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

// 6. Update TestCard to identify previous year
// Wait, isSectional is used for colors. Let's make previous-year look like mock for now, or use a distinct color.
// Actually, let's just make it look like a mock test.
code = code.replace(
  "const isSectional = test.testMode === 'sectional' || test.examType === 'Sectional';",
  "const isSectional = test.testMode === 'sectional' || test.examType === 'Sectional';\n    const isPYQ = test.testMode === 'previous-year';"
);

code = code.replace(
  "{isSectional ? <BookOpen size={20} /> : <FileText size={20} />}",
  "{isSectional ? <BookOpen size={20} /> : isPYQ ? <Clock size={20} /> : <FileText size={20} />}"
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
                    <Target size={16} className="text-purple-500" />
                    <span>{tests.filter(t => getTestMatches(t, selectedExamCategory, 'previous-year')).length} Total Papers Available</span>
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

// 9. Add Previous Year Tests List View (like mock-tests view)
const mockTestsViewStart = "{/* VIEW 3: MOCK TESTS LIST */}\n        {view === 'mock-tests' && selectedExamCategory && (";
const pyqTestsView = `
        {/* VIEW: PREVIOUS YEAR TESTS LIST */}
        {view === 'previous-year-tests' && selectedExamCategory && (
          <motion.div 
            key="v-pyq-tests"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="space-y-6"
          >
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
              <div>
                <h3 className="text-2xl font-bold text-slate-900 mb-2">Previous Year Papers - {selectedExamCategory}</h3>
                <p className="text-slate-500 font-medium">Attempt official past papers to gauge real exam difficulty.</p>
              </div>
              <div className="relative w-full md:w-72">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                <input 
                  type="text"
                  placeholder="Search papers..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 shadow-sm"
                />
              </div>
            </div>

            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {activeTests.map(test => (
                <TestCard key={test.testId} test={test} />
              ))}
            </div>
            
            {activeTests.length === 0 && (
              <div className="text-center py-20 bg-white rounded-3xl border border-slate-100">
                <Clock size={48} className="mx-auto text-slate-300 mb-4" />
                <h3 className="text-xl font-bold text-slate-800 mb-2">No Past Papers Found</h3>
                <p className="text-slate-500">We are adding previous year papers for {selectedExamCategory}. Check back soon!</p>
              </div>
            )}
          </motion.div>
        )}
`;
code = code.replace(
  "{/* VIEW 3: MOCK TESTS LIST */}\n        {view === 'mock-tests' && selectedExamCategory && (",
  pyqTestsView + "\n        " + mockTestsViewStart
);

fs.writeFileSync('src/components/TestSeries.tsx', code);
console.log('TestSeries.tsx updated successfully.');
