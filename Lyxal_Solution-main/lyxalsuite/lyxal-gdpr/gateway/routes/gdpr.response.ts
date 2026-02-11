import { Hono } from 'hono';
import { GdprController } from '../controllers/gdprController';
import { zValidator } from '@hono/zod-validator';
import {
  createGdprResponseSchema,
  gdprResponseParamsSchema,
} from '../validators/gdprSchemas';
import { authRequired } from '../../../lyxalauth/gateway/middleware/authMiddleware';

const router = new Hono();

router.use('*', authRequired);

router
  .post(
    '/gdpr/response/:requestId',
    zValidator('param', gdprResponseParamsSchema),
    zValidator('json', createGdprResponseSchema),
    GdprController.createResponse[1]
  )
  .get('/gdpr/logs', GdprController.listLogs);

export default router;
