import React from 'react';
import LegalLayout from './LegalLayout';

export default function AboutUs() {
  return (
    <LegalLayout 
      title="About Us" 
      subtitle="Rankearn is India's pioneer 'Learning with Incentives' educational platform, transforming test preparation into an engaging, rewarded, and highly-motivated experience."
      seoTitle="About Us - Rankearn Education"
      seoDescription="Learn about Rankearn Education Private Limited, our mission, vision, corporate disclosures, and how we merge academic excellence with skill-based performance rewards."
      lastUpdated="May 24, 2026"
    >
      <section>
        <h2 className="text-2xl font-bold text-slate-900 mb-4">Our Corporate Identity</h2>
        <p className="text-slate-600 mb-4 leading-relaxed">
          <strong>Rankearn</strong> is owned, managed, and operated by <strong>Rankearn Education Private Limited</strong>, a legally incorporated entity registered under the Companies Act, 2013 in India. We operate at the intersection of technology, education, and gamification to solve one of the biggest challenges in online learning: student engagement and sustained motivation.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-slate-900 mb-4">Our Vision & Mission</h2>
        <p className="text-slate-600 mb-4 leading-relaxed">
          Traditional test preparation is often stressful, isolating, and lacks immediate positive reinforcement. At Rankearn, our mission is to motivate aspirants by recognizing and rewarding their hard work, knowledge, and test-taking accuracy. 
        </p>
        <p className="text-slate-600 mb-4 leading-relaxed">
          We believe that when preparation is incentivized, learning becomes more efficient. Through our structured daily contests, subject-wise quizzes, and full-length test series, students are encouraged to prepare thoroughly, perform under real-time exam conditions, and earn virtual coins that recognize their academic superiority.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-slate-900 mb-4">The "Learning with Earning" Concept</h2>
        <p className="text-slate-600 mb-4 leading-relaxed">
          Our platform operates strictly as a <strong>Game of Skill</strong>. Every contest, poll, and battle on Rankearn is carefully curated by academic experts to evaluate real intellectual capabilities, time management, analytical abilities, and knowledge recall. Winnings are solely determined by how well a user answers academic questions compared to peers, creating a transparent, meritocratic ecosystem.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-slate-900 mb-4">Statutory Corporate Information</h2>
        <p className="text-slate-600 mb-6 leading-relaxed">
          In compliance with Section 4 of the Information Technology Act, 2000, and the Consumer Protection (E-Commerce) Rules, 2020, our official statutory and communication details are disclosed below:
        </p>
        
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
          <div className="bg-slate-50 px-8 py-4 border-b border-slate-200">
            <h3 className="text-sm font-bold uppercase tracking-wider text-slate-400 m-0!">Company Disclosures</h3>
          </div>
          
          <div className="p-8 md:p-10 space-y-10">
            <div className="grid md:grid-cols-2 gap-10">
              <div className="space-y-2">
                <p className="text-[10px] font-black uppercase tracking-wider text-emerald-600">Registered Name</p>
                <p className="text-xl font-extrabold text-slate-900 leading-tight">
                  Rankearn Education<br />Private Limited
                </p>
              </div>
              
              <div className="space-y-2">
                <p className="text-[10px] font-black uppercase tracking-wider text-emerald-600">Registered Jurisdiction</p>
                <div className="flex items-center gap-2 text-slate-900 font-bold text-lg">
                  <span className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse" />
                  Bihar, India
                </div>
              </div>
            </div>

            <div className="h-px bg-slate-100 w-full" />

            <div className="grid md:grid-cols-2 gap-10">
              <div className="space-y-3">
                <p className="text-[10px] font-black uppercase tracking-wider text-emerald-600">Corporate & Registered Office</p>
                <p className="text-slate-600 font-semibold leading-relaxed text-[15px]">
                  East Champaran, Bihar<br />
                  PIN Code: 845401
                </p>
              </div>

              <div className="space-y-3">
                <p className="text-[10px] font-black uppercase tracking-wider text-emerald-600">Official Helpdesk & Grievance Email</p>
                <a 
                  href="mailto:rankearnhelp@gmail.com" 
                  className="text-slate-900 font-bold text-lg hover:text-emerald-600 transition-colors block"
                >
                  rankearnhelp@gmail.com
                </a>
                <p className="text-slate-400 text-xs font-medium italic">
                  Turnaround time: 24 to 48 business hours
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-slate-900 mb-4">Our Core Operating Values</h2>
        <ul className="list-disc pl-6 text-slate-600 space-y-4 mb-4">
          <li><strong>Academic Authenticity:</strong> Our content creators and educators design high-standard tests covering UPSC, SSC, Banking, State Exams, and general knowledge, fully aligned with official exam syllabi.</li>
          <li><strong>Level Playing Field:</strong> We enforce strict anti-cheat monitoring, zero-tolerance towards multi-accounting, and secure algorithm testing to prevent cheating or collusive behavior.</li>
          <li><strong>Financial Transparency:</strong> Secure deposit/withdrawal systems backed by standard payment gateways, clear TDS rules under Section 194BA of the IT Act, and zero hidden charges.</li>
          <li><strong>Student Support:</strong> Dedicated customer care via WhatsApp and email, with prompt resolutions to any transaction or contest-related queries.</li>
        </ul>
      </section>
    </LegalLayout>
  );
}
