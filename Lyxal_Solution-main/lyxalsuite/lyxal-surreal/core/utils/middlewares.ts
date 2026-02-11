import { type Context, Next } from 'hono';
import { BaseSurrealClient } from '../baseSurrealClient.js';
import { SaaSError, WorkspaceError } from '../types/errors.types.js';

/**
 * 🆕 MIDDLEWARES ARCHITECTURE BICÉPHALE
 * SaaS(Namespace) / Workspace(Database)
 */

/**
 * Middleware principal SaaS - Valide l'instance SaaS et configure le contexte
 */
export const saasMiddleware = async (c: Context, next: Next) => {
  const saasId = c.req.header('X-SaaS-ID');
  const workspaceId = c.req.header('X-Workspace-ID');
  
  // Vérifier si le header SaaS requis est présent
  if (!saasId) {
    return c.json({ 
      error: 'X-SaaS-ID header manquant. Impossible de déterminer l\'instance SaaS.' 
    }, 400);
  }
  
  try {
    // Obtenir le client SurrealDB (doit être déjà initialisé)
    const surrealClient = BaseSurrealClient.getInstance();
    
    // Vérifier si l'instance SaaS existe
    const saasExists = await surrealClient.saasExists(saasId);
    if (!saasExists) {
      return c.json({ 
        error: `Instance SaaS ${saasId} non trouvée` 
      }, 404);
    }
    
    // Utiliser l'instance SaaS (namespace + database configuration)
    await surrealClient.useSaaS(saasId);
    
    // Récupérer les informations de l'instance SaaS
    const saasResult = await surrealClient.query(
      'SELECT * FROM saas_settings'
    );
    
    if (!saasResult[0] || (saasResult[0] as any[]).length === 0) {
      throw new SaaSError(`Configuration SaaS manquante pour ${saasId}`);
    }
    
    const saasRecord = (saasResult[0] as any[])[0];
    
    // Vérifier si l'instance SaaS est active
    if (saasRecord.status !== 'active') {
      return c.json({ 
        error: `L'instance SaaS ${saasId} est ${saasRecord.status}` 
      }, 403);
    }
    
    // Stocker les informations SaaS dans le contexte
    c.set('saas', saasRecord);
    c.set('surrealClient', surrealClient);
    
    // Si un workspace ID est fourni, valider le workspace
    if (workspaceId) {
      const workspaceExists = await surrealClient.workspaceExists(saasId, workspaceId);
      if (!workspaceExists) {
        return c.json({ 
          error: `Workspace ${workspaceId} non trouvé dans l'instance SaaS ${saasId}` 
        }, 404);
      }
      
      // Basculer vers le workspace
      await surrealClient.useWorkspace(saasId, workspaceId);
      
      // Récupérer les informations du workspace depuis le registry SaaS
      await surrealClient.useSaaS(saasId);
      const workspaceResult = await surrealClient.query(
        'SELECT * FROM workspaces_registry WHERE name = $name',
        { name: workspaceId }
      );
      
      if (!workspaceResult[0] || (workspaceResult[0] as any[]).length === 0) {
        throw new WorkspaceError(`Informations workspace manquantes pour ${workspaceId}`);
      }
      
      const workspaceRecord = (workspaceResult[0] as any[])[0];
      
      // Vérifier si le workspace est actif
      if (workspaceRecord.status !== 'active') {
        return c.json({ 
          error: `Le workspace ${workspaceId} est ${workspaceRecord.status}` 
        }, 403);
      }
      
      // Stocker les informations workspace dans le contexte
      c.set('workspace', workspaceRecord);
      
      // Retourner au workspace pour la suite
      await surrealClient.useWorkspace(saasId, workspaceId);
    }
    
    // Passer à l'étape suivante
    await next();
    return;
  } catch (error) {
    console.error('Erreur dans le middleware SaaS:', error);
    return c.json({ 
      error: 'Erreur lors de la validation SaaS/Workspace',
      details: (error as Error).message 
    }, 500);
  }
};

/**
 * Middleware workspace - Valide spécifiquement un workspace (X-Workspace-ID requis)
 */
export const workspaceMiddleware = async (c: Context, next: Next) => {
  const saasId = c.req.header('X-SaaS-ID');
  const workspaceId = c.req.header('X-Workspace-ID');
  
  // Headers obligatoires pour ce middleware
  if (!saasId || !workspaceId) {
    return c.json({ 
      error: 'X-SaaS-ID et X-Workspace-ID headers requis pour accéder à un workspace' 
    }, 400);
  }
  
  try {
    const surrealClient = BaseSurrealClient.getInstance();
    
    // Vérifier existence SaaS
    const saasExists = await surrealClient.saasExists(saasId);
    if (!saasExists) {
      return c.json({ 
        error: `Instance SaaS ${saasId} non trouvée` 
      }, 404);
    }
    
    // Vérifier existence workspace
    const workspaceExists = await surrealClient.workspaceExists(saasId, workspaceId);
    if (!workspaceExists) {
      return c.json({ 
        error: `Workspace ${workspaceId} non trouvé dans l'instance SaaS ${saasId}` 
      }, 404);
    }
    
    // Configurer le context workspace
    await surrealClient.useWorkspace(saasId, workspaceId);
    
    // Récupérer les informations du workspace
    await surrealClient.useSaaS(saasId);
    const workspaceResult = await surrealClient.query(
      'SELECT * FROM workspaces_registry WHERE name = $name',
      { name: workspaceId }
    );
    
    const workspaceRecord = (workspaceResult[0] as any[])[0];
    
    // Mettre à jour lastAccessedAt
    await surrealClient.query(
      'UPDATE workspaces_registry SET lastAccessedAt = time::now() WHERE name = $name',
      { name: workspaceId }
    );
    
    // Retourner au workspace
    await surrealClient.useWorkspace(saasId, workspaceId);
    
    // Stocker dans le contexte
    c.set('workspace', workspaceRecord);
    c.set('surrealClient', surrealClient);
    
    await next();
    return;
  } catch (error) {
    console.error('Erreur dans le middleware workspace:', error);
    return c.json({ 
      error: 'Erreur lors de la validation du workspace',
      details: (error as Error).message 
    }, 500);
  }
};

/**
 * Middleware de provisionnement automatique SaaS
 * Crée automatiquement une instance SaaS si elle n'existe pas
 */
export const autoProvisionSaaSMiddleware = async (c: Context, next: Next) => {
  const saasId = c.req.header('X-SaaS-ID');
  const saasDisplayName = c.req.header('X-SaaS-DisplayName') || saasId;
  const saasDomain = c.req.header('X-SaaS-Domain') || '';
  const saasPlan = (c.req.header('X-SaaS-Plan') as 'starter' | 'pro' | 'enterprise') || 'starter';
  
  if (!saasId) {
    return c.json({ error: 'X-SaaS-ID header manquant' }, 400);
  }
  
  try {
    const surrealClient = BaseSurrealClient.getInstance();
    
    // Vérifier si l'instance SaaS existe déjà
    const saasExists = await surrealClient.saasExists(saasId);
    
    let saasRecord;
    let isNewlyCreated = false;
    
    if (!saasExists) {
      // Créer automatiquement l'instance SaaS
      await surrealClient.createSaaS(saasId, {
        displayName: saasDisplayName,
        domain: saasDomain,
        plan: saasPlan,
        status: 'active'
      });
      
      isNewlyCreated = true;
      
      // Récupérer l'instance SaaS nouvellement créée
      await surrealClient.useSaaS(saasId);
      const saasResult = await surrealClient.query('SELECT * FROM saas_settings');
      saasRecord = (saasResult[0] as any[])[0];
    } else {
      // Récupérer l'instance SaaS existante
      await surrealClient.useSaaS(saasId);
      const saasResult = await surrealClient.query('SELECT * FROM saas_settings');
      saasRecord = (saasResult[0] as any[])[0];
    }
    
    // Stocker dans le contexte
    c.set('saas', saasRecord);
    c.set('saasCreated', isNewlyCreated);
    c.set('surrealClient', surrealClient);
    
    await next();
    return;
  } catch (error) {
    console.error('Erreur dans le middleware de provisionnement SaaS:', error);
    return c.json({ 
      error: 'Erreur lors de la création automatique de l\'instance SaaS',
      details: (error as Error).message 
    }, 500);
  }
};

/**
 * Middleware de provisionnement automatique Workspace
 * Crée automatiquement un workspace dans une instance SaaS s'il n'existe pas
 */
export const autoProvisionWorkspaceMiddleware = async (c: Context, next: Next) => {
  const saasId = c.req.header('X-SaaS-ID');
  const workspaceId = c.req.header('X-Workspace-ID');
  const modules = c.req.header('X-Workspace-Modules')?.split(',') || [];
  
  if (!saasId || !workspaceId) {
    return c.json({ error: 'X-SaaS-ID et X-Workspace-ID headers requis' }, 400);
  }
  
  try {
    const surrealClient = BaseSurrealClient.getInstance();
    
    // Vérifier si l'instance SaaS existe
    const saasExists = await surrealClient.saasExists(saasId);
    if (!saasExists) {
      return c.json({ error: `Instance SaaS ${saasId} non trouvée` }, 404);
    }
    
    // Récupérer l'instance SaaS
    await surrealClient.useSaaS(saasId);
    const saasResult = await surrealClient.query('SELECT * FROM saas_settings');
    const saasRecord = (saasResult[0] as any[])[0];
    
    // Vérifier si le workspace existe déjà
    const workspaceExists = await surrealClient.workspaceExists(saasId, workspaceId);
    
    let workspaceRecord;
    let isNewlyCreated = false;
    
    if (!workspaceExists) {
      // Créer automatiquement le workspace
      await surrealClient.createWorkspace(saasId, workspaceId, modules);
      isNewlyCreated = true;
      
      // Récupérer le workspace nouvellement créé
      await surrealClient.useSaaS(saasId);
      const workspaceResult = await surrealClient.query(
        'SELECT * FROM workspaces_registry WHERE name = $name',
        { name: workspaceId }
      );
      workspaceRecord = (workspaceResult[0] as any[])[0];
    } else {
      // Récupérer le workspace existant
      await surrealClient.useSaaS(saasId);
      const workspaceResult = await surrealClient.query(
        'SELECT * FROM workspaces_registry WHERE name = $name',
        { name: workspaceId }
      );
      workspaceRecord = (workspaceResult[0] as any[])[0];
    }
    
    // Basculer vers le workspace
    await surrealClient.useWorkspace(saasId, workspaceId);
    
    // Stocker dans le contexte
    c.set('saas', saasRecord);
    c.set('workspace', workspaceRecord);
    c.set('workspaceCreated', isNewlyCreated);
    c.set('surrealClient', surrealClient);
    
    await next();
    return;
  } catch (error) {
    console.error('Erreur dans le middleware de provisionnement workspace:', error);
    return c.json({ 
      error: 'Erreur lors de la création automatique du workspace',
      details: (error as Error).message 
    }, 500);
  }
}; 