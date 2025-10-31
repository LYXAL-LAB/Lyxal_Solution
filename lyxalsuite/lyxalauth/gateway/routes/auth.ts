/**
 * @file auth.ts
 * @description Routes d'authentification pour la Gateway
 */

import { Hono } from 'hono';
import { logtoService } from '../services/logtoService';
import { 
  authMiddleware, 
  apiKeyMiddleware, 
  setTokenCookies, 
  clearTokenCookies 
} from '../middleware/honoAuthMiddleware';
import { getUserIdFromToken } from '../../sdk/core/auth';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { validateZod } from '../validators/validateZod';
import { 
  loginSchema, 
  verifyTokenSchema, 
  refreshTokenSchema, 
  registerSchema,
  resetPasswordRequestSchema,
  resetPasswordConfirmSchema
} from '../validators/schemas/authSchemas';
import { updateUserSchema } from '../validators/schemas/userSchemas';

const router = new Hono();

/**
 * @route POST /login
 * @description Connecte un utilisateur et retourne une session avec tokens
 * @access Public
 */
router.post('/login', validateZod({ body: loginSchema }), async (c) => {
  try {
    logger.info('Tentative de connexion utilisateur', 'auth');
    const validatedData = c.get('validatedBody');
    
    // Déterminer l'identifiant à utiliser
    const identifier = validatedData.username || validatedData.email || validatedData.phone;
    
    // Appeler le service Logto pour l'authentification
    const authResponse = await logtoService.login(identifier, validatedData.password);
    
    // Définir les cookies pour les tokens
    setTokenCookies(c, authResponse.accessToken, authResponse.refreshToken);
    
    // Récupérer l'ID utilisateur depuis le token
    const userId = getUserIdFromToken(authResponse.accessToken);
    
    if (!userId) {
      logger.error('Impossible d\'extraire l\'ID utilisateur du token', 'auth');
      return c.json({
        error: 'invalid_token',
        error_description: 'Impossible d\'extraire l\'ID utilisateur du token',
        status: 500
      }, 500);
    }
    
    // Récupérer les informations de l'utilisateur
    const user = await logtoService.getUser(userId);
    
    logger.info('Connexion utilisateur réussie', 'auth', { userId });
    
    // Renvoyer la session utilisateur
    return c.json({
      userId,
      accessToken: authResponse.accessToken,
      expiresAt: Math.floor(Date.now() / 1000) + authResponse.expiresIn,
      isAuthenticated: true,
      user
    }, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la connexion: ${error.message}`, 'auth', { 
      error: error.error || 'login_failed',
      error_description: error.error_description || 'Erreur lors de la connexion'
    });
    
    return c.json({
      error: error.error || 'login_failed',
      error_description: error.error_description || 'Erreur lors de la connexion',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route POST /logout
 * @description Déconnecte un utilisateur en supprimant les tokens
 * @access Public
 */
router.post('/logout', (c) => {
  logger.info('Déconnexion utilisateur', 'auth');
  
  // Supprimer les cookies
  clearTokenCookies(c);
  
  return c.json({
    success: true,
    message: 'Déconnexion réussie'
  }, 200);
});

/**
 * @route GET /session
 * @description Récupère la session utilisateur courante
 * @access Protected
 */
router.get('/session', authMiddleware, async (c) => {
  try {
    const user = c.get('user');
    
    if (!user) {
      logger.warn('Tentative d\'accès à la session sans authentification', 'auth');
      return c.json({
        error: 'unauthorized',
        error_description: 'Non authentifié',
        status: 401
      }, 401);
    }
    
    logger.debug('Récupération de la session utilisateur', 'auth', { userId: user.userId });
    
    // Récupérer les informations de l'utilisateur
    const userInfo = await logtoService.getUser(user.userId);
    
    // Renvoyer la session utilisateur
    return c.json({
      userId: user.userId,
      accessToken: user.token,
      expiresAt: user.tokenData?.exp || 0,
      isAuthenticated: true,
      user: userInfo
    }, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la session: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'session_error',
      error_description: error.error_description || 'Erreur lors de la récupération de la session',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route POST /verify-token
 * @description Vérifie la validité d'un token
 * @access Protected (API Key)
 */
router.post('/verify-token', apiKeyMiddleware, validateZod({ body: verifyTokenSchema }), async (c) => {
  try {
    const { token } = c.get('validatedBody');
    
    logger.debug('Vérification de la validité d\'un token', 'auth');
    
    // Vérifier la validité du token
    const isValid = await logtoService.verifyToken(token);
    
    if (!isValid) {
      logger.info('Token invalide', 'auth');
      return c.json({
        valid: false
      }, 200);
    }
    
    // Extraire l'ID utilisateur et l'expiration
    const userId = getUserIdFromToken(token);
    const user = c.get('user');
    const tokenData = user?.tokenData || {};
    
    logger.info('Token valide', 'auth', { userId });
    
    return c.json({
      valid: true,
      userId,
      expiresAt: tokenData.exp
    }, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification du token: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'token_verification_error',
      error_description: error.error_description || 'Erreur lors de la vérification du token',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route GET /profile
 * @description Récupère le profil de l'utilisateur courant
 * @access Protected
 */
router.get('/profile', authMiddleware, async (c) => {
  try {
    const user = c.get('user');
    
    if (!user) {
      logger.warn('Tentative d\'accès au profil sans authentification', 'auth');
      return c.json({
        error: 'unauthorized',
        error_description: 'Non authentifié',
        status: 401
      }, 401);
    }
    
    logger.debug('Récupération du profil utilisateur', 'auth', { userId: user.userId });
    
    // Récupérer les informations de l'utilisateur
    const userInfo = await logtoService.getUser(user.userId);
    
    return c.json(userInfo, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du profil: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'profile_error',
      error_description: error.error_description || 'Erreur lors de la récupération du profil',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route PATCH /profile
 * @description Met à jour le profil de l'utilisateur courant
 * @access Protected
 */
router.patch('/profile', authMiddleware, validateZod({ body: updateUserSchema }), async (c) => {
  try {
    const user = c.get('user');
    
    if (!user) {
      logger.warn('Tentative de mise à jour de profil sans authentification', 'auth');
      return c.json({
        error: 'unauthorized',
        error_description: 'Non authentifié',
        status: 401
      }, 401);
    }
    
    const userData = c.get('validatedBody');
    
    logger.info('Mise à jour du profil utilisateur', 'auth', { userId: user.userId });
    
    // Mettre à jour les informations de l'utilisateur
    const updatedUser = await logtoService.updateUser(user.userId, userData);
    
    return c.json(updatedUser, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du profil: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'profile_update_error',
      error_description: error.error_description || 'Erreur lors de la mise à jour du profil',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route POST /register
 * @description Enregistre un nouvel utilisateur
 * @access Public
 */
router.post('/register', validateZod({ body: registerSchema }), async (c) => {
  try {
    const userData = c.get('validatedBody');
    
    logger.info('Tentative d\'enregistrement d\'un nouvel utilisateur', 'auth');
    
    // Créer l'utilisateur
    const createdUser = await logtoService.createUser(userData);
    
    logger.info('Utilisateur enregistré avec succès', 'auth', { userId: createdUser.id });
    
    return c.json({
      success: true,
      user: createdUser
    }, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de l'enregistrement: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'registration_error',
      error_description: error.error_description || 'Erreur lors de l\'enregistrement',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route GET /users/:id
 * @description Récupère un utilisateur par son ID
 * @access Protected (API Key)
 */
router.get('/users/:id', apiKeyMiddleware, async (c) => {
  try {
    const id = c.req.param('id');
    
    logger.debug('Récupération des informations utilisateur par ID', 'auth', { userId: id });
    
    // Récupérer les informations de l'utilisateur
    const user = await logtoService.getUser(id);
    
    return c.json(user, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'utilisateur: ${error.message}`, 'auth', { userId: c.req.param('id') });
    
    return c.json({
      error: error.error || 'user_error',
      error_description: error.error_description || 'Erreur lors de la récupération de l\'utilisateur',
      status: error.status || 500
    }, error.status || 500);
  }
});

/**
 * @route GET /users
 * @description Liste les utilisateurs
 * @access Protected (API Key)
 */
router.get('/users', apiKeyMiddleware, async (c) => {
  try {
    const page = parseInt(c.req.query('page') || '1', 10);
    const pageSize = parseInt(c.req.query('pageSize') || '20', 10);
    
    logger.debug('Récupération de la liste des utilisateurs', 'auth', { page, pageSize });
    
    // Récupérer la liste des utilisateurs
    const users = await logtoService.listUsers(page, pageSize);
    
    return c.json(users, 200);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des utilisateurs: ${error.message}`, 'auth');
    
    return c.json({
      error: error.error || 'users_error',
      error_description: error.error_description || 'Erreur lors de la récupération des utilisateurs',
      status: error.status || 500
    }, error.status || 500);
  }
});

export default router; 