import { GoogleGenAI, Type } from "@google/genai";
import { Attempt, Question } from "../types";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY || '' });

export async function analyzePerformance(attempt: Attempt, questions: Question[]) {
  const model = "gemini-3-flash-preview";
  
  const prompt = `
    Analyze the following exam attempt data and provide performance insights.
    
    Test ID: ${attempt.testId}
    Score: ${attempt.score}
    Accuracy: ${attempt.accuracy}%
    Time Taken: ${attempt.timeTaken} seconds
    
    Questions and Answers:
    ${questions.map((q, i) => `
      Q${i+1}: ${q.questionTextEnglish}
      Topic: ${q.topic}
      Subject: ${q.subject}
      Correct: ${attempt.answers?.[q.questionId] === q.correctAnswer ? 'Yes' : 'No'}
    `).join('\n')}
    
    Provide a JSON response with:
    1. weakTopics: Array of topics where the user struggled.
    2. strongTopics: Array of topics where the user performed well.
    3. recommendations: A string with personalized study advice.
  `;

  try {
    const response = await ai.models.generateContent({
      model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            weakTopics: { type: Type.ARRAY, items: { type: Type.STRING } },
            strongTopics: { type: Type.ARRAY, items: { type: Type.STRING } },
            recommendations: { type: Type.STRING }
          },
          required: ["weakTopics", "strongTopics", "recommendations"]
        }
      }
    });

    return JSON.parse(response.text || '{}');
  } catch (error) {
    console.error('AI Analysis failed', error);
    return {
      weakTopics: [],
      strongTopics: [],
      recommendations: "Keep practicing to get better insights."
    };
  }
}
