import { BattleQuestion } from '../../types';

export const battleQuestionsPool: BattleQuestion[] = [
  { id: '1', text: 'Which is the largest ocean on Earth?', options: ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'], correctAnswer: 3 },
  { id: '2', text: 'What is 15% of 200?', options: ['20', '30', '40', '50'], correctAnswer: 1 },
  { id: '3', text: 'Who wrote the play "Romeo and Juliet"?', options: ['Charles Dickens', 'William Shakespeare', 'Mark Twain', 'Jane Austen'], correctAnswer: 1 },
  { id: '4', text: 'What is the chemical symbol for Gold?', options: ['Go', 'Gd', 'Au', 'Ag'], correctAnswer: 2 },
  { id: '5', text: 'Which planet is known as the Red Planet?', options: ['Venus', 'Mars', 'Jupiter', 'Saturn'], correctAnswer: 1 },
  { id: '6', text: 'If a triangle has angles 90° and 45°, what is the third angle?', options: ['45°', '90°', '60°', '30°'], correctAnswer: 0 },
  { id: '7', text: 'Which element is most abundant in the Earth\'s atmosphere?', options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'], correctAnswer: 2 },
  { id: '8', text: 'What is the square root of 144?', options: ['10', '12', '14', '16'], correctAnswer: 1 },
  { id: '9', text: 'In which year did World War II end?', options: ['1941', '1943', '1945', '1947'], correctAnswer: 2 },
  { id: '10', text: 'What is the capital city of Australia?', options: ['Sydney', 'Melbourne', 'Brisbane', 'Canberra'], correctAnswer: 3 },
  { id: '11', text: 'Who painted the Mona Lisa?', options: ['Vincent van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Claude Monet'], correctAnswer: 2 },
  { id: '12', text: 'What is the hardest natural substance on Earth?', options: ['Gold', 'Iron', 'Diamond', 'Platinum'], correctAnswer: 2 },
  { id: '13', text: 'Which gas do plants absorb from the atmosphere?', options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Helium'], correctAnswer: 1 },
  { id: '14', text: 'Solve: 8 + 2 × 4', options: ['40', '16', '32', '14'], correctAnswer: 1 },
  { id: '15', text: 'Which continent is the Sahara Desert located on?', options: ['Asia', 'South America', 'Africa', 'Australia'], correctAnswer: 2 },
  { id: '16', text: 'How many bones are in the adult human body?', options: ['206', '208', '210', '212'], correctAnswer: 0 },
  { id: '17', text: 'What is the largest mammal in the world?', options: ['Elephant', 'Blue Whale', 'Giraffe', 'Polar Bear'], correctAnswer: 1 },
  { id: '18', text: 'Which programming language is known as the mother of all languages?', options: ['C', 'Java', 'Python', 'Assembly'], correctAnswer: 0 },
  { id: '19', text: 'What is the speed of light?', options: ['300,000 km/s', '150,000 km/s', '400,000 km/s', '100,000 km/s'], correctAnswer: 0 },
  { id: '20', text: 'Who is known as the father of computers?', options: ['Alan Turing', 'Charles Babbage', 'Bill Gates', 'Steve Jobs'], correctAnswer: 1 },
  { id: '21', text: 'What is 7 cubed (7³)?', options: ['21', '49', '343', '240'], correctAnswer: 2 },
  { id: '22', text: 'Which animal is known as the Ship of the Desert?', options: ['Horse', 'Camel', 'Elephant', 'Donkey'], correctAnswer: 1 },
  { id: '23', text: 'What is the boiling point of water at sea level?', options: ['90°C', '100°C', '110°C', '120°C'], correctAnswer: 1 },
  { id: '24', text: 'Who discovered Penicillin?', options: ['Marie Curie', 'Alexander Fleming', 'Louis Pasteur', 'Isaac Newton'], correctAnswer: 1 },
  { id: '25', text: 'What is the smallest prime number?', options: ['0', '1', '2', '3'], correctAnswer: 2 },
];

export const getRandomBattleQuestions = (count: number = 5): BattleQuestion[] => {
  const shuffled = [...battleQuestionsPool].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
};
