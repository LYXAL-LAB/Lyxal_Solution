/**
 * Enregistre un événement d'audit GDPR
 */
export async function logAuditEvent(ctx: any, event: string, payload: any) {
  const auth = ctx.get('auth');
  
  const auditData = {
    user: auth?.userId,
    workspace: auth?.workspace,
    payload,
    timestamp: new Date().toISOString(),
    event
  };

  console.log(`[AUDIT GDPR] ${event}`, auditData);
  
  try {
    // Enregistrement dans SurrealDB via le client surreal
    const db = ctx.get('db');
    if (db) {
      await db.create('gdpr_audit_log', auditData);
    }
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement de l\'audit GDPR:', error);
  }
}
