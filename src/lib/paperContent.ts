// Curriculum chapters per subject+class
export const CURRICULUM: Record<string, string[]> = {
  'Physics|9': ['Physical Quantities & Measurement','Kinematics','Dynamics','Turning Effect of Forces','Gravitation','Work & Energy','Properties of Matter','Thermal Properties','Transfer of Heat'],
  'Physics|10': ['Simple Harmonic Motion & Waves','Sound','Geometrical Optics','Electrostatics','Current Electricity','Electromagnetism','Basic Electronics','Information & Communication Technology','Radioactivity'],
  'Physics|11': ['Measurements','Vectors & Equilibrium','Motion & Force','Work & Energy','Rotational & Circular Motion','Fluid Dynamics','Oscillations','Waves','Physical Optics','Optical Instruments','Heat & Thermodynamics'],
  'Physics|12': ['Electrostatics','Current Electricity','Electromagnetism','Electromagnetic Induction','Alternating Current','Physics of Solids','Electronics','Dawn of Modern Physics','Atomic Spectra','Nuclear Physics'],
  'Chemistry|9': ['Fundamentals of Chemistry','Structure of Atoms','Periodic Table & Periodicity','Structure of Molecules','Physical States of Matter','Solutions','Electrochemistry','Chemical Reactivity'],
  'Chemistry|10': ['Chemical Equilibrium','Acids, Bases & Salts','Organic Chemistry','Hydrocarbons','Biochemistry','Environmental Chemistry','Water','Chemical Industries'],
  'Chemistry|11': ['Basic Concepts','Experimental Techniques','Gases','Liquids','Solids','Chemical Equilibrium','Reaction Kinetics','Thermochemistry','Electrochemistry','Chemical Bonding','S & p-Block Elements'],
  'Chemistry|12': ['Periodic Classification','s-Block Elements','Group IIIA & IVA','Group VA & VIA','Halogens & Noble Gases','Transition Elements','Fundamental Principles of Organic Chemistry','Aliphatic Hydrocarbons','Aromatic Hydrocarbons','Alkyl Halides','Alcohols, Phenols & Ethers','Carbonyl Compounds','Carboxylic Acids','Macromolecules'],
  'Biology|9': ['Introduction to Biology','Solving a Biological Problem','Biodiversity','Cells & Tissues','Cell Cycle','Enzymes','Bioenergetics','Nutrition','Transport'],
  'Biology|10': ['Gaseous Exchange','Homeostasis','Coordination & Control','Support & Movement','Reproduction','Inheritance','Man & His Environment','Biotechnology'],
  'Biology|11': ['Introduction','Biological Molecules','Enzymes','The Cell','Variety of Life','Kingdom Monera','Kingdom Protista','Kingdom Fungi','Kingdom Plantae','Kingdom Animalia','Bioenergetics'],
  'Biology|12': ['Homeostasis','Support & Movement','Coordination & Control','Reproduction','Growth & Development','Chromosomes & DNA','Evolution','Ecosystem','Some Major Ecosystems','Man & His Environment'],
  'Mathematics|9': ['Matrices & Determinants','Real & Complex Numbers','Logarithms','Algebraic Expressions','Factorization','Algebraic Manipulation','Linear Equations & Inequalities','Linear Graphs & Their Applications','Introduction to Coordinate Geometry'],
  'Mathematics|10': ['Quadratic Equations','Theory of Quadratic Equations','Variations','Partial Fractions','Sets & Functions','Basic Statistics','Introduction to Trigonometry','Projection of a Side of a Triangle','Chords of a Circle','Tangent to a Circle','Chords & Arcs','Angle in a Segment','Practical Geometry — Triangles'],
  'Mathematics|11': ['Number Systems','Sets, Functions & Groups','Matrices & Determinants','Quadratic Equations','Sequences & Series','Permutation & Combination','Mathematical Induction & Binomial Theorem','Mathematical Functions','Linear Programming','Trigonometric Identities','Trigonometric Functions & Their Graphs'],
  'Mathematics|12': ['Functions & Limits','Differentiation','Integration','Introduction to Analytic Geometry','Linear Inequalities & Linear Programming','Conic Sections','Vectors','Introduction to Numerical Methods','Further Applications of Integration'],
  'English|9': ['Reading Comprehension','Vocabulary','Grammar & Structure','Translation','Letter Writing','Story Writing','Essay Writing'],
  'English|10': ['Reading Comprehension','Vocabulary','Grammar & Structure','Translation','Letter Writing','Story Writing','Essay Writing'],
  'English|11': ['Reading Comprehension','Vocabulary','Grammar & Structure','Idioms','Letter & Application Writing','Story Writing','Essay Writing','Translation'],
  'English|12': ['Reading Comprehension','Vocabulary','Grammar & Structure','Idioms','Letter & Application Writing','Story Writing','Essay Writing','Translation'],
  'Urdu|9': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing'],
  'Urdu|10': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing'],
  'Urdu|11': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing','Translation'],
  'Urdu|12': ['Nazm','Ghazal','Afsanay','Drama','Grammar','Letter Writing','Essay Writing','Translation'],
  'Islamiat|9': ['Quran Majeed','Hadith Sharif','Ibadat','Seerat-un-Nabi (SAW)','Akhlaqiat','Social Life'],
  'Islamiat|10': ['Quran Majeed','Hadith Sharif','Ibadat','Seerat-un-Nabi (SAW)','Akhlaqiat','Social Life'],
  'Pakistan Studies|9': ['Ideology of Pakistan','Constitutional Development of Pakistan','Land & People of Pakistan'],
  'Pakistan Studies|10': ['Economic Development of Pakistan','Foreign Policy of Pakistan','Pakistan & the Muslim World'],
  'Computer Science|9': ['Introduction to Computers','Computer Components','Input & Output Devices','Storage Devices','Number Systems','Software','Networking'],
  'Computer Science|10': ['Programming Fundamentals','C Language Basics','Control Structures','Arrays & Strings','Functions','File Handling'],
  'Computer Science|11': ['Computer Basics','Data Communication','Applications & Uses of Computers','Programming in C','Data Types & Operators','Decision Making','Loops','Arrays','Functions'],
  'Computer Science|12': ['Data Basics','Database Systems','Database Design Process','Data Integrity & Normalization','Introduction to Microsoft Access','Programming in C++','Objects & Classes','File Handling in C++'],
};

export function chaptersFor(subject: string, cls: string): string[] | null {
  return CURRICULUM[`${subject}|${cls}`] || null;
}

// ── Board-aware helpers ──
function provinceOf(data: any): string {
  return (data.boards || [])[0] || 'Punjab';
}
function boardLabel(data: any): string {
  const province = provinceOf(data);
  if (data.bise) return `BISE ${data.bise}`;
  return province === 'Federal' ? 'Federal Board (FBISE)' : `${province} Board`;
}

// ── Marks: board-aware ──
export function marksFor(subject: string, cls: string, province?: string): number {
  const isFederal = province === 'Federal';
  const isHSSC = ['11','12'].includes(cls);

  if (isFederal) {
    if (isHSSC) return 100;
    return subject === 'Islamiat' ? 50 : subject === 'Pakistan Studies' ? 50 : 75;
  }

  // Punjab (PCTB) default
  if (isHSSC) {
    if (['Physics','Chemistry','Biology'].includes(subject)) return 85;
    return 100;
  }
  // SSC
  const m: Record<string, number> = {
    Physics: 60, Chemistry: 60, Biology: 60,
    'Computer Science': 60,
    English: 75, Urdu: 75,
    Islamiat: 100, 'Pakistan Studies': 50,
    Mathematics: 75,
    'General Mathematics': 75, 'General Science': 60,
  };
  return m[subject] || 75;
}

export function durationFor(subject: string, cls: string, province?: string): string {
  if (province === 'Federal') {
    return ['11','12'].includes(cls) ? '3 hours' : '2 hours 40 minutes';
  }
  if (['Physics','Chemistry','Biology'].includes(subject) && ['9','10'].includes(cls)) return '2 hours 10 minutes';
  if (subject === 'Islamiat') return '3 hours';
  return '2 hours 30 minutes';
}

// ── Intro: board-aware ──
export function paperIntro(data: any): string {
  const board = boardLabel(data);
  const province = provinceOf(data);
  const exam = ['9','10'].includes(data.class) ? 'SSC' : 'HSSC';
  const part = ['9','11'].includes(data.class) ? 'Part-I' : 'Part-II';

  let provinceContext = '';
  if (province === 'Federal') {
    provinceContext = 'The Federal Board of Intermediate and Secondary Education (FBISE) sets a single unified paper for all its affiliated institutions across Pakistan.';
  } else if (province === 'Punjab') {
    provinceContext = `${board} follows the PBCC (Punjab Boards Committee of Chairpersons) syllabus and paper pattern shared across all 9 Punjab BISEs, but sets its own question paper.`;
  } else if (province === 'Sindh') {
    provinceContext = `Sindh has 5 separate BISEs and this paper is specifically from ${board}.`;
  } else if (province === 'KPK') {
    provinceContext = `Khyber Pakhtunkhwa has 8 separate BISEs; this paper is specifically from ${board}.`;
  } else if (province === 'Balochistan') {
    provinceContext = `Balochistan has 7 separate BISEs; this paper is specifically from ${board}.`;
  } else if (province === 'AJK') {
    provinceContext = `Azad Jammu & Kashmir has 3 separate BISEs; this paper is specifically from ${board}.`;
  }

  return `${data.subject} is a core subject in the Class ${data.class} curriculum under ${board}. ` +
    `This is the official paper set for the ${data.year} ${exam} ${part} annual examination — ` +
    `the paper thousands of Pakistani students actually sat that year. ` +
    `${provinceContext} Studying it gives you the single clearest picture of the difficulty, ` +
    `the question distribution, and the paper pattern used by ${board}.`;
}

// ── FAQ: board-aware ──
export function paperFAQ(data: any): { q: string; a: string }[] {
  const board = boardLabel(data);
  const province = provinceOf(data);
  const marks = marksFor(data.subject, data.class, province);
  const dur = durationFor(data.subject, data.class, province);

  const sameAcrossQuestion = province === 'Punjab'
    ? `Is this paper the same across all Punjab boards?`
    : province === 'Federal'
    ? `Does FBISE set one paper for the whole country?`
    : `Is this paper the same across all ${province} boards?`;

  const sameAcrossAnswer = province === 'Punjab'
    ? (data.bise
        ? `No. Each BISE in ${data.boards?.[0] || 'Punjab'} sets its own questions from the same shared syllabus. This is specifically the ${data.year} paper from BISE ${data.bise}.`
        : `This paper is from ${board}.`)
    : province === 'Federal'
    ? `Yes. FBISE sets a single unified paper for every affiliated school and college across Pakistan, whether in Islamabad, cantonments, or overseas. This is the ${data.year} paper.`
    : `No. ${province} has multiple separate BISEs, each setting its own paper from the shared provincial syllabus. This is specifically the ${data.year} paper from ${board}.`;

  return [
    { q: sameAcrossQuestion, a: sameAcrossAnswer },
    { q: `What is the total marks for ${data.subject} Class ${data.class}?`, a: `${marks} marks.` },
    { q: `How long do students get to complete the paper?`, a: `${dur}.` },
    { q: `Where can I find papers from other years?`, a: `All ${data.subject} papers for ${board} are available on this site — see the related papers section below.` },
    { q: `Does this download include answers?`, a: `No, this is the question paper as it was originally printed. For detailed explanations, browse the ${data.subject} Class ${data.class} notes on this site.` },
  ];
}
