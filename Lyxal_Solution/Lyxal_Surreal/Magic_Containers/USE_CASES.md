# 🎯 Use Cases - Magic Containers pour Lyxal

Tous les cas d'usage Lyxal avec code complet, Dockerfile et CI/CD.

---

## 📋 Liste des Services

1. [Lyxal Mail Worker](#1-lyxal-mail-worker-) - Envoi d'emails SMTP
2. [Icons Uploader](#2-icons-uploader-) - Upload automatique icônes
3. [Image Processor](#3-image-processor-) - Resize/optimize images
4. [PDF Generator](#4-pdf-generator-) - Génération factures/devis
5. [Analytics Worker](#5-analytics-worker-) - Aggregation données
6. [Backup Service](#6-backup-service-) - Backups automatiques
7. [Webhooks Handler](#7-webhooks-handler-) - Gestion webhooks

---

## 1. Lyxal Mail Worker ✉️

### Description

Worker Go qui écoute les emails à envoyer via LIVE QUERY SurrealDB et les envoie via SMTP.

### Stack

- **Language** : Go 1.21+
- **Dependencies** : SurrealDB.go, gomail
- **Resources** : 0.3 vCPU, 256 MB RAM
- **Coût** : ~$1/mois

### Documentation Complète

👉 **Voir [../Lyxal_Mail/WORKER.md](../Lyxal_Mail/WORKER.md)** pour :
- Code complet
- Dockerfile
- Déploiement
- Configuration

---

## 2. Icons Uploader 🎨

### Description

Script Node.js qui clone les repos GitHub d'icônes SVG, les optimise et les upload sur Bunny Storage. Run automatique quotidien.

### Stack

- **Language** : Node.js 20+
- **Dependencies** : node-fetch, node-cron, express
- **Resources** : 0.1 vCPU, 128 MB RAM
- **Coût** : ~$0.03/mois

### Documentation Complète

👉 **Voir [../studio/ICONS.md](../studio/ICONS.md)** pour :
- Script complet
- Dockerfile
- Déploiement Magic Containers
- GitHub Actions CI/CD

---

## 3. Image Processor 🖼️

### Description

Service qui resize, optimise et convertit les images uploadées par les users Lyxal. Expose une API HTTP pour traitement à la demande.

### Stack

- **Language** : Node.js + Sharp / Rust + image-rs
- **Resources** : 0.5-1.0 vCPU, 512 MB RAM
- **Coût** : ~$3-5/mois

### Code Complet

#### Structure

```
image-processor/
├── Dockerfile
├── package.json
├── src/
│   ├── index.js
│   ├── processor.js
│   └── storage.js
└── .github/
    └── workflows/
        └── deploy.yml
```

#### src/index.js

```javascript
const express = require('express');
const multer = require('multer');
const { processImage } = require('./processor');
const { uploadToStorage } = require('./storage');

const app = express();
const upload = multer({ storage: multer.memoryStorage() });

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'image-processor' });
});

// Process image
app.post('/process', upload.single('image'), async (req, res) => {
  try {
    const { width, height, format, quality } = req.query;
    
    // Valider l'image
    if (!req.file) {
      return res.status(400).json({ error: 'No image provided' });
    }
    
    console.log(JSON.stringify({
      level: 'info',
      message: 'Processing image',
      originalSize: req.file.size,
      format: format || 'auto'
    }));
    
    // Traiter l'image
    const processed = await processImage(req.file.buffer, {
      width: parseInt(width) || null,
      height: parseInt(height) || null,
      format: format || 'webp',
      quality: parseInt(quality) || 80
    });
    
    // Upload sur Bunny Storage
    const filename = `processed/${Date.now()}.${processed.format}`;
    const url = await uploadToStorage(processed.buffer, filename);
    
    console.log(JSON.stringify({
      level: 'info',
      message: 'Image processed',
      originalSize: req.file.size,
      processedSize: processed.buffer.length,
      compression: ((1 - processed.buffer.length / req.file.size) * 100).toFixed(2) + '%',
      url
    }));
    
    res.json({
      success: true,
      url,
      originalSize: req.file.size,
      processedSize: processed.buffer.length,
      format: processed.format
    });
    
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      message: 'Image processing failed',
      error: error.message,
      stack: error.stack
    }));
    
    res.status(500).json({ 
      error: 'Processing failed',
      message: error.message 
    });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(JSON.stringify({
    level: 'info',
    message: 'Image Processor started',
    port: PORT
  }));
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down gracefully...');
  process.exit(0);
});
```

#### src/processor.js

```javascript
const sharp = require('sharp');

async function processImage(buffer, options) {
  const { width, height, format, quality } = options;
  
  let pipeline = sharp(buffer);
  
  // Resize si dimensions spécifiées
  if (width || height) {
    pipeline = pipeline.resize(width, height, {
      fit: 'inside',
      withoutEnlargement: true
    });
  }
  
  // Convert format
  switch (format) {
    case 'webp':
      pipeline = pipeline.webp({ quality });
      break;
    case 'jpeg':
    case 'jpg':
      pipeline = pipeline.jpeg({ quality, mozjpeg: true });
      break;
    case 'png':
      pipeline = pipeline.png({ 
        quality, 
        compressionLevel: 9,
        adaptiveFiltering: true
      });
      break;
    case 'avif':
      pipeline = pipeline.avif({ quality });
      break;
  }
  
  // Optimize
  pipeline = pipeline.rotate(); // Auto-rotate based on EXIF
  
  const processedBuffer = await pipeline.toBuffer();
  
  return {
    buffer: processedBuffer,
    format
  };
}

module.exports = { processImage };
```

#### src/storage.js

```javascript
const fetch = require('node-fetch');

const BUNNY_STORAGE_ZONE = process.env.BUNNY_STORAGE_ZONE;
const BUNNY_API_KEY = process.env.BUNNY_API_KEY;
const BUNNY_CDN_URL = process.env.BUNNY_CDN_URL;

async function uploadToStorage(buffer, filename) {
  const url = `https://storage.bunnycdn.com/${BUNNY_STORAGE_ZONE}/${filename}`;
  
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'AccessKey': BUNNY_API_KEY,
      'Content-Type': 'application/octet-stream'
    },
    body: buffer
  });
  
  if (!response.ok) {
    throw new Error(`Upload failed: ${response.statusText}`);
  }
  
  return `${BUNNY_CDN_URL}/${filename}`;
}

module.exports = { uploadToStorage };
```

#### Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source
COPY src/ ./src/

# Expose port
EXPOSE 3000

# Start
CMD ["node", "src/index.js"]
```

#### package.json

```json
{
  "name": "lyxal-image-processor",
  "version": "1.0.0",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "multer": "^1.4.5-lts.1",
    "sharp": "^0.33.2",
    "node-fetch": "^3.3.2"
  }
}
```

#### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Image Processor

on:
  push:
    branches: [main]
    paths:
      - 'image-processor/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker Image
        run: |
          cd image-processor
          docker build -t lyxal-image-processor:${{ github.sha }} .
      
      - name: Push to Docker Hub
        run: |
          echo "${{ secrets.DOCKERHUB_TOKEN }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin
          docker tag lyxal-image-processor:${{ github.sha }} lyxal/image-processor:latest
          docker push lyxal/image-processor:latest
      
      - name: Deploy to Magic Containers
        run: |
          curl -X POST "https://api.bunny.net/containers/deploy" \
            -H "AccessKey: ${{ secrets.BUNNY_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{
              "name": "lyxal-image-processor",
              "image": "lyxal/image-processor:latest",
              "port": 3000,
              "env": {
                "BUNNY_STORAGE_ZONE": "${{ secrets.BUNNY_STORAGE_ZONE }}",
                "BUNNY_API_KEY": "${{ secrets.BUNNY_API_KEY }}",
                "BUNNY_CDN_URL": "${{ secrets.BUNNY_CDN_URL }}"
              }
            }'
```

### Utilisation

```bash
# Upload et traiter une image
curl -X POST https://image-processor.lyxal.b-cdn.net/process \
  -F "image=@photo.jpg" \
  -F "width=800" \
  -F "format=webp" \
  -F "quality=80"

# Réponse
{
  "success": true,
  "url": "https://cdn.lyxal.com/processed/1706097600000.webp",
  "originalSize": 2048576,
  "processedSize": 142336,
  "format": "webp"
}
```

---

## 4. PDF Generator 📄

### Description

Service qui génère des PDFs (factures, devis, rapports) à partir de templates HTML.

### Stack

- **Language** : Node.js + Puppeteer / Go + wkhtmltopdf
- **Resources** : 0.5-1.0 vCPU, 512 MB - 1 GB RAM
- **Coût** : ~$2-4/mois

### Code Complet (Node.js + Puppeteer)

#### Structure

```
pdf-generator/
├── Dockerfile
├── package.json
├── src/
│   ├── index.js
│   ├── generator.js
│   ├── templates/
│   │   ├── invoice.html
│   │   └── quote.html
│   └── storage.js
```

#### src/index.js

```javascript
const express = require('express');
const { generatePDF } = require('./generator');
const { uploadToStorage } = require('./storage');

const app = express();
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'pdf-generator' });
});

// Generate PDF
app.post('/generate', async (req, res) => {
  try {
    const { template, data, filename } = req.body;
    
    if (!template || !data) {
      return res.status(400).json({ error: 'Missing template or data' });
    }
    
    console.log(JSON.stringify({
      level: 'info',
      message: 'Generating PDF',
      template,
      filename: filename || 'document.pdf'
    }));
    
    // Générer le PDF
    const pdfBuffer = await generatePDF(template, data);
    
    // Upload sur Bunny Storage
    const pdfFilename = filename || `generated/${Date.now()}.pdf`;
    const url = await uploadToStorage(pdfBuffer, pdfFilename);
    
    console.log(JSON.stringify({
      level: 'info',
      message: 'PDF generated',
      size: pdfBuffer.length,
      url
    }));
    
    res.json({
      success: true,
      url,
      size: pdfBuffer.length
    });
    
  } catch (error) {
    console.error(JSON.stringify({
      level: 'error',
      message: 'PDF generation failed',
      error: error.message
    }));
    
    res.status(500).json({ 
      error: 'Generation failed',
      message: error.message 
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(JSON.stringify({
    level: 'info',
    message: 'PDF Generator started',
    port: PORT
  }));
});
```

#### src/generator.js

```javascript
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');
const Handlebars = require('handlebars');

let browser;

// Init Puppeteer (réutiliser l'instance)
async function initBrowser() {
  if (!browser) {
    browser = await puppeteer.launch({
      headless: 'new',
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage'
      ]
    });
  }
  return browser;
}

async function generatePDF(templateName, data) {
  const br = await initBrowser();
  
  // Charger le template HTML
  const templatePath = path.join(__dirname, 'templates', `${templateName}.html`);
  const templateHTML = fs.readFileSync(templatePath, 'utf-8');
  
  // Compiler avec Handlebars
  const template = Handlebars.compile(templateHTML);
  const html = template(data);
  
  // Générer le PDF
  const page = await br.newPage();
  await page.setContent(html, { waitUntil: 'networkidle0' });
  
  const pdf = await page.pdf({
    format: 'A4',
    printBackground: true,
    margin: {
      top: '20mm',
      right: '10mm',
      bottom: '20mm',
      left: '10mm'
    }
  });
  
  await page.close();
  
  return pdf;
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  if (browser) {
    await browser.close();
  }
  process.exit(0);
});

module.exports = { generatePDF };
```

#### src/templates/invoice.html

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body {
      font-family: 'Helvetica', Arial, sans-serif;
      margin: 0;
      padding: 20px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 40px;
    }
    .logo {
      font-size: 24px;
      font-weight: bold;
      color: #3B82F6;
    }
    .invoice-info {
      text-align: right;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #E5E7EB;
    }
    th {
      background-color: #F9FAFB;
      font-weight: 600;
    }
    .total {
      text-align: right;
      margin-top: 20px;
      font-size: 20px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="header">
    <div class="logo">{{company_name}}</div>
    <div class="invoice-info">
      <strong>Facture #{{invoice_number}}</strong><br>
      Date: {{date}}<br>
      Échéance: {{due_date}}
    </div>
  </div>
  
  <div class="client">
    <strong>Client:</strong><br>
    {{client_name}}<br>
    {{client_address}}
  </div>
  
  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th>Quantité</th>
        <th>Prix unitaire</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      {{#each items}}
      <tr>
        <td>{{description}}</td>
        <td>{{quantity}}</td>
        <td>{{unit_price}} €</td>
        <td>{{total}} €</td>
      </tr>
      {{/each}}
    </tbody>
  </table>
  
  <div class="total">
    Total: {{total_amount}} €
  </div>
</body>
</html>
```

#### Dockerfile

```dockerfile
FROM node:20

# Install Puppeteer dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src/ ./src/

EXPOSE 3000

CMD ["node", "src/index.js"]
```

### Utilisation

```bash
# Générer une facture
curl -X POST https://pdf-generator.lyxal.b-cdn.net/generate \
  -H "Content-Type: application/json" \
  -d '{
    "template": "invoice",
    "filename": "facture-2024-001.pdf",
    "data": {
      "company_name": "Lyxal SAS",
      "invoice_number": "2024-001",
      "date": "2024-01-24",
      "due_date": "2024-02-24",
      "client_name": "BatiPro",
      "client_address": "123 Rue Example, Paris",
      "items": [
        {
          "description": "Abonnement mensuel",
          "quantity": 1,
          "unit_price": 99,
          "total": 99
        }
      ],
      "total_amount": 99
    }
  }'

# Réponse
{
  "success": true,
  "url": "https://cdn.lyxal.com/generated/facture-2024-001.pdf",
  "size": 45678
}
```

---

## 💰 Coûts Estimés par Service

| Service | CPU/mois | RAM/mois | Storage | Traffic | **Total** |
|---------|----------|----------|---------|---------|-----------|
| Mail Worker | $0.30 | $0.60 | $0.01 | $0.05 | **$1** |
| Icons Uploader | $0.02 | $0.01 | $0.01 | $0.00 | **$0.03** |
| Image Processor | $1.50 | $2.00 | $0.10 | $0.50 | **$4** |
| PDF Generator | $1.00 | $1.50 | $0.05 | $0.30 | **$3** |

**Total : ~$8/mois pour 4 services globaux !** 💸

---

## 🚀 Prochaines Étapes

1. **[DEPLOYMENT.md](./DEPLOYMENT.md)** → Guide de déploiement complet
2. **[PRICING.md](./PRICING.md)** → Calcul détaillé des coûts
3. Déployer votre premier service !

---

**Lyxal Magic Containers : Des Services Globaux pour Quelques Centimes** 🎩💰

