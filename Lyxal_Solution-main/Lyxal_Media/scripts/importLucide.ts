import fs from 'node:fs';
import path from 'node:path';
import AdmZip from 'adm-zip';

// URL du zip de Lucide (branche main)
const LUCIDE_REPO_ZIP = 'https://github.com/lucide-icons/lucide/archive/refs/heads/main.zip';

// On calcule les chemins par rapport au fichier script pour être sûr
// Le script est dans Lyxal_SVG/scripts/
// On veut aller dans Lyxal_SVG/packs/lucide/svg/
const BASE_DIR = path.resolve(import.meta.dir, '..'); // Remonte à Lyxal_SVG/
const TARGET_DIR = path.join(BASE_DIR, 'packs', 'lucide', 'svg');
const TEMP_ZIP = path.join(BASE_DIR, 'temp_lucide.zip');

async function main() {
  console.log(`📂 Dossier cible : ${TARGET_DIR}`);
  console.log('🚀 Démarrage de l\'import Lucide...');

  // 1. Créer le dossier cible s'il n'existe pas
  if (!fs.existsSync(TARGET_DIR)) {
    console.log('Creating directory...');
    fs.mkdirSync(TARGET_DIR, { recursive: true });
  }

  // 2. Télécharger le ZIP
  console.log(`⬇️  Téléchargement de ${LUCIDE_REPO_ZIP}...`);
  const response = await fetch(LUCIDE_REPO_ZIP, {
      headers: {
          "User-Agent": "Lyxal-Importer/1.0"
      }
  });
  if (!response.ok) throw new Error(`Erreur téléchargement: ${response.statusText}`);
  
  const arrayBuffer = await response.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  fs.writeFileSync(TEMP_ZIP, buffer);
  console.log('✅ ZIP téléchargé.');

  // 3. Extraire les icônes
  console.log('📦 Extraction des fichiers SVG...');
  try {
    const zip = new AdmZip(TEMP_ZIP);
    const zipEntries = zip.getEntries();
    
    let count = 0;

    zipEntries.forEach((entry) => {
      // Le chemin dans le zip officiel ressemble à : lucide-main/icons/nom-icone.svg
      if (entry.entryName.match(/icons\/.*\.svg$/) && !entry.isDirectory) {
        const fileName = path.basename(entry.entryName);
        const targetPath = path.join(TARGET_DIR, fileName);
        
        // On écrit le fichier
        fs.writeFileSync(targetPath, entry.getData());
        count++;
        if (count % 100 === 0) process.stdout.write('.');
      }
    });
    console.log('\n');
    console.log(`✅ Terminé ! ${count} icônes Lucide importées dans ${TARGET_DIR}`);

  } catch (err) {
    console.error('❌ Erreur lors de l\'extraction ZIP:', err);
  } finally {
     // 4. Nettoyage
    if (fs.existsSync(TEMP_ZIP)) {
        fs.unlinkSync(TEMP_ZIP);
        console.log('🧹 Fichier temporaire nettoyé.');
    }
  }
}

main().catch(console.error);
