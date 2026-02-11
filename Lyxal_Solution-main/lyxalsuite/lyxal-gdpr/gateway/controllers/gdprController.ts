import { zValidator } from '@hono/zod-validator';
import { GdprService } from '../services/gdprService';
import {
  createGdprRequestSchema,
  updateGdprRequestSchema,
  createGdprResponseSchema
} from '../validators/gdprSchemas';

export const GdprController = {
  createRequest: [
    zValidator('json', createGdprRequestSchema),
    async (ctx) => {
      try {
        const data = ctx.req.valid('json');
        const result = await GdprService.createRequest(ctx, data);
        return ctx.json(result);
      } catch (err) {
        console.error('createRequest error:', err);
        return ctx.json({ error: 'Failed to create request' }, 500);
      }
    },
  ],

  getRequest: async (ctx) => {
    try {
      const id = ctx.req.param('id');
      const result = await GdprService.getRequest(ctx, id);
      return ctx.json(result);
    } catch (err) {
      console.error('getRequest error:', err);
      return ctx.json({ error: 'Failed to fetch request' }, 500);
    }
  },

  listRequests: async (ctx) => {
    try {
      const result = await GdprService.listRequests(ctx);
      return ctx.json(result);
    } catch (err) {
      console.error('listRequests error:', err);
      return ctx.json({ error: 'Failed to list requests' }, 500);
    }
  },

  updateRequest: [
    zValidator('json', updateGdprRequestSchema),
    async (ctx) => {
      try {
        const id = ctx.req.param('id');
        const data = ctx.req.valid('json');
        const result = await GdprService.updateRequest(ctx, id, data);
        return ctx.json(result);
      } catch (err) {
        console.error('updateRequest error:', err);
        return ctx.json({ error: 'Failed to update request' }, 500);
      }
    },
  ],

  deleteRequest: async (ctx) => {
    try {
      const id = ctx.req.param('id');
      await GdprService.deleteRequest(ctx, id);
      return ctx.body(null, 204);
    } catch (err) {
      console.error('deleteRequest error:', err);
      return ctx.json({ error: 'Failed to delete request' }, 500);
    }
  },

  createResponse: [
    zValidator('json', createGdprResponseSchema),
    async (ctx) => {
      try {
        const requestId = ctx.req.param('requestId');
        const data = ctx.req.valid('json');
        const result = await GdprService.createResponse(ctx, requestId, data);
        return ctx.json(result);
      } catch (err) {
        console.error('createResponse error:', err);
        return ctx.json({ error: 'Failed to create response' }, 500);
      }
    },
  ],

  listLogs: async (ctx) => {
    try {
      const result = await GdprService.listLogs(ctx);
      return ctx.json(result);
    } catch (err) {
      console.error('listLogs error:', err);
      return ctx.json({ error: 'Failed to list logs' }, 500);
    }
  },
};