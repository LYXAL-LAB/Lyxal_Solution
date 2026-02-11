import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import AdmZip from 'adm-zip';

// Gestion des chemins
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BASE_DIR = path.resolve(__dirname, '..');
const CONFIG_FILE = path.join(BASE_DIR, 'packs.config.json');

async function main() {
    // Récupérer les arguments (le nom du pack)
    const args = process.argv.slice(2);
    const targetPack = args[0];

    if (!targetPack) {
        console.error('❌ Usage: bun scripts/importPack.ts <pack_name> (ou "all")');
        process.exit(1);
    }

    // Charger la config
    if (!fs.existsSync(CONFIG_FILE)) {
        console.error('❌ Fichier de configuration packs.config.json introuvable.');
        process.exit(1);
    }
    const config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));

    // Déterminer quels packs traiter
    const packsToProcess = targetPack === 'all' ? Object.keys(config) : [targetPack];

    for (const packName of packsToProcess) {
        const packConfig = config[packName];
        if (!packConfig) {
            console.error(`⚠️  Pack "${packName}" non trouvé dans la configuration.`);
            continue;
        }
        await processPack(packName, packConfig);
    }
}

async function processPack(name: string, config: any) {
    console.log(`\n🚀 Traitement du pack : ${name}`);
    const TARGET_DIR = path.join(BASE_DIR, 'packs', name, 'svg');
    const TEMP_ZIP = path.join(BASE_DIR, `temp_${name}.zip`);

    // 1. Préparer le dossier
    if (fs.existsSync(TARGET_DIR)) {
        console.log('   Note: Le dossier cible existe déjà, il sera complété/écrasé.');
    } else {
        fs.mkdirSync(TARGET_DIR, { recursive: true });
    }

    // 2. Télécharger
    console.log(`⬇️  Téléchargement de ${config.url}...`);
    try {
        const response = await fetch(config.url, {
            headers: { "User-Agent": "Lyxal-Importer" }
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        
        const buffer = Buffer.from(await response.arrayBuffer());
        fs.writeFileSync(TEMP_ZIP, buffer);
    } catch (e) {
        console.error(`❌ Erreur téléchargement ${name}:`, e);
        return;
    }

    // 3. Extraire et Filtrer
    console.log('📦 Extraction...');
    try {
        const zip = new AdmZip(TEMP_ZIP);
        const zipEntries = zip.getEntries();
        const regex = new RegExp(config.filter);
        let count = 0;

        zipEntries.forEach((entry) => {
            if (!entry.isDirectory && regex.test(entry.entryName)) {
                let fileName = path.basename(entry.entryName);
                
                // Transformation optionnelle du nom (ex: lowercase)
                if (config.transformName === 'lowercase') {
                    fileName = fileName.toLowerCase();
                }

                fs.writeFileSync(path.join(TARGET_DIR, fileName), entry.getData());
                count++;
            }
        });
        console.log(`✅ ${count} icônes extraites pour ${name}.`);

    } catch (e) {
        console.error(`❌ Erreur extraction ${name}:`, e);
    } finally {
        if (fs.existsSync(TEMP_ZIP)) fs.unlinkSync(TEMP_ZIP);
    }
}

main().catch(console.error);