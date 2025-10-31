import { Surreal } from 'surrealdb.js';
import { SALE_SCHEMA } from './schema';
import { SALE_REFERENCE_DATA } from './referenceData';

export async function initSALEDatabase(db: Surreal) {
  try {
    console.log('[SALE] Initialisation du schéma...');
    await db.query(SALE_SCHEMA);

    console.log('[SALE] Insertion des données de référence...');
    await db.query(SALE_REFERENCE_DATA);

    console.log('[SALE] Initialisation réussie ✅');
  } catch (err) {
    console.error('[SALE] Erreur lors de l\'initialisation:', err);
    throw err;
  }
}
