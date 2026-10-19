const fs = require('fs');
let code = fs.readFileSync('src/components/AdminPanel.tsx', 'utf8');

// 1. Add editingExamCategory state
code = code.replace(
  "const [newCategoryName, setNewCategoryName] = useState('');",
  "const [newCategoryName, setNewCategoryName] = useState('');\n  const [editingExamCategory, setEditingExamCategory] = useState<ExamCategory | null>(null);"
);

// 2. Add 'previous-year' to Manual Test mode options
code = code.replace(
  '<option value="sectional">Sectional Test</option>',
  '<option value="sectional">Sectional Test</option>\n                    <option value="previous-year">Previous Year Paper</option>'
);

// 3. Update the value typecast for Manual Test form Mode
code = code.replace(
  "onChange={e => setNewTest({...newTest, testMode: e.target.value as 'mock' | 'sectional'})}",
  "onChange={e => setNewTest({...newTest, testMode: e.target.value as 'mock' | 'sectional' | 'previous-year'})}"
);

// 4. Update AI Test mode to support dropdown (Wait, AI creator uses hardcoded testMode logic right now. Let's find it. Line 1111: `testMode: aiSubjectTopic ? 'sectional' : 'mock',`)
// Actually let's just add it to the form instead.
// For now, let's keep it simple: the prompt asked for "Admin side sabhi card ki details ko edit", which we are doing.
// And "sectional kr baad previous years keliye card bnao". I'll add "previous-year" choice in new test form setup:
code = code.replace(
  "testMode: test.testMode || (test.subject && test.topic ? 'sectional' : 'mock')",
  "testMode: test.testMode || (test.subject && test.topic ? 'sectional' : 'mock')"
); // Just a sanity check if we want to change edit logic, but it's fine.

// 5. Add the Edit button to ExamCategory tags
const pillSearch = `<button title="Delete Exam Category" onClick={async () => {
                       if(confirm(\`Delete exam category \${ec.name}?\`)) {`;
const pillReplace = `<button title="Edit Exam Category" onClick={() => setEditingExamCategory(ec)} className="text-slate-400 hover:text-blue-500 ml-1">
                        <Edit size={12}/>
                      </button>
                      <button title="Delete Exam Category" onClick={async () => {
                       if(confirm(\`Delete exam category \${ec.name}?\`)) {`;
code = code.replace(pillSearch, pillReplace);

// 6. Insert the Edit Modal right before the end of the return statement (or near other modals)
const modalCode = `
      {/* Edit Exam Category Modal */}
      {editingExamCategory && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-[200] p-6">
          <div className="bg-white rounded-2xl p-8 max-w-sm w-full shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-slate-900">Edit Category</h3>
              <button onClick={() => setEditingExamCategory(null)} className="p-2 hover:bg-slate-100 rounded-md transition-colors"><X size={20} /></button>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Category Name</label>
                <input type="text" value={editingExamCategory.name} onChange={e => setEditingExamCategory({...editingExamCategory, name: e.target.value})} className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>
              <div className="flex items-center gap-3">
                <input type="checkbox" id="isPublished" checked={editingExamCategory.isPublished !== false} onChange={e => setEditingExamCategory({...editingExamCategory, isPublished: e.target.checked})} className="w-5 h-5 rounded border-slate-300 text-emerald-500 focus:ring-emerald-500" />
                <label htmlFor="isPublished" className="text-sm font-bold text-slate-700">Published (Visible)</label>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Custom Users Display (Optional)</label>
                <input type="number" value={editingExamCategory.usersCountOverride || ''} onChange={e => setEditingExamCategory({...editingExamCategory, usersCountOverride: e.target.value ? parseInt(e.target.value) : undefined})} placeholder="e.g. 15000" className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Languages</label>
                <input type="text" value={editingExamCategory.languages || ''} onChange={e => setEditingExamCategory({...editingExamCategory, languages: e.target.value})} placeholder="e.g. English, Hindi" className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>
              <button onClick={async () => {
                  await updateDoc(doc(db, 'examCategories', editingExamCategory.id), {
                    name: editingExamCategory.name,
                    isPublished: editingExamCategory.isPublished !== false,
                    usersCountOverride: editingExamCategory.usersCountOverride || null,
                    languages: editingExamCategory.languages || null
                  });
                  setExamCategories(examCategories.map(c => c.id === editingExamCategory.id ? {
                    ...editingExamCategory,
                    usersCountOverride: editingExamCategory.usersCountOverride || undefined,
                    languages: editingExamCategory.languages || undefined
                  } : c));
                  setEditingExamCategory(null);
              }} className="w-full bg-emerald-500 text-white py-3 rounded-lg font-bold hover:bg-emerald-600 transition-all shadow-md mt-4">Save Changes</button>
            </div>
          </div>
        </div>
      )}
`;

code = code.replace('{/* Add Test Modal */}', modalCode + '\n      {/* Add Test Modal */}');

fs.writeFileSync('src/components/AdminPanel.tsx', code);
console.log('AdminPanel.tsx updated successfully.');
