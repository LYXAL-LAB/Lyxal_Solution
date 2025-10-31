/**
 * Enregistre une étape d’installation dans la table SurrealDB `loginstallation`
 * Utilisable en remplacement de console.log pour permettre un suivi live
 */
export async function emitLogInstallation(
    db: any,
    module: string,
    submodule: string,
    entity: string,
    phase: string,
    status: 'in_progress' | 'success' | 'failure',
    message: string,
    details: Record<string, any> = {}
  ): Promise<void> {
    try {
      await db.query('CREATE loginstallation CONTENT $log', {
        log: {
          module,
          submodule,
          entity,
          phase,
          status,
          message,
          timestamp: new Date().toISOString(),
          details
        }
      });
    } catch (error) {
      console.warn(`⚠️ Erreur lors de l’écriture du log [${phase}]`, error);
    }
  }
  