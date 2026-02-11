import fs from 'node:fs';
import path from 'node:path';
import { optimize, loadConfig } from 'svgo';

// Chemins relatifs à la racine du module
const BASE_DIR = path.resolve(__dirname, '..');
const PACKS_DIR = path.join(BASE_DIR, 'packs');
const NORMALIZED_DIR = path.join(BASE_DIR, 'normalized', 'svg');
const CONFIG_FILE = path.join(BASE_DIR, 'packs.config.json');

// Configuration SVGO de base (Plugins communs)
const basePlugins = [
    'removeDimensions',       
    'removeXMLNS',            
    'preset-default',         
    {
      name: 'removeAttrs',
      params: {
        attrs: '(class|style|data.*)', 
      },
    },
    {
        name: 'addAttributesToSVGElement',
        params: {
            attributes: [
                { viewBox: '0 0 24 24' } 
            ]
        }
    }
];

async function main() {
  console.log('🚀 Démarrage de la normalisation...');

  // Charger la config des packs
  let packsConfig: any = {};
  if (fs.existsSync(CONFIG_FILE)) {
      packsConfig = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
  }

  // 1. Lister les packs disponibles (dossiers dans packs/)
  const packs = fs.readdirSync(PACKS_DIR).filter(item => {
      return fs.statSync(path.join(PACKS_DIR, item)).isDirectory();
  });

  if (packs.length === 0) {
      console.log('⚠️  Aucun pack trouvé dans packs/');
      return;
  }

  console.log(`📦 Packs détectés : ${packs.join(', ')}`);

  let totalCount = 0;

  // 2. Traiter chaque pack
  for (const pack of packs) {
    const sourceDir = path.join(PACKS_DIR, pack, 'svg');
    const targetDir = path.join(NORMALIZED_DIR, pack);

    // Récupérer la config du pack (ou défaut)
    const packConfig = packsConfig[pack] || {};
    const isColor = packConfig.mode === 'color';

    // Construire la config SVGO spécifique
    const plugins = [...basePlugins];
    
    // Si monochrome (défaut), on force currentColor
    if (!isColor) {
        plugins.push({
            name: 'convertColors',
            params: { currentColor: true }
        } as any);
    }

    if (!fs.existsSync(sourceDir)) {
        console.log(`⚠️  Pas de dossier svg pour le pack ${pack}, ignoré.`);
        continue;
    }

    // Créer le dossier de destination
    if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
    }

    const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.svg'));
    console.log(`🔄 Traitement du pack ${pack} (${files.length} icônes) [Mode: ${isColor ? 'Color' : 'Monochrome'}]...`);

    for (const file of files) {
        const filePath = path.join(sourceDir, file);
        const content = fs.readFileSync(filePath, 'utf-8');

        try {
            // Optimisation SVGO
            const result = optimize(content, {
                path: filePath,
                plugins: plugins as any
            });

            if (result.data) {
                fs.writeFileSync(path.join(targetDir, file), result.data);
                totalCount++;
            }
        } catch (err) {
            console.error(`❌ Erreur sur ${pack}/${file}:`, err);
        }
    }
  }

  console.log(`✅ Terminé ! ${totalCount} icônes normalisées dans ${NORMALIZED_DIR}`);
}

main().catch(console.error);
