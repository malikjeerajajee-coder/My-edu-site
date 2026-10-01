// Subject-specific exam patterns and marking schemes
export const EXAM_PATTERNS: Record<string, any> = {
  'biology': {
    totalMarks: 75,
    theoryMarks: 60,
    practicalMarks: 15,
    duration: '3 hours',
    sections: [
      { name: 'Objective', marks: 12, questions: 12 },
      { name: 'Short Questions', marks: 33, questions: 11 },
      { name: 'Long Questions', marks: 15, questions: 3 },
    ],
    chapterWeightage: [
      { chapter: 'Cell Biology', marks: 12, priority: 'high' },
      { chapter: 'Genetics', marks: 10, priority: 'high' },
      { chapter: 'Ecology', marks: 8, priority: 'medium' },
      { chapter: 'Human Physiology', marks: 15, priority: 'high' },
      { chapter: 'Plant Physiology', marks: 8, priority: 'medium' },
    ],
    studyTips: [
      'Focus on diagrams — Biology papers award marks for labeled diagrams',
      'Memorize scientific names — they often appear in objective sections',
      'Practice drawing and labeling at least 20 common diagrams',
      'Long questions usually come from Human Physiology and Genetics',
    ],
    commonMistakes: [
      'Not labeling diagrams properly',
      'Confusing mitosis and meiosis stages',
      'Skipping practical-based questions',
    ],
  },
  'physics': {
    totalMarks: 100,
    theoryMarks: 85,
    practicalMarks: 15,
    duration: '3 hours',
    sections: [
      { name: 'MCQs', marks: 17, questions: 17 },
      { name: 'Short Questions', marks: 36, questions: 12 },
      { name: 'Long Questions', marks: 32, questions: 4 },
    ],
    chapterWeightage: [
      { chapter: 'Mechanics', marks: 20, priority: 'high' },
      { chapter: 'Waves & Oscillations', marks: 12, priority: 'medium' },
      { chapter: 'Thermodynamics', marks: 15, priority: 'high' },
      { chapter: 'Electromagnetism', marks: 18, priority: 'high' },
      { chapter: 'Modern Physics', marks: 10, priority: 'medium' },
    ],
    studyTips: [
      'Master numerical problems — they carry 60% of marks',
      'Memorize all formulas with units',
      'Practice dimensional analysis for verification',
      'Draw circuit diagrams clearly in electromagnetism questions',
    ],
    commonMistakes: [
      'Forgetting to write units in answers',
      'Skipping working steps in numericals',
      'Not converting units before calculations',
    ],
  },
  'chemistry': {
    totalMarks: 85,
    theoryMarks: 70,
    practicalMarks: 15,
    duration: '3 hours',
    sections: [
      { name: 'MCQs', marks: 14, questions: 14 },
      { name: 'Short Questions', marks: 35, questions: 14 },
      { name: 'Long Questions', marks: 21, questions: 3 },
    ],
    chapterWeightage: [
      { chapter: 'Physical Chemistry', marks: 25, priority: 'high' },
      { chapter: 'Inorganic Chemistry', marks: 20, priority: 'high' },
      { chapter: 'Organic Chemistry', marks: 25, priority: 'high' },
    ],
    studyTips: [
      'Balance chemical equations — always check atom counts',
      'Memorize IUPAC nomenclature for organic compounds',
      'Practice numerical problems in Physical Chemistry',
      'Learn periodic table trends (electronegativity, atomic size)',
    ],
    commonMistakes: [
      'Incorrect chemical formulas',
      'Unbalanced equations',
      'Confusing structural isomers',
    ],
  },
  'mathematics': {
    totalMarks: 75,
    theoryMarks: 75,
    practicalMarks: 0,
    duration: '3 hours',
    sections: [
      { name: 'MCQs', marks: 15, questions: 15 },
      { name: 'Short Questions', marks: 30, questions: 10 },
      { name: 'Long Questions', marks: 30, questions: 4 },
    ],
    chapterWeightage: [
      { chapter: 'Algebra', marks: 20, priority: 'high' },
      { chapter: 'Calculus', marks: 25, priority: 'high' },
      { chapter: 'Geometry', marks: 15, priority: 'medium' },
      { chapter: 'Trigonometry', marks: 15, priority: 'high' },
    ],
    studyTips: [
      'Practice daily — Math requires muscle memory',
      'Show all working steps — method marks matter',
      'Master integration and differentiation techniques',
      'Learn to solve problems using multiple methods',
    ],
    commonMistakes: [
      'Sign errors in calculations',
      'Skipping steps in solutions',
      'Not checking final answers',
    ],
  },
  'english': {
    totalMarks: 100,
    theoryMarks: 100,
    practicalMarks: 0,
    duration: '3 hours',
    sections: [
      { name: 'Reading Comprehension', marks: 20, questions: 2 },
      { name: 'Writing Skills', marks: 30, questions: 3 },
      { name: 'Grammar', marks: 20, questions: 20 },
      { name: 'Literature', marks: 30, questions: 4 },
    ],
    chapterWeightage: [
      { chapter: 'Prose', marks: 15, priority: 'high' },
      { chapter: 'Poetry', marks: 15, priority: 'high' },
      { chapter: 'Grammar', marks: 20, priority: 'high' },
      { chapter: 'Writing', marks: 30, priority: 'high' },
    ],
    studyTips: [
      'Read comprehension passages twice before answering',
      'Practice essay and letter writing weekly',
      'Memorize grammar rules with examples',
      'Learn quotes from prescribed texts for literature answers',
    ],
    commonMistakes: [
      'Grammar errors in writing sections',
      'Not addressing all parts of essay questions',
      'Poor time management in comprehension',
    ],
  },
};

export function getExamPattern(subject: string): any {
  const key = subject.toLowerCase().replace(/[^a-z]/g, '');
  return EXAM_PATTERNS[key] || EXAM_PATTERNS['english'];
}

export function generateStudyGuide(subject: string, board: string, classNum: string): string {
  const pattern = getExamPattern(subject);
  const tips = pattern.studyTips || [];
  const mistakes = pattern.commonMistakes || [];
  
  return `
## How to Use These Past Papers

### Exam Pattern Overview
- **Total Marks:** ${pattern.totalMarks}
- **Duration:** ${pattern.duration}
- **Theory:** ${pattern.theoryMarks} marks
- **Practical:** ${pattern.practicalMarks} marks

### What to Focus On
${tips.map((tip: string) => `- ${tip}`).join('\n')}

### Common Mistakes to Avoid
${mistakes.map((m: string) => `- ${m}`).join('\n')}

### Board-Specific Tips (${board} Board)
- Check the ${board} Board's official syllabus for any recent changes
- Practice at least 5 years of past papers before your exam
- Time yourself strictly — ${pattern.duration} for the full paper
- Review marking schemes to understand what examiners look for
  `.trim();
}
