/**
 * @file client.ts
 * @description Client d'authentification pour le SDK backend
 */

// @ts-ignore
import * as nodeFetch from 'node-fetch';
const fetch = nodeFetch.default || nodeFetch;

import { 
  User, 
  UserSession, 
  AuthResponse, 
  AuthErrorResponse, 
  LoginRequest,
  RegisterRequest,
  VerificationCodeRequest,
  VerificationCodeVerify,
  ResetPasswordRequest,
  UpdatePasswordRequest,
  Role,
  Organization,
  Application,
  ApiResource,
  PaginationOptions,
  PaginatedResponse
} from '../core/types';
import { isTokenValid, parseJwt } from '../core/auth';
import { buildQueryParams, mapError, createAuthHeader } from '../core/utils';

/**
 * Options de configuration du client d'authentification backend
 */
export interface AuthClientOptions {
  /** URL de base de la gateway */
  gatewayUrl: string;
  /** Clé API pour l'authentification serveur-à-serveur */
  apiKey?: string;
  /** Timeout pour les requêtes en ms */
  timeout?: number;
  /** Fonction de callback lors d'une erreur d'authentification */
  onAuthError?: (error: AuthErrorResponse) => void;
}

/**
 * Client d'authentification pour le backend
 */
export class AuthClient {
  private options: AuthClientOptions;
  private adminToken?: string;

  /**
   * Crée une instance du client d'authentification backend
   * @param options Options de configuration
   */
  constructor(options: AuthClientOptions) {
    this.options = {
      timeout: 10000, // 10 secondes par défaut
      ...options
    };
  }

  /**
   * Effectue une requête authentifiée vers la gateway
   * @param endpoint Point de terminaison de l'API
   * @param options Options de la requête fetch
   * @returns Réponse de l'API
   */
  private async request<T>(
    endpoint: string, 
    options: RequestInit = {},
    useApiKey: boolean = true
  ): Promise<T> {
    const url = `${this.options.gatewayUrl}/api/auth${endpoint}`;
    
    // Définir un timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.options.timeout);
    
    try {
      // Préparer les headers par défaut
      const headers: Record<string, string> = {
        'Content-Type': 'application/json'
      };
      
      // Ajouter les headers existants s'il y en a
      if (options.headers) {
        const existingHeaders = options.headers as Record<string, string>;
        Object.keys(existingHeaders).forEach(key => {
          headers[key] = existingHeaders[key];
        });
      }
      
      // Ajouter la clé API si demandé et disponible
      if (useApiKey && this.options.apiKey) {
        headers['X-API-Key'] = this.options.apiKey;
      }
      
      // Ajouter le token d'administration si disponible
      if (this.adminToken) {
        headers['Authorization'] = createAuthHeader(this.adminToken);
      }
      
      const response = await fetch(url, {
        ...options,
        headers,
        signal: controller.signal
      });
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({ 
          error: `http_error_${response.status}`,
          error_description: response.statusText 
        }));
        
        const error: AuthErrorResponse = {
          ...errorData,
          status: response.status
        };
        
        // Appeler le callback d'erreur si défini
        if (this.options.onAuthError) {
          this.options.onAuthError(error);
        }
        
        throw error;
      }
      
      // Vérifier si la réponse est vide
      const contentType = response.headers.get('content-type');
      if (contentType?.includes('application/json')) {
        return await response.json();
      }
      
      return {} as T;
    } catch (error) {
      const mappedError = mapError(error);
      
      // Appeler le callback d'erreur si défini
      if (this.options.onAuthError) {
        this.options.onAuthError(mappedError);
      }
      
      throw mappedError;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  /**
   * Authentifie en tant qu'administrateur pour accéder aux API de gestion
   * @param credentials Identifiants de connexion admin
   * @returns true si l'authentification a réussi
   */
  public async adminLogin(credentials: LoginRequest): Promise<boolean> {
    try {
      const response = await this.request<AuthResponse>('/admin/login', {
        method: 'POST',
        body: JSON.stringify(credentials)
      }, true);
      
      if (response.accessToken) {
        this.adminToken = response.accessToken;
        return true;
      }
      
      return false;
    } catch (error) {
      this.adminToken = undefined;
      return false;
    }
  }

  /**
   * Vérifie si un token est valide
   * @param token Token à vérifier
   * @returns Informations sur la validité du token
   */
  public async verifyToken(token: string): Promise<{
    valid: boolean;
    userId?: string;
    expiresAt?: number;
  }> {
    try {
      return await this.request<{
        valid: boolean;
        userId?: string;
        expiresAt?: number;
      }>('/verify-token', {
        method: 'POST',
        body: JSON.stringify({ token })
      });
    } catch (error) {
      return { valid: false };
    }
  }

  /**
   * Récupère les informations d'un utilisateur
   * @param userId ID de l'utilisateur
   * @returns Informations utilisateur
   */
  public async getUser(userId: string): Promise<User> {
    return await this.request<User>(`/users/${userId}`);
  }

  /**
   * Liste les utilisateurs
   * @param options Options de pagination
   * @returns Liste paginée d'utilisateurs
   */
  public async listUsers(options?: PaginationOptions): Promise<PaginatedResponse<User>> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<PaginatedResponse<User>>(`/users${queryParams}`);
  }

  /**
   * Crée un nouvel utilisateur
   * @param userData Données utilisateur
   * @returns Utilisateur créé
   */
  public async createUser(userData: RegisterRequest): Promise<User> {
    return await this.request<User>('/users', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  }

  /**
   * Met à jour un utilisateur
   * @param userId ID de l'utilisateur
   * @param userData Données à mettre à jour
   * @returns Utilisateur mis à jour
   */
  public async updateUser(userId: string, userData: Partial<User>): Promise<User> {
    return await this.request<User>(`/users/${userId}`, {
      method: 'PATCH',
      body: JSON.stringify(userData)
    });
  }

  /**
   * Supprime un utilisateur
   * @param userId ID de l'utilisateur
   * @returns true si la suppression a réussi
   */
  public async deleteUser(userId: string): Promise<boolean> {
    try {
      await this.request<void>(`/users/${userId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Récupère les rôles d'un utilisateur
   * @param userId ID de l'utilisateur
   * @returns Liste des rôles
   */
  public async getUserRoles(userId: string): Promise<Role[]> {
    return await this.request<Role[]>(`/users/${userId}/roles`);
  }

  /**
   * Assigne un rôle à un utilisateur
   * @param userId ID de l'utilisateur
   * @param roleId ID du rôle
   * @returns true si l'assignation a réussi
   */
  public async assignRoleToUser(userId: string, roleId: string): Promise<boolean> {
    try {
      await this.request<void>(`/users/${userId}/roles`, {
        method: 'POST',
        body: JSON.stringify({ roleId })
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Retire un rôle à un utilisateur
   * @param userId ID de l'utilisateur
   * @param roleId ID du rôle
   * @returns true si le retrait a réussi
   */
  public async removeRoleFromUser(userId: string, roleId: string): Promise<boolean> {
    try {
      await this.request<void>(`/users/${userId}/roles/${roleId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Liste les rôles
   * @param options Options de pagination
   * @returns Liste paginée des rôles
   */
  public async listRoles(options?: PaginationOptions): Promise<PaginatedResponse<Role>> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<PaginatedResponse<Role>>(`/roles${queryParams}`);
  }

  /**
   * Crée un nouveau rôle
   * @param roleData Données du rôle
   * @returns Rôle créé
   */
  public async createRole(roleData: Partial<Role>): Promise<Role> {
    return await this.request<Role>('/roles', {
      method: 'POST',
      body: JSON.stringify(roleData)
    });
  }

  /**
   * Met à jour un rôle
   * @param roleId ID du rôle
   * @param roleData Données à mettre à jour
   * @returns Rôle mis à jour
   */
  public async updateRole(roleId: string, roleData: Partial<Role>): Promise<Role> {
    return await this.request<Role>(`/roles/${roleId}`, {
      method: 'PATCH',
      body: JSON.stringify(roleData)
    });
  }

  /**
   * Supprime un rôle
   * @param roleId ID du rôle
   * @returns true si la suppression a réussi
   */
  public async deleteRole(roleId: string): Promise<boolean> {
    try {
      await this.request<void>(`/roles/${roleId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Liste les organisations
   * @param options Options de pagination
   * @returns Liste paginée des organisations
   */
  public async listOrganizations(options?: PaginationOptions): Promise<PaginatedResponse<Organization>> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<PaginatedResponse<Organization>>(`/organizations${queryParams}`);
  }

  /**
   * Récupère une organisation
   * @param organizationId ID de l'organisation
   * @returns Organisation
   */
  public async getOrganization(organizationId: string): Promise<Organization> {
    return await this.request<Organization>(`/organizations/${organizationId}`);
  }

  /**
   * Crée une nouvelle organisation
   * @param orgData Données de l'organisation
   * @returns Organisation créée
   */
  public async createOrganization(orgData: Partial<Organization>): Promise<Organization> {
    return await this.request<Organization>('/organizations', {
      method: 'POST',
      body: JSON.stringify(orgData)
    });
  }

  /**
   * Met à jour une organisation
   * @param organizationId ID de l'organisation
   * @param orgData Données à mettre à jour
   * @returns Organisation mise à jour
   */
  public async updateOrganization(organizationId: string, orgData: Partial<Organization>): Promise<Organization> {
    return await this.request<Organization>(`/organizations/${organizationId}`, {
      method: 'PATCH',
      body: JSON.stringify(orgData)
    });
  }

  /**
   * Supprime une organisation
   * @param organizationId ID de l'organisation
   * @returns true si la suppression a réussi
   */
  public async deleteOrganization(organizationId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Ajoute un utilisateur à une organisation
   * @param organizationId ID de l'organisation
   * @param userId ID de l'utilisateur
   * @returns true si l'ajout a réussi
   */
  public async addUserToOrganization(organizationId: string, userId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/users`, {
        method: 'POST',
        body: JSON.stringify({ userId })
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Retire un utilisateur d'une organisation
   * @param organizationId ID de l'organisation
   * @param userId ID de l'utilisateur
   * @returns true si le retrait a réussi
   */
  public async removeUserFromOrganization(organizationId: string, userId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/users/${userId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Liste les applications
   * @param options Options de pagination
   * @returns Liste paginée des applications
   */
  public async listApplications(options?: PaginationOptions): Promise<PaginatedResponse<Application>> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<PaginatedResponse<Application>>(`/applications${queryParams}`);
  }

  /**
   * Récupère une application
   * @param applicationId ID de l'application
   * @returns Application
   */
  public async getApplication(applicationId: string): Promise<Application> {
    return await this.request<Application>(`/applications/${applicationId}`);
  }

  /**
   * Liste les ressources API
   * @param options Options de pagination
   * @returns Liste paginée des ressources API
   */
  public async listApiResources(options?: PaginationOptions): Promise<PaginatedResponse<ApiResource>> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<PaginatedResponse<ApiResource>>(`/api-resources${queryParams}`);
  }

  /**
   * Récupère une ressource API
   * @param resourceId ID de la ressource
   * @returns Ressource API
   */
  public async getApiResource(resourceId: string): Promise<ApiResource> {
    return await this.request<ApiResource>(`/api-resources/${resourceId}`);
  }

  /**
   * Authentifie un utilisateur normal (pas un admin)
   * @param credentials Identifiants de connexion
   * @returns Session utilisateur
   */
  public async login(credentials: LoginRequest): Promise<UserSession> {
    const response = await this.request<AuthResponse>('/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    }, false);
    
    if (!response.accessToken) {
      throw {
        error: 'login_failed',
        error_description: 'Authentification échouée',
        status: 401
      };
    }
    
    // Récupérer les informations utilisateur
    const tokenData = parseJwt(response.accessToken);
    
    if (!tokenData) {
      throw {
        error: 'invalid_token',
        error_description: 'Token invalide ou non décodable',
        status: 401
      };
    }
    
    const userId = tokenData.sub;
    
    const user = await this.getUser(userId);
    
    return {
      userId,
      accessToken: response.accessToken,
      expiresAt: Math.floor(Date.now() / 1000) + response.expiresIn,
      isAuthenticated: true,
      user
    };
  }
  
  /**
   * Déconnecte l'utilisateur courant
   * @returns true si la déconnexion a réussi
   */
  public async logout(): Promise<boolean> {
    try {
      await this.request<{ success: boolean }>('/logout', {
        method: 'POST'
      });
      
      this.adminToken = undefined;
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Enregistre un nouvel utilisateur
   * @param userData Données utilisateur pour l'enregistrement
   * @returns Utilisateur créé
   */
  public async register(userData: RegisterRequest): Promise<User> {
    return await this.request<User>('/register', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  }
  
  /**
   * Demande un code de vérification (email, téléphone)
   * @param data Données pour la demande de code
   * @returns true si la demande a réussi
   */
  public async requestVerificationCode(data: VerificationCodeRequest): Promise<boolean> {
    try {
      await this.request<{ success: boolean }>('/verification-code', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Vérifie un code de vérification
   * @param data Données pour la vérification du code
   * @returns true si la vérification a réussi
   */
  public async verifyCode(data: VerificationCodeVerify): Promise<boolean> {
    try {
      await this.request<{ success: boolean }>('/verify-code', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Réinitialise le mot de passe de l'utilisateur
   * @param data Données pour la réinitialisation
   * @returns true si la réinitialisation a réussi
   */
  public async resetPassword(data: ResetPasswordRequest): Promise<boolean> {
    try {
      await this.request<{ success: boolean }>('/reset-password', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Met à jour le mot de passe de l'utilisateur
   * @param data Données pour la mise à jour
   * @returns true si la mise à jour a réussi
   */
  public async updatePassword(data: UpdatePasswordRequest): Promise<boolean> {
    try {
      await this.request<{ success: boolean }>('/update-password', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Crée une nouvelle application
   * @param applicationData Données de l'application
   * @returns Application créée
   */
  public async createApplication(applicationData: Partial<Application>): Promise<Application> {
    return await this.request<Application>('/applications', {
      method: 'POST',
      body: JSON.stringify(applicationData)
    });
  }
  
  /**
   * Met à jour une application
   * @param applicationId ID de l'application
   * @param applicationData Données à mettre à jour
   * @returns Application mise à jour
   */
  public async updateApplication(applicationId: string, applicationData: Partial<Application>): Promise<Application> {
    return await this.request<Application>(`/applications/${applicationId}`, {
      method: 'PATCH',
      body: JSON.stringify(applicationData)
    });
  }
  
  /**
   * Supprime une application
   * @param applicationId ID de l'application
   * @returns true si la suppression a réussi
   */
  public async deleteApplication(applicationId: string): Promise<boolean> {
    try {
      await this.request<void>(`/applications/${applicationId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Crée une nouvelle ressource API
   * @param resourceData Données de la ressource
   * @returns Ressource API créée
   */
  public async createApiResource(resourceData: Partial<ApiResource>): Promise<ApiResource> {
    return await this.request<ApiResource>('/resources', {
      method: 'POST',
      body: JSON.stringify(resourceData)
    });
  }
  
  /**
   * Met à jour une ressource API
   * @param resourceId ID de la ressource
   * @param resourceData Données à mettre à jour
   * @returns Ressource API mise à jour
   */
  public async updateApiResource(resourceId: string, resourceData: Partial<ApiResource>): Promise<ApiResource> {
    return await this.request<ApiResource>(`/resources/${resourceId}`, {
      method: 'PATCH',
      body: JSON.stringify(resourceData)
    });
  }
  
  /**
   * Supprime une ressource API
   * @param resourceId ID de la ressource
   * @returns true si la suppression a réussi
   */
  public async deleteApiResource(resourceId: string): Promise<boolean> {
    try {
      await this.request<void>(`/resources/${resourceId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * Récupère la session utilisateur associée à un token
   * @param token Token d'accès
   * @returns Session utilisateur ou null si le token est invalide
   */
  public async getSessionFromToken(token: string): Promise<UserSession | null> {
    try {
      const isValid = await this.verifyToken(token);
      
      if (!isValid.valid || !isValid.userId) {
        return null;
      }
      
      const user = await this.getUser(isValid.userId);
      
      return {
        userId: isValid.userId,
        accessToken: token,
        expiresAt: isValid.expiresAt || 0,
        isAuthenticated: true,
        user
      };
    } catch {
      return null;
    }
  }

  // === ACCOUNT MANAGEMENT ===
  
  /**
   * Récupère les informations du compte courant
   * @returns Informations du compte
   */
  public async getAccount(): Promise<any> {
    return await this.request<any>('/account');
  }

  /**
   * Met à jour les informations du compte courant
   * @param accountData Données à mettre à jour
   * @returns Compte mis à jour
   */
  public async updateAccount(accountData: any): Promise<any> {
    return await this.request<any>('/account', {
      method: 'PATCH',
      body: JSON.stringify(accountData)
    });
  }

  // === ASSETS MANAGEMENT ===
  
  /**
   * Télécharge un asset (image, fichier)
   * @param fileData Données du fichier à télécharger
   * @returns Informations sur l'asset téléchargé
   */
  public async uploadAsset(fileData: FormData): Promise<any> {
    return await this.request<any>('/assets', {
      method: 'POST',
      body: fileData,
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
  }

  /**
   * Récupère un asset par son ID
   * @param assetId ID de l'asset
   * @returns Données de l'asset
   */
  public async getAsset(assetId: string): Promise<any> {
    return await this.request<any>(`/assets/${assetId}`);
  }

  // === AUTHENTICATION FLOW ===
  
  /**
   * Récupère les informations d'authentification
   * @param interactionId ID de l'interaction
   * @returns Données d'authentification
   */
  public async getAuthenticationInfo(interactionId: string): Promise<any> {
    return await this.request<any>(`/authn/${interactionId}`);
  }

  /**
   * Vérifie un CAPTCHA
   * @param captchaData Données du CAPTCHA
   * @returns Résultat de la vérification
   */
  public async verifyCaptcha(captchaData: any): Promise<any> {
    return await this.request<any>('/captcha/verify', {
      method: 'POST',
      body: JSON.stringify(captchaData)
    });
  }

  // === CONFIGURATION MANAGEMENT ===
  
  /**
   * Récupère les configurations
   * @returns Configurations
   */
  public async getConfigs(): Promise<any> {
    return await this.request<any>('/configs');
  }

  /**
   * Met à jour les configurations
   * @param configData Données de configuration
   * @returns Configurations mises à jour
   */
  public async updateConfigs(configData: any): Promise<any> {
    return await this.request<any>('/configs', {
      method: 'PATCH',
      body: JSON.stringify(configData)
    });
  }

  // === CONNECTORS MANAGEMENT ===
  
  /**
   * Liste les connecteurs
   * @returns Liste des connecteurs
   */
  public async listConnectors(): Promise<any[]> {
    return await this.request<any[]>('/connectors');
  }

  /**
   * Récupère un connecteur par son ID
   * @param connectorId ID du connecteur
   * @returns Connecteur
   */
  public async getConnector(connectorId: string): Promise<any> {
    return await this.request<any>(`/connectors/${connectorId}`);
  }

  /**
   * Crée un connecteur
   * @param connectorData Données du connecteur
   * @returns Connecteur créé
   */
  public async createConnector(connectorData: any): Promise<any> {
    return await this.request<any>('/connectors', {
      method: 'POST',
      body: JSON.stringify(connectorData)
    });
  }

  /**
   * Met à jour un connecteur
   * @param connectorId ID du connecteur
   * @param connectorData Données du connecteur
   * @returns Connecteur mis à jour
   */
  public async updateConnector(connectorId: string, connectorData: any): Promise<any> {
    return await this.request<any>(`/connectors/${connectorId}`, {
      method: 'PATCH',
      body: JSON.stringify(connectorData)
    });
  }

  /**
   * Supprime un connecteur
   * @param connectorId ID du connecteur
   * @returns true si la suppression a réussi
   */
  public async deleteConnector(connectorId: string): Promise<boolean> {
    try {
      await this.request<void>(`/connectors/${connectorId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === CUSTOM PHRASES MANAGEMENT ===
  
  /**
   * Récupère les phrases personnalisées
   * @returns Phrases personnalisées
   */
  public async getCustomPhrases(): Promise<any> {
    return await this.request<any>('/custom-phrases');
  }

  /**
   * Met à jour les phrases personnalisées
   * @param phrasesData Données des phrases
   * @returns Phrases mises à jour
   */
  public async updateCustomPhrases(phrasesData: any): Promise<any> {
    return await this.request<any>('/custom-phrases', {
      method: 'PATCH',
      body: JSON.stringify(phrasesData)
    });
  }

  // === DASHBOARD MANAGEMENT ===
  
  /**
   * Récupère les statistiques du tableau de bord
   * @returns Statistiques
   */
  public async getDashboardStats(): Promise<any> {
    return await this.request<any>('/dashboard/stats');
  }

  // === DOMAINS MANAGEMENT ===
  
  /**
   * Liste les domaines
   * @returns Liste des domaines
   */
  public async listDomains(): Promise<any[]> {
    return await this.request<any[]>('/domains');
  }

  /**
   * Ajoute un domaine
   * @param domainData Données du domaine
   * @returns Domaine ajouté
   */
  public async addDomain(domainData: any): Promise<any> {
    return await this.request<any>('/domains', {
      method: 'POST',
      body: JSON.stringify(domainData)
    });
  }

  /**
   * Vérifie un domaine
   * @param domainId ID du domaine
   * @returns Résultat de la vérification
   */
  public async verifyDomain(domainId: string): Promise<any> {
    return await this.request<any>(`/domains/${domainId}/verify`, {
      method: 'POST'
    });
  }

  /**
   * Supprime un domaine
   * @param domainId ID du domaine
   * @returns true si la suppression a réussi
   */
  public async deleteDomain(domainId: string): Promise<boolean> {
    try {
      await this.request<void>(`/domains/${domainId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === EMAIL TEMPLATES MANAGEMENT ===
  
  /**
   * Liste les modèles d'email
   * @returns Liste des modèles d'email
   */
  public async listEmailTemplates(): Promise<any[]> {
    return await this.request<any[]>('/email-templates');
  }

  /**
   * Récupère un modèle d'email
   * @param templateId ID du modèle
   * @returns Modèle d'email
   */
  public async getEmailTemplate(templateId: string): Promise<any> {
    return await this.request<any>(`/email-templates/${templateId}`);
  }

  /**
   * Met à jour un modèle d'email
   * @param templateId ID du modèle
   * @param templateData Données du modèle
   * @returns Modèle mis à jour
   */
  public async updateEmailTemplate(templateId: string, templateData: any): Promise<any> {
    return await this.request<any>(`/email-templates/${templateId}`, {
      method: 'PATCH',
      body: JSON.stringify(templateData)
    });
  }

  // === EXPERIENCE MANAGEMENT ===
  
  /**
   * Récupère l'expérience de connexion
   * @returns Expérience de connexion
   */
  public async getSignInExperience(): Promise<any> {
    return await this.request<any>('/sign-in-experience');
  }

  /**
   * Met à jour l'expérience de connexion
   * @param experienceData Données d'expérience
   * @returns Expérience mise à jour
   */
  public async updateSignInExperience(experienceData: any): Promise<any> {
    return await this.request<any>('/sign-in-experience', {
      method: 'PATCH',
      body: JSON.stringify(experienceData)
    });
  }

  // === HOOKS MANAGEMENT ===
  
  /**
   * Liste les hooks
   * @returns Liste des hooks
   */
  public async listHooks(): Promise<any[]> {
    return await this.request<any[]>('/hooks');
  }

  /**
   * Récupère un hook
   * @param hookId ID du hook
   * @returns Hook
   */
  public async getHook(hookId: string): Promise<any> {
    return await this.request<any>(`/hooks/${hookId}`);
  }

  /**
   * Crée un hook
   * @param hookData Données du hook
   * @returns Hook créé
   */
  public async createHook(hookData: any): Promise<any> {
    return await this.request<any>('/hooks', {
      method: 'POST',
      body: JSON.stringify(hookData)
    });
  }

  /**
   * Met à jour un hook
   * @param hookId ID du hook
   * @param hookData Données du hook
   * @returns Hook mis à jour
   */
  public async updateHook(hookId: string, hookData: any): Promise<any> {
    return await this.request<any>(`/hooks/${hookId}`, {
      method: 'PATCH',
      body: JSON.stringify(hookData)
    });
  }

  /**
   * Supprime un hook
   * @param hookId ID du hook
   * @returns true si la suppression a réussi
   */
  public async deleteHook(hookId: string): Promise<boolean> {
    try {
      await this.request<void>(`/hooks/${hookId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === LOGS MANAGEMENT ===
  
  /**
   * Récupère les logs
   * @param options Options de filtrage
   * @returns Logs
   */
  public async getLogs(options?: any): Promise<any> {
    const queryParams = options ? `?${buildQueryParams(options)}` : '';
    return await this.request<any>(`/logs${queryParams}`);
  }

  // === MY ACCOUNT MANAGEMENT ===
  
  /**
   * Récupère les informations du compte de l'utilisateur courant
   * @returns Informations du compte
   */
  public async getMyAccount(): Promise<any> {
    return await this.request<any>('/my-account');
  }

  /**
   * Met à jour le compte de l'utilisateur courant
   * @param accountData Données du compte
   * @returns Compte mis à jour
   */
  public async updateMyAccount(accountData: any): Promise<any> {
    return await this.request<any>('/my-account', {
      method: 'PATCH',
      body: JSON.stringify(accountData)
    });
  }

  // === ONE-TIME TOKENS MANAGEMENT ===
  
  /**
   * Crée un token à usage unique
   * @param tokenData Données du token
   * @returns Token créé
   */
  public async createOneTimeToken(tokenData: any): Promise<any> {
    return await this.request<any>('/one-time-tokens', {
      method: 'POST',
      body: JSON.stringify(tokenData)
    });
  }

  /**
   * Vérifie un token à usage unique
   * @param token Token à vérifier
   * @returns Résultat de la vérification
   */
  public async verifyOneTimeToken(token: string): Promise<any> {
    return await this.request<any>('/one-time-tokens/verify', {
      method: 'POST',
      body: JSON.stringify({ token })
    });
  }

  // === ORGANIZATION INVITATIONS MANAGEMENT ===
  
  /**
   * Liste les invitations d'une organisation
   * @param organizationId ID de l'organisation
   * @returns Liste des invitations
   */
  public async listOrganizationInvitations(organizationId: string): Promise<any[]> {
    return await this.request<any[]>(`/organizations/${organizationId}/invitations`);
  }

  /**
   * Crée une invitation pour une organisation
   * @param organizationId ID de l'organisation
   * @param invitationData Données de l'invitation
   * @returns Invitation créée
   */
  public async createOrganizationInvitation(organizationId: string, invitationData: any): Promise<any> {
    return await this.request<any>(`/organizations/${organizationId}/invitations`, {
      method: 'POST',
      body: JSON.stringify(invitationData)
    });
  }

  /**
   * Supprime une invitation d'organisation
   * @param organizationId ID de l'organisation
   * @param invitationId ID de l'invitation
   * @returns true si la suppression a réussi
   */
  public async deleteOrganizationInvitation(organizationId: string, invitationId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/invitations/${invitationId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === ORGANIZATION ROLES MANAGEMENT ===
  
  /**
   * Liste les rôles d'une organisation
   * @param organizationId ID de l'organisation
   * @returns Liste des rôles
   */
  public async listOrganizationRoles(organizationId: string): Promise<any[]> {
    return await this.request<any[]>(`/organizations/${organizationId}/roles`);
  }

  /**
   * Assigne un rôle à un utilisateur dans une organisation
   * @param organizationId ID de l'organisation
   * @param userId ID de l'utilisateur
   * @param roleId ID du rôle
   * @returns true si l'assignation a réussi
   */
  public async assignOrganizationRoleToUser(organizationId: string, userId: string, roleId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/users/${userId}/roles`, {
        method: 'POST',
        body: JSON.stringify({ roleId })
      });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Retire un rôle à un utilisateur dans une organisation
   * @param organizationId ID de l'organisation
   * @param userId ID de l'utilisateur
   * @param roleId ID du rôle
   * @returns true si le retrait a réussi
   */
  public async removeOrganizationRoleFromUser(organizationId: string, userId: string, roleId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/users/${userId}/roles/${roleId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === ORGANIZATION SCOPES MANAGEMENT ===
  
  /**
   * Liste les scopes d'une organisation
   * @param organizationId ID de l'organisation
   * @returns Liste des scopes
   */
  public async listOrganizationScopes(organizationId: string): Promise<any[]> {
    return await this.request<any[]>(`/organizations/${organizationId}/scopes`);
  }

  /**
   * Ajoute un scope à une organisation
   * @param organizationId ID de l'organisation
   * @param scopeData Données du scope
   * @returns Scope ajouté
   */
  public async addOrganizationScope(organizationId: string, scopeData: any): Promise<any> {
    return await this.request<any>(`/organizations/${organizationId}/scopes`, {
      method: 'POST',
      body: JSON.stringify(scopeData)
    });
  }

  /**
   * Supprime un scope d'une organisation
   * @param organizationId ID de l'organisation
   * @param scopeId ID du scope
   * @returns true si la suppression a réussi
   */
  public async removeOrganizationScope(organizationId: string, scopeId: string): Promise<boolean> {
    try {
      await this.request<void>(`/organizations/${organizationId}/scopes/${scopeId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === PHRASES MANAGEMENT ===
  
  /**
   * Récupère les phrases
   * @returns Phrases
   */
  public async getPhrases(): Promise<any> {
    return await this.request<any>('/phrases');
  }

  // === SAML APPLICATIONS MANAGEMENT ===
  
  /**
   * Liste les applications SAML
   * @returns Liste des applications SAML
   */
  public async listSamlApplications(): Promise<any[]> {
    return await this.request<any[]>('/saml-applications');
  }

  /**
   * Récupère une application SAML
   * @param applicationId ID de l'application
   * @returns Application SAML
   */
  public async getSamlApplication(applicationId: string): Promise<any> {
    return await this.request<any>(`/saml-applications/${applicationId}`);
  }

  /**
   * Crée une application SAML
   * @param applicationData Données de l'application
   * @returns Application SAML créée
   */
  public async createSamlApplication(applicationData: any): Promise<any> {
    return await this.request<any>('/saml-applications', {
      method: 'POST',
      body: JSON.stringify(applicationData)
    });
  }

  /**
   * Met à jour une application SAML
   * @param applicationId ID de l'application
   * @param applicationData Données de l'application
   * @returns Application SAML mise à jour
   */
  public async updateSamlApplication(applicationId: string, applicationData: any): Promise<any> {
    return await this.request<any>(`/saml-applications/${applicationId}`, {
      method: 'PATCH',
      body: JSON.stringify(applicationData)
    });
  }

  /**
   * Supprime une application SAML
   * @param applicationId ID de l'application
   * @returns true si la suppression a réussi
   */
  public async deleteSamlApplication(applicationId: string): Promise<boolean> {
    try {
      await this.request<void>(`/saml-applications/${applicationId}`, {
        method: 'DELETE'
      });
      return true;
    } catch {
      return false;
    }
  }

  // === SSO CONNECTOR PROVIDERS MANAGEMENT ===
  
  /**
   * Liste les fournisseurs de connecteurs SSO
   * @returns Liste des fournisseurs
   */
  public async listSsoConnectorProviders(): Promise<any[]> {
    return await this.request<any[]>('/sso-connector-providers');
  }

  // === STATUS MANAGEMENT ===
  
  /**
   * Récupère le statut du système
   * @returns Statut
   */
  public async getStatus(): Promise<any> {
    return await this.request<any>('/status');
  }

  // === SUBJECT TOKENS MANAGEMENT ===
  
  /**
   * Crée un token de sujet
   * @param tokenData Données du token
   * @returns Token créé
   */
  public async createSubjectToken(tokenData: any): Promise<any> {
    return await this.request<any>('/subject-tokens', {
      method: 'POST',
      body: JSON.stringify(tokenData)
    });
  }

  // === SWAGGER MANAGEMENT ===
  
  /**
   * Récupère la documentation Swagger
   * @returns Documentation Swagger
   */
  public async getSwaggerDocs(): Promise<any> {
    return await this.request<any>('/swagger');
  }

  // === SYSTEM APP CONFIG MANAGEMENT ===
  
  /**
   * Récupère la configuration de l'application système
   * @returns Configuration
   */
  public async getSystemAppConfig(): Promise<any> {
    return await this.request<any>('/system-app-config');
  }

  /**
   * Met à jour la configuration de l'application système
   * @param configData Données de configuration
   * @returns Configuration mise à jour
   */
  public async updateSystemAppConfig(configData: any): Promise<any> {
    return await this.request<any>('/system-app-config', {
      method: 'PATCH',
      body: JSON.stringify(configData)
    });
  }

  // === WELL-KNOWN ENDPOINTS ===
  
  /**
   * Récupère les informations bien connues (well-known)
   * @param type Type d'information (openid-configuration, jwks.json, etc.)
   * @returns Informations bien connues
   */
  public async getWellKnown(type: string): Promise<any> {
    return await this.request<any>(`/.well-known/${type}`);
  }
} 