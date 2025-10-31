import { Hono } from 'hono';
import { GdprController } from '../controllers/gdprController';
import { zValidator } from '@hono/zod-validator';
import {
  createGdprRequestSchema,
  updateGdprRequestSchema,
  gdprRequestParamsSchema,
} from '../validators/gdprSchemas';
import { authRequired } from '../../../lyxalauth/gateway/middleware/authMiddleware';

const router = new Hono();

router.use('*', authRequired);

router.post(
  '/gdpr/request',
  zValidator('json', createGdprRequestSchema),
  GdprController.createRequest[1]
);

router.get(
  '/gdpr/request/:id',
  zValidator('param', gdprRequestParamsSchema),
  GdprController.getRequest
);

router.get('/gdpr/request', GdprController.listRequests);

router.put(
  '/gdpr/request/:id',
  zValidator('param', gdprRequestParamsSchema),
  zValidator('json', updateGdprRequestSchema),
  GdprController.updateRequest[1]
);

router.delete(
  '/gdpr/request/:id',
  zValidator('param', gdprRequestParamsSchema),
  GdprController.deleteRequest
);

export default router;
