export interface BoardInfo {
  slug: string;
  overview: string;
  boardsServed: string[];
  totalMarks: number;
  passingMarks: number;
  examMonths: string;
  groups: { name: string; subjects: string[] }[];
  subjects: { name: string; marks: number; type: 'compulsory' | 'elective' }[];
  paperPatterns: { subject: string; totalMarks: number; objective: string; subjective: string; duration: string }[];
  faq: { q: string; a: string }[];
}

export const BOARD_INFO: Record<string, BoardInfo> = {
  punjab: {
    slug: 'punjab',
    overview: 'The Punjab Boards of Intermediate and Secondary Education (BISEs) conduct the SSC Part-I (Class 9) examinations for students across the province. Nine boards operate under the Punjab Boards Committee of Chairpersons (PBCC), which ensures a unified paper pattern, syllabus, and marking scheme across all boards — so a Lahore board student and a Multan board student sit the same paper on the same day.',
    boardsServed: [
      'BISE Lahore', 'BISE Gujranwala', 'BISE Rawalpindi', 'BISE Multan',
      'BISE Faisalabad', 'BISE Sahiwal', 'BISE Sargodha', 'BISE Bahawalpur',
      'BISE DG Khan',
    ],
    totalMarks: 550,
    passingMarks: 182,
    examMonths: 'March to May (annual), October (supplementary)',
    groups: [
      { name: 'Science Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Tarjuma Tul Quran', 'Mathematics', 'Physics', 'Chemistry', 'Biology / Computer Science'] },
      { name: 'Arts Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'General Mathematics', 'General Science', 'Two electives of choice'] },
    ],
    subjects: [
      { name: 'English',            marks: 75,  type: 'compulsory' },
      { name: 'Urdu',               marks: 75,  type: 'compulsory' },
      { name: 'Islamiat',           marks: 100, type: 'compulsory' },
      { name: 'Pakistan Studies',   marks: 50,  type: 'compulsory' },
      { name: 'Tarjuma Tul Quran',  marks: 50,  type: 'compulsory' },
      { name: 'Mathematics',        marks: 75,  type: 'elective' },
      { name: 'Physics',            marks: 60,  type: 'elective' },
      { name: 'Chemistry',          marks: 60,  type: 'elective' },
      { name: 'Biology',            marks: 60,  type: 'elective' },
      { name: 'Computer Science',   marks: 60,  type: 'elective' },
    ],
    paperPatterns: [
      { subject: 'English',      totalMarks: 75, objective: '19 MCQs', subjective: '56 marks — short questions, grammar, letters, comprehension', duration: '2 hr 30 min' },
      { subject: 'Urdu',         totalMarks: 75, objective: '19 MCQs', subjective: '56 marks — short & long questions, grammar', duration: '2 hr 30 min' },
      { subject: 'Mathematics',  totalMarks: 75, objective: '15 MCQs', subjective: '36 marks short + 24 marks long', duration: '2 hr 30 min' },
      { subject: 'Physics',      totalMarks: 60, objective: '12 MCQs', subjective: '48 marks — short, long & numericals', duration: '2 hr 10 min' },
      { subject: 'Chemistry',    totalMarks: 60, objective: '12 MCQs', subjective: '48 marks — 15 short, 2 long', duration: '2 hr 10 min' },
      { subject: 'Biology',      totalMarks: 60, objective: '12 MCQs', subjective: '48 marks — short & long questions', duration: '2 hr 10 min' },
      { subject: 'Islamiat',     totalMarks: 100, objective: 'MCQs + short', subjective: 'Long questions and Quranic references', duration: '3 hr' },
    ],
    faq: [
      { q: 'How many subjects are in Punjab Board Class 9?', a: 'Students study 8 subjects: 4 compulsory (English, Urdu, Islamiat, Pakistan Studies, plus Tarjuma Tul Quran as the 5th) and 3-4 electives depending on the group. Total marks are 550.' },
      { q: 'What is the passing marks for Punjab Board 9th class?', a: 'The passing marks are 182 out of 550, which is 33%. Students must pass each subject individually as well as overall.' },
      { q: 'Do all Punjab boards have the same paper pattern?', a: 'Yes. The Punjab Boards Committee of Chairpersons (PBCC) sets a unified paper pattern, syllabus, and marking scheme across all 9 boards, so the difficulty and topic coverage are identical.' },
      { q: 'When are the Class 9 annual exams held in Punjab?', a: 'The Class 9 annual exams typically run from mid-March to early May. The 2026 exams are scheduled from 17 April to 8 May 2026.' },
      { q: 'What is the total time given for each paper?', a: 'Most papers are 2 hours 30 minutes. Islamiat papers are 3 hours. Physics, Chemistry, and Biology papers are 2 hours 10 minutes.' },
      { q: 'Is Tarjuma Tul Quran compulsory for all students?', a: 'Yes. Tarjuma Tul Quran is a compulsory subject for all 9th class students in Punjab under the new scheme, carrying 50 marks.' },
      { q: 'What is the new Islamic Studies exam format?', a: 'Starting from 2025, Islamiat is a 100-mark paper taken entirely in Class 9. Previously it was 50 marks split across Class 9 and 10. Pakistan Studies now follows the same pattern, taken entirely in Class 10.' },
      { q: 'Which board conducts the Class 9 exam for my school?', a: 'Your board depends on your school location. The 9 Punjab boards are Lahore, Gujranwala, Rawalpindi, Multan, Faisalabad, Sahiwal, Sargodha, Bahawalpur, and DG Khan. Each covers a specific geographical region.' },
    ],
  },
};

export function getBoardInfo(slug: string): BoardInfo | null {
  return BOARD_INFO[slug] || null;
}
