const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf8');

code = code.replace(
  'const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);',
  'const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);\n  const [headerAction, setHeaderAction] = useState<React.ReactNode>(null);'
);

code = code.replace(
  '<h1 className="text-lg font-semibold text-white capitalize truncate">\n              {getCurrentTitle()}\n            </h1>',
  '<div className="flex items-center gap-3">\n              <h1 className="text-lg font-semibold text-white capitalize truncate">\n                {getCurrentTitle()}\n              </h1>\n              {headerAction}\n            </div>'
);

code = code.replace(
  '<h1 className="text-lg font-semibold text-white capitalize truncate">\r\n              {getCurrentTitle()}\r\n            </h1>',
  '<div className="flex items-center gap-3">\r\n              <h1 className="text-lg font-semibold text-white capitalize truncate">\r\n                {getCurrentTitle()}\r\n              </h1>\r\n              {headerAction}\r\n            </div>'
);

code = code.replace(
  '<Route path="/tests" element={<TestSeries onStartTest={(id) => setActiveTest(id)} profile={profile} />} />',
  '<Route path="/tests" element={<TestSeries onStartTest={(id) => setActiveTest(id)} profile={profile} setHeaderAction={setHeaderAction} />} />'
);

fs.writeFileSync('src/App.tsx', code);
console.log('App.tsx updated successfully.');
