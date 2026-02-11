import { Hono } from 'hono';
import gdprRoutes from './routes/gdpr.routes';

const app = new Hono();

app.route('/gdpr', gdprRoutes);

export default app;
