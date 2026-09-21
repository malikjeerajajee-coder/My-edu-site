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

  federal: {
    slug: 'federal',
    overview: 'The Federal Board of Intermediate and Secondary Education (FBISE) is Pakistan\'s national-level board, headquartered in Islamabad. It serves students in federal government schools and colleges across Pakistan, in cantonment areas, and in Pakistani institutions overseas. Unlike provincial boards, FBISE sets a single unified paper for the entire country — every student affiliated with FBISE sits the same exam on the same day. FBISE is known for a slightly more analytical paper pattern than provincial boards, with greater emphasis on conceptual understanding over rote memorisation.',
    boardsServed: [
      'Federal Board (FBISE)',
    ],
    totalMarks: 550,
    passingMarks: 182,
    examMonths: 'February to April (annual), October (supplementary)',
    groups: [
      { name: 'Science Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'Mathematics', 'Physics', 'Chemistry', 'Biology / Computer Science'] },
      { name: 'Arts Group', subjects: ['English', 'Urdu', 'Islamiat', 'Pakistan Studies', 'General Mathematics', 'General Science', 'Two electives of choice'] },
    ],
    subjects: [
      { name: 'English',              marks: 75,  type: 'compulsory' },
      { name: 'Urdu',                 marks: 75,  type: 'compulsory' },
      { name: 'Islamiat',             marks: 50,  type: 'compulsory' },
      { name: 'Pakistan Studies',     marks: 50,  type: 'compulsory' },
      { name: 'Mathematics',          marks: 75,  type: 'elective' },
      { name: 'Physics',              marks: 60,  type: 'elective' },
      { name: 'Chemistry',            marks: 60,  type: 'elective' },
      { name: 'Biology',              marks: 60,  type: 'elective' },
      { name: 'Computer Science',     marks: 60,  type: 'elective' },
    ],
    paperPatterns: [
      { subject: 'English',      totalMarks: 75, objective: '15 MCQs + short', subjective: '60 marks — short & long questions, grammar, composition', duration: '2 hr 40 min' },
      { subject: 'Urdu',         totalMarks: 75, objective: '15 MCQs + short', subjective: '60 marks — short & long questions, grammar', duration: '2 hr 40 min' },
      { subject: 'Mathematics',  totalMarks: 75, objective: '12 MCQs + short', subjective: '52 marks — short & long questions', duration: '2 hr 40 min' },
      { subject: 'Physics',      totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — including numericals', duration: '2 hr 10 min' },
      { subject: 'Chemistry',    totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — short & long', duration: '2 hr 10 min' },
      { subject: 'Biology',      totalMarks: 60, objective: '12 MCQs + short', subjective: '48 marks — short & long', duration: '2 hr 10 min' },
      { subject: 'Islamiat',     totalMarks: 50, objective: 'MCQs + short',    subjective: 'Short & long questions', duration: '2 hr' },
    ],
    faq: [
      { q: 'What is FBISE?', a: 'FBISE stands for Federal Board of Intermediate and Secondary Education. It\'s the national examination board of Pakistan, headquartered in Islamabad, and sets one unified paper for all affiliated institutions across the country.' },
      { q: 'Does FBISE set one paper for the whole country?', a: 'Yes. Unlike provincial boards which have 5–9 separate BISEs, FBISE sets a single paper for every affiliated school — whether in Islamabad, Karachi, Lahore, or overseas. Every student sits the same exam.' },
      { q: 'What is the total marks for FBISE Class 9?', a: 'FBISE Class 9 is worth 550 marks across 8 subjects. Passing requires at least 182 marks (33%).' },
      { q: 'When are FBISE Class 9 exams held?', a: 'FBISE typically holds the annual SSC Part-I (Class 9) exams in February to April. Supplementary exams are held in October.' },
      { q: 'How is FBISE different from provincial boards?', a: 'FBISE papers are known for a slightly more analytical pattern, with more emphasis on conceptual understanding and application. The syllabus is similar but the question style rewards deeper reasoning.' },
      { q: 'Which schools come under FBISE?', a: 'Federal government schools and colleges (FGEIs), Pakistan Army and Air Force schools, cadet colleges, and Pakistani schools in embassies and missions abroad.' },
      { q: 'Are FBISE past papers accepted by other boards?', a: 'No — FBISE sets a completely different paper from provincial boards. If you\'re sitting FBISE, you must study FBISE past papers specifically.' },
      { q: 'What is the passing marks for FBISE 9th class?', a: 'Passing marks are 182 out of 550, which is 33%. Students must pass each subject individually as well as overall.' },
    ],
  },
};

export function getBoardInfo(slug: string): BoardInfo | null {
  return BOARD_INFO[slug] || null;
}
