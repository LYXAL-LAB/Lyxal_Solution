import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as configService from '../logic/configService';
import { validateZod } from '../validators/validateZod';
import {
  updateAdminConsoleConfigSchema,
  upsertJwtCustomizerSchema,
  patchJwtCustomizerSchema,
  testJwtCustomizerSchema
} from '../validators/schemas/configSchemas';
import {
  validateUpdateAdminConsoleConfig,
  validateUpsertJwtCustomizer,
  validatePatchJwtCustomizer,
  validateTestJwtCustomizer
} from '../validators/configValidation';

const router = new Hono();

// Routes pour la console d'administration
const adminConsoleRouter = new Hono();

/**
 * GET /configs/admin-console
 * Récupère la configuration de la console d'administration
 */
adminConsoleRouter.get('/', async (c) => {
  try {
    logger.info('Récupération de la configuration de la console d\'administration', 'configs');
    const result = await configService.getAdminConsoleConfig();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de la configuration de la console d'administration: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /configs/admin-console
 * Met à jour la configuration de la console d'administration
 */
adminConsoleRouter.patch('/', validateZod({ body: updateAdminConsoleConfigSchema }), async (c) => {
  try {
    logger.info('Mise à jour de la configuration de la console d\'administration', 'configs');
    const data = c.get('validatedBody');
    const result = await configService.updateAdminConsoleConfig(data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour de la configuration de la console d'administration: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

// Routes pour les clés OIDC
const oidcKeysRouter = new Hono();

/**
 * GET /configs/oidc/keys
 * Récupère les clés OIDC
 */
oidcKeysRouter.get('/', async (c) => {
  try {
    logger.info('Récupération des clés OIDC', 'configs');
    const result = await configService.getOidcKeys();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des clés OIDC: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /configs/oidc/keys/:id
 * Supprime une clé OIDC
 */
oidcKeysRouter.delete('/:id', async (c) => {
  try {
    const keyId = c.req.param('id');
    logger.info(`Suppression de la clé OIDC ${keyId}`, 'configs');
    const result = await configService.deleteOidcKey(keyId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression de la clé OIDC: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /configs/oidc/keys/rotate
 * Rotation des clés OIDC
 */
oidcKeysRouter.post('/rotate', async (c) => {
  try {
    logger.info('Rotation des clés OIDC', 'configs');
    const result = await configService.rotateOidcKeys();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la rotation des clés OIDC: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

// Routes pour les personnalisateurs JWT
const jwtCustomizerRouter = new Hono();

/**
 * GET /configs/jwt-customizer/:targetId
 * Récupère un personnalisateur JWT spécifique
 */
jwtCustomizerRouter.get('/:targetId', async (c) => {
  try {
    const targetId = c.req.param('targetId');
    logger.info(`Récupération du personnalisateur JWT pour ${targetId}`, 'configs');
    const result = await configService.getJwtCustomizer(targetId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du personnalisateur JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PUT /configs/jwt-customizer/:targetId
 * Crée ou met à jour un personnalisateur JWT
 */
jwtCustomizerRouter.put('/:targetId', validateZod({ body: upsertJwtCustomizerSchema }), async (c) => {
  try {
    const targetId = c.req.param('targetId');
    logger.info(`Création/mise à jour du personnalisateur JWT pour ${targetId}`, 'configs');
    const data = c.get('validatedBody');
    const result = await configService.upsertJwtCustomizer({ ...data, targetId });
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la création/mise à jour du personnalisateur JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /configs/jwt-customizer/:targetId
 * Supprime un personnalisateur JWT
 */
jwtCustomizerRouter.delete('/:targetId', async (c) => {
  try {
    const targetId = c.req.param('targetId');
    logger.info(`Suppression du personnalisateur JWT pour ${targetId}`, 'configs');
    const result = await configService.deleteJwtCustomizer(targetId);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du personnalisateur JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /configs/jwt-customizer/:targetId
 * Met à jour partiellement un personnalisateur JWT
 */
jwtCustomizerRouter.patch('/:targetId', validateZod({ body: patchJwtCustomizerSchema }), async (c) => {
  try {
    const targetId = c.req.param('targetId');
    logger.info(`Mise à jour partielle du personnalisateur JWT pour ${targetId}`, 'configs');
    const data = c.get('validatedBody');
    const result = await configService.patchJwtCustomizer(targetId, data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour partielle du personnalisateur JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /configs/jwt-customizer/test
 * Teste un personnalisateur JWT
 */
jwtCustomizerRouter.post('/test', validateZod({ body: testJwtCustomizerSchema }), async (c) => {
  try {
    logger.info('Test d\'un personnalisateur JWT', 'configs');
    const data = c.get('validatedBody');
    const result = await configService.testJwtCustomizer(data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du test du personnalisateur JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /configs/jwt-customizers
 * Récupère tous les personnalisateurs JWT
 */
router.get('/jwt-customizers', async (c) => {
  try {
    logger.info('Récupération de tous les personnalisateurs JWT', 'configs');
    const result = await configService.getAllJwtCustomizers();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des personnalisateurs JWT: ${error.message}`, 'configs');
    return c.json({ error: error.message }, 400);
  }
});

// Montage des sous-routes
router.route('/admin-console', adminConsoleRouter);
router.route('/oidc/keys', oidcKeysRouter);
router.route('/jwt-customizer', jwtCustomizerRouter);

export default router; 
