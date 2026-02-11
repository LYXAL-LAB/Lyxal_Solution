import { Surreal } from 'surrealdb';

// Config connexion DB (identique à uploadToBunny.ts)
const DB_CONFIG = {
    endpoint: 'wss://lyxal-solution-06d9qbd4uptppckv6vqkthhk2k.aws-euw1.surreal.cloud',
    username: 'admin',
    password: 'admin',
    namespace: 'Lyxal_Solution',
    database: 'Developpement'
};

async function main() {
    console.log('🔍 Debug Config...');
    const db = new Surreal();

    try {
        await db.connect(DB_CONFIG.endpoint, {
            auth: { username: DB_CONFIG.username, password: DB_CONFIG.password }
        });
        await db.use({ namespace: DB_CONFIG.namespace, database: DB_CONFIG.database });
        
        console.log(`✅ Connecté à ${DB_CONFIG.namespace}/${DB_CONFIG.database}`);

        // 1. Lister tous les enregistrements de la table svg_config pour voir ce qu'il y a
        console.log('--- SELECT * FROM svg_config ---');
        const allConfigs = await db.select('svg_config');
        console.log(JSON.stringify(allConfigs, null, 2));

        // 2. Tester l'accès direct
        console.log('--- SELECT * FROM svg_config:main ---');
        const mainConfig = await db.select('svg_config:main');
        console.log('Raw result:', mainConfig);

    } catch (e) {
        console.error('❌ Erreur:', e);
    } finally {
        await db.close();
    }
}

main();

