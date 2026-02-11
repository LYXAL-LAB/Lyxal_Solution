import { describe, it, expect } from 'vitest';
import { executeGuard, executeGuards, validateGuardConfig, createGuard } from '../index';
import { GuardExecutionContext } from '../../../types/route';

describe('Route Guards System', () => {
  // Contexte de test
  const mockContext: GuardExecutionContext = {
    user: {
      id: 'user123',
      roles: ['user'],
      permissions: ['authenticated'],
      subscription: {
        plan: 'pro',
        features: ['advanced_search', 'export_data'],
        active: true
      }
    },
    route: {
      path: '/dashboard',
      params: {},
      query: {}
    }
  };

  describe('executeGuard', () => {
    it('should execute auth guard successfully for authenticated user', async () => {
      const guard = { type: 'auth' as const, condition: {} };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should fail auth guard for unauthenticated user', async () => {
      const guard = { type: 'auth' as const, condition: {} };
      const result = await executeGuard(guard, {});

      expect(result.success).toBe(false);
      expect(result.error).toBe('Authentication required');
      expect(result.redirectTo).toBe('/signin');
    });

    it('should execute role guard successfully for user with required role', async () => {
      const guard = { type: 'role' as const, condition: { role: 'user' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(true);
    });

    it('should fail role guard for user without required role', async () => {
      const guard = { type: 'role' as const, condition: { role: 'admin' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(false);
      expect(result.error).toContain('Required role not found: admin');
    });

    it('should execute subscription guard successfully for user with required plan', async () => {
      const guard = { type: 'subscription' as const, condition: { plan: 'basic' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(true);
    });

    it('should fail subscription guard for user with insufficient plan', async () => {
      const guard = { type: 'subscription' as const, condition: { plan: 'enterprise' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(false);
      expect(result.error).toContain('Plan enterprise required');
    });

    it('should execute feature guard successfully for user with required feature', async () => {
      const guard = { type: 'feature' as const, condition: { feature: 'advanced_search' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(true);
    });

    it('should fail feature guard for user without required feature', async () => {
      const guard = { type: 'feature' as const, condition: { feature: 'admin_panel' } };
      const result = await executeGuard(guard, mockContext);

      expect(result.success).toBe(false);
      expect(result.error).toContain('Feature admin_panel not available');
    });
  });

  describe('executeGuards', () => {
    it('should pass when no guards are provided', async () => {
      const result = await executeGuards([], mockContext);
      expect(result.success).toBe(true);
    });

    it('should pass when all guards succeed', async () => {
      const guards = [
        { type: 'auth' as const, condition: {} },
        { type: 'role' as const, condition: { role: 'user' } }
      ];

      const result = await executeGuards(guards, mockContext);
      expect(result.success).toBe(true);
    });

    it('should fail when first guard fails', async () => {
      const guards = [
        { type: 'role' as const, condition: { role: 'admin' } },
        { type: 'auth' as const, condition: {} }
      ];

      const result = await executeGuards(guards, mockContext);
      expect(result.success).toBe(false);
      expect(result.error).toContain('Required role not found: admin');
    });
  });

  describe('validateGuardConfig', () => {
    it('should validate correct auth guard', () => {
      const guard = { type: 'auth' as const, condition: {} };
      const result = validateGuardConfig(guard);

      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should validate correct role guard', () => {
      const guard = { type: 'role' as const, condition: { role: 'admin' } };
      const result = validateGuardConfig(guard);

      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject role guard without role', () => {
      const guard = { type: 'role' as const, condition: {} };
      const result = validateGuardConfig(guard);

      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Role guard requires a "role" in condition');
    });

    it('should reject invalid guard type', () => {
      const guard = { type: 'invalid' as any, condition: {} };
      const result = validateGuardConfig(guard);

      expect(result.valid).toBe(false);
      expect(result.errors[0]).toContain('Invalid guard type: invalid');
    });
  });

  describe('createGuard', () => {
    it('should create valid guard', () => {
      const guard = createGuard('auth');
      expect(guard).toEqual({ type: 'auth', condition: {} });
    });

    it('should return null for invalid guard', () => {
      const guard = createGuard('invalid' as any);
      expect(guard).toBeNull();
    });
  });

  describe('Super Admin Privileges', () => {
    const superAdminContext: GuardExecutionContext = {
      ...mockContext,
      user: {
        ...mockContext.user!,
        roles: ['super_admin']
      }
    };

    it('should grant all feature access to super admin', async () => {
      const guard = { type: 'feature' as const, condition: { feature: 'any_feature' } };
      const result = await executeGuard(guard, superAdminContext);

      expect(result.success).toBe(true);
    });

    it('should allow super admin to access admin-only routes', async () => {
      const guard = { type: 'role' as const, condition: { role: 'admin' } };
      const result = await executeGuard(guard, superAdminContext);

      expect(result.success).toBe(true);
    });
  });
});
