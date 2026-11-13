import { Attempt, Question } from '../types';

export interface AttemptMetrics {
  score: number;
  accuracy: number;
  correct: number;
  wrong: number;
  skipped: number;
}

export function calculateAttemptMetrics(
  attempt: Partial<Attempt>,
  questions: Question[],
  negativeMarking = 0
): AttemptMetrics {
  let correct = 0;
  let wrong = 0;

  questions.forEach((question) => {
    const selectedOption = attempt.answers?.[question.questionId];

    if (selectedOption === undefined) {
      return;
    }

    if (selectedOption === question.correctAnswer) {
      correct += 1;
    } else {
      wrong += 1;
    }
  });

  const skipped = questions.length - (correct + wrong);

  return {
    score: correct - wrong * negativeMarking,
    accuracy: correct + wrong > 0 ? (correct / (correct + wrong)) * 100 : 0,
    correct,
    wrong,
    skipped
  };
}

export function formatTimeTaken(timeTaken = 0) {
  const safeTime = Math.max(0, Math.floor(timeTaken));
  const minutes = Math.floor(safeTime / 60);
  const seconds = safeTime % 60;

  return `${minutes}m ${seconds}s`;
}
