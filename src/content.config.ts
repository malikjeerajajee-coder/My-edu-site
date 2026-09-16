import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const notes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/notes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string().optional(),
    date: z.date().optional(),
  }),
});

const quizzes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/quizzes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    questions: z.array(z.object({
      question: z.string(),
      options: z.array(z.string()),
      answer: z.number(),
    })),
  }),
});

const books = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/books' }),
  schema: z.object({
    title: z.string(),
    author: z.string().optional(),
    class: z.string(),
    subject: z.string(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

const gazettes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/gazettes' }),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    board: z.string(),
    boards: z.array(z.string()).optional(),
    class: z.string(),
    pdfUrl: z.string(),
  }),
});

const topicSchema = z.object({
  chapter: z.string(),
  mcqs: z.number().optional(),
  short: z.number().optional(),
  long: z.number().optional(),
});

const faqSchema = z.object({
  q: z.string(),
  a: z.string(),
});

const pastPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/past-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
    totalMarks: z.number().optional(),
    duration: z.string().optional(),
    objective: z.object({ mcqs: z.number(), marks: z.number() }).optional(),
    subjective: z.object({ short: z.number(), long: z.number(), marks: z.number() }).optional(),
    topics: z.array(topicSchema).optional(),
    faq: z.array(faqSchema).optional(),
  }),
});

const guessPapers = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/guess-papers' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

const pairingSchemes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/pairing-schemes' }),
  schema: z.object({
    title: z.string(),
    class: z.string(),
    year: z.number(),
    board: z.string().optional(),
    boards: z.array(z.string()).optional(),
    pdfUrl: z.string(),
  }),
});

export const collections = {
  notes, quizzes, books, gazettes,
  pastPapers, guessPapers, pairingSchemes,
};
