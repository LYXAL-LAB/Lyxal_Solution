import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { validateZod } from '../validators/validateZod';
import { 
  createConnectorSchema,
  updateConnectorSchema,
  testPasswordlessConnectorSchema,
  getAuthorizationUriSchema
} from '../validators/schemas/connectorSchemas';
import { 
  getConnectors,
  createConnector,
  getConnectorById,
  deleteConnector,
  updateConnector,
  testPasswordlessConnector,
  getConnectorAuthorizationUri
} from '../logic/connectorService';

import {
  validateCreateConnector,
  validateUpdateConnector,
  validateTestPasswordlessConnector,
  validateGetAuthorizationUri
} from '../validators/connectorValidation';

// Création du routeur
const connectorRoutes = new Hono();

/**
 * @route GET /connectors
 * @desc Récupère tous les connecteurs
 * @access Admin
 */
connectorRoutes.get('/', async (c) => {
  try {
    logger.info('Récupération de tous les connecteurs', 'connectors');
    const connectors = await getConnectors();
    return c.json(connectors);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des connecteurs: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route POST /connectors
 * @desc Crée un nouveau connecteur
 * @access Admin
 */
connectorRoutes.post('/', validateZod({ body: createConnectorSchema }), async (c) => {
  try {
    logger.info('Création d\'un nouveau connecteur', 'connectors');
    const data = c.get('validatedBody');
    const connector = await createConnector(data);
    return c.json(connector, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un connecteur: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route GET /connectors/:id
 * @desc Récupère un connecteur par son ID
 * @access Admin
 */
connectorRoutes.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Récupération du connecteur ${id}`, 'connectors');
    const connector = await getConnectorById(id);
    return c.json(connector);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du connecteur: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route DELETE /connectors/:id
 * @desc Supprime un connecteur
 * @access Admin
 */
connectorRoutes.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Suppression du connecteur ${id}`, 'connectors');
    await deleteConnector(id);
    return c.json({ success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du connecteur: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route PATCH /connectors/:id
 * @desc Met à jour un connecteur
 * @access Admin
 */
connectorRoutes.patch('/:id', validateZod({ body: updateConnectorSchema }), async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Mise à jour du connecteur ${id}`, 'connectors');
    const data = c.get('validatedBody');
    const updatedConnector = await updateConnector(id, data);
    return c.json(updatedConnector);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du connecteur: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route POST /connectors/test-passwordless
 * @desc Teste un connecteur sans mot de passe
 * @access Admin
 */
connectorRoutes.post('/test-passwordless', validateZod({ body: testPasswordlessConnectorSchema }), async (c) => {
  try {
    logger.info('Test d\'un connecteur sans mot de passe', 'connectors');
    const data = c.get('validatedBody');
    const result = await testPasswordlessConnector(data);
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du test du connecteur sans mot de passe: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route POST /connectors/:id/authorization-uri
 * @desc Récupère l'URI d'autorisation d'un connecteur
 * @access Admin
 */
connectorRoutes.post('/:id/authorization-uri', validateZod({ body: getAuthorizationUriSchema }), async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Récupération de l'URI d'autorisation pour le connecteur ${id}`, 'connectors');
    const data = c.get('validatedBody');
    const result = await getConnectorAuthorizationUri({
      ...data,
      connectorId: id
    });
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération de l'URI d'autorisation: ${error.message}`, 'connectors');
    return c.json({ error: error.message }, 500);
  }
});

export default connectorRoutes; 
