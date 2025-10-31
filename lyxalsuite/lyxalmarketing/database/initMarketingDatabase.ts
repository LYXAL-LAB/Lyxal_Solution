import { Surreal } from 'surrealdb.js';
import { MARKETING_SCHEMA } from './schema';
import { MARKETING_REFERENCE_DATA } from './referenceData';

export async function initMarketingDatabase(db: Surreal) {
  try {
    console.log('[Marketing] Initialisation du schéma...');
    await db.query(MARKETING_SCHEMA);

    console.log('[Marketing] Insertion des données de référence...');
    await db.query(MARKETING_REFERENCE_DATA);

    console.log('[Marketing] Initialisation réussie ✅');
  } catch (err) {
    console.error('[Marketing] Erreur lors de l\'initialisation:', err);
    throw err;
  }
}