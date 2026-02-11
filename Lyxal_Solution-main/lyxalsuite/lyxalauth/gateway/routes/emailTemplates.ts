import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { validateZod } from '../validators/validateZod';
import { 
  updateEmailTemplateSchema, 
  replaceEmailTemplatesSchema 
} from '../validators/schemas/emailTemplateSchemas';
import {
  getEmailTemplates,
  replaceEmailTemplates,
  deleteAllEmailTemplates,
  getEmailTemplateById,
  deleteEmailTemplate,
  updateEmailTemplateDetails
} from '../logic/emailTemplateService';

// Création du routeur
const emailTemplateRoutes = new Hono();

// TODO: Implémenter le middleware d'authentification admin
// emailTemplateRoutes.use('*', isAdmin);

/**
 * @route GET /email-templates
 * @desc Récupère tous les modèles d'emails
 * @access Admin
 */
emailTemplateRoutes.get('/', async (c) => {
  try {
    logger.info('Récupération de tous les modèles d\'emails', 'emailTemplates');
    const templates = await getEmailTemplates();
    return c.json({ data: templates, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des modèles d'emails: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors de la récupération des modèles d\'emails', details: error.message, success: false }, 500);
  }
});

/**
 * @route PUT /email-templates
 * @desc Remplace tous les modèles d'emails
 * @access Admin
 */
emailTemplateRoutes.put('/', validateZod({ body: replaceEmailTemplatesSchema }), async (c) => {
  try {
    logger.info('Remplacement de tous les modèles d\'emails', 'emailTemplates');
    const data = c.get('validatedBody');
    const templates = await replaceEmailTemplates(data);
    return c.json({ data: templates, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors du remplacement des modèles d'emails: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors du remplacement des modèles d\'emails', details: error.message, success: false }, 500);
  }
});

/**
 * @route DELETE /email-templates
 * @desc Supprime tous les modèles d'emails
 * @access Admin
 */
emailTemplateRoutes.delete('/', async (c) => {
  try {
    logger.info('Suppression de tous les modèles d\'emails', 'emailTemplates');
    await deleteAllEmailTemplates();
    return c.json({ success: true, message: 'Tous les modèles d\'emails ont été supprimés' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression des modèles d'emails: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors de la suppression des modèles d\'emails', details: error.message, success: false }, 500);
  }
});

/**
 * @route GET /email-templates/:id
 * @desc Récupère un modèle d'email par son ID
 * @access Admin
 */
emailTemplateRoutes.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de modèle d\'email manquant', success: false }, 400);
    }
    
    logger.info(`Récupération du modèle d'email ${id}`, 'emailTemplates');
    const template = await getEmailTemplateById(id);
    
    if (!template) {
      return c.json({ error: 'Modèle d\'email non trouvé', success: false }, 404);
    }
    
    return c.json({ data: template, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du modèle d'email: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors de la récupération du modèle d\'email', details: error.message, success: false }, 500);
  }
});

/**
 * @route DELETE /email-templates/:id
 * @desc Supprime un modèle d'email par son ID
 * @access Admin
 */
emailTemplateRoutes.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de modèle d\'email manquant', success: false }, 400);
    }
    
    logger.info(`Suppression du modèle d'email ${id}`, 'emailTemplates');
    const result = await deleteEmailTemplate(id);
    
    if (!result) {
      return c.json({ error: 'Modèle d\'email non trouvé ou déjà supprimé', success: false }, 404);
    }
    
    return c.json({ success: true, message: 'Modèle d\'email supprimé avec succès' });
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du modèle d'email: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors de la suppression du modèle d\'email', details: error.message, success: false }, 500);
  }
});

/**
 * @route PATCH /email-templates/:id
 * @desc Met à jour les détails d'un modèle d'email
 * @access Admin
 */
emailTemplateRoutes.patch('/:id', validateZod({ body: updateEmailTemplateSchema }), async (c) => {
  try {
    const id = c.req.param('id');
    if (!id) {
      return c.json({ error: 'ID de modèle d\'email manquant', success: false }, 400);
    }
    
    logger.info(`Mise à jour du modèle d'email ${id}`, 'emailTemplates');
    const data = c.get('validatedBody');
    const updatedTemplate = await updateEmailTemplateDetails(id, data);
    
    if (!updatedTemplate) {
      return c.json({ error: 'Modèle d\'email non trouvé', success: false }, 404);
    }
    
    return c.json({ data: updatedTemplate, success: true });
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du modèle d'email: ${error.message}`, 'emailTemplates');
    return c.json({ error: 'Erreur lors de la mise à jour du modèle d\'email', details: error.message, success: false }, 500);
  }
});

export default emailTemplateRoutes; 
