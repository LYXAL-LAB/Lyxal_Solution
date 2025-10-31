import { z } from 'zod';

/**
 * Schéma pour la mise à jour de l'expérience de connexion
 * @typedef {z.infer<typeof updateSignInExperienceSchema>} UpdateSignInExperienceInput
 */
export const updateSignInExperienceSchema = z.object({
  branding: z.object({
    logoUrl: z.string().url({ message: 'L\'URL du logo doit être une URL valide' }).optional(),
    darkLogoUrl: z.string().url({ message: 'L\'URL du logo en mode sombre doit être une URL valide' }).optional(),
    favicon: z.string().url({ message: 'L\'URL du favicon doit être une URL valide' }).optional(),
    darkFavicon: z.string().url({ message: 'L\'URL du favicon en mode sombre doit être une URL valide' }).optional(),
    appName: z.record(z.string()).optional().describe('Le nom de l\'application doit être un objet de chaînes'),
    appNameAlt: z.record(z.string()).optional().describe('Le nom alternatif de l\'application doit être un objet de chaînes'),
    themeOverride: z.record(z.any()).optional().describe('Le thème personnalisé doit être un objet'),
  }).optional(),
  color: z.object({
    primaryColor: z.string().regex(/^#[\da-f]{3}([\da-f]{3})?$/i, { message: 'La couleur primaire doit être au format hexadécimal' }).optional(),
    isDarkModeEnabled: z.boolean().optional().describe('Le mode sombre doit être un booléen'),
    darkPrimaryColor: z.string().regex(/^#[\da-f]{3}([\da-f]{3})?$/i, { message: 'La couleur primaire en mode sombre doit être au format hexadécimal' }).optional(),
  }).optional(),
  customCSS: z.string().optional().describe('Le CSS personnalisé doit être une chaîne'),
  customCSSEnabled: z.boolean().optional().describe('L\'activation du CSS personnalisé doit être un booléen'),
  languageInfo: z.object({
    autoDetect: z.boolean().optional().describe('La détection automatique doit être un booléen'),
    fallbackLanguage: z.string().optional().describe('La langue par défaut doit être une chaîne'),
  }).optional(),
  termsEnabled: z.boolean().optional().describe('L\'activation des conditions d\'utilisation doit être un booléen'),
  termsUrl: z.record(z.string().url({ message: 'L\'URL des conditions d\'utilisation doit être une URL valide' })).optional(),
  privacyEnabled: z.boolean().optional().describe('L\'activation de la politique de confidentialité doit être un booléen'),
  privacyUrl: z.record(z.string().url({ message: 'L\'URL de la politique de confidentialité doit être une URL valide' })).optional(),
  signIn: z.object({
    methods: z.array(
      z.object({
        identifier: z.enum(['username', 'email', 'phone']).describe('L\'identifiant doit être username, email ou phone'),
        password: z.boolean().describe('Le mot de passe doit être un booléen'),
        verificationCode: z.boolean().describe('Le code de vérification doit être un booléen'),
        isPasswordPrimary: z.boolean().describe('La primauté du mot de passe doit être un booléen'),
      })
    ).optional(),
  }).optional(),
  signUp: z.object({
    identifiers: z.array(z.enum(['username', 'email', 'phone']).describe('Les identifiants doivent être username, email ou phone')).optional(),
    password: z.boolean().optional().describe('Le mot de passe doit être un booléen'),
    verify: z.boolean().optional().describe('La vérification doit être un booléen'),
    secondaryIdentifiers: z.array(
      z.object({
        identifier: z.union([
          z.enum(['username', 'email', 'phone']).describe('L\'identifiant secondaire doit être username, email ou phone'),
          z.literal('emailOrPhone')
        ]),
        verify: z.boolean().optional().describe('La vérification doit être un booléen'),
      })
    ).optional(),
  }).optional(),
  mfa: z.object({
    factors: z.array(z.enum(['Totp', 'WebAuthn', 'BackupCode']).describe('Les facteurs MFA doivent être Totp, WebAuthn ou BackupCode')).optional(),
    policy: z.enum(['UserControlled', 'Mandatory', 'PromptOnlyAtSignIn', 'PromptAtSignInAndSignUp', 'NoPrompt'])
      .describe('La politique MFA doit être UserControlled, Mandatory, PromptOnlyAtSignIn, PromptAtSignInAndSignUp ou NoPrompt').optional(),
    organizationRequiredMfaPolicy: z.enum(['NoPrompt', 'Mandatory'])
      .describe('La politique MFA obligatoire pour l\'organisation doit être NoPrompt ou Mandatory').optional(),
  }).optional(),
  passwordPolicy: z.object({
    length: z.object({
      min: z.number().min(1, { message: 'La longueur minimale doit être d\'au moins 1' }).optional(),
      max: z.number().min(8, { message: 'La longueur maximale doit être d\'au moins 8' }).optional(),
    }).optional(),
    characterTypes: z.object({
      min: z.number().min(0, { message: 'Le nombre minimum de types de caractères doit être d\'au moins 0' }).optional(),
    }).optional(),
    rejects: z.object({
      pwned: z.boolean().optional().describe('Le rejet des mots de passe compromis doit être un booléen'),
      repetitionAndSequence: z.boolean().optional().describe('Le rejet des répétitions et séquences doit être un booléen'),
      userInfo: z.boolean().optional().describe('Le rejet des informations utilisateur doit être un booléen'),
      words: z.array(z.string().describe('Les mots rejetés doivent être des chaînes')).optional(),
    }).optional(),
  }).optional(),
}).partial();

/**
 * Schéma pour la récupération de l'expérience de connexion
 * @typedef {z.infer<typeof getSignInExperienceSchema>} GetSignInExperienceInput
 */
export const getSignInExperienceSchema = z.object({
  organizationId: z.string().optional().describe('L\'ID de l\'organisation doit être une chaîne'),
  appId: z.string().optional().describe('L\'ID de l\'application doit être une chaîne')
});

/**
 * Schéma pour la vérification de politique de mot de passe
 * @typedef {z.infer<typeof checkPasswordPolicySchema>} CheckPasswordPolicyInput
 */
export const checkPasswordPolicySchema = z.object({
  password: z.string().min(1, { message: 'Le mot de passe est requis' }),
  username: z.string().optional().describe('Nom d\'utilisateur à vérifier'),
  name: z.string().optional().describe('Nom à vérifier'),
  email: z.string().email({ message: 'L\'email doit être valide' }).optional().describe('Email à vérifier'),
});

export type UpdateSignInExperienceInput = z.infer<typeof updateSignInExperienceSchema>;
export type GetSignInExperienceInput = z.infer<typeof getSignInExperienceSchema>;
export type CheckPasswordPolicyInput = z.infer<typeof checkPasswordPolicySchema>; 