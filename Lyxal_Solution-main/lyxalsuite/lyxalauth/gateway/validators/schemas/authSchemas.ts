/**
 * @file authSchemas.ts
 * @description Schémas de validation Zod pour les routes d'authentification
 */

import { z } from 'zod';

/**
 * Schéma pour la connexion utilisateur
 * @description Valide les informations d'identification pour la connexion
 * @property {string} [username] - Nom d'utilisateur (optionnel si email ou phone fourni)
 * @property {string} [email] - Adresse email au format valide (optionnel si username ou phone fourni)
 * @property {string} [phone] - Numéro de téléphone (optionnel si username ou email fourni)
 * @property {string} password - Mot de passe (requis)
 */
export const loginSchema = z.object({
  username: z.string().optional().describe("Nom d'utilisateur"),
  email: z.string().email("Format d'email invalide").optional().describe("Adresse email"),
  phone: z.string().optional().describe("Numéro de téléphone"),
  password: z.string().min(1, "Le mot de passe est requis").describe("Mot de passe"),
}).refine(
  data => !!(data.username || data.email || data.phone),
  {
    message: "Au moins un identifiant (username, email ou téléphone) est requis",
    path: ["username"]
  }
);

/**
 * Type inféré du schéma de connexion
 */
export type Login = z.infer<typeof loginSchema>;

/**
 * Schéma pour la vérification de token
 * @description Valide le token pour vérification
 * @property {string} token - Token à vérifier (requis)
 */
export const verifyTokenSchema = z.object({
  token: z.string().min(1, "Le token est requis").describe("Token d'authentification")
});

/**
 * Type inféré du schéma de vérification de token
 */
export type VerifyToken = z.infer<typeof verifyTokenSchema>;

/**
 * Schéma pour le rafraîchissement de token
 * @description Valide le refresh token pour obtenir un nouveau token d'accès
 * @property {string} refreshToken - Refresh token (requis)
 */
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, "Le refresh token est requis").describe("Token de rafraîchissement")
});

/**
 * Type inféré du schéma de rafraîchissement de token
 */
export type RefreshToken = z.infer<typeof refreshTokenSchema>;

/**
 * Schéma pour l'inscription utilisateur
 * @description Valide les données pour l'inscription d'un nouvel utilisateur
 * @property {string} username - Nom d'utilisateur (min 3 caractères)
 * @property {string} email - Adresse email au format valide
 * @property {string} password - Mot de passe respectant les règles de complexité
 * @property {string} [name] - Nom complet (optionnel)
 * @property {string} [phone] - Numéro de téléphone (optionnel)
 * @property {object} [customData] - Données personnalisées (optionnel)
 */
export const registerSchema = z.object({
  username: z.string().min(3, "Le nom d'utilisateur doit comporter au moins 3 caractères").describe("Nom d'utilisateur"),
  email: z.string().email("Format d'email invalide").describe("Adresse email"),
  password: z.string().min(8, "Le mot de passe doit comporter au moins 8 caractères")
    .regex(/[A-Z]/, "Le mot de passe doit contenir au moins une majuscule")
    .regex(/[a-z]/, "Le mot de passe doit contenir au moins une minuscule")
    .regex(/[0-9]/, "Le mot de passe doit contenir au moins un chiffre")
    .regex(/[^A-Za-z0-9]/, "Le mot de passe doit contenir au moins un caractère spécial")
    .describe("Mot de passe"),
  name: z.string().optional().describe("Nom complet"),
  phone: z.string().optional().describe("Numéro de téléphone"),
  customData: z.record(z.unknown()).optional().describe("Données personnalisées")
});

/**
 * Type inféré du schéma d'inscription
 */
export type Register = z.infer<typeof registerSchema>;

/**
 * Schéma pour la demande de réinitialisation de mot de passe
 * @description Valide l'email pour une demande de réinitialisation de mot de passe
 * @property {string} email - Adresse email au format valide
 */
export const resetPasswordRequestSchema = z.object({
  email: z.string().email("Format d'email invalide").describe("Adresse email")
});

/**
 * Type inféré du schéma de demande de réinitialisation de mot de passe
 */
export type ResetPasswordRequest = z.infer<typeof resetPasswordRequestSchema>;

/**
 * Schéma pour la confirmation de réinitialisation de mot de passe
 * @description Valide le token et le nouveau mot de passe pour finaliser la réinitialisation
 * @property {string} token - Token de réinitialisation (requis)
 * @property {string} password - Nouveau mot de passe respectant les règles de complexité
 */
export const resetPasswordConfirmSchema = z.object({
  token: z.string().min(1, "Le token est requis").describe("Token de réinitialisation"),
  password: z.string().min(8, "Le mot de passe doit comporter au moins 8 caractères")
    .regex(/[A-Z]/, "Le mot de passe doit contenir au moins une majuscule")
    .regex(/[a-z]/, "Le mot de passe doit contenir au moins une minuscule")
    .regex(/[0-9]/, "Le mot de passe doit contenir au moins un chiffre")
    .regex(/[^A-Za-z0-9]/, "Le mot de passe doit contenir au moins un caractère spécial")
    .describe("Nouveau mot de passe")
});

/**
 * Type inféré du schéma de confirmation de réinitialisation de mot de passe
 */
export type ResetPasswordConfirm = z.infer<typeof resetPasswordConfirmSchema>; 