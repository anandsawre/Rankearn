import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronDown, Check, Search, X } from 'lucide-react';

interface Option {
  value: string;
  label: string;
}

interface CustomSelectProps {
  value: string;
  onChange: (value: string) => void;
  options: Option[];
  placeholder?: string;
  label?: string;
  disabled?: boolean;
  className?: string;
  searchable?: boolean;
}

const CustomSelect: React.FC<CustomSelectProps> = ({
  value,
  onChange,
  options,
  placeholder = 'Select an option',
  label,
  disabled = false,
  className = '',
  searchable = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const containerRef = useRef<HTMLDivElement>(null);

  const selectedOption = options.find(opt => opt.value === value);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);

  const filteredOptions = options.filter(opt => 
    opt.label.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSelect = (val: string) => {
    onChange(val);
    setIsOpen(false);
    setSearchTerm('');
  };

  return (
    <div className={`space-y-2 relative ${className}`} ref={containerRef}>
      {label && <label className="text-sm font-bold text-slate-700">{label}</label>}
      
      <button
        type="button"
        disabled={disabled}
        onClick={() => !disabled && setIsOpen(!isOpen)}
        className={`
          w-full px-4 h-12 bg-slate-50 border border-slate-200 rounded-lg flex items-center justify-between transition-all
          ${disabled ? 'opacity-50 cursor-not-allowed' : 'hover:border-emerald-200 focus:ring-2 focus:ring-emerald-500 bg-white shadow-sm'}
          ${isOpen ? 'ring-2 ring-emerald-500 border-emerald-500' : ''}
        `}
      >
        <span className={`truncate ${selectedOption ? 'text-slate-900 font-semibold' : 'text-slate-400'}`}>
          {selectedOption ? selectedOption.label : placeholder}
        </span>
        <motion.div
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          <ChevronDown size={18} className="text-slate-400" />
        </motion.div>
      </button>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className="absolute top-full z-[100] w-full md:w-auto md:min-w-full mt-2 bg-white border border-slate-200 rounded-xl shadow-xl overflow-hidden left-0 right-0 md:right-auto"
            style={{ maxHeight: 'calc(100vh - 100px)' }}
          >
            {searchable && (
              <div className="p-3 border-b border-slate-100 bg-slate-50 relative">
                <Search className="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400" size={14} />
                <input
                  type="text"
                  autoFocus
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-4 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  placeholder="Search..."
                />
              </div>
            )}
            
            <div className="max-h-[250px] overflow-y-auto no-scrollbar p-2">
              {filteredOptions.length > 0 ? (
                filteredOptions.map((opt, idx) => (
                  <button
                    key={`${opt.value}-${idx}`}
                    type="button"
                    onClick={() => handleSelect(opt.value)}
                    className={`
                      w-full px-3 py-2.5 rounded-lg text-left text-sm flex items-center justify-between transition-colors
                      ${opt.value === value ? 'bg-emerald-50 text-emerald-600 font-bold' : 'text-slate-700 hover:bg-slate-50'}
                    `}
                  >
                    <span className="truncate">{opt.label}</span>
                    {opt.value === value && <Check size={14} />}
                  </button>
                ))
              ) : (
                <div className="px-4 py-8 text-center text-slate-400 text-sm">
                  No options found
                </div>
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default CustomSelect;
