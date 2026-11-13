export interface ExamPattern {
  id: string;
  examName: string;
  category: string;
  sections: {
    subject: string;
    questionCount: number;
    topics: string[];
  }[];
  totalDuration: number;
  negativeMarking: number;
  createdAt: string;
}

export interface UserProfile {
  userId: string;
  name: string;
  email: string;
  phone?: string;
  profilePhoto?: string;
  examPreparingFor?: string;
  state?: string;
  coins: number;
  totalEarned?: number;
  totalSpent?: number;
  withdrawableBalance?: number;
  badges: string[];
  subscriptionStatus: 'free' | 'premium';
  subscriptionEndDate?: string; // ISO string representing expiry
  createdAt: string;
  role?: 'user' | 'admin';
  isLeaderboardEligible?: boolean;
  fcmTokens?: string[];
  notificationLastClearedAt?: any; // Firestore Timestamp
  lastSpinDate?: any; // Firestore Timestamp
  savedPaymentDetails?: {
    upiId?: string;
    holderName?: string;
    accountNumber?: string;
    ifsc?: string;
    lastMethod?: 'upi' | 'bank';
  };
  referredBy?: string; // userId of the referrer
  referralCode?: string;
  readNotifications?: string[]; // notification IDs read by the user (for global/system alerts)
  referralStats?: {
    totalReferrals: number;
    totalEarnings: number;
    pendingEarnings: number;
  };
  status?: 'active' | 'suspended' | 'banned';
  banReason?: string;
  banUntil?: any; // Firestore Timestamp or ISO string
  violationCount?: number;
  seenBattleQuestionIds?: string[];
}

export interface BattleQuestion {
  id: string;
  text: string;
  textHindi?: string;
  options: string[];
  optionsHindi?: string[];
  correctAnswer: number;
  topic?: string;
  difficulty?: string;
}

export interface AppNotification {
  id: string;
  userId: string; // recipient uid or 'global'
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'transaction' | 'tournament' | 'contest' | 'announcement';
  actionUrl?: string;
  link?: string;
  imageUrl?: string;
  read: boolean;
  readBy?: string[]; // for global notifications
  targetSegment?: 'all' | 'pro' | 'free' | 'user';
  scheduledAt?: string; // ISO string
  clicks?: number;
  pushSent?: boolean;
  createdAt: any; // Firestore timestamp
}

export interface Poll {
  id: string;
  question: string;
  options: string[];
  votes: Record<number, number>; // optionIndex -> count
  voters: string[]; // userIds who voted
  targetSegment: 'all' | 'pro' | 'free';
  isActive: boolean;
  createdAt: any;
  expiresAt?: string;
}

export interface Test {
  testId: string;
  title: string;
  title_lowercase?: string;
  category: string;
  examCategory?: string;
  testMode?: 'mock' | 'sectional' | 'previous-year' | 'tournament';
  subject?: string;
  topic?: string;
  examType: string;
  duration: number;
  totalQuestions: number;
  negativeMarking: number;
  createdBy: string;
  createdAt: string;
  isPremium: boolean;
  status?: 'published' | 'unpublished';
  isTournament?: boolean;
  isProOnly?: boolean;
  entryFee?: number;
  adminCommissionPercentage?: number;
  prizeDistribution?: number[];
  scheduledStartTime?: string;
  scheduledEndTime?: string;
  totalParticipants?: number;
  isResultDeclared?: boolean;
  leaderboardLimit?: number; // How many entries to show on public leaderboard
  winnerCount?: number;      // How many top participants get the prize
  attemptCount?: number;     // Total number of times this test has been attempted
  averageScore?: number;     // Average score across all attempts
  unlockPrice?: number;      // Price in coins to permanently unlock this premium test
  syllabus?: string;         // Optional syllabus text for the test
}

export interface ContestParticipant {
  userId: string;
  feePaid: number;
  joinedAt: string;
}

export interface Category {
  id: string;
  name: string; // Acts as the Subject Name
  topics?: string[]; // Nested categories/chapters
  createdAt: string;
  parentExamId?: string; // Links to ExamCategory
  parentExamName?: string; // Denormalized name for easier display
}

export interface ExamCategory {
  id: string;
  name: string; // e.g. BPSC, SSC, UPSC
  normalizedName?: string;
  createdAt: string;
  isPublished?: boolean;
  usersCountOverride?: number;
  languages?: string;
  iconUrl?: string;
}

export interface Question {
  questionId: string;
  testId: string;
  questionTextHindi?: string;
  questionTextEnglish: string;
  options: { 
    textEnglish: string; 
    textHindi?: string; 
    image?: string 
  }[];
  correctAnswer: number;
  explanation?: string;
  explanationHindi?: string;
  difficultyLevel: 'easy' | 'medium' | 'hard';
  subject: string;
  topic: string;
  imageURL?: string;
}

export interface Attempt {
  attemptId: string;
  userId: string;
  testId: string;
  answers: Record<string, number>; // questionId -> selectedOptionIndex
  startTime: string;
  endTime?: string;
  score?: number;
  accuracy?: number;
  rank?: number;
  timeTaken?: number;
  isCoinsAwarded?: boolean;
  coinsEarned?: number;      // coins won in a tournament (set when admin declares results)
  tournamentRank?: number;   // final rank in the tournament
  isTournament?: boolean;    // flag to identify if the attempt was part of a tournament
  status?: string;           // 'declared', 'pending', etc.
}

export interface LeaderboardEntry {
  userId: string;
  userName: string;
  profilePhoto?: string;
  score: number;
  rank: number;
  state?: string;
  type: 'daily' | 'weekly' | 'monthly' | 'test-wise';
  testId?: string;
  timeTaken?: number;
  coinsEarned?: number;
  isPro?: boolean;
}

export interface AppBanner {
  id: string;
  imageUrl?: string;
  title?: string;
  link?: string; // e.g., '/tests' or 'https://google.com'
  isActive: boolean;
  priority: number;
  scheduledAt?: string; // ISO string
  clicks?: number;
  createdAt: string;
  type?: 'image' | 'spotlight';
  spotlightData?: {
    userId: string;
    userName: string;
    profilePhoto?: string;
    score?: string | number;
    rank?: string | number;
    examName?: string;
    message?: string;
  };
}

export interface WheelSlice {
  label: string;
  value: number;
  type: 'coins' | 'bonus' | 'nothing';
  color: string;
  probability: number; // 0 to 100
}

export interface LuckyWheelConfig {
  slices: WheelSlice[];
  isActive: boolean;
  spinCost: number;
  lastUpdated?: any;
}

export const DEFAULT_SLICES: WheelSlice[] = [
  { label: '5 Coins', value: 5, type: 'coins', color: '#10b981', probability: 30 },
  { label: '10 Coins', value: 10, type: 'coins', color: '#3b82f6', probability: 25 },
  { label: '25 Coins', value: 25, type: 'coins', color: '#6366f1', probability: 15 },
  { label: 'Try Again', value: 0, type: 'nothing', color: '#64748b', probability: 10 },
  { label: '50 Coins', value: 50, type: 'coins', color: '#f59e0b', probability: 10 },
  { label: '5 Coins', value: 5, type: 'coins', color: '#10b981', probability: 5 },
  { label: '100 Coins', value: 100, type: 'coins', color: '#f43f5e', probability: 3 },
  { label: '10 Coins', value: 10, type: 'coins', color: '#3b82f6', probability: 2 },
];

export interface ReferralSystemConfig {
  isActive: boolean;
  referrerReward: number; // in coins
  refereeReward: number;  // in coins
  commissionRate: number; // percentage of contest winnings
  minWithdrawal: number;
  updatedAt: string;
}

export interface Post {
  id: string;
  slug: string;
  title: string;
  content: string;
  excerpt: string;
  imageUrl?: string;
  category?: string;
  createdAt: any; // Firestore Timestamp or ISO string
  authorName: string;
  isActive: boolean;
  metaTitle?: string;
  metaDescription?: string;
}

export interface SupportMessage {
  id: string;
  senderId: string;
  senderName: string;
  text: string;
  timestamp: any;
  role: 'user' | 'admin';
}

export interface SupportTicket {
  id: string; // usually the userId for one-on-one support
  userId: string;
  userName: string;
  userEmail: string;
  lastMessage: string;
  lastUpdated: any;
  status: 'open' | 'closed';
  unreadCount: number;
  userPhoto?: string;
}

export interface Feedback {
  id: string;
  userId: string;
  userName: string;
  rating: number;
  comment: string;
  timestamp: any;
}
