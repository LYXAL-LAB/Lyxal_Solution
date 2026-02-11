import { Hono } from 'hono';
import { GdprController } from '../controllers/gdprController';
import { rateLimit } from '../middlewares/rateLimit';
import { errorHandler } from '../middlewares/errorHandler';
import { authRequired } from '../../../lyxalauth/gateway/middleware/authMiddleware';

const gdprRoutes = new Hono();

gdprRoutes.use('*', errorHandler);
gdprRoutes.use('*', rateLimit);
gdprRoutes.use('*', authRequired);

gdprRoutes
  .post('/request', ...GdprController.createRequest)
  .get('/request/:id', GdprController.getRequest)
  .get('/request', GdprController.listRequests)
  .put('/request/:id', ...GdprController.updateRequest)
  .delete('/request/:id', GdprController.deleteRequest)
  .post('/response/:requestId', ...GdprController.createResponse)
  .get('/logs', GdprController.listLogs);

export default gdprRoutes;