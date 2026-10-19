import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { db } from '../firebase';
import { collection, addDoc, getDocs, doc, setDoc, getDoc, serverTimestamp, writeBatch, deleteDoc, getDocFromServer, query, where, limit, orderBy, onSnapshot, updateDoc, QueryDocumentSnapshot, DocumentData, startAfter, runTransaction } from 'firebase/firestore';
import { auth } from '../firebase';
import { Test, Question, Category, ExamCategory, UserProfile, ExamPattern, Attempt, AppBanner, AppNotification, LuckyWheelConfig, WheelSlice, DEFAULT_SLICES, ReferralSystemConfig, Post, Poll } from '../types';
import { supabase } from '../supabase';
import { useToast } from './Toast';
import { QRCodeSVG } from 'qrcode.react';
import {
  Plus, FileText, Users, DollarSign, BarChart3, Upload, Trash2, Edit, Edit3, Save, Pencil, SquarePen, Sparkles, Youtube,
  Image as ImageIcon, File as FileIcon, Loader2, X, AlertTriangle, Folder, ChevronDown,
  ChevronRight, Layers, Tag, Settings, Download, Search, Layout, CheckCircle2, AlertCircle,
  Globe, LayoutDashboard, BrainCircuit, Home, FolderTree, Settings2, IndianRupee, Zap,
  ScrollText, Clock, RotateCcw, Calendar, Coins, Gift, History, Trophy, Bell, ExternalLink,
  Mail, MessageCircle, Minus, PlusCircle, Star, User, Radio, ArrowUpRight, QrCode, Check,
  XCircle, Dices, FileStack, LayoutGrid, Library, BookOpen, Percent, ArrowRight, UserPlus,
  ShieldAlert, Ban, UserCheck, ShieldX, ShieldCheck, Facebook, Twitter, Instagram, Linkedin, Send, Phone, LineChart, ClipboardList, TrendingUp, RefreshCw
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { GoogleGenAI, Type } from "@google/genai";
import MathText from './MathText';
import { calculateAttemptMetrics } from '../utils/attemptStats';
import { sendPushNotification } from '../utils/push-notifications';
import { jsPDF } from 'jspdf';
import html2canvas from 'html2canvas';
import { Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType } from 'docx';
import { saveAs } from 'file-saver';
import CustomSelect from './CustomSelect';
import CustomDateTimePicker from './CustomDateTimePicker';
import {
  cleanExamCategoryName,
  findExamCategoryGroupById,
  getExamCategoryDocumentId,
  getExamCategoryRegistryKey,
  groupExamCategories,
  normalizeExamCategoryName
} from '../utils/examCategories';
import { compressImage } from '../utils/imageCompressor';
import { capitalizeWords } from '../utils/textFormat';
import ReactQuill from 'react-quill-new';
import 'react-quill-new/dist/quill.snow.css';

import Leaderboard from './Leaderboard';
import ImageBannerModal from './ImageBannerModal';
import AdminSupport from './AdminSupport';
import AdminFeedback from './AdminFeedback';
import AdminBattleQuestions from './AdminBattleQuestions';
import WhatsAppIcon from './icons/WhatsAppIcon';

const quillModules = {
  toolbar: [
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    ['bold', 'italic', 'underline', 'strike'],
    [{ 'list': 'ordered' }, { 'list': 'bullet' }, { 'indent': '-1' }, { 'indent': '+1' }],
    [{ 'align': [] }],
    [{ 'color': [] }, { 'background': [] }],
    ['link', 'image', 'video'],
    ['blockquote', 'code-block'],
    ['clean']
  ],
};

const quillFormats = [
  'header',
  'bold', 'italic', 'underline', 'strike',
  'list', 'indent',
  'align',
  'color', 'background',
  'link', 'image', 'video',
  'blockquote', 'code-block'
];

const APP_PAGES = [
  { label: 'Dashboard', path: '/dashboard' },
  { label: 'Test Series', path: '/tests' },
  { label: '1v1 Battle', path: '/battle' },
  { label: 'Earn', path: '/earn' },
  { label: 'Live Contests', path: '/earn/live' },
  { label: 'Upcoming Contests', path: '/earn/upcoming' },
  { label: 'History (Past Contests)', path: '/earn/past' },
  { label: 'Updates', path: '/updates' },
  { label: 'Leaderboard', path: '/leaderboard' },
  { label: 'Lucky Wheel', path: '/wheel' },
  { label: 'Refer & Earn', path: '/refer' },
  { label: 'Wallet', path: '/wallet' },
  { label: 'Subscription', path: '/subscription' },
  { label: 'Profile', path: '/profile' },
  { label: 'Support Chat', path: '/support' },
  { label: 'Give Feedback', path: '/feedback' },
  { label: 'Contact Us', path: '/contactus' },
  { label: 'About Us', path: '/aboutus' },
  { label: 'Privacy Policy', path: '/privacypolicy' },
  { label: 'Terms of Use', path: '/termsofuse' },
  { label: 'Refund Policy', path: '/refundpolicy' },
  { label: 'Admin Panel', path: '/admin' }
];

export default function AdminPanel({ activeTab, onTabChange }: {
  activeTab: 'overview' | 'tests' | 'users' | 'patterns' | 'ai-creator' | 'finance' | 'contests' | 'settings' | 'banners' | 'notifications' | 'wheel' | 'leaderboard' | 'referrals' | 'posts' | 'support' | 'feedback' | 'battle_qs' | 'polls',
  onTabChange: (tab: 'overview' | 'tests' | 'users' | 'patterns' | 'ai-creator' | 'finance' | 'contests' | 'settings' | 'banners' | 'notifications' | 'wheel' | 'leaderboard' | 'referrals' | 'posts' | 'support' | 'feedback' | 'battle_qs' | 'polls') => void
}) {
  const { showToast } = useToast();
  const [aiSelectedExamId, setAiSelectedExamId] = useState<string>('all');
  // activeTab and isSidebarOpen are now handled by parent App.tsx

  enum OperationType {
    CREATE = 'create',
    UPDATE = 'update',
    DELETE = 'delete',
    LIST = 'list',
    GET = 'get',
    WRITE = 'write',
  }

  interface FirestoreErrorInfo {
    error: string;
    operationType: OperationType;
    path: string | null;
    authInfo: {
      userId: string | undefined;
      email: string | null | undefined;
      emailVerified: boolean | undefined;
      isAnonymous: boolean | undefined;
      tenantId: string | null | undefined;
      providerInfo: {
        providerId: string;
        displayName: string | null;
        email: string | null;
        photoUrl: string | null;
      }[];
    }
  }

  const handleFirestoreError = (error: unknown, operationType: OperationType, path: string | null) => {
    const errInfo: FirestoreErrorInfo = {
      error: error instanceof Error ? error.message : String(error),
      authInfo: {
        userId: auth.currentUser?.uid,
        email: auth.currentUser?.email,
        emailVerified: auth.currentUser?.emailVerified,
        isAnonymous: auth.currentUser?.isAnonymous,
        tenantId: auth.currentUser?.tenantId,
        providerInfo: auth.currentUser?.providerData.map(provider => ({
          providerId: provider.providerId,
          displayName: provider.displayName,
          email: provider.email,
          photoUrl: provider.photoURL
        })) || []
      },
      operationType,
      path
    };
    console.error('Firestore Error: ', JSON.stringify(errInfo));
    throw new Error(JSON.stringify(errInfo));
  };

  const [tests, setTests] = useState<Test[]>([]);
  const [payQRRequest, setPayQRRequest] = useState<any | null>(null);
  const [isQRModalOpen, setIsQRModalOpen] = useState(false);
  const [confirmFinanceAction, setConfirmFinanceAction] = useState<{
    requestId: string,
    type: 'topup' | 'withdraw',
    action: 'approved' | 'rejected',
    data: any
  } | null>(null);
  const [categories, setCategories] = useState<Category[]>([]);
  const [examCategories, setExamCategories] = useState<ExamCategory[]>([]);
  const [showAddTest, setShowAddTest] = useState(false);
  const [showManageCategories, setShowManageCategories] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');
  const [editingExamCategory, setEditingExamCategory] = useState<ExamCategory | null>(null);
  const [selectedIconFile, setSelectedIconFile] = useState<File | null>(null);
  const [iconPreviewUrl, setIconPreviewUrl] = useState<string | null>(null);
  const [isSavingIcon, setIsSavingIcon] = useState(false);

  useEffect(() => {
    if (editingExamCategory) {
      setIconPreviewUrl(editingExamCategory.iconUrl || null);
      setSelectedIconFile(null);
    } else {
      setIconPreviewUrl(null);
      setSelectedIconFile(null);
    }
  }, [editingExamCategory]);
  const [newTopicName, setNewTopicName] = useState('');
  const [selectedCategoryForTopic, setSelectedCategoryForTopic] = useState<string | null>(null);
  const [isAddingCategory, setIsAddingCategory] = useState(false);
  const [selectedExamForSubject, setSelectedExamForSubject] = useState<string>('all'); // 'all' or examCategoryId
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [managingQuestionsFor, setManagingQuestionsFor] = useState<Test | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [showAddQuestion, setShowAddQuestion] = useState(false);
  const [isGenerating, setIsGenerating] = useState(false);
  const [polls, setPolls] = useState<Poll[]>([]);
  const [isFetchingPolls, setIsFetchingPolls] = useState(false);
  const [showAddPoll, setShowAddPoll] = useState(false);
  const [editingPoll, setEditingPoll] = useState<Poll | null>(null);


  // Confirmation State
  const [deleteConfirm, setDeleteConfirm] = useState<{ type: 'test' | 'question' | 'pattern' | 'examCategory' | 'category' | 'topic' | 'declareResult' | 'poll' | 'banner', id: string, title: string, metadata?: any } | null>(null);

  const [isDeleting, setIsDeleting] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState<Record<string, boolean>>({});
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedTests, setSelectedTests] = useState<Set<string>>(new Set());
  const [isBulkDeleting, setIsBulkDeleting] = useState(false);
  const [showBulkDeleteConfirm, setShowBulkDeleteConfirm] = useState(false);
  const [categorySearchTerm, setCategorySearchTerm] = useState('');
  const [contestFilter, setContestFilter] = useState<'all' | 'live' | 'upcoming' | 'past'>('all');

  // Settings / Cloudflare Worker State
  const [cfWorkerUrl, setCfWorkerUrl] = useState('');
  const [currentAdminName, setCurrentAdminName] = useState<string>('');
  const [adminNamesMap, setAdminNamesMap] = useState<Record<string, string>>({});
  const [cfPrompt, setCfPrompt] = useState('');
  const [featureFlags, setFeatureFlags] = useState<{ showSubscriptionTab: boolean }>({ showSubscriptionTab: true });
  const [subscriptionConfig, setSubscriptionConfig] = useState<{ priceInCoins: number, durationDays: number, contestDiscount: number, isActive: boolean }>({ priceInCoins: 5000, durationDays: 30, contestDiscount: 50, isActive: true });

  // Fetch Worker URL from Firestore
  useEffect(() => {
    const fetchWorkerConfig = async () => {
      try {
        const docRef = doc(db, 'configs', 'ai_worker');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          const url = docSnap.data().url;
          setCfWorkerUrl(url || '');
          // Keep localStorage as a fallback for the current session/legacy
          localStorage.setItem('cfWorkerUrl', url || '');
        } else {
          // Fallback to localStorage if no Firestore doc exists yet
          const localUrl = localStorage.getItem('cfWorkerUrl');
          if (localUrl) setCfWorkerUrl(localUrl);
        }
      } catch (error) {
        console.error("Error fetching worker config:", error);
        // Fallback to localStorage on error
        const localUrl = localStorage.getItem('cfWorkerUrl');
        if (localUrl) setCfWorkerUrl(localUrl);
      }
    };
    fetchWorkerConfig();

    const fetchFeatureFlagsConfig = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'feature_flags'));
        if (snap.exists()) {
          const data = snap.data();
          setFeatureFlags({ showSubscriptionTab: data.showSubscriptionTab !== false });
        }
      } catch (e) {
        console.error("Error fetching feature flags:", e);
      }
    };
    fetchFeatureFlagsConfig();

    const fetchSubscriptionConfig = async () => {
      try {
        const snap = await getDoc(doc(db, 'configs', 'subscription_settings'));
        if (snap.exists()) {
          setSubscriptionConfig(prev => ({ ...prev, ...snap.data() as any }));
        }
      } catch (e) {
        console.error("Error fetching subscription config:", e);
      }
    };
    fetchSubscriptionConfig();

    const fetchAdminProfile = async () => {
      if (auth.currentUser) {
        const userDoc = await getDoc(doc(db, 'users', auth.currentUser.uid));
        if (userDoc.exists()) {
          setCurrentAdminName(userDoc.data().name || '');
        }
      }

      // Fetch all admins to map emails to names for legacy records
      try {
        const q = query(collection(db, 'users'), where('role', '==', 'admin'));
        const snap = await getDocs(q);
        const mapping: Record<string, string> = {};
        snap.forEach(d => {
          const data = d.data();
          if (data.email && data.name) {
            mapping[data.email.toLowerCase()] = data.name;
          }
        });
        setAdminNamesMap(mapping);
      } catch (err) {
        console.error("Error fetching admin names map:", err);
      }
    };
    fetchAdminProfile();
  }, []);

  // Fetch Payment Config
  useEffect(() => {
    const fetchPaymentSettings = async () => {
      try {
        const docRef = doc(db, 'configs', 'payment_settings');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setPaymentConfig(prev => ({ ...prev, ...docSnap.data() }));
        }
      } catch (error) {
        console.error("Error fetching payment settings:", error);
      }
    };
    fetchPaymentSettings();
  }, []);

  // Fetch Withdrawal Settings
  useEffect(() => {
    const fetchWithdrawalSettings = async () => {
      try {
        const docRef = doc(db, 'configs', 'withdrawal_settings');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setWithdrawalSettings(prev => ({ ...prev, ...docSnap.data() }));
        }
      } catch (error) {
        console.error("Error fetching withdrawal settings:", error);
      }
    };
    fetchWithdrawalSettings();
  }, []);

  // Fetch Wheel Config
  useEffect(() => {
    const fetchWheelConfig = async () => {
      try {
        const docRef = doc(db, 'configs', 'lucky_wheel');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setWheelConfig(docSnap.data() as LuckyWheelConfig);
        } else {
          setWheelConfig({
            slices: DEFAULT_SLICES,
            isActive: true,
            spinCost: 10
          });
        }
      } catch (error) {
        console.error("Error fetching wheel config:", error);
      }
    };
    if (activeTab === 'wheel') {
      fetchWheelConfig();
    }
  }, [activeTab]);

  // Fetch Referral Config
  useEffect(() => {
    const fetchReferralConfig = async () => {
      try {
        const docRef = doc(db, 'configs', 'referral_system');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setReferralConfig(docSnap.data() as ReferralSystemConfig);
        } else {
          // Default config if not exists
          const defaultConfig: ReferralSystemConfig = {
            isActive: true,
            referrerReward: 50,
            refereeReward: 100,
            commissionRate: 5,
            minWithdrawal: 2000,
            updatedAt: new Date().toISOString()
          };
          setReferralConfig(defaultConfig);
          await setDoc(docRef, defaultConfig);
        }
      } catch (error) {
        console.error("Error fetching referral config:", error);
      }
    };
    if (activeTab === 'referrals') {
      fetchReferralConfig();
      fetchReferralLogs(true);
    }
  }, [activeTab]);

  useEffect(() => {
    if (activeTab === 'polls') {
      fetchPolls();
    }
  }, [activeTab]);


  const [referralConfig, setReferralConfig] = useState<ReferralSystemConfig>({
    isActive: true,
    referrerReward: 50,
    refereeReward: 100,
    commissionRate: 5,
    minWithdrawal: 2000,
    updatedAt: new Date().toISOString()
  });
  const [paymentConfig, setPaymentConfig] = useState({ upiId: '', merchantName: '', qrNote: '', coinsPerRupee: 1 });
  const [financeRequests, setFinanceRequests] = useState<any[]>([]);
  const [financeTabType, setFinanceTabType] = useState<'pending' | 'history'>('pending');
  const [financeLastDoc, setFinanceLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMoreFinance, setHasMoreFinance] = useState(true);
  const [isFetchingFinance, setIsFetchingFinance] = useState(false);
  const [isSavingConfig, setIsSavingConfig] = useState(false);
  const [isProcessingTopup, setIsProcessingTopup] = useState<string | null>(null);
  const [withdrawalRequests, setWithdrawalRequests] = useState<any[]>([]);
  const [withdrawalLastDoc, setWithdrawalLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMoreWithdrawals, setHasMoreWithdrawals] = useState(true);
  const [isFetchingWithdrawals, setIsFetchingWithdrawals] = useState(false);
  const [isProcessingWithdrawal, setIsProcessingWithdrawal] = useState<string | null>(null);
  const [withdrawalSettings, setWithdrawalSettings] = useState({
    minCoins: 2000,
    isUPIEnabled: true,
    isBankEnabled: false,
    feePercentage: 0,
    withdrawalNote: 'Withdrawals are processed within 24-48 hours.',
    coinsPerRupee: 20
  });
  const [financeSubTab, setFinanceSubTab] = useState<'topups' | 'withdrawals' | 'settings'>('topups');
  const [referralSubTab, setReferralSubTab] = useState<'history' | 'settings'>('history');
  const [referralLogs, setReferralLogs] = useState<any[]>([]);
  const [isFetchingReferrals, setIsFetchingReferrals] = useState(false);
  const [referralLastDoc, setReferralLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMoreReferrals, setHasMoreReferrals] = useState(true);
  const [referralStats, setReferralStats] = useState({ totalJoins: 0, totalDistributed: 0 });
  const [referralSearchQuery, setReferralSearchQuery] = useState('');

  // Official Posts State
  const [adminPosts, setAdminPosts] = useState<Post[]>([]);
  const [isFetchingPosts, setIsFetchingPosts] = useState(false);
  const [showAddPost, setShowAddPost] = useState(false);
  const [isSavingPost, setIsSavingPost] = useState(false);
  const [isUploadingPostImage, setIsUploadingPostImage] = useState(false);
  const [editingPostObj, setEditingPostObj] = useState<Post | null>(null);
  const [isAddingNewCategory, setIsAddingNewCategory] = useState(false);
  const existingPostCategories = Array.from(new Set(adminPosts.map(p => p.category).filter(Boolean)));
  const [postFormData, setPostFormData] = useState({
    title: '',
    content: '',
    excerpt: '',
    imageUrl: '',
    category: '',
    slug: '',
    metaTitle: '',
    metaDescription: '',
    isActive: true,
    sendNotification: false
  });

  const [socialLinks, setSocialLinks] = useState({ facebook: '', twitter: '', instagram: '', youtube: '', linkedin: '', telegram: '', whatsapp: '' });
  const [isSavingSocialLinks, setIsSavingSocialLinks] = useState(false);
  const [apkUrl, setApkUrl] = useState('');
  const [isSavingApkUrl, setIsSavingApkUrl] = useState(false);

  // Fetch Settings Config
  useEffect(() => {
    const fetchSocialLinks = async () => {
      try {
        const docRef = doc(db, 'configs', 'social_links');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setSocialLinks(prev => ({ ...prev, ...docSnap.data() }));
        }
      } catch (error) {
        console.error("Error fetching social links config:", error);
      }
    };
    const fetchApkSettings = async () => {
      try {
        const docRef = doc(db, 'configs', 'app_settings');
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setApkUrl(docSnap.data().apkUrl || '');
        }
      } catch (error) {
        console.error("Error fetching APK settings:", error);
      }
    };
    if (activeTab === 'settings') {
      fetchSocialLinks();
      fetchApkSettings();
    }
  }, [activeTab]);

  const fetchAdminPosts = async () => {
    setIsFetchingPosts(true);
    try {
      const q = query(collection(db, 'posts'), orderBy('createdAt', 'desc'));
      const snap = await getDocs(q);
      setAdminPosts(snap.docs.map(doc => ({ id: doc.id, ...doc.data() }) as Post));
    } catch (error) {
      console.error("Error fetching posts:", error);
    } finally {
      setIsFetchingPosts(false);
    }
  };

  const handleSavePost = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSavingPost(true);
    try {
      const postData = {
        ...postFormData,
        authorName: currentAdminName || 'Admin',
        createdAt: editingPostObj ? editingPostObj.createdAt : serverTimestamp(),
        updatedAt: serverTimestamp()
      };

      if (editingPostObj) {
        await updateDoc(doc(db, 'posts', editingPostObj.id), postData);
        showToast('Post updated successfully', 'success');
      } else {
        await addDoc(collection(db, 'posts'), postData);
        showToast('Post created successfully', 'success');
      }

      // Handle Notifications if enabled
      if (postFormData.sendNotification && postFormData.isActive) {
        const notifTitle = `New Update: ${postFormData.title}`;
        const notifMessage = postFormData.excerpt || "Check out the latest news and updates!";

        try {
          // 1. Create In-App Notification
          await addDoc(collection(db, 'notifications'), {
            title: notifTitle,
            message: notifMessage,
            type: 'announcement',
            link: `/updates/${postFormData.slug}`,
            actionUrl: `/updates/${postFormData.slug}`,
            createdAt: serverTimestamp(),
            readBy: []
          });

          // 2. Send Push Notification
          await sendPushNotification('global', notifTitle, notifMessage, {
            type: 'update',
            slug: postFormData.slug,
            actionUrl: `/updates/${postFormData.slug}`
          });

          showToast('Notifications sent to all users', 'success');
        } catch (error) {
          console.error("Error sending post notifications:", error);
          showToast('Post saved, but failed to send notifications', 'warning');
        }
      }

      setShowAddPost(false);
      setEditingPostObj(null);
      setIsAddingNewCategory(false);
      setPostFormData({
        title: '', content: '', excerpt: '', imageUrl: '', category: '', slug: '', metaTitle: '', metaDescription: '', isActive: true, sendNotification: false
      });
      fetchAdminPosts();
    } catch (error) {
      console.error("Error saving post:", error);
      showToast('Failed to save post', 'error');
    } finally {
      setIsSavingPost(false);
    }
  };

  const handlePostImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      showToast('Please select a valid image file', 'error');
      return;
    }

    setIsUploadingPostImage(true);
    try {
      // Compress to ~800KB max for blog images
      const compressedFile = await compressImage(file, 800, 1200);

      const fileName = `post-${Date.now()}-${file.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`;
      const { data, error } = await supabase.storage
        .from('post-images')
        .upload(fileName, compressedFile, {
          cacheControl: '3600',
          upsert: false
        });

      if (error) throw error;

      const { data: { publicUrl } } = supabase.storage
        .from('post-images')
        .getPublicUrl(fileName);

      setPostFormData({ ...postFormData, imageUrl: publicUrl });
      showToast('Cover image uploaded!', 'success');
    } catch (error: any) {
      console.error('Upload error:', error);
      showToast(error.message || 'Failed to upload image', 'error');
    } finally {
      setIsUploadingPostImage(false);
    }
  };

  const [suspensionModalUser, setSuspensionModalUser] = useState<UserProfile | null>(null);
  const [suspensionReason, setSuspensionReason] = useState<string>('');
  const [suspensionDuration, setSuspensionDuration] = useState<'24h' | '72h' | '7d' | 'permanent'>('24h');
  const [isSuspending, setIsSuspending] = useState(false);


  const [viewingLeaderboardFor, setViewingLeaderboardFor] = useState<Test | null>(null);

  const fetchFinanceRequests = async (reset = false) => {
    if (isFetchingFinance || (!hasMoreFinance && !reset)) return;
    setIsFetchingFinance(true);
    try {
      let q;
      if (financeTabType === 'pending') {
        q = query(
          collection(db, 'topup_requests'),
          where('status', '==', 'pending'),
          orderBy('timestamp', 'asc'),
          limit(20)
        );
      } else {
        q = query(
          collection(db, 'topup_requests'),
          where('status', 'in', ['approved', 'rejected']),
          orderBy('processedAt', 'desc'),
          limit(20)
        );
      }

      if (!reset && financeLastDoc) {
        q = query(q, startAfter(financeLastDoc));
      }

      const snap = await getDocs(q);
      const docs = snap.docs.map(doc => ({ id: doc.id, ...(doc.data() as any) }));

      if (reset) {
        setFinanceRequests(docs);
      } else {
        setFinanceRequests(prev => [...prev, ...docs]);
      }

      setFinanceLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMoreFinance(snap.docs.length === 20);
    } catch (error: any) {
      console.error("Error fetching finance requests:", error);
      if (error.code === 'failed-precondition') {
        showToast('History view requires a Firestore Index. Check console for setup link.', 'error');
      }
    } finally {
      setIsFetchingFinance(false);
    }
  };

  const fetchWithdrawalRequests = async (reset = false) => {
    if (isFetchingWithdrawals || (!hasMoreWithdrawals && !reset)) return;
    setIsFetchingWithdrawals(true);
    try {
      let q;
      if (financeTabType === 'pending') {
        q = query(
          collection(db, 'withdrawal_requests'),
          where('status', '==', 'pending'),
          orderBy('timestamp', 'asc'),
          limit(20)
        );
      } else {
        q = query(
          collection(db, 'withdrawal_requests'),
          where('status', 'in', ['approved', 'rejected']),
          orderBy('processedAt', 'desc'),
          limit(20)
        );
      }

      if (!reset && withdrawalLastDoc) {
        q = query(q, startAfter(withdrawalLastDoc));
      }

      const snap = await getDocs(q);
      const docs = snap.docs.map(doc => ({ id: doc.id, ...(doc.data() as any) }));

      if (reset) {
        setWithdrawalRequests(docs);
      } else {
        setWithdrawalRequests(prev => [...prev, ...docs]);
      }

      setWithdrawalLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMoreWithdrawals(snap.docs.length === 20);
    } catch (error: any) {
      console.error("Error fetching withdrawal requests:", error);
    } finally {
      setIsFetchingWithdrawals(false);
    }
  };

  const fetchReferralLogs = async (reset = false) => {
    if (isFetchingReferrals || (!hasMoreReferrals && !reset)) return;
    setIsFetchingReferrals(true);
    try {
      let q;
      if (referralSearchQuery.trim()) {
        // 1. First, find the user who OWNS this referral code to get their UID
        const searchCode = referralSearchQuery.trim().toUpperCase();
        const usersRef = collection(db, 'users');
        const referrerQuery = query(usersRef, where('referralCode', '==', searchCode));
        const referrerSnap = await getDocs(referrerQuery);

        if (!referrerSnap.empty) {
          const referrerUid = referrerSnap.docs[0].id;
          // 2. Now query users who were referred by this UID
          q = query(
            collection(db, 'users'),
            where('referredBy', '==', referrerUid),
            orderBy('createdAt', 'desc'),
            limit(20)
          );
        } else {
          // If no user found with that code, maybe they searched for a UID directly
          q = query(
            collection(db, 'users'),
            where('referredBy', '==', searchCode),
            orderBy('createdAt', 'desc'),
            limit(20)
          );
        }
      } else {
        q = query(
          collection(db, 'users'),
          where('referredBy', '!=', ''),
          orderBy('referredBy'),
          orderBy('createdAt', 'desc'),
          limit(20)
        );
      }

      if (!reset && referralLastDoc) {
        q = query(q, startAfter(referralLastDoc));
      }

      const snap = await getDocs(q);
      const joinedUsers = snap.docs.map(doc => ({ userId: doc.id, ...(doc.data() as any) }));

      if (joinedUsers.length > 0) {
        const codes = Array.from(new Set(joinedUsers.map(u => u.referredBy)));
        const referrerMap: Record<string, any> = {};

        // Fetch referrers by UID (since referredBy stores the UID)
        for (const uid of codes) {
          if (!uid) continue;
          try {
            // First try fetching as UID (Document ID)
            const rDoc = await getDoc(doc(db, 'users', uid));
            if (rDoc.exists()) {
              referrerMap[uid] = rDoc.data();
            } else {
              // Fallback: Check if it was stored as a code instead of UID in legacy data
              const rq = query(collection(db, 'users'), where('referralCode', '==', uid.toUpperCase()));
              const rSnap = await getDocs(rq);
              if (!rSnap.empty) {
                referrerMap[uid] = rSnap.docs[0].data();
              }
            }
          } catch (err) {
            console.error("Error fetching referrer:", uid, err);
          }
        }

        const logs = joinedUsers.map(user => ({
          joinedUser: user,
          referrer: referrerMap[user.referredBy] || { name: 'Unknown', email: user.referredBy }
        }));

        // Client-side sort by newest first (backup to server sort)
        const sortedLogs = logs.sort((a, b) => {
          const dateA = new Date(a.joinedUser.createdAt || 0).getTime();
          const dateB = new Date(b.joinedUser.createdAt || 0).getTime();
          return dateB - dateA;
        });

        if (reset) {
          setReferralLogs(sortedLogs);
        } else {
          setReferralLogs(prev => {
            const combined = [...prev, ...sortedLogs];
            // Remove duplicates and re-sort
            const unique = combined.filter((v, i, a) => a.findIndex(t => t.joinedUser.userId === v.joinedUser.userId) === i);
            return unique.sort((a, b) => {
              const dA = new Date(a.joinedUser.createdAt || 0).getTime();
              const dB = new Date(b.joinedUser.createdAt || 0).getTime();
              return dB - dA;
            });
          });
        }
      } else if (reset) {
        setReferralLogs([]);
      }

      setReferralLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMoreReferrals(snap.docs.length === 20);

      if (reset) {
        // Simple count estimate for now
        setReferralStats({
          totalJoins: joinedUsers.length,
          totalDistributed: 0 // We'd need a separate query for transactions to get the real total
        });
      }
    } catch (error) {
      console.error("Error fetching referral logs:", error);
    } finally {
      setIsFetchingReferrals(false);
    }
  };

  const fetchContests = async (filter?: 'all' | 'live' | 'upcoming' | 'past') => {

    setIsLoadingContests(true);
    const activeFilter = filter || contestFilter;
    try {
      const nowStr = new Date().toISOString();
      let q;

      const testsRef = collection(db, 'tests');

      if (activeFilter === 'live') {
        // Live: isTournament == true AND scheduledEndTime >= now
        // We filter for tests that haven't ended yet
        q = query(
          testsRef,
          where('isTournament', '==', true),
          where('scheduledEndTime', '>=', nowStr),
          orderBy('scheduledEndTime', 'asc'),
          limit(50)
        );
      } else if (activeFilter === 'upcoming') {
        // Upcoming: isTournament == true AND scheduledStartTime > now
        q = query(
          testsRef,
          where('isTournament', '==', true),
          where('scheduledStartTime', '>', nowStr),
          orderBy('scheduledStartTime', 'asc'),
          limit(50)
        );
      } else if (activeFilter === 'past') {
        // Past: isTournament == true AND scheduledEndTime < now
        q = query(
          testsRef,
          where('isTournament', '==', true),
          where('scheduledEndTime', '<', nowStr),
          orderBy('scheduledEndTime', 'desc'),
          limit(50)
        );
      } else {
        // All
        q = query(
          testsRef,
          where('isTournament', '==', true),
          orderBy('createdAt', 'desc'),
          limit(50)
        );
      }

      const snap = await getDocs(q);
      const fetched = snap.docs.map(doc => ({ testId: doc.id, ...(doc.data() as object) } as Test));

      // Secondary client-side refinement for "Live" if needed
      // (Because server query only checks end time, some upcoming might show up if we don't check start time)
      if (activeFilter === 'live') {
        const now = new Date();
        setContests(fetched.filter(t => {
          const start = t.scheduledStartTime ? new Date(t.scheduledStartTime) : null;
          return start && start <= now;
        }));
      } else {
        setContests(fetched);
      }

    } catch (error) {
      console.error("Error fetching contests:", error);
      showToast('Error loading contests. You may need to create a Firestore Index.', 'error');
    } finally {
      setIsLoadingContests(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'finance') {
      if (financeSubTab === 'topups') {
        fetchFinanceRequests(true);
      } else if (financeSubTab === 'withdrawals') {
        fetchWithdrawalRequests(true);
      }
    } else if (activeTab === 'contests') {
      fetchContests();
    } else if (activeTab === 'referrals') {
      // Logic for referrals if needed
    } else if (activeTab === 'posts') {
      fetchAdminPosts();
    }
  }, [activeTab, financeTabType, contestFilter, financeSubTab]);

  const handleSaveReferralConfig = async () => {
    setIsSavingConfig(true);
    try {
      const configWithTimestamp = {
        ...referralConfig,
        updatedAt: new Date().toISOString()
      };
      await setDoc(doc(db, 'configs', 'referral_system'), configWithTimestamp);
      showToast('Referral settings updated successfully', 'success');
    } catch (error) {
      console.error("Error saving referral config:", error);
      showToast('Failed to save referral settings', 'error');
    } finally {
      setIsSavingConfig(false);
    }
  };

  const handleSavePaymentConfig = async () => {
    setIsSavingConfig(true);
    try {
      await setDoc(doc(db, 'configs', 'payment_settings'), paymentConfig);
      showToast('Payment settings updated successfully', 'success');
    } catch (error) {
      console.error("Error saving payment config:", error);
      showToast('Failed to save payment settings', 'error');
    } finally {
      setIsSavingConfig(false);
    }
  };

  const handleProcessTopup = async (requestId: string, status: 'approved' | 'rejected') => {
    setIsProcessingTopup(requestId);
    try {
      const request = financeRequests.find(r => r.id === requestId);
      if (!request) return;

      if (status === 'approved') {
        await runTransaction(db, async (transaction) => {
          const userRef = doc(db, 'users', request.userId);
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists()) throw new Error("User not found");

          const userData = userDoc.data();
          const currentCoins = userData.coins || 0;
          const currentTotalEarned = userData.totalEarned || 0;
          transaction.update(userRef, {
            coins: currentCoins + request.amount,
            totalEarned: currentTotalEarned + request.amount
          });

          const requestRef = doc(db, 'topup_requests', requestId);
          transaction.update(requestRef, {
            status: 'approved',
            processedAt: serverTimestamp(),
            processedBy: auth.currentUser?.email,
            processedByName: currentAdminName
          });

          // Create transaction log
          const txRef = doc(collection(db, 'transactions'));
          transaction.set(txRef, {
            userId: request.userId,
            amount: request.amount,
            type: 'earn',
            category: 'top_up',
            timestamp: serverTimestamp(),
            currentBalance: currentCoins + request.amount,
            utr: request.utr
          });

          // Add Notification for user
          const notifRef = doc(collection(db, 'notifications'));
          transaction.set(notifRef, {
            userId: request.userId,
            title: 'Coins Credited! 🪙',
            message: `Your account has been credited with ${request.amount} coins successfully. Check your wallet!`,
            type: 'transaction',
            read: false,
            createdAt: serverTimestamp(),
            actionUrl: '/wallet'
          });
        });

        // Trigger Push Notification (Fire & Forget)
        try {
          await sendPushNotification(
            request.userId,
            'Coins Credited! 🪙',
            `Your account has been credited with ${request.amount} coins. Enjoy!`
          );
        } catch (pushErr) {
          console.error('Push Error during Topup:', pushErr);
        }

        showToast(`Top-up of ${request.amount} coins approved!`, 'success');
      } else {
        await updateDoc(doc(db, 'topup_requests', requestId), {
          status: 'rejected',
          processedAt: serverTimestamp(),
          processedBy: auth.currentUser?.email,
          processedByName: currentAdminName
        });
        showToast('Top-up request rejected', 'warning');
      }
      // Update local state to remove processed item
      setFinanceRequests(prev => prev.filter(r => r.id !== requestId));
    } catch (error) {
      console.error("Error processing topup:", error);
      showToast('Failed to process top-up', 'error');
    } finally {
      setIsProcessingTopup(null);
    }
  };

  const handleSaveWithdrawalSettings = async () => {
    setIsSavingConfig(true);
    try {
      await setDoc(doc(db, 'configs', 'withdrawal_settings'), withdrawalSettings);
      showToast('Withdrawal settings updated', 'success');
    } catch (error) {
      console.error("Error saving withdrawal config:", error);
      showToast('Failed to save settings', 'error');
    } finally {
      setIsSavingConfig(false);
    }
  };

  const handleProcessWithdrawal = async (requestId: string, status: 'approved' | 'rejected') => {
    setIsProcessingWithdrawal(requestId);
    try {
      const request = withdrawalRequests.find(r => r.id === requestId);
      if (!request) return;

      if (status === 'approved') {
        await updateDoc(doc(db, 'withdrawal_requests', requestId), {
          status: 'approved',
          processedAt: serverTimestamp(),
          processedBy: auth.currentUser?.email,
          processedByName: currentAdminName
        });

        // Add Notification for user
        await addDoc(collection(db, 'notifications'), {
          userId: request.userId,
          title: 'Withdrawal Success! ✅',
          message: `Your withdrawal of ₹${request.inRupees} has been processed successfully.`,
          type: 'success',
          read: false,
          createdAt: serverTimestamp(),
          actionUrl: '/wallet'
        });

        try {
          await sendPushNotification(
            request.userId,
            'Withdrawal Success! ✅',
            `Your withdrawal request of ₹${request.inRupees} has been processed.`
          );
        } catch (e) { }

        showToast('Withdrawal marked as approved!', 'success');
      } else {
        // Refund coins if rejected
        await runTransaction(db, async (transaction) => {
          const userRef = doc(db, 'users', request.userId);
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists()) throw new Error("User not found");

          const userData = userDoc.data();
          const currentCoins = userData.coins || 0;
          const currentTotalSpent = userData.totalSpent || 0;
          transaction.update(userRef, {
            coins: currentCoins + request.amount,
            totalSpent: Math.max(0, currentTotalSpent - request.amount) // Refund deducts from total spent
          });

          const requestRef = doc(db, 'withdrawal_requests', requestId);
          transaction.update(requestRef, {
            status: 'rejected',
            processedAt: serverTimestamp(),
            processedBy: auth.currentUser?.email,
            processedByName: currentAdminName
          });

          // Create refund transaction log
          const txRef = doc(collection(db, 'transactions'));
          transaction.set(txRef, {
            userId: request.userId,
            amount: request.amount,
            type: 'earn',
            category: 'withdrawal_refund',
            timestamp: serverTimestamp(),
            currentBalance: currentCoins + request.amount,
            withdrawalRequestId: requestId
          });

          // Notification
          const notifRef = doc(collection(db, 'notifications'));
          transaction.set(notifRef, {
            userId: request.userId,
            title: 'Withdrawal Rejected ❌',
            message: `Your withdrawal request of ₹${request.inRupees} was rejected. Coins have been refunded to your wallet.`,
            type: 'warning',
            read: false,
            createdAt: serverTimestamp(),
            actionUrl: '/wallet'
          });
        });

        try {
          await sendPushNotification(
            request.userId,
            'Withdrawal Rejected ❌',
            `Withdrawal of ₹${request.inRupees} was rejected. Coins refunded.`
          );
        } catch (e) { }

        showToast('Withdrawal rejected and coins refunded', 'warning');
      }
      setWithdrawalRequests(prev => prev.filter(r => r.id !== requestId));
    } catch (error) {
      console.error("Error processing withdrawal:", error);
      showToast('Failed to process withdrawal', 'error');
    } finally {
      setIsProcessingWithdrawal(null);
    }
  };

  const [showExportModal, setShowExportModal] = useState(false);
  const [testToExport, setTestToExport] = useState<Test | null>(null);
  const [isExporting, setIsExporting] = useState<string | null>(null);
  const [exportingTestData, setExportingTestData] = useState<{ test: Test, questions: Question[] } | null>(null);
  const [isCfGenerating, setIsCfGenerating] = useState(false);
  const [debouncedSearchTerm, setDebouncedSearchTerm] = useState('');

  // Analytics State
  const [viewingAnalyticsFor, setViewingAnalyticsFor] = useState<Test | null>(null);
  const [isFetchingAnalytics, setIsFetchingAnalytics] = useState(false);
  const [analyticsAttempts, setAnalyticsAttempts] = useState<Attempt[]>([]);
  const [analyticsUserMap, setAnalyticsUserMap] = useState<Record<string, UserProfile>>({});
  const [analyticsStats, setAnalyticsStats] = useState({ total: 0, avgScore: 0, topScore: 0 });
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [userSearchTerm, setUserSearchTerm] = useState('');
  const [testFilter, setTestFilter] = useState<string>('all');

  // Pagination State
  const [userLastDoc, setUserLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMoreUsers, setHasMoreUsers] = useState(true);
  const [isLoadingUsers, setIsLoadingUsers] = useState(false);
  const [testLastDoc, setTestLastDoc] = useState<QueryDocumentSnapshot<DocumentData> | null>(null);
  const [hasMoreTests, setHasMoreTests] = useState(true);
  const [isLoadingTests, setIsLoadingTests] = useState(false);
  const [userDebouncedSearchTerm, setUserDebouncedSearchTerm] = useState('');
  // Admin Wallet Management State
  const [walletModalUser, setWalletModalUser] = useState<UserProfile | null>(null);
  const [walletCoinAmount, setWalletCoinAmount] = useState<number>(100);
  const [walletReason, setWalletReason] = useState<string>('');
  const [isAddingCoins, setIsAddingCoins] = useState(false);
  const [walletActionType, setWalletActionType] = useState<'add' | 'deduct'>('add');

  // Export status
  const [examPatterns, setExamPatterns] = useState<ExamPattern[]>([]);
  const [showAddPattern, setShowAddPattern] = useState(false);
  const [selectedPatternId, setSelectedPatternId] = useState<string>('');
  const [newPattern, setNewPattern] = useState<Partial<ExamPattern>>({
    examName: '',
    category: 'Railway',
    sections: [{ subject: '', questionCount: 10, topics: [] }],
    totalDuration: 60,
    negativeMarking: 0.25
  });

  // Contest Management State
  const [contests, setContests] = useState<Test[]>([]);
  const [isLoadingContests, setIsLoadingContests] = useState(false);
  const [selectedContestForReview, setSelectedContestForReview] = useState<Test | null>(null);
  const [contestAttempts, setContestAttempts] = useState<Attempt[]>([]);
  const [contestUserMap, setContestUserMap] = useState<Record<string, UserProfile>>({});
  const [contestQuestions, setContestQuestions] = useState<Question[]>([]);
  const [isDeclaringResults, setIsDeclaringResults] = useState(false);

  // App Banner Management State
  const [banners, setBanners] = useState<AppBanner[]>([]);
  const [isFetchingBanners, setIsFetchingBanners] = useState(false);
  const [isUploadingBanner, setIsUploadingBanner] = useState(false);
  const [showAddBanner, setShowAddBanner] = useState(false);
  const [newBanner, setNewBanner] = useState<Partial<AppBanner>>({
    title: '',
    link: '',
    isActive: true,
    priority: 0,
    scheduledAt: ''
  });
  const [bannerFile, setBannerFile] = useState<File | null>(null);
  const [isCompressingBanner, setIsCompressingBanner] = useState(false);
  const [editingBanner, setEditingBanner] = useState<AppBanner | null>(null);

  // Security/Auth Settings
  const [requireEmailVerification, setRequireEmailVerification] = useState(false);
  const [isSavingSecurity, setIsSavingSecurity] = useState(false);

  // Spotlight Banner State
  const [showAddSpotlight, setShowAddSpotlight] = useState(false);
  const [spotlightSearchTerm, setSpotlightSearchTerm] = useState('');
  const [isSearchingSpotlight, setIsSearchingSpotlight] = useState(false);
  const [spotlightFoundUser, setSpotlightFoundUser] = useState<UserProfile | null>(null);
  const [spotlightData, setSpotlightData] = useState({
    score: '',
    rank: '',
    examName: '',
    message: '',
    priority: 0,
    isActive: true
  });
  const [isPublishingSpotlight, setIsPublishingSpotlight] = useState(false);
  const [bannerSubTab, setBannerSubTab] = useState<'all' | 'promotional' | 'spotlights'>('all');
  // Lucky Wheel Management State
  const [wheelConfig, setWheelConfig] = useState<LuckyWheelConfig | null>(null);
  const [isSavingWheelConfig, setIsSavingWheelConfig] = useState(false);
  const [notifyOnSave, setNotifyOnSave] = useState(false);
  const [activeBanner, setActiveBanner] = useState<AppBanner | null>(null);

  const handleBannerFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      showToast('Please select a valid image file', 'error');
      return;
    }

    setIsCompressingBanner(true);
    try {
      // Compress banner to max 150KB
      const compressedFile = await compressImage(file, 150, 1600);
      setBannerFile(compressedFile);
    } catch (err) {
      console.error('Banner compression error:', err);
      showToast('Failed to optimize banner', 'error');
    } finally {
      setIsCompressingBanner(false);
      e.target.value = ''; // Reset input
    }
  };

  // New Notification Management State
  const [notifTargetType, setNotifTargetType] = useState<'global' | 'user'>('global');
  const [notifTargetUserId, setNotifTargetUserId] = useState('');
  const [notifTitle, setNotifTitle] = useState('');
  const [notifMessage, setNotifMessage] = useState('');
  const [notifType, setNotifType] = useState<'info' | 'success' | 'warning' | 'transaction' | 'contest'>('info');
  const [notifSelectedRoute, setNotifSelectedRoute] = useState('none');
  const [notifCustomUrl, setNotifCustomUrl] = useState('');
  const [notifImageUrl, setNotifImageUrl] = useState('');
  const [notifActionLabel, setNotifActionLabel] = useState('');
  const [notifShowAsBanner, setNotifShowAsBanner] = useState(false);
  const [isUploadingNotifImage, setIsUploadingNotifImage] = useState(false);
  const [isSendingNotif, setIsSendingNotif] = useState(false);
  const [notifTargetSegment, setNotifTargetSegment] = useState<'all' | 'pro' | 'free' | 'user'>('all');
  const [notifScheduledAt, setNotifScheduledAt] = useState('');
  const [notifHistory, setNotifHistory] = useState<AppNotification[]>([]);
  const [isFetchingNotifHistory, setIsFetchingNotifHistory] = useState(false);
  const [localBannerPreview, setLocalBannerPreview] = useState<{ imageUrl: string, title: string, message: string, actionUrl?: string, actionLabel?: string } | null>(null);

  // Notification User Search State
  const [isSearchingNotifUser, setIsSearchingNotifUser] = useState(false);
  const [notifUserSearchTerm, setNotifUserSearchTerm] = useState('');
  const [notifUserSearchResults, setNotifUserSearchResults] = useState<UserProfile[]>([]);

  // Real-time server-side search effect
  useEffect(() => {
    if (notifTargetType !== 'user' || !notifUserSearchTerm || notifUserSearchTerm.length < 3) {
      setNotifUserSearchResults([]);
      setIsSearchingNotifUser(false);
      return;
    }

    const timer = setTimeout(async () => {
      setIsSearchingNotifUser(true);
      try {
        const usersRef = collection(db, 'users');
        const term = notifUserSearchTerm.trim();

        let finalResults: UserProfile[] = [];

        if (/^\+?\d+$/.test(term)) {
          const q = query(usersRef, where('phone', '==', term), limit(5));
          const snap = await getDocs(q);
          finalResults = snap.docs.map(d => ({ ...(d.data() || {}), userId: d.id } as UserProfile));
        } else {
          // Send parallel queries to capture both standard and lowercased namings dynamically
          const capitalized = term.charAt(0).toUpperCase() + term.slice(1).toLowerCase();
          const lowercased = term.toLowerCase();

          const qCapital = query(
            usersRef,
            where('name', '>=', capitalized),
            where('name', '<=', capitalized + '\uf8ff'),
            limit(10)
          );

          const qLower = query(
            usersRef,
            where('name', '>=', lowercased),
            where('name', '<=', lowercased + '\uf8ff'),
            limit(10)
          );

          const [snapCapital, snapLower] = await Promise.all([getDocs(qCapital), getDocs(qLower)]);

          const combined = [...snapCapital.docs, ...snapLower.docs];
          const uniqueMap = new Map();

          combined.forEach(d => {
            if (!uniqueMap.has(d.id)) {
              uniqueMap.set(d.id, { ...(d.data() || {}), userId: d.id } as UserProfile);
            }
          });

          finalResults = Array.from(uniqueMap.values());
        }

        setNotifUserSearchResults(finalResults);
      } catch (err) {
        console.error("Error searching users:", err);
      } finally {
        setIsSearchingNotifUser(false);
      }
    }, 500);

    return () => clearTimeout(timer);
  }, [notifUserSearchTerm, notifTargetType]);

  // Memoized grouping for Tests tab (Moved to top level to avoid hook errors)
  const filteredGroupedTests = React.useMemo(() => {
    const filtered = tests.filter(test =>
      testFilter === 'all' || test.examCategory === testFilter
    );

    const grouped = filtered.reduce((acc, test) => {
      const exam = test.examCategory || 'General / Uncategorized';
      const mode = test.testMode || 'mock';

      if (!acc[exam]) acc[exam] = { mock: [], sectional: [], 'previous-year': [] };
      if (!acc[exam][mode]) acc[exam][mode] = [];

      acc[exam][mode].push(test);
      return acc;
    }, {} as Record<string, Record<string, Test[]>>);

    return Object.entries(grouped).filter(([exam, modes]) => {
      const hasMatchInExam = exam.toLowerCase().includes(searchTerm.toLowerCase());
      const hasMatchInTests = Object.values(modes).some(mTests =>
        mTests.some(t => t.title.toLowerCase().includes(searchTerm.toLowerCase()))
      );
      return hasMatchInExam || hasMatchInTests;
    });
  }, [tests, testFilter, searchTerm]);

  // Unified Flat List for Spreadsheet View
  const filteredFlatTests = React.useMemo(() => {
    return tests
      .filter(test => {
        const examName = test.examCategory || 'General / Uncategorized';
        const isMatchExam = testFilter === 'all' || test.examCategory === testFilter;
        const isMatchSearch = test.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          examName.toLowerCase().includes(searchTerm.toLowerCase()) ||
          (test.testMode || '').toLowerCase().includes(searchTerm.toLowerCase());
        return isMatchExam && isMatchSearch;
      })
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [tests, testFilter, searchTerm]);

  const APP_ROUTES = [
    { label: 'No Action (Just Notification)', value: 'none' },
    { label: 'Dashboard', value: '/dashboard' },
    { label: 'Test Series', value: '/tests' },
    { label: '1v1 Battle', value: '/battle' },
    { label: 'Earn', value: '/earn' },
    { label: 'Live Contests', value: '/earn/live' },
    { label: 'Upcoming Contests', value: '/earn/upcoming' },
    { label: 'History (Past Contests)', value: '/earn/past' },
    { label: 'Updates', value: '/updates' },
    { label: 'Leaderboard', value: '/leaderboard' },
    { label: 'Lucky Wheel', value: '/wheel' },
    { label: 'Refer & Earn', value: '/refer' },
    { label: 'Wallet', value: '/wallet' },
    { label: 'Subscription', value: '/subscription' },
    { label: 'Profile', value: '/profile' },
    { label: 'Support Chat', value: '/support' },
    { label: 'Give Feedback', value: '/feedback' },
    { label: 'Contact Us', value: '/contactus' },
    { label: 'About Us', value: '/aboutus' },
    { label: 'Privacy Policy', value: '/privacypolicy' },
    { label: 'Terms of Use', value: '/termsofuse' },
    { label: 'Refund Policy', value: '/refundpolicy' },
    { label: 'Admin Panel', value: '/admin' },
    { label: 'External Link / Custom Path', value: 'custom' },
  ];

  const handleNotifImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      showToast('Please select a valid image file', 'error');
      return;
    }

    setIsUploadingNotifImage(true);
    try {
      // Compress notification images strictly to 150KB for fast push delivery
      const compressedFile = await compressImage(file, 150, 1000);

      const reader = new FileReader();
      reader.onload = async (event) => {
        try {
          const base64 = event.target?.result as string;
          const rawWorkerUrl = localStorage.getItem('cfWorkerUrl') || (import.meta as any).env?.VITE_WORKER_URL || '';
          const workerUrl = rawWorkerUrl.replace(/\/$/, '');

          const response = await fetch(`${workerUrl}/upload-notification-image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              image: base64,
              fileName: `notif-${Date.now()}-${file.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`
            })
          });

          if (!response.ok) throw new Error('Upload failed');
          const data = await response.json();
          setNotifImageUrl(data.url);
          showToast('Notification image uploaded!', 'success');
        } catch (uploadInnerError: any) {
          console.error("Worker upload error", uploadInnerError);
          showToast('Failed to upload image to edge', 'error');
        }
      };
      reader.readAsDataURL(compressedFile);
    } catch (error) {
      console.error('Image upload error:', error);
      showToast('Failed to upload image', 'error');
    } finally {
      setIsUploadingNotifImage(false);
    }
  };

  const handleSendNotification = async () => {
    if (!notifTitle.trim() || !notifMessage.trim()) {
      showToast('Title and Message are required', 'error');
      return;
    }
    if (notifTargetType === 'user' && !notifTargetUserId.trim()) {
      showToast('User ID is required for targeted notification', 'error');
      return;
    }

    setIsSendingNotif(true);
    try {
      const actionUrlValue = notifSelectedRoute === 'custom' ? notifCustomUrl : (notifSelectedRoute === 'none' ? undefined : notifSelectedRoute);
      const isScheduledForFuture = notifScheduledAt && new Date(notifScheduledAt) > new Date();

      const rawNotifData: any = {
        userId: notifTargetType === 'global' ? 'global' : notifTargetUserId,
        title: notifTitle,
        message: notifMessage,
        type: notifType,
        read: false,
        actionUrl: actionUrlValue,
        imageUrl: notifImageUrl || undefined,
        actionLabel: notifActionLabel || undefined,
        showAsBanner: notifShowAsBanner,
        scheduledAt: notifScheduledAt || undefined,
        targetSegment: notifTargetType === 'global' ? notifTargetSegment : 'user',
        clicks: 0,
        pushSent: !isScheduledForFuture, // If not future, it's sent immediately below
        createdAt: serverTimestamp(),
      };

      // Strip undefined values before saving to Firestore
      const notifData = Object.fromEntries(
        Object.entries(rawNotifData).filter(([, v]) => v !== undefined)
      );

      await addDoc(collection(db, 'notifications'), notifData);
      showToast(notifScheduledAt ? 'Notification scheduled successfully!' : 'Notification sent successfully!', 'success');

      // --- Push Notification Broadcast (Only if NOT scheduled or scheduled for NOW) ---
      if (!isScheduledForFuture) {
        try {
          const target = notifTargetType === 'global' ? 'global' : notifTargetUserId;
          const actionUrl = notifSelectedRoute === 'custom' ? notifCustomUrl : (notifSelectedRoute === 'none' ? undefined : notifSelectedRoute);
          await sendPushNotification(target, notifTitle, notifMessage, {
            type: notifType,
            actionUrl,
            image: notifImageUrl,
            imageUrl: notifImageUrl,
            body: notifMessage,
            title: notifTitle,
            actionLabel: notifActionLabel || 'Open Now'
          });
        } catch (pushErr) {
          console.error('Push Notification Error:', pushErr);
        }
      }

      setNotifTitle('');
      setNotifMessage('');
      setNotifImageUrl('');
      setNotifActionLabel('');
      setNotifShowAsBanner(false);
      setNotifSelectedRoute('none');
      setNotifCustomUrl('');
      setNotifScheduledAt('');
      fetchNotifHistory(); // Refresh history
    } catch (error) {
      console.error('Error sending notification:', error);
      showToast('Failed to send notification', 'error');
    } finally {
      setIsSendingNotif(false);
    }
  };

  // --- Background Scheduler for Pending Notifications ---
  // This acts as a fallback for scheduled push notifications when an admin is online
  useEffect(() => {
    const processScheduledPushes = async () => {
      try {
        const now = new Date().toISOString();
        const q = query(
          collection(db, 'notifications'),
          where('pushSent', '==', false),
          where('scheduledAt', '<=', now),
          limit(5)
        );
        
        const snap = await getDocs(q);
        if (snap.empty) return;

        console.log(`[Scheduler] Found ${snap.docs.length} pending scheduled pushes...`);

        for (const notifDoc of snap.docs) {
          const data = notifDoc.data() as AppNotification;
          
          try {
            const target = data.userId === 'global' ? 'global' : data.userId;
            
            // Trigger the actual push broadcast
            await sendPushNotification(
              target, 
              data.title, 
              data.message, 
              {
                type: data.type,
                actionUrl: data.actionUrl || data.link,
                imageUrl: data.imageUrl,
                body: data.message,
                title: data.title
              }
            );

            // Mark as sent in Firestore to prevent duplicate processing
            await updateDoc(notifDoc.ref, { pushSent: true });
            
            // Refresh history if visible
            fetchNotifHistory();
            
          } catch (itemErr) {
            console.error('[Scheduler] Failed to process notification:', notifDoc.id, itemErr);
          }
        }
      } catch (err) {
        console.error('[Scheduler] Error checking scheduled notifications:', err);
      }
    };

    // Run every 45 seconds while admin is on the panel
    const interval = setInterval(processScheduledPushes, 45000);
    processScheduledPushes(); // Initial check

    return () => clearInterval(interval);
  }, []);

  const fetchNotifHistory = async () => {
    setIsFetchingNotifHistory(true);
    try {
      const q = query(collection(db, 'notifications'), orderBy('createdAt', 'desc'), limit(20));
      const snap = await getDocs(q);
      setNotifHistory(snap.docs.map(d => ({ id: d.id, ...d.data() } as AppNotification)));
    } catch (error) {
      console.error("Error fetching notif history:", error);
    } finally {
      setIsFetchingNotifHistory(false);
    }
  };

  const examCategoryRegistryRef = doc(db, 'configs', 'exam_category_registry');

  const buildExamCategoryPayload = (examCategory: ExamCategory) => ({
    name: cleanExamCategoryName(examCategory.name),
    normalizedName: normalizeExamCategoryName(examCategory.name),
    createdAt: examCategory.createdAt || new Date().toISOString(),
    isPublished: examCategory.isPublished !== false,
    usersCountOverride: typeof examCategory.usersCountOverride === 'number' ? examCategory.usersCountOverride : null,
    languages: examCategory.languages?.trim() || null,
    iconUrl: examCategory.iconUrl || null
  });

  const toStoredExamCategory = (examCategory: ExamCategory) => ({
    id: examCategory.id,
    ...buildExamCategoryPayload(examCategory)
  });

  const buildExamCategoryRegistryEntries = (items: ExamCategory[]) => {
    return items.reduce<Record<string, string>>((entries, category) => {
      const registryKey = getExamCategoryRegistryKey(category.name);

      if (registryKey) {
        entries[registryKey] = category.id;
      }

      return entries;
    }, {});
  };

  const seedDefaultExamCategories = async () => {
    const defaults = ['SSC', 'Banking', 'Railway', 'UPSC'];
    const now = new Date().toISOString();
    const batch = writeBatch(db);

    const seededCategories = defaults.map((name) => {
      const id = getExamCategoryDocumentId(name);
      const category = toStoredExamCategory({ id, name, createdAt: now });
      batch.set(doc(db, 'examCategories', id), category);
      return category;
    });

    batch.set(examCategoryRegistryRef, {
      entries: buildExamCategoryRegistryEntries(seededCategories),
      updatedAt: now
    });

    await batch.commit();
    return seededCategories;
  };

  const fetchTestAnalytics = async (test: Test) => {
    setViewingAnalyticsFor(test);
    setIsFetchingAnalytics(true);
    setAnalyticsAttempts([]);

    try {
      // 1. Fetch the 50 most recent attempts (Low read count)
      const attemptsRef = collection(db, 'attempts');
      const q = query(
        attemptsRef,
        where('testId', '==', test.testId),
        orderBy('startTime', 'desc'),
        limit(50)
      );

      const snap = await getDocs(q);
      const attemptsData = snap.docs.map(d => ({ attemptId: d.id, ...d.data() } as Attempt));
      setAnalyticsAttempts(attemptsData);

      // 2. Aggregate basic stats
      if (attemptsData.length > 0) {
        const total = attemptsData.length;
        const sum = attemptsData.reduce((acc, curr) => acc + (curr.score || 0), 0);
        const max = Math.max(...attemptsData.map(d => d.score || 0));
        setAnalyticsStats({ total, avgScore: total > 0 ? sum / total : 0, topScore: max });

        // 3. Fetch missing user profiles (Batch)
        const missingUserIds = Array.from(new Set(attemptsData.map(a => a.userId)))
          .filter(uid => !analyticsUserMap[uid] && !users.find(u => u.userId === uid));

        if (missingUserIds.length > 0) {
          const newUserMap = { ...analyticsUserMap };
          // For simplicity and matching your "Low Read" request:
          // We fetch user names in chunks of 10 if needed, or check existing 'users' state
          for (const uid of missingUserIds) {
            const userDoc = await getDoc(doc(db, 'users', uid));
            if (userDoc.exists()) {
              newUserMap[uid] = userDoc.data() as UserProfile;
            }
          }
          setAnalyticsUserMap(newUserMap);
        }
      } else {
        setAnalyticsStats({ total: 0, avgScore: 0, topScore: 0 });
      }
    } catch (error) {
      console.error("Error fetching analytics:", error);
      showToast('Error loading analytics', 'error');
    } finally {
      setIsFetchingAnalytics(false);
    }
  };



  const syncFetchedExamCategories = async (fetched: ExamCategory[]) => {
    const groupedCategories = groupExamCategories(fetched);
    const duplicateGroups = groupedCategories.filter((group) => group.aliasIds.length > 1);
    const normalizedGroups = groupedCategories.filter((group) => {
      const primary = group.rawCategories.find((category) => category.id === group.id);

      return !primary ||
        cleanExamCategoryName(primary.name) !== group.name ||
        normalizeExamCategoryName(primary.normalizedName || primary.name) !== group.normalizedName;
    });

    if (duplicateGroups.length === 0 && normalizedGroups.length === 0) {
      return groupedCategories.map(({ rawCategories, aliasIds, ...group }) => group);
    }

    const subjectSnap = await getDocs(collection(db, 'categories'));
    const subjectDocs = subjectSnap.docs;
    const touchedTestIds = new Set<string>();
    const touchedPatternIds = new Set<string>();

    for (const group of groupedCategories) {
      const primary = group.rawCategories.find((category) => category.id === group.id) || group.rawCategories[0];
      const aliasIds = group.aliasIds.filter((id) => id !== group.id);
      const aliasNames = Array.from(new Set(
        group.rawCategories
          .map((category) => cleanExamCategoryName(category.name))
          .filter(Boolean)
      )).filter((name) => name !== group.name);

      const shouldNormalizePrimary = !primary ||
        cleanExamCategoryName(primary.name) !== group.name ||
        normalizeExamCategoryName(primary.normalizedName || primary.name) !== group.normalizedName;

      if (!shouldNormalizePrimary && aliasIds.length === 0) {
        continue;
      }

      const batch = writeBatch(db);
      batch.set(doc(db, 'examCategories', group.id), toStoredExamCategory(group), { merge: true });

      subjectDocs.forEach((subjectDoc) => {
        const subjectData = subjectDoc.data() as Category;
        const parentExamId = subjectData.parentExamId || null;

        if (!parentExamId) {
          return;
        }

        if (parentExamId === group.id || aliasIds.includes(parentExamId)) {
          const nextUpdates: Record<string, string> = {};

          if (parentExamId !== group.id) {
            nextUpdates.parentExamId = group.id;
          }

          if (subjectData.parentExamName !== group.name) {
            nextUpdates.parentExamName = group.name;
          }

          if (Object.keys(nextUpdates).length > 0) {
            batch.update(subjectDoc.ref, nextUpdates);
          }
        }
      });

      aliasIds.forEach((aliasId) => {
        batch.delete(doc(db, 'examCategories', aliasId));
      });

      await batch.commit();

      for (const aliasName of aliasNames) {
        const testsSnap = await getDocs(query(collection(db, 'tests'), where('examCategory', '==', aliasName)));

        if (!testsSnap.empty) {
          const testsBatch = writeBatch(db);

          testsSnap.docs.forEach((testDoc) => {
            if (touchedTestIds.has(testDoc.id)) {
              return;
            }

            touchedTestIds.add(testDoc.id);
            testsBatch.update(testDoc.ref, { examCategory: group.name });
          });

          await testsBatch.commit();
        }

        const patternsSnap = await getDocs(query(collection(db, 'examPatterns'), where('category', '==', aliasName)));

        if (!patternsSnap.empty) {
          const patternsBatch = writeBatch(db);

          patternsSnap.docs.forEach((patternDoc) => {
            if (touchedPatternIds.has(patternDoc.id)) {
              return;
            }

            touchedPatternIds.add(patternDoc.id);
            patternsBatch.update(patternDoc.ref, { category: group.name });
          });

          await patternsBatch.commit();
        }
      }
    }

    const syncedCategories = groupedCategories.map(({ rawCategories, aliasIds, ...group }) => group);
    await setDoc(examCategoryRegistryRef, {
      entries: buildExamCategoryRegistryEntries(syncedCategories),
      updatedAt: new Date().toISOString()
    });

    setCategories((prev) => prev.map((category) => {
      if (!category.parentExamId) {
        return category;
      }

      const parentExamGroup = groupedCategories.find((group) => group.aliasIds.includes(category.parentExamId));

      if (!parentExamGroup) {
        return category;
      }

      return {
        ...category,
        parentExamId: parentExamGroup.id,
        parentExamName: parentExamGroup.name
      };
    }));

    if (duplicateGroups.length > 0) {
      showToast('Duplicate exam categories were merged automatically.');
    }

    return syncedCategories;
  };

  const handleDeleteExamCategory = async (examCategory: ExamCategory) => {
    const linkedSubjects = categories.filter((category) => category.parentExamId === examCategory.id);

    if (linkedSubjects.length > 0) {
      showToast('Delete blocked: move or remove linked subjects first.');
      return;
    }

    const testsSnap = await getDocs(query(collection(db, 'tests'), where('examCategory', '==', examCategory.name), limit(1)));

    if (!testsSnap.empty) {
      showToast('Delete blocked: tests are still linked to this exam category.');
      return;
    }

    try {
      await runTransaction(db, async (transaction) => {
        const registrySnap = await transaction.get(examCategoryRegistryRef);
        const registryEntries = {
          ...(((registrySnap.exists() ? registrySnap.data()?.entries : null) as Record<string, string> | null) || {})
        };
        delete registryEntries[getExamCategoryRegistryKey(examCategory.name)];

        // All reads must come before all writes in a Firestore transaction
        transaction.set(examCategoryRegistryRef, {
          entries: registryEntries,
          updatedAt: new Date().toISOString()
        });
        transaction.delete(doc(db, 'examCategories', examCategory.id));
      });

      setExamCategories((prev) => prev.filter((category) => category.id !== examCategory.id));
      if (aiSelectedExamId === examCategory.id) {
        setAiSelectedExamId('all');
        setAiTargetExam('');
      }
      if (selectedExamForSubject === examCategory.id) {
        setSelectedExamForSubject('all');
      }

      if (examCategory.iconUrl && examCategory.iconUrl.includes('supabase.co')) {
        try {
          const oldPath = examCategory.iconUrl.split('/').pop();
          if (oldPath) {
            await supabase.storage.from('avatars').remove([`avatars/${oldPath}`]);
          }
        } catch (deleteError) {
          console.warn('Failed to delete category icon during deletion', deleteError);
        }
      }

      showToast('Exam category deleted successfully.');
    } catch (error) {
      console.error('Error deleting exam category', error);
      handleFirestoreError(error, OperationType.DELETE, `examCategories/${examCategory.id}`);
    }
  };

  const handleSaveExamCategory = async () => {
    if (!editingExamCategory) {
      return;
    }

    const cleanedName = cleanExamCategoryName(editingExamCategory.name);
    const normalizedName = normalizeExamCategoryName(cleanedName);

    if (!cleanedName) {
      showToast('Please enter a valid exam category name.');
      return;
    }

    const duplicateExists = examCategories.some((category) =>
      category.id !== editingExamCategory.id &&
      normalizeExamCategoryName(category.name) === normalizedName
    );

    if (duplicateExists) {
      showToast(`${cleanedName} already exists.`);
      return;
    }

    const previousCategory = examCategories.find((category) => category.id === editingExamCategory.id) || editingExamCategory;
    const previousRegistryKey = getExamCategoryRegistryKey(previousCategory.name);
    const nextRegistryKey = getExamCategoryRegistryKey(cleanedName);

    let finalIconUrl = iconPreviewUrl;

    if (selectedIconFile) {
      setIsSavingIcon(true);
      try {
        const compressedFile = await compressImage(selectedIconFile, 20, 200);

        if (editingExamCategory.iconUrl && editingExamCategory.iconUrl.includes('supabase.co')) {
          try {
            const oldPath = editingExamCategory.iconUrl.split('/').pop();
            if (oldPath) {
              await supabase.storage.from('avatars').remove([`avatars/${oldPath}`]);
            }
          } catch (deleteError) {
            console.warn('Failed to delete old category icon', deleteError);
          }
        }

        const fileExt = compressedFile.name.split('.').pop() || 'jpg';
        const fileName = `category_icon_${editingExamCategory.id}_${Date.now()}.${fileExt}`;
        const filePath = `avatars/${fileName}`;

        const { error: uploadError } = await supabase.storage
          .from('avatars')
          .upload(filePath, compressedFile);

        if (uploadError) throw uploadError;

        const { data: { publicUrl } } = supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

        finalIconUrl = publicUrl;
      } catch (err) {
        console.error('Error uploading/compressing icon:', err);
        showToast('Failed to upload category icon.');
        setIsSavingIcon(false);
        return;
      } finally {
        setIsSavingIcon(false);
      }
    } else if (!iconPreviewUrl && editingExamCategory.iconUrl) {
      if (editingExamCategory.iconUrl.includes('supabase.co')) {
        try {
          const oldPath = editingExamCategory.iconUrl.split('/').pop();
          if (oldPath) {
            await supabase.storage.from('avatars').remove([`avatars/${oldPath}`]);
          }
        } catch (deleteError) {
          console.warn('Failed to delete old category icon', deleteError);
        }
      }
      finalIconUrl = null;
    }

    try {
      await runTransaction(db, async (transaction) => {
        const examCategoryRef = doc(db, 'examCategories', editingExamCategory.id);
        const registrySnap = await transaction.get(examCategoryRegistryRef);
        const registryEntries = (registrySnap.exists() ? registrySnap.data()?.entries : null) as Record<string, string> | null;
        const conflictingExamCategoryId = registryEntries?.[nextRegistryKey];

        if (conflictingExamCategoryId && conflictingExamCategoryId !== editingExamCategory.id) {
          throw new Error('duplicate-exam-category');
        }

        transaction.update(examCategoryRef, {
          name: cleanedName,
          normalizedName,
          isPublished: editingExamCategory.isPublished !== false,
          usersCountOverride: typeof editingExamCategory.usersCountOverride === 'number' ? editingExamCategory.usersCountOverride : null,
          languages: editingExamCategory.languages?.trim() || null,
          iconUrl: finalIconUrl
        });

        const nextRegistryEntries = { ...(registryEntries || {}) };

        if (previousRegistryKey && previousRegistryKey !== nextRegistryKey) {
          delete nextRegistryEntries[previousRegistryKey];
        }

        nextRegistryEntries[nextRegistryKey] = editingExamCategory.id;

        transaction.set(examCategoryRegistryRef, {
          entries: nextRegistryEntries,
          updatedAt: new Date().toISOString()
        });
      });

      if (previousCategory.name !== cleanedName) {
        const subjectsSnap = await getDocs(query(collection(db, 'categories'), where('parentExamId', '==', editingExamCategory.id)));

        if (!subjectsSnap.empty) {
          const subjectsBatch = writeBatch(db);
          subjectsSnap.docs.forEach((subjectDoc) => {
            subjectsBatch.update(subjectDoc.ref, { parentExamName: cleanedName });
          });
          await subjectsBatch.commit();
        }

        const testsSnap = await getDocs(query(collection(db, 'tests'), where('examCategory', '==', previousCategory.name)));

        if (!testsSnap.empty) {
          const testsBatch = writeBatch(db);
          testsSnap.docs.forEach((testDoc) => {
            testsBatch.update(testDoc.ref, { examCategory: cleanedName });
          });
          await testsBatch.commit();
        }

        const patternsSnap = await getDocs(query(collection(db, 'examPatterns'), where('category', '==', previousCategory.name)));

        if (!patternsSnap.empty) {
          const patternsBatch = writeBatch(db);
          patternsSnap.docs.forEach((patternDoc) => {
            patternsBatch.update(patternDoc.ref, { category: cleanedName });
          });
          await patternsBatch.commit();
        }
      }

      setExamCategories((prev) => prev.map((category) => category.id === editingExamCategory.id ? {
        ...category,
        ...editingExamCategory,
        name: cleanedName,
        normalizedName,
        isPublished: editingExamCategory.isPublished !== false,
        usersCountOverride: typeof editingExamCategory.usersCountOverride === 'number' ? editingExamCategory.usersCountOverride : undefined,
        languages: editingExamCategory.languages?.trim() || undefined,
        iconUrl: finalIconUrl || undefined
      } : category));
      setCategories((prev) => prev.map((category) =>
        category.parentExamId === editingExamCategory.id
          ? { ...category, parentExamName: cleanedName }
          : category
      ));
      setEditingExamCategory(null);
      showToast('Exam category updated successfully.');
    } catch (error) {
      console.error('Error updating exam category', error);

      if (error instanceof Error && error.message === 'duplicate-exam-category') {
        showToast(`${cleanedName} already exists.`);
        return;
      }

      handleFirestoreError(error, OperationType.UPDATE, `examCategories/${editingExamCategory.id}`);
    }
  };

  const handleAdminWalletAction = async () => {
    if (!walletModalUser || walletCoinAmount <= 0) return;

    setIsAddingCoins(true);
    try {
      const userRef = doc(db, 'users', walletModalUser.userId);
      const transactionRef = doc(collection(db, 'transactions'));

      await runTransaction(db, async (txn) => {
        const userSnap = await txn.get(userRef);
        if (!userSnap.exists()) throw new Error('User not found');
        const currentCoins = userSnap.data().coins || 0;

        // Validation for deduction
        if (walletActionType === 'deduct' && currentCoins < walletCoinAmount) {
          throw new Error('Insufficient balance for deduction');
        }

        const userData = userSnap.data();
        const currentTotalEarned = userData.totalEarned || 0;
        const currentTotalSpent = userData.totalSpent || 0;
        const newBalance = walletActionType === 'add' ? currentCoins + walletCoinAmount : currentCoins - walletCoinAmount;
        const updateData: any = { coins: newBalance };
        if (walletActionType === 'add') {
          updateData.totalEarned = currentTotalEarned + walletCoinAmount;
        } else {
          updateData.totalSpent = currentTotalSpent + walletCoinAmount;
        }

        txn.update(userRef, updateData);
        txn.set(transactionRef, {
          userId: walletModalUser.userId,
          amount: walletCoinAmount,
          type: walletActionType === 'add' ? 'earn' : 'spend',
          category: walletActionType === 'add' ? 'admin_credit' : 'admin_debit',
          note: walletReason.trim() || (walletActionType === 'add' ? 'Admin credit' : 'Admin adjustment'),
          timestamp: serverTimestamp(),
          currentBalance: newBalance
        });
      });

      // Update local users state immediately
      setUsers(prev => prev.map(u =>
        u.userId === walletModalUser.userId
          ? {
            ...u, coins: walletActionType === 'add'
              ? (u.coins || 0) + walletCoinAmount
              : (u.coins || 0) - walletCoinAmount,
            totalEarned: walletActionType === 'add' ? (u.totalEarned || 0) + walletCoinAmount : u.totalEarned,
            totalSpent: walletActionType === 'deduct' ? (u.totalSpent || 0) + walletCoinAmount : u.totalSpent
          }
          : u
      ));

      showToast(`✅ ${walletCoinAmount} coins ${walletActionType === 'add' ? 'added to' : 'deducted from'} ${walletModalUser.name}'s wallet!`, 'success');
      setWalletModalUser(null);
      setWalletCoinAmount(100);
      setWalletReason('');
      setWalletActionType('add'); // Reset to add
    } catch (error: any) {
      console.error('Admin wallet action failed:', error);
      showToast(error.message || 'Failed to update wallet. Please try again.', 'error');
    } finally {
      setIsAddingCoins(false);
    }
  };

  const handleUpdateUserStatus = async (userId: string, status: 'active' | 'suspended' | 'banned', reason?: string, duration?: string) => {
    setIsSuspending(true);
    try {
      let banUntil = null;
      if (status !== 'active' && duration && duration !== 'permanent') {
        const now = new Date();
        if (duration === '24h') now.setHours(now.getHours() + 24);
        else if (duration === '72h') now.setHours(now.getHours() + 72);
        else if (duration === '7d') now.setDate(now.getDate() + 7);
        banUntil = now.toISOString();
      }

      await updateDoc(doc(db, 'users', userId), {
        status,
        banReason: reason || '',
        banUntil: banUntil,
        updatedAt: serverTimestamp()
      });

      // Update local state
      setUsers(prev => prev.map(u => u.userId === userId ? { ...u, status, banReason: reason || '', banUntil } : u));

      showToast(`User account ${status === 'active' ? 'activated' : 'suspended'} successfully`, 'success');
      setSuspensionModalUser(null);
      setSuspensionReason('');
      setSuspensionDuration('24h');
    } catch (error) {
      console.error("Error updating user status:", error);
      showToast('Failed to update user status', 'error');
    } finally {
      setIsSuspending(false);
    }
  };

  const handleToggleWheelStatus = async () => {
    if (!wheelConfig) return;
    const newStatus = !wheelConfig.isActive;
    setWheelConfig({ ...wheelConfig, isActive: newStatus });

    try {
      await updateDoc(doc(db, 'configs', 'lucky_wheel'), {
        isActive: newStatus,
        lastUpdated: serverTimestamp()
      });
      showToast(`Wheel is now ${newStatus ? 'Online' : 'Offline'}`, 'success');
    } catch (err) {
      console.error("Error toggling wheel status:", err);
      showToast('Failed to update wheel status', 'error');
      // Rollback
      setWheelConfig({ ...wheelConfig, isActive: !newStatus });
    }
  };

  const handleSaveWheelConfig = async () => {
    if (!wheelConfig) return;
    setIsSavingWheelConfig(true);
    try {
      await setDoc(doc(db, 'configs', 'lucky_wheel'), {
        ...wheelConfig,
        lastUpdated: serverTimestamp()
      });
      showToast('Lucky Wheel settings saved!', 'success');
    } catch (err) {
      console.error("Error saving wheel config:", err);
      showToast('Failed to save wheel settings', 'error');
    } finally {
      setIsSavingWheelConfig(false);
    }
  };

  const handleAddSlice = () => {
    if (!wheelConfig) return;
    const newSlice: WheelSlice = { label: 'New Reward', value: 10, type: 'coins', color: '#10b981', probability: 5 };
    setWheelConfig({ ...wheelConfig, slices: [...wheelConfig.slices, newSlice] });
  };

  const handleDeleteSlice = (index: number) => {
    if (!wheelConfig) return;
    const updatedSlices = [...wheelConfig.slices];
    updatedSlices.splice(index, 1);
    setWheelConfig({ ...wheelConfig, slices: updatedSlices });
  };

  const fetchUsers = async (reset = false) => {
    if (isLoadingUsers || (!hasMoreUsers && !reset)) return;
    setIsLoadingUsers(true);
    try {
      let q;
      const searchLower = userDebouncedSearchTerm.toLowerCase().trim();

      if (searchLower) {
        // Simple prefix search for email
        q = query(
          collection(db, 'users'),
          where('email', '>=', searchLower),
          where('email', '<=', searchLower + '\uf8ff'),
          limit(20)
        );
      } else {
        q = query(collection(db, 'users'), orderBy('createdAt', 'desc'), limit(20));
      }

      if (!reset && userLastDoc) {
        q = query(q, startAfter(userLastDoc));
      }

      const snap = await getDocs(q);
      const fetchedUsers = snap.docs.map(doc => doc.data() as UserProfile);

      if (reset) {
        setUsers(fetchedUsers);
      } else {
        setUsers(prev => [...prev, ...fetchedUsers]);
      }

      setUserLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMoreUsers(snap.docs.length === 20);
    } catch (error) {
      console.error('Error fetching users', error);
      handleFirestoreError(error, OperationType.LIST, 'users');
    } finally {
      setIsLoadingUsers(false);
    }
  };

  useEffect(() => {
    const timer = setTimeout(() => {
      setUserDebouncedSearchTerm(userSearchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [userSearchTerm]);

  useEffect(() => {
    if (activeTab === 'users') {
      fetchUsers(true);
    }
  }, [activeTab, userDebouncedSearchTerm]);

  useEffect(() => {
    const q = query(collection(db, 'examPatterns'), orderBy('createdAt', 'desc'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setExamPatterns(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as ExamPattern)));
    }, (error) => {
      console.error('Error fetching patterns', error);
      handleFirestoreError(error, OperationType.LIST, 'examPatterns');
    });
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearchTerm(searchTerm);
    }, 500);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  const toggleCategory = (category: string) => {
    setExpandedCategories(prev => ({
      ...prev,
      [category]: !prev[category]
    }));
  };

  // AI Creator State
  const [aiInputType, setAiInputType] = useState<'topic' | 'video' | 'file'>('topic');
  const [aiTopic, setAiTopic] = useState('');
  const [aiSubjectTopic, setAiSubjectTopic] = useState('');
  const [aiVideoUrl, setAiVideoUrl] = useState('');
  const [aiFile, setAiFile] = useState<File | null>(null);
  const [aiQuestionCount, setAiQuestionCount] = useState(10);
  const [aiDifficulty, setAiDifficulty] = useState<'easy' | 'medium' | 'hard'>('medium');
  const [aiCategory, setAiCategory] = useState('');
  const [aiTargetExam, setAiTargetExam] = useState('');
  const [aiTestTitle, setAiTestTitle] = useState('');
  const [newTest, setNewTest] = useState<Partial<Test>>({
    title: '',
    examCategory: '',
    testMode: 'mock',
    category: '',
    topic: '',
    examType: 'Mock Test',
    duration: 60,
    totalQuestions: 100,
    negativeMarking: 0.25,
    isPremium: false,
    unlockPrice: 0,
    status: 'unpublished'
  });
  const [isGeneratingCA, setIsGeneratingCA] = useState(false);

  useEffect(() => {
    const fetchAuthSettings = async () => {
      try {
        const docSnap = await getDoc(doc(db, 'configs', 'auth_settings'));
        if (docSnap.exists()) {
          setRequireEmailVerification(docSnap.data().requireEmailVerification || false);
        }
      } catch (error) {
        console.error("Error fetching auth settings:", error);
      }
    };
    fetchAuthSettings();
  }, []);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const categoriesSnap = await getDocs(collection(db, 'categories'));
        const fetchedCategories = categoriesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() } as Category));
        setCategories(fetchedCategories);

        if (fetchedCategories.length === 0) {
          const defaults = ['SSC', 'Banking', 'Railway', 'UPSC'];
          const batch = writeBatch(db);
          const newCats: Category[] = [];
          for (const name of defaults) {
            const newDoc = doc(collection(db, 'categories'));
            const catData = { name, topics: [], createdAt: new Date().toISOString() };
            batch.set(newDoc, catData);
            newCats.push({ id: newDoc.id, ...catData });
          }
          await batch.commit();
          setCategories(newCats);
        } else {
          // Normalize older categories to have `topics` array if missing
          const normalized = fetchedCategories.map(c => ({
            ...c,
            topics: c.topics || []
          }));
          setCategories(normalized);
        }
      } catch (error) {
        console.error('Error fetching categories', error);
      }
    };
    const fetchExamCategories = async () => {
      try {
        const snap = await getDocs(collection(db, 'examCategories'));
        const fetched = snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as ExamCategory));

        if (fetched.length === 0) {
          const seededCategories = await seedDefaultExamCategories();
          setExamCategories(seededCategories);
        } else {
          const syncedCategories = await syncFetchedExamCategories(fetched);
          setExamCategories(syncedCategories);
        }
      } catch (error) {
        console.error('Error fetching exam categories', error);
      }
    };

    const fetchInitialData = async () => {
      await fetchCategories();
      await fetchExamCategories();
    };

    fetchInitialData();
  }, []);

  const fetchTests = async (reset = false) => {
    if (isLoadingTests || (!hasMoreTests && !reset)) return;
    setIsLoadingTests(true);
    try {
      let q;
      const searchLower = debouncedSearchTerm.toLowerCase().trim();

      if (searchLower) {
        q = query(
          collection(db, 'tests'),
          where('title_lowercase', '>=', searchLower),
          where('title_lowercase', '<=', searchLower + '\uf8ff'),
          orderBy('title_lowercase')
        );
      } else {
        q = query(collection(db, 'tests'), orderBy('createdAt', 'desc'));
      }

      // Add category filter if not 'all'
      if (testFilter !== 'all') {
        q = query(q, where('examCategory', '==', testFilter));
      }

      if (!reset && testLastDoc) {
        q = query(q, startAfter(testLastDoc));
      }

      q = query(q, limit(20));

      const snap = await getDocs(q);
      const testsData = snap.docs.map(doc => ({
        testId: doc.id,
        ...(doc.data() as object)
      })) as Test[];

      if (reset) {
        setTests(testsData);
      } else {
        setTests(prev => [...prev, ...testsData]);
      }

      setTestLastDoc(snap.docs[snap.docs.length - 1] || null);
      setHasMoreTests(snap.docs.length === 20);
    } catch (error) {
      console.error('Error fetching tests', error);
      if (error instanceof Error && error.message.includes('permissions')) {
        handleFirestoreError(error, OperationType.LIST, 'tests');
      }
    } finally {
      setIsLoadingTests(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'tests') {
      fetchTests(true);
    }
  }, [activeTab, debouncedSearchTerm, testFilter]);

  const handleCreateCategory = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCategoryName.trim()) return;
    setIsAddingCategory(true);
    try {
      const parentExam = selectedExamForSubject !== 'all' ? findExamCategoryGroupById(examCategories, selectedExamForSubject) : null;

      const catData = {
        name: newCategoryName.trim(),
        topics: [], // Initialize empty child topics
        createdAt: new Date().toISOString(),
        parentExamId: parentExam?.id || null,
        parentExamName: parentExam?.name || null
      };

      const docRef = await addDoc(collection(db, 'categories'), catData as any);
      setCategories(prev => [...prev, { id: docRef.id, ...catData } as any]);
      setNewCategoryName('');
    } catch (error) {
      console.error('Error adding category', error);
      handleFirestoreError(error, OperationType.CREATE, 'categories');
    } finally {
      setIsAddingCategory(false);
    }
  };

  const handleCreateExamCategory = async (name: string) => {
    const cleanedName = cleanExamCategoryName(name);
    const normalizedName = normalizeExamCategoryName(cleanedName);

    if (!cleanedName) return;

    const duplicateExists = examCategories.some(
      (category) => normalizeExamCategoryName(category.name) === normalizedName
    );

    if (duplicateExists) {
      showToast(`${cleanedName} already exists.`);
      return false;
    }

    try {
      const createdAt = new Date().toISOString();
      const examCategoryId = getExamCategoryDocumentId(cleanedName);

      await runTransaction(db, async (transaction) => {
        const examCategoryRef = doc(db, 'examCategories', examCategoryId);
        const registrySnap = await transaction.get(examCategoryRegistryRef);
        const registryEntries = (registrySnap.exists() ? registrySnap.data()?.entries : null) as Record<string, string> | null;
        const registryKey = getExamCategoryRegistryKey(cleanedName);
        const conflictingExamCategoryId = registryEntries?.[registryKey];

        if (conflictingExamCategoryId) {
          throw new Error('duplicate-exam-category');
        }

        const existingExamCategorySnap = await transaction.get(examCategoryRef);

        if (existingExamCategorySnap.exists()) {
          throw new Error('duplicate-exam-category');
        }

        transaction.set(examCategoryRef, {
          name: cleanedName,
          normalizedName,
          createdAt
        });

        transaction.set(examCategoryRegistryRef, {
          entries: {
            ...(registryEntries || {}),
            [registryKey]: examCategoryId
          },
          updatedAt: createdAt
        });
      });

      setExamCategories(prev => [...prev, { id: examCategoryId, name: cleanedName, normalizedName, createdAt }]);
      showToast('Exam category created successfully.');
      return true;
    } catch (error) {
      console.error('Error adding exam category', error);

      if (error instanceof Error && error.message === 'duplicate-exam-category') {
        showToast(`${cleanedName} already exists.`);
        return false;
      }

      handleFirestoreError(error, OperationType.CREATE, 'examCategories');
      return false;
    }
  };

  const handleDeleteCategory = async (id: string) => {
    setIsDeleting(true);
    try {
      await deleteDoc(doc(db, 'categories', id));
      setCategories(prev => prev.filter(c => c.id !== id));
      setDeleteConfirm(null);
      showToast('Subject deleted successfully.');
    } catch (error) {
      console.error('Error deleting category', error);
      handleFirestoreError(error, OperationType.DELETE, `categories/${id}`);
    } finally {
      setIsDeleting(false);
    }
  };

  const handleExportTest = async (test: Test, format: 'txt' | 'docx' | 'pdf') => {
    setIsExporting(test.testId);
    try {
      const qSnap = await getDocs(collection(db, 'tests', test.testId, 'questions'));
      const testQuestions = qSnap.docs.map(d => d.data() as Question);

      if (testQuestions.length === 0) {
        showToast('This test has no questions to export.');
        return;
      }

      if (format === 'txt') {
        let content = `${test.title}\n`;
        content += `Category: ${test.category}\n`;
        content += `Duration: ${test.duration} minutes\n`;
        content += `Total Questions: ${testQuestions.length}\n\n`;
        content += `------------------------------------------\n\n`;

        testQuestions.forEach((q, idx) => {
          content += `Q${idx + 1}: ${q.questionTextEnglish}\n`;
          if (q.questionTextHindi) content += `हिन्दी: ${q.questionTextHindi}\n`;

          q.options.forEach((opt, oIdx) => {
            content += `   (${String.fromCharCode(65 + oIdx)}) ${opt.textEnglish}`;
            if (opt.textHindi) content += ` / ${opt.textHindi}`;
            content += '\n';
          });

          content += `Correct Answer: (${String.fromCharCode(65 + q.correctAnswer)})\n`;
          content += `Explanation: ${q.explanation || 'N/A'}\n`;
          if (q.explanationHindi) content += `व्याख्या: ${q.explanationHindi}\n`;
          content += `\n`;
        });

        const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
        saveAs(blob, `${test.title.replace(/\s+/g, '_')}.txt`);
      } else if (format === 'docx') {
        const doc = new Document({
          sections: [{
            properties: {},
            children: [
              new Paragraph({
                text: test.title,
                heading: HeadingLevel.HEADING_1,
                alignment: AlignmentType.CENTER,
              }),
              new Paragraph({
                children: [
                  new TextRun({ text: `Category: ${test.category}`, bold: true }),
                  new TextRun({ text: ` | Duration: ${test.duration} mins`, bold: true }),
                ],
                alignment: AlignmentType.CENTER,
              }),
              new Paragraph({ text: "", spacing: { after: 200 } }),
              ...testQuestions.flatMap((q, idx) => [
                new Paragraph({
                  children: [
                    new TextRun({ text: `Q${idx + 1}: `, bold: true }),
                    new TextRun({ text: q.questionTextEnglish }),
                  ],
                  spacing: { before: 200 },
                }),
                ...(q.questionTextHindi ? [new Paragraph({ children: [new TextRun({ text: q.questionTextHindi, italics: true })] })] : []),
                ...q.options.map((opt, oIdx) => new Paragraph({
                  text: `(${String.fromCharCode(65 + oIdx)}) ${opt.textEnglish}${opt.textHindi ? ` / ${opt.textHindi}` : ''}`,
                  indent: { left: 720 },
                })),
                new Paragraph({
                  children: [
                    new TextRun({ text: "Correct Answer: ", bold: true }),
                    new TextRun({ text: `(${String.fromCharCode(65 + q.correctAnswer)})` }),
                  ],
                  spacing: { before: 100 },
                }),
                new Paragraph({
                  children: [
                    new TextRun({ text: "Explanation: ", bold: true }),
                    new TextRun({ text: q.explanation || 'N/A' }),
                  ],
                }),
                ...(q.explanationHindi ? [new Paragraph({ children: [new TextRun({ text: `व्याख्या: ${q.explanationHindi}`, italics: true })] })] : []),
              ]),
            ],
          }],
        });

        const blob = await Packer.toBlob(doc);
        saveAs(blob, `${test.title.replace(/\s+/g, '_')}.docx`);
      } else if (format === 'pdf') {
        setExportingTestData({ test, questions: testQuestions });

        // Wait for rendering
        setTimeout(async () => {
          const element = document.getElementById('pdf-export-content');
          if (!element) {
            setIsExporting(null);
            setExportingTestData(null);
            return;
          }

          try {
            const canvas = await html2canvas(element, {
              scale: 2,
              useCORS: true,
              logging: false,
              backgroundColor: '#ffffff'
            });

            const imgData = canvas.toDataURL('image/png');
            const pdf = new jsPDF('p', 'mm', 'a4');
            const imgProps = pdf.getImageProperties(imgData);
            const pdfWidth = pdf.internal.pageSize.getWidth();
            const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

            let heightLeft = pdfHeight;
            let position = 0;
            const pageHeight = pdf.internal.pageSize.getHeight();

            pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, pdfHeight);
            heightLeft -= pageHeight;

            while (heightLeft >= 0) {
              position = heightLeft - pdfHeight;
              pdf.addPage();
              pdf.addImage(imgData, 'PNG', 0, position, pdfWidth, pdfHeight);
              heightLeft -= pageHeight;
            }

            pdf.save(`${test.title.replace(/\s+/g, '_')}.pdf`);
          } catch (err) {
            console.error('PDF generation error:', err);
            showToast('Failed to generate PDF.');
          } finally {
            setIsExporting(null);
            setExportingTestData(null);
          }
        }, 1000);
        return; // Exit early as PDF is handled in timeout
      }
    } catch (error) {
      console.error('Export failed', error);
      showToast('Failed to export test.');
    } finally {
      setIsExporting(null);
    }
  };
  const handleDownloadSample = () => {
    const sample = [
      {
        title: "SSC CGL Mock 01",
        category: "SSC",
        examType: "Mock Test",
        duration: 60,
        totalQuestions: 1,
        negativeMarking: 0.25,
        isPremium: false,
        questions: [
          {
            questionTextEnglish: "Who is known as the Father of the Nation in India?",
            questionTextHindi: "भारत में राष्ट्रपिता के रूप में किसे जाना जाता है?",
            options: [
              { textEnglish: "Mahatma Gandhi", textHindi: "महात्मा गांधी" },
              { textEnglish: "Jawaharlal Nehru", textHindi: "जवाहरलाल नेहरू" },
              { textEnglish: "Subhash Chandra Bose", textHindi: "सुभाष चंद्र बोस" },
              { textEnglish: "Sardar Patel", textHindi: "सरदार पटेल" }
            ],
            correctAnswer: 0,
            explanation: "Mahatma Gandhi is known as the Father of the Nation.",
            subject: "General Awareness",
            topic: "History",
            difficultyLevel: "easy"
          }
        ]
      }
    ];
    const blob = new Blob([JSON.stringify(sample, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'test_sample.json';
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleImportJson = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const text = await file.text();
      const data = JSON.parse(text);
      const testsToImport = Array.isArray(data) ? data : [data];
      const importedCategories: string[] = [];

      for (const testData of testsToImport) {
        const { questions: testQuestions, ...testInfo } = testData;

        // Create test
        const testRef = await addDoc(collection(db, 'tests'), {
          ...testInfo,
          status: 'unpublished',
          totalQuestions: testQuestions?.length || testInfo.totalQuestions || 0,
          title_lowercase: testInfo.title?.toLowerCase() || '',
          createdAt: new Date().toISOString(),
          createdBy: 'admin'
        });

        if (testInfo.category) {
          importedCategories.push(testInfo.category);
        }

        // Add questions in batches of 500
        if (testQuestions && Array.isArray(testQuestions)) {
          for (let i = 0; i < testQuestions.length; i += 500) {
            const batch = writeBatch(db);
            const chunk = testQuestions.slice(i, i + 500);
            for (const q of chunk) {
              const qRef = doc(collection(db, 'tests', testRef.id, 'questions'));
              batch.set(qRef, {
                ...q,
                questionId: qRef.id,
                testId: testRef.id
              });
            }
            await batch.commit();
          }
        }
      }

      // Refresh tests
      const qSnap = await getDocs(collection(db, 'tests'));
      setTests(qSnap.docs.map(d => ({ testId: d.id, ...d.data() } as Test)));

      // Expand imported categories
      setExpandedCategories(prev => {
        const next = { ...prev };
        importedCategories.forEach(cat => {
          next[cat] = true;
        });
        return next;
      });

      showToast('Tests imported successfully!');
    } catch (error) {
      console.error('Import failed', error);
      showToast('Failed to import tests. Check JSON format.');
    }
    // Reset input
    e.target.value = '';
  };

  useEffect(() => {
    const testConnection = async () => {
      try {
        await getDocFromServer(doc(db, 'test', 'connection'));
      } catch (error) {
        if (error instanceof Error && error.message.includes('the client is offline')) {
          console.error("Please check your Firebase configuration. ");
        }
      }
    };
    testConnection();
  }, []);

  useEffect(() => {
    if (managingQuestionsFor) {
      const fetchQuestions = async () => {
        try {
          const qSnap = await getDocs(collection(db, 'tests', managingQuestionsFor.testId, 'questions'));
          setQuestions(qSnap.docs.map(d => {
            const data = d.data() as any;
            // Normalize options to bilingual structure
            const normalizedOptions = data.options?.map((opt: any) => ({
              textEnglish: opt.textEnglish || opt.text || '',
              textHindi: opt.textHindi || '',
              image: opt.image || ''
            })) || [];
            return { questionId: d.id, ...data, options: normalizedOptions } as Question;
          }));
        } catch (error) {
          console.error('Error fetching questions', error);
          handleFirestoreError(error, OperationType.LIST, `tests/${managingQuestionsFor.testId}/questions`);
        }
      };
      fetchQuestions();
    }
  }, [managingQuestionsFor]);

  // App Banner Logic
  const fetchBanners = async () => {
    setIsFetchingBanners(true);
    try {
      const q = query(collection(db, 'app_banners'), orderBy('createdAt', 'desc'));
      const snap = await getDocs(q);
      setBanners(snap.docs.map(doc => ({ id: doc.id, ...doc.data() } as AppBanner)));
    } catch (error) {
      console.error("Error fetching banners:", error);
      showToast('Error loading banners', 'error');
    } finally {
      setIsFetchingBanners(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'banners') {
      fetchBanners();
    }
  }, [activeTab]);

  const handleSaveBanner = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!bannerFile && !newBanner.imageUrl && !editingBanner) {
      showToast('Please select an image', 'error');
      return;
    }
    setIsUploadingBanner(true);
    try {
      let imageUrl = newBanner.imageUrl || (editingBanner?.imageUrl || '');

      if (bannerFile) {
        const fileExt = bannerFile.name.split('.').pop();
        const fileName = `${Math.random().toString(36).substring(2)}_${Date.now()}.${fileExt}`;
        const filePath = `app_banners/${fileName}`;

        const { error: uploadError } = await supabase.storage
          .from('app-banners')
          .upload(filePath, bannerFile);

        if (uploadError) throw uploadError;

        const { data: { publicUrl } } = supabase.storage
          .from('app-banners')
          .getPublicUrl(filePath);

        imageUrl = publicUrl;
      }

      const bannerData = {
        ...newBanner,
        imageUrl,
        clicks: editingBanner ? (editingBanner.clicks || 0) : 0,
        updatedAt: new Date().toISOString()
      };

      if (editingBanner) {
        await updateDoc(doc(db, 'app_banners', editingBanner.id), bannerData);
        setBanners(prev => prev.map(b => b.id === editingBanner.id ? { ...b, ...bannerData } : b));
        showToast('Banner updated successfully!', 'success');
      } else {
        const docRef = await addDoc(collection(db, 'app_banners'), {
          ...bannerData,
          createdAt: new Date().toISOString()
        });
        setBanners(prev => [{ id: docRef.id, ...bannerData, createdAt: new Date().toISOString() } as AppBanner, ...prev]);
        showToast('Banner created successfully!', 'success');
      }

      setShowAddBanner(false);
      setEditingBanner(null);
      setNewBanner({ title: '', link: '', isActive: true, priority: 0 });
      setBannerFile(null);
    } catch (error) {
      console.error("Error saving banner:", error);
      showToast('Failed to save banner', 'error');
    } finally {
      setIsUploadingBanner(false);
    }
  };

  const handleSearchSpotlightUser = async () => {
    if (!spotlightSearchTerm.trim()) {
      showToast('Please enter a name, email or UID', 'error');
      return;
    }
    setIsSearchingSpotlight(true);
    setSpotlightFoundUser(null);
    try {
      let foundUser: UserProfile | null = null;
      const term = spotlightSearchTerm.trim();

      // Helper: search by name prefix (tries original case + capitalized)
      const searchByName = async (searchTerm: string): Promise<UserProfile | null> => {
        const variants = [
          searchTerm,
          searchTerm.charAt(0).toUpperCase() + searchTerm.slice(1),
          searchTerm.toLowerCase(),
        ];
        for (const v of [...new Set(variants)]) {
          const q = query(
            collection(db, 'users'),
            where('name', '>=', v),
            where('name', '<=', v + '\uf8ff'),
            limit(1)
          );
          const snap = await getDocs(q);
          if (!snap.empty) return { userId: snap.docs[0].id, ...snap.docs[0].data() } as UserProfile;
        }
        return null;
      };

      if (term.includes('@')) {
        // Search by Email (always lowercase)
        const q = query(collection(db, 'users'), where('email', '==', term.toLowerCase()), limit(1));
        const snap = await getDocs(q);
        if (!snap.empty) foundUser = { userId: snap.docs[0].id, ...snap.docs[0].data() } as UserProfile;
      } else if (term.length === 28 && !term.includes(' ')) {
        // Likely a Firestore UID (28 chars, no spaces)
        const docRef = doc(db, 'users', term);
        const snap = await getDoc(docRef);
        if (snap.exists()) {
          foundUser = { userId: snap.id, ...snap.data() } as UserProfile;
        } else {
          foundUser = await searchByName(term);
        }
      } else {
        // Search by name
        foundUser = await searchByName(term);
        // Fallback: try as UID if name not found
        if (!foundUser && !term.includes(' ')) {
          const docRef = doc(db, 'users', term);
          const snap = await getDoc(docRef);
          if (snap.exists()) foundUser = { userId: snap.id, ...snap.data() } as UserProfile;
        }
      }

      if (foundUser) {
        setSpotlightFoundUser(foundUser);
        showToast('User found successfully!', 'success');
      } else {
        showToast('No user found with that name, email or UID', 'error');
      }
    } catch (err) {
      console.error('Error searching user:', err);
      showToast('Error searching user', 'error');
    } finally {
      setIsSearchingSpotlight(false);
    }
  };

  const handleSaveSpotlightBanner = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!spotlightFoundUser && !editingBanner) {
      showToast('Please search and select a user', 'error');
      return;
    }
    setIsPublishingSpotlight(true);
    try {
      const bannerData = {
        type: 'spotlight',
        title: `Spotlight: ${editingBanner?.spotlightData?.userName || spotlightFoundUser?.name}`,
        isActive: spotlightData.isActive,
        priority: spotlightData.priority,
        updatedAt: new Date().toISOString(),
        spotlightData: {
          userId: editingBanner?.spotlightData?.userId || spotlightFoundUser?.userId,
          userName: editingBanner?.spotlightData?.userName || spotlightFoundUser?.name,
          profilePhoto: editingBanner?.spotlightData?.profilePhoto || spotlightFoundUser?.profilePhoto || '',
          score: spotlightData.score,
          rank: spotlightData.rank,
          examName: spotlightData.examName,
          message: spotlightData.message
        }
      };

      if (editingBanner) {
        await updateDoc(doc(db, 'app_banners', editingBanner.id), bannerData);
        setBanners(prev => prev.map(b => b.id === editingBanner.id ? { ...b, ...bannerData } as AppBanner : b));
        showToast('Spotlight updated successfully!', 'success');
      } else {
        const docRef = await addDoc(collection(db, 'app_banners'), {
          ...bannerData,
          createdAt: new Date().toISOString()
        });
        setBanners(prev => [{ id: docRef.id, ...bannerData, createdAt: new Date().toISOString() } as AppBanner, ...prev]);
        showToast('Spotlight created successfully!', 'success');
      }

      setShowAddSpotlight(false);
      setEditingBanner(null);
      setSpotlightFoundUser(null);
      setSpotlightSearchTerm('');
      setSpotlightData({ score: '', rank: '', examName: '', message: '', priority: 0, isActive: true });
    } catch (error) {
      console.error("Error saving spotlight:", error);
      showToast('Failed to save spotlight banner', 'error');
    } finally {
      setIsPublishingSpotlight(false);
    }
  };

  const handleDeleteBanner = async (id: string, imageUrl: string) => {
    try {
      // 1. Delete from Firestore
      await deleteDoc(doc(db, 'app_banners', id));

      // 2. Delete from Supabase if it's a supabase URL
      if (imageUrl.includes('supabase.co')) {
        const path = imageUrl.split('/').pop();
        if (path) {
          await supabase.storage.from('app-banners').remove([`app_banners/${path}`]);
        }
      }

      setBanners(prev => prev.filter(b => b.id !== id));
      showToast('Banner deleted successfully');
    } catch (error) {
      console.error("Error deleting banner:", error);
      showToast('Delete failed', 'error');
    }
  };

  const handleToggleBanner = async (banner: AppBanner) => {
    try {
      const newStatus = !banner.isActive;
      await updateDoc(doc(db, 'app_banners', banner.id), { isActive: newStatus });
      setBanners(prev => prev.map(b => b.id === banner.id ? { ...b, isActive: newStatus } : b));
    } catch (error) {
      console.error("Error updating banner:", error);
      showToast('Update failed', 'error');
    }
  };

  const toTitleCase = (str: string) => {
    if (!str) return '';
    return str.replace(/\b\w/g, l => l.toUpperCase());
  };

  const getValidExamCategory = (test: Test) => {
    if (test.examCategory) {
      const norm = normalizeExamCategoryName(test.examCategory);
      const match = examCategories.find(c => normalizeExamCategoryName(c.name) === norm);
      if (match) return match.name;
    }
    if (test.category) {
      const norm = normalizeExamCategoryName(test.category);
      const match = examCategories.find(c => normalizeExamCategoryName(c.name) === norm);
      if (match) return match.name;
    }
    if (test.examType) {
      const norm = normalizeExamCategoryName(test.examType);
      const match = examCategories.find(c => normalizeExamCategoryName(c.name) === norm);
      if (match) return match.name;
    }
    return '';
  };

  const handleAddTest = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (newTest.testMode === 'sectional') {
        if (!newTest.category) {
          showToast('Subject is required for Sectional Test', 'error');
          return;
        }
        if (!newTest.topic) {
          showToast('Topic is required for Sectional Test', 'error');
          return;
        }
      }

      const formattedTitle = toTitleCase(newTest.title);
      const rawData = {
        ...newTest,
        title: formattedTitle,
        title_lowercase: formattedTitle.toLowerCase(),
        subject: newTest.category || '', // Keep subject in sync with category
        updatedAt: new Date().toISOString()
      };

      // Firestore throws on undefined values — strip them out
      const testData = Object.fromEntries(
        Object.entries(rawData).filter(([, v]) => v !== undefined)
      );

      if (editingTest) {
        await setDoc(doc(db, 'tests', editingTest.testId), testData, { merge: true });
        showToast(`Test series "${formattedTitle}" updated successfully`, 'success');

        if (notifyOnSave) {
          const title = testData.isTournament ? '🏆 Tournament Updated!' : '📝 Test Updated!';
          const message = `"${formattedTitle}" has been updated. Start practicing!`;
          await sendPushNotification('global', title, message, {
            testId: editingTest.testId,
            actionUrl: `/dashboard?join=${editingTest.testId}`,
            type: 'test_alert'
          });
        }

        setEditingTest(null);
      } else {
        const testRef = await addDoc(collection(db, 'tests'), {
          ...testData,
          createdAt: new Date().toISOString(),
          createdBy: 'admin'
        });
        showToast(`New test series "${formattedTitle}" created successfully`, 'success');

        if (notifyOnSave) {
          const title = testData.isTournament ? '🏆 New Tournament Live!' : '📝 New Test Available!';
          const message = `Check out "${formattedTitle}" on Rankearn. Start practicing now!`;
          await sendPushNotification('global', title, message, {
            testId: testRef.id,
            actionUrl: `/dashboard?join=${testRef.id}`,
            type: 'test_alert'
          });
        }
      }
      setNotifyOnSave(false);
      setShowAddTest(false);
      setNewTest({
        title: '',
        examCategory: '',
        testMode: 'mock',
        category: '',
        topic: '',
        examType: 'Mock Test',
        duration: 60,
        totalQuestions: 100,
        negativeMarking: 0.25,
        isPremium: false,
        status: 'unpublished',
        leaderboardLimit: undefined,
        winnerCount: undefined,
        isTournament: false,
        isProOnly: false,
        entryFee: 0,
        adminCommissionPercentage: 20,
        scheduledStartTime: undefined,
        scheduledEndTime: undefined
      });
      // Refresh tests or contests based on mode
      if (newTest.isTournament || editingTest?.isTournament || editingTest?.testMode === 'tournament') {
        fetchContests();
      }
      fetchTests(true);
    } catch (error) {
      console.error('Error adding/editing test', error);
      handleFirestoreError(error, editingTest ? OperationType.UPDATE : OperationType.CREATE, 'tests');
    }
  };


  const handleDeclareResults = async (test: Test) => {
    const isActuallyTournament = test.isTournament || test.testMode === 'tournament';
    if (!isActuallyTournament || test.isResultDeclared) {
      console.log("Cannot declare:", { isTournament: test.isTournament, testMode: test.testMode, isResultDeclared: test.isResultDeclared });
      return;
    }

    try {
      showToast('Calculating results...', 'info');
      // 1. Fetch all attempts for this test
      const attemptsRef = collection(db, 'attempts');
      const q = query(attemptsRef, where('testId', '==', test.testId));
      const snap = await getDocs(q);

      const attempts = snap.docs.map(doc => ({ attemptId: doc.id, ...doc.data() } as unknown as Attempt));

      if (attempts.length === 0) {
        // No attempts, just mark as declared to clear it from the pending list
        await updateDoc(doc(db, 'tests', test.testId), {
          isResultDeclared: true,
          prizePoolDistributed: 0,
          totalParticipantsCollected: 0
        });
        setTests(prev => prev.map(t => t.testId === test.testId ? { ...t, isResultDeclared: true } : t));
        showToast('No attempts found. Test marked as declared with 0 participants.', 'success');
        return;
      }

      // 2. Sort attempts (Higher score first, then lower timeTaken)
      attempts.sort((a, b) => {
        if ((b.score || 0) !== (a.score || 0)) {
          return (b.score || 0) - (a.score || 0); // DESC score
        }
        return (a.timeTaken || 0) - (b.timeTaken || 0); // ASC timeTaken
      });

      // 3. Prize Pool Calculation
      const participantsSnap = await getDocs(collection(db, 'tests', test.testId, 'participants'));
      const totalParticipants = participantsSnap.size || attempts.length;

      const entryFee = test.entryFee || 0;
      const totalPool = totalParticipants * entryFee;
      const adminCommission = test.adminCommissionPercentage || 20;
      const netPool = totalPool * (1 - adminCommission / 100);

      // 4. Distribution logic
      // We reward a number of people based on test.winnerCount (default to 10 if not set)
      const wCount = test.winnerCount || 10;

      // Dynamic percentage distribution (example: 1st gets 40%, 2nd 20%, others split remainder)
      const getPercent = (rank: number, count: number) => {
        if (rank === 1) return 0.40;
        if (count === 1) return 1.0;
        if (rank === 2) return 0.20;
        // Split remaining 40% among other winners
        const remaining = 0.40;
        const others = Math.max(0, count - 2);
        return others > 0 ? remaining / others : 0;
      };

      // We will only reward unique users (their best attempt)
      const bestAttempts = new Map<string, any>();
      for (const attempt of attempts) {
        if (!bestAttempts.has(attempt.userId)) {
          bestAttempts.set(attempt.userId, attempt);
        }
      }

      const sortedBestAttempts = Array.from(bestAttempts.values()).sort((a, b) => {
        if ((b.score || 0) !== (a.score || 0)) return (b.score || 0) - (a.score || 0);
        return (a.timeTaken || 0) - (b.timeTaken || 0);
      });

      const topWinners = sortedBestAttempts.slice(0, wCount);


      const uniqueWinnings = new Map<string, number>();

      // Build a map: userId -> { prize, rank, attemptId }
      const winnerDetails = new Map<string, { prize: number; rank: number; attemptId: string }>();
      for (let i = 0; i < topWinners.length; i++) {
        const winner = topWinners[i];
        const percent = getPercent(i + 1, wCount);
        const prize = Math.floor(netPool * percent);
        // We MUST set the rank even if prize is 0 (Free Tournament)
        winnerDetails.set(winner.userId, { prize, rank: i + 1, attemptId: winner.attemptId });
        if (prize > 0) {
          uniqueWinnings.set(winner.userId, prize);
        }
      }

      // 4. Get all winners' profiles and referral config for commission
      const winnerUserIds = Array.from(winnerDetails.keys());
      const winnerProfiles: Record<string, UserProfile> = {};
      if (winnerUserIds.length > 0) {
        const chunks = [];
        for (let i = 0; i < winnerUserIds.length; i += 30) {
          chunks.push(winnerUserIds.slice(i, i + 30));
        }
        for (const chunk of chunks) {
          const qWinners = query(collection(db, 'users'), where('userId', 'in', chunk));
          const snapWinners = await getDocs(qWinners);
          snapWinners.forEach(doc => {
            winnerProfiles[doc.id] = { userId: doc.id, ...doc.data() } as UserProfile;
          });
        }
      }

      const refConfigSnap = await getDoc(doc(db, 'configs', 'referral_system'));
      const refConfig = refConfigSnap.exists() ? refConfigSnap.data() as ReferralSystemConfig : null;
      const commRate = (refConfig?.isActive && refConfig?.commissionRate) || 0;

      // 5. Batch update users, attempts and test status
      const { increment } = await import('firebase/firestore');
      const batch = writeBatch(db);

      for (const [userId, details] of winnerDetails.entries()) {
        // Credit coins to user wallet and mark as leaderboard eligible
        if (details.prize > 0) {
          batch.update(doc(db, 'users', userId), {
            coins: increment(details.prize),
            totalEarned: increment(details.prize),
            withdrawableBalance: increment(details.prize),
            isLeaderboardEligible: true
          });
        }

        // Handle Referral Commission
        const winnerProfile = winnerProfiles[userId];
        const referrerId = winnerProfile?.referredBy;
        if (referrerId && commRate > 0 && details.prize > 0) {
          const commission = Math.floor(details.prize * (commRate / 100));
          if (commission > 0) {
            batch.update(doc(db, 'users', referrerId), {
              coins: increment(commission),
              totalEarned: increment(commission),
              withdrawableBalance: increment(commission),
              'referralStats.totalEarnings': increment(commission)
            });

            const commTxRef = doc(collection(db, 'transactions'));
            batch.set(commTxRef, {
              userId: referrerId,
              amount: commission,
              type: 'earn',
              category: 'referral_commission',
              referenceId: test.testId,
              testTitle: `Commission: ${winnerProfile.name} won in ${test.title}`,
              timestamp: serverTimestamp()
            });

            const commNotifRef = doc(collection(db, 'notifications'));
            batch.set(commNotifRef, {
              userId: referrerId,
              title: 'Referral Commission! 💸',
              message: `You earned ${commission} coins as commission from ${winnerProfile.name}'s win in "${test.title}"!`,
              type: 'referral',
              read: false,
              createdAt: new Date().toISOString()
            });
          }
        }

        // Stamp the attempt so ResultView can display the prize banner
        batch.update(doc(db, 'attempts', details.attemptId), {
          coinsEarned: details.prize,
          tournamentRank: details.rank,
          isCoinsAwarded: true
        });

        // Log the transaction in the transactions collection only if there is a prize
        if (details.prize > 0) {
          const transactionRef = doc(collection(db, 'transactions'));
          batch.set(transactionRef, {
            userId: userId,
            amount: details.prize,
            type: 'earn',
            category: 'tournament_prize',
            referenceId: test.testId,
            testTitle: test.title,
            timestamp: serverTimestamp()
          });
        }
      }

      batch.update(doc(db, 'tests', test.testId), {
        isResultDeclared: true,
        prizePoolDistributed: netPool,
        totalParticipantsCollected: totalParticipants
      });

      await batch.commit();

      // Refresh tests & contests locally so UI updates immediately
      setTests(prev => prev.map(t => t.testId === test.testId ? { ...t, isResultDeclared: true } : t));
      setContests(prev => prev.map(t => t.testId === test.testId ? { ...t, isResultDeclared: true } : t));
      setSelectedContestForReview(null);

      showToast(`Results declared successfully! Distributed ${netPool} coins among ${uniqueWinnings.size} users.`);
    } catch (error) {
      console.error('Error declaring results:', error);
      handleFirestoreError(error, OperationType.UPDATE, `tests/${test.testId}`);
      showToast('Failed to declare results. Check console.');
    }
  };

  const handleDeleteTest = async (testId: string) => {
    setIsDeleting(true);
    try {
      await deleteDoc(doc(db, 'tests', testId));
      setTests(prev => prev.filter(t => t.testId !== testId));
      setDeleteConfirm(null);
      // Remove from selected if present
      const newSelected = new Set(selectedTests);
      newSelected.delete(testId);
      setSelectedTests(newSelected);
    } catch (error) {
      console.error('Error deleting test', error);
      handleFirestoreError(error, OperationType.DELETE, `tests/${testId}`);
    } finally {
      setIsDeleting(false);
    }
  };

  const fetchPolls = async () => {
    setIsFetchingPolls(true);
    try {
      const q = query(collection(db, 'polls'), orderBy('createdAt', 'desc'));
      const snap = await getDocs(q);
      setPolls(snap.docs.map(d => ({ id: d.id, ...d.data() } as Poll)));
    } catch (err) {
      console.error("Error fetching polls:", err);
    } finally {
      setIsFetchingPolls(false);
    }
  };

  const handleSavePoll = async (pollData: Partial<Poll>) => {
    try {
      if (editingPoll && (editingPoll as any).id) {
        const pollRef = doc(db, 'polls', (editingPoll as any).id);
        await updateDoc(pollRef, pollData);
        showToast('Poll updated successfully', 'success');
      } else {
        const newPoll = {
          ...pollData,
          votes: {},
          voters: [],
          createdAt: serverTimestamp(),
        };
        await addDoc(collection(db, 'polls'), newPoll);
        showToast('Poll created successfully', 'success');
      }
      setShowAddPoll(false);
      setEditingPoll(null);
      fetchPolls();
    } catch (err) {
      console.error("Error saving poll:", err);
      showToast('Error saving poll', 'error');
    }
  };

  const handleDeletePoll = async (pollId: string) => {
    setIsDeleting(true);
    try {
      await deleteDoc(doc(db, 'polls', pollId));
      setPolls(prev => prev.filter(p => p.id !== pollId));
      setDeleteConfirm(null);
      showToast('Poll deleted successfully', 'success');
    } catch (error) {
      console.error('Error deleting poll', error);
      handleFirestoreError(error, OperationType.DELETE, `polls/${pollId}`);
    } finally {
      setIsDeleting(false);
    }
  };

  const handleBulkDelete = async () => {
    setIsBulkDeleting(true);
    try {
      const batch = writeBatch(db);
      selectedTests.forEach(testId => {
        batch.delete(doc(db, 'tests', testId));
      });
      await batch.commit();

      setTests(prev => prev.filter(t => !selectedTests.has(t.testId)));
      setSelectedTests(new Set());
      setShowBulkDeleteConfirm(false);
    } catch (error) {
      console.error('Error in bulk delete', error);
      handleFirestoreError(error, OperationType.DELETE, 'tests/bulk');
    } finally {
      setIsBulkDeleting(false);
    }
  };

  const handleSaveQuestion = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!managingQuestionsFor || !editingQuestion) return;

    try {
      const qData = { ...editingQuestion };
      if (editingQuestion.questionId) {
        await setDoc(doc(db, 'tests', managingQuestionsFor.testId, 'questions', editingQuestion.questionId), qData);
      } else {
        const qRef = await addDoc(collection(db, 'tests', managingQuestionsFor.testId, 'questions'), {
          ...qData,
          testId: managingQuestionsFor.testId
        });
        // Update with ID
        await setDoc(qRef, { questionId: qRef.id }, { merge: true });
      }

      setShowAddQuestion(false);
      setEditingQuestion(null);

      // Refresh questions
      const qSnap = await getDocs(collection(db, 'tests', managingQuestionsFor.testId, 'questions'));
      setQuestions(qSnap.docs.map(d => ({ questionId: d.id, ...d.data() } as Question)));
    } catch (error) {
      console.error('Error saving question', error);
      handleFirestoreError(error, editingQuestion.questionId ? OperationType.UPDATE : OperationType.CREATE, `tests/${managingQuestionsFor.testId}/questions`);
    }
  };

  const handleDeleteQuestion = async (qId: string) => {
    if (!managingQuestionsFor) return;
    setIsDeleting(true);
    try {
      await deleteDoc(doc(db, 'tests', managingQuestionsFor.testId, 'questions', qId));
      setQuestions(prev => prev.filter(q => q.questionId !== qId));
      setDeleteConfirm(null);
    } catch (error) {
      console.error('Error deleting question', error);
      handleFirestoreError(error, OperationType.DELETE, `tests/${managingQuestionsFor.testId}/questions/${qId}`);
    } finally {
      setIsDeleting(false);
    }
  };

  const handleDeletePattern = async (id: string) => {
    setIsDeleting(true);
    try {
      await deleteDoc(doc(db, 'examPatterns', id));
      setDeleteConfirm(null);
    } catch (error) {
      console.error('Error deleting pattern', error);
      handleFirestoreError(error, OperationType.DELETE, `examPatterns/${id}`);
    } finally {
      setIsDeleting(false);
    }
  };

  const normalizeComparableText = (value?: string | null) =>
    (value || '')
      .toLowerCase()
      .replace(/[^a-z0-9\u0900-\u097f\s]/gi, ' ')
      .replace(/\s+/g, ' ')
      .trim();

  const looselyMatches = (left?: string | null, right?: string | null) => {
    const normalizedLeft = normalizeComparableText(left);
    const normalizedRight = normalizeComparableText(right);

    if (!normalizedLeft || !normalizedRight) return false;

    return normalizedLeft === normalizedRight
      || normalizedLeft.includes(normalizedRight)
      || normalizedRight.includes(normalizedLeft);
  };

  const BPSC_OPTION_4_EN = 'More than one of the above';
  const BPSC_OPTION_4_HI = 'उपर्युक्त में से एक से अधिक';
  const BPSC_OPTION_5_EN = 'None of the above';
  const BPSC_OPTION_5_HI = 'उपर्युक्त में से कोई भी नहीं';

  const resolvePatternSection = (
    question: { subject?: string; topic?: string },
    sections: ExamPattern['sections']
  ) => {
    const subjectMatches = sections.filter(section => looselyMatches(question.subject, section.subject));
    if (subjectMatches.length === 1) {
      return subjectMatches[0];
    }

    const topicMatches = sections.filter(section =>
      section.topics.some(topic => looselyMatches(question.topic, topic))
    );
    if (topicMatches.length === 1) {
      return topicMatches[0];
    }

    if (sections.length === 1) {
      return sections[0];
    }

    return null;
  };

  const validateAndNormalizeAiQuestions = ({
    rawQuestions,
    expectedCount,
    expectedOptions,
    isBPSC,
    pattern,
    selectedTopic
  }: {
    rawQuestions: any[];
    expectedCount: number;
    expectedOptions: number;
    isBPSC: boolean;
    pattern?: ExamPattern;
    selectedTopic?: string;
  }) => {
    if (!Array.isArray(rawQuestions) || rawQuestions.length === 0) {
      throw new Error('AI did not return any questions.');
    }

    if (rawQuestions.length !== expectedCount) {
      throw new Error(`AI returned ${rawQuestions.length} questions, but ${expectedCount} are required.`);
    }

    const patternSections = pattern?.sections.filter(section =>
      section.subject?.trim() && Number.isFinite(section.questionCount)
    ) || [];
    const sectionCounts = new Map<string, number>();
    const canonicalSelectedTopic = selectedTopic?.trim();

    const normalizedQuestions = rawQuestions.map((rawQuestion, index) => {
      const questionNumber = index + 1;
      const questionTextEnglish = rawQuestion?.questionTextEnglish?.trim();
      const questionTextHindi = rawQuestion?.questionTextHindi?.trim();
      const options = Array.isArray(rawQuestion?.options) ? rawQuestion.options : [];
      const correctAnswer = rawQuestion?.correctAnswer;

      if (!questionTextEnglish || !questionTextHindi) {
        throw new Error(`Question ${questionNumber} is missing English or Hindi text.`);
      }

      if (options.length !== expectedOptions) {
        throw new Error(`Question ${questionNumber} must have exactly ${expectedOptions} options.`);
      }

      if (!Number.isInteger(correctAnswer) || correctAnswer < 0 || correctAnswer >= expectedOptions) {
        throw new Error(`Question ${questionNumber} has an invalid correct answer index.`);
      }

      const normalizedOptions = options.map((option: any, optionIndex: number) => {
        const textEnglish = option?.textEnglish?.trim();
        const textHindi = option?.textHindi?.trim();

        if (!textEnglish || !textHindi) {
          throw new Error(`Question ${questionNumber}, option ${optionIndex + 1} is missing English or Hindi text.`);
        }

        return {
          textEnglish,
          textHindi
        };
      });

      if (isBPSC && expectedOptions === 5) {
        normalizedOptions[3] = {
          textEnglish: BPSC_OPTION_4_EN,
          textHindi: BPSC_OPTION_4_HI
        };
        normalizedOptions[4] = {
          textEnglish: BPSC_OPTION_5_EN,
          textHindi: BPSC_OPTION_5_HI
        };
      }

      const normalizedQuestion = {
        questionTextEnglish,
        questionTextHindi,
        options: normalizedOptions,
        correctAnswer,
        explanation: rawQuestion?.explanation?.trim() || '',
        explanationHindi: rawQuestion?.explanationHindi?.trim() || '',
        subject: rawQuestion?.subject?.trim() || '',
        topic: rawQuestion?.topic?.trim() || ''
      };

      if (canonicalSelectedTopic) {
        if (!normalizedQuestion.topic) {
          normalizedQuestion.topic = canonicalSelectedTopic;
        } else if (!looselyMatches(normalizedQuestion.topic, canonicalSelectedTopic)) {
          throw new Error(`Question ${questionNumber} is outside the selected topic "${canonicalSelectedTopic}".`);
        } else {
          normalizedQuestion.topic = canonicalSelectedTopic;
        }
      }

      if (patternSections.length > 0) {
        const matchedSection = resolvePatternSection(normalizedQuestion, patternSections);

        if (!matchedSection) {
          throw new Error(`Question ${questionNumber} could not be mapped to any selected exam pattern section.`);
        }

        normalizedQuestion.subject = matchedSection.subject;

        if (matchedSection.topics.length > 0) {
          const matchedTopic = matchedSection.topics.find(topic => looselyMatches(normalizedQuestion.topic, topic));

          if (!matchedTopic) {
            throw new Error(`Question ${questionNumber} topic "${normalizedQuestion.topic || 'N/A'}" is outside the allowed syllabus for ${matchedSection.subject}.`);
          }

          normalizedQuestion.topic = matchedTopic;
        } else if (!normalizedQuestion.topic) {
          normalizedQuestion.topic = matchedSection.subject;
        }

        sectionCounts.set(
          matchedSection.subject,
          (sectionCounts.get(matchedSection.subject) || 0) + 1
        );
      }

      return normalizedQuestion;
    });

    if (patternSections.length > 0) {
      const mismatchedSections = patternSections
        .filter(section => (sectionCounts.get(section.subject) || 0) !== section.questionCount)
        .map(section => `${section.subject}: expected ${section.questionCount}, got ${sectionCounts.get(section.subject) || 0}`);

      if (mismatchedSections.length > 0) {
        throw new Error(`AI output does not match the selected exam pattern. ${mismatchedSections.join('; ')}`);
      }
    }

    return normalizedQuestions;
  };

  const handleAiGenerate = async () => {
    if (!aiTestTitle) {
      showToast('Please enter a test title');
      return;
    }

    setIsGenerating(true);
    try {
      const storedCfWorkerUrl = cfWorkerUrl || localStorage.getItem('cfWorkerUrl');
      if (!storedCfWorkerUrl) {
        throw new Error("Please configure the Cloudflare Worker URL in the Settings tab first.");
      }

      const pattern = examPatterns.find(p => p.id === selectedPatternId);

      const isBPSC = aiTargetExam?.toLowerCase().includes('bpsc') || aiCategory?.toLowerCase().includes('bpsc');
      const numOptions = isBPSC ? 5 : 4;

      let prompt = `Generate a ${aiDifficulty} difficulty mock test for ${aiCategory} category${aiTargetExam ? ` specifically for the ${aiTargetExam} exam` : ''}. 
      ${aiSubjectTopic ? `This test MUST focus EXCLUSIVELY on the sub-topic or specific chapter: ${aiSubjectTopic}.` : ''}
      The topic or content is: ${aiTopic || aiTestTitle}.
      
      CRITICAL INSTRUCTIONS & CONSTRAINTS:
      1. EXACT COUNT: You MUST generate EXACTLY ${aiQuestionCount} multiple-choice questions. Count them carefully. Do not generate less or more.
      2. DIVERSITY & ANTI-REPETITION: To prevent question repetition across exams, randomly select diverse and obscure concepts from the deep syllabus. Ensure creative framing.
      3. ACADEMIC STANDARD: The question difficulty, content, and core concepts MUST strictly align with the NCERT syllabus (Class 6 to Class 10) level, while matching the expected pattern of the ${aiTargetExam || aiCategory} exam.
      4. EXACTLY ${numOptions} OPTIONS: You must provide EXACTLY ${numOptions} options for EVERY question.${isBPSC ? `
         Since this is a BPSC pattern test, the options MUST be structured as follows:
         - Option 1, 2, and 3: Relevant distinct choices.
         - Option 4: Must always represent "More than one of the above" (Hindi: "उपर्युक्त में से एक से अधिक").
         - Option 5: Must always represent "None of the above" (Hindi: "उपर्युक्त में से कोई भी नहीं").` : ''}
      
      ${pattern ? `
      EXAM PATTERN REQUIREMENTS:
      Follow this marks distribution strictly:
      ${pattern.sections.map(s => `- ${s.subject}: ${s.questionCount} questions (Topics: ${s.topics.join(', ')})`).join('\n')}
      ` : ''}

      General Formatting:
      1. IMPORTANT: For each question, each option, and the explanation, provide both English and Hindi translations.
      2. MATH & SCIENCE: Use LaTeX for all mathematical equations, formulas, and scientific notations. 
         - Use $...$ for inline math (e.g., $E=mc^2$).
         - Use $$...$$ for block math.
         - Ensure chemical formulas like $H_2O$ and complex equations are properly formatted in LaTeX.
         - IMPORTANT FOR JSON OUTPUT: Escape every LaTeX backslash inside JSON strings. Example: write \\\\text{प्रकाश ऊर्जा}, \\\\to, \\\\frac{a}{b}, not \\\text{...} or \\to.
      
      Return the response in JSON format matching this schema:
      {
        "questions": [
          {
            "questionTextEnglish": "string",
            "questionTextHindi": "string",
            "options": [
              {"textEnglish": "string", "textHindi": "string"},
              // Must be exactly ${numOptions} options
            ],
            "correctAnswer": 0,
            "explanation": "string",
            "explanationHindi": "string",
            "subject": "string",
            "topic": "string"
          }
        ]
      }
      
      FINAL CRITICAL REMINDER: You MUST return EXACTLY ${aiQuestionCount} questions. No more, no less. Each question must have a clearly unique "questionTextEnglish".`;

      prompt += `\n5. STRICT LABELS: The "subject" and "topic" fields must use clear canonical labels only, not vague labels like "General" or "Mixed".`;

      if (pattern) {
        prompt += `\nUse the section subject names EXACTLY as written in the selected exam pattern for every question's "subject" field.`;
        prompt += `\nUse only the listed topic names from the selected exam pattern in the "topic" field for the relevant section.`;
      }

      if (aiSubjectTopic) {
        prompt += `\nTOPIC LOCK: Every question's "topic" field must be exactly "${aiSubjectTopic}".`;
      }

      if (aiInputType === 'video') {
        prompt += `\nBase the questions on the content of this video: ${aiVideoUrl}`;
      }

      const allRawQuestions: any[] = [];
      const CHUNK_SIZE = 50;
      const totalChunks = Math.ceil(aiQuestionCount / CHUNK_SIZE);

      for (let i = 0; i < totalChunks; i++) {
        const start = i * CHUNK_SIZE;
        const remaining = aiQuestionCount - start;
        const currentChunkCount = Math.min(CHUNK_SIZE, remaining);

        if (totalChunks > 1) {
          showToast(`Generating questions ${start + 1} to ${start + currentChunkCount}... (Chunk ${i + 1}/${totalChunks})`, 'info');
        }

        let chunkPrompt = prompt;
        // Update the prompt to ask for the specific chunk count
        chunkPrompt = chunkPrompt.replace(`EXACTLY ${aiQuestionCount} questions`, `EXACTLY ${currentChunkCount} questions`);

        const parts: any[] = [{ text: chunkPrompt }];

        if (aiInputType === 'file' && aiFile) {
          const reader = new FileReader();
          const base64Promise = new Promise<string>((resolve) => {
            reader.onload = () => resolve((reader.result as string).split(',')[1]);
            reader.readAsDataURL(aiFile);
          });
          const base64Data = await base64Promise;
          parts.push({
            inlineData: {
              data: base64Data,
              mimeType: aiFile.type
            }
          });
        }

        const requestBody = {
          model: "gemini-2.5-flash",
          contents: [{ role: "user", parts }],
          generationConfig: {
            responseMimeType: "application/json",
            responseSchema: {
              type: Type.OBJECT,
              properties: {
                questions: {
                  type: Type.ARRAY,
                  items: {
                    type: Type.OBJECT,
                    properties: {
                      questionTextEnglish: { type: Type.STRING },
                      questionTextHindi: { type: Type.STRING },
                      options: {
                        type: Type.ARRAY,
                        items: {
                          type: Type.OBJECT,
                          properties: {
                            textEnglish: { type: Type.STRING },
                            textHindi: { type: Type.STRING }
                          }
                        }
                      },
                      correctAnswer: { type: Type.INTEGER },
                      explanation: { type: Type.STRING },
                      explanationHindi: { type: Type.STRING },
                      subject: { type: Type.STRING },
                      topic: { type: Type.STRING },
                      questionNumber: { type: Type.INTEGER }
                    },
                    required: ["questionTextEnglish", "questionTextHindi", "options", "correctAnswer", "questionNumber"]
                  }
                }
              }
            }
          }
        };

        const aiResponse = await fetch(storedCfWorkerUrl.trim(), {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(requestBody)
        });

        if (!aiResponse.ok) {
          throw new Error(`Worker returned error at Chunk ${i + 1}: ${aiResponse.status} ${await aiResponse.text()}`);
        }

        const geminiResponse = await aiResponse.json();

        let responseText = '{}';
        if (geminiResponse.candidates && geminiResponse.candidates.length > 0) {
          const candidate = geminiResponse.candidates[0];
          if (candidate.content && candidate.content.parts && candidate.content.parts.length > 0) {
            responseText = candidate.content.parts[0].text;
          }
        } else if (geminiResponse.error) {
          throw new Error(`Gemini API Error at Chunk ${i + 1}: ${geminiResponse.error.message || 'Unknown error'}`);
        }

        const cleanText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();

        let result: any = {};
        try {
          result = JSON.parse(cleanText || '{}');
        } catch (e: any) {
          console.error(`Failed to parse Gemini JSON at Chunk ${i + 1}:`, cleanText);
          throw new Error(`JSON format error from AI at Chunk ${i + 1}: ${e.message}`);
        }

        if (!result.questions || result.questions.length === 0) {
          throw new Error(`No questions generated in Chunk ${i + 1}.`);
        }

        allRawQuestions.push(...result.questions);
      }

      const validatedQuestions = validateAndNormalizeAiQuestions({
        rawQuestions: allRawQuestions,
        expectedCount: aiQuestionCount,
        expectedOptions: numOptions,
        isBPSC,
        pattern,
        selectedTopic: aiSubjectTopic || undefined
      });

      // Create Test in Firestore
      const finalTitle = toTitleCase(aiSubjectTopic ? `${aiTestTitle} - ${aiSubjectTopic}` : aiTestTitle);
      const testRef = await addDoc(collection(db, 'tests'), {
        title: finalTitle,
        title_lowercase: finalTitle.toLowerCase(),
        status: 'unpublished',
        category: aiCategory || '',
        examCategory: aiTargetExam || pattern?.category || 'General',
        testMode: aiSubjectTopic ? 'sectional' : 'mock',
        subject: aiCategory || '',
        topic: aiSubjectTopic || '',
        examType: aiTargetExam || 'AI Generated',
        duration: pattern?.totalDuration || aiQuestionCount,
        totalQuestions: validatedQuestions.length,
        negativeMarking: pattern?.negativeMarking || 0.25,
        isPremium: false,
        createdAt: new Date().toISOString(),
        createdBy: 'admin'
      });

      // Batch add questions
      const batch = writeBatch(db);
      validatedQuestions.forEach((q) => {
        const qRef = doc(collection(db, 'tests', testRef.id, 'questions'));
        batch.set(qRef, {
          ...q,
          testId: testRef.id,
          difficultyLevel: aiDifficulty,
          questionId: qRef.id
        });
      });
      await batch.commit();

      showToast('Test generated successfully!');
      onTabChange('tests');
      // Refresh tests
      const qSnap = await getDocs(collection(db, 'tests'));
      setTests(qSnap.docs.map(d => ({ testId: d.id, ...d.data() } as Test)));

      // Reset form
      setAiTestTitle('');
      setAiTopic('');
      setAiVideoUrl('');
      setAiFile(null);
      setAiSubjectTopic('');
    } catch (error) {
      console.error('AI Generation failed:', error);
      showToast(error instanceof Error ? error.message : 'Failed to generate test. Please try again.');
    } finally {
      setIsGenerating(false);
    }
  };

  const handleGenerateCA = async () => {
    setIsGeneratingCA(true);
    try {
      const storedCfWorkerUrl = cfWorkerUrl || localStorage.getItem('cfWorkerUrl');
      if (!storedCfWorkerUrl) {
        throw new Error("Please configure the Cloudflare Worker URL in the Settings tab first.");
      }

      const prompt = `Write a comprehensive daily current affairs update for today. Focus on topics strictly relevant to Indian competitive exams like UPSC, BPSC, SSC, and Banking.
      Include national news, international news, sports, and key dates/appointments.
      Format strictly in Markdown. Use emojis for headings, bullet points, and bold text for important names/dates.
      Provide the content primarily in Hindi, with key terms in English brackets.`;

      const requestBody = {
        model: "gemini-2.5-flash",
        contents: [{ role: "user", parts: [{ text: prompt }] }]
      };

      const aiResponse = await fetch(storedCfWorkerUrl.trim(), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody)
      });

      if (!aiResponse.ok) throw new Error('Worker returned error');

      const geminiResponse = await aiResponse.json();
      let responseText = '';
      if (geminiResponse.candidates && geminiResponse.candidates.length > 0) {
        responseText = geminiResponse.candidates[0].content.parts[0].text;
      }

      if (!responseText) throw new Error("Could not generate content");

      const today = new Date();
      const dateStr = today.toISOString().split('T')[0];

      await addDoc(collection(db, 'currentAffairs'), {
        title: toTitleCase(`Daily Current Affairs - ${dateStr}`),
        content: responseText,
        date: dateStr,
        createdAt: today.toISOString(),
        author: 'AI Auto Post'
      });

      showToast('Daily Current Affairs generated and posted successfully!');
    } catch (error) {
      console.error(error);
      showToast('Failed to generate Current Affairs. Check console.');
    } finally {
      setIsGeneratingCA(false);
    }
  };




  const stats = [
    { label: 'Users', value: users.length.toString(), icon: Users, color: 'text-blue-600', bg: 'bg-blue-50' },
    { label: 'Tests', value: tests.length.toString(), icon: FileText, color: 'text-emerald-600', bg: 'bg-emerald-50' },
    { label: 'Revenue', value: '₹4.2L', icon: IndianRupee, color: 'text-amber-600', bg: 'bg-amber-50' },
    { label: 'Accuracy', value: '68%', icon: BarChart3, color: 'text-purple-600', bg: 'bg-purple-50' },
  ];

  const currentTab = [
    { id: 'overview', label: 'Overview' },
    { id: 'tests', label: 'Tests' },
    { id: 'users', label: 'Users' },
    { id: 'patterns', label: 'Categories & Patterns' },
    { id: 'ai-creator', label: 'AI Creator' },
    { id: 'tournaments', label: 'Contests' },
    { id: 'finance', label: 'Finance' },
    { id: 'banners', label: 'Banners' },
    { id: 'posts', label: 'Updates' },
    { id: 'battle_qs', label: 'Battle Questions' },
    { id: 'settings', label: 'Settings' }
  ].find(t => t.id === activeTab);

  return (
    <div className={activeTab === 'notifications' ? 'space-y-0' : 'space-y-6'}>

      {activeTab === 'overview' && (
        <div className="space-y-10">
          {/* Stats Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {stats.map((stat, i) => (
              <div key={i} className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4 group hover:border-emerald-100 transition-all text-left">
                <div className={`w-14 h-14 ${stat.bg} ${stat.color} rounded-2xl flex items-center justify-center shrink-0 transition-transform group-hover:scale-110 shadow-sm`}>
                  <stat.icon size={28} />
                </div>
                <div>
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">{stat.label}</p>
                  <p className="text-2xl font-black text-slate-900 leading-none">{stat.value}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'battle_qs' && (
        <AdminBattleQuestions storedCfWorkerUrl={cfWorkerUrl} />
      )}

      {activeTab === 'ai-creator' && (
        <div className="space-y-8">
          <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5">
            {/* Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex items-center gap-4 rounded-t-xl">
              <div className="p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
                <BrainCircuit size={24} strokeWidth={3} />
              </div>
              <div>
                <h3 className="text-xl font-black text-slate-900 leading-none">AI Test Intelligence</h3>
                <p className="text-[11px] text-slate-400 font-bold mt-1.5 flex items-center gap-2 uppercase tracking-widest">
                  Neural Content Generation Engine
                </p>
              </div>
            </div>

            <div className="p-6 lg:p-8 space-y-10">
              {/* Step 1: Base Configuration */}
              <div className="space-y-6">
                <div className="flex items-center gap-3 mb-2">
                  <span className="w-7 h-7 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center text-xs font-black">01</span>
                  <h4 className="text-sm font-black text-slate-800 uppercase tracking-wider">Test Architecture</h4>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  <div className="space-y-2">
                    <div className="relative group">
                      <FileText className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
                      <input
                        type="text"
                        value={aiTestTitle}
                        onChange={e => setAiTestTitle(capitalizeWords(e.target.value))}
                        className="w-full pl-12 pr-4 h-12 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-bold"
                        placeholder="e.g. Modern History Mock Test"
                      />
                    </div>
                  </div>

                  <CustomSelect
                    value={aiSelectedExamId}
                    onChange={(val) => {
                      const examId = val;
                      setAiSelectedExamId(examId);
                      const exam = findExamCategoryGroupById(examCategories, examId);
                      if (exam) {
                        setAiTargetExam(exam.name);
                      } else {
                        setAiTargetExam('');
                      }
                      setAiCategory('');
                      setAiSubjectTopic('');
                    }}
                    options={[
                      { value: 'all', label: 'Select Exam Group' },
                      ...examCategories.map(cat => ({ value: cat.id, label: cat.name }))
                    ]}
                    className="w-full"
                  />

                  <CustomSelect
                    value={selectedPatternId}
                    onChange={(val) => {
                      const patternId = val;
                      setSelectedPatternId(patternId);
                      const pattern = examPatterns.find(p => p.id === patternId);
                      if (pattern) {
                        setAiTargetExam(pattern.examName);
                        setAiCategory(pattern.category);
                        const totalQs = pattern.sections.reduce((acc, s) => acc + (isNaN(s.questionCount) ? 0 : s.questionCount), 0);
                        setAiQuestionCount(totalQs);
                      } else {
                        setAiTargetExam('');
                      }
                    }}
                    options={[
                      { value: '', label: 'No Pattern / Custom' },
                      ...examPatterns.map(p => ({ value: p.id, label: `${p.examName} (${p.category})` }))
                    ]}
                    className="w-full"
                  />

                  <CustomSelect
                    value={aiCategory}
                    onChange={(val) => {
                      setAiCategory(val);
                      setAiSubjectTopic('');
                    }}
                    options={[
                      { value: '', label: 'Select Subject' },
                      ...categories
                        .filter(cat => {
                          const isGlobal = !cat.parentExamId || cat.parentExamId === 'all';
                          const examId = aiSelectedExamId;
                          const isMatch = examId === 'all' || cat.parentExamId === examId;
                          const examNames = new Set(examCategories.map(ec => ec.name.toLowerCase().trim()));
                          const isExamName = examNames.has(cat.name.toLowerCase().trim());
                          if (isExamName) return false;
                          return isMatch;
                        })
                        .map(cat => ({ value: cat.name, label: cat.name }))
                    ]}
                    className="w-full"
                    searchable
                  />

                  <CustomSelect
                    value={aiSubjectTopic}
                    onChange={setAiSubjectTopic}
                    disabled={!aiCategory || !categories.find(c => c.name === aiCategory)?.topics?.length}
                    options={[
                      { value: '', label: 'Any Topic / Mixed' },
                      ...(categories.find(c => c.name === aiCategory)?.topics || []).map(topic => ({ value: topic, label: topic }))
                    ]}
                    className="w-full"
                    searchable
                  />

                  <CustomSelect
                    value={aiTargetExam}
                    onChange={setAiTargetExam}
                    options={[
                      { value: '', label: 'General (No specific exam)' },
                      ...examCategories.map(cat => ({ value: cat.name, label: cat.name }))
                    ]}
                    className="w-full"
                  />
                </div>
              </div>

              {/* Step 2: Knowledge Source */}
              <div className="space-y-6 pt-6 border-t border-slate-100">
                <div className="flex items-center gap-3 mb-2">
                  <span className="w-7 h-7 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center text-xs font-black">02</span>
                  <h4 className="text-sm font-black text-slate-800 uppercase tracking-wider">Knowledge Source</h4>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                  <div className="flex flex-col gap-3">
                    {[
                      { id: 'topic', icon: ScrollText, label: 'Prompt / Context', sub: 'Generate from text or topic' },
                      { id: 'video', icon: Youtube, label: 'YouTube Video', sub: 'Transcribe & analyze video' },
                      { id: 'file', icon: Upload, label: 'Document / Image', sub: 'Scan PDF, DOC or Photos' }
                    ].map(type => (
                      <button
                        key={type.id}
                        onClick={() => setAiInputType(type.id as any)}
                        className={`flex items-center gap-4 p-4 rounded-xl border transition-all text-left group ${aiInputType === type.id ? 'border-emerald-500 bg-emerald-50/50 shadow-sm shadow-emerald-900/5' : 'border-slate-100 bg-white hover:border-slate-300'}`}
                      >
                        <div className={`p-3 rounded-lg transition-colors ${aiInputType === type.id ? 'bg-emerald-500 text-white' : 'bg-slate-50 text-slate-400 group-hover:bg-slate-100'}`}>
                          <type.icon size={20} />
                        </div>
                        <div>
                          <p className={`text-xs font-black uppercase tracking-tight ${aiInputType === type.id ? 'text-emerald-700' : 'text-slate-700'}`}>{type.label}</p>
                          <p className="text-[10px] font-bold text-slate-400 mt-0.5">{type.sub}</p>
                        </div>
                        <div className={`ml-auto w-4 h-4 rounded-full border-2 flex items-center justify-center transition-all ${aiInputType === type.id ? 'border-emerald-500 bg-emerald-500' : 'border-slate-200'}`}>
                          {aiInputType === type.id && <Check className="text-white" size={10} strokeWidth={4} />}
                        </div>
                      </button>
                    ))}
                  </div>

                  <div className="lg:col-span-2">
                    {aiInputType === 'topic' && (
                      <div className="space-y-2 h-full flex flex-col">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Text Context / Topic Prompt</label>
                        <textarea
                          value={aiTopic}
                          onChange={e => setAiTopic(e.target.value)}
                          className="flex-1 w-full p-5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-bold min-h-[200px]"
                          placeholder="Paste historical text, scientific papers, or just a topic name like 'Vedic Period'..."
                        />
                      </div>
                    )}

                    {aiInputType === 'video' && (
                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">YouTube URL</label>
                        <div className="relative group">
                          <Youtube className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-rose-500 transition-colors" size={20} />
                          <input
                            type="url"
                            value={aiVideoUrl}
                            onChange={e => setAiVideoUrl(e.target.value)}
                            className="w-full pl-12 pr-4 h-14 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-rose-500/20 focus:border-rose-500 transition-all text-sm font-bold no-capitalize"
                            placeholder="https://www.youtube.com/watch?v=..."
                          />
                        </div>
                        <p className="text-[10px] font-bold text-slate-400 px-1 mt-2">AI will process the transcript to generate questions based on the video content.</p>
                      </div>
                    )}

                    {aiInputType === 'file' && (
                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Source Document</label>
                        <div className="border-2 border-dashed border-slate-200 rounded-xl p-10 flex flex-col items-center justify-center bg-slate-50 hover:bg-white hover:border-emerald-400 transition-all cursor-pointer relative group">
                          <input
                            type="file"
                            onChange={e => setAiFile(e.target.files?.[0] || null)}
                            className="absolute inset-0 opacity-0 cursor-pointer"
                            accept="image/*,.pdf,.doc,.docx,.txt"
                          />
                          <div className={`w-16 h-16 rounded-2xl shadow-sm flex items-center justify-center transition-all mb-4 ${aiFile ? 'bg-emerald-500 text-white scale-110' : 'bg-white text-slate-300 group-hover:text-emerald-500'}`}>
                            {aiFile ? <FileIcon size={32} /> : <Upload size={32} />}
                          </div>
                          <p className="text-sm font-black text-slate-900">{aiFile ? aiFile.name : 'Drop Source File Here'}</p>
                          <p className="text-[10px] font-bold text-slate-400 mt-1 uppercase tracking-widest">{aiFile ? `${(aiFile.size / 1024 / 1024).toFixed(2)} MB` : 'PDF, DOCX, TXT OR IMAGE'}</p>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Step 3: AI Configuration */}
              <div className="pt-8 border-t border-slate-100">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-center">
                  {/* Question Volume with Manual Entry */}
                  <div className="flex items-center gap-4 bg-slate-50 p-1.5 rounded-lg border border-slate-200 h-12">
                    <input
                      type="range"
                      min="5"
                      max="200"
                      step="5"
                      value={aiQuestionCount}
                      onChange={e => setAiQuestionCount(parseInt(e.target.value))}
                      className="flex-1 h-1.5 bg-slate-200 rounded-lg appearance-none cursor-pointer accent-emerald-500 ml-2"
                    />
                    <div className="flex items-center gap-1 bg-white px-2 rounded border border-slate-100">
                      <input
                        type="number"
                        value={aiQuestionCount}
                        onChange={e => {
                          const val = parseInt(e.target.value);
                          setAiQuestionCount(isNaN(val) ? 0 : Math.min(val, 500));
                        }}
                        className="w-10 h-8 text-sm font-black text-slate-900 focus:outline-none text-center bg-transparent"
                      />
                      <span className="text-[10px] font-black text-slate-400 uppercase">Qs</span>
                    </div>
                  </div>

                  <CustomSelect
                    value={aiDifficulty}
                    onChange={(val) => setAiDifficulty(val as 'easy' | 'medium' | 'hard')}
                    options={[
                      { value: 'easy', label: 'Beginner / Easy' },
                      { value: 'medium', label: 'Standard / Medium' },
                      { value: 'hard', label: 'Challenging / Hard' }
                    ]}
                    className="w-full"
                  />
                  <button
                    onClick={handleAiGenerate}
                    disabled={isGenerating}
                    className="w-full bg-emerald-500 text-white h-12 rounded-lg font-black text-xs uppercase tracking-[0.2em] hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-900/20 flex items-center justify-center gap-3 active:scale-95 disabled:opacity-50"
                  >
                    {isGenerating ? (
                      <>
                        <Loader2 className="animate-spin" size={18} />
                        Synthesizing...
                      </>
                    ) : (
                      <>
                        <Sparkles size={18} strokeWidth={3} />
                        Generate AI Test
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Current Affairs Section */}
          <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5">
            <div className="p-8 flex flex-col md:flex-row items-center gap-8 text-center md:text-left rounded-xl">
              <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-indigo-600 text-white rounded-2xl flex items-center justify-center shadow-xl shadow-blue-900/20 shrink-0">
                <Globe size={40} strokeWidth={2} />
              </div>
              <div className="flex-1">
                <h2 className="text-2xl font-black text-slate-900 leading-tight">Automated News Harvesting</h2>
                <p className="text-slate-500 text-sm mt-2 font-medium max-w-2xl">Deploy the AI agent to curate today's most critical current affairs across BPSC, UPSC, and SSC domains. The system will auto-post directly to the student portal.</p>
              </div>
              <button
                onClick={handleGenerateCA}
                disabled={isGeneratingCA}
                className="w-full md:w-auto h-14 px-10 bg-slate-900 text-white font-black text-[11px] uppercase tracking-widest rounded-xl shadow-xl hover:bg-slate-800 transition-all flex items-center justify-center gap-3 active:scale-95"
              >
                {isGeneratingCA ? (
                  <><Loader2 className="animate-spin" size={18} /> Harvesting...</>
                ) : (
                  <><Sparkles size={18} /> Auto-Post News</>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'patterns' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 overflow-hidden flex flex-col min-h-[700px]">
            {/* Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col gap-6">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
                    <ScrollText size={24} strokeWidth={3} />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-slate-900 leading-none">Exam Patterns</h3>
                    <p className="text-[11px] text-slate-400 font-bold mt-1.5 flex items-center gap-2">
                      Define Architecture & Syllabus Structure
                    </p>
                  </div>
                </div>

                <div className="flex flex-nowrap items-center gap-3 overflow-x-auto no-scrollbar pb-1">
                  <button
                    onClick={() => setShowManageCategories(true)}
                    className="flex items-center gap-2 px-5 h-12 bg-amber-500 text-white rounded-lg text-[11px] font-black uppercase tracking-wider transition-all hover:bg-amber-600 shadow-md shadow-amber-900/20 active:scale-95 shrink-0"
                  >
                    <BookOpen size={18} strokeWidth={3} />
                    Subjects
                  </button>

                  <button
                    onClick={() => setShowAddPattern(true)}
                    className="bg-emerald-500 text-white px-5 sm:px-6 h-12 rounded-lg font-black text-[11px] uppercase tracking-wider hover:bg-emerald-600 transition-all shadow-md shadow-emerald-900/20 flex items-center justify-center gap-2 active:scale-95 whitespace-nowrap shrink-0"
                  >
                    <Plus size={18} strokeWidth={4} />
                    New Pattern
                  </button>
                </div>
              </div>

              {/* Management & Search Bar */}
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pt-4 border-t border-slate-100/50">
                <div className="flex-1 relative group">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
                  <input
                    type="text"
                    placeholder="Search patterns by exam name or category..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-12 pr-4 h-12 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-bold shadow-sm"
                  />
                </div>

                <div className="flex flex-col sm:flex-row gap-3 min-w-fit">
                  <div className="bg-white p-2 rounded-lg border border-slate-200 shadow-sm flex items-center gap-3">
                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest pl-2">Quick Add Exam Tag:</span>
                    <form
                      onSubmit={async (e) => {
                        e.preventDefault();
                        const form = e.target as HTMLFormElement;
                        const input = form.elements.namedItem('examCatName') as HTMLInputElement;
                        if (await handleCreateExamCategory(input.value)) {
                          input.value = '';
                        }
                      }}
                      className="flex gap-2"
                    >
                      <input
                        type="text"
                        name="examCatName"
                        placeholder="E.g. SSC, BPSC"
                        className="w-32 px-3 py-1.5 border border-slate-100 bg-slate-50 rounded-md text-xs font-bold focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                        required
                      />
                      <button type="submit" className="bg-emerald-500 text-white px-3 py-1.5 rounded-md font-bold text-xs hover:bg-emerald-600 transition-colors">
                        Add
                      </button>
                    </form>
                  </div>
                </div>
              </div>
            </div>

            {/* Content Area */}
            <div className="flex-1 p-6 overflow-y-auto no-scrollbar bg-slate-50/20">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {examPatterns
                  .filter(p => p.examName.toLowerCase().includes(searchTerm.toLowerCase()) || p.category.toLowerCase().includes(searchTerm.toLowerCase()))
                  .map(pattern => (
                    <div key={pattern.id} className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md hover:border-emerald-100 transition-all group relative overflow-hidden flex flex-col">
                      <div className="absolute top-0 left-0 w-1 h-full bg-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity" />

                      <div className="p-5">
                        <div className="flex justify-between items-start mb-4">
                          <div className="w-12 h-12 bg-slate-50 rounded-lg flex items-center justify-center text-slate-400 group-hover:bg-emerald-50 group-hover:text-emerald-500 transition-all">
                            <Layout size={24} />
                          </div>
                          <button
                            onClick={() => setDeleteConfirm({ type: 'pattern', id: pattern.id, title: pattern.examName })}
                            className="p-2 text-slate-300 hover:text-rose-500 hover:bg-rose-50 rounded-lg transition-all"
                          >
                            <Trash2 size={18} />
                          </button>
                        </div>

                        <h4 className="text-lg font-black text-slate-900 mb-1 leading-tight">{pattern.examName}</h4>
                        <div className="flex items-center gap-2 mb-4">
                          <span className="px-2 py-0.5 bg-slate-100 text-slate-500 text-[10px] font-black uppercase tracking-widest rounded border border-slate-200">
                            {pattern.category}
                          </span>
                          <span className="w-1 h-1 rounded-full bg-slate-300" />
                          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                            {pattern.sections.length} Sections
                          </span>
                        </div>

                        <div className="space-y-2 mb-6">
                          {pattern.sections.slice(0, 3).map((section, idx) => (
                            <div key={idx} className="flex items-center justify-between py-1.5 px-3 bg-slate-50/50 rounded-lg border border-slate-100">
                              <span className="text-xs font-bold text-slate-600 truncate mr-2">{section.subject}</span>
                              <span className="text-xs font-black text-slate-900 bg-white px-2 py-0.5 rounded border border-slate-100">{section.questionCount} Qs</span>
                            </div>
                          ))}
                          {pattern.sections.length > 3 && (
                            <p className="text-[10px] font-bold text-slate-400 text-center pt-1">+{pattern.sections.length - 3} more sections</p>
                          )}
                        </div>
                      </div>

                      <div className="mt-auto p-4 bg-slate-50 border-t border-slate-100 flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="flex items-center gap-1.5 text-slate-500">
                            <Clock size={14} />
                            <span className="text-xs font-bold">{pattern.totalDuration} Min</span>
                          </div>
                          <div className="w-px h-3 bg-slate-200" />
                          <div className="flex items-center gap-1.5 text-rose-500">
                            <AlertCircle size={14} />
                            <span className="text-xs font-bold">-{pattern.negativeMarking}</span>
                          </div>
                        </div>

                        <button className="text-[10px] font-black text-emerald-600 uppercase tracking-widest hover:underline">
                          Edit Details
                        </button>
                      </div>
                    </div>
                  ))}
              </div>

              {examPatterns.length === 0 && (
                <div className="py-24 flex flex-col items-center justify-center bg-white rounded-xl border border-dashed border-slate-200">
                  <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4 border border-slate-100 shadow-inner">
                    <ScrollText size={40} className="text-slate-200" strokeWidth={1.5} />
                  </div>
                  <h3 className="text-lg font-black text-slate-900 uppercase tracking-tight">No Patterns Found</h3>
                  <p className="text-slate-400 text-sm mt-1">Start by creating a new exam structure.</p>
                </div>
              )}
            </div>
          </div>

          {/* Root Exam Tags Quick List */}
          <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
            <h4 className="text-xs font-black text-slate-400 uppercase tracking-[0.2em] mb-4">Registered Exam Tags</h4>
            <div className="flex flex-wrap gap-2">
              {examCategories.map(ec => (
                <span key={ec.id} className="inline-flex items-center gap-2 px-3 py-1.5 bg-slate-50 text-slate-700 text-xs font-bold rounded-lg border border-slate-100 hover:border-emerald-200 hover:bg-emerald-50 transition-all group">
                  {ec.name}
                  <div className="flex items-center gap-1 opacity-100 lg:opacity-0 lg:group-hover:opacity-100 transition-opacity">
                    <button onClick={() => setEditingExamCategory(ec)} className="p-1 hover:text-emerald-600">
                      <Edit size={12} />
                    </button>
                    <button
                      onClick={() => setDeleteConfirm({ type: 'examCategory', id: ec.id, title: ec.name })}
                      className="p-1 hover:text-rose-600"
                    >
                      <Trash2 size={12} />
                    </button>
                  </div>
                </span>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Finance Tab */}
      {activeTab === 'finance' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden flex flex-col min-h-[700px]">
            {/* Unified Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col gap-6">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-emerald-500 text-white rounded-xl shadow-lg shadow-emerald-100">
                    <IndianRupee size={24} strokeWidth={3} />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-slate-900 leading-none">Finance Management</h3>
                    <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1.5">
                      {financeSubTab === 'settings' ? 'Configure Payment Rules' : (financeSubTab === 'topups' ? 'Verify User Deposits' : 'Process Payout Requests')}
                    </p>
                  </div>
                </div>

                <div className="flex flex-nowrap items-center gap-2 bg-white/50 p-1 rounded-xl border border-slate-100 shadow-sm overflow-x-auto no-scrollbar">
                  {[
                    { id: 'topups', label: 'Top-ups', icon: PlusCircle },
                    { id: 'withdrawals', label: 'Withdrawals', icon: ArrowUpRight },
                    { id: 'settings', label: 'Settings', icon: Settings2 }
                  ].map(tab => (
                    <button
                      key={tab.id}
                      onClick={() => setFinanceSubTab(tab.id as any)}
                      className={`flex items-center gap-2 px-5 py-2.5 rounded-lg text-[10px] font-black uppercase tracking-wider transition-all active:scale-95 whitespace-nowrap shrink-0 ${financeSubTab === tab.id
                        ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-100'
                        : 'text-slate-400 hover:text-emerald-600 hover:bg-emerald-50'
                        }`}
                    >
                      <tab.icon size={14} />
                      {tab.label}
                    </button>
                  ))}
                </div>
              </div>

              {financeSubTab !== 'settings' && (
                <div className="flex items-center justify-between pt-4 border-t border-slate-100/50">
                  <div className="flex flex-nowrap items-center gap-2 bg-white p-1 rounded-xl border border-slate-200 shadow-sm overflow-x-auto no-scrollbar">
                    <button
                      onClick={() => setFinanceTabType('pending')}
                      className={`px-6 py-2 rounded-lg text-[10px] font-black uppercase tracking-tight transition-all shrink-0 ${financeTabType === 'pending' ? 'bg-emerald-500 text-white shadow-md shadow-emerald-100' : 'text-slate-400 hover:text-emerald-600 hover:bg-emerald-50'}`}
                    >
                      Pending
                    </button>
                    <button
                      onClick={() => setFinanceTabType('history')}
                      className={`px-6 py-2 rounded-lg text-[10px] font-black uppercase tracking-tight transition-all shrink-0 ${financeTabType === 'history' ? 'bg-emerald-500 text-white shadow-md shadow-emerald-100' : 'text-slate-400 hover:text-emerald-600 hover:bg-emerald-50'}`}
                    >
                      History
                    </button>
                  </div>

                  <button
                    onClick={() => financeSubTab === 'topups' ? fetchFinanceRequests(true) : fetchWithdrawalRequests(true)}
                    disabled={isFetchingFinance || isFetchingWithdrawals}
                    className="p-2.5 bg-white border border-slate-200 text-slate-400 hover:text-emerald-500 hover:border-emerald-100 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-50"
                    title="Refresh Data"
                  >
                    <RotateCcw size={18} className={(isFetchingFinance || isFetchingWithdrawals) ? 'animate-spin' : ''} />
                  </button>
                </div>
              )}
            </div>

            <div className="flex-1 flex flex-col p-6 overflow-x-auto">
              {financeSubTab === 'settings' ? (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-stretch h-full">
                  {/* UPI Configuration (Deposit) */}
                  <div className="bg-white p-8 rounded-2xl border border-slate-100 shadow-sm flex flex-col h-full">
                    <div className="flex items-center gap-3 border-b border-slate-50 pb-4">
                      <div className="w-10 h-10 bg-emerald-50 text-emerald-600 rounded-xl flex items-center justify-center">
                        <Plus size={20} />
                      </div>
                      <div>
                        <h3 className="font-bold text-slate-900">Deposit / Top-up Settings</h3>
                        <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Merchant UPI Details</p>
                      </div>
                    </div>

                    <div className="flex-1 flex flex-col pt-6">
                      <div className="flex-1 space-y-4">
                        <div>
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">UPI ID (VPA)</label>
                          <input
                            type="text"
                            value={paymentConfig.upiId}
                            onChange={e => setPaymentConfig({ ...paymentConfig, upiId: e.target.value })}
                            placeholder="e.g. name@upi"
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700"
                          />
                        </div>
                        <div>
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Merchant Name</label>
                          <input
                            type="text"
                            value={paymentConfig.merchantName}
                            onChange={e => setPaymentConfig({ ...paymentConfig, merchantName: e.target.value })}
                            placeholder="e.g. Rankearn Admin"
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700"
                          />
                        </div>
                        <div>
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">QR Note</label>
                          <input
                            type="text"
                            value={paymentConfig.qrNote}
                            onChange={e => setPaymentConfig({ ...paymentConfig, qrNote: e.target.value })}
                            placeholder="e.g. Wallet Top-up"
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700"
                          />
                        </div>

                        <div className="pt-4 border-t border-slate-50">
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Coin Value (1 INR = X Coins)</label>
                          <div className="flex items-center gap-3">
                            <div className="flex-1 relative">
                              <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 font-bold">1 ₹ =</div>
                              <input
                                type="number"
                                value={paymentConfig.coinsPerRupee}
                                onChange={e => setPaymentConfig({ ...paymentConfig, coinsPerRupee: parseInt(e.target.value) || 1 })}
                                className="w-full pl-16 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700"
                              />
                            </div>
                            <div className="px-4 py-3 bg-amber-50 border border-amber-100 rounded-xl flex items-center gap-2">
                              <Coins size={18} className="text-amber-500" />
                              <span className="text-sm font-black text-amber-700">Coins</span>
                            </div>
                          </div>
                          <p className="text-[9px] text-slate-400 mt-2 font-medium italic">* This value determines how many coins a user gets for every ₹1 they deposit.</p>
                        </div>
                      </div>

                      <div className="mt-8">
                        <button
                          onClick={handleSavePaymentConfig}
                          disabled={isSavingConfig}
                          className="w-full py-4 bg-emerald-500 text-white font-black rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 disabled:opacity-50"
                        >
                          Save Deposit Settings
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Withdrawal Configuration */}
                  <div className="bg-white p-8 rounded-2xl border border-slate-100 shadow-sm flex flex-col h-full">
                    <div className="flex items-center gap-3 border-b border-slate-50 pb-4">
                      <div className="w-10 h-10 bg-indigo-50 text-indigo-600 rounded-xl flex items-center justify-center">
                        <ArrowUpRight size={20} />
                      </div>
                      <div>
                        <h3 className="font-bold text-slate-900">Withdrawal Configuration</h3>
                        <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Global Payout Rules</p>
                      </div>
                    </div>

                    <div className="flex-1 flex flex-col pt-6">
                      <div className="flex-1 space-y-4">
                        <div>
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Minimum Coins for Withdrawal</label>
                          <input
                            type="number"
                            value={withdrawalSettings.minCoins}
                            onChange={e => setWithdrawalSettings({ ...withdrawalSettings, minCoins: parseInt(e.target.value) || 0 })}
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none font-bold text-slate-700"
                          />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 flex items-center justify-between">
                            <span className="text-xs font-bold text-slate-700">UPI Payouts</span>
                            <button
                              onClick={() => setWithdrawalSettings({ ...withdrawalSettings, isUPIEnabled: !withdrawalSettings.isUPIEnabled })}
                              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${withdrawalSettings.isUPIEnabled ? 'bg-emerald-500' : 'bg-slate-300'}`}
                            >
                              <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${withdrawalSettings.isUPIEnabled ? 'translate-x-6' : 'translate-x-1'}`} />
                            </button>
                          </div>
                          <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 flex items-center justify-between">
                            <span className="text-xs font-bold text-slate-700">Bank Payouts</span>
                            <button
                              onClick={() => setWithdrawalSettings({ ...withdrawalSettings, isBankEnabled: !withdrawalSettings.isBankEnabled })}
                              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${withdrawalSettings.isBankEnabled ? 'bg-emerald-500' : 'bg-slate-300'}`}
                            >
                              <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${withdrawalSettings.isBankEnabled ? 'translate-x-6' : 'translate-x-1'}`} />
                            </button>
                          </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Processing Fee (%)</label>
                            <input
                              type="number"
                              value={withdrawalSettings.feePercentage}
                              onChange={e => setWithdrawalSettings({ ...withdrawalSettings, feePercentage: parseFloat(e.target.value) || 0 })}
                              className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none font-bold text-slate-700"
                            />
                          </div>
                          <div>
                            <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Conversion (₹1 = ? Coins)</label>
                            <div className="relative">
                              <input
                                type="number"
                                value={withdrawalSettings.coinsPerRupee}
                                onChange={e => setWithdrawalSettings({ ...withdrawalSettings, coinsPerRupee: parseInt(e.target.value) || 1 })}
                                className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none font-bold text-slate-700 pr-16"
                              />
                              <div className="absolute right-4 top-1/2 -translate-y-1/2 text-[10px] font-black text-slate-400 uppercase">Coins</div>
                            </div>
                          </div>
                        </div>

                        <div>
                          <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Admin Note (Public)</label>
                          <textarea
                            value={withdrawalSettings.withdrawalNote}
                            onChange={e => setWithdrawalSettings({ ...withdrawalSettings, withdrawalNote: e.target.value })}
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none text-xs font-medium resize-none h-16"
                          />
                        </div>
                      </div>

                      <div className="mt-8">
                        <button
                          onClick={handleSaveWithdrawalSettings}
                          disabled={isSavingConfig}
                          className="w-full py-4 bg-emerald-500 text-white font-black rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 disabled:opacity-50"
                        >
                          Save Withdrawal Settings
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <>
                  <div className="overflow-x-auto">
                    {financeSubTab === 'topups' ? (
                      <table className="w-full text-left">
                        <thead>
                          <tr className="bg-slate-50/50">
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest w-16">S.No.</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">User Details</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Amount (Coins)</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">UTR Reference</th>
                            <th className="px-6 py-4 text-right text-[10px] font-black text-slate-400 uppercase tracking-widest">Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-50">
                          {financeRequests.map((req, index) => (
                            <tr key={req.id} className="hover:bg-slate-50/30 transition-colors group">
                              <td className="px-6 py-4">
                                <span className="text-xs font-black text-slate-400">#{index + 1}</span>
                              </td>
                              <td className="px-6 py-4">
                                <div className="flex items-start gap-3">
                                  <img
                                    src={req.userPhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(req.userName || 'U')}&background=random`}
                                    className="w-10 h-10 rounded-full border border-slate-100 object-cover shrink-0"
                                    alt=""
                                  />
                                  <div>
                                    <p className="font-black text-slate-900 text-sm whitespace-nowrap">{req.userName || 'Unknown'}</p>
                                    <p className="text-[10px] text-slate-500 font-bold mb-1">{req.userPhone || 'No Mobile'}</p>
                                    <p className="text-[9px] text-slate-400 font-medium">
                                      {financeTabType === 'pending'
                                        ? new Date(req.timestamp).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })
                                        : `Done: ${new Date(req.processedAt?.seconds * 1000 || req.processedAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}`
                                      }
                                    </p>
                                  </div>
                                </div>
                              </td>
                              <td className="px-6 py-4">
                                <div className="flex items-center gap-1 text-emerald-600 font-black">
                                  <Coins size={14} />
                                  {req.amount.toLocaleString()}
                                </div>
                                <p className="text-[10px] text-slate-400 font-bold">₹{(req.amount / 20).toLocaleString()}</p>
                              </td>
                              <td className="px-6 py-4">
                                <span className="bg-white border border-slate-200 px-2.5 py-1 rounded-lg font-mono text-xs font-bold text-slate-700 shadow-sm">
                                  {req.utr}
                                </span>
                                {financeTabType === 'history' && (
                                  <div className={`mt-2 inline-block px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-widest ${req.status === 'approved' ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>
                                    {req.status}
                                  </div>
                                )}
                              </td>
                              <td className="px-6 py-4">
                                {financeTabType === 'pending' ? (
                                  <div className="flex items-center justify-end gap-2">
                                    <button
                                      onClick={() => setConfirmFinanceAction({ requestId: req.id, type: 'topup', action: 'approved', data: req })}
                                      disabled={isProcessingTopup === req.id}
                                      className="px-5 py-2.5 bg-emerald-600 text-white font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-emerald-700 transition-all shadow-md active:scale-95 disabled:opacity-50 flex items-center gap-2"
                                    >
                                      {isProcessingTopup === req.id ? (
                                        <Loader2 size={12} className="animate-spin" />
                                      ) : (
                                        <div className="w-5 h-5 border-2 border-white/80 rounded-full flex items-center justify-center">
                                          <Check size={10} strokeWidth={4} />
                                        </div>
                                      )}
                                      Approve
                                    </button>
                                    <button
                                      onClick={() => setConfirmFinanceAction({ requestId: req.id, type: 'topup', action: 'rejected', data: req })}
                                      disabled={isProcessingTopup === req.id}
                                      className="px-5 py-2.5 bg-rose-50 text-rose-600 font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-rose-100 transition-all active:scale-95 disabled:opacity-50 border border-rose-100 flex items-center gap-2"
                                    >
                                      <div className="w-5 h-5 border-2 border-rose-500 text-rose-600 rounded-full flex items-center justify-center">
                                        <X size={10} strokeWidth={4} />
                                      </div>
                                      Reject
                                    </button>
                                  </div>
                                ) : (
                                  <div className="text-right">
                                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Admin Staff</p>
                                    <p className="text-[11px] font-bold text-slate-700 truncate max-w-[120px] ml-auto">
                                      {req.processedByName || (req.processedBy ? adminNamesMap[req.processedBy.toLowerCase()] : null) || req.processedBy?.split('@')[0] || 'Manager'}
                                    </p>
                                  </div>
                                )}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    ) : (
                      <table className="w-full text-left">
                        <thead>
                          <tr className="bg-slate-50/50">
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest w-16">S.No.</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">User / Method</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Withdrawal Details</th>
                            <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Net Payable</th>
                            <th className="px-6 py-4 text-right text-[10px] font-black text-slate-400 uppercase tracking-widest">Status/Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-50">
                          {withdrawalRequests.map((req, index) => (
                            <tr key={req.id} className="hover:bg-slate-50/30 transition-colors">
                              <td className="px-6 py-4">
                                <span className="text-xs font-black text-slate-400">#{index + 1}</span>
                              </td>
                              <td className="px-6 py-4">
                                <div className="flex items-start gap-3">
                                  <img
                                    src={req.userPhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(req.userName || 'U')}&background=random`}
                                    className="w-10 h-10 rounded-full border border-slate-100 object-cover shrink-0"
                                    alt=""
                                  />
                                  <div>
                                    <p className="font-black text-slate-900 text-sm whitespace-nowrap leading-tight">{req.userName || 'Unknown'}</p>
                                    <div className="flex items-center gap-2 mt-1">
                                      <span className={`px-2 py-0.5 rounded text-[9px] font-black uppercase ${req.paymentMethod === 'upi' ? 'bg-indigo-50 text-indigo-600' : 'bg-amber-50 text-amber-600'}`}>
                                        {req.paymentMethod}
                                      </span>
                                      <span className="text-[9px] text-slate-400 font-bold uppercase">{new Date(req.timestamp).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}</span>
                                    </div>
                                  </div>
                                </div>
                              </td>
                              <td className="px-6 py-4">
                                {req.paymentMethod === 'upi' ? (
                                  <div className="space-y-1">
                                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">UPI Details</p>
                                    <p className="text-sm font-bold text-slate-700 leading-none">{req.paymentDetails.upiId}</p>
                                    <p className="text-[9px] font-bold text-slate-500 uppercase tracking-tighter">Holder: {req.paymentDetails.holderName}</p>
                                  </div>
                                ) : (
                                  <div className="space-y-1">
                                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Bank Details</p>
                                    <p className="text-xs font-bold text-slate-700">A/C: {req.paymentDetails.accountNumber}</p>
                                    <p className="text-[9px] font-bold text-slate-500 uppercase tracking-tighter">IFSC: {req.paymentDetails.ifsc}</p>
                                    <p className="text-[9px] font-bold text-slate-500 uppercase tracking-tighter">Holder: {req.paymentDetails.holderName}</p>
                                  </div>
                                )}
                              </td>
                              <td className="px-6 py-4">
                                <p className="font-black text-slate-900 text-base leading-none">₹{req.inRupees.toLocaleString()}</p>
                                <p className="text-[10px] text-slate-500 font-bold mt-1.5 flex items-center gap-1">
                                  <Coins size={10} /> {req.amount.toLocaleString()} Coins
                                </p>
                              </td>
                              <td className="px-6 py-4">
                                {financeTabType === 'pending' ? (
                                  <div className="flex items-center justify-end gap-2">
                                    {req.paymentMethod === 'upi' && (
                                      <button
                                        onClick={() => {
                                          setPayQRRequest(req);
                                          setIsQRModalOpen(true);
                                        }}
                                        className="px-5 py-2.5 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-all shadow-md active:scale-95 flex items-center gap-2 text-[10px] font-black uppercase tracking-wider"
                                        title="Quick Pay with QR"
                                      >
                                        <div className="w-5 h-5 border-2 border-white/80 rounded-full flex items-center justify-center">
                                          <QrCode size={10} strokeWidth={3} />
                                        </div>
                                        Pay
                                      </button>
                                    )}
                                    <button
                                      onClick={() => setConfirmFinanceAction({ requestId: req.id, type: 'withdraw', action: 'approved', data: req })}
                                      disabled={isProcessingWithdrawal === req.id}
                                      className="px-5 py-2.5 bg-emerald-500 text-white font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-emerald-600 transition-all shadow-md active:scale-95 disabled:opacity-50 flex items-center gap-2"
                                    >
                                      {isProcessingWithdrawal === req.id ? (
                                        <Loader2 size={12} className="animate-spin" />
                                      ) : (
                                        <div className="w-5 h-5 border-2 border-white/80 rounded-full flex items-center justify-center">
                                          <Check size={10} strokeWidth={4} />
                                        </div>
                                      )}
                                      <span className="hidden sm:inline">Mark </span>Paid
                                    </button>
                                    <button
                                      onClick={() => setConfirmFinanceAction({ requestId: req.id, type: 'withdraw', action: 'rejected', data: req })}
                                      disabled={isProcessingWithdrawal === req.id}
                                      className="px-5 py-2.5 bg-rose-50 text-rose-600 font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-rose-100 transition-all active:scale-95 disabled:opacity-50 border border-rose-100 flex items-center gap-2"
                                    >
                                      <div className="w-5 h-5 border-2 border-rose-500 text-rose-600 rounded-full flex items-center justify-center">
                                        <X size={10} strokeWidth={4} />
                                      </div>
                                      Reject
                                    </button>
                                  </div>
                                ) : (
                                  <div className="text-right">
                                    <div className={`inline-block px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-widest mb-1.5 ${req.status === 'approved' ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>
                                      {req.status}
                                    </div>
                                    <p className="text-[9px] text-slate-400 font-bold uppercase">
                                      {req.processedByName || (req.processedBy ? adminNamesMap[req.processedBy.toLowerCase()] : null) || req.processedBy?.split('@')[0] || 'Admin'}
                                    </p>
                                  </div>
                                )}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    )}

                    {((financeSubTab === 'topups' && financeRequests.length === 0 && !isFetchingFinance) ||
                      (financeSubTab === 'withdrawals' && withdrawalRequests.length === 0 && !isFetchingWithdrawals)) && (
                        <div className="py-24 text-center">
                          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto text-slate-300 mb-4">
                            <CheckCircle2 size={32} />
                          </div>
                          <p className="text-slate-500 font-bold uppercase tracking-[0.2em] text-xs">Everything is up to date!</p>
                        </div>
                      )}
                  </div>

                  {((financeSubTab === 'topups' && hasMoreFinance) || (financeSubTab === 'withdrawals' && hasMoreWithdrawals)) && (
                    <div className="p-4 border-t border-slate-50 text-center bg-slate-50/20">
                      <button
                        onClick={() => financeSubTab === 'topups' ? fetchFinanceRequests(false) : fetchWithdrawalRequests(false)}
                        className="px-8 py-2.5 bg-white border border-slate-200 text-slate-600 font-black text-[10px] uppercase tracking-widest rounded-xl hover:bg-slate-50 transition-all shadow-sm mx-auto"
                      >
                        View Older Activity
                      </button>
                    </div>
                  )}
                </>
              )}
            </div>
          </div>
        </div>
      )}

      {activeTab === 'posts' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden flex flex-col min-h-[700px]">
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-emerald-500 text-white rounded-xl shadow-lg shadow-emerald-100 flex items-center justify-center">
                  <FileText size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <h3 className="text-xl font-black text-slate-900 leading-none">Official Updates</h3>
                  <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1.5 flex items-center gap-2">
                    Manage Blog Posts & News
                  </p>
                </div>
              </div>
              <button
                onClick={() => {
                  setEditingPostObj(null);
                  setPostFormData({
                    title: '', content: '', excerpt: '', imageUrl: '', category: '', slug: '', metaTitle: '', metaDescription: '', isActive: true, sendNotification: false
                  });
                  setShowAddPost(true);
                }}
                className="bg-emerald-500 text-white px-6 py-3 rounded-xl font-black text-xs uppercase tracking-widest hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 flex items-center gap-2 active:scale-95"
              >
                <Plus size={18} strokeWidth={3} />
                New Update
              </button>
            </div>

            <div className="flex-1 p-6 overflow-y-auto no-scrollbar bg-slate-50/20">
              {isFetchingPosts ? (
                <div className="flex flex-col items-center justify-center py-24">
                  <Loader2 className="animate-spin text-emerald-500 mb-4" size={40} />
                  <p className="text-slate-400 font-bold uppercase tracking-widest text-xs">Loading Updates...</p>
                </div>
              ) : adminPosts.length === 0 ? (
                <div className="py-24 text-center">
                  <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto text-slate-200 mb-4 shadow-inner border border-slate-100">
                    <Bell size={40} />
                  </div>
                  <p className="text-slate-500 font-bold uppercase tracking-[0.2em] text-xs">No updates published yet.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {adminPosts.map(post => (
                    <div key={post.id} className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden flex flex-col group hover:shadow-xl transition-all border-l-4 border-l-transparent hover:border-l-emerald-500">
                      {post.imageUrl && (
                        <div className="h-40 overflow-hidden relative">
                          <img src={post.imageUrl} alt={post.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                          <div className="absolute top-3 right-3">
                            <span className={`px-2.5 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest shadow-sm ${post.isActive ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-500'}`}>
                              {post.isActive ? 'Live' : 'Draft'}
                            </span>
                          </div>
                        </div>
                      )}
                      <div className="p-5 flex-1 flex flex-col">
                        <div className="flex items-center gap-2 mb-3">
                          <span className="bg-emerald-50 text-emerald-600 text-[10px] font-black uppercase tracking-tighter px-2 py-0.5 rounded">
                            {post.category || 'General'}
                          </span>
                          <span className="text-slate-300 text-[10px] font-black">•</span>
                          <span className="text-slate-400 text-[10px] font-bold">
                            {post.createdAt?.seconds ? new Date(post.createdAt.seconds * 1000).toLocaleDateString() : 'Recent'}
                          </span>
                        </div>
                        <h4 className="font-black text-slate-900 leading-tight mb-2 line-clamp-2">{post.title}</h4>
                        <p className="text-slate-500 text-xs line-clamp-2 mb-4 font-medium leading-relaxed">{post.excerpt}</p>

                        <div className="mt-auto pt-4 border-t border-slate-50 flex items-center justify-between">
                          <div className="flex items-center gap-1">
                            <button
                              onClick={() => {
                                setEditingPostObj(post);
                                setPostFormData({
                                  title: post.title,
                                  content: post.content,
                                  excerpt: post.excerpt,
                                  imageUrl: post.imageUrl || '',
                                  category: post.category || '',
                                  slug: post.slug,
                                  metaTitle: post.metaTitle || '',
                                  metaDescription: post.metaDescription || '',
                                  isActive: post.isActive,
                                  sendNotification: false
                                });
                                setShowAddPost(true);
                              }}
                              className="p-2 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-xl transition-all"
                            >
                              <Edit size={18} />
                            </button>
                            <button
                              onClick={() => {
                                setDeleteConfirm({
                                  type: 'post' as any,
                                  id: post.id,
                                  title: post.title
                                });
                              }}
                              className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-all"
                            >
                              <Trash2 size={18} />
                            </button>
                          </div>
                          <a
                            href={`/updates/${post.slug}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all"
                          >
                            <ExternalLink size={18} />
                          </a>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {activeTab === 'polls' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden flex flex-col min-h-[700px]">
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-emerald-500 text-white rounded-xl shadow-lg shadow-emerald-100 flex items-center justify-center">
                  <BarChart3 size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <h3 className="text-xl font-black text-slate-900 leading-none">Community Polls</h3>
                  <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1.5 flex items-center gap-2">
                    Engage with your community
                  </p>
                </div>
              </div>
              <button
                onClick={() => {
                  setEditingPoll({
                    question: '',
                    options: ['', ''],
                    targetSegment: 'all',
                    isActive: true,
                    votes: {},
                    voters: []
                  } as any);
                  setShowAddPoll(true);
                }}
                className="bg-emerald-500 text-white px-6 py-3 rounded-xl font-black text-xs uppercase tracking-widest hover:bg-emerald-600 transition-all flex items-center justify-center gap-2 active:scale-95 border border-emerald-600/10"
              >
                <Plus size={18} strokeWidth={3} />
                Create New Poll
              </button>
            </div>

            <div className="flex-1 p-6 overflow-y-auto no-scrollbar bg-slate-50/20">
              {isFetchingPolls ? (
                <div className="flex flex-col items-center justify-center py-24">
                  <Loader2 className="animate-spin text-emerald-500 mb-4" size={40} />
                  <p className="text-slate-400 font-bold uppercase tracking-widest text-xs">Loading Polls...</p>
                </div>
              ) : polls.length === 0 ? (
                <div className="py-24 text-center">
                  <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto text-slate-200 mb-4 shadow-inner border border-slate-100">
                    <BarChart3 size={40} />
                  </div>
                  <p className="text-slate-500 font-bold uppercase tracking-[0.2em] text-xs">No polls created yet.</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {polls.map(poll => {
                    const totalVotes: number = (Object.values(poll.votes || {}) as number[]).reduce((a: number, b: number) => a + b, 0);
                    const isExpired = poll.expiresAt && new Date(poll.expiresAt) < new Date();
                    
                    return (
                      <div key={poll.id} className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden flex flex-col group hover:shadow-xl transition-all">
                        <div className="p-5 flex-1 flex flex-col">
                          <div className="flex items-center justify-between mb-3">
                            <div className="flex items-center gap-2">
                              <span className={`px-2 py-0.5 rounded text-[9px] font-black uppercase tracking-widest ${poll.isActive && !isExpired ? 'bg-emerald-100 text-emerald-600' : 'bg-rose-100 text-rose-600'}`}>
                                {isExpired ? 'Expired' : (poll.isActive ? 'Active' : 'Inactive')}
                              </span>
                              <span className="bg-slate-50 text-slate-400 text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded">
                                {poll.targetSegment}
                              </span>
                            </div>
                            <span className="text-slate-400 text-[10px] font-bold">
                              {poll.createdAt?.seconds ? new Date(poll.createdAt.seconds * 1000).toLocaleDateString() : 'Recent'}
                            </span>
                          </div>
                          
                          <h4 className="font-black text-slate-900 leading-tight mb-4 line-clamp-2">{poll.question}</h4>
                          
                          <div className="space-y-2 mb-6">
                            {poll.options.map((opt, idx) => {
                              const v = poll.votes?.[idx] || 0;
                              const p = totalVotes > 0 ? Math.round((v / totalVotes) * 100) : 0;
                              return (
                                <div key={idx} className="relative h-8 bg-slate-50 rounded-lg overflow-hidden border border-slate-100/50">
                                  <div className="absolute inset-0 bg-emerald-500/5" style={{ width: `${p}%` }} />
                                  <div className="absolute inset-0 flex items-center justify-between px-3">
                                    <span className="text-[10px] font-bold text-slate-700 truncate mr-2">{opt}</span>
                                    <span className="text-[10px] font-black text-emerald-600">{p}%</span>
                                  </div>
                                </div>
                              );
                            })}
                          </div>

                          <div className="mt-auto pt-4 border-t border-slate-50 flex items-center justify-between">
                            <div className="flex items-center gap-2 text-slate-400">
                              <Users size={14} />
                              <span className="text-[10px] font-black uppercase tracking-widest">{totalVotes} Votes</span>
                            </div>
                            <div className="flex items-center gap-1">
                              <button
                                onClick={() => {
                                  setEditingPoll(poll);
                                  setShowAddPoll(true);
                                }}
                                className="p-2 text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 rounded-xl transition-all"
                              >
                                <Edit size={18} />
                              </button>
                              <button
                                onClick={() => {
                                  setDeleteConfirm({
                                    type: 'poll',
                                    id: poll.id,
                                    title: poll.question
                                  });
                                }}
                                className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-xl transition-all"
                              >
                                <Trash2 size={18} />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {activeTab === 'contests' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden min-h-[600px] flex flex-col">
            {/* Unified Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-emerald-500 text-white rounded-xl shadow-lg shadow-emerald-100 flex items-center justify-center">
                  <Trophy size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <h3 className="text-xl font-black text-slate-900 leading-none">Contest Arena</h3>
                  <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1.5 flex items-center gap-2">
                    Manage All Contests
                    <span className="w-1 h-1 bg-slate-300 rounded-full" />
                    {contests.length} Contests
                  </p>
                </div>
              </div>

              <div className="flex flex-wrap items-center gap-3">
                <button
                  onClick={() => fetchContests()}
                  disabled={isLoadingContests}
                  className="px-4 py-2 bg-white border border-slate-200 text-slate-600 font-black text-[10px] uppercase tracking-widest rounded-xl hover:bg-slate-50 transition-all shadow-sm active:scale-95 disabled:opacity-50 flex items-center gap-2"
                >
                  <RotateCcw size={14} className={isLoadingContests ? 'animate-spin' : ''} />
                  Refresh List
                </button>
              </div>
            </div>

            {/* Premium Sub-Navigation */}
            <div className="px-6 py-3 border-b border-slate-50 bg-white sticky top-0 z-10 overflow-x-auto no-scrollbar">
              <div className="flex items-center gap-1 min-w-max">
                {[
                  { id: 'all', label: 'All Contests', icon: Trophy },
                  { id: 'live', label: 'Live Now', icon: Radio },
                  { id: 'upcoming', label: 'Upcoming', icon: Clock },
                  { id: 'past', label: 'Past / Ended', icon: History }
                ].map(tab => {
                  const count = contests.filter(t => {
                    const now = new Date();
                    const startTime = t.scheduledStartTime ? new Date(t.scheduledStartTime) : null;
                    const endTime = t.scheduledEndTime ? new Date(t.scheduledEndTime) : null;
                    let s = t.isResultDeclared || (endTime && now > endTime) ? 'past' : (startTime && now < startTime ? 'upcoming' : 'live');
                    return tab.id === 'all' || s === tab.id;
                  }).length;

                  return (
                    <button
                      key={tab.id}
                      onClick={() => setContestFilter(tab.id as any)}
                      className={`flex items-center gap-2.5 px-5 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-tight transition-all active:scale-95 whitespace-nowrap ${contestFilter === tab.id
                        ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-100'
                        : 'text-slate-400 hover:text-slate-900 hover:bg-slate-50'
                        }`}
                    >
                      <tab.icon size={16} strokeWidth={contestFilter === tab.id ? 2.5 : 2} />
                      {tab.label}
                      <span className={`ml-1 px-2 py-0.5 rounded-lg text-[9px] font-bold ${contestFilter === tab.id ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-500'
                        }`}>
                        {count}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Card Content Grid */}
            <div className="flex-1 p-6 overflow-y-auto custom-scrollbar bg-slate-50/20">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {contests.length > 0 ? contests.filter(t => {
                  if (contestFilter === 'all') return true;
                  const now = new Date();
                  const startTime = t.scheduledStartTime ? new Date(t.scheduledStartTime) : null;
                  const endTime = t.scheduledEndTime ? new Date(t.scheduledEndTime) : null;
                  let s = t.isResultDeclared || (endTime && now > endTime) ? 'past' : (startTime && now < startTime ? 'upcoming' : 'live');
                  return s === contestFilter;
                }).map(t => {
                  const now = new Date();
                  const startTime = t.scheduledStartTime ? new Date(t.scheduledStartTime) : null;
                  const endTime = t.scheduledEndTime ? new Date(t.scheduledEndTime) : null;

                  let status: 'upcoming' | 'live' | 'past' = 'upcoming';
                  if (t.isResultDeclared || (endTime && now > endTime)) status = 'past';
                  else if (startTime && now < startTime) status = 'upcoming';
                  else status = 'live';

                  return (
                    <div key={t.testId} className={`group bg-white rounded-2xl border ${status === 'live' ? 'border-red-100 shadow-sm' : 'border-slate-100 shadow-sm'} overflow-hidden flex flex-col transition-all hover:shadow-xl hover:-translate-y-1`}>
                      {/* Card Top Header */}
                      <div className={`px-5 py-2.5 ${status === 'live' ? 'bg-red-50/30' : status === 'upcoming' ? 'bg-amber-50/30' : 'bg-slate-50/40'} border-b border-inherit relative`}>
                        <div className="flex items-center justify-between mb-2">
                          <span className={`px-2.5 py-1 rounded-full text-[9px] font-black uppercase tracking-widest flex items-center gap-1.5 shadow-sm ${status === 'live' ? 'bg-red-500 text-white' :
                            status === 'upcoming' ? 'bg-amber-500 text-white' :
                              'bg-slate-500 text-white'
                            }`}>
                            {status === 'live' && (
                              <span className="relative flex h-1.5 w-1.5">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-white"></span>
                              </span>
                            )}
                            {status}
                          </span>

                          <div className="flex items-center gap-1.5">
                            {t.isResultDeclared && (
                              <div className="bg-emerald-50 text-emerald-600 px-2 py-1 rounded-lg flex items-center gap-1 text-[9px] font-black uppercase tracking-tight">
                                <CheckCircle2 size={10} /> Finalized
                              </div>
                            )}
                            {status === 'live' && (
                              <button
                                onClick={async () => {
                                  if (window.confirm(`Send LIVE push notification for "${t.title}" to all users?`)) {
                                    try {
                                      const title = t.isTournament ? '🏆 Contest Live Now!' : '📝 Test Live Now!';
                                      const message = `"${t.title}" is now LIVE! Start participating to win rewards.`;
                                      await sendPushNotification('global', title, message, {
                                        testId: t.testId,
                                        actionUrl: `/dashboard?join=${t.testId}`,
                                        type: 'test_alert'
                                      });
                                      showToast('Live push notification sent!', 'success');
                                    } catch (err) {
                                      console.error('Error sending live notification:', err);
                                      showToast('Failed to send push notification.', 'error');
                                    }
                                  }
                                }}
                                className="p-2 text-slate-400 hover:text-orange-500 hover:bg-white rounded-full transition-all shadow-sm bg-white/50 border border-transparent hover:border-slate-100"
                                title="Send Live Notification"
                              >
                                <Bell size={14} className="animate-pulse text-orange-500" />
                              </button>
                            )}
                            <button
                              onClick={() => setManagingQuestionsFor(t)}
                              className="p-2 text-slate-400 hover:text-indigo-600 hover:bg-white rounded-full transition-all shadow-sm bg-white/50 border border-transparent hover:border-slate-100"
                              title="Manage Questions"
                            >
                              <FileText size={14} />
                            </button>
                            <button
                              onClick={() => {
                                setEditingTest(t);
                                setNewTest({
                                  ...t,
                                  examCategory: getValidExamCategory(t),
                                  testMode: t.testMode || (t.subject && t.topic ? 'sectional' : 'mock'),
                                  duration: isNaN(t.duration) ? 60 : t.duration,
                                  totalQuestions: isNaN(t.totalQuestions) ? 100 : t.totalQuestions,
                                  negativeMarking: isNaN(t.negativeMarking) ? 0.25 : t.negativeMarking,
                                  status: t.status || 'published',
                                  scheduledStartTime: t.scheduledStartTime,
                                  scheduledEndTime: t.scheduledEndTime,
                                  unlockPrice: t.unlockPrice || 0
                                });
                                setNotifyOnSave(t.status === 'published' || !t.status);
                                setShowAddTest(true);
                              }}
                              className="p-2 text-slate-400 hover:text-blue-600 hover:bg-white rounded-full transition-all shadow-sm bg-white/50 border border-transparent hover:border-slate-100"
                              title="Edit Settings"
                            >
                              <Edit size={14} />
                            </button>
                          </div>
                        </div>
                        <h4 className="font-black text-slate-900 leading-tight line-clamp-2 text-sm group-hover:text-indigo-600 transition-colors uppercase tracking-tight">{t.title}</h4>
                      </div>

                      {/* Card Content Body */}
                      <div className="p-5 flex-1 space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                          <div className="bg-slate-50/50 p-2.5 rounded-xl border border-slate-50">
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Starts At</p>
                            <p className="text-[11px] font-bold text-slate-700 truncate">
                              {startTime ? startTime.toLocaleString('en-IN', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', hour12: true }) : 'Not set'}
                            </p>
                          </div>
                          <div className="bg-slate-50/50 p-2.5 rounded-xl border border-slate-50">
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Ends At</p>
                            <p className="text-[11px] font-bold text-slate-700 truncate">
                              {endTime ? endTime.toLocaleString('en-IN', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit', hour12: true }) : 'Not set'}
                            </p>
                          </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div className="bg-slate-50/50 p-2.5 rounded-xl border border-slate-50">
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Fee / Winners</p>
                            <p className="text-[11px] font-bold text-slate-700">{t.entryFee || 0}C / {t.winnerCount || 10}</p>
                          </div>
                          <div className="bg-slate-50/50 p-2.5 rounded-xl border border-slate-50">
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Participation</p>
                            <p className="text-[11px] font-bold text-slate-700">{t.totalParticipants || 0} Members</p>
                          </div>
                        </div>

                        {status === 'past' && !t.isResultDeclared && (
                          <div className="p-3 bg-amber-50 rounded-xl border border-amber-100 flex items-center gap-3">
                            <AlertCircle size={18} className="text-amber-500 shrink-0" />
                            <p className="text-[11px] font-bold text-amber-700 leading-tight uppercase tracking-tight">Review rankings to declare results.</p>
                          </div>
                        )}
                      </div>

                      {/* Card Actions Footer */}
                      <div className="p-5 pt-0">
                        <button
                          onClick={async () => {
                            setSelectedContestForReview(t);
                            setIsDeclaringResults(true);
                            try {
                              // Fetch Questions first to calculate scores if missing
                              const qSnap = await getDocs(collection(db, 'tests', t.testId, 'questions'));
                              const questions = qSnap.docs.map(d => ({ questionId: d.id, ...d.data() } as Question));
                              setContestQuestions(questions);

                              const q = query(collection(db, 'attempts'), where('testId', '==', t.testId));
                              const snap = await getDocs(q);
                              const attempts = snap.docs.map(doc => {
                                const data = doc.data() as Attempt;
                                let score = data.score;
                                if (score === undefined || score === null) {
                                  // Calculate score on the fly for legacy attempts
                                  score = calculateAttemptMetrics(data, questions, t.negativeMarking || 0).score;
                                }
                                return { attemptId: doc.id, ...data, score } as Attempt;
                              });
                              setContestAttempts(attempts);

                              // Fetch missing user profiles for the attempts
                              const uniqueUserIds = Array.from(new Set(attempts.map(a => a.userId)));
                              if (uniqueUserIds.length > 0) {
                                const newUserMap = { ...contestUserMap };
                                // Fetch in chunks or one by one if few
                                for (const uid of uniqueUserIds) {
                                  if (!newUserMap[uid]) {
                                    const userDoc = await getDoc(doc(db, 'users', uid));
                                    if (userDoc.exists()) {
                                      newUserMap[uid] = userDoc.data() as UserProfile;
                                    }
                                  }
                                }
                                setContestUserMap(newUserMap);
                              }
                            } catch (err) {
                              console.error(err);
                              showToast('Error loading attempts', 'error');
                            } finally {
                              setIsDeclaringResults(false);
                            }
                          }}
                          className={`w-full py-3 rounded-xl font-black text-[10px] uppercase tracking-widest transition-all shadow-sm active:scale-95 flex items-center justify-center gap-2 ${t.isResultDeclared
                            ? 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                            : status === 'past'
                              ? 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-emerald-100'
                              : 'bg-white border border-slate-200 text-slate-600 hover:border-indigo-200 hover:text-indigo-600'
                            }`}
                        >
                          {t.isResultDeclared ? 'View Final Leaderboard' : status === 'past' ? 'Review & Declare Result' : 'Track Live Ranking'}
                          <ChevronRight size={14} strokeWidth={2.5} />
                        </button>
                      </div>
                    </div>
                  );
                }) : (
                  <div className="col-span-full py-24 flex flex-col items-center justify-center bg-white rounded-3xl border border-dashed border-slate-200">
                    <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4 border border-slate-100 shadow-inner">
                      <Trophy size={40} className="text-slate-200" strokeWidth={1.5} />
                    </div>
                    <h3 className="text-lg font-black text-slate-900 uppercase tracking-tight">No match found</h3>
                    <p className="text-slate-400 text-sm mt-1">Try switching tabs or refreshing the list.</p>
                    <button
                      onClick={() => fetchContests()}
                      className="mt-6 text-indigo-600 font-bold text-xs hover:underline uppercase tracking-widest"
                    >
                      + Refresh Database
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {showAddPattern && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[200] p-4">
          <div className="bg-white rounded-xl w-full max-w-2xl max-h-[90vh] shadow-2xl flex flex-col overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <h3 className="text-xl font-bold text-slate-900">Create Exam Pattern</h3>
              <button onClick={() => setShowAddPattern(false)} className="p-2 hover:bg-slate-100 rounded-lg transition-colors"><X size={20} /></button>
            </div>
            <div className="flex-1 overflow-y-auto p-6 space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Exam Name</label>
                  <input
                    type="text"
                    value={newPattern.examName}
                    onChange={e => setNewPattern({ ...newPattern, examName: capitalizeWords(e.target.value) })}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500"
                    placeholder="e.g. RRB NTPC Stage 1"
                  />
                </div>
                <CustomSelect
                  value={newPattern.category}
                  onChange={val => setNewPattern({ ...newPattern, category: val })}
                  options={[
                    { value: '', label: 'Select Root Category' },
                    ...examCategories.map(cat => ({ value: cat.name, label: cat.name }))
                  ]}
                  className="w-full"
                />
              </div>

              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-bold text-slate-700">Sections & Syllabus</label>
                  <button
                    onClick={() => setNewPattern({
                      ...newPattern,
                      sections: [...(newPattern.sections || []), { subject: '', questionCount: 10, topics: [] }]
                    })}
                    className="text-emerald-600 text-xs font-bold hover:underline"
                  >
                    Add Section
                  </button>
                </div>
                <div className="space-y-4">
                  {newPattern.sections?.map((section, idx) => (
                    <div key={idx} className="p-4 bg-slate-50 rounded-xl border border-slate-200 space-y-4 relative">
                      <button
                        onClick={() => {
                          const newSecs = [...(newPattern.sections || [])];
                          newSecs.splice(idx, 1);
                          setNewPattern({ ...newPattern, sections: newSecs });
                        }}
                        className="absolute top-4 right-4 text-slate-400 hover:text-red-500 transition-all active:scale-95"
                      >
                        <X size={16} />
                      </button>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <label className="text-xs font-bold text-slate-500 uppercase">Subject</label>
                          <input
                            type="text"
                            value={section.subject}
                            onChange={e => {
                              const newSecs = [...(newPattern.sections || [])];
                              newSecs[idx].subject = e.target.value;
                              setNewPattern({ ...newPattern, sections: newSecs });
                            }}
                            className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                            placeholder="e.g. Mathematics"
                          />
                        </div>
                        <div className="space-y-2">
                          <label className="text-xs font-bold text-slate-500 uppercase">Questions</label>
                          <input
                            type="number"
                            value={section.questionCount ?? ''}
                            onChange={e => {
                              const newSecs = [...(newPattern.sections || [])];
                              const val = parseInt(e.target.value);
                              newSecs[idx].questionCount = isNaN(val) ? 0 : val;
                              setNewPattern({ ...newPattern, sections: newSecs });
                            }}
                            className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <label className="text-xs font-bold text-slate-500 uppercase">Topics (Comma separated)</label>
                        <textarea
                          value={section.topics.join(', ')}
                          onChange={e => {
                            const newSecs = [...(newPattern.sections || [])];
                            newSecs[idx].topics = e.target.value.split(',').map(t => t.trim()).filter(Boolean);
                            setNewPattern({ ...newPattern, sections: newSecs });
                          }}
                          className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm h-20"
                          placeholder="Number System, Algebra, Percentage..."
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Total Duration (Mins)</label>
                  <input
                    type="number"
                    value={newPattern.totalDuration ?? ''}
                    onChange={e => {
                      const val = parseInt(e.target.value);
                      setNewPattern({ ...newPattern, totalDuration: isNaN(val) ? 0 : val });
                    }}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Negative Marking</label>
                  <input
                    type="number"
                    step="0.01"
                    value={newPattern.negativeMarking ?? ''}
                    onChange={e => {
                      const val = parseFloat(e.target.value);
                      setNewPattern({ ...newPattern, negativeMarking: isNaN(val) ? 0 : val });
                    }}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
              </div>
            </div>
            <div className="p-6 border-t border-slate-100 bg-slate-50 flex gap-4">
              <button
                onClick={() => setShowAddPattern(false)}
                className="flex-1 py-3 bg-white text-slate-700 font-bold rounded-xl border border-slate-200 hover:bg-slate-50 transition-all active:scale-95"
              >
                Cancel
              </button>
              <button
                onClick={async () => {
                  if (!newPattern.examName) return;
                  try {
                    await addDoc(collection(db, 'examPatterns'), {
                      ...newPattern,
                      createdAt: new Date().toISOString()
                    });
                    setShowAddPattern(false);
                  } catch (error) {
                    console.error('Error saving pattern', error);
                  }
                }}
                className="flex-1 py-3 bg-emerald-500 text-white font-bold rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 active:scale-95"
              >
                Save Pattern
              </button>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'users' && (
        <div>
          <div className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden">
            {/* Integrated Card Header */}
            <div className="p-6 border-b border-slate-100 flex flex-col md:flex-row md:items-center justify-between gap-4 bg-slate-50/30">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg shadow-sm border border-emerald-100">
                  <Users size={20} />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-slate-900">Registered Users</h3>
                  <p className="text-xs text-slate-500 font-medium">Manage and monitor your student community</p>
                </div>
              </div>

              <div className="flex flex-1 max-w-md relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
                <input
                  type="text"
                  placeholder="Search users by name or email..."
                  value={userSearchTerm}
                  onChange={(e) => setUserSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-medium shadow-sm"
                />
              </div>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left">
                <thead className="bg-slate-50/50 border-b border-slate-100">
                  <tr>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">User</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Contact</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Joined</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">XP / Coins</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Wallet</th>
                    <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Safety</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-50">
                  {users.map(u => (
                    <tr key={u.userId} className="hover:bg-slate-50/50 transition-colors">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <img
                            src={u.profilePhoto || `https://ui-avatars.com/api/?name=${u.name}`}
                            className="w-10 h-10 rounded-full object-cover border border-slate-100 shrink-0"
                            alt={u.name}
                          />
                          <div>
                            <p className="font-bold text-slate-900">{u.name}</p>
                            <p className="text-xs text-slate-500">{u.role === 'admin' ? 'Administrator' : 'Student'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex flex-col gap-2">
                          <div className="flex items-center gap-2 group/contact">
                            <div className="w-7 h-7 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center shrink-0 border border-blue-100 group-hover/contact:bg-blue-100 transition-colors">
                              <Mail size={14} />
                            </div>
                            <span className="text-sm text-slate-900 font-medium truncate max-w-[200px]">{u.email}</span>
                          </div>
                          <div className="flex items-center gap-2 group/contact">
                            <div className="w-7 h-7 bg-emerald-50 text-emerald-600 rounded-lg flex items-center justify-center shrink-0 border border-emerald-100 group-hover/contact:bg-emerald-100 transition-colors">
                              <Phone size={14} />
                            </div>
                            <span className="text-xs text-slate-500 font-medium">{u.phone || 'No phone'}</span>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider border ${u.subscriptionStatus === 'premium'
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-100'
                          : 'bg-slate-50 text-slate-500 border-slate-100'
                          }`}>
                          {u.subscriptionStatus}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-slate-500">
                        {new Date(u.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="text-sm">
                          <p className="text-amber-600 text-xs font-bold">{u.coins} Coins</p>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <button
                          onClick={() => {
                            setWalletModalUser(u);
                            setWalletCoinAmount(100);
                            setWalletReason('');
                          }}
                          title="Add coins to wallet"
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 text-amber-700 hover:bg-amber-100 border border-amber-200 rounded-xl text-[11px] font-black transition-all hover:scale-105 active:scale-95 whitespace-nowrap shadow-sm shadow-amber-100"
                        >
                          <Coins size={12} />
                          Add Coins
                        </button>
                      </td>
                      <td className="px-6 py-4 text-center border-l border-slate-50">
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => {
                              setSuspensionModalUser(u);
                              setSuspensionReason(u.banReason || '');
                              setSuspensionDuration('24h');
                            }}
                            className={`p-2 rounded-lg transition-all ${u.status === 'suspended' || u.status === 'banned'
                              ? 'bg-rose-50 text-rose-600 border border-rose-100'
                              : 'bg-slate-50 text-slate-400 border border-slate-100 hover:text-rose-500 hover:bg-rose-50'
                              }`}
                            title={u.status === 'suspended' || u.status === 'banned' ? 'Manage Suspension' : 'Suspend User'}
                          >
                            <ShieldAlert size={16} />
                          </button>
                          {u.violationCount && u.violationCount > 0 && (
                            <div className="relative group">
                              <div className="w-6 h-6 bg-amber-100 text-amber-600 rounded-lg flex items-center justify-center cursor-help animate-pulse border border-amber-200">
                                <AlertTriangle size={12} strokeWidth={3} />
                              </div>
                              <div className="absolute bottom-full mb-2 left-1/2 -translate-x-1/2 hidden group-hover:block w-48 bg-slate-900 text-white p-2 rounded-lg text-[10px] z-50 text-center shadow-2xl">
                                <p className="font-bold text-amber-400 mb-1 tracking-widest uppercase">Cheating Warning</p>
                                Detected {u.violationCount} suspicious activities (Tab switches) during live tests.
                                <div className="absolute top-full left-1/2 -translate-x-1/2 border-8 border-transparent border-t-slate-900" />
                              </div>
                            </div>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {users.length === 0 && !isLoadingUsers && (
              <div className="p-12 text-center">
                <Users size={48} className="mx-auto text-slate-200 mb-4" />
                <p className="text-slate-500">No users found in the database.</p>
              </div>
            )}
            {isLoadingUsers && (
              <div className="p-12 text-center">
                <Loader2 size={32} className="mx-auto text-emerald-500 animate-spin mb-4" />
                <p className="text-slate-500">Loading users...</p>
              </div>
            )}
            {hasMoreUsers && !isLoadingUsers && users.length > 0 && (
              <div className="p-6 border-t border-slate-50 text-center">
                <button
                  onClick={() => fetchUsers(false)}
                  className="px-6 py-2 bg-slate-900 text-white rounded-lg font-bold text-sm hover:bg-slate-800 transition-all"
                >
                  Load More Users
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {activeTab === 'tests' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 flex flex-col min-h-[700px]">
            {/* Unified Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col gap-6">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                  <div className="p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
                    <ClipboardList size={24} strokeWidth={3} />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-slate-900 leading-none">Test Repository</h3>
                    <p className="text-[11px] text-slate-400 font-bold mt-1.5 flex items-center gap-2">
                      Manage Exam Content & Syllabus
                      <span className="hidden sm:inline-flex items-center gap-2">
                        <span className="w-1 h-1 bg-slate-300 rounded-full" />
                        {tests.length} Items Syncing
                      </span>
                    </p>
                  </div>
                </div>

                <div className="flex flex-nowrap items-center gap-3 pb-1">
                  {selectedTests.size > 0 && (
                    <button
                      onClick={() => setShowBulkDeleteConfirm(true)}
                      className="flex items-center gap-2 px-5 h-12 bg-rose-50 text-rose-600 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all hover:bg-rose-100 border border-rose-100 shadow-sm active:scale-95 shrink-0"
                    >
                      <Trash2 size={16} />
                      Delete Selected ({selectedTests.size})
                    </button>
                  )}

                  <div className="flex items-center gap-1 bg-white px-1 h-12 rounded-lg border border-slate-200 shadow-sm shrink-0">
                    <button
                      onClick={handleDownloadSample}
                      className="p-2.5 text-slate-400 hover:text-emerald-500 hover:bg-emerald-50 rounded-xl transition-all"
                      title="Download Sample JSON"
                    >
                      <Download size={18} />
                    </button>
                    <label
                      className="p-2.5 text-slate-400 hover:text-emerald-500 hover:bg-emerald-50 rounded-xl transition-all cursor-pointer"
                      title="Import JSON Data"
                    >
                      <Upload size={18} />
                      <input type="file" accept=".json" className="hidden" onChange={handleImportJson} />
                    </label>
                    <button
                      onClick={() => setShowManageCategories(true)}
                      className="p-2.5 text-slate-400 hover:text-emerald-500 hover:bg-emerald-50 rounded-lg transition-all"
                      title="Manage Categories"
                    >
                      <LayoutGrid size={18} />
                    </button>
                  </div>

                  <div className="hidden lg:block w-56 shrink-0">
                    <CustomSelect
                      value={testFilter}
                      onChange={setTestFilter}
                      options={[
                        { value: 'all', label: 'All Exam Groups' },
                        ...examCategories.map(cat => ({ value: cat.name, label: cat.name }))
                      ]}
                      className="!space-y-0"
                    />
                  </div>

                  <div className="flex items-center gap-3 shrink-0">
                    <button
                      onClick={() => setShowAddTest(true)}
                      className="bg-emerald-500 text-white px-5 sm:px-6 h-12 rounded-lg font-black text-[11px] uppercase tracking-wider hover:bg-emerald-600 transition-all shadow-md shadow-emerald-900/20 flex items-center justify-center gap-2 active:scale-95 whitespace-nowrap"
                    >
                      <Plus size={18} strokeWidth={4} />
                      New Test
                    </button>

                    <button
                      onClick={() => fetchTests(true)}
                      disabled={isLoadingTests}
                      className="w-12 h-12 flex items-center justify-center bg-white border border-slate-200 text-slate-400 hover:text-emerald-500 hover:border-emerald-100 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-50"
                      title="Refresh List"
                    >
                      <RotateCcw size={18} className={isLoadingTests ? 'animate-spin' : ''} />
                    </button>
                  </div>
                </div>
              </div>

              {/* Search & Secondary Filter Bar */}
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pt-4 border-t border-slate-100/50">
                <div className="flex-1 relative group">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-500 transition-colors" size={18} />
                  <input
                    type="text"
                    placeholder="Search by title, exam group or test mode..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-12 pr-4 h-12 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 transition-all text-sm font-bold shadow-sm"
                  />
                </div>

                <div className="flex items-center gap-3 lg:hidden">
                  <div className="w-full sm:w-56">
                    <CustomSelect
                      value={testFilter}
                      onChange={setTestFilter}
                      options={[
                        { value: 'all', label: 'All Exam Groups' },
                        ...examCategories.map(cat => ({ value: cat.name, label: cat.name }))
                      ]}
                      className="!space-y-0"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Content Area */}
            <div className="flex-1 p-0 overflow-y-auto no-scrollbar bg-slate-50/20">
              <div className="space-y-4">
                {(() => {
                  if (filteredFlatTests.length === 0 && !isLoadingTests) {
                    return (
                      <div className="py-24 flex flex-col items-center justify-center bg-white rounded-xl border border-dashed border-slate-200">
                        <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mb-4 border border-slate-100 shadow-inner">
                          <FileText size={40} className="text-slate-200" strokeWidth={1.5} />
                        </div>
                        <h3 className="text-lg font-black text-slate-900 uppercase tracking-tight">No Tests Found</h3>
                        <p className="text-slate-400 text-sm mt-1">Try refining your search or filters.</p>
                      </div>
                    );
                  }

                  return (
                    <div className="bg-transparent overflow-x-auto custom-scrollbar">
                      <table className="w-full text-left border-collapse">
                        <thead>
                          <tr className="bg-slate-50/80 border-b border-slate-100">
                            <th className="px-4 py-3 w-10 text-center">
                              <div
                                onClick={() => {
                                  const allIds = filteredFlatTests.map(t => t.testId);
                                  const isAllSelected = filteredFlatTests.length > 0 && filteredFlatTests.every(t => selectedTests.has(t.testId));
                                  const newSelected = new Set(selectedTests);
                                  if (isAllSelected) allIds.forEach(id => newSelected.delete(id));
                                  else allIds.forEach(id => newSelected.add(id));
                                  setSelectedTests(newSelected);
                                }}
                                className={`w-5 h-5 mx-auto rounded flex items-center justify-center border-2 transition-all cursor-pointer ${filteredFlatTests.length > 0 && filteredFlatTests.every(t => selectedTests.has(t.testId))
                                  ? 'bg-emerald-500 border-emerald-500 shadow-sm shadow-emerald-500/20'
                                  : 'border-slate-300 bg-white hover:border-emerald-400'
                                  }`}
                              >
                                {filteredFlatTests.length > 0 && filteredFlatTests.every(t => selectedTests.has(t.testId)) && (
                                  <Check size={12} strokeWidth={4} className="text-white" />
                                )}
                              </div>
                            </th>
                            <th className="px-2 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest w-8 text-center">S.No</th>
                            <th className="px-4 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest min-w-[200px]">Test Details</th>
                            <th className="px-4 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest">Exam Group</th>
                            <th className="px-4 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest">Type / Mode</th>
                            <th className="px-4 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Config</th>
                            <th className="px-4 py-3 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Status</th>
                            <th className="px-4 py-3 text-right text-[10px] font-black text-slate-400 uppercase tracking-widest min-w-[220px]">Actions</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-50">
                          {filteredFlatTests.map((test, idx) => (
                            <tr key={test.testId} className={`hover:bg-slate-50/50 transition-colors group/row ${selectedTests.has(test.testId) ? 'bg-emerald-50/30' : ''}`}>
                              <td className="px-4 py-3 text-center">
                                <div
                                  onClick={() => {
                                    const newSelected = new Set(selectedTests);
                                    if (selectedTests.has(test.testId)) newSelected.delete(test.testId);
                                    else newSelected.add(test.testId);
                                    setSelectedTests(newSelected);
                                  }}
                                  className={`w-5 h-5 mx-auto rounded flex items-center justify-center border-2 transition-all cursor-pointer ${selectedTests.has(test.testId)
                                    ? 'bg-emerald-500 border-emerald-500 shadow-sm shadow-emerald-500/20'
                                    : 'border-slate-200 bg-white hover:border-emerald-300'
                                    }`}
                                >
                                  {selectedTests.has(test.testId) && <Check size={12} strokeWidth={4} className="text-white" />}
                                </div>
                              </td>
                              <td className="px-2 py-3 text-xs sm:text-sm font-black text-slate-900 text-center">
                                {idx + 1}
                              </td>
                              <td className="px-4 py-3">
                                <div className="flex flex-col">
                                  <div className="flex items-center gap-2">
                                    <span className="font-black text-slate-900 text-xs sm:text-sm truncate max-w-[250px]">{test.title}</span>
                                    {test.isPremium && <span className="text-[8px] bg-amber-500 text-white px-1.5 py-0.5 rounded-full font-black uppercase">Pro</span>}
                                    {test.isTournament && <span className="text-[8px] bg-indigo-500 text-white px-1.5 py-0.5 rounded-full font-black uppercase">Tournament</span>}
                                  </div>
                                  <p className="text-[9px] text-slate-400 font-bold mt-0.5 uppercase tracking-tighter">
                                    Created: {new Date(test.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: '2-digit' })}
                                  </p>
                                </div>
                              </td>
                              <td className="px-4 py-3">
                                <span className="text-[10px] font-black text-slate-600 bg-slate-100 px-2 py-1 rounded uppercase tracking-tight">
                                  {test.examCategory || 'General'}
                                </span>
                              </td>
                              <td className="px-4 py-3">
                                <div className="flex items-center gap-2">
                                  <span className={`w-2 h-2 rounded-full ${test.testMode === 'mock' ? 'bg-blue-400' :
                                    test.testMode === 'sectional' ? 'bg-purple-400' : 'bg-amber-400'
                                    }`} />
                                  <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">{test.testMode || 'mock'}</span>
                                </div>
                              </td>
                              <td className="px-4 py-3 text-center">
                                <div className="flex flex-col gap-1 items-center">
                                  <span className="text-[10px] font-black text-slate-700 bg-slate-100 px-2 py-0.5 rounded-md min-w-[45px]">{test.duration}m</span>
                                  <span className="text-[10px] font-black text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-md min-w-[45px]">{test.totalQuestions} Qs</span>
                                </div>
                              </td>
                              <td className="px-4 py-3 text-center">
                                <span className={`text-[9px] font-black uppercase px-2 py-1 rounded-full border ${test.status === 'published' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 'bg-rose-50 text-rose-600 border-rose-100'
                                  }`}>
                                  {test.status}
                                </span>
                              </td>
                              <td className="px-4 py-3">
                                <div className="flex items-center justify-end gap-1">
                                  {/* Promotion / Contest Scheduling Action */}
                                  <button
                                    onClick={() => {
                                      setEditingTest(test);
                                      setNewTest({
                                        ...test,
                                        isTournament: true,
                                        examCategory: getValidExamCategory(test),
                                        testMode: test.testMode || 'mock',
                                        duration: isNaN(test.duration) ? 60 : test.duration,
                                        totalQuestions: isNaN(test.totalQuestions) ? 100 : test.totalQuestions,
                                        status: 'published',
                                        scheduledStartTime: test.scheduledStartTime || new Date(Date.now() + 86400000).toISOString().slice(0, 16),
                                        scheduledEndTime: test.scheduledEndTime || new Date(Date.now() + 86400000 + 3600000).toISOString().slice(0, 16),
                                        entryFee: test.entryFee || 10,
                                        winnerCount: test.winnerCount || 10
                                      });
                                      setNotifyOnSave(true);
                                      setShowAddTest(true);
                                    }}
                                    className="p-2 text-slate-400 hover:text-rose-500 hover:bg-rose-50 rounded-lg transition-all"
                                    title="Schedule as Contest"
                                  >
                                    <Radio size={16} strokeWidth={2.5} />
                                  </button>
                                  <button
                                    onClick={() => setViewingLeaderboardFor(test)}
                                    className="p-2 text-slate-400 hover:text-amber-500 hover:bg-amber-50 rounded-lg transition-all"
                                    title="Leaderboard"
                                  >
                                    <Trophy size={16} />
                                  </button>
                                  <button
                                    onClick={async () => {
                                      if (window.confirm(`Send push notification for "${test.title}" to all users?`)) {
                                        const title = test.isTournament ? '🏆 New Tournament Live!' : '📝 New Test Available!';
                                        const message = `Check out "${test.title}" on Rankearn. Start practicing now!`;
                                        await sendPushNotification('global', title, message, {
                                          testId: test.testId,
                                          actionUrl: `/dashboard?join=${test.testId}`,
                                          type: 'test_alert'
                                        });
                                        showToast('Push notification broadcasted!', 'success');
                                      }
                                    }}
                                    className="p-2 text-slate-400 hover:text-orange-500 hover:bg-orange-50 rounded-lg transition-all"
                                    title="Push Notify All"
                                  >
                                    <Bell size={16} className="animate-pulse" />
                                  </button>
                                  <button
                                    onClick={() => fetchTestAnalytics(test)}
                                    className="p-2 text-slate-400 hover:text-emerald-500 hover:bg-emerald-50 rounded-lg transition-all"
                                    title="Analytics"
                                  >
                                    <LineChart size={16} />
                                  </button>
                                  <button onClick={() => setManagingQuestionsFor(test)} className="p-2 text-slate-400 hover:text-blue-500 hover:bg-blue-50 rounded-lg transition-all" title="Questions"><FileText size={16} /></button>
                                  <button
                                    onClick={() => {
                                      setEditingTest(test);
                                      setNewTest({
                                        ...test,
                                        examCategory: getValidExamCategory(test),
                                        testMode: test.testMode || (test.subject && test.topic ? 'sectional' : 'mock'),
                                        duration: isNaN(test.duration) ? 60 : test.duration,
                                        totalQuestions: isNaN(test.totalQuestions) ? 100 : test.totalQuestions,
                                        negativeMarking: isNaN(test.negativeMarking) ? 0.25 : test.negativeMarking,
                                        status: test.status || 'published',
                                        scheduledStartTime: test.scheduledStartTime,
                                        scheduledEndTime: test.scheduledEndTime,
                                        leaderboardLimit: test.leaderboardLimit,
                                        winnerCount: test.winnerCount
                                      });
                                      setNotifyOnSave(test.status === 'published' || !test.status);
                                      setShowAddTest(true);
                                    }}
                                    className="p-2 text-slate-400 hover:text-indigo-500 hover:bg-indigo-50 rounded-lg transition-all"
                                    title="Edit Settings"
                                  >
                                    <Edit size={16} />
                                  </button>
                                  <button onClick={() => setDeleteConfirm({ type: 'test', id: test.testId, title: test.title })} className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-all" title="Delete"><Trash2 size={16} /></button>
                                </div>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  );
                })()}

                {isLoadingTests && (
                  <div className="p-12 text-center bg-white rounded-3xl border border-slate-100 shadow-sm">
                    <Loader2 size={32} className="mx-auto text-emerald-500 animate-spin mb-4" />
                    <p className="text-slate-500 font-bold text-sm">Loading test database...</p>
                  </div>
                )}

                {hasMoreTests && !isLoadingTests && tests.length > 0 && (
                  <div className="py-8 text-center">
                    <button
                      onClick={() => fetchTests(false)}
                      className="px-10 py-4 bg-slate-900 text-white rounded-2xl font-black text-[12px] uppercase tracking-widest shadow-xl shadow-slate-200 hover:shadow-2xl hover:-translate-y-0.5 transition-all active:scale-95"
                    >
                      Load More Documents
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'wheel' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden min-h-[600px] flex flex-col">
            {/* Unified Master Header */}
            <div className="p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col sm:flex-row sm:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-amber-500 text-white rounded-xl shadow-lg shadow-amber-100 flex items-center justify-center">
                  <Trophy size={24} strokeWidth={2.5} />
                </div>
                <div>
                  <h3 className="text-xl font-black text-slate-900 leading-none">Lucky Wheel</h3>
                  <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1.5 flex items-center gap-2">
                    Manage Rewards & Distribution
                    <span className="w-1 h-1 bg-slate-300 rounded-full" />
                    {wheelConfig?.slices.length || 0} Reward Slices
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-4">
                {/* Modern Status Toggle */}
                <div className="flex items-center gap-3 bg-white px-4 py-2 rounded-xl border border-slate-100 shadow-sm">
                  <span className={`text-[10px] font-black uppercase tracking-tighter transition-colors ${wheelConfig?.isActive ? 'text-emerald-500' : 'text-slate-400'}`}>
                    {wheelConfig?.isActive ? 'Wheel Active' : 'Wheel Offline'}
                  </span>
                  <button
                    onClick={handleToggleWheelStatus}
                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-all duration-300 ${wheelConfig?.isActive ? 'bg-emerald-500 shadow-sm shadow-emerald-100' : 'bg-slate-200'}`}
                  >
                    <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform duration-300 ${wheelConfig?.isActive ? 'translate-x-6' : 'translate-x-1'}`} />
                  </button>
                </div>

                <button
                  onClick={handleSaveWheelConfig}
                  disabled={isSavingWheelConfig || !wheelConfig}
                  className="px-6 py-2.5 bg-slate-900 text-white font-black text-[11px] uppercase tracking-wider rounded-xl hover:bg-slate-800 transition-all shadow-lg active:scale-95 disabled:opacity-50 flex items-center gap-2"
                >
                  {isSavingWheelConfig ? <Loader2 className="animate-spin" size={14} /> : <CheckCircle2 size={14} />}
                  Save
                </button>
              </div>
            </div>

            <div className="flex-1 p-6 overflow-y-auto custom-scrollbar">
              {wheelConfig ? (
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
                  {/* Left Section: Settings & Summary */}
                  <div className="lg:col-span-4 space-y-6">
                    <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm space-y-6 sticky top-0">
                      <div>
                        <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2 px-1">Spin Cost (Coins)</label>
                        <div className="relative group">
                          <div className="absolute left-4 top-1/2 -translate-y-1/2 text-amber-500">
                            <Coins size={18} />
                          </div>
                          <input
                            type="number"
                            value={wheelConfig.spinCost}
                            onChange={e => setWheelConfig({ ...wheelConfig, spinCost: Math.max(0, parseInt(e.target.value) || 0) })}
                            className="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 outline-none font-bold text-slate-700 transition-all text-lg"
                            placeholder="10"
                          />
                        </div>
                      </div>

                      {/* Live Probability Tracker */}
                      <div className="space-y-4">
                        <div className="flex items-center justify-between px-1">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Total Weight</label>
                          {(() => {
                            const total = wheelConfig.slices.reduce((acc, s) => acc + (Number(s.probability) || 0), 0);
                            const isBalanced = Math.abs(total - 100) < 0.1;
                            return (
                              <span className={`text-xs font-black ${isBalanced ? 'text-emerald-500' : 'text-rose-500 blink-slow'}`}>
                                {total}% / 100%
                              </span>
                            );
                          })()}
                        </div>
                        {(() => {
                          const total = wheelConfig.slices.reduce((acc, s) => acc + (Number(s.probability) || 0), 0);
                          return (
                            <div className="h-4 bg-slate-100 rounded-full overflow-hidden shadow-inner flex">
                              <motion.div
                                initial={{ width: 0 }}
                                animate={{ width: `${Math.min(100, (total / 100) * 100)}%` }}
                                className={`h-full transition-all duration-500 ${Math.abs(total - 100) < 0.1 ? 'bg-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.3)]' : 'bg-rose-500 shadow-[0_0_15px_rgba(244,63,94,0.3)]'}`}
                              />
                            </div>
                          );
                        })()}
                        <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
                          <div className="flex gap-3">
                            <AlertCircle size={16} className="text-slate-400 shrink-0 mt-0.5" />
                            <p className="text-xs text-slate-500 font-medium leading-relaxed">
                              Ensure the total weight adds up to exactly <span className="text-slate-900 font-bold">100%</span> for optimal user experience. Higher weight increases the chance of winning that reward.
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Right Section: Slices Editor */}
                  <div className="lg:col-span-8 space-y-6">
                    <div className="flex items-center justify-between bg-white px-6 py-4 rounded-2xl border border-slate-100 shadow-sm">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-indigo-50 text-indigo-600 rounded-lg flex items-center justify-center">
                          <Layers size={16} />
                        </div>
                        <h4 className="font-bold text-slate-800">Reward Slices</h4>
                      </div>
                      <button
                        onClick={handleAddSlice}
                        className="flex items-center gap-2 px-4 py-2 bg-emerald-50 text-emerald-600 hover:bg-emerald-100 border border-emerald-100 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all active:scale-95"
                      >
                        <Plus size={16} strokeWidth={3} />
                        Add Slice
                      </button>
                    </div>

                    <div className="space-y-4">
                      <AnimatePresence mode="popLayout">
                        {wheelConfig.slices.map((slice, idx) => (
                          <motion.div
                            key={idx}
                            layout
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                            className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:border-emerald-200 transition-all group"
                          >
                            <div className="flex flex-col md:flex-row items-start md:items-center gap-6">
                              {/* Color & Label Info */}
                              <div className="flex items-center gap-4 min-w-[200px]">
                                <div className="relative">
                                  <div className="w-12 h-12 rounded-2xl shadow-lg border-2 border-white flex items-center justify-center group-hover:scale-110 transition-transform" style={{ backgroundColor: slice.color }}>
                                    {slice.type === 'coins' ? <Coins size={20} className="text-white/80" /> : <XCircle size={20} className="text-white/80" />}
                                  </div>
                                  <input
                                    type="color"
                                    value={slice.color}
                                    onChange={e => {
                                      const updated = [...wheelConfig.slices];
                                      updated[idx].color = e.target.value;
                                      setWheelConfig({ ...wheelConfig, slices: updated });
                                    }}
                                    className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full cursor-pointer border-2 border-white shadow-sm opacity-0 group-hover:opacity-100 transition-opacity"
                                  />
                                </div>
                                <div className="flex-1">
                                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block mb-1">Slice Label</label>
                                  <input
                                    type="text"
                                    value={slice.label}
                                    onChange={e => {
                                      const updated = [...wheelConfig.slices];
                                      updated[idx].label = e.target.value;
                                      setWheelConfig({ ...wheelConfig, slices: updated });
                                    }}
                                    className="w-full bg-transparent font-black text-slate-900 outline-none focus:text-indigo-600 transition-colors"
                                  />
                                </div>
                              </div>

                              {/* Controls Grid */}
                              <div className="flex-1 grid grid-cols-2 lg:grid-cols-3 gap-6 w-full">
                                <div>
                                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block mb-1.5">Value</label>
                                  <input
                                    type="number"
                                    value={slice.value}
                                    onChange={e => {
                                      const updated = [...wheelConfig.slices];
                                      updated[idx].value = parseInt(e.target.value) || 0;
                                      setWheelConfig({ ...wheelConfig, slices: updated });
                                    }}
                                    className="w-full bg-slate-50 px-3 py-2 rounded-lg text-xs font-bold border border-slate-200 outline-none focus:border-emerald-500 focus:bg-white transition-all shadow-inner"
                                  />
                                </div>
                                <div>
                                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block mb-1.5">Prob. (%)</label>
                                  <input
                                    type="number"
                                    value={slice.probability}
                                    onChange={e => {
                                      const updated = [...wheelConfig.slices];
                                      updated[idx].probability = parseFloat(e.target.value) || 0;
                                      setWheelConfig({ ...wheelConfig, slices: updated });
                                    }}
                                    className="w-full bg-slate-50 px-3 py-2 rounded-lg text-xs font-bold border border-slate-200 outline-none focus:border-emerald-500 focus:bg-white transition-all shadow-inner"
                                  />
                                </div>
                                <div className="col-span-2 lg:col-span-1">
                                  <label className="text-[9px] font-black text-slate-400 uppercase tracking-widest block mb-1.5">Reward Type</label>
                                  <select
                                    value={slice.type}
                                    onChange={e => {
                                      const updated = [...wheelConfig.slices];
                                      updated[idx].type = e.target.value as any;
                                      setWheelConfig({ ...wheelConfig, slices: updated });
                                    }}
                                    className="w-full bg-slate-50 px-3 py-2 rounded-lg text-xs font-bold border border-slate-200 outline-none focus:border-indigo-500 focus:bg-white transition-all shadow-inner appearance-none lowercase tracking-widest"
                                  >
                                    <option value="coins">Coins</option>
                                    <option value="nothing">Nothing</option>
                                  </select>
                                </div>
                              </div>

                              <button
                                onClick={() => handleDeleteSlice(idx)}
                                className="p-3 text-slate-300 hover:text-rose-500 hover:bg-rose-50 rounded-xl transition-all self-end md:self-center opacity-0 group-hover:opacity-100"
                                title="Remove Slice"
                              >
                                <Trash2 size={20} />
                              </button>
                            </div>
                          </motion.div>
                        ))}
                      </AnimatePresence>
                    </div>

                    {wheelConfig.slices.length === 0 && (
                      <div className="py-20 text-center bg-white rounded-2xl border border-dashed border-slate-200">
                        <Dices size={48} className="mx-auto text-slate-200 mb-4" />
                        <p className="text-slate-500 font-bold uppercase tracking-widest text-xs">No reward slices configured</p>
                        <button
                          onClick={handleAddSlice}
                          className="mt-4 text-emerald-500 font-black text-[10px] uppercase tracking-widest hover:underline"
                        >
                          + Add Your First Slice
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center h-[500px]">
                  <Loader2 className="animate-spin text-amber-500 mb-4" size={40} />
                  <p className="text-slate-500 font-black text-xs uppercase tracking-[0.2em]">Synchronizing Wheel Config...</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}


      {activeTab === 'leaderboard' && (
        <div className="w-full">
          <Leaderboard />
        </div>
      )}

      {activeTab === 'banners' && (
        <div className="space-y-6">
          <div className="bg-white rounded-xl border border-slate-100 shadow-xl overflow-hidden flex flex-col min-h-[600px]">
            {/* Unified Master Header */}
            <div className="bg-slate-50/50 border-b border-slate-100 p-4 sm:p-6">
              <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-emerald-500 rounded-xl flex items-center justify-center shadow-lg shadow-emerald-100 shrink-0">
                    <ImageIcon className="text-white" size={24} />
                  </div>
                  <div>
                    <h2 className="text-xl sm:text-2xl font-black text-slate-900 tracking-tight">Banner Management</h2>
                    <p className="text-slate-500 text-xs sm:text-sm font-medium">Manage Banners and Spotlight</p>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-3">
                  <button
                    onClick={() => {
                      setEditingBanner(null);
                      setSpotlightData({ score: '', rank: '', examName: '', message: '', priority: 0, isActive: true });
                      setSpotlightFoundUser(null);
                      setSpotlightSearchTerm('');
                      setShowAddSpotlight(true);
                    }}
                    className="flex-1 sm:flex-none px-5 py-2.5 bg-amber-500 text-white font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-amber-600 transition-all shadow-md active:scale-95 flex items-center justify-center gap-2"
                  >
                    <Plus size={14} />
                    Spotlight
                  </button>
                  <button
                    onClick={() => {
                      setEditingBanner(null);
                      setNewBanner({ title: '', link: '', isActive: true, priority: 0 });
                      setBannerFile(null);
                      setShowAddBanner(true);
                    }}
                    className="flex-1 sm:flex-none px-5 py-2.5 bg-emerald-600 text-white font-black text-[11px] uppercase tracking-wider rounded-lg hover:bg-emerald-700 transition-all shadow-md active:scale-95 flex items-center justify-center gap-2"
                  >
                    <Plus size={14} />
                    Banner
                  </button>
                  <button
                    onClick={() => fetchBanners()}
                    disabled={isFetchingBanners}
                    className="p-2.5 bg-white border border-slate-200 text-slate-400 rounded-lg hover:text-emerald-600 hover:border-emerald-200 hover:bg-emerald-50 transition-all active:scale-90"
                    title="Refresh Banners"
                  >
                    <RotateCcw size={18} className={isFetchingBanners ? 'animate-spin text-emerald-500' : ''} />
                  </button>
                </div>
              </div>

              {/* Sub-navigation Tabs */}
              <div className="flex items-center gap-1 mt-6 bg-slate-100/50 p-1.5 rounded-xl w-fit overflow-x-auto no-scrollbar max-w-full">
                {[
                  { id: 'all', label: 'All Items', icon: Layout },
                  { id: 'promotional', label: 'Promotional', icon: ImageIcon },
                  { id: 'spotlights', label: 'Spotlights', icon: Star }
                ].map((tab) => (
                  <button
                    key={tab.id}
                    onClick={() => setBannerSubTab(tab.id as any)}
                    className={`flex items-center gap-2 px-6 py-2.5 rounded-lg text-xs font-black transition-all whitespace-nowrap uppercase tracking-wider ${bannerSubTab === tab.id
                      ? 'bg-white text-emerald-600 shadow-sm'
                      : 'text-slate-500 hover:bg-white/50 hover:text-slate-900'
                      }`}
                  >
                    <tab.icon size={14} />
                    {tab.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Unified Body */}
            <div className="flex-1 p-6">
              {isFetchingBanners ? (
                <div className="h-96 flex flex-col items-center justify-center">
                  <div className="relative">
                    <div className="w-16 h-16 border-4 border-emerald-100 rounded-full animate-spin border-t-emerald-500"></div>
                    <ImageIcon className="absolute inset-0 m-auto text-emerald-500 animate-pulse" size={24} />
                  </div>
                  <p className="mt-4 text-slate-400 font-black text-[10px] uppercase tracking-[0.2em]">Synchronizing Banners...</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                  {banners
                    .filter(b => {
                      if (bannerSubTab === 'promotional') return b.type !== 'spotlight';
                      if (bannerSubTab === 'spotlights') return b.type === 'spotlight';
                      return true;
                    })
                    .map(banner => (
                      <div key={banner.id} className="bg-white rounded-xl border border-slate-100 shadow-sm overflow-hidden flex flex-col group hover:shadow-xl hover:border-emerald-100 transition-all duration-300">
                        {/* Preview Area */}
                        <div className="aspect-[21/9] relative overflow-hidden bg-slate-50 flex items-center justify-center">
                          {banner.type === 'spotlight' ? (
                            <div className="absolute inset-0 bg-gradient-to-br from-amber-400 to-orange-500 flex flex-col items-center justify-center text-white p-4">
                              <Star size={48} className="text-white/20 absolute -right-4 -top-4 rotate-12" />
                              <div className="w-12 h-12 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center mb-2 shadow-lg">
                                <Star size={24} className="text-white fill-white" />
                              </div>
                              <h3 className="font-black text-lg tracking-tight text-center leading-tight">{banner.spotlightData?.userName}</h3>
                              <p className="text-[10px] font-black uppercase tracking-widest text-white/80 mt-1">{banner.spotlightData?.examName}</p>
                            </div>
                          ) : (
                            <img src={banner.imageUrl} alt={banner.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                          )}

                          {/* Clicks Stat Overlay - Top Left */}
                          {banner.clicks !== undefined && (
                            <div className="absolute top-3 left-3 bg-white/90 backdrop-blur-md text-emerald-600 px-2.5 py-1.5 rounded-xl shadow-lg border border-white/50 text-[10px] font-black uppercase tracking-wider flex items-center gap-1.5 z-10">
                              <TrendingUp size={12} className="text-emerald-500" />
                              <span>{banner.clicks} Clicks</span>
                            </div>
                          )}

                          {/* Edit Button Overlay - Top Right (Visible on mobile, hover on desktop) */}
                          <div className="absolute top-3 right-3 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 translate-y-0 sm:translate-y-[-10px] sm:group-hover:translate-y-0 transition-all duration-300 z-10">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                setEditingBanner(banner);
                                if (banner.type === 'spotlight') {
                                  setSpotlightData({
                                    score: String(banner.spotlightData?.score || ''),
                                    rank: String(banner.spotlightData?.rank || ''),
                                    examName: banner.spotlightData?.examName || '',
                                    message: banner.spotlightData?.message || '',
                                    priority: banner.priority || 0,
                                    isActive: banner.isActive
                                  });
                                  setShowAddSpotlight(true);
                                } else {
                                  setNewBanner({
                                    title: banner.title || '',
                                    link: banner.link || '',
                                    isActive: banner.isActive,
                                    priority: banner.priority || 0,
                                    imageUrl: banner.imageUrl
                                  });
                                  setShowAddBanner(true);
                                }
                              }}
                              className="p-2 bg-white/90 backdrop-blur-md text-indigo-600 rounded-full shadow-lg border border-white/50 hover:bg-white hover:scale-110 transition-all"
                              title="Edit Banner"
                            >
                              <SquarePen size={16} />
                            </button>
                          </div>
                        </div>

                        {/* Info Area */}
                        <div className="p-5 flex-1 flex flex-col space-y-4">
                          <div className="flex items-start justify-between gap-3">
                            <div className="flex-1 min-w-0">
                              <h3 className="font-black text-slate-900 text-sm leading-snug line-clamp-1 group-hover:text-emerald-600 transition-colors">
                                {banner.title || (banner.type === 'spotlight' ? 'Top Scorer Spotlight' : 'Promotional Banner')}
                              </h3>
                              <div className="flex items-center gap-2 mt-1">
                                <span className={`text-[9px] font-black px-1.5 py-0.5 rounded uppercase tracking-widest border ${banner.type === 'spotlight'
                                  ? 'bg-amber-50 text-amber-600 border-amber-100'
                                  : 'bg-indigo-50 text-indigo-600 border-indigo-100'
                                  }`}>
                                  {banner.type === 'spotlight' ? 'Spotlight' : 'Promotional'}
                                </span>
                                <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">
                                  Priority {banner.priority}
                                </span>

                                {banner.scheduledAt && new Date(banner.scheduledAt) > new Date() && (
                                  <span className="flex items-center gap-1 text-[9px] font-black text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded border border-amber-100 uppercase tracking-widest">
                                    <Clock size={10} /> Scheduled
                                  </span>
                                )}
                              </div>
                            </div>

                            {/* Actions Horizontally Aligned on Right */}
                            <div className="flex items-center gap-2 shrink-0">
                              <button
                                onClick={() => handleToggleBanner(banner)}
                                className={`px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-widest border transition-all active:scale-95 ${banner.isActive
                                  ? 'bg-emerald-50 text-emerald-600 border-emerald-100 shadow-sm shadow-emerald-50'
                                  : 'bg-slate-50 text-slate-400 border-slate-100'
                                  }`}
                              >
                                {banner.isActive ? 'Active' : 'Hidden'}
                              </button>
                              <button
                                onClick={() => setDeleteConfirm({ type: 'banner', id: banner.id, title: banner.title || (banner.type === 'spotlight' ? 'Top Scorer Spotlight' : 'Promotional Banner'), metadata: { imageUrl: banner.imageUrl } })}
                                className="p-2 bg-rose-50 text-rose-500 rounded-lg border border-rose-100 hover:bg-rose-500 hover:text-white transition-all active:scale-90"
                                title="Delete Banner"
                              >
                                <Trash2 size={16} />
                              </button>
                            </div>
                          </div>

                          {banner.link && (
                            <div className="flex items-center gap-2 text-[11px] font-bold text-slate-500 bg-slate-50 px-3 py-2 rounded-xl group-hover:bg-emerald-50 group-hover:text-emerald-600 transition-colors">
                              <Globe size={14} className="shrink-0" />
                              <span className="truncate">{banner.link}</span>
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                </div>
              )}

              {!isFetchingBanners && banners.length === 0 && (
                <div className="h-96 flex flex-col items-center justify-center text-center px-6">
                  <div className="w-20 h-20 bg-slate-50 rounded-3xl flex items-center justify-center text-slate-200 mb-4 border border-dashed border-slate-200">
                    <ImageIcon size={40} />
                  </div>
                  <h3 className="text-lg font-black text-slate-900 uppercase tracking-tight">Gallery is Empty</h3>
                  <p className="text-slate-500 text-sm mt-1 max-w-[280px]">No banners or spotlights found in your database. Start by adding one above.</p>
                </div>
              )}
            </div>
          </div>

          {/* Add Spotlight Modal */}
            {showAddSpotlight && createPortal(
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4"
              >
                <motion.div
                  initial={{ scale: 0.9, y: 20 }}
                  animate={{ scale: 1, y: 0 }}
                  className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden flex flex-col max-h-[85vh]"
                >
                  <div className="p-6 border-b border-slate-100 flex items-center justify-between shrink-0">
                    <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                      <Star className="text-amber-500" /> {editingBanner ? 'Edit Spotlight' : 'Create Spotlight'}
                    </h3>
                    <button onClick={() => setShowAddSpotlight(false)} className="p-2 hover:bg-slate-50 rounded-xl transition-all">
                      <X size={20} />
                    </button>
                  </div>

                  <div className="p-6 overflow-y-auto w-full no-scrollbar">
                    {/* User Search Section */}
                    {!editingBanner && (
                      <div className="space-y-4 mb-6 pb-6 border-b border-slate-100">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Search User (Name, Email or UID)</label>
                        <div className="relative">
                          <input
                            type="text"
                            autoComplete="off"
                            value={spotlightSearchTerm}
                            onChange={e => setSpotlightSearchTerm(e.target.value)}
                            onKeyDown={e => e.key === 'Enter' && (e.preventDefault(), handleSearchSpotlightUser())}
                            placeholder="Type name, email or UID..."
                            className="w-full px-4 py-3 pr-12 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-amber-500 outline-none"
                          />
                          <button
                            type="button"
                            onClick={handleSearchSpotlightUser}
                            disabled={isSearchingSpotlight}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-amber-500 transition-colors disabled:opacity-50"
                          >
                            {isSearchingSpotlight
                              ? <Loader2 size={18} className="animate-spin text-amber-500" />
                              : <Search size={18} />}
                          </button>
                        </div>

                        {spotlightFoundUser && (
                          <div className="bg-amber-50 border border-amber-100 rounded-xl p-4 flex items-center gap-4">
                            <div className="w-12 h-12 rounded-full bg-amber-200 overflow-hidden flex shrink-0 items-center justify-center">
                              {spotlightFoundUser.profilePhoto ? (
                                <img src={spotlightFoundUser.profilePhoto} alt="dp" className="w-full h-full object-cover" />
                              ) : (
                                <User className="text-amber-600" />
                              )}
                            </div>
                            <div>
                              <p className="font-bold text-slate-900">{spotlightFoundUser.name}</p>
                              <p className="text-xs text-slate-500">{spotlightFoundUser.email}</p>
                            </div>
                            <CheckCircle2 className="ml-auto text-amber-500" />
                          </div>
                        )}
                      </div>
                    )}

                    {editingBanner && (
                      <div className="bg-amber-50 border border-amber-100 rounded-xl p-4 flex items-center gap-4 mb-6">
                        <div className="w-12 h-12 rounded-full bg-amber-200 overflow-hidden flex shrink-0 items-center justify-center">
                          {editingBanner.spotlightData?.profilePhoto ? (
                            <img src={editingBanner.spotlightData.profilePhoto} alt="dp" className="w-full h-full object-cover" />
                          ) : (
                            <User className="text-amber-600" />
                          )}
                        </div>
                        <div>
                          <p className="font-bold text-slate-900">{editingBanner.spotlightData?.userName}</p>
                          <p className="text-xs text-slate-500 italic">Editing existing spotlight</p>
                        </div>
                        <Star className="ml-auto text-amber-500 fill-amber-500" size={18} />
                      </div>
                    )}

                    {/* Spotlight Fields Form */}
                    <form id="spotlightForm" onSubmit={handleSaveSpotlightBanner} className="space-y-4">
                      <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Score / Percentage</label>
                          <input type="text" value={spotlightData.score} onChange={e => setSpotlightData({ ...spotlightData, score: e.target.value })} placeholder="e.g. 98.5%" className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
                        </div>
                        <div className="space-y-2">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Rank</label>
                          <input type="text" value={spotlightData.rank} onChange={e => setSpotlightData({ ...spotlightData, rank: e.target.value })} placeholder="e.g. #1" className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Exam Name (Optional)</label>
                        <input type="text" value={spotlightData.examName} onChange={e => setSpotlightData({ ...spotlightData, examName: e.target.value })} placeholder="e.g. SSC CGL 2024" className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
                      </div>

                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Special Message</label>
                        <textarea value={spotlightData.message} onChange={e => setSpotlightData({ ...spotlightData, message: e.target.value })} placeholder="A personalized congratulation..." rows={2} className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none resize-none" />
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Priority (0 = High)</label>
                          <input type="number" value={spotlightData.priority} onChange={e => setSpotlightData({ ...spotlightData, priority: parseInt(e.target.value) || 0 })} className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none" />
                        </div>
                        <div className="flex items-end pb-3">
                          <label className="flex items-center gap-2 cursor-pointer">
                            <input type="checkbox" checked={spotlightData.isActive} onChange={e => setSpotlightData({ ...spotlightData, isActive: e.target.checked })} className="w-5 h-5 rounded-lg text-amber-500" />
                            <span className="text-sm font-bold text-slate-600">Active</span>
                          </label>
                        </div>
                      </div>
                    </form>
                  </div>

                  <div className="p-6 border-t border-slate-100 shrink-0">
                    <button
                      type="submit"
                      form="spotlightForm"
                      disabled={isPublishingSpotlight || (!editingBanner && !spotlightFoundUser)}
                      className="w-full py-4 bg-amber-500 text-white font-bold rounded-2xl hover:bg-amber-600 transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isPublishingSpotlight ? <Loader2 size={20} className="animate-spin" /> : editingBanner ? <Save size={20} /> : <Star size={20} />}
                      {editingBanner ? 'Update Spotlight' : 'Publish Spotlight'}
                    </button>
                  </div>
                </motion.div>
              </motion.div>
            , document.body)}

          {/* Add Banner Modal */}
            {showAddBanner && createPortal(
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4"
              >
                <motion.div
                  initial={{ scale: 0.9, y: 20 }}
                  animate={{ scale: 1, y: 0 }}
                  className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden flex flex-col max-h-[85vh]"
                >
                  <div className="py-4 px-6 md:py-5 md:px-8 border-b border-slate-100 flex items-center justify-between bg-slate-50/30 shrink-0">
                    <div className="flex items-center gap-3.5">
                      <div className="w-10 h-10 md:w-12 md:h-12 bg-emerald-500 text-white rounded-full flex items-center justify-center shrink-0">
                        <ImageIcon className="w-5 h-5 md:w-6 md:h-6" />
                      </div>
                      <div>
                        <h3 className="text-lg md:text-xl font-black text-slate-900 uppercase tracking-tight">
                          {editingBanner ? 'Edit Banner' : 'Create New'}
                        </h3>
                        <p className="text-[9px] md:text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] mt-1">Configure Banner Settings</p>
                      </div>
                    </div>
                    <button onClick={() => setShowAddBanner(false)} className="p-2 hover:bg-white rounded-xl transition-all text-slate-400">
                      <X className="w-5 h-5 md:w-6 md:h-6" />
                    </button>
                  </div>

                  <form onSubmit={handleSaveBanner} className="flex-1 flex flex-col min-h-0">
                    <div className="flex-1 overflow-y-auto p-4 md:p-6 space-y-4 no-scrollbar">

                      {/* Simple Image Uploader / Preview matching user request */}
                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Banner Image</label>

                        {!bannerFile && !isCompressingBanner && (
                          <div
                            onClick={() => document.getElementById('banner-upload')?.click()}
                            className="aspect-[21/9] bg-slate-50 border-2 border-dashed border-slate-200 rounded-xl flex flex-col items-center justify-center cursor-pointer hover:bg-slate-100 transition-all"
                          >
                            <Upload className="text-slate-400 mb-2" size={28} />
                            <p className="text-sm font-bold text-slate-500">Click to upload image</p>
                            <p className="text-[10px] text-slate-400 mt-1 uppercase">Recommended 1200x514</p>
                          </div>
                        )}

                        {isCompressingBanner && (
                          <div className="aspect-[21/9] bg-slate-50 border-2 border-slate-200 rounded-xl flex flex-col items-center justify-center">
                            <Loader2 className="animate-spin text-emerald-500 mb-2" size={28} />
                            <p className="text-sm font-bold text-slate-500">Processing image...</p>
                          </div>
                        )}

                        {bannerFile && !isCompressingBanner && (
                          <div className="relative group rounded-xl overflow-hidden shadow-sm border border-slate-200">
                            <img
                              src={URL.createObjectURL(bannerFile)}
                              alt="Banner Preview"
                              className="w-full aspect-[21/9] object-cover"
                            />
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                              <button
                                type="button"
                                onClick={(e) => {
                                  e.preventDefault();
                                  e.stopPropagation();
                                  setBannerFile(null);
                                }}
                                className="bg-rose-500 text-white p-3 rounded-full hover:bg-rose-600 shadow-xl transition-transform transform hover:scale-110"
                              >
                                <Trash2 size={20} />
                              </button>
                            </div>
                            <div className="absolute top-2 left-2 bg-slate-900/80 text-white text-[10px] font-bold px-2 py-1 rounded backdrop-blur-sm truncate max-w-[200px]">
                              {bannerFile.name} ({(bannerFile.size / 1024).toFixed(1)} KB)
                            </div>
                          </div>
                        )}

                        <input
                          id="banner-upload"
                          type="file"
                          accept="image/*"
                          className="hidden"
                          onChange={handleBannerFileChange}
                          disabled={isCompressingBanner}
                        />
                      </div>

                      <div className="space-y-4 pt-2">
                        <div className="space-y-2">
                          <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Banner Title (Optional)</label>
                          <input
                            type="text"
                            value={newBanner.title}
                            onChange={e => setNewBanner({ ...newBanner, title: capitalizeWords(e.target.value) })}
                            placeholder="e.g. Weekend Mega Contest"
                            className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none"
                          />
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                          <div className="space-y-1">
                            <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Quick Link (App Page)</label>
                            <CustomSelect
                              value={APP_PAGES.some(p => p.path === newBanner.link) ? (newBanner.link || '') : ''}
                              options={APP_PAGES.map(p => ({ value: p.path, label: p.label }))}
                              onChange={val => {
                                if (val) {
                                  setNewBanner({ ...newBanner, link: val });
                                }
                              }}
                              placeholder="Select App Page..."
                            />
                          </div>

                          <div className="space-y-2">
                            <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Custom Link / URL</label>
                            <input
                              type="text"
                              value={newBanner.link}
                              onChange={e => setNewBanner({ ...newBanner, link: e.target.value })}
                              placeholder="e.g. /custom-page or https://..."
                              className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-medium text-sm"
                            />
                          </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                          <div className="space-y-2">
                            <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Priority (0 = High)</label>
                            <input
                              type="number"
                              value={newBanner.priority}
                              onChange={e => setNewBanner({ ...newBanner, priority: parseInt(e.target.value) || 0 })}
                              className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold"
                            />
                          </div>
                          <div className="flex items-end pb-3">
                            <label className="flex items-center gap-2 cursor-pointer group">
                              <input
                                type="checkbox"
                                checked={newBanner.isActive}
                                onChange={e => setNewBanner({ ...newBanner, isActive: e.target.checked })}
                                className="w-5 h-5 rounded-lg border-slate-300 text-emerald-500 focus:ring-emerald-500"
                              />
                              <span className="text-sm font-bold text-slate-600 group-hover:text-slate-900 transition-colors">Mark Active</span>
                            </label>
                          </div>
                        </div>

                        <div className="pt-2">
                          <CustomDateTimePicker
                            label="Schedule Publication (Optional)"
                            value={newBanner.scheduledAt || ''}
                            onChange={val => setNewBanner({ ...newBanner, scheduledAt: val })}
                            accentColor="emerald"
                            icon={Calendar}
                          />
                        </div>
                      </div>
                    </div>{/* end scrollable */}

                    <div className="p-4 md:p-6 border-t border-slate-100 shrink-0">
                      <button
                        type="submit"
                        disabled={isUploadingBanner || (!bannerFile && !editingBanner?.imageUrl)}
                        className="w-full py-4 bg-emerald-500 text-white font-bold rounded-2xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.98]"
                      >
                        {isUploadingBanner ? (
                          <>
                            <Loader2 size={20} className="animate-spin" />
                            {editingBanner ? 'Updating Banner...' : 'Uploading to Cloud...'}
                          </>
                        ) : (
                          <>
                            {editingBanner ? <Save size={20} /> : <Plus size={20} />}
                            {editingBanner ? 'Update Banner' : 'Create Banner'}
                          </>
                        )}
                      </button>
                    </div>
                  </form>
                </motion.div>
              </motion.div>
            , document.body)}
        </div>
      )}

      {activeTab === 'notifications' && (
        <div className="space-y-8">
          {/* Redundant headers removed for cleaner UI */}


          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
            <div className="grid xl:grid-cols-[1fr_350px] divide-x divide-slate-100">
              {/* Left Column: Form Section */}
              <div className="p-6 md:p-8 space-y-6">
                <div className="pb-4 border-b border-slate-100">
                  <h3 className="text-xl font-black text-slate-800 flex items-center gap-2">
                    <Bell size={24} className="text-emerald-500" />
                    Compose New Notification
                  </h3>
                </div>

                <div className="space-y-5">
                  <div>

                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-1.5">
                      <button
                        onClick={() => { setNotifTargetType('global'); setNotifTargetSegment('all'); }}
                        className={`py-3 rounded-xl font-bold text-[10px] uppercase border-2 transition-all shadow-sm active:scale-95 flex flex-col items-center justify-center gap-1 ${notifTargetType === 'global' && notifTargetSegment === 'all' ? 'bg-emerald-50 border-emerald-500 text-emerald-700' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <Users size={14} />
                        All Users
                      </button>
                      <button
                        onClick={() => { setNotifTargetType('global'); setNotifTargetSegment('pro'); }}
                        className={`py-3 rounded-xl font-bold text-[10px] uppercase border-2 transition-all shadow-sm active:scale-95 flex flex-col items-center justify-center gap-1 ${notifTargetType === 'global' && notifTargetSegment === 'pro' ? 'bg-amber-50 border-amber-500 text-amber-700' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <Zap size={14} />
                        Pro Users
                      </button>
                      <button
                        onClick={() => { setNotifTargetType('global'); setNotifTargetSegment('free'); }}
                        className={`py-3 rounded-xl font-bold text-[10px] uppercase border-2 transition-all shadow-sm active:scale-95 flex flex-col items-center justify-center gap-1 ${notifTargetType === 'global' && notifTargetSegment === 'free' ? 'bg-blue-50 border-blue-500 text-blue-700' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <User size={14} />
                        Free Users
                      </button>
                      <button
                        onClick={() => setNotifTargetType('user')}
                        className={`py-3 rounded-xl font-bold text-[10px] uppercase border-2 transition-all shadow-sm active:scale-95 flex flex-col items-center justify-center gap-1 ${notifTargetType === 'user' ? 'bg-emerald-50 border-emerald-500 text-emerald-700' : 'bg-white border-slate-200 text-slate-600 hover:bg-slate-50'}`}
                      >
                        <Search size={14} />
                        Specific
                      </button>
                    </div>
                  </div>

                  {notifTargetType === 'user' && (
                    <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className="relative z-10">
                      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Search & Select Target User</label>
                      <div className="relative mt-1.5">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                        <input
                          type="text"
                          value={notifTargetUserId ? (users.find(u => u.userId === notifTargetUserId)?.name || notifTargetUserId) : notifUserSearchTerm}
                          onChange={e => {
                            setNotifTargetUserId('');
                            setNotifUserSearchTerm(e.target.value);
                          }}
                          placeholder="Type name or mobile (min 3 chars)..."
                          className="w-full pl-12 pr-10 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700 transition-colors"
                        />
                        {isSearchingNotifUser && (
                          <div className="absolute right-4 top-1/2 -translate-y-1/2">
                            <Loader2 size={16} className="animate-spin text-emerald-500" />
                          </div>
                        )}
                        {notifTargetUserId && (
                          <button onClick={() => { setNotifTargetUserId(''); setNotifUserSearchTerm(''); }} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-rose-500 p-1 bg-white rounded-full shadow-sm border border-slate-100 transition-all">
                            <X size={14} />
                          </button>
                        )}
                      </div>

                      {/* Search Results Dropdown */}
                      {notifUserSearchResults.length > 0 && !notifTargetUserId && (
                        <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl border border-slate-200 shadow-xl overflow-hidden max-h-60 overflow-y-auto z-50">
                          {notifUserSearchResults.map(u => (
                            <button
                              key={u.userId}
                              onClick={() => {
                                setNotifTargetUserId(u.userId);
                                // Caching user briefly so the input display Name logic works seamlessly
                                if (!users.find(existing => existing.userId === u.userId)) {
                                  setUsers(prev => [...prev, u]);
                                }
                                setNotifUserSearchResults([]);
                                setNotifUserSearchTerm('');
                              }}
                              className="w-full text-left p-3 flex items-center gap-3 hover:bg-slate-50 transition-colors border-b border-slate-50 last:border-0"
                            >
                              <img src={u.profilePhoto || `https://ui-avatars.com/api/?name=${u.name}`} alt={u.name} className="w-10 h-10 rounded-full border border-slate-200 object-cover shrink-0" />
                              <div className="flex-1 overflow-hidden">
                                <p className="font-bold text-sm text-slate-800 truncate">{u.name}</p>
                                <p className="text-xs text-slate-500 truncate font-medium">{u.phone || u.email || 'No contact info'}</p>
                              </div>
                              <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-1 rounded-md border border-emerald-100 uppercase tracking-wider">Select</span>
                            </button>
                          ))}
                        </div>
                      )}

                      {notifUserSearchTerm.length >= 3 && notifUserSearchResults.length === 0 && !isSearchingNotifUser && !notifTargetUserId && (
                        <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl border border-slate-200 shadow-xl p-6 text-center z-50">
                          <AlertCircle className="mx-auto text-slate-300 mb-2" size={24} />
                          <p className="text-sm font-bold text-slate-600">No users found</p>
                          <p className="text-xs text-slate-400 mt-1">Try a different name or exact mobile number</p>
                        </div>
                      )}
                    </motion.div>
                  )}

                  <div className="grid md:grid-cols-2 gap-5 pt-2">
                    <div className="flex flex-col">

                      <div className="flex items-center gap-4 mb-2">
                        <label className={`
                          px-5 py-2.5 rounded-xl font-bold text-sm cursor-pointer flex items-center justify-center gap-2 transition-all shrink-0 active:scale-95 shadow-sm
                          ${isUploadingNotifImage ? 'bg-emerald-500/70 text-white pointer-events-none' : 'bg-emerald-500 text-white hover:bg-emerald-600 shadow-emerald-100'}
                        `}>
                          {isUploadingNotifImage && <Loader2 size={16} className="animate-spin" />}
                          {isUploadingNotifImage ? 'Processing...' : 'Choose File'}
                          <input type="file" accept="image/*" className="hidden" onChange={handleNotifImageUpload} disabled={isUploadingNotifImage} />
                        </label>
                        <span className="text-sm text-slate-500 font-medium truncate flex-1">
                          {notifImageUrl ? 'notification-attachment.png' : 'No file chosen'}
                        </span>
                      </div>

                      {isUploadingNotifImage && (
                        <div className="flex items-center gap-2 text-sm text-slate-500 mt-2 px-2">
                          <Loader2 className="animate-spin text-emerald-500" size={16} />
                          Uploading to cloud...
                        </div>
                      )}

                      {notifImageUrl && !isUploadingNotifImage && (
                        <div className="space-y-4 mt-4">
                          <div className="relative border border-slate-200 rounded-xl bg-slate-50/50 p-2 max-w-full">
                            <button
                              onClick={() => { setNotifImageUrl(''); setNotifShowAsBanner(false); }}
                              className="absolute top-3 right-3 bg-slate-400 text-white rounded-full p-1 hover:bg-rose-500 shadow-sm transition-all z-10 active:scale-95"
                            >
                              <X size={14} />
                            </button>
                            <img src={notifImageUrl} className="w-full max-h-[140px] object-cover rounded-lg shadow-sm border border-slate-100" alt="Attachment" />
                          </div>

                          <label className="flex items-center gap-3 p-4 bg-emerald-50 border border-emerald-100 rounded-xl cursor-pointer hover:bg-emerald-100 transition-colors group">
                            <input
                              type="checkbox"
                              checked={notifShowAsBanner}
                              onChange={(e) => setNotifShowAsBanner(e.target.checked)}
                              className="w-5 h-5 rounded border-emerald-300 text-emerald-600 focus:ring-emerald-500 transition-all"
                            />
                            <div className="flex-1">
                              <p className="text-sm font-bold text-emerald-800">Show as Large Image Banner</p>
                              <p className="text-[10px] text-emerald-600 font-medium">Instead of a small toast, users will see a full-size promotional modal.</p>
                            </div>
                            <ImageIcon size={20} className="text-emerald-500 group-hover:scale-110 transition-transform" />
                          </label>
                        </div>
                      )}
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div className="flex flex-col">
                        <CustomSelect
                          value={notifSelectedRoute}
                          onChange={(val) => setNotifSelectedRoute(val)}
                          options={APP_ROUTES}
                          placeholder="Select Target Page / Redirect..."
                          className="mt-1.5"
                        />
                      </div>

                      <div className="flex flex-col">
                        <input
                          type="text"
                          value={notifActionLabel}
                          onChange={e => setNotifActionLabel(e.target.value)}
                          placeholder="Button Text (e.g. Open Now, Join Now)"
                          className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none mt-1.5 font-bold text-sm"
                        />
                      </div>
                    </div>
                  </div>

                  {notifSelectedRoute === 'custom' && (
                    <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}>
                      <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">External Link / Custom Path</label>
                      <input
                        type="text"
                        value={notifCustomUrl}
                        onChange={e => setNotifCustomUrl(e.target.value)}
                        placeholder="https://youtube.com or /my-path"
                        className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none mt-1.5"
                      />
                    </motion.div>
                  )}

                  <div>
                    <input
                      type="text"
                      value={notifTitle}
                      onChange={e => setNotifTitle(capitalizeWords(e.target.value))}
                      placeholder="Enter short, catchy title..."
                      className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none mt-1.5 font-bold"
                    />
                  </div>

                  <div>
                    <textarea
                      value={notifMessage}
                      onChange={e => setNotifMessage(e.target.value)}
                      placeholder="Write your message here..."
                      rows={3}
                      className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none mt-1.5 resize-none text-sm font-medium"
                    />
                  </div>

                  <div className="pt-2">
                    <CustomDateTimePicker
                      label="Schedule For (Optional)"
                      value={notifScheduledAt}
                      onChange={val => setNotifScheduledAt(val)}
                      accentColor="emerald"
                      icon={Calendar}
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Notification Type Color Theme</label>
                    <div className="flex flex-wrap gap-2">
                      {(['info', 'success', 'warning', 'transaction', 'contest'] as const).map(type => {
                        const styles = {
                          info: { active: 'bg-blue-600 border-blue-600 text-white shadow-blue-100', inactive: 'text-blue-600 bg-blue-50 border-blue-100 hover:bg-blue-100' },
                          success: { active: 'bg-emerald-600 border-emerald-600 text-white shadow-emerald-100', inactive: 'text-emerald-600 bg-emerald-50 border-emerald-100 hover:bg-emerald-100' },
                          warning: { active: 'bg-amber-500 border-amber-500 text-white shadow-amber-100', inactive: 'text-amber-600 bg-amber-50 border-amber-100 hover:bg-amber-100' },
                          transaction: { active: 'bg-indigo-600 border-indigo-600 text-white shadow-indigo-100', inactive: 'text-indigo-600 bg-indigo-50 border-indigo-100 hover:bg-indigo-100' },
                          contest: { active: 'bg-rose-500 border-rose-500 text-white shadow-rose-100', inactive: 'text-rose-600 bg-rose-50 border-rose-100 hover:bg-rose-100' }
                        }[type];

                        return (
                          <button
                            key={type}
                            onClick={() => setNotifType(type)}
                            className={`flex-1 min-w-[80px] sm:min-w-[100px] py-2.5 px-1 rounded-xl font-bold text-[11px] sm:text-xs uppercase border-2 transition-all active:scale-95 flex items-center justify-center shadow-sm ${notifType === type ? styles.active + ' shadow-lg' : styles.inactive}`}
                          >
                            {type}
                          </button>
                        );
                      })}
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4 mt-2">
                    <button
                      onClick={() => {
                        if (notifShowAsBanner && notifImageUrl) {
                          setLocalBannerPreview({
                            imageUrl: notifImageUrl,
                            title: notifTitle || 'Preview Title',
                            message: notifMessage || 'Preview message body content goes here.',
                            actionUrl: notifSelectedRoute === 'custom' ? notifCustomUrl : (notifSelectedRoute === 'none' ? undefined : notifSelectedRoute),
                            actionLabel: notifActionLabel || 'Open Now'
                          });
                        } else {
                          const previewType = (notifType === 'transaction' || notifType === 'contest') ? 'info' : notifType;
                          showToast(
                            notifTitle || 'Preview Title',
                            previewType as any,
                            5000,
                            notifSelectedRoute === 'custom' ? notifCustomUrl : (notifSelectedRoute === 'none' ? undefined : notifSelectedRoute)
                          );
                        }
                      }}
                      className="py-4 bg-slate-100 text-slate-700 font-bold rounded-2xl hover:bg-slate-200 transition-all flex items-center justify-center gap-2 active:scale-95"
                    >
                      Preview
                    </button>
                    <button
                      onClick={handleSendNotification}
                      disabled={isSendingNotif}
                      className="py-4 bg-emerald-500 text-white font-black rounded-2xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.98]"
                    >
                      {isSendingNotif && <Loader2 className="animate-spin" size={22} />}
                      Send
                    </button>
                  </div>

                  <ImageBannerModal
                    isOpen={!!localBannerPreview}
                    onClose={() => setLocalBannerPreview(null)}
                    imageUrl={localBannerPreview?.imageUrl || ''}
                    title={localBannerPreview?.title || ''}
                    message={localBannerPreview?.message || ''}
                    actionUrl={localBannerPreview?.actionUrl}
                    actionLabel={localBannerPreview?.actionLabel}
                  />
                </div>
              </div>

              {/* Right Column: Preview Section (Desktop Only) */}
              <div className="hidden xl:flex bg-slate-50/50 p-8 flex-col items-center justify-start space-y-6 overflow-y-auto no-scrollbar max-h-[800px]">
                <div className="text-center shrink-0">
                  <h3 className="text-sm font-black text-slate-700 flex items-center justify-center gap-2 mb-1">
                    <Sparkles size={16} className="text-amber-500" />
                    LIVE PREVIEW
                  </h3>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Real-time Appearance</p>
                </div>

                {/* Notifications History List */}
                <div className="w-full space-y-4 pt-6 border-t border-slate-200 mt-6">
                  <div className="flex items-center justify-between px-1">
                    <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Sent/Scheduled History</h4>
                    <button onClick={fetchNotifHistory} className="text-emerald-500 hover:text-emerald-600 transition-colors">
                      <RefreshCw size={12} className={isFetchingNotifHistory ? 'animate-spin' : ''} />
                    </button>
                  </div>

                  <div className="space-y-3">
                    {notifHistory.map(item => (
                      <div key={item.id} className="bg-white p-3 rounded-xl border border-slate-100 shadow-sm hover:shadow-md transition-all group">
                        <div className="flex items-start justify-between gap-2">
                          <h5 className="font-bold text-xs text-slate-800 line-clamp-1">{item.title}</h5>
                          <div className="flex items-center gap-1 shrink-0">
                            {item.clicks !== undefined && (
                              <span className="text-[9px] font-bold text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded flex items-center gap-1">
                                <TrendingUp size={10} /> {item.clicks}
                              </span>
                            )}
                            {item.scheduledAt && new Date(item.scheduledAt) > new Date() ? (
                              <span className="text-[9px] font-bold text-amber-600 bg-amber-50 px-1.5 py-0.5 rounded flex items-center gap-1">
                                <Clock size={10} />
                              </span>
                            ) : (
                              <span className="text-[9px] font-bold text-slate-400 bg-slate-50 px-1.5 py-0.5 rounded">
                                <Check size={10} />
                              </span>
                            )}
                          </div>
                        </div>
                        <p className="text-[10px] text-slate-500 line-clamp-2 mt-1 leading-relaxed">{item.message}</p>
                        <div className="flex items-center gap-2 mt-2">
                          <span className="text-[8px] font-black uppercase text-slate-300 tracking-tighter">
                            {item.targetSegment || 'all'} segment
                          </span>
                          <span className="text-[8px] font-bold text-slate-300 ml-auto">
                            {new Date(item.createdAt?.seconds * 1000 || item.createdAt || Date.now()).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                    ))}
                    {notifHistory.length === 0 && !isFetchingNotifHistory && (
                      <div className="text-center py-10">
                        <History size={24} className="mx-auto text-slate-200 mb-2" />
                        <p className="text-[9px] font-bold text-slate-400 uppercase tracking-widest">No history found</p>
                      </div>
                    )}
                  </div>
                </div>

                <div className="bg-slate-900 rounded-[2rem] p-1.5 aspect-[9/16] w-[260px] border-2 border-slate-800 shadow-2xl relative overflow-hidden ring-2 ring-slate-100/50">
                  <div className="absolute top-0 left-1/2 -translate-x-1/2 w-16 h-4 bg-slate-800 rounded-b-xl z-20" />
                  <div className="h-full w-full bg-slate-100 rounded-[1.8rem] overflow-hidden relative">
                    {/* Fake Notch/Status Bar */}
                    <div className="h-8 w-full flex items-center justify-between px-6 pt-2">
                      <span className="text-[8px] font-bold">9:41</span>
                      <div className="flex gap-1">
                        <div className="w-2.5 h-1 bg-slate-800 rounded-full" />
                        <div className="w-1.5 h-1 bg-slate-800 rounded-full" />
                      </div>
                    </div>

                    {/* Actual Notification Card */}
                    <div className="absolute inset-x-2 top-10 bg-white/95 backdrop-blur-md rounded-2xl p-0.5 shadow-xl border border-white/20 animate-bounce-subtle overflow-hidden">
                      <div className="p-3">
                        <div className="flex items-center gap-2 mb-1.5">
                          <div className="w-5 h-5 bg-emerald-500 rounded-lg flex items-center justify-center text-white shrink-0 shadow-sm">
                            <Bell size={10} />
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-[10px] font-black text-slate-900 truncate leading-none mb-0.5">{notifTitle || 'Notification Title'}</p>
                            <p className="text-[8px] text-slate-400 font-bold uppercase tracking-tighter">Rankearn • Now</p>
                          </div>
                        </div>
                        <p className="text-[9px] text-slate-600 leading-relaxed line-clamp-2 mb-1">{notifMessage || 'Hi! This is how your notification will look to the users...'}</p>
                      </div>

                      {notifImageUrl && (
                        <div className="px-2 pb-2">
                          <img
                            src={notifImageUrl}
                            alt="preview"
                            className="w-full aspect-video rounded-lg object-cover border border-slate-100 shadow-sm"
                          />
                        </div>
                      )}

                      {(notifSelectedRoute !== 'none') && (
                        <div className="px-3 pb-3">
                          <div className="inline-flex items-center gap-1.5 px-2 py-1 bg-emerald-50 rounded text-[8px] font-black text-emerald-600 uppercase tracking-tighter shadow-sm border border-emerald-100">
                            <span>{notifActionLabel || (notifSelectedRoute === 'custom' ? 'View Link' : 'Open Page')}</span>
                            <ExternalLink size={8} />
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Fake Icons to make it look like a phone */}
                    <div className="absolute bottom-4 inset-x-4 grid grid-cols-4 gap-2 opacity-10">
                      {[...Array(4)].map((_, i) => <div key={i} className="aspect-square bg-slate-400 rounded-lg" />)}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2 text-slate-400">
                  <div className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping" />
                  <span className="text-[10px] font-bold uppercase tracking-tighter">Live Syncing</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'referrals' && (
        <div className="max-w-6xl mx-auto space-y-6">
          {/* Header & Sub-tabs */}
          <div className="bg-white rounded-2xl p-6 md:p-8 border border-slate-100 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-emerald-500 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-emerald-100">
                <Users size={28} />
              </div>
              <div>
                <h3 className="text-2xl font-black text-slate-900 tracking-tight">Referral Management</h3>
                <p className="text-slate-500 font-medium text-sm">Monitor activity and configure rewards</p>
              </div>
            </div>

            <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200 self-start md:self-center">
              <button
                onClick={() => setReferralSubTab('history')}
                className={`px-6 py-2.5 rounded-lg text-xs font-black transition-all flex items-center gap-2 ${referralSubTab === 'history'
                  ? 'bg-white text-emerald-600 shadow-sm'
                  : 'text-slate-500 hover:text-slate-700'
                  }`}
              >
                <History size={14} />
                HISTORY
              </button>
              <button
                onClick={() => setReferralSubTab('settings')}
                className={`px-6 py-2.5 rounded-lg text-xs font-black transition-all flex items-center gap-2 ${referralSubTab === 'settings'
                  ? 'bg-white text-emerald-600 shadow-sm'
                  : 'text-slate-500 hover:text-slate-700'
                  }`}
              >
                <Settings size={14} />
                SETTINGS
              </button>
            </div>
          </div>

          {referralSubTab === 'history' ? (
            <div className="space-y-6">
              {/* Stats Overview */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-5">
                  <div className="w-14 h-14 bg-blue-50 text-blue-500 rounded-2xl flex items-center justify-center">
                    <UserPlus size={28} />
                  </div>
                  <div>
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-1">Total Referrals (Batch)</p>
                    <p className="text-3xl font-black text-slate-900 leading-none">{referralLogs.length}</p>
                  </div>
                </div>
                <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-5">
                  <div className="w-14 h-14 bg-amber-50 text-amber-500 rounded-2xl flex items-center justify-center">
                    <Coins size={28} />
                  </div>
                  <div>
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] mb-1">Recent Bonus Distributed</p>
                    <p className="text-3xl font-black text-slate-900 leading-none">0 <span className="text-sm text-slate-400">Coins</span></p>
                  </div>
                </div>
              </div>

              {/* History Table */}
              <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
                <div className="p-6 border-b border-slate-50 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  <h4 className="font-black text-slate-800 text-sm uppercase tracking-tight flex items-center gap-2">
                    <History size={16} className="text-emerald-500" />
                    Recent Joinings via Referral
                  </h4>

                  <div className="flex items-center gap-3">
                    <div className="relative flex-1 sm:w-64">
                      <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={14} />
                      <input
                        type="text"
                        placeholder="Search by Referral Code..."
                        value={referralSearchQuery}
                        onChange={(e) => setReferralSearchQuery(e.target.value.toUpperCase())}
                        onKeyDown={(e) => e.key === 'Enter' && fetchReferralLogs(true)}
                        className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold focus:ring-2 focus:ring-emerald-500 outline-none transition-all"
                      />
                    </div>
                    <button
                      onClick={() => fetchReferralLogs(true)}
                      className="p-2 bg-emerald-50 text-emerald-600 hover:bg-emerald-100 rounded-xl transition-colors"
                      title="Search / Refresh"
                    >
                      {isFetchingReferrals ? <Loader2 size={18} className="animate-spin" /> : <Search size={18} />}
                    </button>
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left">
                    <thead className="bg-slate-50/50">
                      <tr>
                        <th className="px-4 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center w-12">#</th>
                        <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Joined User</th>
                        <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Referred By (Code)</th>
                        <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Joining Date</th>
                        <th className="px-6 py-4 text-[10px] font-black text-slate-400 uppercase tracking-widest text-right">Status</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-50">
                      {isFetchingReferrals && referralLogs.length === 0 ? (
                        <tr>
                          <td colSpan={4} className="px-6 py-20 text-center">
                            <Loader2 size={32} className="animate-spin mx-auto text-emerald-500 mb-4" />
                            <p className="text-sm font-bold text-slate-400">Loading referral records...</p>
                          </td>
                        </tr>
                      ) : referralLogs.length === 0 ? (
                        <tr>
                          <td colSpan={4} className="px-6 py-20 text-center">
                            <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
                              <Users size={28} className="text-slate-300" />
                            </div>
                            <p className="text-sm font-bold text-slate-400">No referral joined users found yet.</p>
                          </td>
                        </tr>
                      ) : (
                        referralLogs.map((log, idx) => (
                          <tr key={idx} className="hover:bg-slate-50/50 transition-colors group">
                            <td className="px-4 py-5 text-center text-xs font-black text-slate-400">
                              {idx + 1}
                            </td>
                            <td className="px-6 py-5">
                              <div className="flex items-center gap-3">
                                <img
                                  src={log.joinedUser.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(log.joinedUser.name)}&background=10b981&color=fff`}
                                  className="w-10 h-10 rounded-full object-cover border border-slate-100 shrink-0"
                                  alt=""
                                />
                                <div>
                                  <p className="text-sm font-black text-slate-900 leading-tight">{log.joinedUser.name}</p>
                                  <p className="text-[10px] text-slate-500 font-bold uppercase tracking-tight">{log.joinedUser.email}</p>
                                </div>
                              </div>
                            </td>
                            <td className="px-6 py-5">
                              <div className="flex items-center gap-3">
                                <img
                                  src={log.referrer.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(log.referrer.name || 'U')}&background=f59e0b&color=fff`}
                                  className="w-10 h-10 rounded-full object-cover border border-slate-100 shrink-0"
                                  alt=""
                                />
                                <div>
                                  <p className="text-xs font-black text-slate-800">{log.referrer.name || 'Unknown'}</p>
                                  <p className="text-[10px] font-black text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded inline-block mt-1">
                                    CODE: {log.referrer.referralCode || log.joinedUser.referredBy}
                                  </p>
                                </div>
                              </div>
                            </td>
                            <td className="px-6 py-5">
                              <div className="flex flex-col gap-1">
                                <div className="flex items-center gap-1.5 text-slate-700">
                                  <Calendar size={12} className="text-slate-400" />
                                  <p className="text-xs font-bold whitespace-nowrap">
                                    {log.joinedUser.createdAt ? new Date(log.joinedUser.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }) : '---'}
                                  </p>
                                </div>
                                <div className="flex items-center gap-1.5 text-slate-400">
                                  <Clock size={10} />
                                  <p className="text-[10px] font-bold uppercase">
                                    {log.joinedUser.createdAt ? new Date(log.joinedUser.createdAt).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', hour12: true }) : ''}
                                  </p>
                                </div>
                              </div>
                            </td>
                            <td className="px-6 py-5 text-right">
                              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 text-emerald-600 rounded-full text-[10px] font-black uppercase tracking-widest border border-emerald-100">
                                <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" />
                                Successful
                              </span>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>

                {hasMoreReferrals && (
                  <div className="p-6 bg-slate-50/50 border-t border-slate-50 flex justify-center">
                    <button
                      onClick={() => fetchReferralLogs()}
                      disabled={isFetchingReferrals}
                      className="px-8 py-3 bg-white border border-slate-200 text-slate-600 font-black text-xs rounded-xl hover:bg-slate-50 transition-all flex items-center gap-2 shadow-sm disabled:opacity-50"
                    >
                      {isFetchingReferrals ? <Loader2 size={14} className="animate-spin" /> : 'LOAD MORE RECORDS'}
                    </button>
                  </div>
                )}
              </div>
            </div>
          ) : (
            /* Settings View (Existing Logic) */
            <div className="bg-white rounded-2xl p-8 border border-slate-100 shadow-sm space-y-8">
              <div className="flex items-center gap-4 mb-2">
                <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center">
                  <Settings size={24} />
                </div>
                <div>
                  <h3 className="text-2xl font-bold text-slate-900">Referral Settings</h3>
                  <p className="text-slate-500">Configure rewards and rules for the referral program</p>
                </div>
              </div>

              <div className="space-y-8">
                {/* System Toggle */}
                <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 flex items-center justify-between">
                  <div>
                    <h4 className="font-bold text-slate-900 text-sm">System Active</h4>
                    <p className="text-xs text-slate-500">Enable or disable the entire referral system</p>
                  </div>
                  <button
                    onClick={() => setReferralConfig({ ...referralConfig, isActive: !referralConfig.isActive })}
                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${referralConfig.isActive ? 'bg-emerald-500' : 'bg-slate-300'}`}
                  >
                    <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${referralConfig.isActive ? 'translate-x-6' : 'translate-x-1'}`} />
                  </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Referrer Reward */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Referrer Reward (Coins)</label>
                    <div className="relative">
                      <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                        <Coins size={18} />
                      </div>
                      <input
                        type="number"
                        value={referralConfig.referrerReward}
                        onChange={e => setReferralConfig({ ...referralConfig, referrerReward: parseInt(e.target.value) || 0 })}
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold"
                      />
                    </div>
                  </div>

                  {/* Welcome Bonus */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">New User Welcome Bonus (Coins)</label>
                    <div className="relative">
                      <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                        <Coins size={18} />
                      </div>
                      <input
                        type="number"
                        value={referralConfig.refereeReward}
                        onChange={e => setReferralConfig({ ...referralConfig, refereeReward: parseInt(e.target.value) || 0 })}
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold"
                      />
                    </div>
                  </div>

                  {/* Commission Rate */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Commission Rate (%)</label>
                    <div className="relative">
                      <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                        <Percent size={18} />
                      </div>
                      <input
                        type="number"
                        value={referralConfig.commissionRate}
                        onChange={e => setReferralConfig({ ...referralConfig, commissionRate: parseFloat(e.target.value) || 0 })}
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold"
                      />
                    </div>
                  </div>

                  {/* Min Withdrawal */}
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-1">Min Withdrawal for Referral Earnings</label>
                    <div className="relative">
                      <div className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                        <IndianRupee size={18} />
                      </div>
                      <input
                        type="number"
                        value={referralConfig.minWithdrawal}
                        onChange={e => setReferralConfig({ ...referralConfig, minWithdrawal: parseInt(e.target.value) || 0 })}
                        className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold"
                      />
                    </div>
                  </div>
                </div>

                <div className="pt-4 border-t border-slate-50">
                  <button
                    onClick={handleSaveReferralConfig}
                    disabled={isSavingConfig}
                    className="w-full py-4 bg-emerald-500 text-white font-black rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 flex items-center justify-center gap-3 active:scale-95 disabled:opacity-50"
                  >
                    {isSavingConfig ? <Loader2 size={20} className="animate-spin" /> : <Save size={20} />}
                    Save Referral Settings
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'support' && (
        <div className="w-full">
          <AdminSupport />
        </div>
      )}

      {activeTab === 'feedback' && (
        <div className="w-full">
          <AdminFeedback />
        </div>
      )}


      {activeTab === 'settings' && (
        <div className="max-w-4xl mx-auto space-y-8">
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center shrink-0">
                <Settings size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">Worker Settings</h3>
                <p className="text-slate-500">Configure Cloudflare worker for custom AI Test Generation</p>
              </div>
            </div>

            <div className="space-y-6">
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Cloudflare Worker URL / Gemini Proxy API</label>
                <input
                  type="url"
                  value={cfWorkerUrl}
                  onChange={e => setCfWorkerUrl(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 no-capitalize"
                  placeholder="https://testkarlo.alleduupdated.workers.dev"
                />
                <p className="text-xs text-slate-500">
                  This URL acts as a proxy to Gemini API. The AI Creator will automatically send the correctly formatted prompt body directly to this URL.
                </p>
              </div>

              <button
                onClick={async () => {
                  if (!cfWorkerUrl.trim()) {
                    showToast('Please enter a valid URL');
                    return;
                  }
                  try {
                    await setDoc(doc(db, 'configs', 'ai_worker'), {
                      url: cfWorkerUrl.trim(),
                      updatedAt: new Date().toISOString()
                    });
                    localStorage.setItem('cfWorkerUrl', cfWorkerUrl.trim());
                    showToast('Worker URL saved successfully to Database! All components will now use this URL.');
                  } catch (error) {
                    console.error("Error saving worker config:", error);
                    showToast("Failed to save to database. Saving locally instead.");
                    localStorage.setItem('cfWorkerUrl', cfWorkerUrl.trim());
                  }
                }}
                className="w-full bg-emerald-500 text-white py-3 rounded-xl font-bold hover:bg-emerald-600 transition-all shadow-md shadow-emerald-100 flex items-center justify-center gap-3 text-sm"
              >
                Save Settings
              </button>
            </div>
          </div>

          {/* Feature Flags Settings */}
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8 mt-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-full flex items-center justify-center shrink-0">
                <LayoutDashboard size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">App Features</h3>
                <p className="text-slate-500">Enable or disable specific tabs and features in the app</p>
              </div>
            </div>

            <div className="space-y-6">
              <div className="flex items-center justify-between p-4 border border-slate-100 rounded-xl bg-slate-50">
                <div>
                  <h4 className="font-bold text-slate-800">Subscription Tab</h4>
                  <p className="text-xs text-slate-500">Show the Subscription/Premium tab in the app navigation menu.</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer shrink-0">
                  <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={featureFlags.showSubscriptionTab}
                    onChange={async (e) => {
                      const newValue = e.target.checked;
                      setFeatureFlags(prev => ({ ...prev, showSubscriptionTab: newValue }));
                      try {
                        await setDoc(doc(db, 'configs', 'feature_flags'), { showSubscriptionTab: newValue }, { merge: true });
                        showToast('Subscription tab visibility updated! Refresh the app to see changes.', 'success');
                      } catch (err) {
                        console.error('Error saving feature flag', err);
                        showToast('Failed to save settings', 'error');
                      }
                    }}
                  />
                  <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-indigo-500"></div>
                </label>
              </div>
            </div>
          </div>

          {/* Subscription Model Settings */}
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8 mt-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-amber-100 text-amber-600 rounded-full flex items-center justify-center shrink-0">
                <Coins size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">Rankearn PRO Configuration</h3>
                <p className="text-slate-500">Configure the Coin-based subscription pricing and validity</p>
              </div>
            </div>

            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Price (in Coins)</label>
                  <input
                    type="number"
                    value={subscriptionConfig.priceInCoins}
                    onChange={e => setSubscriptionConfig({ ...subscriptionConfig, priceInCoins: parseInt(e.target.value) || 0 })}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500"
                    placeholder="e.g. 5000"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Duration (Days)</label>
                  <input
                    type="number"
                    value={subscriptionConfig.durationDays}
                    onChange={e => setSubscriptionConfig({ ...subscriptionConfig, durationDays: parseInt(e.target.value) || 0 })}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500"
                    placeholder="e.g. 30"
                  />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Contest Discount (%)</label>
                  <input
                    type="number"
                    value={subscriptionConfig.contestDiscount}
                    onChange={e => setSubscriptionConfig({ ...subscriptionConfig, contestDiscount: parseInt(e.target.value) || 0 })}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500"
                    placeholder="e.g. 50"
                  />
                  <p className="text-[10px] text-slate-400 font-medium">Discount given to PRO users on tournament entries</p>
                </div>
              </div>

              <div className="flex items-center justify-between p-4 border border-slate-100 rounded-xl bg-slate-50">
                <div>
                  <h4 className="font-bold text-slate-800">Is Subscription Active?</h4>
                  <p className="text-xs text-slate-500">Allow users to purchase the PRO pass</p>
                </div>
                <label className="relative inline-flex items-center cursor-pointer shrink-0">
                  <input
                    type="checkbox"
                    className="sr-only peer"
                    checked={subscriptionConfig.isActive}
                    onChange={(e) => setSubscriptionConfig({ ...subscriptionConfig, isActive: e.target.checked })}
                  />
                  <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                </label>
              </div>

              <button
                onClick={async () => {
                  try {
                    await setDoc(doc(db, 'configs', 'subscription_settings'), subscriptionConfig);
                    showToast('Subscription configuration saved successfully!', 'success');
                  } catch (error) {
                    console.error("Error saving subscription config:", error);
                    showToast('Failed to save configuration', 'error');
                  }
                }}
                className="w-full bg-amber-500 text-white py-3 rounded-xl font-bold hover:bg-amber-600 transition-all shadow-md shadow-amber-100 flex items-center justify-center gap-3 text-sm"
              >
                Save PRO Settings
              </button>
            </div>
          </div>

          {/* Social Media Links Settings */}
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8 mt-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center shrink-0">
                <Globe size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">Social Media Links</h3>
                <p className="text-slate-500">Configure links to display in the landing page footer</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {[
                { key: 'whatsapp', label: 'WhatsApp', icon: WhatsAppIcon, color: 'text-green-500' },
                { key: 'youtube', label: 'YouTube', icon: Youtube, color: 'text-red-500' },
                { key: 'twitter', label: 'X (Twitter)', icon: Twitter, color: 'text-slate-800' },
                { key: 'telegram', label: 'Telegram', icon: Send, color: 'text-blue-500' },
                { key: 'facebook', label: 'Facebook', icon: Facebook, color: 'text-blue-600' },
                { key: 'instagram', label: 'Instagram', icon: Instagram, color: 'text-pink-600' },
                { key: 'linkedin', label: 'LinkedIn', icon: Linkedin, color: 'text-blue-700' }
              ].map(platform => (
                <div key={platform.key} className="space-y-2">
                  <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                    <platform.icon size={16} className={platform.color} /> {platform.label}
                  </label>
                  <input
                    type="url"
                    value={(socialLinks as any)[platform.key] || ''}
                    onChange={e => setSocialLinks(prev => ({ ...prev, [platform.key]: e.target.value }))}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder={`Enter ${platform.label} URL`}
                  />
                </div>
              ))}
            </div>

            <button
              onClick={async () => {
                setIsSavingSocialLinks(true);
                try {
                  await setDoc(doc(db, 'configs', 'social_links'), socialLinks);
                  showToast('Social media links saved successfully!', 'success');
                } catch (error) {
                  console.error("Error saving social links:", error);
                  showToast('Failed to save social links', 'error');
                } finally {
                  setIsSavingSocialLinks(false);
                }
              }}
              disabled={isSavingSocialLinks}
              className="w-full bg-blue-500 text-white py-3 rounded-xl font-bold hover:bg-blue-600 transition-all shadow-md shadow-blue-100 flex items-center justify-center gap-3 text-sm disabled:opacity-50"
            >
              {isSavingSocialLinks ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
              Save Social Links
            </button>
          </div>

          {/* APK Download Settings */}
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8 mt-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-full flex items-center justify-center shrink-0">
                <Download size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">APK Download Settings</h3>
                <p className="text-slate-500">Configure the APK download link for the landing page</p>
              </div>
            </div>

            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">APK Download URL</label>
                <input
                  type="url"
                  value={apkUrl}
                  onChange={e => setApkUrl(e.target.value)}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  placeholder="https://example.com/your-app.apk"
                />
              </div>

              <button
                onClick={async () => {
                  setIsSavingApkUrl(true);
                  try {
                    await setDoc(doc(db, 'configs', 'app_settings'), { apkUrl });
                    showToast('APK download link saved successfully!', 'success');
                  } catch (error) {
                    console.error("Error saving APK settings:", error);
                    showToast('Failed to save APK download link', 'error');
                  } finally {
                    setIsSavingApkUrl(false);
                  }
                }}
                disabled={isSavingApkUrl}
                className="w-full bg-indigo-500 text-white py-3 rounded-xl font-bold hover:bg-indigo-600 transition-all shadow-md shadow-indigo-100 flex items-center justify-center gap-3 text-sm disabled:opacity-50"
              >
                {isSavingApkUrl ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
                Save APK settings
              </button>
            </div>
          </div>

          {/* Security & Authentication Settings */}
          <div className="bg-white rounded-xl p-8 border border-slate-100 shadow-sm space-y-8">
            <div className="flex items-center gap-4 mb-2">
              <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center shrink-0">
                <ShieldCheck size={24} />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-slate-900">Security & Authentication</h3>
                <p className="text-slate-500">Configure global security policies for users</p>
              </div>
            </div>

            <div className="space-y-6">
              <div className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl border border-slate-100 group transition-all hover:bg-slate-100/50">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center text-rose-500 shadow-sm border border-slate-100 shrink-0">
                    <Mail size={20} />
                  </div>
                  <div>
                    <p className="font-bold text-slate-900">Force Email Verification</p>
                    <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest mt-0.5">Require users to verify email before accessing dashboard</p>
                  </div>
                </div>
                <button
                  onClick={async () => {
                    const newValue = !requireEmailVerification;
                    setIsSavingSecurity(true);
                    try {
                      await setDoc(doc(db, 'configs', 'auth_settings'), {
                        requireEmailVerification: newValue,
                        updatedAt: new Date().toISOString()
                      });
                      setRequireEmailVerification(newValue);
                      showToast(`Email verification ${newValue ? 'enabled' : 'disabled'} successfully`, 'success');
                    } catch (error) {
                      console.error("Error saving security settings:", error);
                      showToast('Failed to update security settings', 'error');
                    } finally {
                      setIsSavingSecurity(false);
                    }
                  }}
                  disabled={isSavingSecurity}
                  className={`w-14 h-7 rounded-full relative transition-all duration-300 shrink-0 ${requireEmailVerification ? 'bg-emerald-500 shadow-lg shadow-emerald-200' : 'bg-slate-200'}`}
                >
                  <div className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-all duration-300 shadow-sm ${requireEmailVerification ? 'left-8' : 'left-1'}`} />
                </button>
              </div>

              <div className="p-4 bg-amber-50 rounded-2xl border border-amber-100 flex items-start gap-3">
                <AlertTriangle size={18} className="text-amber-500 shrink-0 mt-0.5" />
                <p className="text-[11px] text-amber-700 font-medium leading-relaxed">
                  <span className="font-bold">Important:</span> Enabling this will block all unverified users from accessing their dashboard until they click the link sent to their email. Google Login users are exempt as they are pre-verified by Google.
                </p>
              </div>
            </div>
          </div>


        </div>
      )}


      {/* Edit Exam Category Modal */}
      {editingExamCategory && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-[200] p-6">
          <div className="bg-white rounded-xl p-8 max-w-sm w-full shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-slate-900">Edit Category</h3>
              <button onClick={() => setEditingExamCategory(null)} className="p-2 hover:bg-slate-100 rounded-md transition-colors"><X size={20} /></button>
            </div>
            <div className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Category Name</label>
                <input type="text" value={editingExamCategory.name} onChange={e => setEditingExamCategory({ ...editingExamCategory, name: capitalizeWords(e.target.value) })} className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700 block">Category Icon</label>
                <div className="flex items-center gap-4 bg-slate-50/50 p-3 rounded-lg border border-slate-100">
                  <div className="w-14 h-14 shrink-0 bg-white rounded-full shadow-sm border border-slate-100 flex items-center justify-center relative overflow-hidden text-emerald-600">
                    {iconPreviewUrl ? (
                      <img src={iconPreviewUrl} alt="Preview" className="w-full h-full object-cover" />
                    ) : (
                      <Layers size={24} />
                    )}
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="px-3 py-1.5 bg-white hover:bg-slate-50 text-slate-700 rounded-lg text-xs font-bold cursor-pointer transition-colors inline-block border border-slate-200 shadow-sm text-center">
                      Choose Icon
                      <input
                        type="file"
                        accept="image/*"
                        onChange={async (e) => {
                          const file = e.target.files?.[0];
                          if (file) {
                            setSelectedIconFile(file);
                            setIconPreviewUrl(URL.createObjectURL(file));
                          }
                        }}
                        className="hidden"
                      />
                    </label>
                    {iconPreviewUrl && (
                      <button
                        type="button"
                        onClick={() => {
                          setSelectedIconFile(null);
                          setIconPreviewUrl(null);
                        }}
                        className="text-xs text-rose-500 font-bold hover:text-rose-600 transition-colors text-left"
                      >
                        Remove Icon
                      </button>
                    )}
                    <span className="text-[9px] text-slate-400 font-medium">Max 20 KB (compressed automatically)</span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <input type="checkbox" id="isPublished" checked={editingExamCategory.isPublished !== false} onChange={e => setEditingExamCategory({ ...editingExamCategory, isPublished: e.target.checked })} className="w-5 h-5 rounded border-slate-300 text-emerald-500 focus:ring-emerald-500" />
                <label htmlFor="isPublished" className="text-sm font-bold text-slate-700">Published (Visible)</label>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Custom Users Display (Optional)</label>
                <input type="number" value={editingExamCategory.usersCountOverride || ''} onChange={e => setEditingExamCategory({ ...editingExamCategory, usersCountOverride: e.target.value ? parseInt(e.target.value) : undefined })} placeholder="e.g. 15000" className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Languages</label>
                <input type="text" value={editingExamCategory.languages || ''} onChange={e => setEditingExamCategory({ ...editingExamCategory, languages: capitalizeWords(e.target.value) })} placeholder="e.g. English, Hindi" className="w-full px-4 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500" />
              </div>
              <button
                onClick={handleSaveExamCategory}
                disabled={isSavingIcon}
                className="w-full bg-emerald-500 text-white py-3 rounded-lg font-bold hover:bg-emerald-600 transition-all shadow-md mt-4 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSavingIcon && <Loader2 size={18} className="animate-spin" />}
                {isSavingIcon ? 'Saving Icon...' : 'Save Changes'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add Test Modal */}
      {showAddTest && (
        createPortal(
          <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4">
            <div className="bg-white rounded-2xl w-full max-w-lg max-h-[85vh] shadow-2xl flex flex-col relative overflow-hidden">
              <div className="px-4 py-3 md:px-6 md:py-4 border-b border-slate-100 flex items-center justify-between shrink-0">
                <h3 className="text-lg md:text-2xl font-bold text-slate-900">{editingTest ? 'Edit Test' : 'Create New Test'}</h3>
                <button
                  onClick={() => {
                    setShowAddTest(false);
                    setEditingTest(null);
                    setNotifyOnSave(false);
                    setNewTest({
                      title: '',
                      examCategory: '',
                      testMode: 'mock',
                      category: '',
                      topic: '',
                      examType: 'Mock Test',
                      duration: 60,
                      totalQuestions: 100,
                      negativeMarking: 0.25,
                      isPremium: false,
                      status: 'published',
                      scheduledStartTime: undefined,
                      scheduledEndTime: undefined,
                      leaderboardLimit: undefined,
                      winnerCount: undefined,
                      unlockPrice: 0
                    });
                  }}
                  className="p-2 hover:bg-slate-100 rounded-md transition-colors active:scale-95 text-slate-400 hover:text-slate-900"
                >
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleAddTest} className="flex-1 flex flex-col min-h-0 relative">
                <div className="flex-1 overflow-y-auto px-4 py-4 md:px-6 space-y-4 no-scrollbar">
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700">Test Title</label>
                    <input
                      required
                      type="text"
                      value={newTest.title}
                      onChange={e => setNewTest({ ...newTest, title: e.target.value })}
                      className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      placeholder="e.g. SSC CGL Mock Test 01"
                    />
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <CustomSelect
                      label="Exam Category"
                      value={newTest.examCategory}
                      onChange={(val) => setNewTest({ 
                        ...newTest, 
                        examCategory: val, 
                        examType: val,
                        category: '',
                        topic: ''
                      })}
                      options={[
                        { value: '', label: 'Select Exam Category...' },
                        ...examCategories.map(cat => ({ value: cat.name, label: cat.name }))
                      ]}
                      className="w-full"
                    />
                    <CustomSelect
                      label="Test Mode"
                      value={newTest.testMode}
                      onChange={(val) => setNewTest({ 
                        ...newTest, 
                        testMode: val as 'mock' | 'sectional' | 'previous-year',
                        category: '',
                        topic: ''
                      })}
                      options={[
                        { value: 'mock', label: 'Mock Test' },
                        { value: 'sectional', label: 'Sectional Test' },
                        { value: 'previous-year', label: 'Previous Year Paper' }
                      ]}
                      className="w-full"
                    />
                  </div>

                  <AnimatePresence>
                    {newTest.testMode === 'sectional' && (
                      <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }} exit={{ height: 0, opacity: 0 }} className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4">
                        <CustomSelect
                          label="Subject"
                          value={newTest.category}
                          onChange={(val) => setNewTest({ ...newTest, category: val, topic: '' })}
                          options={[
                            { value: '', label: 'Select Subject...' },
                            ...categories
                              .filter(cat => {
                                const examNames = new Set(examCategories.map(ec => ec.name.toLowerCase().trim()));
                                const isExamName = examNames.has(cat.name.toLowerCase().trim());
                                const selectedExam = examCategories.find(ec => ec.name === newTest.examCategory);
                                const isMatch = !newTest.examCategory || cat.parentExamId === selectedExam?.id;

                                if (isExamName) return false;
                                return isMatch;
                              })
                              .map(cat => ({ value: cat.name, label: cat.name }))
                          ]}
                          className="w-full"
                          searchable
                        />
                        <CustomSelect
                          label="Topic"
                          value={newTest.topic}
                          onChange={(val) => setNewTest({ ...newTest, topic: val })}
                          disabled={!newTest.category || !categories.find(c => c.name === newTest.category)?.topics?.length}
                          options={[
                            { value: '', label: 'Select Topic...' },
                            ...(categories.find(c => c.name === newTest.category)?.topics || []).map(t => ({ value: t, label: t }))
                          ]}
                          className="w-full"
                          searchable
                        />
                      </motion.div>
                    )}
                  </AnimatePresence>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-slate-700">Duration (mins)</label>
                      <input
                        type="number"
                        value={newTest.duration ?? ''}
                        onChange={e => {
                          const val = parseInt(e.target.value);
                          setNewTest({ ...newTest, duration: isNaN(val) ? 0 : val });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      />
                    </div>
                    <CustomSelect
                      label="Publish Status"
                      value={newTest.status || 'published'}
                      onChange={(val) => {
                        setNewTest({ ...newTest, status: val as 'published' | 'unpublished' });
                        setNotifyOnSave(val === 'published');
                      }}
                      options={[
                        { value: 'published', label: 'Published' },
                        { value: 'unpublished', label: 'Unpublished' }
                      ]}
                      className="w-full"
                    />
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-slate-700">Total Questions</label>
                      <input
                        type="number"
                        value={newTest.totalQuestions ?? ''}
                        onChange={e => {
                          const val = parseInt(e.target.value);
                          setNewTest({ ...newTest, totalQuestions: isNaN(val) ? 0 : val });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-slate-700">Negative Marking</label>
                      <input
                        type="number"
                        step="0.01"
                        value={newTest.negativeMarking ?? ''}
                        onChange={e => {
                          const val = parseFloat(e.target.value);
                          setNewTest({ ...newTest, negativeMarking: isNaN(val) ? 0 : val });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-slate-700">Leaderboard Limit</label>
                      <input
                        type="number"
                        placeholder="e.g. 10 (Default: All)"
                        value={newTest.leaderboardLimit ?? ''}
                        onChange={e => {
                          const val = parseInt(e.target.value);
                          setNewTest({ ...newTest, leaderboardLimit: isNaN(val) ? undefined : val });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-slate-700">Winner Count (Contest)</label>
                      <input
                        type="number"
                        placeholder="e.g. 10"
                        value={newTest.winnerCount ?? ''}
                        onChange={e => {
                          const val = parseInt(e.target.value);
                          setNewTest({ ...newTest, winnerCount: isNaN(val) ? undefined : val });
                        }}
                        className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-slate-700">Test / Contest Syllabus (Optional)</label>
                    <textarea
                      placeholder="e.g. History (Maurya Empire), Current Affairs (Jan 2024)..."
                      value={newTest.syllabus || ''}
                      onChange={e => setNewTest({ ...newTest, syllabus: e.target.value })}
                      className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm min-h-[100px]"
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="flex items-center gap-3 p-3 bg-slate-50 rounded-xl border border-slate-200 cursor-pointer hover:bg-slate-100 transition-colors">
                      <input
                        type="checkbox"
                        id="isPremium"
                        checked={newTest.isPremium}
                        onChange={e => setNewTest({ ...newTest, isPremium: e.target.checked })}
                        className="w-5 h-5 rounded border-slate-300 text-emerald-500 focus:ring-emerald-500"
                      />
                      <label htmlFor="isPremium" className="flex-1 text-sm font-bold text-slate-700 cursor-pointer">Premium Test</label>
                    </div>

                    <label className={`flex items-center gap-3 p-3 rounded-xl border transition-all cursor-pointer ${notifyOnSave ? 'bg-emerald-50 border-emerald-500' : 'bg-slate-50 border-slate-200 hover:bg-slate-100'}`}>
                      <input
                        type="checkbox"
                        className="w-5 h-5 rounded border-slate-300 text-emerald-500 focus:ring-emerald-500"
                        checked={notifyOnSave}
                        onChange={e => setNotifyOnSave(e.target.checked)}
                      />
                      <div className="flex-1">
                        <p className={`text-xs font-bold leading-none ${notifyOnSave ? 'text-emerald-700' : 'text-slate-600'}`}>Push Notify</p>
                      </div>
                      <Bell size={14} className={notifyOnSave ? 'text-emerald-500 animate-bounce' : 'text-slate-400'} />
                    </label>
                  </div>

                  <AnimatePresence>
                    {newTest.isPremium && !newTest.isTournament && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="space-y-1 bg-amber-50/50 p-3 rounded-xl border border-amber-100"
                      >
                        <label className="text-[10px] font-black text-amber-600 uppercase tracking-widest">Unlock Price (Coins)</label>
                        <input
                          type="number"
                          value={newTest.unlockPrice ?? 0}
                          onChange={e => {
                            const val = parseInt(e.target.value);
                            setNewTest({ ...newTest, unlockPrice: isNaN(val) ? 0 : val });
                          }}
                          className="w-full px-3 py-2 bg-white border border-amber-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 font-bold text-amber-900"
                          placeholder="e.g. 50"
                        />
                      </motion.div>
                    )}
                  </AnimatePresence>

                  <div className="flex flex-col gap-4 p-4 border border-indigo-100 bg-indigo-50/50 rounded-xl">
                    <div className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        id="isTournament"
                        checked={!!newTest.isTournament}
                        onChange={e => setNewTest({ ...newTest, isTournament: e.target.checked })}
                        className="w-5 h-5 rounded border-slate-300 text-indigo-500 focus:ring-indigo-500"
                      />
                      <label htmlFor="isTournament" className="text-sm font-bold text-slate-900">Run as Paid Contest</label>
                    </div>

                    <div className="flex items-center gap-3 mt-1 pl-1">
                      <input
                        type="checkbox"
                        id="isProOnly"
                        checked={!!newTest.isProOnly}
                        onChange={e => setNewTest({ ...newTest, isProOnly: e.target.checked })}
                        className="w-5 h-5 rounded border-slate-300 text-amber-500 focus:ring-amber-500"
                      />
                      <label htmlFor="isProOnly" className="text-sm font-bold text-slate-900 flex items-center gap-1.5 cursor-pointer">
                        <Star size={14} className="text-amber-500 fill-amber-500" />
                        Exclusive for PRO Users
                      </label>
                    </div>


                    {newTest.isTournament && (
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-2">
                        <div className="space-y-2">
                          <label className="text-sm font-bold text-slate-700">Entry Fee (Coins)</label>
                          <input
                            type="number"
                            value={newTest.entryFee ?? 0}
                            onChange={e => {
                              const val = parseInt(e.target.value);
                              setNewTest({ ...newTest, entryFee: isNaN(val) ? 0 : val });
                            }}
                            className="w-full px-4 py-3 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          />
                        </div>
                        <div className="space-y-2">
                          <label className="text-sm font-bold text-slate-700">Admin Commission (%)</label>
                          <input
                            type="number"
                            value={newTest.adminCommissionPercentage ?? 20}
                            onChange={e => {
                              const val = parseFloat(e.target.value);
                              setNewTest({ ...newTest, adminCommissionPercentage: isNaN(val) ? 0 : val });
                            }}
                            className="w-full px-4 py-3 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                          />
                        </div>
                        <div className="space-y-4 md:col-span-2 bg-slate-50/50 p-4 rounded-xl border border-slate-100 mt-2">
                          <div className="flex items-center gap-2 mb-2">
                            <Calendar size={16} className="text-indigo-500" />
                            <h4 className="text-xs font-black text-slate-900 uppercase tracking-wider">Contest Schedule</h4>
                          </div>

                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <CustomDateTimePicker
                              label="Start Time"
                              value={newTest.scheduledStartTime}
                              onChange={(val) => setNewTest({ ...newTest, scheduledStartTime: val })}
                              accentColor="indigo"
                              icon={Calendar}
                            />

                            <CustomDateTimePicker
                              label="End Time"
                              value={newTest.scheduledEndTime}
                              onChange={(val) => setNewTest({ ...newTest, scheduledEndTime: val })}
                              accentColor="red"
                              icon={Clock}
                            />
                          </div>
                        </div>
                      </div>
                    )}
                  </div>{/* end isTournament */}
                </div>{/* end scrollable area */}

                <div className="px-4 py-3 md:px-6 border-t border-slate-100 shrink-0">
                  <button
                    type="submit"
                    className="w-full bg-emerald-500 text-white py-3 rounded-xl font-bold hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 active:scale-95"
                  >
                    {editingTest ? 'Update Test Series' : 'Create Test Series'}
                  </button>
                </div>
              </form>
            </div>
          </div>
          , document.body)
      )}

      {/* Manage Questions Modal */}
      {managingQuestionsFor && createPortal(
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 md:p-6">
          <div className="bg-white rounded-xl w-full max-w-5xl max-h-[85vh] shadow-2xl flex flex-col overflow-hidden">
            <div className="p-4 md:p-6 border-b border-slate-100 bg-slate-50 flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="flex items-center justify-between w-full md:w-auto">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center shrink-0 shadow-sm">
                    <FileText size={20} />
                  </div>
                  <h3 className="text-lg md:text-xl font-bold text-slate-900 line-clamp-1 pr-2">{managingQuestionsFor.title}</h3>
                </div>
                <button
                  onClick={() => setManagingQuestionsFor(null)}
                  className="md:hidden p-2 hover:bg-slate-200 rounded-lg transition-colors shrink-0"
                >
                  <X size={20} />
                </button>
              </div>

              <hr className="md:hidden border-slate-200" />

              <div className="flex items-center justify-between md:justify-end gap-3 md:gap-6">
                <p className="text-sm text-slate-500 font-bold md:font-medium">{questions.length} Questions total</p>
                <div className="flex items-center gap-3">
                  <div className="relative group/export">
                    <button
                      className="p-2 text-slate-400 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-all active:scale-95"
                      title="Export Test"
                    >
                      {isExporting === managingQuestionsFor.testId ? <Loader2 size={18} className="animate-spin" /> : <Download size={18} />}
                    </button>
                    <div className="absolute right-0 top-full mt-1 hidden group-hover/export:block bg-white border border-slate-200 rounded-lg shadow-xl z-50 py-1 min-w-[120px]">
                      <button
                        onClick={() => handleExportTest(managingQuestionsFor, 'txt')}
                        className="w-full text-left px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-50 hover:text-emerald-600 transition-colors"
                      >
                        Export as Text
                      </button>
                      <button
                        onClick={() => handleExportTest(managingQuestionsFor, 'docx')}
                        className="w-full text-left px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-50 hover:text-blue-600 transition-colors"
                      >
                        Export as Word
                      </button>
                      <button
                        onClick={() => handleExportTest(managingQuestionsFor, 'pdf')}
                        className="w-full text-left px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-50 hover:text-red-600 transition-colors"
                      >
                        Export as PDF
                      </button>
                      <button
                        onClick={() => window.print()}
                        className="w-full text-left px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-50 hover:text-purple-600 transition-colors border-t border-slate-100"
                      >
                        Print Test
                      </button>
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      setEditingQuestion({
                        questionId: '',
                        testId: managingQuestionsFor.testId,
                        questionTextEnglish: '',
                        questionTextHindi: '',
                        options: [
                          { textEnglish: '', textHindi: '' },
                          { textEnglish: '', textHindi: '' },
                          { textEnglish: '', textHindi: '' },
                          { textEnglish: '', textHindi: '' }
                        ],
                        correctAnswer: 0,
                        explanation: '',
                        explanationHindi: '',
                        difficultyLevel: 'medium',
                        subject: 'General',
                        topic: ''
                      });
                      setShowAddQuestion(true);
                    }}
                    className="bg-emerald-500 text-white p-2 md:px-4 md:py-2 rounded-lg font-bold text-sm hover:bg-emerald-600 transition-all flex items-center gap-2"
                  >
                    <Plus size={18} />
                    <span className="hidden md:inline">Add Question</span>
                  </button>
                  <button
                    onClick={() => setManagingQuestionsFor(null)}
                    className="hidden md:block p-2 hover:bg-slate-200 rounded-lg transition-colors"
                  >
                    <X size={20} />
                  </button>
                </div>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-4 no-scrollbar">
              {questions.length === 0 ? (
                <div className="text-center py-12">
                  <FileText size={48} className="mx-auto text-slate-200 mb-4" />
                  <p className="text-slate-500 font-medium">No questions added yet.</p>
                </div>
              ) : (
                questions.map((q, idx) => (
                  <div key={q.questionId} className="p-6 bg-slate-50 rounded-xl border border-slate-200 group relative">
                    <div className="flex justify-between items-start mb-4">
                      <div className="flex-1">
                        <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2 py-1 rounded mb-2 inline-block">Q{idx + 1} • {q.subject}</span>
                        <MathText className="font-bold text-slate-900" text={q.questionTextEnglish} />
                        {q.questionTextHindi && <MathText className="text-slate-500 text-sm mt-1" text={q.questionTextHindi} />}
                      </div>
                      <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          onClick={() => {
                            setEditingQuestion(q);
                            setShowAddQuestion(true);
                          }}
                          className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg"
                        >
                          <Edit size={18} />
                        </button>
                        <button
                          onClick={() => setDeleteConfirm({ type: 'question', id: q.questionId, title: q.questionTextEnglish })}
                          className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                        >
                          <Trash2 size={18} />
                        </button>
                      </div>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      {q.options.map((opt, oIdx) => (
                        <div
                          key={oIdx}
                          className={`p-3 rounded-xl border text-sm flex flex-col gap-1 ${oIdx === q.correctAnswer ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-bold' : 'bg-white border-slate-100 text-slate-600'}`}
                        >
                          <div className="flex items-center gap-3">
                            <span className="w-6 h-6 rounded-lg bg-slate-100 flex items-center justify-center text-[10px] font-bold shrink-0">{oIdx + 1}</span>
                            <MathText text={opt.textEnglish} />
                          </div>
                          {opt.textHindi && <MathText className="text-xs opacity-70 ml-9" text={opt.textHindi} />}
                        </div>
                      ))}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>, document.body
      )}

      {/* Add/Edit Question Modal */}
      {showAddQuestion && editingQuestion && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[99999] p-4 md:p-6">
          <div className="bg-white rounded-xl w-full max-w-2xl max-h-[85vh] shadow-2xl flex flex-col overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <h3 className="text-xl font-bold text-slate-900">{editingQuestion.questionId ? 'Edit Question' : 'Add New Question'}</h3>
              <button onClick={() => setShowAddQuestion(false)} className="p-2 hover:bg-slate-100 rounded-lg transition-colors"><X size={20} /></button>
            </div>
            <form onSubmit={handleSaveQuestion} className="flex-1 overflow-y-auto p-6 space-y-6 no-scrollbar">
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-bold text-slate-700">Question Text (English)</label>
                  <span className="text-[10px] text-slate-400">Tip: Use $...$ for math (e.g. $E=mc^2$)</span>
                </div>
                <textarea
                  required
                  value={editingQuestion.questionTextEnglish}
                  onChange={e => setEditingQuestion({ ...editingQuestion, questionTextEnglish: e.target.value })}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 h-24"
                  placeholder="Enter question in English..."
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Question Text (Hindi) - Optional</label>
                <textarea
                  value={editingQuestion.questionTextHindi}
                  onChange={e => setEditingQuestion({ ...editingQuestion, questionTextHindi: e.target.value })}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 h-24"
                  placeholder="Enter question in Hindi..."
                />
              </div>

              {/* Math Preview */}
              {(editingQuestion.questionTextEnglish.includes('$') || editingQuestion.questionTextHindi.includes('$')) && (
                <div className="p-4 bg-blue-50 border border-blue-100 rounded-xl space-y-2">
                  <h4 className="text-[10px] font-bold text-blue-600 uppercase tracking-wider">Math Preview</h4>
                  <div className="space-y-2">
                    <MathText className="text-sm font-medium text-slate-800" text={editingQuestion.questionTextEnglish} />
                    {editingQuestion.questionTextHindi && (
                      <MathText className="text-xs text-slate-500" text={editingQuestion.questionTextHindi} />
                    )}
                  </div>
                </div>
              )}

              <div className="space-y-4">
                <label className="text-sm font-bold text-slate-700">Options (Select correct one)</label>
                <div className="space-y-3">
                  {editingQuestion.options.map((opt, i) => (
                    <div key={i} className="flex flex-col gap-2 p-4 bg-slate-50 rounded-xl border border-slate-200">
                      <div className="flex items-center gap-3">
                        <input
                          type="radio"
                          name="correct-answer"
                          checked={editingQuestion.correctAnswer === i}
                          onChange={() => setEditingQuestion({ ...editingQuestion, correctAnswer: i })}
                          className="w-5 h-5 text-emerald-500 focus:ring-emerald-500"
                        />
                        <span className="text-sm font-bold text-slate-500">Option {i + 1}</span>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 pl-8">
                        <input
                          required
                          type="text"
                          value={opt.textEnglish}
                          onChange={e => {
                            const newOpts = [...editingQuestion.options];
                            newOpts[i] = { ...newOpts[i], textEnglish: e.target.value };
                            setEditingQuestion({ ...editingQuestion, options: newOpts });
                          }}
                          className="px-4 py-2 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                          placeholder="English text"
                        />
                        <input
                          type="text"
                          value={opt.textHindi}
                          onChange={e => {
                            const newOpts = [...editingQuestion.options];
                            newOpts[i] = { ...newOpts[i], textHindi: e.target.value };
                            setEditingQuestion({ ...editingQuestion, options: newOpts });
                          }}
                          className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                          placeholder="Hindi text"
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-bold text-slate-700">Subject</label>
                  <input
                    type="text"
                    value={editingQuestion.subject}
                    onChange={e => setEditingQuestion({ ...editingQuestion, subject: e.target.value })}
                    className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                </div>
                <CustomSelect
                  label="Difficulty"
                  value={editingQuestion.difficultyLevel}
                  onChange={(val) => setEditingQuestion({ ...editingQuestion, difficultyLevel: val as any })}
                  options={[
                    { value: 'easy', label: 'Easy' },
                    { value: 'medium', label: 'Medium' },
                    { value: 'hard', label: 'Hard' }
                  ]}
                  className="w-full"
                />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Explanation (English)</label>
                <textarea
                  value={editingQuestion.explanation}
                  onChange={e => setEditingQuestion({ ...editingQuestion, explanation: e.target.value })}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 h-24"
                  placeholder="Enter explanation in English..."
                />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Explanation (Hindi)</label>
                <textarea
                  value={editingQuestion.explanationHindi}
                  onChange={e => setEditingQuestion({ ...editingQuestion, explanationHindi: e.target.value })}
                  className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 h-24"
                  placeholder="Enter explanation in Hindi..."
                />
              </div>

              <div className="pt-4">
                <button
                  type="submit"
                  className="w-full bg-emerald-500 text-white py-4 rounded-xl font-bold hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100"
                >
                  {editingQuestion.questionId ? 'Update Question' : 'Save Question'}
                </button>
              </div>
            </form>
          </div>
        </div>, document.body
      )}

      {showAddPoll && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4">
          <motion.div
            initial={{ scale: 0.95, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            className="relative w-full max-w-xl max-h-[90vh] bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden flex flex-col"
          >
             <div className="py-4 px-6 md:py-5 md:px-8 border-b border-slate-50 flex items-center justify-between bg-slate-50/30">
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 md:w-12 md:h-12 bg-emerald-500 text-white rounded-full flex items-center justify-center shrink-0">
                  <BarChart3 className="w-5 h-5 md:w-6 md:h-6" />
                </div>
                <div>
                  <h3 className="text-lg md:text-xl font-black text-slate-900 uppercase tracking-tight">
                    {editingPoll ? 'Edit Poll' : 'Create New Poll'}
                  </h3>
                  <p className="text-[9px] md:text-[10px] text-slate-400 font-bold uppercase tracking-[0.2em] mt-1">Configure Community Question</p>
                </div>
              </div>
              <button onClick={() => setShowAddPoll(false)} className="p-2 hover:bg-white rounded-xl transition-all text-slate-400">
                <X className="w-5 h-5 md:w-6 md:h-6" />
              </button>
            </div>

            <div className="p-6 md:p-8 space-y-6 flex-1 overflow-y-auto no-scrollbar">
              <div className="space-y-2">
                <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Poll Question</label>
                <textarea
                  placeholder="Enter your question here..."
                  className="w-full p-5 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:outline-none font-bold text-slate-700 min-h-[100px] resize-none"
                  value={editingPoll?.question || ''}
                  onChange={(e) => setEditingPoll(prev => ({ ...prev, question: e.target.value } as any))}
                />
              </div>

              <div className="space-y-4">
                <div className="flex items-center justify-between ml-1">
                  <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Options</label>
                  <button
                    onClick={() => {
                      const opts = [...(editingPoll?.options || ['', ''])];
                      if (opts.length < 6) {
                        opts.push('');
                        setEditingPoll(prev => ({ ...prev, options: opts } as any));
                      }
                    }}
                    className="text-[10px] font-black text-emerald-600 uppercase tracking-widest hover:underline"
                  >
                    + Add Option
                  </button>
                </div>
                
                <div className="space-y-3">
                  {(editingPoll?.options || ['', '']).map((opt, idx) => (
                    <div key={idx} className="relative group flex items-center w-full">
                      <div className="absolute left-4 top-1/2 -translate-y-1/2 w-6 h-6 bg-white border-2 border-slate-100 rounded-lg flex items-center justify-center text-[10px] font-black text-slate-400 group-focus-within:border-emerald-500 group-focus-within:text-emerald-600 transition-all z-10">
                        {idx + 1}
                      </div>
                      <input
                        type="text"
                        placeholder={`Option ${idx + 1}`}
                        className={`w-full pl-14 py-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:outline-none font-bold text-slate-700 ${idx > 1 ? 'pr-12' : 'pr-4'}`}
                        value={opt}
                        onChange={(e) => {
                          const opts = [...(editingPoll?.options || ['', ''])];
                          opts[idx] = e.target.value;
                          setEditingPoll(prev => ({ ...prev, options: opts } as any));
                        }}
                      />
                      {idx > 1 && (
                        <button
                          onClick={() => {
                            const opts = [...(editingPoll?.options || [])];
                            opts.splice(idx, 1);
                            setEditingPoll(prev => ({ ...prev, options: opts } as any));
                          }}
                          className="absolute right-3 top-1/2 -translate-y-1/2 p-2 text-slate-300 hover:text-rose-500 transition-colors z-10"
                        >
                          <X size={20} />
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Target Segment</label>
                  <CustomSelect
                    value={editingPoll?.targetSegment || 'all'}
                    onChange={(val) => setEditingPoll(prev => ({ ...prev, targetSegment: val } as any))}
                    options={[
                      { value: 'all', label: 'All Students' },
                      { value: 'pro', label: 'PRO Members Only' },
                      { value: 'free', label: 'Free Users Only' }
                    ]}
                    className="w-full"
                  />
                </div>
                <div className="space-y-2">
                  <CustomDateTimePicker
                    label="Expires At (Optional)"
                    value={editingPoll?.expiresAt}
                    onChange={(val) => setEditingPoll(prev => ({ ...prev, expiresAt: val } as any))}
                    accentColor="emerald"
                  />
                </div>
              </div>

              <div className="p-5 bg-emerald-50/50 rounded-lg border border-emerald-100/50 flex items-center justify-between">
                <div>
                  <p className="text-xs font-black text-emerald-900 uppercase tracking-tight">Active Status</p>
                  <p className="text-[10px] text-emerald-600 font-bold uppercase tracking-widest mt-0.5">Visible on dashboard</p>
                </div>
                <button
                  onClick={() => setEditingPoll(prev => ({ ...prev, isActive: !prev?.isActive } as any))}
                  className={`relative inline-flex h-7 w-12 shrink-0 items-center rounded-full transition-colors focus:outline-none ${editingPoll?.isActive !== false ? 'bg-emerald-500' : 'bg-slate-200'}`}
                >
                  <span className={`inline-block h-5 w-5 transform rounded-full bg-white transition-transform ${editingPoll?.isActive !== false ? 'translate-x-6' : 'translate-x-1'}`} />
                </button>
              </div>
            </div>

            <div className="p-6 md:p-8 bg-slate-50 border-t border-slate-100 flex gap-4">
              <button
                onClick={() => setShowAddPoll(false)}
                className="flex-1 py-3 bg-white text-slate-500 font-black text-xs uppercase tracking-wider rounded-xl border border-slate-200 hover:bg-slate-100 transition-all active:scale-95 text-center"
              >
                Discard
              </button>
              <button
                onClick={() => handleSavePoll(editingPoll || {})}
                className="flex-1 py-3 bg-emerald-500 text-white font-black text-xs uppercase tracking-wider rounded-xl hover:bg-emerald-600 transition-all active:scale-95 text-center"
              >
                {editingPoll?.id ? 'Update Poll' : 'Publish Poll'}
              </button>
            </div>
          </motion.div>
        </div>, document.body
      )}

      {showAddPost && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 md:p-6">
          <div className="bg-white rounded-2xl w-full max-w-4xl max-h-[85vh] shadow-2xl flex flex-col overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <h3 className="text-xl font-black text-slate-900">{editingPostObj ? 'Edit Update' : 'Create New Update'}</h3>
              <button onClick={() => { setShowAddPost(false); setIsAddingNewCategory(false); }} className="p-2 hover:bg-white rounded-xl transition-colors text-slate-400 hover:text-slate-600 shadow-sm border border-transparent hover:border-slate-200">
                <X size={24} />
              </button>
            </div>
            <form onSubmit={handleSavePost} className="flex-1 flex flex-col min-h-0">
              <div className="flex-1 overflow-y-auto p-8 space-y-8 no-scrollbar">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div className="space-y-6">
                  <div>
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Post Title</label>
                    <input
                      required
                      type="text"
                      value={postFormData.title}
                      onChange={e => {
                        const title = e.target.value;
                        const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
                        setPostFormData({ ...postFormData, title, slug });
                      }}
                      className="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-slate-700"
                      placeholder="Enter update title..."
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">URL Slug</label>
                    <input
                      required
                      type="text"
                      value={postFormData.slug}
                      onChange={e => setPostFormData({ ...postFormData, slug: e.target.value })}
                      className="w-full px-5 py-3 bg-slate-100 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-mono text-xs text-slate-600"
                      placeholder="url-slug-here"
                    />
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-2 min-w-0">
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest">Category</label>
                      {!isAddingNewCategory ? (
                        <div className="flex gap-2">
                          <CustomSelect
                            value={postFormData.category}
                            onChange={(val) => {
                              if (val === '__add_new__') {
                                setIsAddingNewCategory(true);
                                setPostFormData({ ...postFormData, category: '' });
                              } else {
                                setPostFormData({ ...postFormData, category: val });
                              }
                            }}
                            options={[
                              { value: '', label: 'Select Category' },
                              ...existingPostCategories.map(cat => ({ value: cat, label: cat })),
                              { value: '__add_new__', label: '+ Add New Category' }
                            ]}
                            className="flex-1 !space-y-0"
                          />
                        </div>
                      ) : (
                        <div className="relative flex items-center animate-in fade-in slide-in-from-left-2 duration-300">
                          <input
                            autoFocus
                            type="text"
                            value={postFormData.category}
                            onChange={e => setPostFormData({ ...postFormData, category: e.target.value })}
                            className="w-full pl-5 pr-12 py-3 bg-white border-2 border-emerald-500 rounded-xl outline-none font-bold text-slate-700 shadow-lg shadow-emerald-500/10"
                            placeholder="Type new category..."
                          />
                          <button
                            type="button"
                            onClick={() => setIsAddingNewCategory(false)}
                            className="absolute right-2 p-2 text-slate-400 hover:text-emerald-500 hover:bg-emerald-50 rounded-lg transition-all"
                            title="Back to selection"
                          >
                            <RotateCcw size={18} />
                          </button>
                        </div>
                      )}
                    </div>
                    <div className="min-w-0">
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Status</label>
                      <div className="flex items-center gap-3 h-[46px] px-5 bg-slate-50 border border-slate-200 rounded-xl">
                        <span className="text-xs font-bold text-slate-600 flex-1">{postFormData.isActive ? 'Published' : 'Draft'}</span>
                        <button
                          type="button"
                          onClick={() => setPostFormData({ ...postFormData, isActive: !postFormData.isActive })}
                          className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${postFormData.isActive ? 'bg-emerald-500' : 'bg-slate-300'}`}
                        >
                          <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${postFormData.isActive ? 'translate-x-6' : 'translate-x-1'}`} />
                        </button>
                      </div>
                    </div>
                    <div className="min-w-0 col-span-1 sm:col-span-2 md:col-span-1">
                      <label className="block text-[10px] font-black text-emerald-600 uppercase tracking-widest mb-2 flex items-center gap-2">
                        <Bell size={12} />
                        Push Notifications
                      </label>
                      <div className="flex items-center gap-3 h-[46px] px-5 bg-emerald-50 border border-emerald-100 rounded-xl">
                        <span className="text-[10px] font-black text-emerald-700 flex-1 uppercase tracking-tight">Notify Users?</span>
                        <button
                          type="button"
                          onClick={() => setPostFormData({ ...postFormData, sendNotification: !postFormData.sendNotification })}
                          className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors ${postFormData.sendNotification ? 'bg-emerald-500' : 'bg-slate-300'}`}
                        >
                          <span className={`inline-block h-3 w-3 transform rounded-full bg-white transition-transform ${postFormData.sendNotification ? 'translate-x-5' : 'translate-x-1'}`} />
                        </button>
                      </div>
                    </div>
                  </div>
                  <div>
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Image URL / Upload</label>
                    <div className="space-y-3">
                      <div className="flex flex-col sm:flex-row gap-3">
                        <input
                          type="url"
                          value={postFormData.imageUrl}
                          onChange={e => setPostFormData({ ...postFormData, imageUrl: e.target.value })}
                          className="flex-1 px-5 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-medium text-slate-600 text-sm"
                          placeholder="https://images.unsplash.com/..."
                        />
                        <div className="relative group/upload h-[46px] sm:h-auto">
                          <input
                            type="file"
                            accept="image/*"
                            onChange={handlePostImageUpload}
                            className="absolute inset-0 opacity-0 cursor-pointer z-10"
                            disabled={isUploadingPostImage}
                          />
                          <button
                            type="button"
                            className="w-full sm:w-auto h-full px-6 bg-emerald-50 text-emerald-600 rounded-xl border border-emerald-100 hover:bg-emerald-100 transition-all flex items-center justify-center gap-2 font-bold text-xs whitespace-nowrap shadow-sm active:scale-95"
                          >
                            {isUploadingPostImage ? <Loader2 size={16} className="animate-spin" /> : <Upload size={16} />}
                            <span>Upload Image</span>
                          </button>
                        </div>
                      </div>
                      {postFormData.imageUrl && (
                        <div className="relative h-32 rounded-xl overflow-hidden border border-slate-100">
                          <img src={postFormData.imageUrl} alt="Preview" className="w-full h-full object-cover" />
                          <button
                            type="button"
                            onClick={() => setPostFormData({ ...postFormData, imageUrl: '' })}
                            className="absolute top-2 right-2 p-1 bg-white/80 backdrop-blur-sm text-rose-500 rounded-lg hover:bg-rose-500 hover:text-white transition-all shadow-sm"
                          >
                            <X size={14} strokeWidth={3} />
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                <div className="space-y-6">
                  <div>
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Excerpt (SEO Description)</label>
                    <textarea
                      required
                      value={postFormData.excerpt}
                      onChange={e => setPostFormData({ ...postFormData, excerpt: e.target.value, metaDescription: e.target.value })}
                      className="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-medium text-slate-600 h-32 resize-none"
                      placeholder="Short summary for the feed and search engines..."
                    />
                  </div>
                  <div className="bg-emerald-50 p-6 rounded-2xl border border-emerald-100">
                    <h4 className="text-[10px] font-black text-emerald-600 uppercase tracking-widest mb-4">SEO Optimization</h4>
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Meta Title</label>
                        <input
                          type="text"
                          value={postFormData.metaTitle}
                          onChange={e => setPostFormData({ ...postFormData, metaTitle: e.target.value })}
                          className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none text-xs font-bold"
                          placeholder="If different from title"
                        />
                      </div>
                      <div>
                        <label className="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Meta Description</label>
                        <textarea
                          value={postFormData.metaDescription}
                          onChange={e => setPostFormData({ ...postFormData, metaDescription: e.target.value })}
                          className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg focus:ring-2 focus:ring-emerald-500 outline-none text-xs font-medium h-20 resize-none"
                          placeholder="Custom SEO description"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-4">
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Main Content (Formatted Text)</label>
                <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden min-h-[400px] flex flex-col">
                  <ReactQuill
                    theme="snow"
                    value={postFormData.content}
                    onChange={(content) => setPostFormData({ ...postFormData, content })}
                    modules={quillModules}
                    formats={quillFormats}
                    placeholder="Write your content here with rich formatting..."
                    className="flex-1 flex flex-col"
                  />
                </div>
                <style>{`
                  .quill {
                    display: flex;
                    flex-direction: column;
                    height: 100%;
                  }
                  .ql-container {
                    flex: 1;
                    font-size: 16px;
                    border: none !important;
                  }
                  .ql-toolbar {
                    border: none !important;
                    border-bottom: 1px solid #e2e8f0 !important;
                    background: #f8fafc;
                    padding: 12px !important;
                  }
                  .ql-editor {
                    min-height: 350px;
                    padding: 24px;
                  }
                `}</style>
              </div>

              </div>{/* end scrollable */}

              <div className="px-8 py-4 border-t border-slate-100 flex items-center justify-end gap-4 shrink-0 bg-white">
                <button
                  type="button"
                  onClick={() => { setShowAddPost(false); setIsAddingNewCategory(false); }}
                  className="px-8 py-4 bg-slate-100 text-slate-500 font-black rounded-xl hover:bg-slate-200 transition-all uppercase tracking-widest text-xs"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSavingPost}
                  className="px-10 py-4 bg-emerald-500 text-white font-black rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 flex items-center gap-3 disabled:opacity-50 uppercase tracking-widest text-xs"
                >
                  {isSavingPost && <Loader2 size={18} className="animate-spin" />}
                  {editingPostObj ? 'Update Post' : 'Publish Post'}
                </button>
              </div>
            </form>
          </div>
        </div>
      , document.body)}

      {/* Test Analytics Modal */}
      {viewingAnalyticsFor && createPortal(
          <div
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-6"
          >
            <div
              className="bg-white rounded-2xl max-w-4xl w-full max-h-[85vh] shadow-2xl border border-slate-100 flex flex-col overflow-hidden"
            >
              {/* Modal Header */}
              <div className="p-6 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-indigo-100 text-indigo-600 rounded-xl flex items-center justify-center shadow-sm">
                    <BarChart3 size={24} />
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-slate-900">Test Analytics</h3>
                    <p className="text-xs text-slate-500 font-medium truncate max-w-[300px]">{viewingAnalyticsFor.title}</p>
                  </div>
                </div>
                <button
                  onClick={() => setViewingAnalyticsFor(null)}
                  className="p-2 hover:bg-white rounded-xl transition-colors text-slate-400 hover:text-slate-600 shadow-sm border border-transparent hover:border-slate-200"
                >
                  <X size={24} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-8 no-scrollbar">
                {isFetchingAnalytics ? (
                  <div className="flex flex-col items-center justify-center py-20 text-slate-400">
                    <Loader2 size={40} className="animate-spin mb-4 text-indigo-500" />
                    <p className="font-bold text-sm">Fetching attempt records...</p>
                  </div>
                ) : analyticsAttempts.length === 0 ? (
                  <div className="text-center py-20 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                    <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-4 shadow-sm">
                      <AlertCircle size={32} className="text-slate-300" />
                    </div>
                    <h4 className="text-lg font-bold text-slate-900">No attempts found</h4>
                    <p className="text-sm text-slate-400">This test hasn't been attempted by any user yet.</p>
                  </div>
                ) : (
                  <>
                    {/* Quick Stats Grid */}
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      {[
                        { label: 'Total Attempts', value: analyticsStats.total, icon: Users, color: 'text-blue-600', bg: 'bg-blue-50' },
                        { label: 'Average Score', value: `${analyticsStats.avgScore.toFixed(1)}%`, icon: Sparkles, color: 'text-emerald-600', bg: 'bg-emerald-50' },
                        { label: 'Top Performer', value: `${analyticsStats.topScore.toFixed(1)}%`, icon: Zap, color: 'text-amber-600', bg: 'bg-amber-50' }
                      ].map((stat, idx) => (
                        <div key={idx} className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-4">
                          <div className={`w-12 h-12 ${stat.bg} ${stat.color} rounded-xl flex items-center justify-center shrink-0`}>
                            <stat.icon size={24} />
                          </div>
                          <div>
                            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">{stat.label}</p>
                            <p className="text-2xl font-black text-slate-900">{stat.value}</p>
                          </div>
                        </div>
                      ))}
                    </div>

                    {/* Recent Attempts Table */}
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <h4 className="font-bold text-slate-800 flex items-center gap-2">
                          <Clock size={18} className="text-slate-400" />
                          Recent Activity
                        </h4>
                        <span className="text-[10px] font-bold text-slate-400 uppercase bg-slate-100 px-2 py-1 rounded-md">Showing Last 50</span>
                      </div>
                      <div className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm">
                        <div className="overflow-x-auto">
                          <table className="w-full text-left">
                            <thead className="bg-slate-50/50 border-b border-slate-100">
                              <tr>
                                <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">User Profile</th>
                                <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Attempted On</th>
                                <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Score</th>
                                <th className="px-6 py-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Duration</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                              {analyticsAttempts.map((attempt) => {
                                const user = analyticsUserMap[attempt.userId] || users.find(u => u.userId === attempt.userId);
                                const score = attempt.score || 0;
                                const date = new Date(attempt.startTime).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });

                                return (
                                  <tr key={attempt.attemptId} className="hover:bg-slate-50/30 transition-colors">
                                    <td className="px-6 py-4">
                                      <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 font-bold text-xs ring-2 ring-white">
                                          {user?.name?.charAt(0) || <Users size={14} />}
                                        </div>
                                        <div>
                                          <p className="text-sm font-bold text-slate-900">{user?.name || 'Unknown User'}</p>
                                          <p className="text-[10px] text-slate-400 font-medium">{user?.email || attempt.userId}</p>
                                        </div>
                                      </div>
                                    </td>
                                    <td className="px-6 py-4 text-xs font-medium text-slate-500">{date}</td>
                                    <td className="px-6 py-4">
                                      <div className="flex items-center gap-2">
                                        <div className={`text-sm font-bold ${score >= 70 ? 'text-emerald-600' : score >= 40 ? 'text-amber-600' : 'text-red-500'}`}>
                                          {score.toFixed(1)}%
                                        </div>
                                        <div className="w-16 h-1.5 bg-slate-100 rounded-full overflow-hidden shrink-0">
                                          <div className={`h-full rounded-full ${score >= 70 ? 'bg-emerald-500' : score >= 40 ? 'bg-amber-500' : 'bg-red-500'}`} style={{ width: `${score}%` }} />
                                        </div>
                                      </div>
                                    </td>
                                    <td className="px-6 py-4 text-xs font-bold text-slate-500">
                                      {attempt.timeTaken ? `${Math.floor(attempt.timeTaken / 60)}m ${attempt.timeTaken % 60}s` : '--'}
                                    </td>
                                  </tr>
                                );
                              })}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </div>

              <div className="p-6 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Database Optimization: Manual Refresh Only</p>
                <button
                  onClick={() => viewingAnalyticsFor && fetchTestAnalytics(viewingAnalyticsFor)}
                  className="text-xs font-bold text-indigo-600 hover:text-indigo-700 flex items-center gap-2 transition-colors"
                >
                  <RotateCcw size={14} />
                  Refresh Data
                </button>
              </div>
            </div>
          </div>, document.body
        )}


      {/* Export Options Modal */}
      <AnimatePresence>
        {showExportModal && testToExport && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[300] p-6"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="bg-white rounded-xl p-8 max-w-md w-full shadow-2xl border border-slate-100 relative overflow-hidden"
            >
              <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-50 rounded-full -mr-16 -mt-16 opacity-50" />

              <div className="relative">
                <div className="flex items-center justify-between mb-6">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center shadow-sm">
                      <Download size={24} />
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-slate-900">Export Test</h3>
                      <p className="text-xs text-slate-500 font-medium truncate max-w-[200px]">{testToExport.title}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => {
                      setShowExportModal(false);
                      setTestToExport(null);
                    }}
                    className="p-2 hover:bg-slate-100 rounded-xl transition-colors text-slate-400 hover:text-slate-600"
                  >
                    <X size={24} />
                  </button>
                </div>

                <div className="grid grid-cols-1 gap-3">
                  {[
                    { id: 'pdf', label: 'Export as PDF', icon: FileText, color: 'text-red-500', bg: 'bg-red-50', sub: 'Best for printing and sharing' },
                    { id: 'docx', label: 'Export as Word', icon: Download, color: 'text-blue-500', bg: 'bg-blue-50', sub: 'Editable document format' },
                    { id: 'txt', label: 'Export as Text', icon: FileText, color: 'text-slate-600', bg: 'bg-slate-100', sub: 'Plain text for simple use' },
                    { id: 'print', label: 'Print Directly', icon: Layout, color: 'text-purple-500', bg: 'bg-purple-50', sub: 'Open browser print dialog' }
                  ].map((option) => (
                    <button
                      key={option.id}
                      onClick={() => {
                        if (option.id === 'print') {
                          window.print();
                        } else {
                          handleExportTest(testToExport, option.id as any);
                        }
                        setShowExportModal(false);
                        setTestToExport(null);
                      }}
                      className="flex items-center gap-4 p-4 rounded-xl border border-slate-100 hover:border-emerald-200 hover:bg-emerald-50/30 transition-all group active:scale-[0.98] text-left"
                    >
                      <div className={`w-10 h-10 ${option.bg} ${option.color} rounded-xl flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform`}>
                        <option.icon size={20} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-bold text-slate-900 text-sm">{option.label}</p>
                        <p className="text-[10px] text-slate-500 font-medium">{option.sub}</p>
                      </div>
                      <ChevronRight size={16} className="text-slate-300 group-hover:translate-x-1 transition-transform" />
                    </button>
                  ))}
                </div>

                <p className="mt-6 text-center text-[10px] text-slate-400 font-medium">
                  Select a format to download this test series.
                </p>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>


      {/* Delete Confirmation Modal */}
      {deleteConfirm && createPortal(
          <div
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[99999] p-6"
          >
            <div
              className="bg-white rounded-xl p-6 max-w-sm w-full text-center shadow-2xl border border-slate-100"
            >
              <div className="w-16 h-16 bg-red-50 text-red-500 rounded-xl flex items-center justify-center mx-auto mb-4">
                <AlertTriangle size={32} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2">Are you sure?</h3>
              <p className="text-slate-500 mb-6 leading-relaxed text-sm">
                You are about to delete <span className="font-bold text-slate-900">"{deleteConfirm.title}"</span>.
                This action cannot be undone.
              </p>
              <div className="flex gap-4">
                <button
                  onClick={() => setDeleteConfirm(null)}
                  disabled={isDeleting}
                  className="flex-1 py-3 bg-slate-100 text-slate-700 font-bold rounded-xl hover:bg-slate-200 transition-all disabled:opacity-50 text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    if (deleteConfirm.type === 'test') {
                      handleDeleteTest(deleteConfirm.id);
                    } else if (deleteConfirm.type === 'question') {
                      handleDeleteQuestion(deleteConfirm.id);
                    } else if (deleteConfirm.type === 'pattern') {
                      handleDeletePattern(deleteConfirm.id);
                    } else if (deleteConfirm.type === 'examCategory') {
                      const catToDelete = examCategories.find(c => c.id === deleteConfirm.id);
                      if (catToDelete) {
                        handleDeleteExamCategory(catToDelete);
                      } else {
                        setDeleteConfirm(null);
                      }
                    } else if (deleteConfirm.type === 'category') {
                      handleDeleteCategory(deleteConfirm.id);
                    } else if (deleteConfirm.type === 'topic') {
                      const handleTopicDelete = async () => {
                        setIsDeleting(true);
                        try {
                          const catId = deleteConfirm.metadata?.categoryId;
                          const topicToRemove = deleteConfirm.id;
                          const category = categories.find(c => c.id === catId);
                          if (category && category.topics) {
                            const updatedTopics = category.topics.filter(t => t !== topicToRemove);
                            const { doc, updateDoc } = await import('firebase/firestore');
                            await updateDoc(doc(db, 'categories', catId), { topics: updatedTopics });
                            setCategories(categories.map(c => c.id === catId ? { ...c, topics: updatedTopics } : c));
                            showToast(`Topic "${topicToRemove}" removed successfully.`);
                          }
                        } catch (err) {
                          console.error('Error removing topic', err);
                          showToast('Failed to remove topic.');
                        } finally {
                          setIsDeleting(false);
                          setDeleteConfirm(null);
                        }
                      };
                      handleTopicDelete();
                    } else if (deleteConfirm.type === 'declareResult') {
                      const finalizeResult = async () => {
                        setIsDeleting(true);
                        try {
                          const test = deleteConfirm.metadata?.test;
                          if (!test) return;

                          setIsDeclaringResults(true);
                          await handleDeclareResults(test);

                          try {
                            const { addDoc, collection, serverTimestamp } = await import('firebase/firestore');
                            await addDoc(collection(db, 'notifications'), {
                              userId: 'global',
                              title: 'Results Declared! 🏆',
                              message: `The results for "${test.title}" are now live.`,
                              type: 'contest',
                              read: false,
                              createdAt: serverTimestamp(),
                              actionUrl: '/earn'
                            });
                            await sendPushNotification('global', 'Results Declared! 🏆', `Contest "${test.title}" results are out!`);
                          } catch (err) {
                            console.error('Error sending global contest notification:', err);
                          }

                          setIsDeclaringResults(false);
                          setSelectedContestForReview(null);
                          fetchContests();
                        } catch (err) {
                          console.error('Error finalising results', err);
                          showToast('Failed to declare results.');
                        } finally {
                          setIsDeleting(false);
                          setDeleteConfirm(null);
                        }
                      };
                      finalizeResult();
                    } else if (deleteConfirm.type === 'poll') {
                      handleDeletePoll(deleteConfirm.id);
                    } else if (deleteConfirm.type === 'banner') {
                      const finalizeBannerDelete = async () => {
                        setIsDeleting(true);
                        await handleDeleteBanner(deleteConfirm.id, deleteConfirm.metadata?.imageUrl || '');
                        setIsDeleting(false);
                        setDeleteConfirm(null);
                      };
                      finalizeBannerDelete();
                    } else if (deleteConfirm.type === ('post' as any)) {
                      const finalizePostDelete = async () => {
                        setIsDeleting(true);
                        try {
                          await deleteDoc(doc(db, 'posts', deleteConfirm.id));
                          setAdminPosts(adminPosts.filter(p => p.id !== deleteConfirm.id));
                          showToast('Post deleted successfully', 'success');
                        } catch (err) {
                          console.error('Error deleting post', err);
                          showToast('Failed to delete post', 'error');
                        } finally {
                          setIsDeleting(false);
                          setDeleteConfirm(null);
                        }
                      };
                      finalizePostDelete();
                    }
                  }}
                  disabled={isDeleting}
                  className="flex-1 py-3 bg-red-500 text-white font-bold rounded-xl hover:bg-red-600 transition-all shadow-lg shadow-red-100 flex items-center justify-center gap-2 disabled:opacity-50 text-sm"
                >
                  {isDeleting ? (
                    <>
                      <Loader2 className="animate-spin" size={18} />
                      Deleting...
                    </>
                  ) : (
                    deleteConfirm.type === 'declareResult' ? 'Yes, Declare' : 'Yes, Delete'
                  )}
                </button>
              </div>
            </div>
          </div>,
          document.body
        )}

        <AnimatePresence>
        {showBulkDeleteConfirm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[300] p-6"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-white rounded-xl p-6 max-w-sm w-full text-center shadow-2xl border border-slate-100"
            >
              <div className="w-16 h-16 bg-red-50 text-red-500 rounded-xl flex items-center justify-center mx-auto mb-4">
                <AlertTriangle size={32} />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2">Bulk Delete?</h3>
              <p className="text-slate-500 mb-6 leading-relaxed text-sm">
                You are about to delete <span className="font-bold text-slate-900">{selectedTests.size} tests</span>.
                This action cannot be undone.
              </p>
              <div className="flex gap-4">
                <button
                  onClick={() => setShowBulkDeleteConfirm(false)}
                  disabled={isBulkDeleting}
                  className="flex-1 py-3 bg-slate-100 text-slate-700 font-bold rounded-xl hover:bg-slate-200 transition-all disabled:opacity-50 text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={handleBulkDelete}
                  disabled={isBulkDeleting}
                  style={{ backgroundColor: '#ef4444', color: '#ffffff', boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05), 0 0 0 0 rgba(252, 165, 165, 0.5)' }}
                  className="flex-1 py-3 font-bold rounded-xl hover:bg-red-600 transition-all flex items-center justify-center gap-2 disabled:opacity-50 text-sm"
                >
                  {isBulkDeleting ? (
                    <>
                      <Loader2 className="animate-spin" size={18} />
                      Deleting...
                    </>
                  ) : (
                    'Yes, Delete All'
                  )}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Admin Wallet Management Modal */}
      {createPortal(
        <AnimatePresence>
          {walletModalUser && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-[2000] p-4"
              onClick={(e) => { if (e.target === e.currentTarget) setWalletModalUser(null); }}
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0, y: 20 }}
                animate={{ scale: 1, opacity: 1, y: 0 }}
                exit={{ scale: 0.9, opacity: 0, y: 20 }}
                className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden flex flex-col max-h-[92vh]"
              >
              {/* Modal Header */}
              <div className={`p-6 relative overflow-hidden transition-colors duration-500 shrink-0 ${walletActionType === 'add'
                ? 'bg-gradient-to-r from-amber-500 to-orange-500'
                : 'bg-gradient-to-r from-rose-500 to-red-600'
                }`}>
                <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-10 -mt-10" />
                <div className="relative flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
                      {walletActionType === 'add' ? <PlusCircle size={24} className="text-white" /> : <Minus size={24} className="text-white" />}
                    </div>
                    <div>
                      <h3 className="text-white font-black text-lg">
                        {walletActionType === 'add' ? 'Credit Wallet' : 'Debit Wallet'}
                      </h3>
                      <p className="text-white/80 text-xs font-medium uppercase tracking-wider">Admin {walletActionType === 'add' ? 'Reward' : 'Correction'}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => setWalletModalUser(null)}
                    className="p-2 hover:bg-white/20 rounded-xl transition-colors text-white"
                  >
                    <X size={20} />
                  </button>
                </div>
              </div>

              <div className="p-6 space-y-5 overflow-y-auto no-scrollbar pb-24 sm:pb-6">
                {/* Action Toggle */}
                <div className="flex bg-slate-100 p-1 rounded-xl border border-slate-200">
                  <button
                    onClick={() => setWalletActionType('add')}
                    className={`flex-1 py-2.5 rounded-lg text-xs font-black transition-all flex items-center justify-center gap-2 ${walletActionType === 'add'
                      ? 'bg-white text-amber-600 shadow-sm'
                      : 'text-slate-500 hover:text-slate-700'
                      }`}
                  >
                    <PlusCircle size={14} />
                    CREDIT (ADD)
                  </button>
                  <button
                    onClick={() => setWalletActionType('deduct')}
                    className={`flex-1 py-2.5 rounded-lg text-xs font-black transition-all flex items-center justify-center gap-2 ${walletActionType === 'deduct'
                      ? 'bg-white text-rose-600 shadow-sm'
                      : 'text-slate-500 hover:text-slate-700'
                      }`}
                  >
                    <Minus size={14} />
                    DEBIT (REMOVE)
                  </button>
                </div>

                {/* User Info */}
                <div className="flex items-center gap-3 p-4 bg-slate-50 rounded-xl border border-slate-100">
                  <img
                    src={walletModalUser.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(walletModalUser.name)}&background=${walletActionType === 'add' ? 'f59e0b' : 'f43f5e'}&color=fff`}
                    className={`w-12 h-12 rounded-full object-cover border-2 transition-colors shrink-0 ${walletActionType === 'add' ? 'border-amber-100' : 'border-rose-100'}`}
                    alt={walletModalUser.name}
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-black text-slate-900 truncate">{walletModalUser.name}</p>
                    <p className="text-xs text-slate-500 truncate">{walletModalUser.email}</p>
                  </div>
                  <div className="text-right shrink-0">
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Balance</p>
                    <p className={`text-lg font-black ${walletActionType === 'add' ? 'text-amber-600' : 'text-rose-600'}`}>
                      {walletModalUser.coins?.toLocaleString() || 0}
                    </p>
                  </div>
                </div>

                {/* Quick Amounts */}
                <div>
                  <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-2">Select Amount</label>
                  <div className="grid grid-cols-4 gap-2">
                    {[50, 100, 500, 1000].map(amt => (
                      <button
                        key={amt}
                        onClick={() => setWalletCoinAmount(amt)}
                        className={`py-2.5 rounded-xl font-black text-sm border-2 transition-all ${walletCoinAmount === amt
                          ? walletActionType === 'add'
                            ? 'bg-amber-50 border-amber-400 text-amber-700 shadow-sm'
                            : 'bg-rose-50 border-rose-400 text-rose-700 shadow-sm'
                          : 'bg-white border-slate-100 text-slate-400 hover:border-slate-200'
                          }`}
                      >
                        {amt}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Custom Amount Input */}
                <div>
                  <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-2">Amount (Coins)</label>
                  <div className="relative">
                    <Coins className={`absolute left-4 top-1/2 -translate-y-1/2 ${walletActionType === 'add' ? 'text-amber-400' : 'text-rose-400'}`} size={18} />
                    <input
                      type="number"
                      min={1}
                      value={walletCoinAmount}
                      onChange={e => {
                        const val = parseInt(e.target.value);
                        setWalletCoinAmount(isNaN(val) || val < 1 ? 1 : val);
                      }}
                      className={`w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 font-black text-slate-900 text-lg transition-all ${walletActionType === 'add' ? 'focus:ring-amber-400' : 'focus:ring-rose-400'
                        }`}
                      placeholder="Enter amount..."
                    />
                  </div>
                </div>

                {/* Status Warning for Deduction */}
                {walletActionType === 'deduct' && walletCoinAmount > (walletModalUser.coins || 0) && (
                  <div className="flex items-center gap-2 p-3 bg-rose-50 text-rose-600 rounded-xl border border-rose-100 animate-pulse">
                    <AlertTriangle size={16} />
                    <p className="text-xs font-bold uppercase tracking-tight">Amount exceeds current balance!</p>
                  </div>
                )}

                {/* Reason */}
                <div>
                  <label className="block text-xs font-black text-slate-500 uppercase tracking-widest mb-2">Note / Reason</label>
                  <input
                    type="text"
                    value={walletReason}
                    onChange={e => setWalletReason(e.target.value)}
                    placeholder={walletActionType === 'add' ? "e.g. Reward for leaderboard" : "e.g. Manual correction"}
                    className={`w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 text-sm font-medium text-slate-700 transition-all ${walletActionType === 'add' ? 'focus:ring-amber-400' : 'focus:ring-rose-400'
                      }`}
                    maxLength={100}
                  />
                </div>

                {/* Summary */}
                <div className={`rounded-xl p-4 flex items-center justify-between border transition-all ${walletActionType === 'add'
                  ? 'bg-amber-50 border-amber-100'
                  : 'bg-rose-50 border-rose-100'
                  }`}>
                  <div>
                    <p className={`text-[10px] font-black uppercase tracking-widest ${walletActionType === 'add' ? 'text-amber-600' : 'text-rose-600'}`}>
                      Expected New Balance
                    </p>
                    <p className="text-2xl font-black text-slate-900">
                      {Math.max(0, walletActionType === 'add'
                        ? (walletModalUser.coins || 0) + walletCoinAmount
                        : (walletModalUser.coins || 0) - walletCoinAmount
                      ).toLocaleString()}
                      <span className="text-xs text-slate-400 font-bold ml-1 uppercase">Coins</span>
                    </p>
                  </div>
                  {walletActionType === 'add' ? <Gift size={32} className="text-amber-300" /> : <History size={32} className="text-rose-300" />}
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3">
                  <button
                    onClick={() => setWalletModalUser(null)}
                    disabled={isAddingCoins}
                    className="flex-1 py-4 bg-slate-100 text-slate-600 font-black rounded-xl hover:bg-slate-200 transition-colors text-sm disabled:opacity-50"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleAdminWalletAction}
                    disabled={isAddingCoins || walletCoinAmount <= 0 || (walletActionType === 'deduct' && walletCoinAmount > (walletModalUser.coins || 0))}
                    className={`flex-1 py-4 text-white font-black rounded-xl transition-all shadow-lg active:scale-[0.98] flex items-center justify-center gap-2 text-sm disabled:opacity-50 disabled:cursor-not-allowed ${walletActionType === 'add'
                      ? 'bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 shadow-amber-200'
                      : 'bg-gradient-to-r from-rose-500 to-red-600 hover:from-rose-600 hover:to-red-700 shadow-rose-200'
                      }`}
                  >
                    {isAddingCoins ? (
                      <><Loader2 size={16} className="animate-spin" /> Processing...</>
                    ) : (
                      <>
                        {walletActionType === 'add' ? <PlusCircle size={16} /> : <Minus size={16} />}
                        {walletActionType === 'add' ? 'Confirm Addition' : 'Confirm Deduction'}
                      </>
                    )}
                  </button>
                </div>
              </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>,
        document.body
      )}

      {/* Account Suspension Modal */}
      {createPortal(
        <AnimatePresence>
          {suspensionModalUser && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-[2000] p-4"
              onClick={(e) => { if (e.target === e.currentTarget) setSuspensionModalUser(null); }}
            >
              <motion.div
                initial={{ scale: 0.9, opacity: 0, y: 20 }}
                animate={{ scale: 1, opacity: 1, y: 0 }}
                exit={{ scale: 0.9, opacity: 0, y: 20 }}
                className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-100 max-h-[85vh] flex flex-col"
              >
              {/* Modal Header */}
              <div className="p-6 bg-slate-900 text-white relative overflow-hidden shrink-0">
                <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-10 -mt-10" />
                <div className="relative flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-white/10 rounded-xl flex items-center justify-center border border-white/20">
                      <ShieldAlert size={24} className="text-rose-400" />
                    </div>
                    <div>
                      <h3 className="text-white font-black text-lg uppercase tracking-tight">Account Enforcement</h3>
                      <p className="text-white/50 text-[10px] font-black uppercase tracking-widest">Policy Violation Management</p>
                    </div>
                  </div>
                  <button
                    onClick={() => setSuspensionModalUser(null)}
                    className="p-2 hover:bg-white/10 rounded-xl transition-colors text-white/70"
                  >
                    <X size={20} />
                  </button>
                </div>
              </div>

              <div className="p-6 space-y-6">
                {/* User Card */}
                <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100">
                  <img
                    src={suspensionModalUser.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(suspensionModalUser.name)}&background=0f172a&color=fff`}
                    className="w-14 h-14 rounded-full object-cover border-2 border-white shadow-sm shrink-0"
                    alt=""
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-black text-slate-900 truncate text-lg leading-tight">{suspensionModalUser.name}</p>
                    <p className="text-[10px] text-slate-500 font-bold truncate uppercase tracking-widest mt-1">{suspensionModalUser.email}</p>
                  </div>
                  {suspensionModalUser.violationCount && suspensionModalUser.violationCount > 0 && (
                    <div className="bg-rose-100 text-rose-600 px-3 py-1.5 rounded-xl text-[10px] font-black flex items-center gap-1.5 animate-pulse border border-rose-200">
                      <ShieldX size={12} />
                      {suspensionModalUser.violationCount} FLAGS
                    </div>
                  )}
                </div>

                {suspensionModalUser.status === 'suspended' || suspensionModalUser.status === 'banned' ? (
                  <div className="space-y-6">
                    <div className="bg-rose-50 border border-rose-100 rounded-xl p-4 text-center">
                      <p className="text-[10px] font-black text-rose-400 uppercase tracking-widest mb-1">Current Status</p>
                      <p className="text-xl font-black text-rose-600 uppercase tracking-tighter">{suspensionModalUser.status}</p>
                      <p className="text-[10px] text-slate-500 font-bold mt-2 italic">"{suspensionModalUser.banReason || 'No reason provided'}"</p>
                    </div>

                    <button
                      onClick={() => handleUpdateUserStatus(suspensionModalUser.userId, 'active')}
                      disabled={isSuspending}
                      className="w-full py-4 bg-emerald-500 text-white font-black rounded-xl hover:bg-emerald-600 transition-all shadow-lg shadow-emerald-100 active:scale-[0.98] flex items-center justify-center gap-2 text-xs uppercase tracking-widest"
                    >
                      {isSuspending ? <Loader2 size={16} className="animate-spin" /> : <UserCheck size={16} />}
                      Restore Account Access
                    </button>
                  </div>
                ) : (
                  <>
                    {/* Reason Selection */}
                    <div>
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">Violation Reason</label>
                      <div className="grid grid-cols-2 gap-2 mb-3">
                        {['Cheating (Tab Switch)', 'Multiple Accounts', 'Spam/Abuse', 'Fraudulent Payout'].map(r => (
                          <button
                            key={r}
                            onClick={() => setSuspensionReason(r)}
                            className={`text-[10px] font-bold px-3 py-2.5 rounded-lg border transition-all text-left ${suspensionReason === r
                              ? 'bg-slate-900 text-white border-slate-900 shadow-md'
                              : 'bg-white text-slate-600 border-slate-100 hover:border-slate-300'
                              }`}
                          >
                            {r}
                          </button>
                        ))}
                      </div>
                      <input
                        type="text"
                        value={suspensionReason}
                        onChange={e => setSuspensionReason(e.target.value)}
                        placeholder="Or enter custom reason..."
                        className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-slate-900 outline-none text-sm font-medium transition-all"
                      />
                    </div>

                    {/* Duration Selection */}
                    <div>
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">Enforcement Duration</label>
                      <div className="grid grid-cols-4 gap-2">
                        {[
                          { id: '24h', label: '24H' },
                          { id: '72h', label: '72H' },
                          { id: '7d', label: '7D' },
                          { id: 'permanent', label: 'PERM' }
                        ].map(d => (
                          <button
                            key={d.id}
                            onClick={() => setSuspensionDuration(d.id as any)}
                            className={`py-2.5 rounded-xl text-[10px] font-black transition-all border-2 ${suspensionDuration === d.id
                              ? 'bg-slate-900 border-slate-900 text-white shadow-md'
                              : 'bg-white border-slate-100 text-slate-400 hover:border-slate-200'
                              }`}
                          >
                            {d.label}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Warning Box */}
                    <div className="p-4 bg-rose-50 rounded-xl border border-rose-100 flex gap-3">
                      <AlertTriangle className="text-rose-500 shrink-0" size={18} />
                      <p className="text-[10px] text-rose-800 font-bold leading-relaxed uppercase">
                        Suspension will freeze all wallet activities and revoke app access immediately.
                      </p>
                    </div>

                    <button
                      onClick={() => handleUpdateUserStatus(
                        suspensionModalUser.userId,
                        suspensionDuration === 'permanent' ? 'banned' : 'suspended',
                        suspensionReason,
                        suspensionDuration
                      )}
                      disabled={isSuspending || !suspensionReason.trim()}
                      className="w-full py-4 bg-rose-500 text-white font-black rounded-xl hover:bg-rose-600 transition-all shadow-lg shadow-rose-100 active:scale-[0.98] flex items-center justify-center gap-2 text-xs uppercase tracking-widest disabled:opacity-50"
                    >
                      {isSuspending ? <Loader2 size={16} className="animate-spin" /> : <Ban size={16} />}
                      Confirm Enforcement
                    </button>
                  </>
                )}
              </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>,
        document.body
      )}

      {/* Hidden PDF Export Content */}
      {exportingTestData && (
        <div className="fixed -left-[9999px] top-0 overflow-hidden">
          <div id="pdf-export-content" style={{ backgroundColor: '#ffffff', color: '#0f172a' }} className="p-12 w-[800px] font-sans">
            <div style={{ borderColor: '#0f172a', borderBottomWidth: '2px', textAlign: 'center', paddingBottom: '1.5rem', marginBottom: '2rem' }} className="border-b">
              <h1 style={{ color: '#0f172a', fontSize: '1.875rem', fontWeight: 900, textTransform: 'uppercase', letterSpacing: '-0.025em', marginBottom: '0.5rem' }}>{exportingTestData.test.title}</h1>
              <div style={{ color: '#475569', display: 'flex', justifyContent: 'center', gap: '1.5rem', fontSize: '0.875rem', fontWeight: 700 }}>
                <span>CATEGORY: {exportingTestData.test.category}</span>
                <span>DURATION: {exportingTestData.test.duration} MINS</span>
                <span>QUESTIONS: {exportingTestData.questions.length}</span>
              </div>
            </div>

            <div className="space-y-10">
              {exportingTestData.questions.map((q, idx) => (
                <div key={idx} className="space-y-4" style={{ breakInside: 'avoid', marginBottom: '2.5rem' }}>
                  <div style={{ display: 'flex', gap: '0.75rem' }}>
                    <span style={{ color: '#0f172a', fontWeight: 900, fontSize: '1.125rem' }}>Q{idx + 1}.</span>
                    <div style={{ flex: 1 }} className="space-y-2">
                      <MathText style={{ color: '#0f172a', fontSize: '1.125rem', fontWeight: 700, lineHeight: 1.625 }} text={q.questionTextEnglish} />
                      {q.questionTextHindi && (
                        <MathText style={{ color: '#475569', fontSize: '1rem', fontStyle: 'italic', lineHeight: 1.625 }} text={q.questionTextHindi} />
                      )}
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', columnGap: '2rem', rowGap: '0.75rem', marginLeft: '2.5rem' }}>
                    {q.options.map((opt, oIdx) => (
                      <div key={oIdx} style={{ display: 'flex', gap: '0.5rem', alignItems: 'flex-start' }}>
                        <span style={{ color: '#475569', fontWeight: 700 }}>({String.fromCharCode(65 + oIdx)})</span>
                        <div style={{ flex: 1 }}>
                          <MathText style={{ color: '#1e293b', fontSize: '0.875rem', fontWeight: 500 }} text={opt.textEnglish} />
                          {opt.textHindi && (
                            <MathText style={{ color: '#64748b', fontSize: '0.75rem', fontStyle: 'italic' }} text={opt.textHindi} />
                          )}
                        </div>
                      </div>
                    ))}
                  </div>

                  <div style={{ borderTopWidth: '1px', borderTopColor: '#f1f5f9', marginLeft: '2.5rem', paddingTop: '1rem' }} className="space-y-2">
                    <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
                      <span style={{ backgroundColor: '#0f172a', color: '#ffffff', fontSize: '0.75rem', fontWeight: 900, paddingLeft: '0.5rem', paddingRight: '0.5rem', paddingTop: '0.125rem', paddingBottom: '0.125rem', borderRadius: '0.25rem' }}>CORRECT ANSWER:</span>
                      <span style={{ color: '#059669', fontWeight: 700 }}>({String.fromCharCode(65 + q.correctAnswer)})</span>
                    </div>
                    {(q.explanation || q.explanationHindi) && (
                      <div style={{ backgroundColor: '#f8fafc', padding: '1rem', borderRadius: '0.5rem' }}>
                        <span style={{ color: '#94a3b8', fontSize: '0.625rem', fontWeight: 900, textTransform: 'uppercase', display: 'block', marginBottom: '0.25rem' }}>Explanation</span>
                        {q.explanation && <MathText style={{ color: '#334155', fontSize: '0.875rem', lineHeight: 1.625 }} text={q.explanation} />}
                        {q.explanationHindi && <MathText style={{ color: '#64748b', fontSize: '0.875rem', fontStyle: 'italic', lineHeight: 1.625, marginTop: '0.25rem' }} text={q.explanationHindi} />}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>

            <div style={{ borderTopWidth: '1px', borderTopColor: '#e2e8f0', color: '#94a3b8' }} className="mt-12 pt-6 border-t text-center text-[10px] font-bold uppercase tracking-widest">
              Generated by Rankearn • {new Date().toLocaleDateString()}
            </div>
          </div>
        </div>
      )}

      {/* --- Restored Manage Categories Modal (Subject -> Topics) --- */}
      <AnimatePresence>
        {showManageCategories && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 sm:p-6 overflow-y-auto"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0, y: 20 }}
              animate={{ scale: 1, opacity: 1, y: 0 }}
              exit={{ scale: 0.95, opacity: 0, y: 20 }}
              className="bg-white rounded-xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh]"
            >
              <div className="p-6 border-b border-slate-100 flex items-center justify-between sticky top-0 bg-white z-10 shrink-0">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center">
                    <Folder size={20} />
                  </div>
                  <h2 className="text-xl font-bold text-slate-900">Manage Categories (Subjects & Topics)</h2>
                </div>
                <button
                  onClick={() => setShowManageCategories(false)}
                  className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-50 rounded-xl transition-colors"
                >
                  <X size={24} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto no-scrollbar p-6 bg-slate-50/50 space-y-6">

                {/* Exam Group Filter */}
                <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
                  <CustomSelect
                    label="Filter Subjects by Exam Group"
                    value={selectedExamForSubject}
                    onChange={setSelectedExamForSubject}
                    options={[
                      { value: 'all', label: 'All Exams (Global)' },
                      ...examCategories.map(cat => ({ value: cat.id, label: cat.name }))
                    ]}
                    className="w-full"
                  />
                </div>

                {/* Add New Subject */}
                <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
                  <h3 className="text-sm font-bold text-slate-700 mb-3 uppercase tracking-wider flex items-center gap-2">
                    <Plus size={16} /> Create New {selectedExamForSubject === 'all' ? 'Global' : findExamCategoryGroupById(examCategories, selectedExamForSubject)?.name} Subject
                  </h3>
                  <form onSubmit={handleCreateCategory} className="flex gap-3">
                    <input
                      type="text"
                      value={newCategoryName}
                      onChange={e => setNewCategoryName(capitalizeWords(e.target.value))}
                      placeholder="e.g. Mathematics, History, Reasoning"
                      className="flex-1 px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 font-medium"
                    />
                    <button
                      type="submit"
                      disabled={isAddingCategory || !newCategoryName.trim()}
                      className="px-6 py-3 bg-slate-900 text-white font-bold rounded-xl hover:bg-slate-800 transition-colors disabled:opacity-50 flex items-center gap-2 whitespace-nowrap"
                    >
                      {isAddingCategory ? <Loader2 className="animate-spin" size={20} /> : <Plus size={20} />} Add
                    </button>
                  </form>
                </div>

                {/* List Subjects & Topics */}
                <div className="space-y-4">
                  {categories
                    .filter(c => selectedExamForSubject === 'all' || c.parentExamId === selectedExamForSubject)
                    .map(category => (
                      <div key={category.id} className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
                        <div className="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/30 border-b border-slate-100">
                          <div className="flex items-center gap-3">
                            <div className="p-2 bg-emerald-50 text-emerald-600 rounded-lg">
                              <Layers size={18} />
                            </div>
                            <div>
                              <h4 className="font-bold text-slate-900 text-lg flex items-center gap-2">
                                {category.name}
                                {category.parentExamName && (
                                  <span className="text-[10px] bg-slate-100 text-slate-500 px-2 py-0.5 rounded-full font-bold uppercase tracking-wider">
                                    {category.parentExamName}
                                  </span>
                                )}
                              </h4>
                              <p className="text-xs text-slate-500 font-medium">{category.topics?.length || 0} Topics available</p>
                            </div>
                          </div>
                          <button
                            onClick={() => {
                              setDeleteConfirm({
                                type: 'category',
                                id: category.id,
                                title: category.name
                              });
                            }}
                            className="text-red-500 hover:text-red-700 p-2 hover:bg-red-50 rounded-lg transition-colors flex items-center justify-center"
                            title="Delete Subject"
                          >
                            <Trash2 size={18} />
                          </button>
                        </div>

                        <div className="p-4 space-y-4">
                          {/* Topic Tags */}
                          <div className="flex flex-wrap gap-2">
                            {(category.topics || []).map((topic, idx) => (
                              <div key={idx} className="flex items-center gap-1 bg-emerald-50 border border-emerald-100 text-emerald-700 px-3 py-1.5 rounded-lg text-sm font-medium">
                                <Tag size={12} className="opacity-70" /> {topic}
                                <button
                                  onClick={() => {
                                    setDeleteConfirm({
                                      type: 'topic',
                                      id: topic,
                                      title: topic,
                                      metadata: { categoryId: category.id, categoryName: category.name }
                                    });
                                  }}
                                  className="ml-2 p-0.5 hover:bg-emerald-200 rounded-md text-emerald-800 transition-colors"
                                >
                                  <X size={14} />
                                </button>
                              </div>
                            ))}
                            {(category.topics?.length === 0 || !category.topics) && (
                              <span className="text-sm text-slate-400 italic">No topics added yet.</span>
                            )}
                          </div>

                          {/* Add Topic Input Form */}
                          <form
                            onSubmit={async (e) => {
                              e.preventDefault();
                              if (!newTopicName.trim() || selectedCategoryForTopic !== category.id) return;
                              try {
                                const updatedTopics = [...(category.topics || []), newTopicName.trim()];
                                const { doc, updateDoc } = await import('firebase/firestore');
                                await updateDoc(doc(db, 'categories', category.id), { topics: updatedTopics });
                                setCategories(categories.map(c => c.id === category.id ? { ...c, topics: updatedTopics } : c));
                                setNewTopicName('');
                                setSelectedCategoryForTopic(null);
                              } catch (err) {
                                console.error('Error adding topic', err);
                              }
                            }}
                            className="flex gap-2 mt-2 pt-4 border-t border-slate-100"
                          >
                            <input
                              type="text"
                              placeholder="Add new topic (e.g. Thermodynamics)"
                              value={selectedCategoryForTopic === category.id ? newTopicName : ''}
                              onChange={(e) => {
                                setSelectedCategoryForTopic(category.id);
                                setNewTopicName(capitalizeWords(e.target.value));
                              }}
                              className="flex-1 px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500 text-sm"
                            />
                            <button
                              type="submit"
                              disabled={!newTopicName.trim() || selectedCategoryForTopic !== category.id}
                              className="px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-lg text-sm transition-colors disabled:opacity-50"
                            >
                              Add
                            </button>
                          </form>
                        </div>
                      </div>
                    ))}

                  {categories.length === 0 && (
                    <div className="text-center py-10">
                      <Folder size={48} className="mx-auto text-slate-300 mb-4" />
                      <p className="text-slate-500">No subjects created yet.</p>
                    </div>
                  )}
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
      {/* Tournament Review & Declaration Modal */}
      {selectedContestForReview && createPortal(
          <div
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 lg:p-6"
          >
            <div
              className="bg-white rounded-xl w-full max-w-4xl max-h-[85vh] shadow-2xl overflow-hidden flex flex-col border border-slate-100"
            >
              {/* Header - Premium Orange Gradient */}
              <div className="relative p-4 md:p-6 bg-gradient-to-br from-orange-400 to-orange-600 overflow-hidden">
                {/* Decorative background circle */}
                <div className="absolute -top-12 -right-12 w-48 h-48 bg-white/10 rounded-full blur-2xl" />
                <div className="absolute top-4 right-4 w-24 h-24 bg-orange-300/20 rounded-full" />

                <div className="relative flex items-center justify-between z-10">
                  <div className="flex items-center gap-5">
                    <div className="w-12 h-12 md:w-14 md:h-14 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center border border-white/30 shadow-lg text-white">
                      <Trophy size={28} />
                    </div>
                    <div>
                      <h3 className="text-lg md:text-2xl font-black text-white leading-tight">Contest Results</h3>
                      <p className="text-[10px] md:text-[11px] font-bold uppercase tracking-widest text-orange-100 opacity-90">Review & Declare</p>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedContestForReview(null)}
                    className="p-2.5 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all border border-white/20"
                  >
                    <X size={24} />
                  </button>
                </div>
              </div>

              {/* Content */}
              <div className="flex-1 overflow-y-auto no-scrollbar p-4 md:p-8 space-y-6 md:space-y-8 bg-slate-50/50">
                {isDeclaringResults && contestAttempts.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-20">
                    <div className="w-20 h-20 bg-white rounded-2xl shadow-xl flex items-center justify-center mb-6">
                      <Loader2 size={40} className="animate-spin text-orange-500" />
                    </div>
                    <p className="font-extrabold text-slate-400 text-sm uppercase tracking-widest">Compiling Result Data...</p>
                  </div>
                ) : (
                  <>
                    {/* Tournament Identity Card */}
                    <div className="bg-white p-4 md:p-5 rounded-lg border border-slate-100 shadow-sm flex items-center justify-between gap-3">
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 bg-orange-100 text-orange-600 rounded-full flex items-center justify-center">
                          <LayoutDashboard size={20} />
                        </div>
                        <div>
                          <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Active Contest</p>
                          <h4 className="font-black text-slate-900 leading-tight line-clamp-1">{selectedContestForReview.title}</h4>
                        </div>
                      </div>
                      <div className="hidden sm:block text-right">
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Entry Fee</p>
                        <p className="text-sm font-black text-slate-900">{selectedContestForReview.entryFee || 0} Coins</p>
                      </div>
                    </div>

                    {/* Summary Cards Grid */}
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      {[
                        { label: 'Registered', value: selectedContestForReview.totalParticipants || 0, icon: Users, color: 'text-blue-500', bg: 'bg-blue-50' },
                        { label: 'Finished', value: new Set(contestAttempts.map(a => a.userId)).size, icon: CheckCircle2, color: 'text-emerald-500', bg: 'bg-emerald-50' },
                        { label: 'Prize Pool', value: `${Math.floor(((selectedContestForReview.totalParticipants || 0) * (selectedContestForReview.entryFee || 0)) * (1 - (selectedContestForReview.adminCommissionPercentage || 20) / 100))} C`, icon: Coins, color: 'text-orange-500', bg: 'bg-orange-50' },
                        { label: 'Winners', value: selectedContestForReview.winnerCount || 10, icon: Trophy, color: 'text-amber-500', bg: 'bg-amber-50' }
                      ].map((box, i) => (
                        <div key={i} className="bg-white p-3 md:p-4 rounded-lg border border-slate-100 shadow-sm transition-transform hover:scale-[1.02] flex items-center gap-3">
                          <div className={`p-1.5 ${box.bg} ${box.color} rounded-full flex items-center justify-center shrink-0`}>
                            <box.icon size={14} />
                          </div>
                          <div>
                            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-0.5">{box.label}</p>
                            <p className="text-base md:text-xl font-black text-slate-900 leading-none">{box.value}</p>
                          </div>
                        </div>
                      ))}
                    </div>

                    {/* Leaderboard Section */}
                    <div className="space-y-4">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <Trophy size={18} className="text-orange-500" />
                          <h4 className="font-black text-slate-800 text-sm uppercase tracking-tight">Ranking</h4>
                        </div>
                      </div>

                      <div className="bg-white rounded-lg border border-slate-100 overflow-hidden shadow-sm">
                        <div className="max-h-[350px] overflow-y-auto no-scrollbar">
                          <table className="w-full text-left">
                            <thead className="bg-slate-50 border-b border-slate-100 sticky top-0 z-20">
                              <tr>
                                <th className="px-4 md:px-6 py-4 text-[9px] md:text-[10px] font-black text-slate-400 uppercase">Rank</th>
                                <th className="px-4 md:px-6 py-4 text-[9px] md:text-[10px] font-black text-slate-400 uppercase">Participant</th>
                                <th className="px-4 md:px-6 py-4 text-[9px] md:text-[10px] font-black text-slate-400 uppercase text-center">Score</th>
                                <th className="px-4 md:px-6 py-4 text-[9px] md:text-[10px] font-black text-slate-400 uppercase text-right">Prize</th>
                              </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                              {(() => {
                                const bestAttempts = new Map<string, Attempt>();
                                contestAttempts.forEach(att => {
                                  if (!bestAttempts.has(att.userId) || (att.score || 0) > (bestAttempts.get(att.userId)?.score || 0)) {
                                    bestAttempts.set(att.userId, att);
                                  }
                                });

                                const sorted = Array.from(bestAttempts.values()).sort((a, b) => {
                                  if ((b.score || 0) !== (a.score || 0)) return (b.score || 0) - (a.score || 0);
                                  return (a.timeTaken || 0) - (b.timeTaken || 0);
                                });

                                const wCount = selectedContestForReview.winnerCount || 10;
                                const netPool = ((selectedContestForReview.totalParticipants || 0) * (selectedContestForReview.entryFee || 0)) * (1 - (selectedContestForReview.adminCommissionPercentage || 20) / 100);

                                const getPercent = (rank: number, count: number) => {
                                  if (rank === 1) return 0.40;
                                  if (count === 1) return 1.0;
                                  if (rank === 2) return 0.20;
                                  const remaining = 0.40;
                                  const others = Math.max(0, count - 2);
                                  return others > 0 ? remaining / others : 0;
                                };

                                return sorted.slice(0, Math.max(20, wCount)).map((att, idx) => {
                                  const isWinner = idx < wCount;
                                  const prize = isWinner ? Math.floor(netPool * getPercent(idx + 1, wCount)) : 0;
                                  return (
                                    <tr key={idx} className={`group transition-colors ${isWinner ? 'bg-orange-50/10 hover:bg-orange-50/30' : 'hover:bg-slate-50'}`}>
                                      <td className="px-4 md:px-6 py-4 md:py-5">
                                        <div className={`w-8 h-8 rounded-lg flex items-center justify-center font-black text-xs ${idx === 0 ? 'bg-orange-500 text-white shadow-lg shadow-orange-100' :
                                          idx === 1 ? 'bg-slate-800 text-white shadow-lg' :
                                            idx === 2 ? 'bg-slate-400 text-white' :
                                              'text-slate-400'
                                          }`}>
                                          {idx + 1}
                                        </div>
                                      </td>
                                      <td className="px-4 md:px-6 py-4 md:py-5">
                                        <div className="flex items-center gap-3">
                                          <img
                                            src={contestUserMap[att.userId]?.profilePhoto || `https://ui-avatars.com/api/?name=${encodeURIComponent(contestUserMap[att.userId]?.name || att.userId)}&background=f59e0b&color=fff`}
                                            className="w-8 h-8 rounded-full object-cover border border-slate-100 shrink-0"
                                            alt=""
                                          />
                                          <div>
                                            <p className="font-bold text-slate-800 text-[11px] md:text-xs truncate max-w-[80px] md:max-w-[150px]">
                                              {contestUserMap[att.userId]?.name || att.userId}
                                            </p>
                                            <p className="text-[9px] md:text-[10px] text-slate-400 font-bold uppercase tracking-tighter">Time: {att.timeTaken}s</p>
                                          </div>
                                        </div>
                                      </td>
                                      <td className="px-4 md:px-6 py-4 md:py-5 text-center">
                                        <span className={`text-xs md:text-sm font-black ${isWinner ? 'text-orange-600' : 'text-slate-400'}`}>
                                          {att.score?.toFixed(1)} <span className="text-[9px] opacity-60">pts</span>
                                        </span>
                                      </td>
                                      <td className="px-4 md:px-6 py-4 md:py-5 text-right">
                                        {isWinner ? (
                                          <div className="inline-flex items-center gap-1 px-2 md:px-3 py-1 md:py-1.5 bg-orange-50 text-orange-600 rounded-lg md:rounded-xl border border-orange-100 font-black text-[11px] md:text-sm whitespace-nowrap">
                                            <Coins size={12} />
                                            {prize.toLocaleString()}
                                          </div>
                                        ) : (
                                          <span className="text-slate-300 text-[9px] md:text-[10px] font-black uppercase">None</span>
                                        )}
                                      </td>
                                    </tr>
                                  );
                                });
                              })()}
                            </tbody>
                          </table>
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </div>

              <div className="p-4 md:p-8 bg-white border-t border-slate-100 flex flex-col sm:flex-row items-center justify-between gap-5 md:gap-6">
                <div>
                  <p className="text-[10px] text-slate-400 font-black uppercase tracking-[0.2em] mb-1">Status Report</p>
                  <p className="text-xs font-bold text-slate-600">
                    {selectedContestForReview.isResultDeclared ? '✅ Results finalized and distributed.' : '⚠️ Review rankings before declaration.'}
                  </p>
                </div>
                <div className="flex items-stretch gap-4 w-full sm:w-auto">
                  <button
                    onClick={() => setSelectedContestForReview(null)}
                    className="flex-1 sm:flex-none px-8 py-4 bg-slate-100 hover:bg-slate-200 text-slate-600 font-black text-xs rounded-lg transition-all uppercase tracking-widest active:scale-95 flex items-center justify-center"
                  >
                    Cancel
                  </button>
                  {!selectedContestForReview.isResultDeclared && (
                    <button
                      onClick={() => {
                        setDeleteConfirm({
                          type: 'declareResult',
                          id: selectedContestForReview.testId,
                          title: selectedContestForReview.title,
                          metadata: { test: selectedContestForReview }
                        });
                      }}
                      disabled={isDeclaringResults}
                      className="flex-1 sm:flex-none px-10 py-4 bg-gradient-to-r from-orange-500 to-orange-600 text-white font-black text-xs rounded-lg transition-all shadow-xl shadow-orange-100 hover:shadow-orange-200 flex items-center justify-center gap-3 active:scale-95 disabled:opacity-50 uppercase tracking-widest"
                    >
                      {isDeclaringResults && <Loader2 size={16} className="animate-spin" />}
                      Declare Results
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>,
          document.body
        )}

      <AnimatePresence>
        {isQRModalOpen && payQRRequest && (
          <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="bg-white rounded-xl shadow-2xl w-full max-w-sm max-h-[90vh] overflow-y-auto relative no-scrollbar"
            >
              <div className="bg-gradient-to-r from-orange-500 to-amber-500 p-5 flex items-center justify-between sticky top-0 z-20 shadow-sm">
                <div>
                  <h3 className="text-xl font-black text-white leading-none">Instant Pay</h3>
                  <p className="text-[10px] text-white/70 font-black uppercase tracking-widest mt-1">Scan to Payout</p>
                </div>
                <button
                  onClick={() => setIsQRModalOpen(false)}
                  className="p-2 bg-white/10 hover:bg-white/20 text-white rounded-full transition-all backdrop-blur-md"
                >
                  <X size={18} />
                </button>
              </div>

              <div className="p-6 text-center space-y-5">
                <div className="w-52 h-52 bg-white p-5 rounded-xl border-4 border-slate-50 mx-auto flex items-center justify-center shadow-xl shadow-orange-100/50">
                  <QRCodeSVG
                    value={`upi://pay?pa=${payQRRequest.paymentDetails.upiId}&pn=${encodeURIComponent(payQRRequest.paymentDetails.holderName)}&am=${payQRRequest.inRupees}&cu=INR&tn=${encodeURIComponent('Rankearn Payout')}`}
                    size={165}
                    level="H"
                  />
                </div>

                <div className="space-y-1">
                  <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Amount to Pay</p>
                  <p className="text-3xl font-black text-slate-900 leading-none">
                    ₹{payQRRequest.inRupees.toLocaleString()}
                  </p>
                </div>

                <div className="bg-slate-50 p-4 rounded-lg border border-slate-100 text-left space-y-2.5">
                  <div className="flex flex-col">
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">UPI ID (VPA)</span>
                    <span className="text-sm font-bold text-slate-800 break-all leading-tight">{payQRRequest.paymentDetails.upiId}</span>
                  </div>
                  <div className="flex flex-col border-t border-slate-200/50 pt-2">
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest leading-none mb-1">Payee Name</span>
                    <span className="text-sm font-bold text-slate-800 leading-tight">{payQRRequest.paymentDetails.holderName}</span>
                  </div>
                </div>

                <div className="flex flex-col gap-2.5">
                  <button
                    onClick={async () => {
                      setIsQRModalOpen(false);
                      await handleProcessWithdrawal(payQRRequest.id, 'approved');
                    }}
                    className="w-full py-3.5 bg-emerald-500 text-white font-black rounded-lg shadow-lg shadow-emerald-100 hover:bg-emerald-600 transition-all flex items-center justify-center gap-2 uppercase tracking-widest text-[10px]"
                  >
                    <CheckCircle2 size={16} strokeWidth={3} />
                    I've Paid & Approve
                  </button>
                  <button
                    onClick={() => setIsQRModalOpen(false)}
                    className="w-full py-3 bg-slate-100 text-slate-500 font-black rounded-lg text-[10px] uppercase tracking-widest"
                  >
                    Don't Approve yet
                  </button>
                </div>

                <div className="p-3 bg-amber-50 rounded-xl flex items-start gap-2.5 text-left">
                  <AlertCircle size={14} className="text-amber-500 shrink-0 mt-0.5" />
                  <p className="text-[9px] text-amber-800 font-bold leading-relaxed">
                    Scan QR using any UPI app. After payment, click "I've Paid & Approve".
                  </p>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {confirmFinanceAction && (
          <div className="fixed inset-0 z-[110] bg-slate-900/60 backdrop-blur-md flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="bg-white rounded-xl shadow-2xl w-full max-w-sm overflow-hidden border border-slate-100"
            >
              <div className={`p-6 text-center space-y-6 ${confirmFinanceAction.action === 'approved' ? 'bg-gradient-to-b from-emerald-50/50' : 'bg-gradient-to-b from-rose-50/50'}`}>
                <div className={`w-20 h-20 rounded-xl flex items-center justify-center mx-auto shadow-lg ${confirmFinanceAction.action === 'approved' ? 'bg-emerald-500 text-white shadow-emerald-100' : 'bg-rose-500 text-white shadow-rose-100'}`}>
                  {confirmFinanceAction.action === 'approved' ? <CheckCircle2 size={40} strokeWidth={3} /> : <AlertTriangle size={40} strokeWidth={3} />}
                </div>

                <div className="space-y-2">
                  <h3 className="text-xl font-black text-slate-900 uppercase tracking-tight">Confirm Action</h3>
                  <p className="text-xs text-slate-500 font-bold leading-relaxed px-4">
                    Are you sure you want to <span className={confirmFinanceAction.action === 'approved' ? 'text-emerald-600' : 'text-rose-600'}>{confirmFinanceAction.action === 'approved' ? 'Approve' : 'Reject'}</span> this
                    {confirmFinanceAction.type === 'topup' ? ' Top-up ' : ' Withdrawal '} request for
                    <span className="text-slate-900 ml-1 font-black">₹{(confirmFinanceAction.data.amount / 20).toLocaleString()}</span>?
                  </p>
                </div>

                <div className="bg-white p-4 rounded-lg border border-slate-100 text-left space-y-3 shadow-sm relative z-10">
                  <div className="flex justify-between items-center">
                    <span className="text-[10px] font-black text-slate-400 uppercase">User</span>
                    <span className="text-xs font-bold text-slate-700">{confirmFinanceAction.data.userName}</span>
                  </div>
                  <div className="flex justify-between items-center border-t border-slate-50 pt-3">
                    <span className="text-[10px] font-black text-slate-400 uppercase">{confirmFinanceAction.type === 'topup' ? 'UTR' : 'Mode'}</span>
                    <span className="text-xs font-bold text-slate-900 uppercase truncate max-w-[150px]">
                      {confirmFinanceAction.type === 'topup' ? confirmFinanceAction.data.utr : confirmFinanceAction.data.paymentMethod}
                    </span>
                  </div>
                </div>

                <div className="flex flex-col gap-3">
                  <button
                    onClick={async () => {
                      const { requestId, type, action } = confirmFinanceAction;
                      setConfirmFinanceAction(null);
                      if (type === 'topup') {
                        await handleProcessTopup(requestId, action);
                      } else {
                        await handleProcessWithdrawal(requestId, action);
                      }
                    }}
                    className={`w-full py-4 text-white font-black rounded-lg transition-all shadow-lg uppercase tracking-widest text-xs flex items-center justify-center gap-2 ${confirmFinanceAction.action === 'approved' ? 'bg-emerald-500 hover:bg-emerald-600 shadow-emerald-100' : 'bg-rose-500 hover:bg-rose-600 shadow-rose-100'}`}
                  >
                    {confirmFinanceAction.action === 'approved' ? <CheckCircle2 size={16} strokeWidth={3} /> : <X size={16} strokeWidth={3} />}
                    Yes, {confirmFinanceAction.action === 'approved' ? 'Approve' : 'Reject'}
                  </button>
                  <button
                    onClick={() => setConfirmFinanceAction(null)}
                    className="w-full py-4 bg-slate-100 text-slate-500 font-black rounded-lg text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {viewingLeaderboardFor && (
          <LeaderboardModal
            test={viewingLeaderboardFor}
            onClose={() => setViewingLeaderboardFor(null)}
          />
        )}
      </AnimatePresence>

    </div>
  );
}

// Separate component for Leaderboard Modal to keep main component clean
function LeaderboardModal({ test, onClose }: { test: Test, onClose: () => void }) {
  return createPortal(
    <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 lg:p-6">
      <div
        className="bg-white rounded-xl w-full max-w-4xl max-h-[85vh] shadow-2xl overflow-hidden flex flex-col border border-slate-100"
      >
        <div className="p-4 md:p-6 border-b border-slate-100 flex items-center justify-between shrink-0 bg-white sticky top-0 z-10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-amber-500 text-white rounded-xl flex items-center justify-center shadow-lg">
              <Trophy size={20} />
            </div>
            <div>
              <h3 className="text-lg md:text-xl font-black text-slate-900 leading-tight line-clamp-1">{test.title}</h3>
              <p className="text-[10px] font-black uppercase tracking-widest text-slate-400">Live Rankings</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-slate-100 rounded-xl transition-all text-slate-400 hover:text-slate-900"
          >
            <X size={24} />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto no-scrollbar bg-slate-50/30">
          <Leaderboard testId={test.testId} />
        </div>
      </div>
    </div>,
    document.body
  );
}
