import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  getTotalUserCount,
  getNewUserCount,
  getActiveUserData
} from '../logic/dashboardService';
import { validateZod } from '../validators/validateZod';
import { userStatsQuerySchema } from '../validators/schemas/dashboardSchemas';

// Création du routeur
const dashboardRoutes = new Hono();

/**
 * @route GET /dashboard/users/total
 * @desc Récupère le nombre total d'utilisateurs
 * @access Admin
 */
dashboardRoutes.get('/users/total', async (c) => {
  try {
    logger.info('Récupération du nombre total d\'utilisateurs', 'dashboard');
    const result = await getTotalUserCount();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du nombre total d'utilisateurs: ${error.message}`, 'dashboard');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route GET /dashboard/users/new
 * @desc Récupère le nombre de nouveaux utilisateurs dans un intervalle de temps optionnel
 * @access Admin
 */
dashboardRoutes.get('/users/new', validateZod({ query: userStatsQuerySchema }), async (c) => {
  try {
    logger.info('Récupération du nombre de nouveaux utilisateurs', 'dashboard');
    const { startTimeExclusive, endTimeInclusive } = c.get('validatedQuery');
    
    const result = await getNewUserCount(
      startTimeExclusive,
      endTimeInclusive
    );
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du nombre de nouveaux utilisateurs: ${error.message}`, 'dashboard');
    return c.json({ error: error.message }, 500);
  }
});

/**
 * @route GET /dashboard/users/active
 * @desc Récupère les données d'utilisateurs actifs dans un intervalle de temps optionnel
 * @access Admin
 */
dashboardRoutes.get('/users/active', validateZod({ query: userStatsQuerySchema }), async (c) => {
  try {
    logger.info('Récupération des données d\'utilisateurs actifs', 'dashboard');
    const { startTimeExclusive, endTimeInclusive } = c.get('validatedQuery');
    
    const result = await getActiveUserData({
      startTimeExclusive,
      endTimeInclusive
    });
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des données d'utilisateurs actifs: ${error.message}`, 'dashboard');
    return c.json({ error: error.message }, 500);
  }
});

export default dashboardRoutes; 
