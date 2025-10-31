/**
 * @file logtoService.ts
 * @description Service pour interagir avec l'API Logto Cloud
 */

// @ts-ignore
import * as nodeFetch from 'node-fetch';
const fetch = nodeFetch.default || nodeFetch;

import { config } from '../config';
import { 
  AuthResponse, 
  AuthErrorResponse, 
  User, 
  ApiResource as Resource, 
  PaginatedResponse
} from '../../sdk/core/types';
import { mapError } from '../../sdk/core/utils';

/**
 * Service pour interagir avec l'API Logto Cloud
 */
export class LogtoService {
  private readonly endpoint: string;
  private readonly apiKey: string;
  private readonly appId: string;
  private readonly appSecret: string;
  private readonly audience: string;
  private readonly defaultScopes: string[];
  private accessToken: string | null = null;
  private tokenExpiresAt: number = 0;

  /**
   * Crée une instance du service Logto
   */
  constructor() {
    const { endpoint, apiKey, appId, appSecret, audience, defaultScopes } = config.logto;
    this.endpoint = endpoint;
    this.apiKey = apiKey;
    this.appId = appId;
    this.appSecret = appSecret;
    this.audience = audience;
    this.defaultScopes = defaultScopes;
  }

  /**
   * Obtient un token d'accès administrateur pour l'API Logto
   * @returns Token d'accès pour l'API
   */
  private async getAdminToken(): Promise<string> {
    // Vérifier si le token existant est toujours valide
    const now = Date.now();
    if (this.accessToken && this.tokenExpiresAt > now + 60000) {
      return this.accessToken;
    }

    try {
      const response = await fetch(`${this.endpoint}/api/access-token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`
        },
        body: JSON.stringify({
          resource: this.audience
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw {
          error: errorData.error || 'admin_token_error',
          error_description: errorData.error_description || 'Échec de récupération du token administrateur',
          status: response.status
        };
      }

      const data = await response.json();
      const accessToken = data.access_token;
      
      if (!accessToken) {
        throw new Error('Token d\'accès administrateur non reçu');
      }
      
      // Stocker le token et calculer l'expiration
      this.accessToken = accessToken;
      this.tokenExpiresAt = now + (data.expires_in * 1000);
      
      return accessToken;
    } catch (error) {
      console.error('Erreur lors de la récupération du token administrateur:', error);
      throw mapError(error);
    }
  }

  /**
   * Effectue une requête authentifiée vers l'API Logto
   * @param path Chemin de l'API
   * @param options Options de la requête
   * @returns Réponse de l'API
   */
  private async request<T>(
    path: string,
    options: RequestInit = {}
  ): Promise<T> {
    try {
      const token = await this.getAdminToken();
      
      // Convertir les headers existants en objet simple
      const existingHeaders = options.headers ? 
        (options.headers instanceof Headers ? 
          Object.fromEntries(options.headers.entries()) : 
          options.headers as Record<string, string>) : 
        {};
      
      // Créer un nouvel objet headers
      const headers: Record<string, string> = {
        'Authorization': `Bearer ${token}`,
        ...existingHeaders
      };

      // Ajouter Content-Type si nécessaire et non présent
      if (!headers['Content-Type'] && options.body) {
        headers['Content-Type'] = 'application/json';
      }
      
      // Créer un nouvel objet d'options en excluant body s'il est null
      const fetchOptions: RequestInit = {
        ...options,
        headers
      };
      
      // Supprimer body s'il est null pour éviter l'erreur de type
      if (fetchOptions.body === null) {
        delete fetchOptions.body;
      }
      
      const response = await fetch(`${this.endpoint}${path}`, fetchOptions);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({
          error: `http_error_${response.status}`,
          error_description: response.statusText
        }));
        
        throw {
          ...errorData,
          status: response.status
        };
      }
      
      // Vérifier si la réponse est vide
      const contentType = response.headers.get('content-type');
      if (contentType?.includes('application/json')) {
        return await response.json();
      }
      
      return {} as T;
    } catch (error) {
      console.error(`Erreur lors de la requête à ${path}:`, error);
      throw mapError(error);
    }
  }

  /**
   * Authentifie un utilisateur avec identifiant et mot de passe
   * @param username Nom d'utilisateur, email ou téléphone
   * @param password Mot de passe
   * @returns Réponse d'authentification avec tokens
   */
  public async login(username: string, password: string): Promise<AuthResponse> {
    try {
      const response = await fetch(`${this.endpoint}/api/token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          grant_type: 'password',
          username,
          password,
          client_id: this.appId,
          client_secret: this.appSecret,
          scope: this.defaultScopes.join(' ')
        })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw {
          error: errorData.error || 'login_failed',
          error_description: errorData.error_description || 'Échec de connexion',
          status: response.status
        };
      }
      
      const data = await response.json();
      
      return {
        accessToken: data.access_token,
        refreshToken: data.refresh_token,
        idToken: data.id_token,
        expiresIn: data.expires_in,
        tokenType: data.token_type,
        scope: data.scope
      };
    } catch (error) {
      console.error('Erreur lors de la connexion:', error);
      throw mapError(error);
    }
  }

  /**
   * Rafraîchit un token d'accès
   * @param refreshToken Token de rafraîchissement
   * @returns Nouveaux tokens
   */
  public async refreshToken(refreshToken: string): Promise<AuthResponse> {
    try {
      const response = await fetch(`${this.endpoint}/api/token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          grant_type: 'refresh_token',
          refresh_token: refreshToken,
          client_id: this.appId,
          client_secret: this.appSecret,
          scope: this.defaultScopes.join(' ')
        })
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw {
          error: errorData.error || 'refresh_token_failed',
          error_description: errorData.error_description || 'Échec du rafraîchissement du token',
          status: response.status
        };
      }
      
      const data = await response.json();
      
      return {
        accessToken: data.access_token,
        refreshToken: data.refresh_token,
        idToken: data.id_token,
        expiresIn: data.expires_in,
        tokenType: data.token_type,
        scope: data.scope
      };
    } catch (error) {
      console.error('Erreur lors du rafraîchissement du token:', error);
      throw mapError(error);
    }
  }

  /**
   * Récupère les informations d'un utilisateur
   * @param userId ID de l'utilisateur
   * @returns Informations utilisateur
   */
  public async getUser(userId: string): Promise<User> {
    return this.request<User>(`/api/users/${userId}`);
  }

  /**
   * Liste les utilisateurs
   * @param page Numéro de page
   * @param pageSize Taille de la page
   * @returns Liste paginée d'utilisateurs
   */
  public async listUsers(page: number = 1, pageSize: number = 20): Promise<PaginatedResponse<User>> {
    return this.request<PaginatedResponse<User>>(`/api/users?page=${page}&page_size=${pageSize}`);
  }

  /**
   * Crée un nouvel utilisateur
   * @param userData Données utilisateur
   * @returns Utilisateur créé
   */
  public async createUser(userData: Partial<User>): Promise<User> {
    return this.request<User>('/api/users', {
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
    return this.request<User>(`/api/users/${userId}`, {
      method: 'PATCH',
      body: JSON.stringify(userData)
    });
  }

  /**
   * Récupère une ressource API
   * @param resourceId ID de la ressource
   * @returns Ressource API
   */
  public async getResource(resourceId: string): Promise<Resource> {
    return this.request<Resource>(`/api/resources/${resourceId}`);
  }

  /**
   * Liste les ressources API
   * @param page Numéro de page
   * @param pageSize Taille de la page
   * @returns Liste paginée de ressources
   */
  public async listResources(page: number = 1, pageSize: number = 20): Promise<PaginatedResponse<Resource>> {
    return this.request<PaginatedResponse<Resource>>(`/api/resources?page=${page}&page_size=${pageSize}`);
  }

  /**
   * Vérifie la validité d'un token
   * @param token Token à vérifier
   * @returns true si le token est valide
   */
  public async verifyToken(token: string): Promise<boolean> {
    try {
      const response = await fetch(`${this.endpoint}/api/token/introspect`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          token,
          client_id: this.appId,
          client_secret: this.appSecret
        })
      });
      
      if (!response.ok) {
        return false;
      }
      
      const data = await response.json();
      return data.active === true;
    } catch (error) {
      console.error('Erreur lors de la vérification du token:', error);
      return false;
    }
  }
}

// Exporter une instance unique du service
export const logtoService = new LogtoService(); 