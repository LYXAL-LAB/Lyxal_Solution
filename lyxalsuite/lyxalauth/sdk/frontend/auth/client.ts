/**
 * @file client.ts
 * @description Client d'authentification pour le SDK frontend
 */

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
  UpdatePasswordRequest
} from '../../core/types';
import { getUserIdFromToken } from '../../core/auth';
import { mapError } from '../../core/utils';

/**
 * Options de configuration du client d'authentification frontend
 */
export interface AuthClientOptions {
  /** URL de base de la gateway */
  gatewayUrl: string;
  /** URL de redirection après connexion */
  redirectUri?: string;
  /** Activer les cookies sécurisés */
  secureCookies?: boolean;
  /** Temps d'expiration de la session locale en secondes */
  sessionExpirySeconds?: number;
  /** Fonction de callback lors d'une erreur d'authentification */
  onAuthError?: (error: AuthErrorResponse) => void;
}

/**
 * Client d'authentification pour le frontend
 */
export class AuthClient {
  private options: AuthClientOptions;
  private currentSession: UserSession | null = null;

  /**
   * Crée une instance du client d'authentification frontend
   * @param options Options de configuration
   */
  constructor(options: AuthClientOptions) {
    this.options = {
      sessionExpirySeconds: 3600, // 1 heure par défaut
      secureCookies: true,
      ...options
    };

    // Tenter de restaurer la session à l'initialisation
    this.restoreSession();
  }

  /**
   * Effectue une requête authentifiée vers la gateway
   * @param endpoint Point de terminaison de l'API
   * @param options Options de la requête fetch
   * @returns Réponse de l'API
   */
  private async request<T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.options.gatewayUrl}/api/auth${endpoint}`;
    
    // Préparer les headers par défaut
    const headers = new Headers(options.headers);
    if (!headers.has('Content-Type') && options.body) {
      headers.set('Content-Type', 'application/json');
    }
    
    // Credentials nécessaires pour les cookies
    const credentials: RequestCredentials = 'include';
    
    try {
      const response = await fetch(url, {
        ...options,
        headers,
        credentials
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
    }
  }

  /**
   * Restaure la session depuis le serveur
   * @returns Session restaurée ou null
   */
  public async restoreSession(): Promise<UserSession | null> {
    try {
      const session = await this.request<UserSession>('/session');
      if (session && session.isAuthenticated) {
        this.currentSession = session;
        return session;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Authentifie un utilisateur avec identifiant et mot de passe
   * @param credentials Identifiants de connexion
   * @returns Session utilisateur
   */
  public async login(credentials: LoginRequest): Promise<UserSession> {
    const response = await this.request<AuthResponse>('/login', {
      method: 'POST',
      body: JSON.stringify(credentials)
    });
    
    // La session sera mise à jour côté serveur et gérée par les cookies
    // Récupérer la session complète
    const session = await this.restoreSession();
    if (!session) {
      throw {
        error: 'session_error',
        error_description: 'Impossible de récupérer la session après connexion',
        status: 500
      };
    }
    
    return session;
  }

  /**
   * Enregistre un nouvel utilisateur
   * @param userData Données utilisateur pour l'enregistrement
   * @returns Session utilisateur ou null si confirmation requise
   */
  public async register(userData: RegisterRequest): Promise<UserSession | null> {
    await this.request<{ success: boolean }>('/register', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
    
    // Dans certains cas, l'utilisateur peut être connecté automatiquement
    try {
      return await this.restoreSession();
    } catch {
      return null;
    }
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
      
      this.currentSession = null;
      return true;
    } catch {
      return false;
    }
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
   * Met à jour le mot de passe de l'utilisateur connecté
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
   * Récupère le profil de l'utilisateur courant
   * @returns Profil utilisateur
   */
  public async getProfile(): Promise<User> {
    return await this.request<User>('/profile');
  }

  /**
   * Met à jour le profil de l'utilisateur courant
   * @param userData Données à mettre à jour
   * @returns Profil utilisateur mis à jour
   */
  public async updateProfile(userData: Partial<User>): Promise<User> {
    return await this.request<User>('/profile', {
      method: 'PATCH',
      body: JSON.stringify(userData)
    });
  }

  /**
   * Récupère la session utilisateur courante
   * @returns Session utilisateur ou null
   */
  public async getSession(): Promise<UserSession | null> {
    // Toujours tenter de récupérer la session depuis le serveur pour être sûr
    return await this.restoreSession();
  }

  /**
   * Vérifie si l'utilisateur est authentifié
   * @returns true si l'utilisateur est authentifié
   */
  public async isAuthenticated(): Promise<boolean> {
    const session = await this.getSession();
    return !!session?.isAuthenticated;
  }

  // Fonctionnalités Applications
  
  /**
   * Récupère toutes les applications
   * @returns Liste des applications
   */
  public async getApplications(): Promise<any[]> {
    return await this.request<any[]>('/applications');
  }
  
  /**
   * Récupère une application par son ID
   * @param id ID de l'application
   * @returns Détails de l'application
   */
  public async getApplication(id: string): Promise<any> {
    return await this.request<any>(`/applications/${id}`);
  }
  
  /**
   * Crée une nouvelle application
   * @param applicationData Données de l'application
   * @returns Application créée
   */
  public async createApplication(applicationData: any): Promise<any> {
    return await this.request<any>('/applications', {
      method: 'POST',
      body: JSON.stringify(applicationData)
    });
  }
  
  /**
   * Met à jour une application
   * @param id ID de l'application
   * @param applicationData Données à mettre à jour
   * @returns Application mise à jour
   */
  public async updateApplication(id: string, applicationData: any): Promise<any> {
    return await this.request<any>(`/applications/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(applicationData)
    });
  }
  
  /**
   * Supprime une application
   * @param id ID de l'application
   * @returns Résultat de la suppression
   */
  public async deleteApplication(id: string): Promise<any> {
    return await this.request<any>(`/applications/${id}`, {
      method: 'DELETE'
    });
  }
  
  // Fonctionnalités Rôles
  
  /**
   * Récupère tous les rôles
   * @returns Liste des rôles
   */
  public async getRoles(): Promise<any[]> {
    return await this.request<any[]>('/roles');
  }
  
  /**
   * Récupère un rôle par son ID
   * @param id ID du rôle
   * @returns Détails du rôle
   */
  public async getRole(id: string): Promise<any> {
    return await this.request<any>(`/roles/${id}`);
  }
  
  /**
   * Crée un nouveau rôle
   * @param roleData Données du rôle
   * @returns Rôle créé
   */
  public async createRole(roleData: any): Promise<any> {
    return await this.request<any>('/roles', {
      method: 'POST',
      body: JSON.stringify(roleData)
    });
  }
  
  /**
   * Met à jour un rôle
   * @param id ID du rôle
   * @param roleData Données à mettre à jour
   * @returns Rôle mis à jour
   */
  public async updateRole(id: string, roleData: any): Promise<any> {
    return await this.request<any>(`/roles/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(roleData)
    });
  }
  
  /**
   * Supprime un rôle
   * @param id ID du rôle
   * @returns Résultat de la suppression
   */
  public async deleteRole(id: string): Promise<any> {
    return await this.request<any>(`/roles/${id}`, {
      method: 'DELETE'
    });
  }
  
  // Fonctionnalités Ressources
  
  /**
   * Récupère toutes les ressources
   * @returns Liste des ressources
   */
  public async getResources(): Promise<any[]> {
    return await this.request<any[]>('/resources');
  }
  
  /**
   * Récupère une ressource par son ID
   * @param id ID de la ressource
   * @returns Détails de la ressource
   */
  public async getResource(id: string): Promise<any> {
    return await this.request<any>(`/resources/${id}`);
  }
  
  /**
   * Crée une nouvelle ressource
   * @param resourceData Données de la ressource
   * @returns Ressource créée
   */
  public async createResource(resourceData: any): Promise<any> {
    return await this.request<any>('/resources', {
      method: 'POST',
      body: JSON.stringify(resourceData)
    });
  }
  
  /**
   * Met à jour une ressource
   * @param id ID de la ressource
   * @param resourceData Données à mettre à jour
   * @returns Ressource mise à jour
   */
  public async updateResource(id: string, resourceData: any): Promise<any> {
    return await this.request<any>(`/resources/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(resourceData)
    });
  }
  
  /**
   * Supprime une ressource
   * @param id ID de la ressource
   * @returns Résultat de la suppression
   */
  public async deleteResource(id: string): Promise<any> {
    return await this.request<any>(`/resources/${id}`, {
      method: 'DELETE'
    });
  }
  
  // Fonctionnalités Organisations
  
  /**
   * Récupère toutes les organisations
   * @returns Liste des organisations
   */
  public async getOrganizations(): Promise<any[]> {
    return await this.request<any[]>('/organizations');
  }
  
  /**
   * Récupère une organisation par son ID
   * @param id ID de l'organisation
   * @returns Détails de l'organisation
   */
  public async getOrganization(id: string): Promise<any> {
    return await this.request<any>(`/organizations/${id}`);
  }
  
  /**
   * Crée une nouvelle organisation
   * @param organizationData Données de l'organisation
   * @returns Organisation créée
   */
  public async createOrganization(organizationData: any): Promise<any> {
    return await this.request<any>('/organizations', {
      method: 'POST',
      body: JSON.stringify(organizationData)
    });
  }
  
  /**
   * Met à jour une organisation
   * @param id ID de l'organisation
   * @param organizationData Données à mettre à jour
   * @returns Organisation mise à jour
   */
  public async updateOrganization(id: string, organizationData: any): Promise<any> {
    return await this.request<any>(`/organizations/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(organizationData)
    });
  }
  
  /**
   * Supprime une organisation
   * @param id ID de l'organisation
   * @returns Résultat de la suppression
   */
  public async deleteOrganization(id: string): Promise<any> {
    return await this.request<any>(`/organizations/${id}`, {
      method: 'DELETE'
    });
  }
  
  // Autres fonctionnalités peuvent être ajoutées de manière similaire...
  
  // Fonctionnalités Utilisateurs (plus détaillées que getProfile/updateProfile)
  
  /**
   * Récupère tous les utilisateurs
   * @returns Liste des utilisateurs
   */
  public async getUsers(): Promise<any[]> {
    return await this.request<any[]>('/users');
  }
  
  /**
   * Récupère un utilisateur par son ID
   * @param id ID de l'utilisateur
   * @returns Détails de l'utilisateur
   */
  public async getUser(id: string): Promise<any> {
    return await this.request<any>(`/users/${id}`);
  }
  
  /**
   * Crée un nouvel utilisateur
   * @param userData Données de l'utilisateur
   * @returns Utilisateur créé
   */
  public async createUser(userData: any): Promise<any> {
    return await this.request<any>('/users', {
      method: 'POST',
      body: JSON.stringify(userData)
    });
  }
  
  /**
   * Met à jour un utilisateur
   * @param id ID de l'utilisateur
   * @param userData Données à mettre à jour
   * @returns Utilisateur mis à jour
   */
  public async updateUser(id: string, userData: any): Promise<any> {
    return await this.request<any>(`/users/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(userData)
    });
  }
  
  /**
   * Supprime un utilisateur
   * @param id ID de l'utilisateur
   * @returns Résultat de la suppression
   */
  public async deleteUser(id: string): Promise<any> {
    return await this.request<any>(`/users/${id}`, {
      method: 'DELETE'
    });
  }
} 