import React, { useState } from 'react';
import { UserProfile } from '../types';
import { supabase } from '../supabase';
import { 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar, 
  Shield, 
  LogOut,
  Camera,
  Edit2,
  Pencil,
  ChevronRight,
  X,
  Loader2,
  Star
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { useToast } from './Toast';
import { compressImage } from '../utils/imageCompressor';
import { capitalizeWords } from '../utils/textFormat';

interface ProfileProps {
  profile: UserProfile | null;
  onLogout: () => void;
  onUpdate: (data: Partial<UserProfile>) => Promise<void>;
}

export default function Profile({ profile, onLogout, onUpdate }: ProfileProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [editData, setEditData] = useState<Partial<UserProfile>>({});
  const [isSaving, setIsSaving] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isCompressing, setIsCompressing] = useState(false);
  const { showToast } = useToast();

  if (!profile) return null;

  const handleEdit = () => {
    setEditData({
      name: profile.name,
      phone: profile.phone || '',
      state: profile.state || '',
      examPreparingFor: profile.examPreparingFor || '',
      profilePhoto: profile.profilePhoto || ''
    });
    setSelectedFile(null);
    setIsEditing(true);
  };

  const handlePhotoChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      showToast('Please select a valid image file', 'error');
      return;
    }

    setIsCompressing(true);
    try {
      // Compress to 50KB for profile pictures
      const compressedFile = await compressImage(file, 50, 800);
      setSelectedFile(compressedFile);
      
      const reader = new FileReader();
      reader.onloadend = () => {
        setEditData({ ...editData, profilePhoto: reader.result as string });
      };
      reader.readAsDataURL(compressedFile);
    } catch (error) {
      console.error('Compression error:', error);
      showToast('Failed to optimize image', 'error');
    } finally {
      setIsCompressing(false);
      // Reset input so the same file can be selected again if needed
      e.target.value = '';
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    try {
      let finalPhotoUrl = editData.profilePhoto;

      if (selectedFile) {
        // 1. Delete old photo if it's from Supabase
        if (profile.profilePhoto && profile.profilePhoto.includes('supabase.co')) {
          try {
            const oldPath = profile.profilePhoto.split('/').pop();
            if (oldPath) {
              await supabase.storage.from('avatars').remove([`avatars/${oldPath}`]);
            }
          } catch (deleteError) {
            console.warn('Failed to delete old photo', deleteError);
          }
        }

        // 2. Upload new photo
        const fileExt = selectedFile.name.split('.').pop();
        const fileName = `avatar_${profile.userId}_${Date.now()}.${fileExt}`;
        const filePath = `avatars/${fileName}`;

        const { error: uploadError } = await supabase.storage
          .from('avatars')
          .upload(filePath, selectedFile);

        if (uploadError) throw uploadError;

        const { data: { publicUrl } } = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);
        
        finalPhotoUrl = publicUrl;
      }

      await onUpdate({ ...editData, profilePhoto: finalPhotoUrl });
      setIsEditing(false);
      setSelectedFile(null);
    } catch (error) {
      console.error('Save failed', error);
    } finally {
      setIsSaving(false);
    }
  };

  const sections = [
    { icon: Mail, label: 'Email Address', value: profile.email, color: 'text-blue-600', bg: 'bg-blue-50' },
    { icon: Phone, label: 'Phone Number', value: profile.phone || 'Not linked', color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { icon: MapPin, label: 'State', value: profile.state || 'Not set', color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { icon: Shield, label: 'Subscription', value: (profile.subscriptionStatus === 'premium' && (!profile.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date())) ? 'PRO Member' : 'Free Plan', color: 'text-violet-600', bg: 'bg-violet-50' },
  ];

  return (
    <div className="space-y-8 pb-12 max-w-5xl">
      {/* Edit Profile Modal */}
      <AnimatePresence>
        {isEditing && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsEditing(false)}
              className="absolute inset-0 bg-slate-900/60 backdrop-blur-md"
            />

            {/* Modal Card */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="relative w-full max-w-sm bg-white rounded-xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh]"
            >
              {/* Header */}
              <div className="bg-gradient-to-r from-emerald-600 to-emerald-500 p-4 relative overflow-hidden shrink-0">
                <div className="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl" />
                
                <div className="flex items-center gap-4 relative z-10">
                  <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/30 text-white shadow-inner">
                    <User size={28} strokeWidth={3} />
                  </div>
                  <div>
                    <h2 className="text-xl font-black text-white leading-none uppercase tracking-tight">Edit Profile</h2>
                    <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1.5">Personal Details</p>
                  </div>
                </div>

                <button 
                  onClick={() => setIsEditing(false)} 
                  className="absolute top-4 right-4 p-2 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20 backdrop-blur-md z-20"
                >
                  <X size={18} />
                </button>
              </div>

              {/* Scrollable Content */}
              <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4">
                {/* Photo Upload Section */}
                <div className="flex flex-col items-center gap-3">
                  <div className="relative group">
                    <div className="w-24 h-24 rounded-2xl overflow-hidden border-4 border-slate-50 shadow-xl group-hover:scale-105 transition-transform duration-300">
                      <img 
                        src={editData.profilePhoto || `https://ui-avatars.com/api/?name=${editData.name}`} 
                        className={`w-full h-full object-cover transition-opacity ${isCompressing ? 'opacity-50' : 'opacity-100'}`}
                        alt="Preview"
                      />
                    </div>
                    
                    {isCompressing && (
                      <div className="absolute inset-0 flex items-center justify-center bg-white/20 backdrop-blur-[2px] rounded-2xl">
                        <Loader2 className="animate-spin text-emerald-500" size={24} />
                      </div>
                    )}

                    <label className="absolute -bottom-2 -right-2 p-2.5 bg-emerald-500 text-white rounded-xl shadow-lg cursor-pointer hover:bg-emerald-600 transition-all active:scale-90 ring-4 ring-white group-hover:rotate-12">
                      <Camera size={16} strokeWidth={3} />
                      <input type="file" className="hidden" accept="image/*" onChange={handlePhotoChange} disabled={isCompressing} />
                    </label>
                  </div>
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
                    {selectedFile 
                      ? `Ready (${(selectedFile.size / 1024).toFixed(0)} KB)`
                      : 'Tap icon to update photo'}
                  </p>
                </div>

                {/* Form Fields */}
                <div className="space-y-3">
                  <div className="space-y-1.5">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Full Name</label>
                    <div className="relative">
                      <User size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-emerald-500" />
                      <input 
                        type="text" 
                        value={editData.name || ''}
                        onChange={e => setEditData({...editData, name: capitalizeWords(e.target.value)})}
                        className="w-full pl-11 pr-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl text-sm font-bold text-slate-700 outline-none focus:border-emerald-500 focus:bg-white transition-all"
                        placeholder="Your Name"
                      />
                    </div>
                  </div>

                  <div className="space-y-1.5">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Phone Number</label>
                    <div className="relative">
                      <Phone size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-emerald-500" />
                      <input 
                        type="tel" 
                        value={editData.phone || ''}
                        onChange={e => setEditData({...editData, phone: e.target.value})}
                        className="w-full pl-11 pr-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl text-sm font-bold text-slate-700 outline-none focus:border-emerald-500 focus:bg-white transition-all"
                        placeholder="10-digit mobile number"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">State</label>
                      <div className="relative">
                        <MapPin size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-emerald-500" />
                        <input 
                          type="text" 
                          value={editData.state || ''}
                          onChange={e => setEditData({...editData, state: capitalizeWords(e.target.value)})}
                          className="w-full pl-10 pr-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl text-xs font-bold text-slate-700 outline-none focus:border-emerald-500 focus:bg-white transition-all"
                          placeholder="State"
                        />
                      </div>
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-1">Goal / Exam</label>
                      <div className="relative">
                        <Shield size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-emerald-500" />
                        <input 
                          type="text" 
                          value={editData.examPreparingFor || ''}
                          onChange={e => setEditData({...editData, examPreparingFor: capitalizeWords(e.target.value)})}
                          className="w-full pl-10 pr-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl text-xs font-bold text-slate-700 outline-none focus:border-emerald-500 focus:bg-white transition-all"
                          placeholder="Exam"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Fixed Footer */}
              <div className="p-4 pt-0 flex gap-2 shrink-0">
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="flex-1 py-3 bg-slate-100 text-slate-600 font-black rounded-xl text-[11px] uppercase tracking-widest hover:bg-slate-200 transition-colors"
                >
                  Cancel
                </button>
                <button 
                  onClick={handleSave}
                  disabled={isSaving}
                  className="flex-1 py-3 bg-gradient-to-r from-emerald-600 to-emerald-500 text-white font-black rounded-xl text-[11px] uppercase tracking-widest shadow-lg shadow-emerald-100 flex items-center justify-center gap-2 hover:from-emerald-700 transition-all active:scale-95 disabled:opacity-50"
                >
                  {isSaving ? <Loader2 className="animate-spin" size={18} /> : 'Update Profile'}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <div className="max-w-3xl space-y-6">
        <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
          {/* Unified User Header within the card */}
          <div className="p-8 bg-slate-50/50 border-b border-slate-100 flex flex-col md:flex-row items-center gap-6 relative">
            <div className="relative">
              <img 
                src={profile.profilePhoto || `https://ui-avatars.com/api/?name=${profile.name}`} 
                className="w-24 h-24 rounded-full border-2 border-white shadow-lg object-cover" 
                alt="Profile" 
              />
              <button 
                onClick={handleEdit}
                className="absolute bottom-0 right-0 p-2 bg-emerald-500 text-white rounded-full shadow-lg hover:bg-emerald-600 transition-all active:scale-95 ring-2 ring-white"
              >
                <Camera size={14} />
              </button>
            </div>

            <div className="flex-1 flex flex-col md:flex-row md:items-center justify-between gap-6">
              <div className="text-center md:text-left space-y-3">
                <div>
                  <div className="flex flex-col md:flex-row md:items-center gap-2 md:gap-4 mb-2">
                    <div className="flex items-center gap-2">
                      <h2 className="text-2xl font-bold text-slate-900">{profile.name}</h2>
                      {profile.subscriptionStatus === 'premium' && (!profile.subscriptionEndDate || new Date(profile.subscriptionEndDate) > new Date()) && (
                        <div className="bg-amber-100 text-amber-600 px-2 py-0.5 rounded flex items-center gap-1 border border-amber-200 shadow-sm">
                          <Star size={12} fill="currentColor" />
                          <span className="text-[10px] font-black uppercase tracking-wider">PRO</span>
                        </div>
                      )}
                    </div>
                    <div className="flex items-center justify-center md:justify-start gap-2">
                      <span className="px-3 py-1 bg-emerald-100/50 text-emerald-700 rounded-full text-xs font-bold border border-emerald-200">
                        {profile.examPreparingFor || 'Aspirant'}
                      </span>
                      {profile.role === 'admin' && (
                        <span className="px-3 py-1 bg-slate-900 text-white rounded-full text-xs font-bold">
                          Admin
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="flex flex-wrap justify-center md:justify-start gap-4 text-slate-500 text-sm font-medium">
                    <span className="flex items-center gap-1.5"><Calendar size={16} className="text-blue-500" /> Joined {new Date(profile.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>
                  </div>
                </div>

              </div>


            </div>
          </div>

          <div className="p-6 border-b border-slate-50 font-bold text-slate-900 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-blue-50 rounded-full flex items-center justify-center text-blue-500 border border-blue-100">
                <User size={16} />
              </div>
              Account Details
            </div>
            <button 
              onClick={handleEdit}
              className="w-8 h-8 flex items-center justify-center bg-emerald-500 text-white rounded-full shadow-lg shadow-emerald-100 hover:bg-emerald-600 transition-all active:scale-90"
              title="Edit Profile"
            >
              <Pencil size={14} strokeWidth={3} />
            </button>
          </div>
          <div className="divide-y divide-slate-50">
            {sections.map((item, i) => (
              <div key={i} className="p-6 flex items-center justify-between group cursor-pointer hover:bg-slate-50 transition-colors">
                <div className="flex items-center gap-4">
                  <div className={`w-11 h-11 ${item.bg} rounded-full flex items-center justify-center ${item.color} transition-colors shadow-sm border border-white`}>
                    <item.icon size={20} />
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">{item.label}</p>
                    <p className="font-semibold text-slate-900">{item.value}</p>
                  </div>
                </div>
                <ChevronRight size={20} className="text-slate-300" />
              </div>
            ))}
            
            {/* Sign Out row inside the card */}
            <div 
              onClick={onLogout}
              className="p-6 flex items-center justify-between group cursor-pointer hover:bg-red-50 transition-colors"
            >
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 bg-red-50 rounded-full flex items-center justify-center text-red-400 group-hover:text-red-500 transition-colors border border-red-100/50">
                  <LogOut size={20} />
                </div>
                <div>
                  <p className="text-xs font-bold text-red-400 uppercase tracking-wider">Session</p>
                  <p className="font-semibold text-red-600">Sign Out from Account</p>
                </div>
              </div>
              <ChevronRight size={20} className="text-red-300" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
