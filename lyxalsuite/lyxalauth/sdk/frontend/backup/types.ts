/**
 * Types pour le SDK frontend lyxalauth
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
}

export interface Role {
  id: string;
  name: string;
  description?: string;
  scopes?: string[];
}

export interface Organization {
  id: string;
  name: string;
  description?: string;
  logo?: string;
  createdAt: string;
  updatedAt: string;
}

export interface OrganizationRole {
  id: string;
  name: string;
  description?: string;
  organizationScopes?: string[];
  resourceScopes?: Record<string, string[]>;
}

export interface OrganizationInvitation {
  id: string;
  organizationId: string;
  email: string;
  expiresAt: string;
  createdAt: string;
  status: 'pending' | 'accepted' | 'expired';
}

export interface Application {
  id: string;
  name: string;
  description?: string;
  type: 'spa' | 'traditional' | 'native' | 'machine_to_machine';
  oidcClientMetadata: {
    redirectUris: string[];
    postLogoutRedirectUris: string[];
    clientUri?: string;
    logoUri?: string;
  };
  customClientMetadata?: Record<string, any>;
  createdAt: string;
}

export interface Resource {
  id: string;
  name: string;
  indicator: string;
  isDefault: boolean;
  accessTokenTtl: number;
  createdAt: string;
}

export interface Scope {
  id: string;
  name: string;
  description?: string;
  resourceId: string;
  createdAt: string;
}

export interface SignInExperience {
  id: string;
  branding: {
    logoUrl?: string;
    darkLogoUrl?: string;
    favicon?: string;
    appName?: string;
    colors?: Record<string, string>;
  };
  termsOfUseUrl?: string;
  privacyPolicyUrl?: string;
  languages: string[];
  signUp: {
    identifiers: Array<'username' | 'email' | 'phone' | 'social'>;
    password: boolean;
    verify: boolean;
  };
  signIn: {
    methods: Array<'password' | 'email' | 'phone' | 'social'>;
  };
}

export interface Connector {
  id: string;
  connectorId: string;
  connectorName: string;
  connectorType: 'social' | 'sms' | 'email';
  config: Record<string, any>;
  createdAt: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken?: string;
  idToken?: string;
  expiresIn: number;
  tokenType: string;
  scope?: string;
}

export interface VerificationCodeRequest {
  email?: string;
  phone?: string;
  purpose: 'SignIn' | 'Register' | 'ForgotPassword' | 'Generic';
}

export interface VerificationCodeVerify {
  code: string;
  email?: string;
  phone?: string;
}

export interface PaginationOptions {
  page?: number;
  pageSize?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  totalCount: number;
  pageSize: number;
  page: number;
} 