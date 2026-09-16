import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const notes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/notes' }),
  schema: z.object({
    title: z.string(),
    subject: z.string(),
    class: z.string(),
    board: z.string().optional(),
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
    pdfUrl: z.string(),
  }),
});

const gazettes = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/gazettes' }),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    board: z.string(),
    class: z.string(),
    pdfUrl: z.string(),
  }),
});

export const collections = { notes, quizzes, books, gazettes };
