/**
 * @file index.ts
 * @description Point d'entrée principal de la Gateway lyxalauth
 */

import { Hono } from 'hono';
import { cors } from 'hono/cors';
// import { logger } from 'hono/logger';
// import { secureLogger, secureLog } from './utils/secureLogger';
import { requestIdMiddleware, requestLoggerMiddleware, structuredLogger } from './core/logger/structuredLogger';
import { errorMiddleware, notFoundHandler } from './core/errors';
import { config } from './config';
import authRoutes from './routes/auth';
import { mutationRateLimiter, authRateLimiter } from './middleware/rateLimiter';
import { csrfMiddleware } from './middleware/csrfProtection';

// Importer toutes les routes supplémentaires
import applicationsRoutes from './routes/applications';
import usersRoutes from './routes/users';
import rolesRoutes from './routes/roles';
import resourcesRoutes from './routes/resources';
import organizationsRoutes from './routes/organizations';
import domainsRoutes from './routes/domains';
import connectorsRoutes from './routes/connectors';
import emailTemplatesRoutes from './routes/emailTemplates';
import experienceRoutes from './routes/experience';
import hooksRoutes from './routes/hooks';
import logsRoutes from './routes/logs';
import myAccountRoutes from './routes/myAccount';
import oneTimeTokensRoutes from './routes/oneTimeTokens';
import phrasesRoutes from './routes/phrases';
import samlApplicationsRoutes from './routes/samlApplications';
import statusRoutes from './routes/status';
import verificationRoutes from './routes/verification';
import dashboardRoutes from './routes/dashboard';
import samlAuthRoutes from './routes/samlAuth';
import wellKnownRoutes from './routes/wellKnown';
import assetsRoutes from './routes/assets';
import accountRoutes from './routes/account';
import customPhrasesRoutes from './routes/customPhrases';
import organizationInvitationsRoutes from './routes/organizationInvitations';
import organizationRolesRoutes from './routes/organizationRoles';
import organizationScopesRoutes from './routes/organizationScopes';
import sentinelRoutes from './routes/sentinel';
import signInExperienceRoutes from './routes/signInExperience';
import ssoConnectorProvidersRoutes from './routes/ssoConnectorProviders';
import subjectTokensRoutes from './routes/subjectTokens';
import systemAppConfigRoutes from './routes/systemAppConfig';
import swaggerRoutes from './routes/swagger';
import verificationCodeRoutes from './routes/verificationCode';
import authnRoutes from './routes/authn';
import captchaRoutes from './routes/captcha';
import configsRoutes from './routes/configs';
import interactionRoutes from './routes/interaction';

// Créer l'application Hono
const app = new Hono();

// Middleware d'identification des requêtes (doit être en premier)
app.use('*', requestIdMiddleware());

// Middleware de journalisation structurée
app.use('*', requestLoggerMiddleware());

// Middleware CORS
app.use('*', cors({
  origin: config.corsOrigin,
  allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key', 'X-CSRF-Token'],
  credentials: true
}));

// Protection CSRF globale
app.use('*', csrfMiddleware());

// Appliquer le rate limiter pour les routes d'authentification
app.use('/api/auth/login', authRateLimiter());
app.use('/api/auth/register', authRateLimiter());
app.use('/api/auth/password/reset', authRateLimiter());

// Appliquer le rate limiter pour les méthodes mutables (POST, PUT, PATCH, DELETE)
app.use('*', async (c, next) => {
  const method = c.req.method;
  if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
    return mutationRateLimiter()(c, next);
  }
  await next();
});

// Routes principales
app.route('/api/auth', authRoutes);

// Routes supplémentaires
app.route('/api/auth/applications', applicationsRoutes);
app.route('/api/auth/users', usersRoutes);
app.route('/api/auth/roles', rolesRoutes);
app.route('/api/auth/resources', resourcesRoutes);
app.route('/api/auth/organizations', organizationsRoutes);
app.route('/api/auth/domains', domainsRoutes);
app.route('/api/auth/connectors', connectorsRoutes);
app.route('/api/auth/email-templates', emailTemplatesRoutes);
app.route('/api/auth/experience', experienceRoutes);
app.route('/api/auth/hooks', hooksRoutes);
app.route('/api/auth/logs', logsRoutes);
app.route('/api/auth/my-account', myAccountRoutes);
app.route('/api/auth/one-time-tokens', oneTimeTokensRoutes);
app.route('/api/auth/phrases', phrasesRoutes);
app.route('/api/auth/saml-applications', samlApplicationsRoutes);
app.route('/api/auth/status', statusRoutes);
app.route('/api/auth/verification', verificationRoutes);
app.route('/api/auth/dashboard', dashboardRoutes);
app.route('/api/auth/saml', samlAuthRoutes);
app.route('/api/auth/.well-known', wellKnownRoutes);
app.route('/api/auth/assets', assetsRoutes);
app.route('/api/auth/account', accountRoutes);
app.route('/api/auth/custom-phrases', customPhrasesRoutes);
app.route('/api/auth/organization-invitations', organizationInvitationsRoutes);
app.route('/api/auth/organization-roles', organizationRolesRoutes);
app.route('/api/auth/organization-scopes', organizationScopesRoutes);
app.route('/api/auth/sentinel', sentinelRoutes);
app.route('/api/auth/sign-in-experience', signInExperienceRoutes);
app.route('/api/auth/sso-connector-providers', ssoConnectorProvidersRoutes);
app.route('/api/auth/subject-tokens', subjectTokensRoutes);
app.route('/api/auth/system-app-config', systemAppConfigRoutes);
app.route('/api/auth/swagger', swaggerRoutes);
app.route('/api/auth/verification-code', verificationCodeRoutes);
app.route('/api/auth/authn', authnRoutes);
app.route('/api/auth/captcha', captchaRoutes);
app.route('/api/auth/configs', configsRoutes);
app.route('/api/auth/interaction', interactionRoutes);

// Route de vérification de santé
app.get('/health', (c) => {
  return c.json({ status: 'ok', version: '1.0.0' }, 200);
});

// Gestionnaire d'erreurs global (remplace l'ancien)
app.onError(errorMiddleware());

// Gestionnaire de routes non trouvées (remplace l'ancien)
app.notFound(notFoundHandler());

// Démarrer le serveur
const PORT = config.port;
structuredLogger.info(`Serveur démarré sur le port ${PORT} en mode ${config.nodeEnv}`, 'server');

// Exporter l'application pour les tests et pour l'exécution
export default {
  fetch: app.fetch,
  port: PORT
}; 