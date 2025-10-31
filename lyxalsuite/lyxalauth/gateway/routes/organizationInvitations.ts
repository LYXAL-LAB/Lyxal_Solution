import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as organizationInvitationService from '../logic/organizationInvitationService';
import { validateZod } from '../validators/validateZod';
import {
  createOrganizationInvitationSchema,
  updateOrganizationInvitationStatusSchema,
  paginationSchema
} from '../validators/schemas/organizationInvitationSchemas';
import {
  validateCreateOrganizationInvitation,
  validateUpdateOrganizationInvitationStatus,
  validatePagination
} from '../validators/organizationInvitationValidation';
import { authRequired } from '../middleware/authMiddleware';
import { rateLimiter } from '../middleware/rateLimiter';
import { AppError, ErrorCode } from '../core/errors/AppError';

const router = new Hono();

// Appliquer le middleware d'authentification à toutes les routes
router.use('*', authRequired);

// Appliquer le middleware de limitation de taux pour prévenir les abus
router.use('*', rateLimiter({ windowMs: 15 * 60 * 1000, maxRequests: 100 }));

/**
 * GET /organizations/:organizationId/invitations
 * Récupère toutes les invitations d'une organisation
 */
router.get('/:organizationId/invitations', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération des invitations', 'organizationInvitations', {
      organizationId
    });
    
    // Extraction et validation des paramètres de requête
    const page = c.req.query('page') ? parseInt(c.req.query('page') || '1', 10) : 1;
    const pageSize = c.req.query('page_size') ? parseInt(c.req.query('page_size') || '20', 10) : 20;
    
    const pagination = validatePagination({ page, pageSize });
    const result = await organizationInvitationService.getOrganizationInvitations(
      organizationId,
      pagination.page,
      pagination.pageSize
    );
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des invitations', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/invitations
 * Crée une nouvelle invitation à une organisation
 */
router.post('/:organizationId/invitations', validateZod({ body: createOrganizationInvitationSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    if (!organizationId) {
      throw new AppError('ID d\'organisation manquant', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Création d\'une invitation', 'organizationInvitations', { 
      organizationId 
    });
    
    const data = c.get('validatedBody');
    // Ajouter l'ID de l'organisation si ce n'est pas déjà fait
    if (!data.organizationId) {
      data.organizationId = organizationId;
    }
    
    const result = await organizationInvitationService.createOrganizationInvitation(data);
    return c.json(result, 201);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la création d\'une invitation', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * GET /organizations/:organizationId/invitations/:invitationId
 * Récupère une invitation spécifique
 */
router.get('/:organizationId/invitations/:invitationId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const invitationId = c.req.param('invitationId');
    
    if (!organizationId || !invitationId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Récupération d\'une invitation', 'organizationInvitations', {
      organizationId,
      invitationId
    });
    const result = await organizationInvitationService.getOrganizationInvitation(organizationId, invitationId);
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération de l\'invitation', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * DELETE /organizations/:organizationId/invitations/:invitationId
 * Supprime une invitation
 */
router.delete('/:organizationId/invitations/:invitationId', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const invitationId = c.req.param('invitationId');
    
    if (!organizationId || !invitationId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Suppression d\'une invitation', 'organizationInvitations', {
      organizationId,
      invitationId
    });
    const result = await organizationInvitationService.deleteOrganizationInvitation(organizationId, invitationId);
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la suppression de l\'invitation', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * POST /organizations/:organizationId/invitations/:invitationId/resend
 * Renvoie le message d'invitation
 */
router.post('/:organizationId/invitations/:invitationId/resend', async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const invitationId = c.req.param('invitationId');
    
    if (!organizationId || !invitationId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Renvoi d\'une invitation', 'organizationInvitations', {
      organizationId,
      invitationId
    });
    const result = await organizationInvitationService.resendOrganizationInvitation(organizationId, invitationId);
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors du renvoi de l\'invitation', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

/**
 * PUT /organizations/:organizationId/invitations/:invitationId/status
 * Met à jour le statut d'une invitation
 */
router.put('/:organizationId/invitations/:invitationId/status', validateZod({ body: updateOrganizationInvitationStatusSchema }), async (c) => {
  try {
    const organizationId = c.req.param('organizationId');
    const invitationId = c.req.param('invitationId');
    
    if (!organizationId || !invitationId) {
      throw new AppError('Paramètres manquants', ErrorCode.MISSING_REQUIRED_FIELD);
    }
    
    structuredLogger.info('Mise à jour du statut d\'une invitation', 'organizationInvitations', {
      organizationId,
      invitationId
    });
    
    const data = c.get('validatedBody');
    const result = await organizationInvitationService.updateOrganizationInvitationStatus(organizationId, invitationId, data);
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la mise à jour du statut de l\'invitation', 'organizationInvitations', {
      error: error.message 
    });
    const statusCode = error instanceof AppError ? error.httpStatus : 400;
    return c.json({ error: error.message, code: error instanceof AppError ? error.code : 'UNKNOWN_ERROR' }, statusCode as 400 | 401 | 403 | 404 | 409 | 429 | 500 | 501 | 502 | 503 | 504);
  }
});

export default router; 
