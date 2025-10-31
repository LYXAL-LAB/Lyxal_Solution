import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { validateZod } from '../validators/validateZod';
import { createDomainSchema } from '../validators/schemas/domainSchemas';
import {
  getDomains,
  createDomain,
  getDomainById,
  deleteDomain
} from '../logic/domainService';

// Création du routeur
const domainRoutes = new Hono();

/**
 * @route GET /domains
 * @desc Récupère tous les domaines
 * @access Admin
 */
domainRoutes.get('/', async (c) => {
  try {
    logger.info('Récupération de tous les domaines', 'domains');
    const domains = await getDomains();
    return c.json(domains);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des domaines: ${error.message}`, 'domains');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route POST /domains
 * @desc Crée un nouveau domaine
 * @access Admin
 */
domainRoutes.post('/', validateZod({ body: createDomainSchema }), async (c) => {
  try {
    logger.info('Création d\'un nouveau domaine', 'domains');
    const data = c.get('validatedBody');
    const domain = await createDomain(data);
    return c.json(domain, 201);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un domaine: ${error.message}`, 'domains');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route GET /domains/:id
 * @desc Récupère un domaine par son ID
 * @access Admin
 */
domainRoutes.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Récupération du domaine ${id}`, 'domains');
    const domain = await getDomainById(id);
    return c.json(domain);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du domaine: ${error.message}`, 'domains');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route DELETE /domains/:id
 * @desc Supprime un domaine
 * @access Admin
 */
domainRoutes.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    logger.info(`Suppression du domaine ${id}`, 'domains');
    await deleteDomain(id);
    return c.json({ success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du domaine: ${error.message}`, 'domains');
    return c.json({ error: error.message }, 500);
  }
});

export default domainRoutes; 
