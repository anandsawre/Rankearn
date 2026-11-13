import React from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, ShieldCheck, Calendar } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { Helmet } from 'react-helmet-async';

interface LegalLayoutProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
  seoTitle: string;
  seoDescription: string;
  lastUpdated?: string;
}

export default function LegalLayout({ 
  title, 
  subtitle, 
  children, 
  seoTitle, 
  seoDescription,
  lastUpdated = "May 14, 2026"
}: LegalLayoutProps) {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-slate-50 font-sans selection:bg-emerald-500/20 selection:text-emerald-900">
      <Helmet>
        <title>{`${seoTitle} | Rankearn Legal`}</title>
        <meta name="description" content={seoDescription} />
      </Helmet>

      {/* Simplified Navbar */}
      <nav className="sticky top-0 inset-x-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200 py-4 shadow-sm">
        <div className="max-w-4xl mx-auto px-6 flex items-center gap-4">
          <button 
            onClick={() => navigate(-1)}
            className="w-10 h-10 rounded-full border border-slate-200 flex items-center justify-center text-slate-400 hover:text-emerald-600 hover:border-emerald-200 hover:bg-emerald-50 transition-all"
            title="Go Back"
          >
            <ArrowLeft size={20} />
          </button>

          <div className="flex items-center gap-2 cursor-pointer" onClick={() => navigate('/')}>
            <div className="w-8 h-8 bg-emerald-600 rounded-lg flex items-center justify-center shadow-emerald-200 shadow-lg">
              <ShieldCheck size={20} className="text-white" />
            </div>
            <span className="font-extrabold text-xl tracking-tight text-slate-900">Rankearn</span>
          </div>
        </div>
      </nav>

      {/* Header */}
      <header className="bg-white border-b border-slate-200 py-12 md:py-20 overflow-hidden relative">
        <div className="absolute inset-0 z-0 overflow-hidden opacity-30">
          <div className="absolute top-[-10%] right-[-5%] w-[400px] h-[400px] bg-emerald-50 rounded-full blur-[100px]" />
          <div className="absolute bottom-[-10%] left-[-10%] w-[300px] h-[300px] bg-blue-50 rounded-full blur-[100px]" />
        </div>

        <div className="max-w-4xl mx-auto px-6 relative z-10">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="flex flex-wrap items-center gap-4 mb-6"
          >
            <span className="flex items-center gap-2 text-emerald-600 font-bold uppercase tracking-widest text-[10px] md:text-xs bg-emerald-50 px-3 py-1 rounded-full border border-emerald-100">
              <ShieldCheck size={14} />
              Official Legal Documentation
            </span>
            <span className="flex items-center gap-2 text-slate-500 font-bold uppercase tracking-widest text-[10px] md:text-xs bg-slate-50 px-3 py-1 rounded-full border border-slate-100">
              <Calendar size={14} />
              Updated: {lastUpdated}
            </span>
          </motion.div>
          
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-4xl md:text-5xl lg:text-6xl font-black text-slate-900 leading-[1.1] mb-6 tracking-tight"
          >
            {title}
          </motion.h1>
          
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="text-lg md:text-xl text-slate-500 font-medium max-w-2xl leading-relaxed"
          >
            {subtitle}
          </motion.p>
        </div>
      </header>

      {/* Content */}
      <main className="max-w-4xl mx-auto px-6 py-12 md:py-20">
        <motion.div 
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="bg-white p-8 md:p-16 rounded-3xl border border-slate-200 shadow-sm space-y-12"
        >
          {/* Custom Typography styling without @tailwindcss/typography */}
          <div className="
            [&>section]:mb-16
            [&>section:last-child]:mb-0
            [&_h2]:text-2xl [&_h2]:md:text-3xl [&_h2]:font-black [&_h2]:text-slate-900 [&_h2]:tracking-tight [&_h2]:mb-8 [&_h2]:pb-4 [&_h2]:border-b [&_h2]:border-slate-100
            [&_h3]:text-xl [&_h3]:font-bold [&_h3]:text-slate-800 [&_h3]:tracking-tight [&_h3]:mb-4 [&_h3]:mt-10
            [&_p]:text-slate-600 [&_p]:leading-[1.8] [&_p]:font-medium [&_p]:mb-6 [&_p]:text-[17px]
            [&_ul]:list-disc [&_ul]:pl-6 [&_ul]:mb-8 [&_ul]:space-y-4
            [&_li]:text-slate-600 [&_li]:font-medium [&_li]:leading-relaxed [&_li]:text-[16px]
            [&_strong]:text-slate-900 [&_strong]:font-bold
            [&_a]:text-emerald-600 [&_a]:font-bold [&_a]:underline hover:[&_a]:text-emerald-700
            [&_.legal-note]:bg-slate-50 [&_.legal-note]:p-6 [&_.legal-note]:rounded-2xl [&_.legal-note]:border [&_.legal-note]:border-slate-100 [&_.legal-note]:italic [&_.legal-note]:text-slate-500 [&_.legal-note]:text-sm
          ">
            {children}
          </div>
        </motion.div>
      </main>

      {/* Simple Footer */}
      <footer className="bg-slate-50 border-t border-slate-200 py-16">
        <div className="max-w-4xl mx-auto px-6">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-6 h-6 bg-emerald-600 rounded flex items-center justify-center">
                  <ShieldCheck size={14} className="text-white" />
                </div>
                <span className="font-black text-lg tracking-tight text-slate-900">Rankearn Legal</span>
              </div>
              <p className="text-slate-500 text-sm font-medium leading-relaxed">
                Rankearn Education is committed to absolute transparency and legal compliance. 
                Our documents are reviewed periodically to stay aligned with Indian Law.
              </p>
            </div>
            <div className="text-left md:text-right">
              <p className="text-slate-400 text-xs font-bold uppercase tracking-widest mb-2">Copyright</p>
              <p className="text-slate-600 text-sm font-bold">
                © {new Date().getFullYear()} Rankearn Education Private Limited.
              </p>
              <p className="text-slate-400 text-xs font-medium mt-1">
                All rights reserved. Unauthorized reproduction is strictly prohibited.
              </p>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
