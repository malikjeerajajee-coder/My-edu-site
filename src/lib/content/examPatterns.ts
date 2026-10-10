export interface ExamPattern {
  totalMarks: number;
  theoryMarks: number;
  practicalMarks: number;
  duration: string;
  sections: { name: string; marks: number; questions: number }[];
  chapterWeightage: { chapter: string; marks: number; priority: string }[];
  studyTips: string[];
  commonMistakes: string[];
}

const norm = (s: string) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

function bandDefault(subject: string, band: string): ExamPattern {
  if (band === 'hssc') {
    return {
      totalMarks: 100, theoryMarks: 100, practicalMarks: 0, duration: '3 hours',
      sections: [
        { name: 'MCQs', marks: 20, questions: 20 },
        { name: 'Short questions', marks: 40, questions: 8 },
        { name: 'Long questions', marks: 40, questions: 4 },
      ],
      chapterWeightage: [
        { chapter: 'Most-repeated chapters (last 5 years)', marks: 50, priority: 'high' },
        { chapter: 'Remaining syllabus', marks: 50, priority: 'medium' },
      ],
      studyTips: [
        `Practise every ${subject} paper your own board published in the last 5 years`,
        'Inter papers reward precise answers — match answer length to marks',
        'Solve one full paper in exactly 3 hours before exam day',
      ],
      commonMistakes: ['Attempting long questions first and running out of time', 'Ignoring the MCQ section, which is 20 free marks'],
    };
  }
  if (band === 'primary') {
    return {
      totalMarks: 100, theoryMarks: 100, practicalMarks: 0, duration: '2 hours 30 minutes',
      sections: [
        { name: 'Objective', marks: 20, questions: 20 },
        { name: 'Subjective', marks: 80, questions: 8 },
      ],
      chapterWeightage: [
        { chapter: 'Most-repeated chapters', marks: 50, priority: 'high' },
        { chapter: 'Remaining syllabus', marks: 50, priority: 'medium' },
      ],
      studyTips: [`Revise the full ${subject} textbook twice before the exam`, 'Practise handwriting speed — time is tight in primary papers'],
      commonMistakes: ['Leaving objective questions unanswered', 'Spelling errors in short answers'],
    };
  }
  return {
    totalMarks: 60, theoryMarks: 60, practicalMarks: 0, duration: '2 hours 10 minutes',
    sections: [
      { name: 'Objective (MCQs)', marks: 12, questions: 12 },
      { name: 'Short questions', marks: 33, questions: 11 },
      { name: 'Long questions', marks: 15, questions: 3 },
    ],
    chapterWeightage: [
      { chapter: 'Most-repeated chapters (last 5 years)', marks: 36, priority: 'high' },
      { chapter: 'Remaining syllabus', marks: 24, priority: 'medium' },
    ],
    studyTips: [
      `Practise all ${subject} past papers from your own board first`,
      'Memorise the paper pattern above before exam day',
      'One minute per mark is a safe pace — stick to it',
    ],
    commonMistakes: ['Skipping objective-section revision', 'Writing answers longer than the marks require'],
  };
}

const OVERRIDES: Record<string, Partial<ExamPattern> & { chapterWeightage?: any[] }> = {
  biology: {
    totalMarks: 60, practicalMarks: 0, duration: '2 hours 10 minutes',
    chapterWeightage: [
      { chapter: 'Cell Biology & Genetics', marks: 18, priority: 'high' },
      { chapter: 'Human & Plant Physiology', marks: 20, priority: 'high' },
      { chapter: 'Ecology & Diversity', marks: 10, priority: 'medium' },
    ],
    studyTips: ['Focus on diagrams — labelled diagrams carry dedicated marks', 'Memorise scientific names for the objective section', 'Long questions usually come from Physiology and Genetics'],
    commonMistakes: ['Unlabelled diagrams', 'Confusing mitosis and meiosis stages'],
  },
  physics: {
    totalMarks: 60, duration: '2 hours 10 minutes',
    chapterWeightage: [
      { chapter: 'Mechanics & Waves', marks: 20, priority: 'high' },
      { chapter: 'Thermodynamics & Electromagnetism', marks: 25, priority: 'high' },
      { chapter: 'Modern Physics', marks: 10, priority: 'medium' },
    ],
    studyTips: ['Numericals carry most marks — practise daily', 'Memorise formulas with units', 'Show every step; method marks are real'],
    commonMistakes: ['Missing units', 'Unit conversion errors'],
  },
  chemistry: {
    totalMarks: 60, duration: '2 hours 10 minutes',
    chapterWeightage: [
      { chapter: 'Physical Chemistry', marks: 20, priority: 'high' },
      { chapter: 'Inorganic Chemistry', marks: 18, priority: 'high' },
      { chapter: 'Organic Chemistry', marks: 22, priority: 'high' },
    ],
    studyTips: ['Always balance equations before answering', 'Learn IUPAC naming rules', 'Practise Physical Chemistry numericals'],
    commonMistakes: ['Unbalanced equations', 'Wrong chemical formulas'],
  },
  mathematics: {
    totalMarks: 75, duration: '2 hours 40 minutes',
    chapterWeightage: [
      { chapter: 'Algebra & Trigonometry', marks: 30, priority: 'high' },
      { chapter: 'Geometry & Mensuration', marks: 20, priority: 'medium' },
      { chapter: 'Statistics & Probability', marks: 15, priority: 'medium' },
    ],
    studyTips: ['Show all working — method marks matter', 'Practise under timed conditions daily'],
    commonMistakes: ['Sign errors', 'Skipping steps'],
  },
  english: {
    totalMarks: 75, duration: '2 hours 40 minutes',
    chapterWeightage: [
      { chapter: 'Grammar & Composition', marks: 25, priority: 'high' },
      { chapter: 'Prose & Poetry', marks: 25, priority: 'high' },
      { chapter: 'Writing (essay/letter)', marks: 25, priority: 'high' },
    ],
    studyTips: ['Read comprehension twice before answering', 'Practise one essay and one letter weekly'],
    commonMistakes: ['Grammar slips in writing sections', 'Ignoring part (b) of questions'],
  },
  urdu: {
    totalMarks: 75, duration: '2 hours 40 minutes',
    chapterWeightage: [
      { chapter: 'Qawaid (grammar)', marks: 25, priority: 'high' },
      { chapter: 'Prose & Poetry', marks: 30, priority: 'high' },
      { chapter: 'Composition', marks: 20, priority: 'medium' },
    ],
    studyTips: ['Memorise verses with references', 'Practise idioms and translations daily'],
    commonMistakes: ['Spelling mistakes in Urdu script', 'Skipping grammar section'],
  },
  islamiat: {
    totalMarks: 50, duration: '2 hours',
    chapterWeightage: [
      { chapter: 'Quranic verses & translation', marks: 15, priority: 'high' },
      { chapter: 'Seerat & history', marks: 20, priority: 'high' },
      { chapter: 'Practices of Islam', marks: 15, priority: 'medium' },
    ],
    studyTips: ['Learn Arabic text with exact translation', 'Quote references where possible'],
    commonMistakes: ['Wrong verse references', 'Vague answers on practices'],
  },
  'pakistan-studies': {
    totalMarks: 50, duration: '2 hours',
    chapterWeightage: [
      { chapter: 'Ideology & movement', marks: 20, priority: 'high' },
      { chapter: 'Constitutional history', marks: 15, priority: 'high' },
      { chapter: 'Post-1947 issues', marks: 15, priority: 'medium' },
    ],
    studyTips: ['Memorise dates and resolutions in order', 'Answer in points, not paragraphs'],
    commonMistakes: ['Mixing up dates of resolutions', 'Ignoring map-based questions'],
  },
  'computer-science': {
    totalMarks: 60, duration: '2 hours 10 minutes',
    chapterWeightage: [
      { chapter: 'Fundamentals & number systems', marks: 20, priority: 'high' },
      { chapter: 'Programming basics', marks: 20, priority: 'high' },
      { chapter: 'Hardware & software', marks: 15, priority: 'medium' },
    ],
    studyTips: ['Practise number-system conversions by hand', 'Memorise syntax for your prescribed language'],
    commonMistakes: ['Binary-hex conversion slips', 'Undefined terms in short answers'],
  },
};

export function getExamPattern(subject: string, cls?: string): ExamPattern {
  const n = Number(cls || 0);
  const band = n === 11 || n === 12 ? 'hssc' : n >= 1 && n <= 8 ? 'primary' : 'ssc';
  const base = bandDefault(subject, band);
  const o = OVERRIDES[norm(subject)];
  if (!o) return base;
  return {
    ...base,
    ...o,
    sections: o.sections || base.sections,
    chapterWeightage: o.chapterWeightage || base.chapterWeightage,
    studyTips: o.studyTips || base.studyTips,
    commonMistakes: o.commonMistakes || base.commonMistakes,
  };
}
