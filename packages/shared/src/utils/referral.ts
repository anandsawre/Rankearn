import { collection, query, where, getDocs, limit, Firestore } from 'firebase/firestore';

const generateCode = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < 8; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

export const generateUniqueReferralCode = async (db: Firestore): Promise<string> => {
  const usersRef = collection(db, 'users');
  let code = '';
  let isUnique = false;
  let attempts = 0;

  while (!isUnique && attempts < 5) {
    code = generateCode();
    const q = query(usersRef, where('referralCode', '==', code), limit(1));
    const querySnapshot = await getDocs(q);
    
    if (querySnapshot.empty) {
      isUnique = true;
    } else {
      attempts++;
    }
  }

  if (!isUnique) {
    code = generateCode().substring(0, 4) + Date.now().toString(36).toUpperCase().slice(-4);
  }

  return code;
};
