/**
 * @file AppError.ts
 * @description Classe de base pour les erreurs typées de l'application
 */

/**
 * Codes d'erreur standardisés
 */
export enum ErrorCode {
  // Erreurs d'authentification (1000-1999)
  UNAUTHORIZED = 1000,
  INVALID_CREDENTIALS = 1001,
  TOKEN_EXPIRED = 1002,
  TOKEN_INVALID = 1003,
  INSUFFICIENT_PERMISSIONS = 1004,
  ACCOUNT_LOCKED = 1005,
  MFA_REQUIRED = 1006,
  
  // Erreurs de validation (2000-2999)
  VALIDATION_ERROR = 2000,
  INVALID_INPUT = 2001,
  MISSING_REQUIRED_FIELD = 2002,
  INVALID_FORMAT = 2003,
  BAD_REQUEST = 2004,
  
  // Erreurs de ressources (3000-3999)
  RESOURCE_NOT_FOUND = 3000,
  RESOURCE_ALREADY_EXISTS = 3001,
  RESOURCE_CONFLICT = 3002,
  
  // Erreurs de limites (4000-4999)
  RATE_LIMIT_EXCEEDED = 4000,
  QUOTA_EXCEEDED = 4001,
  
  // Erreurs de sécurité (5000-5999)
  CSRF_VALIDATION_FAILED = 5000,
  FORBIDDEN_OPERATION = 5001,
  
  // Erreurs externes (6000-6999)
  EXTERNAL_SERVICE_ERROR = 6000,
  NETWORK_ERROR = 6001,
  TIMEOUT_ERROR = 6002,
  
  // Erreurs système (9000-9999)
  INTERNAL_SERVER_ERROR = 9000,
  NOT_IMPLEMENTED = 9001,
  SERVICE_UNAVAILABLE = 9002,
  DATABASE_ERROR = 9003
}

/**
 * Correspondance entre les codes d'erreur et les codes HTTP
 */
export const ERROR_HTTP_STATUS: Record<ErrorCode, number> = {
  // Erreurs d'authentification
  [ErrorCode.UNAUTHORIZED]: 401,
  [ErrorCode.INVALID_CREDENTIALS]: 401,
  [ErrorCode.TOKEN_EXPIRED]: 401,
  [ErrorCode.TOKEN_INVALID]: 401,
  [ErrorCode.INSUFFICIENT_PERMISSIONS]: 403,
  [ErrorCode.ACCOUNT_LOCKED]: 403,
  [ErrorCode.MFA_REQUIRED]: 401,
  
  // Erreurs de validation
  [ErrorCode.VALIDATION_ERROR]: 400,
  [ErrorCode.INVALID_INPUT]: 400,
  [ErrorCode.MISSING_REQUIRED_FIELD]: 400,
  [ErrorCode.INVALID_FORMAT]: 400,
  [ErrorCode.BAD_REQUEST]: 400,
  
  // Erreurs de ressources
  [ErrorCode.RESOURCE_NOT_FOUND]: 404,
  [ErrorCode.RESOURCE_ALREADY_EXISTS]: 409,
  [ErrorCode.RESOURCE_CONFLICT]: 409,
  
  // Erreurs de limites
  [ErrorCode.RATE_LIMIT_EXCEEDED]: 429,
  [ErrorCode.QUOTA_EXCEEDED]: 429,
  
  // Erreurs de sécurité
  [ErrorCode.CSRF_VALIDATION_FAILED]: 403,
  [ErrorCode.FORBIDDEN_OPERATION]: 403,
  
  // Erreurs externes
  [ErrorCode.EXTERNAL_SERVICE_ERROR]: 502,
  [ErrorCode.NETWORK_ERROR]: 502,
  [ErrorCode.TIMEOUT_ERROR]: 504,
  
  // Erreurs système
  [ErrorCode.INTERNAL_SERVER_ERROR]: 500,
  [ErrorCode.NOT_IMPLEMENTED]: 501,
  [ErrorCode.SERVICE_UNAVAILABLE]: 503,
  [ErrorCode.DATABASE_ERROR]: 500
};

/**
 * Interface pour les données supplémentaires d'erreur
 */
export interface ErrorDetails {
  [key: string]: any;
}

/**
 * Classe de base pour les erreurs typées de l'application
 */
export class AppError extends Error {
  readonly code: ErrorCode;
  readonly httpStatus: number;
  readonly details?: ErrorDetails;
  readonly isOperational: boolean;
  
  /**
   * Constructeur
   * @param message Message d'erreur
   * @param code Code d'erreur
   * @param details Détails supplémentaires (pour le logging, pas exposés au client)
   * @param isOperational Indique si l'erreur est opérationnelle (attendue) ou programmation
   */
  constructor(
    message: string,
    code: ErrorCode = ErrorCode.INTERNAL_SERVER_ERROR,
    details?: ErrorDetails,
    isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    this.httpStatus = ERROR_HTTP_STATUS[code] || 500;
    this.details = details;
    this.isOperational = isOperational;
    
    // Capturer la stack trace
    Error.captureStackTrace(this, this.constructor);
  }
  
  /**
   * Convertit l'erreur en objet pour la réponse API
   * Ne renvoie que les informations sécurisées
   */
  toJSON() {
    return {
      error: this.name,
      code: this.code,
      message: this.message,
      status: this.httpStatus
    };
  }
} 