import { describe, it, expect } from 'vitest';
import { validateRoute } from '../routeSchema';
describe('Route Schema Validation', () => {
    it('should validate a valid route', () => {
        const validRoute = {
            identity: {
                value: '/dashboard',
                slug: 'dashboard',
                code: 'dashboard'
            },
            page: {
                identity: {
                    code: 'dashboard_page'
                }
            },
            permissions: ['authenticated'],
            status: 'active'
        };
        const result = validateRoute(validRoute);
        expect(result.success).toBe(true);
        expect(result.data).toBeDefined();
    });
    it('should reject route without leading slash', () => {
        const invalidRoute = {
            identity: {
                value: 'dashboard', // Missing leading slash
                slug: 'dashboard',
                code: 'dashboard'
            },
            page: {
                identity: {
                    code: 'dashboard_page'
                }
            },
            permissions: ['authenticated'],
            status: 'active'
        };
        const result = validateRoute(invalidRoute);
        expect(result.success).toBe(false);
        expect(result.errors).toContain("identity.value: Route path must start with /");
    });
    it('should reject route with invalid slug format', () => {
        const invalidRoute = {
            identity: {
                value: '/dashboard',
                slug: 'Dashboard', // Invalid: uppercase
                code: 'dashboard'
            },
            page: {
                identity: {
                    code: 'dashboard_page'
                }
            },
            permissions: ['authenticated'],
            status: 'active'
        };
        const result = validateRoute(invalidRoute);
        expect(result.success).toBe(false);
        expect(result.errors).toContain("identity.slug: Slug must be kebab-case (lowercase, numbers, hyphens)");
    });
    it('should reject route without permissions', () => {
        const invalidRoute = {
            identity: {
                value: '/dashboard',
                slug: 'dashboard',
                code: 'dashboard'
            },
            page: {
                identity: {
                    code: 'dashboard_page'
                }
            },
            permissions: [], // Empty permissions
            status: 'active'
        };
        const result = validateRoute(invalidRoute);
        expect(result.success).toBe(false);
        expect(result.errors).toContain("permissions: At least one permission required");
    });
});
