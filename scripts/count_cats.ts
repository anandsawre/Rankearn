import { initializeApp } from 'firebase/app';
import { getFirestore, collection, getDocs } from 'firebase/firestore';
import firebaseConfig from '../firebase-applet-config.json';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function countCategories() {
  const snap = await getDocs(collection(db, 'examCategories'));
  console.log(`Total Categories: ${snap.size}`);
  snap.docs.forEach(d => console.log(`- ${d.data().name}`));
}

countCategories();
