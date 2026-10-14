/**
 * Class display helpers.
 * In the Pakistani education system there is no "Class 0".
 * The pre-Class-1 year is officially ECCE (Early Childhood Care and Education),
 * commonly called Kachi.
 */
export const classLabel = (c: string | number): string => {
  const s = String(c);
  if (s === '0') return 'ECCE';
  return `Class ${s}`;
};

export const classFullLabel = (c: string | number): string => {
  const s = String(c);
  if (s === '0') return 'ECCE (Kachi)';
  return `Class ${s}`;
};

export const classShortLabel = (c: string | number): string => {
  const s = String(c);
  if (s === '0') return 'ECCE';
  return s.padStart(2, '0');
};