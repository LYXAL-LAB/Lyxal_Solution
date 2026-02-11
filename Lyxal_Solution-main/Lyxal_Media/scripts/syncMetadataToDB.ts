import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Surreal } from 'surrealdb';

// Config connexion DB
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
const CONFIG_FILE = path.join(BASE_DIR, 'packs.config.json');

async function main() {
    console.log('🚀 Synchronisation des icônes vers SurrealDB...');

    if (!fs.existsSync(NORMALIZED_DIR)) {
        console.error(`❌ Dossier normalized introuvable : ${NORMALIZED_DIR}`);
        return;
    }

    // Charger la config des packs
    let packsConfig: any = {};
    if (fs.existsSync(CONFIG_FILE)) {
        packsConfig = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf-8'));
    } else {
        console.warn('⚠️ Fichier packs.config.json introuvable, les métadonnées des packs seront incomplètes.');
    }

    // 1. Connexion DB
    const db = new Surreal();
    try {
        console.log('🔌 Connexion à SurrealDB...');
        await db.connect(DB_CONFIG.endpoint, {
            auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
        });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
        console.log('✅ Connecté.');
    } catch (e) {
        console.error('❌ Erreur connexion DB:', e);
        return;
    }

    // 2. Scan des packs
    const packs = fs.readdirSync(NORMALIZED_DIR).filter(item => {
        return fs.statSync(path.join(NORMALIZED_DIR, item)).isDirectory();
    });

    console.log(`📦 Packs détectés : ${packs.join(', ')}`);

    for (const pack of packs) {
        const packDir = path.join(NORMALIZED_DIR, pack);
        const files = fs.readdirSync(packDir).filter(f => f.endsWith('.svg'));
        
        console.log(`🔄 Traitement du pack ${pack} (${files.length} icônes)...`);

        // A. Mise à jour de la table icon_pack
        try {
            // Récupérer les métadonnées depuis packs.config.json
            const packMeta = packsConfig[pack] || {};

            // ID: icon_pack:lucide
            const packId = `icon_pack:${pack}`;
            await db.merge(packId, {
                identity: { 
                    name: pack,
                    version: packMeta.version || '0.0.0'
                },
                info: {
                    icon_count: files.length,
                    description: packMeta.description || `Pack ${pack} synchronisé`,
                    license: packMeta.license || 'Unknown',
                    source_url: packMeta.website || packMeta.url || ''
                },
                timestamp: { updated_at: new Date() }
            });
        } catch (e) {
            console.error(`⚠️ Erreur update pack ${pack}:`, e);
        }

        // B. Insertion des icônes (Batch)
        const BATCH_SIZE = 50;
        let batch: any[] = [];
        let totalImported = 0;

        for (const file of files) {
            const filePath = path.join(packDir, file);
            let content = '';
            try {
                content = fs.readFileSync(filePath, 'utf-8');
            } catch (e) { continue; }

            const name = path.basename(file, '.svg');
            const slug = `${pack}-${name}`; // ID unique global

            // Objet Icon pour DB
            const iconRecord = {
                id: `icon:${slug}`, // Force l'ID
                identity: {
                    pack: pack,
                    name: name,
                    slug: slug
                },
                resource: {
                    content: content, // Le SVG
                    viewbox: '0 0 24 24',
                    type: 'stroke'
                },
                presentation: {
                    label: name.replace(/-/g, ' '),
                    tags: name.split('-').filter(t => t.length > 2),
                    category: 'uncategorized'
                },
                status: {
                    is_active: true,
                    is_optimized: true
                },
                timestamp: { updated_at: new Date() }
            };

            batch.push(iconRecord);

            if (batch.length >= BATCH_SIZE) {
                await processBatch(db, batch);
                totalImported += batch.length;
                process.stdout.write('.');
                batch = [];
            }
        }

        // Dernier batch
        if (batch.length > 0) {
            await processBatch(db, batch);
            totalImported += batch.length;
        }
        console.log(`\n✅ Pack ${pack} terminé (${totalImported} icônes).`);
    }

    console.log('🎉 Synchronisation terminée.');
    await db.close();
}

async function processBatch(db: Surreal, items: any[]) {
    // On utilise Promise.all pour insérer en parallèle (ou create/upsert)
    // db.create échoue si ID existe. db.update/merge est mieux pour la sync.
    // Mais db.create est plus rapide pour l'initial insert.
    // Utilisons une stratégie "Upsert" (Create ou Update) via `let result = await db.query('UPSERT $data')` 
    // ou simplement db.merge() sur chaque item si l'ID est fourni.
    
    // Le plus performant en SDK JS est souvent Promise.all([db.merge(...), ...])
    
    const promises = items.map(item => {
        // On utilise MERGE pour que ça marche en update aussi (idempotent)
        // item contient déjà 'id'
        return db.query(`UPSERT ${item.id} CONTENT $data`, { data: item }).catch(e => {
             console.error(`Err ${item.id}:`, e.message);
        });
    });

    await Promise.all(promises);
}

main().catch(console.error);

