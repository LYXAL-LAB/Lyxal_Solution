/**
 * Erreurs spécifiques à lyxalsurreal - Architecture Bicéphale
 * Gestion centralisée et typée des erreurs SaaS/Workspace
 */

/**
 * Erreur de base pour toutes les erreurs SurrealDB
 */
// TODO: À vérifier - Classe d'erreur de base SurrealDB compatible Gateway avec gestion détails
export class SurrealError extends Error {
  public readonly code: string;
  public readonly details?: Record<string, any>;

  constructor(message: string, code: string, details?: Record<string, any>) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    if (details !== undefined) {
      this.details = details;
    }
    
    // Nécessaire pour le support correct des classes d'erreur en TypeScript
    Object.setPrototypeOf(this, SurrealError.prototype);
  }
}

/**
 * Erreur de connexion à SurrealDB
 */
// TODO: À vérifier - Erreur connexion SurrealDB avec détails techniques pour debugging
export class SurrealConnectionError extends SurrealError {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'ERR_SURREAL_CONNECTION', details);
    Object.setPrototypeOf(this, SurrealConnectionError.prototype);
  }
}

/**
 * Erreur d'authentification à SurrealDB
 */
// TODO: À vérifier - Erreur authentification SurrealDB avec contexte sécurisé
export class SurrealAuthError extends SurrealError {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'ERR_SURREAL_AUTH', details);
    Object.setPrototypeOf(this, SurrealAuthError.prototype);
  }
}

/**
 * Erreur de namespace SurrealDB
 */
// TODO: À vérifier - Erreur namespace compatible avec l'architecture hiérarchique 6 niveaux
export class SurrealNamespaceError extends SurrealError {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'ERR_SURREAL_NAMESPACE', details);
    Object.setPrototypeOf(this, SurrealNamespaceError.prototype);
  }
}

/**
 * Erreur de requête SurrealDB
 */
// TODO: À vérifier - Erreur requête SurrealDB avec debugging avancé et contexte performance
export class SurrealQueryError extends SurrealError {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'ERR_SURREAL_QUERY', details);
    Object.setPrototypeOf(this, SurrealQueryError.prototype);
  }
}

// ==========================================
// ERREURS ARCHITECTURE BICÉPHALE
// ==========================================

/**
 * Erreur spécifique aux instances SaaS
 */
// TODO: À vérifier - Erreur SaaS compatible avec les registries et niveaux hiérarchiques
export class SaaSError extends SurrealError {
  constructor(message: string, code: string = 'ERR_SAAS', details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, SaaSError.prototype);
  }
}

/**
 * Erreur pour une instance SaaS non trouvée
 */
// TODO: À vérifier - Erreur SaaS non trouvé avec navigation hiérarchique et contexte parent
export class SaaSNotFoundError extends SaaSError {
  constructor(saasId: string, details?: Record<string, any>) {
    super(`Instance SaaS '${saasId}' non trouvée`, 'ERR_SAAS_NOT_FOUND', details);
    Object.setPrototypeOf(this, SaaSNotFoundError.prototype);
  }
}

/**
 * Erreur pour une instance SaaS inactive ou suspendue
 */
// TODO: À vérifier - Erreur SaaS inactif avec gestion des statuts registry cohérents
export class SaaSInactiveError extends SaaSError {
  constructor(saasId: string, status: string, details?: Record<string, any>) {
    super(
      `Instance SaaS '${saasId}' est ${status}`, 
      'ERR_SAAS_INACTIVE', 
      { ...details, status }
    );
    Object.setPrototypeOf(this, SaaSInactiveError.prototype);
  }
}

/**
 * Erreur spécifique aux workspaces
 */
// TODO: À vérifier - Erreur Workspace compatible avec l'architecture bicéphale et templates
export class WorkspaceError extends SurrealError {
  constructor(message: string, code: string = 'ERR_WORKSPACE', details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, WorkspaceError.prototype);
  }
}

/**
 * Erreur pour un workspace non trouvé
 */
// TODO: À vérifier - Erreur Workspace non trouvé avec contexte SaaS parent et navigation
export class WorkspaceNotFoundError extends WorkspaceError {
  constructor(workspaceId: string, saasId: string, details?: Record<string, any>) {
    super(
      `Workspace '${workspaceId}' non trouvé dans l'instance SaaS '${saasId}'`, 
      'ERR_WORKSPACE_NOT_FOUND', 
      { ...details, saasId, workspaceId }
    );
    Object.setPrototypeOf(this, WorkspaceNotFoundError.prototype);
  }
}

/**
 * Erreur pour un workspace inactif
 */
// TODO: À vérifier - Erreur Workspace inactif avec gestion des statuts et cycle de vie
export class WorkspaceInactiveError extends WorkspaceError {
  constructor(workspaceId: string, saasId: string, status: string, details?: Record<string, any>) {
    super(
      `Workspace '${workspaceId}' dans l'instance SaaS '${saasId}' est ${status}`, 
      'ERR_WORKSPACE_INACTIVE', 
      { ...details, saasId, workspaceId, status }
    );
    Object.setPrototypeOf(this, WorkspaceInactiveError.prototype);
  }
}

/**
 * Erreur spécifique aux modules de workspace
 */
// TODO: À vérifier - Erreur module Workspace compatible avec les templates SaaS et dependencies
export class WorkspaceModuleError extends SurrealError {
  constructor(message: string, code: string = 'ERR_WORKSPACE_MODULE', details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, WorkspaceModuleError.prototype);
  }
}

/**
 * Erreur pour un module de workspace non trouvé
 */
// TODO: À vérifier - Erreur module non trouvé avec contexte workspace et gestion versions
export class WorkspaceModuleNotFoundError extends WorkspaceModuleError {
  constructor(moduleName: string, workspaceId: string, details?: Record<string, any>) {
    super(
      `Module '${moduleName}' non trouvé dans le workspace '${workspaceId}'`, 
      'ERR_WORKSPACE_MODULE_NOT_FOUND', 
      { ...details, workspaceId, moduleName }
    );
    Object.setPrototypeOf(this, WorkspaceModuleNotFoundError.prototype);
  }
}

/**
 * Erreur spécifique au provisionnement
 */
// TODO: À vérifier - Erreur provisionnement compatible avec l'automatisation et déploiement
export class ProvisioningError extends SurrealError {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'ERR_PROVISIONING', details);
    Object.setPrototypeOf(this, ProvisioningError.prototype);
  }
} 