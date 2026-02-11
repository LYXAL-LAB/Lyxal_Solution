/**
 * @file types.ts
 * @description Types partagés pour tous les modules lyxalauth (backend, frontend, gateway)
 */

/**
 * Interface pour un utilisateur
 */
export interface User {
  id: string;
  username?: string;
  primaryEmail?: string;
  primaryPhone?: string;
  name?: string;
  avatar?: string;
  customData?: Record<string, any>;
  identities?: Record<string, any>;
  lastSignInAt?: string;
  createdAt: string;
  applicationId?: string;
  isSuspended?: boolean;
  isDeleted?: boolean;
}

/**
 * Interface pour une session utilisateur
 */
export interface UserSession {
  userId: string;
  accessToken: string;
  refreshToken?: string;
  idToken?: string;
  expiresAt: number;
  isAuthenticated: boolean;
  user?: User;
}

/**
 * Interface pour un token décodé
 */
export interface DecodedToken {
  sub: string;
  iss: string;
  aud: string;
  exp: number;
  iat: number;
  scope?: string;
  roles?: string[];
  [key: string]: any;
}

/**
 * Interface pour la réponse d'authentification
 */
export interface AuthResponse {
  accessToken: string;
  refreshToken?: string;
  idToken?: string;
  expiresIn: number;
  tokenType: string;
  scope?: string;
}

/**
 * Interface pour la réponse d'erreur d'authentification
 */
export interface AuthErrorResponse {
  error: string;
  error_description?: string;
  status?: number;
}

/**
 * Interface pour un rôle utilisateur
 */
export interface Role {
  id: string;
  name: string;
  description?: string;
  scopes?: string[];
}

/**
 * Interface pour un rôle d'organisation
 */
export interface OrganizationRole {
  id: string;
  name: string;
  description?: string;
  organizationScopes?: string[];
  resourceScopes?: Record<string, string[]>;
}

/**
 * Interface pour une organisation
 */
export interface Organization {
  id: string;
  name: string;
  description?: string;
  logo?: string;
  users?: string[];
  roles?: OrganizationRole[];
  createdAt: string;
  updatedAt: string;
}

/**
 * Interface pour une application
 */
export interface Application {
  id: string;
  name: string;
  description?: string;
  type: 'native' | 'spa' | 'traditional' | 'machine_to_machine';
  oidcClientMetadata?: {
    redirectUris?: string[];
    postLogoutRedirectUris?: string[];
    clientUri?: string;
    logoUri?: string;
  };
  customClientMetadata?: Record<string, any>;
  createdAt: string;
}

/**
 * Interface pour une ressource API
 */
export interface ApiResource {
  id: string;
  name: string;
  identifier: string;
  scopes: Array<{
    name: string;
    description?: string;
  }>;
  accessTokenTtl?: number;
  createdAt: string;
}

/**
 * Interface pour les options de pagination
 */
export interface PaginationOptions {
  page?: number;
  pageSize?: number;
}

/**
 * Interface pour une réponse paginée
 */
export interface PaginatedResponse<T> {
  items: T[];
  totalCount: number;
  hasNextPage: boolean;
}

/**
 * Interface pour un connecteur
 */
export interface Connector {
  id: string;
  type: string;
  name: string;
  logo?: string;
  logoDark?: string;
  target: string[];
  config: Record<string, any>;
  enabled: boolean;
  createdAt: string;
}

/**
 * Interface pour l'expérience de connexion
 */
export interface SignInExperience {
  id: string;
  branding: {
    logoUrl?: string;
    darkLogoUrl?: string;
    favicon?: string;
    appName?: string;
    colors?: {
      primary?: string;
      background?: string;
      text?: string;
    };
  };
  language: {
    default: string;
    supported: string[];
  };
  terms?: {
    enabled: boolean;
    url?: string;
  };
  privacy?: {
    enabled: boolean;
    url?: string;
  };
  methods: {
    username?: {
      enabled: boolean;
      register?: boolean;
      signIn?: boolean;
    };
    email?: {
      enabled: boolean;
      register?: boolean;
      signIn?: boolean;
      verification?: boolean;
    };
    phone?: {
      enabled: boolean;
      register?: boolean;
      signIn?: boolean;
      verification?: boolean;
    };
    social?: {
      enabled: boolean;
      connectors?: string[];
    };
  };
  mfa?: {
    enabled: boolean;
    required?: boolean;
    options?: string[];
  };
  createdAt: string;
  updatedAt: string;
}

/**
 * Types pour les requêtes d'authentification
 */
export interface LoginRequest {
  username?: string;
  email?: string;
  phone?: string;
  password: string;
}

export interface RegisterRequest {
  username?: string;
  email?: string;
  phone?: string;
  password?: string;
  name?: string;
  customData?: Record<string, any>;
}

export interface VerificationCodeRequest {
  email?: string;
  phone?: string;
  purpose: 'SignIn' | 'Register' | 'ForgotPassword' | 'ResetPassword';
}

export interface VerificationCodeVerify {
  email?: string;
  phone?: string;
  code: string;
  purpose: 'SignIn' | 'Register' | 'ForgotPassword' | 'ResetPassword';
}

export interface ResetPasswordRequest {
  token: string;
  password: string;
}

export interface UpdatePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

/**
 * Types pour les hooks
 */
export interface WebhookEvent {
  event: string;
  payload: Record<string, any>;
  timestamp: number;
  signature?: string;
}

/**
 * Types pour l'audit
 */
export interface AuditLog {
  id: string;
  userId?: string;
  action: string;
  resource: string;
  resourceId?: string;
  data?: Record<string, any>;
  ip?: string;
  userAgent?: string;
  timestamp: number;
} 