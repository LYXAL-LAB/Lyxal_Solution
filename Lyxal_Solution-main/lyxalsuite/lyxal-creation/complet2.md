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
                <option value="dramatic">Dramatique et intense</option>
                <option value="humorous">Humoristique</option>
              </select>
            </div>

            <Button
              type="submit"
              loading={generateEbook.isPending}
              className="w-full py-4 text-lg"
            >
              {generateEbook.isPending ? 'Génération en cours...' : 'Générer l\'Ebook'}
            </Button>
          </form>
        ) : (
          <div className="text-center">
            <h2 className="text-2xl font-semibold mb-4">Génération en cours</h2>
            <Progress 
              value={taskStatus?.progress || 0} 
              className="mb-4"
            />
            <p className="text-gray-600 mb-8">
              {taskStatus?.status === 'processing' 
                ? `Étape en cours: ${getStepDescription(taskStatus.progress)}`
                : 'Initialisation...'
              }
            </p>
            
            {taskStatus?.status === 'completed' && (
              <div className="mt-8">
                <h3 className="text-xl font-semibold text-green-600 mb-4">
                  ✅ Ebook généré avec succès !
                </h3>
                <div className="flex gap-4 justify-center">
                  <Button onClick={() => downloadFile('pdf')}>
                    Télécharger PDF
                  </Button>
                  <Button onClick={() => downloadFile('epub')}>
                    Télécharger EPUB
                  </Button>
                  <Button variant="outline" onClick={() => setCurrentTask(null)}>
                    Créer un nouveau livre
                  </Button>
                </div>
              </div>
            )}
            
            {taskStatus?.status === 'failed' && (
              <div className="mt-8">
                <h3 className="text-xl font-semibold text-red-600 mb-4">
                  ❌ Erreur lors de la génération
                </h3>
                <p className="text-gray-600 mb-4">{taskStatus.error}</p>
                <Button onClick={() => setCurrentTask(null)}>
                  Réessayer
                </Button>
              </div>
            )}
          </div>
        )}
      </Card>
    </div>
  );
}

function getStepDescription(progress) {
  if (progress < 20) return 'Génération de la structure...';
  if (progress < 70) return 'Écriture des chapitres...';
  if (progress < 85) return 'Création de la couverture...';
  if (progress < 95) return 'Formatage des fichiers...';
  return 'Finalisation...';
}
```

### Dashboard Principal (apps/web/src/components/Dashboard.jsx)
```jsx
import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, Button } from '@packages/ui';
import { useAuth } from '@packages/auth';
import { PlusIcon, BookOpenIcon, TrendingUpIcon } from 'lucide-react';

export function Dashboard() {
  const { user } = useAuth();
  
  const { data: projects } = useQuery({
    queryKey: ['projects', user.id],
    queryFn: async () => {
      const response = await fetch('/api/projects');
      return response.json();
    }
  });

  const { data: analytics } = useQuery({
    queryKey: ['analytics', user.id],
    queryFn: async () => {
      const response = await fetch('/api/analytics/dashboard');
      return response.json();
    }
  });

  return (
    <div className="max-w-7xl mx-auto p-6">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Tableau de bord</h1>
          <p className="text-gray-600">Bienvenue, {user.name}</p>
        </div>
        <Button href="/create" className="flex items-center gap-2">
          <PlusIcon size={20} />
          Nouveau projet
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Projets créés</p>
              <p className="text-3xl font-bold">{analytics?.totalProjects || 0}</p>
            </div>
            <BookOpenIcon className="h-8 w-8 text-blue-500" />
          </div>
        </Card>
        
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Ebooks publiés</p>
              <p className="text-3xl font-bold">{analytics?.publishedBooks || 0}</p>
            </div>
            <TrendingUpIcon className="h-8 w-8 text-green-500" />
          </div>
        </Card>
        
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Crédits restants</p>
              <p className="text-3xl font-bold">{user.subscription?.credits_remaining || 0}</p>
            </div>
            <div className="h-8 w-8 bg-purple-100 rounded-full flex items-center justify-center">
              <span className="text-purple-600 font-bold">⚡</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Projets récents */}
      <Card className="p-6">
        <h2 className="text-xl font-semibold mb-6">Projets récents</h2>
        {projects?.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {projects.slice(0, 6).map(project => (
              <ProjectCard key={project.id} project={project} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <BookOpenIcon className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Aucun projet encore
            </h3>
            <p className="text-gray-600 mb-6">
              Commencez par créer votre premier ebook
            </p>
            <Button href="/create">Créer mon premier ebook</Button>
          </div>
        )}
      </Card>
    </div>
  );
}

function ProjectCard({ project }) {
  const statusColors = {
    'draft': 'bg-gray-100 text-gray-800',
    'processing': 'bg-blue-100 text-blue-800',
    'completed': 'bg-green-100 text-green-800',
    'published': 'bg-purple-100 text-purple-800'
  };

  return (
    <Card className="p-4 hover:shadow-md transition-shadow cursor-pointer">
      <div className="flex justify-between items-start mb-3">
        <h3 className="font-semibold text-lg line-clamp-2">{project.title}</h3>
        <span className={`px-2 py-1 rounded-full text-xs ${statusColors[project.status]}`}>
          {project.status}
        </span>
      </div>
      
      <p className="text-gray-600 text-sm mb-3 line-clamp-2">
        {project.content?.outline || 'Aucune description'}
      </p>
      
      <div className="flex justify-between items-center text-sm text-gray-500">
        <span>{project.type}</span>
        <span>{new Date(project.updated_at).toLocaleDateString()}</span>
      </div>
    </Card>
  );
}
```

### Système d'Auth avec Logto (packages/auth/src/index.js)
```javascript
import { LogtoProvider, useLogto } from '@logto/react';
import { createContext, useContext, useEffect, useState } from 'react';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  return (
    <LogtoProvider
      config={{
        endpoint: process.env.REACT_APP_LOGTO_ENDPOINT,
        appId: process.env.REACT_APP_LOGTO_APP_ID,
        scopes: ['read:user', 'read:subscription']
      }}
    >
      <AuthWrapper>{children}</AuthWrapper>
    </LogtoProvider>
  );
}

function AuthWrapper({ children }) {
  const { isAuthenticated, getAccessToken, fetchUserInfo, signIn, signOut } = useLogto();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initAuth = async () => {
      if (isAuthenticated) {
        try {
          const userInfo = await fetchUserInfo();
          const token = await getAccessToken();
          
          // Récupérer les infos complètes utilisateur depuis notre API
          const response = await fetch('/api/user/profile', {
            headers: { Authorization: `Bearer ${token}` }
          });
          const userData = await response.json();
          
          setUser({ ...userInfo, ...userData });
        } catch (error) {
          console.error('Erreur auth:', error);
        }
      }
      setLoading(false);
    };

    initAuth();
  }, [isAuthenticated]);

  return (
    <AuthContext.Provider 
      value={{ 
        user, 
        loading, 
        isAuthenticated, 
        signIn, 
        signOut,
        getAccessToken 
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

// Plugin Fastify pour l'auth
export function logtoPlugin(fastify, options) {
  fastify.decorateRequest('user', null);
  
  fastify.addHook('preHandler', async (request, reply) => {
    const authHeader = request.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      
      try {
        // Vérifier le token avec Logto
        const response = await fetch(`${process.env.LOGTO_ENDPOINT}/oidc/token/introspection`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({
            token,
            client_id: process.env.LOGTO_APP_ID,
            client_secret: process.env.LOGTO_APP_SECRET
          })
        });
        
        const tokenInfo = await response.json();
        if (tokenInfo.active) {
          // Récupérer l'utilisateur depuis SurrealDB
          const user = await db.select('users', tokenInfo.sub);
          request.user = user[0];
        }
      } catch (error) {
        console.error('Erreur vérification token:', error);
      }
    }
  });
}
```

## Gestion des Abonnements et Paiements

### Service Billing (apps/api/src/services/billing.js)
```javascript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export class BillingService {
  constructor() {
    this.plans = {
      starter: {
        price_id: 'price_starter_monthly',
        credits: 10,
        price: 19
      },
      pro: {
        price_id: 'price_pro_monthly', 
        credits: 50,
        price: 49
      },
      enterprise: {
        price_id: 'price_enterprise_monthly',
        credits: 200,
        price: 149
      }
    };
  }

  async createSubscription(userId, planId) {
    const user = await db.select('users', userId);
    const plan = this.plans[planId];
    
    if (!plan) throw new Error('Plan invalide');

    // Créer customer Stripe si nécessaire
    let customerId = user[0].stripe_customer_id;
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user[0].email,
        name: user[0].name,
        metadata: { user_id: userId }
      });
      customerId = customer.id;
      
      await db.update('users', userId, {
        stripe_customer_id: customerId
      });
    }

    // Créer la souscription
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: plan.price_id }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent']
    });

    // Sauvegarder en base
    await db.create('subscriptions', {
      user: userId,
      stripe_subscription_id: subscription.id,
      plan: planId,
      status: subscription.status,
      current_period_start: new Date(subscription.current_period_start * 1000),
      current_period_end: new Date(subscription.current_period_end * 1000),
      credits_remaining: plan.credits
    });

    return {
      subscription_id: subscription.id,
      client_secret: subscription.latest_invoice.payment_intent.client_secret
    };
  }

  async handleWebhook(event) {
    switch (event.type) {
      case 'invoice.payment_succeeded':
        await this.handlePaymentSucceeded(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionCanceled(event.data.object);
        break;
    }
  }

  async handlePaymentSucceeded(invoice) {
    const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
    const customerId = subscription.customer;
    
    // Trouver l'utilisateur
    const users = await db.query('SELECT * FROM users WHERE stripe_customer_id = $1', [customerId]);
    if (users.length === 0) return;
    
    const user = users[0];
    
    // Renouveler les crédits
    const planName = Object.keys(this.plans).find(
      plan => this.plans[plan].price_id === subscription.items.data[0].price.id
    );
    
    if (planName) {
      await db.update('subscriptions', user.subscription.id, {
        credits_remaining: this.plans[planName].credits,
        current_period_start: new Date(subscription.current_period_start * 1000),
        current_period_end: new Date(subscription.current_period_end * 1000),
        status: subscription.status
      });
    }
  }

  async consumeCredits(userId, amount = 1) {
    const user = await db.select('users', userId);
    const subscription = user[0].subscription;
    
    if (!subscription || subscription.credits_remaining < amount) {
      throw new Error('Crédits insuffisants');
    }
    
    await db.update('subscriptions', subscription.id, {
      credits_remaining: subscription.credits_remaining - amount
    });
    
    return subscription.credits_remaining - amount;
  }
}
```

## Configuration Docker et Déploiement

### docker-compose.yml
```yaml
version: '3.8'

services:
  # Base de données SurrealDB
  surrealdb:
    image: surrealdb/surrealdb:latest
    ports:
      - "8000:8000"
    command: start --log trace --user root --pass root memory
    volumes:
      - surrealdb_data:/data
    environment:
      - SURREAL_USER=root
      - SURREAL_PASS=root

  # Redis pour les queues
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # API Gateway
  api:
    build:
      context: .
      dockerfile: apps/api/Dockerfile
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=ws://surrealdb:8000/rpc
      - REDIS_URL=redis://redis:6379
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN}
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - LOGTO_ENDPOINT=${LOGTO_ENDPOINT}
      - LOGTO_APP_SECRET=${LOGTO_APP_SECRET}
    depends_on:
      - surrealdb
      - redis

  # Service Ebook
  ebook-service:
    build:
      context: .
      dockerfile: apps/ebook-service/Dockerfile
    environment:
      - DATABASE_URL=ws://surrealdb:8000/rpc
      - REDIS_URL=redis://redis:6379
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN}
    depends_on:
      - surrealdb
      - redis

  # Frontend
  web:
    build:
      context: .
      dockerfile: apps/web/Dockerfile
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:3001
      - REACT_APP_LOGTO_ENDPOINT=${LOGTO_ENDPOINT}
      - REACT_APP_LOGTO_APP_ID=${LOGTO_APP_ID}
    depends_on:
      - api

  # Worker pour tâches async
  worker:
    build:
      context: .
      dockerfile: apps/worker/Dockerfile
    environment:
      - DATABASE_URL=ws://surrealdb:8000/rpc
      - REDIS_URL=redis://redis:6379
      - CLAUDE_API_KEY=${CLAUDE_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REPLICATE_API_TOKEN=${REPLICATE_API_TOKEN}
    depends_on:
      - surrealdb
      - redis

volumes:
  surrealdb_data:
  redis_data:
```

### Dockerfile API (apps/api/Dockerfile)
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copier package.json et installer les dépendances
COPY package*.json ./
COPY apps/api/package*.json ./apps/api/
COPY packages/ ./packages/

RUN npm ci --only=production

# Copier le code source
COPY apps/api/ ./apps/api/
COPY packages/ ./packages/

WORKDIR /app/apps/api

EXPOSE 3001

CMD ["node", "src/index.js"]
```

### Configuration Kubernetes (k8s/)
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: creative-ai

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: creative-ai
data:
  DATABASE_URL: "ws://surrealdb:8000/rpc"
  REDIS_URL: "redis://redis:6379"

---
# k8s/deployment-api.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: creative-ai
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: creative-ai/api:latest
        ports:
        - containerPort: 3001
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: api-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

---
# k8s/service-api.yaml
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: creative-ai
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 3001
  type: ClusterIP

---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: creative-ai-ingress
  namespace: creative-ai
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - api.creative-ai.com
    secretName: creative-ai-tls
  rules:
  - host: api.creative-ai.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
```

## Scripts d'Automatisation

### Package.json Principal
```json
{
  "name": "creative-ai-suite",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "type-check": "turbo run type-check",
    "db:setup": "node scripts/setup-database.js",
    "db:seed": "node scripts/seed-database.js",
    "docker:build": "docker-compose build",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "deploy:staging": "npm run build && ./scripts/deploy-staging.sh",
    "deploy:prod": "npm run build && ./scripts/deploy-prod.sh"
  },
  "devDependencies": {
    "turbo": "^1.10.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}
```

### Script Setup Database (scripts/setup-database.js)
```javascript
#!/usr/bin/env node

import { Surreal } from 'surrealdb.js';

const db = new Surreal();

async function setupDatabase() {
  try {
    await db.connect('ws://localhost:8000/rpc');
    await db.signin({ user: 'root', pass: 'root' });
    await db.use({ ns: 'creative_ai', db: 'main' });

    console.log('🗃️  Configuration de la base de données...');

    // Exécuter les schémas SurrealDB
    await db.query(`
      -- Utilisateurs
      DEFINE TABLE users SCHEMAFULL;
      DEFINE FIELD email ON users TYPE string;
      DEFINE FIELD name ON users TYPE string;
      DEFINE FIELD avatar ON users TYPE string;
      DEFINE FIELD stripe_customer_id ON users TYPE string;
      DEFINE FIELD subscription ON users TYPE record(subscriptions);
      DEFINE FIELD preferences ON users TYPE object;
      DEFINE FIELD created_at ON users TYPE datetime DEFAULT time::now();
      DEFINE INDEX email_idx ON users COLUMNS email UNIQUE;

      -- Abonnements
      DEFINE TABLE subscriptions SCHEMAFULL;
      DEFINE FIELD user ON subscriptions TYPE record(users);
      DEFINE FIELD stripe_subscription_id ON subscriptions TYPE string;
      DEFINE FIELD plan ON subscriptions TYPE string;
      DEFINE FIELD status ON subscriptions TYPE string;
      DEFINE FIELD current_period_start ON subscriptions TYPE datetime;
      DEFINE FIELD current_period_end ON subscriptions TYPE datetime;
      DEFINE FIELD credits_remaining ON subscriptions TYPE number DEFAULT 0;

      -- Projets
      DEFINE TABLE projects SCHEMAFULL;
      DEFINE FIELD user ON projects TYPE record(users);
      DEFINE FIELD title ON projects TYPE string;
      DEFINE FIELD type ON projects TYPE string;
      DEFINE FIELD status ON projects TYPE string;
      DEFINE FIELD content ON projects TYPE object;
      DEFINE FIELD settings ON projects TYPE object;
      DEFINE FIELD metadata ON projects TYPE object;
      DEFINE FIELD created_at ON projects TYPE datetime DEFAULT time::now();
      DEFINE FIELD updated_at ON projects TYPE datetime DEFAULT time::now();

      -- Ebooks
      DEFINE TABLE ebooks SCHEMAFULL;
      DEFINE FIELD project ON ebooks TYPE record(projects);
      DEFINE FIELD genre ON ebooks TYPE string;
      DEFINE FIELD target_length ON ebooks TYPE number;
      DEFINE FIELD chapters ON ebooks TYPE array<object>;
      DEFINE FIELD cover_image ON ebooks TYPE string;
      DEFINE FIELD formats ON ebooks TYPE object;
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

      -- Tâches
      DEFINE TABLE tasks SCHEMAFULL;
      DEFINE FIELD user ON tasks TYPE record(users);
      DEFINE FIELD project ON tasks TYPE record(projects);
      DEFINE FIELD type ON tasks TYPE string;
      DEFINE FIELD status ON tasks TYPE string;
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
    `);

    console.log('✅ Base de données configurée avec succès!');
    
  } catch (error) {
    console.error('❌ Erreur:', error);
    process.exit(1);
  } finally {
    await db.close();
  }
}

setupDatabase();
```

### Script Déploiement (scripts/deploy-prod.sh)
```bash
#!/bin/bash

set -e

echo "🚀 Déploiement en production..."

# Build des images Docker
echo "📦 Construction des images..."
docker build -t creative-ai/api:latest -f apps/api/Dockerfile .
docker build -t creative-ai/web:latest -f apps/web/Dockerfile .
docker build -t creative-ai/ebook-service:latest -f apps/ebook-service/Dockerfile .

# Tag et push vers le registry
echo "📤 Push vers le registry..."
docker tag creative-ai/api:latest registry.creative-ai.com/api:latest
docker tag creative-ai/web:latest registry.creative-ai.com/web:latest
docker tag creative-ai/ebook-service:latest registry.creative-ai.com/ebook-service:latest

docker push registry.creative-ai.com/api:latest
docker push registry.creative-ai.com/web:latest
docker push registry.creative-ai.com/ebook-service:latest

# Déploiement Kubernetes
echo "☸️  Déploiement Kubernetes..."
kubectl apply -f k8s/
kubectl rollout restart deployment/api -n creative-ai
kubectl rollout restart deployment/web -n creative-ai
kubectl rollout restart deployment/ebook-service -n creative-ai

# Attendre que les déploiements soient prêts
kubectl rollout status deployment/api -n creative-ai
kubectl rollout status deployment/web -n creative-ai
kubectl rollout status deployment/ebook-service -n creative-ai

echo "✅ Déploiement terminé avec succès!"
```

## Configuration de Monitoring

### Monitoring avec Grafana (monitoring/docker-compose.yml)
```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3030:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/local-config.yaml
      - loki_data:/loki

  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./promtail-config.yml:/etc/promtail/config.yml
      - /var/log:/var/log:ro

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

## Tests Automatisés

### Tests E2E avec Playwright (tests/e2e/ebook-creation.spec.js)
```javascript
import { test, expect } from '@playwright/test';

test.describe('Création d\'ebook', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('[data-testid=email]', 'test@example.com');
    await page.fill('[data-testid=password]', 'password');
    await page.click('[data-testid=login-button]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('Créer un ebook complet', async ({ page }) => {
    // Aller à la page de création
    await page.goto('/create');
    
    // Remplir le formulaire
    await page.fill('[data-testid=title]', 'Mon Premier