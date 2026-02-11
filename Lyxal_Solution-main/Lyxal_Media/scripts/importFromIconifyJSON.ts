import fs from 'node:fs';
import { fileURLToPath } from 'node:url';
import { Surreal } from 'surrealdb';
import { fetch } from 'bun';

// Config connexion DB
const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

async function main() {
    // Récupérer l'URL JSON depuis les arguments CLI
    // Ex: bun scripts/importFromLyxalJSON.ts https://raw.githubusercontent.com/Lyxal/icon-sets/master/json/lucide.json
    const targetUrl = process.argv[2];

    if (!targetUrl) {
        console.error('❌ Usage: bun scripts/importFromLyxalJSON.ts <url_du_json>');
        process.exit(1);
    }

    console.log(`🚀 Importation depuis Lyxal JSON: ${targetUrl}`);

    // 1. Téléchargement
    let data;
    try {
        const res = await fetch(targetUrl);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        data = await res.json();
    } catch (e) {
        console.error('❌ Erreur téléchargement JSON:', e);
        return;
    }

    const prefix = data.prefix;
    const info = data.info || {};
    console.log(`📦 Pack détecté : ${info.name} (${prefix}) - ${Object.keys(data.icons).length} icônes`);

    // 2. Connexion DB
    const db = new Surreal();
    try {
        console.log('🔌 Connexion à SurrealDB...');
        await db.connect(DB_CONFIG.endpoint, {
            auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
        });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
    } catch (e) {
        console.error('❌ Erreur connexion DB:', e);
        return;
    }

    // 3. Import Pack via Function
    try {
        const category = info.category || 'Uncategorized';
        const tags = info.tags || [];

        await db.query(`
            fn::create_icon_pack(
                $name, 
                $category, 
                $version, 
                $license, 
                $source_url, 
                $icon_count,
                $tags
            )
        `, {
            name: prefix,
            category: category,
            version: "0.0.0",
            license: info.license?.title || 'Unknown',
            source_url: info.author?.url || info.url || '',
            icon_count: Object.keys(data.icons).length,
            tags: tags
        });

        console.log(`✅ Pack ${prefix} synchronisé.`);
    } catch (e) {
        console.error('⚠️ Erreur création pack:', e);
        // On continue même si le pack échoue (ex: déjà existant si CREATE), 
        // mais avec UPSERT dans la fonction, ça devrait passer.
    }

    // 4. Import Icônes
    const icons = data.icons;
    const widthGlobal = data.width || 24;
    const heightGlobal = data.height || 24;

    // Préparation des catégories
    let iconCategories: Record<string, string[]> = {}; 
    if (data.categories) {
        for (const [catName, iconList] of Object.entries(data.categories as Record<string, string[]>)) {
            for (const iconName of iconList) {
                if (!iconCategories[iconName]) iconCategories[iconName] = [];
                iconCategories[iconName].push(catName);
            }
        }
    }

    console.log(`🔄 Importation de ${Object.keys(icons).length} icônes...`);

    let batch: { name: string; body: any; width: any; height: any; tags: string[]; category: string; }[] = [];
    const BATCH_SIZE = 50;
    let total = 0;

    for (const [name, iconData] of Object.entries(icons as Record<string, any>)) {
        const w = iconData.width || widthGlobal;
        const h = iconData.height || heightGlobal;
        const body = iconData.body;
        
        const tags = iconCategories[name] || [];
        // Ajout des tags globaux si pertinent
        const keywordTags = name.split('-').filter(t => t.length > 2);
        const finalTags = [...new Set([...tags, ...keywordTags])];

        // On push l'appel de fonction dans le batch
        batch.push({
            name: name,
            body: body,
            width: w,
            height: h,
            tags: finalTags,
            category: tags[0] || 'uncategorized'
        });

        if (batch.length >= BATCH_SIZE) {
            await processBatch(db, prefix, batch);
            total += batch.length;
            process.stdout.write('.');
            batch = [];
        }
    }

    if (batch.length > 0) {
        await processBatch(db, prefix, batch);
        total += batch.length;
    }

    console.log(`\n🎉 Import terminé : ${total} icônes.`);
    await db.close();
}

async function processBatch(db: Surreal, prefix: string, items: any[]) {
    // On construit une requête transactionnelle ou multiple
    let query = 'BEGIN TRANSACTION;';
    const vars: Record<string, any> = {};

    items.forEach((item, index) => {
        const i = index;
        query += `
            fn::create_icon(
                $prefix,
                $name_${i},
                $body_${i},
                $width_${i},
                $height_${i},
                $cat_${i},
                $tags_${i}
            );
        `;
        vars[`name_${i}`] = item.name;
        vars[`body_${i}`] = item.body;
        vars[`width_${i}`] = item.width;
        vars[`height_${i}`] = item.height;
        vars[`cat_${i}`] = item.category;
        vars[`tags_${i}`] = item.tags;
    });
    
    query += 'COMMIT TRANSACTION;';
    vars['prefix'] = prefix;

    try {
        await db.query(query, vars);
    } catch (e: any) {
        console.error(`\n⚠️ Erreur batch:`, e.message);
    }
}

main().catch(console.error);

