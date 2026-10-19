import { db } from './firebase';
import { collection, getDocs, addDoc, query, limit } from 'firebase/firestore';

export async function seedData() {
  const testsSnap = await getDocs(query(collection(db, 'tests'), limit(1)));
  if (!testsSnap.empty) return;

  console.log('Seeding initial data...');

  const sampleTests = [
    {
      title: 'SSC CGL Tier 1 - Full Mock 01',
      category: 'SSC',
      examType: 'Mock Test',
      duration: 60,
      totalQuestions: 100,
      negativeMarking: 0.25,
      isPremium: false,
      createdAt: new Date().toISOString(),
      createdBy: 'admin'
    },
    {
      title: 'IBPS PO Prelims - Quant Special',
      category: 'Banking',
      examType: 'Sectional Test',
      duration: 20,
      totalQuestions: 35,
      negativeMarking: 0.25,
      isPremium: true,
      createdAt: new Date().toISOString(),
      createdBy: 'admin'
    }
  ];

  for (const testData of sampleTests) {
    const testRef = await addDoc(collection(db, 'tests'), testData);
    
    if (testData.title.includes('SSC CGL')) {
      const questions = [
        // General Intelligence
        {
          questionTextEnglish: 'Find the odd one out from the given options.',
          questionTextHindi: 'दिए गए विकल्पों में से विषम को चुनें।',
          options: [
            { textEnglish: 'Apple', textHindi: 'सेब' },
            { textEnglish: 'Banana', textHindi: 'केला' },
            { textEnglish: 'Potato', textHindi: 'आलू' },
            { textEnglish: 'Grape', textHindi: 'अंगूर' }
          ],
          correctAnswer: 2,
          explanation: 'Potato is a vegetable, others are fruits.',
          explanationHindi: 'आलू एक सब्जी है, अन्य फल हैं।',
          difficultyLevel: 'easy',
          subject: 'General Intelligence',
          topic: 'Classification'
        },
        // General Awareness
        {
          questionTextEnglish: 'Which of the following is the capital of France?',
          questionTextHindi: 'निम्नलिखित में से कौन फ्रांस की राजधानी है?',
          options: [
            { textEnglish: 'Berlin', textHindi: 'बर्लिन' },
            { textEnglish: 'Madrid', textHindi: 'मैड्रिड' },
            { textEnglish: 'Paris', textHindi: 'पेरिस' },
            { textEnglish: 'Rome', textHindi: 'रोम' }
          ],
          correctAnswer: 2,
          explanation: 'Paris is the capital of France.',
          explanationHindi: 'पेरिस फ्रांस की राजधानी है।',
          difficultyLevel: 'easy',
          subject: 'General Awareness',
          topic: 'Geography'
        },
        // Quantitative Aptitude
        {
          questionTextEnglish: 'If 20% of a number is 120, then what is 120% of that number?',
          questionTextHindi: 'यदि किसी संख्या का 20%, 120 है, तो उस संख्या का 120% क्या होगा?',
          options: [
            { textEnglish: '480', textHindi: '480' },
            { textEnglish: '720', textHindi: '720' },
            { textEnglish: '600', textHindi: '600' },
            { textEnglish: '360', textHindi: '360' }
          ],
          correctAnswer: 1,
          explanation: '20% = 120 => 100% = 600 => 120% = 720.',
          explanationHindi: '20% = 120 => 100% = 600 => 120% = 720.',
          difficultyLevel: 'medium',
          subject: 'Quantitative Aptitude',
          topic: 'Percentage'
        },
        // English Comprehension
        {
          questionTextEnglish: 'Select the most appropriate synonym of the given word: "ABANDON"',
          questionTextHindi: 'दिए गए शब्द का सबसे उपयुक्त पर्यायवाची चुनें: "ABANDON"',
          options: [
            { textEnglish: 'Keep', textHindi: 'रखना' },
            { textEnglish: 'Discard', textHindi: 'त्यागना' },
            { textEnglish: 'Support', textHindi: 'समर्थन' },
            { textEnglish: 'Adopt', textHindi: 'अपनाना' }
          ],
          correctAnswer: 1,
          explanation: 'Abandon means to leave or discard something.',
          explanationHindi: 'Abandon का अर्थ है किसी चीज़ को छोड़ना या त्यागना।',
          difficultyLevel: 'easy',
          subject: 'English Comprehension',
          topic: 'Synonyms'
        },
        // More General Awareness
        {
          questionTextEnglish: 'Who was the first Prime Minister of India?',
          questionTextHindi: 'भारत के पहले प्रधानमंत्री कौन थे?',
          options: [
            { textEnglish: 'Mahatma Gandhi', textHindi: 'महात्मा गांधी' },
            { textEnglish: 'Jawaharlal Nehru', textHindi: 'जवाहरलाल नेहरू' },
            { textEnglish: 'Sardar Patel', textHindi: 'सरदार पटेल' },
            { textEnglish: 'B.R. Ambedkar', textHindi: 'बी.आर. अंबेडकर' }
          ],
          correctAnswer: 1,
          explanation: 'Jawaharlal Nehru was the first PM of India.',
          explanationHindi: 'जवाहरलाल नेहरू भारत के पहले प्रधानमंत्री थे।',
          difficultyLevel: 'easy',
          subject: 'General Awareness',
          topic: 'History'
        }
      ];

      for (const q of questions) {
        await addDoc(collection(db, 'tests', testRef.id, 'questions'), q);
      }
    }
  }

  console.log('Seeding complete!');
}
