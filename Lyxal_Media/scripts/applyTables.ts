import { Surreal } from 'surrealdb';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

async function main() {
    const db = new Surreal();
    try {
        console.log('🔌 Connecting to SurrealDB...');
        await db.connect(DB_CONFIG.endpoint, {
            auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
        });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });

        const tablesDir = path.resolve(__dirname, '../surreal/tables');
        const files = fs.readdirSync(tablesDir).filter(f => f.endsWith('.surql'));

        for (const file of files) {
            const filePath = path.join(tablesDir, file);
            let query = fs.readFileSync(filePath, 'utf-8');
            console.log(`📜 Applying table schema from ${file}...`);
            try {
                // On force la redéfinition si besoin en changeant DEFINE FIELD IF NOT EXISTS par DEFINE FIELD OVERWRITE si supporté,
                // mais SurrealDB ne supporte pas OVERWRITE pour les fields facilement.
                // On va juste appliquer le fichier tel quel. Si le champ existe déjà avec un autre type, ça peut bloquer sans migration.
                // Pour être sûr, on peut essayer de changer le type explicitement.
                
                await db.query(query);
                console.log(`✅ ${file} applied.`);
            } catch (e) {
                console.error(`❌ Error applying ${file}:`, e);
            }
        }
        
        // Force update of identity.pack type if it was string
        console.log('🔧 Forcing type update for icon.identity.pack...');
        try {
            // Cette commande va échouer si des données incompatibles existent (des strings qui ne sont pas des record IDs valides)
            // Mais ici on veut RECORD.
            await db.query('DEFINE FIELD identity.pack ON TABLE icon TYPE record<icon_pack>;');
            console.log('✅ Field identity.pack type enforced.');
        } catch(e) {
            console.warn('⚠️ Could not enforce type (might be data conflict):', e);
        }

    } catch (e) {
        console.error('❌ Error:', e);
    } finally {
        await db.close();
    }
}

main();
