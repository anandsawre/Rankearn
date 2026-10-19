const fs = require('fs');
let code = fs.readFileSync('src/components/TestSeries.tsx', 'utf8');

// 1. Replace Subject Card
const oldSubjectCard = `                <div 
                  key={subject.id} 
                  onClick={() => { setSelectedSubject(subject.name); setView('sectional-topics'); }}
                  className="bg-white p-6 md:p-8 rounded-3xl border border-slate-100/80 shadow-[0_4px_20px_-10px_rgba(0,0,0,0.05)] hover:shadow-[0_8px_30px_-12px_rgba(59,130,246,0.2)] transition-all duration-300 cursor-pointer group flex items-center justify-between relative overflow-hidden hover:-translate-y-1"
                >
                  <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-blue-500 scale-y-0 group-hover:scale-y-100 transition-transform duration-300 origin-bottom rounded-r-md"></div>
                  <div className="flex items-center gap-5">
                    <div className="w-14 h-14 bg-blue-50/80 text-blue-600 rounded-2xl flex items-center justify-center group-hover:bg-blue-500 group-hover:text-white transition-colors duration-300 shadow-sm">
                      <BookOpen size={26} strokeWidth={2} />
                    </div>
                    <div>
                      <h4 className="font-bold text-slate-800 text-xl tracking-tight mb-1 group-hover:text-blue-700 transition-colors">{subject.name}</h4>
                      <p className="text-xs font-black text-slate-400 uppercase tracking-widest">{count} Tests Available</p>
                    </div>
                  </div>
                  <div className="w-10 h-10 rounded-full flex items-center justify-center text-slate-300 group-hover:text-blue-600 group-hover:bg-blue-50 transition-colors">
                    <ChevronRight size={24} strokeWidth={3} className="group-hover:translate-x-1 transition-transform" />
                  </div>
                </div>`;

const newSubjectCard = `                <div 
                  key={subject.id} 
                  onClick={() => { setSelectedSubject(subject.name); setView('sectional-topics'); }}
                  className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden"
                >
                  <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-blue-50 to-white/0 z-0 opacity-80"></div>
                  
                  <div className="relative z-10 p-6 flex-1 flex flex-col">
                    <div className="flex items-center gap-4 mb-5">
                      <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10">
                        <BookOpen size={24} className="text-blue-600" />
                      </div>
                      <h3 className="text-xl font-bold text-slate-800 leading-tight z-10 line-clamp-2">
                        {subject.name}
                      </h3>
                    </div>
                    
                    <p className="text-sm font-medium text-slate-600 mb-6 z-10 line-clamp-2">
                      Master this subject by practicing deeply focused, topic-wise tests.
                    </p>

                    <div className="w-full h-px bg-slate-100 mb-5 z-10"></div>
                    
                    <div className="space-y-4 text-[13px] text-slate-600 font-medium z-10 mb-6 flex-1">
                      <div className="flex items-center gap-2">
                        <Layers size={16} className="text-blue-500" />
                        <span>{count} Total Tests Available</span>
                      </div>
                    </div>
                    
                    <button className="w-full py-2.5 bg-blue-500 text-white rounded-lg font-bold text-sm shadow-sm hover:bg-blue-600 transition-colors z-10 flex items-center justify-center gap-2">
                      View Topics <ChevronRight size={16} />
                    </button>
                  </div>
                </div>`;

// 2. Replace Topic Card
const oldTopicCard = `                  <div 
                    key={topic} 
                    onClick={() => { setSelectedTopic(topic); setView('sectional-tests'); }}
                    className="bg-white p-6 md:p-8 rounded-3xl border border-slate-100/80 shadow-[0_4px_20px_-10px_rgba(0,0,0,0.05)] hover:shadow-[0_8px_30px_-12px_rgba(16,185,129,0.2)] transition-all duration-300 cursor-pointer group flex justify-between items-center relative overflow-hidden hover:-translate-y-1"
                  >
                    <div className="absolute left-0 top-0 bottom-0 w-1.5 bg-emerald-400 scale-y-0 group-hover:scale-y-100 transition-transform duration-300 origin-bottom rounded-r-md"></div>
                    <div className="flex-1 pr-4">
                      <h4 className="font-bold text-slate-800 text-lg tracking-tight group-hover:text-emerald-700 transition-colors leading-snug mb-3">
                        {topic}
                      </h4>
                      <div className="flex items-center gap-2 text-[11px] font-black text-emerald-600 bg-emerald-50/80 w-fit px-3 py-1.5 rounded-lg border border-emerald-100/50 uppercase tracking-widest">
                        {count} Tests <Play size={10} fill="currentColor" />
                      </div>
                    </div>
                    <div className="w-12 h-12 rounded-2xl bg-slate-50 flex items-center justify-center text-slate-400 group-hover:bg-gradient-to-br group-hover:from-emerald-400 group-hover:to-emerald-500 group-hover:text-white transition-all duration-300 shadow-sm group-hover:shadow-lg group-hover:shadow-emerald-200">
                      <ChevronRight size={22} strokeWidth={3} className="group-hover:translate-x-0.5 transition-transform" />
                    </div>
                  </div>`;

const newTopicCard = `                  <div 
                    key={topic} 
                    onClick={() => { setSelectedTopic(topic); setView('sectional-tests'); }}
                    className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all duration-300 group flex flex-col justify-between cursor-pointer relative overflow-hidden"
                  >
                    <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-emerald-50 to-white/0 z-0 opacity-80"></div>
                    
                    <div className="relative z-10 p-6 flex-1 flex flex-col">
                      <div className="flex items-center gap-4 mb-5">
                        <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative z-10">
                          <Layers size={24} className="text-emerald-600" />
                        </div>
                        <h3 className="text-xl font-bold text-slate-800 leading-tight z-10 line-clamp-2">
                          {topic}
                        </h3>
                      </div>
                      
                      <p className="text-sm font-medium text-slate-600 mb-6 z-10 line-clamp-2">
                        Targeted questions focused specifically on {topic}.
                      </p>

                      <div className="w-full h-px bg-slate-100 mb-5 z-10"></div>
                      
                      <div className="space-y-4 text-[13px] text-slate-600 font-medium z-10 mb-6 flex-1">
                        <div className="flex items-center gap-2">
                          <Target size={16} className="text-emerald-500" />
                          <span>{count} Tests Available</span>
                        </div>
                      </div>
                      
                      <button className="w-full py-2.5 bg-emerald-500 text-white rounded-lg font-bold text-sm shadow-sm hover:bg-emerald-600 transition-colors z-10 flex items-center justify-center gap-2">
                        Practice Now <Play size={14} fill="currentColor" strokeWidth={0}/>
                      </button>
                    </div>
                  </div>`;

code = code.replace(oldSubjectCard, newSubjectCard);
code = code.replace(oldTopicCard, newTopicCard);

fs.writeFileSync('src/components/TestSeries.tsx', code);
console.log('Cards converted to Vertical Sectional style.');
