import React, { useState, useRef, useEffect } from 'react';
import { 
  format, 
  addMonths, 
  subMonths, 
  startOfMonth, 
  endOfMonth, 
  startOfWeek, 
  endOfWeek, 
  eachDayOfInterval, 
  isSameMonth, 
  isSameDay, 
  isToday, 
  setHours, 
  setMinutes, 
  getHours, 
  getMinutes,
  parseISO
} from 'date-fns';
import { Calendar as CalendarIcon, Clock, ChevronLeft, ChevronRight, X, Check, ChevronDown } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface CustomDateTimePickerProps {
  label: string;
  value?: string;
  onChange: (value: string | undefined) => void;
  icon?: React.ElementType;
  accentColor?: 'indigo' | 'emerald' | 'red' | 'amber';
}

export default function CustomDateTimePicker({ 
  label, 
  value, 
  onChange, 
  icon: Icon = CalendarIcon,
  accentColor = 'indigo'
}: CustomDateTimePickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [viewDate, setViewDate] = useState(value ? parseISO(value) : new Date());

  const colors = {
    indigo: { bg: 'bg-indigo-600', text: 'text-indigo-600', light: 'bg-indigo-50', border: 'border-indigo-100', shadow: 'shadow-indigo-100', ring: 'ring-indigo-600/20' },
    emerald: { bg: 'bg-emerald-600', text: 'text-emerald-600', light: 'bg-emerald-50', border: 'border-emerald-100', shadow: 'shadow-emerald-100', ring: 'ring-emerald-600/20' },
    red: { bg: 'bg-red-600', text: 'text-red-600', light: 'bg-red-50', border: 'border-red-100', shadow: 'shadow-red-100', ring: 'ring-red-600/20' },
    amber: { bg: 'bg-amber-600', text: 'text-amber-600', light: 'bg-amber-50', border: 'border-amber-100', shadow: 'shadow-amber-100', ring: 'ring-amber-600/20' },
  };

  const activeColor = colors[accentColor];

  const [showHourPicker, setShowHourPicker] = useState(false);
  const [showMinutePicker, setShowMinutePicker] = useState(false);
  const hourPickerRef = useRef<HTMLDivElement>(null);
  const minutePickerRef = useRef<HTMLDivElement>(null);

  // Close pickers on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (hourPickerRef.current && !hourPickerRef.current.contains(event.target as Node)) {
        setShowHourPicker(false);
      }
      if (minutePickerRef.current && !minutePickerRef.current.contains(event.target as Node)) {
        setShowMinutePicker(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Current selected values
  const selectedDate = value ? parseISO(value) : null;
  const currentHours = selectedDate ? getHours(selectedDate) : 10;
  const currentMinutes = selectedDate ? getMinutes(selectedDate) : 0;
  
  const [selectedHours, setSelectedHours] = useState(currentHours % 12 || 12);
  const [selectedMinutes, setSelectedMinutes] = useState(currentMinutes);
  const [ampm, setAmpm] = useState(currentHours >= 12 ? 'PM' : 'AM');

  useEffect(() => {
    if (selectedDate) {
      const h = getHours(selectedDate);
      setSelectedHours(h % 12 || 12);
      setSelectedMinutes(getMinutes(selectedDate));
      setAmpm(h >= 12 ? 'PM' : 'AM');
    }
  }, [value]);

  const handleDateSelect = (date: Date) => {
    let finalHours = ampm === 'PM' ? (selectedHours === 12 ? 12 : selectedHours + 12) : (selectedHours === 12 ? 0 : selectedHours);
    const newDate = setMinutes(setHours(date, finalHours), selectedMinutes);
    onChange(newDate.toISOString());
  };

  const handleTimeUpdate = (h: number, m: number, p: string) => {
    const baseDate = selectedDate || new Date();
    setSelectedHours(h);
    setSelectedMinutes(m);
    setAmpm(p);
    
    let finalHours = p === 'PM' ? (h === 12 ? 12 : h + 12) : (h === 12 ? 0 : h);
    const newDate = setMinutes(setHours(baseDate, finalHours), m);
    onChange(newDate.toISOString());
  };

  const monthStart = startOfMonth(viewDate);
  const monthEnd = endOfMonth(monthStart);
  const startDate = startOfWeek(monthStart);
  const endDate = endOfWeek(monthEnd);
  const calendarDays = eachDayOfInterval({ start: startDate, end: endDate });

  const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return (
    <div className="space-y-1.5 w-full">
      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">{label}</label>
      
      {/* TRIGGER INPUT */}
      <div 
        onClick={() => setIsOpen(true)}
        className="group relative flex items-center gap-3 w-full pl-11 pr-4 py-3.5 bg-white border border-slate-200 rounded-lg cursor-pointer transition-all hover:bg-slate-50 hover:border-slate-300 shadow-sm"
      >
        <div className="absolute left-3.5 w-7 h-7 bg-slate-50 rounded-lg flex items-center justify-center text-slate-400 group-hover:bg-slate-100 group-hover:text-slate-600 transition-colors">
          <Icon size={14} />
        </div>
        <div className="flex flex-col">
          <span className={`text-[12px] font-bold ${!value ? 'text-slate-400 italic font-medium' : 'text-slate-900'}`}>
            {value ? format(parseISO(value), 'do MMM, hh:mm a') : 'Tap to set time...'}
          </span>
        </div>
      </div>

      <AnimatePresence>
        {isOpen && (
          <div className="fixed inset-0 flex items-center justify-center z-[999] p-4 md:p-6">
            {/* BACKDROP */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsOpen(false)}
              className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm"
            />

            {/* MODAL CARD */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="relative w-full max-w-[300px] bg-white rounded-lg shadow-[0_32px_64px_-16px_rgba(0,0,0,0.3)] overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Header */}
              <div className="p-4 flex items-center justify-between border-b border-slate-50">
                <div className="flex flex-col">
                  <h4 className="text-[14px] font-black text-slate-800 tracking-tight">{format(viewDate, 'MMMM yyyy')}</h4>
                  <div className="flex items-center gap-1">
                    <div className={`w-1 h-1 rounded-full ${activeColor.bg}`} />
                    <span className="text-[9px] font-black text-slate-400 tracking-widest uppercase">Pick a Date</span>
                  </div>
                </div>
                <div className="flex items-center gap-1.5">
                  <button type="button" onClick={() => setViewDate(subMonths(viewDate, 1))} className="p-1.5 hover:bg-slate-50 border border-slate-100 rounded-lg transition-all"><ChevronLeft size={16} /></button>
                  <button type="button" onClick={() => setViewDate(addMonths(viewDate, 1))} className="p-1.5 hover:bg-slate-50 border border-slate-100 rounded-lg transition-all"><ChevronRight size={16} /></button>
                </div>
              </div>

              {/* Calendar Grid */}
              <div className="p-4 pt-2">
                <div className="grid grid-cols-7 mb-1">
                  {weekDays.map(day => (
                    <div key={day} className="text-[9px] font-black text-slate-300 text-center uppercase py-1">{day[0]}</div>
                  ))}
                </div>
                <div className="grid grid-cols-7 gap-0.5">
                  {calendarDays.map((day, i) => {
                    const isSelected = selectedDate && isSameDay(day, selectedDate);
                    const isCurrentMonth = isSameMonth(day, monthStart);
                    const today = isToday(day);

                    return (
                      <button
                        key={i}
                        type="button"
                        onClick={() => handleDateSelect(day)}
                        className={`
                          aspect-square w-full rounded-lg text-[11px] font-bold transition-all relative flex items-center justify-center
                          ${!isCurrentMonth ? 'text-slate-100' : 'text-slate-600 hover:bg-slate-50'}
                          ${isSelected ? `${activeColor.bg} text-white shadow-lg ${activeColor.shadow} scale-105 z-10` : ''}
                          ${today && !isSelected ? `${activeColor.text} ${activeColor.light}` : ''}
                        `}
                      >
                        {format(day, 'd')}
                        {today && !isSelected && <div className={`absolute bottom-1 w-1 h-1 rounded-full ${activeColor.bg}`} />}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Time Section */}
              <div className="bg-slate-50 py-3 px-4 border-t border-slate-100">

                
                <div className="w-full flex items-center gap-2 bg-white p-2.5 rounded-lg border border-slate-200 shadow-sm">
                    {/* CUSTOM HOURS PICKER */}
                    <div className="flex-1 relative" ref={hourPickerRef}>
                      <button
                        type="button"
                        onClick={() => setShowHourPicker(!showHourPicker)}
                        className="w-full bg-slate-50 border-none text-[15px] font-black text-slate-800 py-3 rounded-lg focus:outline-none cursor-pointer text-center hover:bg-slate-100 transition-colors flex items-center justify-center gap-1"
                      >
                        {selectedHours.toString().padStart(2, '0')}
                        <ChevronDown size={12} className={`opacity-30 transition-transform ${showHourPicker ? 'rotate-180' : ''}`} />
                      </button>
                      
                      <AnimatePresence>
                        {showHourPicker && (
                          <motion.div
                            initial={{ opacity: 0, y: -10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: -10, scale: 0.95 }}
                            className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 w-[60px] bg-white rounded-lg border border-slate-100 shadow-2xl z-[1000] max-h-48 overflow-y-auto no-scrollbar py-2"
                          >
                            {Array.from({ length: 12 }, (_, i) => i + 1).map(h => (
                              <button
                                key={h}
                                type="button"
                                onClick={() => {
                                  handleTimeUpdate(h, selectedMinutes, ampm);
                                  setShowHourPicker(false);
                                }}
                                className={`w-full py-2.5 text-sm font-bold transition-colors ${selectedHours === h ? `${activeColor.bg} text-white` : 'text-slate-600 hover:bg-slate-50'}`}
                              >
                                {h.toString().padStart(2, '0')}
                              </button>
                            ))}
                          </motion.div>
                        )}
                      </AnimatePresence>
                      <span className="absolute -top-2 left-1/2 -translate-x-1/2 px-1.5 bg-white text-[7px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Hours</span>
                    </div>
                    
                    <span className="text-slate-200 font-black text-lg">:</span>

                    {/* CUSTOM MINUTES PICKER */}
                    <div className="flex-1 relative" ref={minutePickerRef}>
                      <button
                        type="button"
                        onClick={() => setShowMinutePicker(!showMinutePicker)}
                        className="w-full bg-slate-50 border-none text-[15px] font-black text-slate-800 py-3 rounded-lg focus:outline-none cursor-pointer text-center hover:bg-slate-100 transition-colors flex items-center justify-center gap-1"
                      >
                        {selectedMinutes.toString().padStart(2, '0')}
                        <ChevronDown size={12} className={`opacity-30 transition-transform ${showMinutePicker ? 'rotate-180' : ''}`} />
                      </button>

                      <AnimatePresence>
                        {showMinutePicker && (
                          <motion.div
                            initial={{ opacity: 0, y: -10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: -10, scale: 0.95 }}
                            className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 w-[60px] bg-white rounded-lg border border-slate-100 shadow-2xl z-[1000] max-h-48 overflow-y-auto no-scrollbar py-2"
                          >
                            {Array.from({ length: 60 }, (_, i) => i).map(m => (
                              <button
                                key={m}
                                type="button"
                                onClick={() => {
                                  handleTimeUpdate(selectedHours, m, ampm);
                                  setShowMinutePicker(false);
                                }}
                                className={`w-full py-2.5 text-sm font-bold transition-colors ${selectedMinutes === m ? `${activeColor.bg} text-white` : 'text-slate-600 hover:bg-slate-50'}`}
                              >
                                {m.toString().padStart(2, '0')}
                              </button>
                            ))}
                          </motion.div>
                        )}
                      </AnimatePresence>
                      <span className="absolute -top-2 left-1/2 -translate-x-1/2 px-1.5 bg-white text-[7px] font-black text-slate-400 uppercase tracking-widest whitespace-nowrap">Minutes</span>
                    </div>

                    <div className="w-px h-8 bg-slate-100 mx-1" />

                    <div className="flex flex-col gap-1">
                      {['AM', 'PM'].map(p => (
                        <button
                          key={p}
                          type="button"
                          onClick={() => handleTimeUpdate(selectedHours, selectedMinutes, p)}
                          className={`w-10 py-1 rounded-md text-[9px] font-black transition-all ${ampm === p ? `${activeColor.bg} text-white shadow-md` : 'text-slate-400 hover:bg-slate-50'}`}
                        >
                          {p}
                        </button>
                      ))}
                    </div>
                  </div>
              </div>

              {/* Action Buttons */}
              <div className="p-4 bg-white flex items-center justify-between gap-3 border-t border-slate-100">
                <button 
                  type="button"
                  onClick={() => { onChange(undefined); setIsOpen(false); }}
                  className="text-[10px] font-black text-slate-400 hover:text-red-500 transition-colors uppercase tracking-widest px-1"
                >
                  Clear
                </button>
                <button 
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className={`flex-1 py-3 ${activeColor.bg} text-white rounded-lg text-[12px] font-black shadow-lg ${activeColor.shadow} hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2`}
                >
                  Confirm
                  <Check size={16} />
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
