# Spécifications Techniques Complètes - Suite CreativeAI

## Stack Technique Choisi

### Frontend
- **Framework**: React 18+ avec Vite
- **UI**: Tailwind CSS + HeadlessUI
- **État**: Zustand (plus léger que Redux)
- **Routing**: React Router v6
- **Forms**: React Hook Form + Zod validation
- **HTTP**: TanStack Query (React Query)

### Backend
- **Database**: SurrealDB
- **Auth**: Logto
- **AI Text**: Claude API + OpenAI fallback
- **AI Images**: Replicate API
- **Runtime**: Node.js avec Fastify
- **File Storage**: AWS S3 ou Cloudflare R2

## Architecture Détaillée

### Structure du Monorepo
```
creative-ai-suite/
├── apps/
│   ├── web/                    # Interface utilisateur principale
│   ├── api/                    # API Gateway
│   ├── ebook-service/          # Service création ebooks
│   ├── content-service/        # Service création contenu
│   └── design-service/         # Service création designs
├── packages/
│   ├── ui/                     # Composants partagés
│   ├── database/              # Schémas SurrealDB
│   ├── auth/                  # Utilitaires Logto
│   ├── ai/                    # Intégrations IA
│   └── utils/                 # Utilitaires communs
├── docker-compose.yml
└── turbo.json
```

## Base de Données SurrealDB - Schémas

### Schema Principal
```sql
-- Utilisateurs
DEFINE TABLE users SCHEMAFULL;
DEFINE FIELD email ON users TYPE string;
DEFINE FIELD name ON users TYPE string;
DEFINE FIELD avatar ON users TYPE string;
DEFINE FIELD subscription ON users TYPE record(subscriptions);
DEFINE FIELD preferences ON users TYPE object;
DEFINE FIELD created_at ON users TYPE datetime DEFAULT time::now();
DEFINE INDEX email_idx ON users COLUMNS email UNIQUE;

-- Abonnements
DEFINE TABLE subscriptions SCHEMAFULL;
DEFINE FIELD user ON subscriptions TYPE record(users);
DEFINE FIELD plan ON subscriptions TYPE string;
DEFINE FIELD status ON subscriptions TYPE string;
DEFINE FIELD current_period_start ON subscriptions TYPE datetime;
DEFINE FIELD current_period_end ON subscriptions TYPE datetime;
DEFINE FIELD credits_remaining ON subscriptions TYPE number DEFAULT 0;

-- Projets (générique pour tous types de contenus)
DEFINE TABLE projects SCHEMAFULL;
DEFINE FIELD user ON projects TYPE record(users);
DEFINE FIELD title ON projects TYPE string;
DEFINE FIELD type ON projects TYPE string; -- 'ebook', 'article', 'design', etc.
DEFINE FIELD status ON projects TYPE string; -- 'draft', 'processing', 'completed', 'published'
DEFINE FIELD content ON projects TYPE object;
DEFINE FIELD settings ON projects TYPE object;
DEFINE FIELD metadata ON projects TYPE object;
DEFINE FIELD created_at ON projects TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON projects TYPE datetime DEFAULT time::now();

-- Ebooks spécifiquement
DEFINE TABLE ebooks SCHEMAFULL;
DEFINE FIELD project ON ebooks TYPE record(projects);
DEFINE FIELD genre ON ebooks TYPE string;
DEFINE FIELD target_length ON ebooks TYPE number;
DEFINE FIELD chapters ON ebooks TYPE array<object>;
DEFINE FIELD cover_image ON ebooks TYPE string;
DEFINE FIELD formats ON ebooks TYPE object; -- PDF, EPUB, MOBI URLs
DEFINE FIELD distribution ON ebooks TYPE array<object>;
DEFINE FIELD sales_data ON ebooks TYPE object;

-- Templates
DEFINE TABLE templates SCHEMAFULL;
DEFINE FIELD name ON templates TYPE string;
DEFINE FIELD type ON templates TYPE string;
DEFINE FIELD content ON templates TYPE object;
DEFINE FIELD is_public ON templates TYPE bool DEFAULT false;
DEFINE FIELD creator ON templates TYPE record(users);
DEFINE FIELD usage_count ON templates TYPE number DEFAULT 0;

-- Tâches asynchrones
DEFINE TABLE tasks SCHEMAFULL;
DEFINE FIELD user ON tasks TYPE record(users);
DEFINE FIELD project ON tasks TYPE record(projects);
DEFINE FIELD type ON tasks TYPE string; -- 'generate_text', 'generate_image', 'publish'
DEFINE FIELD status ON tasks TYPE string; -- 'pending', 'processing', 'completed', 'failed'
DEFINE FIELD progress ON tasks TYPE number DEFAULT 0;
DEFINE FIELD result ON tasks TYPE object;
DEFINE FIELD error ON tasks TYPE string;
DEFINE FIELD created_at ON tasks TYPE datetime DEFAULT time::now();

-- Analytics
DEFINE TABLE analytics SCHEMAFULL;
DEFINE FIELD user ON analytics TYPE record(users);
DEFINE FIELD project ON analytics TYPE record(projects);
DEFINE FIELD event_type ON analytics TYPE string;
DEFINE FIELD event_data ON analytics TYPE object;
DEFINE FIELD timestamp ON analytics TYPE datetime DEFAULT time::now();
```

## Services Architecture

### API Gateway (apps/api/src/index.js)
```javascript
import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import { logtoPlugin } from '@packages/auth';
import { ebookRoutes } from './routes/ebook.js';
import { contentRoutes } from './routes/content.js';
import { designRoutes } from './routes/design.js';

const fastify = Fastify({ logger: true });

// Plugins
await fastify.register(cors);
await fastify.register(jwt, { secret: process.env.JWT_SECRET });
await fastify.register(logtoPlugin);

// Routes
await fastify.register(ebookRoutes, { prefix: '/api/ebook' });
await fastify.register(contentRoutes, { prefix: '/api/content' });
await fastify.register(designRoutes, { prefix: '/api/design' });

// Health check
fastify.get('/health', async () => ({ status: 'ok' }));

const start = async () => {
  try {
    await fastify.listen({ port: 3001, host: '0.0.0.0' });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
```

### Service Ebook (apps/ebook-service/src/index.js)
```javascript
import Fastify from 'fastify';
import { AITextGenerator } from '@packages/ai/text';
import { AIImageGenerator } from '@packages/ai/images';
import { EbookFormatter } from './lib/formatter.js';
import { DistributionManager } from './lib/distribution.js';

const fastify = Fastify({ logger: true });

const textGenerator = new AITextGenerator({
  claude: process.env.CLAUDE_API_KEY,
  openai: process.env.OPENAI_API_KEY
});

const imageGenerator = new AIImageGenerator({
  replicate: process.env.REPLICATE_API_TOKEN
});

// Génération d'ebook complet
fastify.post('/generate', async (request, reply) => {
  const { title, genre, targetLength, outline, style } = request.body;
  
  try {
    // Créer la tâche
    const task = await db.create('tasks', {
      user: request.user.id,
      type: 'generate_ebook',
      status: 'processing',
      progress: 0
    });

    // Traitement asynchrone
    processEbookGeneration(task.id, { title, genre, targetLength, outline, style });
    
    return { taskId: task.id };
  } catch (error) {
    return reply.code(500).send({ error: error.message });
  }
});

async function processEbookGeneration(taskId, params) {
  try {
    // 1. Générer la structure
    await updateTaskProgress(taskId, 10);
    const structure = await textGenerator.generateStructure(params);
    
    // 2. Générer les chapitres
    await updateTaskProgress(taskId, 30);
    const chapters = [];
    for (let i = 0; i < structure.chapters.length; i++) {
      const chapter = await textGenerator.generateChapter(structure.chapters[i]);
      chapters.push(chapter);
      await updateTaskProgress(taskId, 30 + (i / structure.chapters.length) * 40);
    }
    
    // 3. Générer la couverture
    await updateTaskProgress(taskId, 80);
    const coverImage = await imageGenerator.generateCover({
      title: params.title,
      genre: params.genre,
      style: 'professional'
    });
    
    // 4. Formatter l'ebook
    await updateTaskProgress(taskId, 90);
    const formatter = new EbookFormatter();
    const formats = await formatter.createFormats({
      title: params.title,
      chapters,
      coverImage
    });
    
    // 5. Sauvegarder
    await db.update('tasks', taskId, {
      status: 'completed',
      progress: 100,
      result: { chapters, coverImage, formats }
    });
    
  } catch (error) {
    await db.update('tasks', taskId, {
      status: 'failed',
      error: error.message
    });
  }
}
```

### Générateur IA Texte (packages/ai/src/text.js)
```javascript
import Anthropic from '@anthropic-ai/sdk';
import OpenAI from 'openai';

export class AITextGenerator {
  constructor({ claude, openai }) {
    this.claude = new Anthropic({ apiKey: claude });
    this.openai = new OpenAI({ apiKey: openai });
  }

  async generateStructure({ title, genre, targetLength, outline }) {
    const prompt = `
Créer la structure détaillée d'un ebook:
- Titre: ${title}
- Genre: ${genre}
- Longueur cible: ${targetLength} mots
- Synopsis: ${outline}

Retourner un JSON avec:
- introduction (résumé 100 mots)
- chapters (array avec title, summary, wordCount pour chaque chapitre)
- conclusion (résumé 100 mots)
`;

    try {
      const response = await this.claude.messages.create({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }]
      });
      
      return JSON.parse(response.content[0].text);
    } catch (error) {
      // Fallback vers OpenAI
      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        response_format: { type: 'json_object' }
      });
      
      return JSON.parse(response.choices[0].message.content);
    }
  }

  async generateChapter({ title, summary, wordCount, previousChapters = [] }) {
    const context = previousChapters.length > 0 
      ? `Contexte des chapitres précédents:\n${previousChapters.map(ch => ch.title + ': ' + ch.summary).join('\n')}\n\n`
      : '';

    const prompt = `${context}Écrire le chapitre complet:
Titre: ${title}
Résumé: ${summary}
Longueur: ${wordCount} mots

Le chapitre doit être engageant, bien structuré et cohérent avec l'histoire globale.`;

    try {
      const response = await this.claude.messages.create({
        model: 'claude-3-sonnet-20240229',
        max_tokens: 4000,
        messages: [{ role: 'user', content: prompt }]
      });
      
      return {
        title,
        content: response.content[0].text,
        wordCount: response.content[0].text.split(' ').length
      };
    } catch (error) {
      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 4000
      });
      
      return {
        title,
        content: response.choices[0].message.content,
        wordCount: response.choices[0].message.content.split(' ').length
      };
    }
  }

  async improveText(text, improvements = ['grammar', 'style', 'flow']) {
    const prompt = `Améliorer ce texte en se concentrant sur: ${improvements.join(', ')}

Texte original:
${text}

Retourner le texte amélioré en conservant le sens et le style original.`;

    const response = await this.claude.messages.create({
      model: 'claude-3-sonnet-20240229',
      max_tokens: 4000,
      messages: [{ role: 'user', content: prompt }]
    });
    
    return response.content[0].text;
  }
}
```

### Générateur IA Images (packages/ai/src/images.js)
```javascript
import Replicate from 'replicate';

export class AIImageGenerator {
  constructor({ replicate }) {
    this.replicate = new Replicate({ auth: replicate });
  }

  async generateCover({ title, genre, style = 'professional' }) {
    const genreStyles = {
      'fiction': 'dramatic lighting, artistic composition',
      'non-fiction': 'clean, professional, modern',
      'romance': 'warm colors, elegant typography',
      'thriller': 'dark atmosphere, suspenseful mood',
      'fantasy': 'mystical elements, vibrant colors',
      'sci-fi': 'futuristic design, tech elements'
    };

    const prompt = `Book cover design for "${title}", ${genre} genre, ${genreStyles[genre] || 'professional design'}, ${style} style, high quality, 4K, book cover layout, readable title placement`;

    try {
      const output = await this.replicate.run(
        "stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
        {
          input: {
            prompt,
            negative_prompt: "blurry, low quality, distorted text, watermark",
            width: 768,
            height: 1024,
            num_outputs: 1,
            scheduler: "K_EULER",
            num_inference_steps: 50,
            guidance_scale: 7.5
          }
        }
      );

      return output[0];
    } catch (error) {
      console.error('Erreur génération image:', error);
      throw new Error('Impossible de générer la couverture');
    }
  }

  async generateIllustration({ description, style, width = 1024, height = 768 }) {
    const prompt = `${description}, ${style} illustration, high quality, detailed, professional artwork`;

    const output = await this.replicate.run(
      "stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
      {
        input: {
          prompt,
          width,
          height,
          num_inference_steps: 50,
          guidance_scale: 7.5
        }
      }
    );

    return output[0];
  }
}
```

### Formatteur Ebook (apps/ebook-service/src/lib/formatter.js)
```javascript
import puppeteer from 'puppeteer';
import archiver from 'archiver';
import path from 'path';
import fs from 'fs/promises';

export class EbookFormatter {
  async createFormats({ title, chapters, coverImage, author = 'AI Generated' }) {
    const formats = {};
    
    // Générer PDF
    formats.pdf = await this.generatePDF({ title, chapters, coverImage, author });
    
    // Générer EPUB
    formats.epub = await this.generateEPUB({ title, chapters, coverImage, author });
    
    // Générer MOBI (via calibre si disponible)
    // formats.mobi = await this.generateMOBI(formats.epub);
    
    return formats;
  }

  async generatePDF({ title, chapters, coverImage, author }) {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    
    const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>${title}</title>
    <style>
        @page { 
            size: A4; 
            margin: 2cm; 
        }
        body { 
            font-family: 'Times New Roman', serif; 
            line-height: 1.6; 
            color: #333;
        }
        .cover { 
            text-align: center; 
            page-break-after: always; 
            padding-top: 100px;
        }
        .cover img { 
            max-width: 400px; 
            height: auto; 
        }
        .cover h1 { 
            font-size: 2.5em; 
            margin: 20px 0; 
        }
        .cover h2 { 
            font-size: 1.5em; 
            color: #666; 
        }
        .chapter { 
            page-break-before: always; 
        }
        .chapter h2 { 
            font-size: 1.8em; 
            border-bottom: 2px solid #333; 
            padding-bottom: 10px; 
        }
        .chapter-content { 
            text-align: justify; 
            text-indent: 2em; 
        }
        .chapter-content p { 
            margin: 1em 0; 
        }
    </style>
</head>
<body>
    <div class="cover">
        <img src="${coverImage}" alt="Couverture">
        <h1>${title}</h1>
        <h2>par ${author}</h2>
    </div>
    
    ${chapters.map(chapter => `
        <div class="chapter">
            <h2>${chapter.title}</h2>
            <div class="chapter-content">
                ${chapter.content.split('\n').map(p => `<p>${p}</p>`).join('')}
            </div>
        </div>
    `).join('')}
</body>
</html>`;
    
    await page.setContent(html, { waitUntil: 'networkidle0' });
    const pdf = await page.pdf({ 
      format: 'A4',
      printBackground: true,
      margin: { top: '2cm', bottom: '2cm', left: '2cm', right: '2cm' }
    });
    
    await browser.close();
    return pdf;
  }

  async generateEPUB({ title, chapters, coverImage, author }) {
    // Structure EPUB basique
    const epubStructure = {
      'META-INF/container.xml': `<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>`,
      
      'OEBPS/content.opf': `<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookId" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:title>${title}</dc:title>
    <dc:creator opf:role="aut">${author}</dc:creator>
    <dc:identifier id="BookId">${Date.now()}</dc:identifier>
    <dc:language>fr</dc:language>
  </metadata>
  <manifest>
    <item id="cover" href="cover.jpg" media-type="image/jpeg"/>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    ${chapters.map((_, i) => `<item id="chapter${i+1}" href="chapter${i+1}.xhtml" media-type="application/xhtml+xml"/>`).join('\n    ')}
  </manifest>
  <spine toc="ncx">
    ${chapters.map((_, i) => `<itemref idref="chapter${i+1}"/>`).join('\n    ')}
  </spine>
</package>`,
      
      'OEBPS/toc.ncx': `<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="${Date.now()}"/>
  </head>
  <docTitle><text>${title}</text></docTitle>
  <navMap>
    ${chapters.map((chapter, i) => `
    <navPoint id="chapter${i+1}" playOrder="${i+1}">
      <navLabel><text>${chapter.title}</text></navLabel>
      <content src="chapter${i+1}.xhtml"/>
    </navPoint>`).join('')}
  </navMap>
</ncx>`
    };

    // Ajouter les chapitres
    chapters.forEach((chapter, i) => {
      epubStructure[`OEBPS/chapter${i+1}.xhtml`] = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>${chapter.title}</title>
  <style>
    body { font-family: serif; line-height: 1.6; }
    h1 { text-align: center; margin-bottom: 2em; }
    p { text-indent: 2em; margin: 1em 0; text-align: justify; }
  </style>
</head>
<body>
  <h1>${chapter.title}</h1>
  ${chapter.content.split('\n').map(p => `<p>${p}</p>`).join('\n  ')}
</body>
</html>`;
    });

    // Créer le ZIP EPUB
    const archive = archiver('zip', { store: true });
    const chunks = [];
    
    archive.on('data', chunk => chunks.push(chunk));
    
    // Ajouter mimetype en premier (non compressé)
    archive.append('application/epub+zip', { name: 'mimetype', store: true });
    
    // Ajouter tous les fichiers
    Object.entries(epubStructure).forEach(([filename, content]) => {
      archive.append(content, { name: filename });
    });
    
    await archive.finalize();
    return Buffer.concat(chunks);
  }
}
```

### Distribution Manager (apps/ebook-service/src/lib/distribution.js)
```javascript
export class DistributionManager {
  constructor() {
    this.platforms = {
      amazon: new AmazonKDPClient(),
      apple: new AppleBooksClient(),
      google: new GooglePlayBooksClient(),
      kobo: new KoboClient()
    };
  }

  async publishEbook(ebook, platforms = ['amazon']) {
    const results = {};
    
    for (const platform of platforms) {
      try {
        results[platform] = await this.platforms[platform].publish(ebook);
      } catch (error) {
        results[platform] = { error: error.message };
      }
    }
    
    return results;
  }
}

class AmazonKDPClient {
  async publish({ title, author, description, categories, price, formats }) {
    // Intégration avec Amazon KDP API (quand disponible)
    // Pour l'instant, génération des métadonnées optimisées
    return {
      status: 'prepared',
      metadata: {
        title,
        author,
        description: this.optimizeDescription(description),
        keywords: this.generateKeywords(title, description, categories),
        categories: this.mapCategories(categories),
        price
      },
      files: {
        manuscript: formats.pdf || formats.epub,
        cover: formats.cover
      }
    };
  }

  optimizeDescription(description) {
    // Optimiser la description pour Amazon
    return description.length > 4000 
      ? description.substring(0, 4000) + '...'
      : description;
  }

  generateKeywords(title, description, categories) {
    // Extraire mots-clés pertinents
    const words = [...title.split(' '), ...description.split(' ')]
      .filter(word => word.length > 3)
      .slice(0, 7);
    return words;
  }

  mapCategories(categories) {
    // Mapper vers catégories Amazon
    const mapping = {
      'fiction': 'Fiction & Literature',
      'non-fiction': 'Non-Fiction',
      'romance': 'Romance',
      'thriller': 'Mystery, Thriller & Suspense'
    };
    return categories.map(cat => mapping[cat] || cat);
  }
}
```

## Frontend React Components

### Structure des Composants UI (packages/ui/src/index.js)
```javascript
// Composants de base réutilisables
export { Button } from './Button';
export { Input } from './Input';
export { Modal } from './Modal';
export { Card } from './Card';
export { Progress } from './Progress';
export { Toast } from './Toast';

// Composants métier
export { ProjectCard } from './ProjectCard';
export { TaskStatus } from './TaskStatus';
export { AISettings } from './AISettings';
export { TemplateSelector } from './TemplateSelector';
```

### Composant Principal Ebook (apps/web/src/components/EbookCreator.jsx)
```jsx
import React, { useState } from 'react';
import { useMutation, useQuery } from '@tanstack/react-query';
import { Button, Input, Card, Progress, Toast } from '@packages/ui';
import { useAuth } from '@packages/auth';

export function EbookCreator() {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    title: '',
    genre: 'fiction',
    targetLength: 20000,
    outline: '',
    style: 'engaging'
  });
  const [currentTask, setCurrentTask] = useState(null);

  const generateEbook = useMutation({
    mutationFn: async (data) => {
      const response = await fetch('/api/ebook/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      return response.json();
    },
    onSuccess: (data) => {
      setCurrentTask(data.taskId);
    }
  });

  const { data: taskStatus } = useQuery({
    queryKey: ['task', currentTask],
    queryFn: async () => {
      const response = await fetch(`/api/tasks/${currentTask}`);
      return response.json();
    },
    enabled: !!currentTask,
    refetchInterval: currentTask ? 2000 : false
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    generateEbook.mutate(formData);
  };

  return (
    <div className="max-w-4xl mx-auto p-6">
      <Card className="p-8">
        <h1 className="text-3xl font-bold mb-8">Créer un Ebook</h1>
        
        {!currentTask ? (
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-sm font-medium mb-2">
                Titre de l'ebook
              </label>
              <Input
                value={formData.title}
                onChange={(e) => setFormData(prev => ({
                  ...prev, 
                  title: e.target.value
                }))}
                placeholder="Le mystère de la forêt enchantée"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Genre</label>
              <select
                value={formData.genre}
                onChange={(e) => setFormData(prev => ({
                  ...prev, 
                  genre: e.target.value
                }))}
                className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="fiction">Fiction</option>
                <option value="non-fiction">Non-Fiction</option>
                <option value="romance">Romance</option>
                <option value="thriller">Thriller</option>
                <option value="fantasy">Fantasy</option>
                <option value="sci-fi">Science-Fiction</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">
                Longueur cible (mots)
              </label>
              <Input
                type="number"
                value={formData.targetLength}
                onChange={(e) => setFormData(prev => ({
                  ...prev, 
                  targetLength: parseInt(e.target.value)
                }))}
                min="5000"
                max="100000"
                step="1000"
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">
                Synopsis / Idée principale
              </label>
              <textarea
                value={formData.outline}
                onChange={(e) => setFormData(prev => ({
                  ...prev, 
                  outline: e.target.value
                }))}
                placeholder="Décrivez l'idée principale, les personnages, l'intrigue..."
                rows="4"
                className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">
                Style d'écriture
              </label>
              <select
                value={formData.style}
                onChange={(e) => setFormData(prev => ({
                  ...prev, 
                  style: e.target.value
                }))}
                className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="engaging">Engageant et accessible</option>
                <option value="literary">Littéraire et sophistiqué</option>
                <option value="conversational">Conversationnel</option>
                <option value="dramatic">