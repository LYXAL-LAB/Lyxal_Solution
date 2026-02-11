import { Surreal } from 'surrealdb.js';
import { CRM_SCHEMA } from './schema';
import { CRM_REFERENCE_DATA } from './referenceData';

export async function initCRMDatabase(db: Surreal) {
  try {
    console.log('[CRM] Initialisation du schéma...');
    await db.query(CRM_SCHEMA);

    console.log('[CRM] Insertion des données de référence...');
    await db.query(CRM_REFERENCE_DATA);

    console.log('[CRM] Initialisation réussie ✅');
  } catch (err) {
    console.error('[CRM] Erreur lors de l\'initialisation:', err);
    throw err;
  }
}
