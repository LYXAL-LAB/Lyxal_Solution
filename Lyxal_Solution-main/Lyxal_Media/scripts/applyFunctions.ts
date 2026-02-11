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

        const functionsDir = path.resolve(__dirname, '../surreal/functions');
        const files = fs.readdirSync(functionsDir).filter(f => f.endsWith('.surql'));

        for (const file of files) {
            const filePath = path.join(functionsDir, file);
            const query = fs.readFileSync(filePath, 'utf-8');
            console.log(`📜 Applying function from ${file}...`);
            try {
                await db.query(query);
                console.log(`✅ ${file} applied.`);
            } catch (e) {
                console.error(`❌ Error applying ${file}:`, e);
            }
        }

    } catch (e) {
        console.error('❌ Error:', e);
    } finally {
        await db.close();
    }
}

main();