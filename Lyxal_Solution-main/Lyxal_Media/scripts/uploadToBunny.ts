import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Surreal } from 'surrealdb';

// Config connexion DB (pour récupérer la config Bunny)
const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const BASE_DIR = path.resolve(__dirname, '..');
const NORMALIZED_DIR = path.join(BASE_DIR, 'normalized', 'svg');

async function main() {
    console.log('🚀 Démarrage de l\'upload vers Bunny Storage (Config via DB)...');

    // 1. Connexion DB
    const db = new Surreal();
    let bunnyConfig: any = null;

    try {
        console.log('🔌 Connexion à SurrealDB...');
        await db.connect(DB_CONFIG.endpoint, {
            auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
        });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
        
        // 2. Récupération config
        console.log('📥 Lecture de la configuration svg_config...');
        // On sélectionne toute la table car select('id') peut être capricieux selon les versions
        const results = await db.select<Record<string, any>>('svg_config');
        
        // On cherche celui qui a l'ID svg_config:main ou on prend le premier
        const config = Array.isArray(results) 
            ? results.find((r: any) => r.id === 'svg_config:main' || r.id?.toString() === 'svg_config:main') || results[0]
            : results;
        
        if (!config || !config.bunny) {
            throw new Error('Configuration Bunny introuvable dans la table svg_config');
        }
        bunnyConfig = config.bunny;
        console.log(`✅ Config trouvée pour zone: ${bunnyConfig.storage_zone}`);

    } catch (e) {
        console.error('❌ Erreur DB:', e);
        return;
    } finally {
        await db.close();
    }

    // 3. Préparation Upload
    const STORAGE_NAME = bunnyConfig.storage_zone;
    const STORAGE_PASSWORD = bunnyConfig.api_key;
    const STORAGE_REGION = bunnyConfig.region || 'storage.bunnycdn.com';

    // URL de base de l'API Bunny
    const BASE_API_URL = `https://${STORAGE_REGION}/${STORAGE_NAME}/svg`;

    if (!fs.existsSync(NORMALIZED_DIR)) {
        console.error(`❌ Dossier source introuvable : ${NORMALIZED_DIR}`);
        return;
    }

    const packs = fs.readdirSync(NORMALIZED_DIR).filter(item => {
        return fs.statSync(path.join(NORMALIZED_DIR, item)).isDirectory();
    });

    // 4. Boucle d'upload
    for (const pack of packs) {
        const packDir = path.join(NORMALIZED_DIR, pack);
        const files = fs.readdirSync(packDir).filter(f => f.endsWith('.svg'));
        
        console.log(`☁️  Upload du pack ${pack} (${files.length} fichiers)...`);

        const BATCH_SIZE = 20;
        let batch: string[] = [];
        
        for (const file of files) {
            batch.push(file);
            if (batch.length >= BATCH_SIZE) {
                await uploadBatch(pack, batch, packDir, BASE_API_URL, STORAGE_PASSWORD);
                batch = [];
            }
        }
        if (batch.length > 0) {
            await uploadBatch(pack, batch, packDir, BASE_API_URL, STORAGE_PASSWORD);
        }
    }

    console.log('\n✅ Upload terminé avec succès !');
}

async function uploadBatch(pack: string, files: string[], localDir: string, baseUrl: string, apiKey: string) {
    const promises = files.map(async (file) => {
        const localPath = path.join(localDir, file);
        const content = fs.readFileSync(localPath);
        const targetUrl = `${baseUrl}/${pack}/${file}`;

        try {
            const response = await fetch(targetUrl, {
                method: 'PUT',
                headers: {
                    'AccessKey': apiKey,
                    'Content-Type': 'image/svg+xml'
                },
                body: content as unknown as BodyInit
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }
            process.stdout.write('.');
        } catch (error) {
            console.error(`\n❌ Erreur upload ${pack}/${file}:`, error);
        }
    });

    await Promise.all(promises);
}

main().catch(console.error);
