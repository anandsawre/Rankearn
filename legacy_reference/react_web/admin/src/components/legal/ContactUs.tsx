import React from 'react';
import LegalLayout from './LegalLayout';
import { Mail, Phone, MapPin, MessageSquare, ShieldAlert } from 'lucide-react';

export default function ContactUs() {
  return (
    <LegalLayout
      title="Contact Us"
      subtitle="We are here to assist you. Please use the appropriate channel for a faster response."
      seoTitle="Contact Us"
      seoDescription="Get in touch with Rankearn Education for support, business queries, or grievance redressal."
      lastUpdated="May 14, 2026"
    >
      <section>
        <div className="grid md:grid-cols-2 gap-8 not-prose">
          <div className="bg-slate-50 p-8 rounded-3xl border border-slate-200 hover:border-emerald-200 transition-colors">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center shadow-sm shrink-0">
                <Mail size={24} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 m-0!">Email Support</h3>
            </div>
            <p className="text-slate-500 text-sm mb-6 leading-relaxed">For questions about tests, coins, or your account.</p>
            <a href="mailto:rankearnhelp@gmail.com" className="text-emerald-600 font-bold hover:underline text-lg">rankearnhelp@gmail.com</a>
          </div>

          <div className="bg-slate-50 p-8 rounded-3xl border border-slate-200 hover:border-emerald-200 transition-colors">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center shadow-sm shrink-0">
                <MessageSquare size={24} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 m-0!">WhatsApp Support</h3>
            </div>
            <p className="text-slate-500 text-sm mb-6 leading-relaxed">Fastest way to get help with your queries.</p>
            <a href="https://wa.me/917766863787" target="_blank" rel="noopener noreferrer" className="text-emerald-600 font-bold hover:underline text-lg">+91 7766863787</a>
          </div>

          <div className="bg-slate-50 p-8 rounded-3xl border border-slate-200 hover:border-purple-200 transition-colors">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-12 h-12 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center shadow-sm shrink-0">
                <Phone size={24} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 m-0!">Call Support</h3>
            </div>
            <p className="text-slate-500 text-sm mb-6 leading-relaxed">Available Mon-Sat, 10 AM to 6 PM IST.</p>
            <a href="tel:+917766863787" className="text-purple-600 font-bold hover:underline text-lg">+91 7766863787</a>
          </div>

          <div className="bg-slate-50 p-8 rounded-3xl border border-slate-200 hover:border-rose-200 transition-colors">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-2xl flex items-center justify-center shadow-sm shrink-0">
                <MapPin size={24} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 m-0!">Our Office</h3>
            </div>
            <address className="text-slate-600 not-italic leading-relaxed">
              <span className="font-bold text-rose-600">Rankearn Education Pvt. Ltd.</span><br />
              Bihar, East Champaran, 845401
            </address>
          </div>
        </div>
      </section>

    </LegalLayout>
  );
}
