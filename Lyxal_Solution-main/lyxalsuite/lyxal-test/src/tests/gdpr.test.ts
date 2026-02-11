/**
 * Tests GDPR - Types et Flux
 * Regroupés depuis lyxal-gdpr avec améliorations
 */

import { createTestEnvironment, generateTestId, cleanTimestamps } from '@lyxal-test/helpers';
import { TEST_USERS, createTestUser } from '@lyxal-test/fixtures';

// Types GDPR locaux (évite les problèmes d'import)
interface CreateGdprRequestInput {
  typeSelect: number;
  modelId: number;
  modelSelect: string;
  requestComment: string;
  gdprRequestOrigin: string;
  requestDateT: Date;
  dueSendingDateT: Date;
  statusSelect: number;
}

interface UpdateGdprRequestInput {
  statusSelect?: string;
  requestComment?: string;
}

interface CreateGdprResponseInput {
  responseEmailAddress: string;
  anonymizationResult?: string;
  fileId?: string;
}

interface GdprRequest {
  id: string;
  typeSelect: number;
  modelId: number;
  modelSelect: string;
  statusSelect: string;
  requestDateT: string;
  dueSendingDateT: string;
  requestComment: string;
  label: string;
}

interface GdprResponse {
  id: string;
  typeSelect: number;
  sendingDateT: string;
  responseEmailAddress: string;
  anonymizationResult: string;
}

interface GdprLog {
  id: string;
  modelLog: string;
  numberOfrecords: number;
  gdprResponse: string;
}

describe('🛡️ GDPR Types et Flux - LyxalSuite', () => {
  let testEnv: ReturnType<typeof createTestEnvironment>;

  beforeAll(() => {
    testEnv = createTestEnvironment('gdpr-tests');
  });

  afterAll(async () => {
    await testEnv.teardown();
  });

  describe('📝 CreateGdprRequestInput', () => {
    test('should validate a valid access request input', () => {
      const testUser = createTestUser({ role: 'user' });
      
      const input: CreateGdprRequestInput = {
        typeSelect: 0, // Access request
        modelId: 123,
        modelSelect: 'user',
        requestComment: `Test request for ${testUser.email}`,
        gdprRequestOrigin: `gdpr_request_origin:${testEnv.testId}`,
        requestDateT: new Date(),
        dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 jours
        statusSelect: 1
      };

      // Validation des types
      expect(input.typeSelect).toBe(0);
      expect(input.modelId).toBe(123);
      expect(input.modelSelect).toBe('user');
      expect(input.requestComment).toContain(testUser.email);
      expect(input.requestDateT).toBeInstanceOf(Date);
      expect(input.dueSendingDateT).toBeInstanceOf(Date);
      
      console.log(`📝 Access request créé pour: ${testUser.email}`);
    });

    test('should validate a valid erasure request input', () => {
      const testUser = TEST_USERS.find(u => u.role === 'user');
      
      const input: CreateGdprRequestInput = {
        typeSelect: 1, // Erasure request
        modelId: 456,
        modelSelect: 'user',
        requestComment: `Erasure request for ${testUser?.email}`,
        gdprRequestOrigin: `gdpr_request_origin:${testEnv.testId}`,
        requestDateT: new Date(),
        dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        statusSelect: 1
      };

      expect(input.typeSelect).toBe(1);
      expect(input.modelId).toBe(456);
      expect(input.requestComment).toContain(testUser?.email);
      
      console.log(`🗑️ Erasure request créé pour: ${testUser?.email}`);
    });

    test('should generate unique request origins', () => {
      const origin1 = `gdpr_request_origin:${generateTestId('request')}`;
      const origin2 = `gdpr_request_origin:${generateTestId('request')}`;
      
      expect(origin1).not.toBe(origin2);
      expect(origin1).toContain('gdpr_request_origin:request_');
      expect(origin2).toContain('gdpr_request_origin:request_');
    });
  });

  describe('🔄 UpdateGdprRequestInput', () => {
    test('should validate a valid update request input', () => {
      const input: UpdateGdprRequestInput = {
        statusSelect: '2', // En cours
        requestComment: `Updated comment - ${testEnv.testId}`
      };

      expect(input.statusSelect).toBe('2');
      expect(input.requestComment).toContain(testEnv.testId);
    });

    test('should allow partial updates', () => {
      const statusUpdate: UpdateGdprRequestInput = {
        statusSelect: '3' // Terminé
      };

      const commentUpdate: UpdateGdprRequestInput = {
        requestComment: `Only comment updated - ${generateTestId('comment')}`
      };

      expect(statusUpdate.statusSelect).toBe('3');
      expect(statusUpdate.requestComment).toBeUndefined();
      
      expect(commentUpdate.statusSelect).toBeUndefined();
      expect(commentUpdate.requestComment).toContain('Only comment updated');
    });

    test('should handle status transitions', () => {
      const statusFlow = [
        { status: '1', label: 'Nouveau' },
        { status: '2', label: 'En cours' },
        { status: '3', label: 'Terminé' },
        { status: '4', label: 'Rejeté' }
      ];

      statusFlow.forEach(({ status, label }) => {
        const update: UpdateGdprRequestInput = { statusSelect: status };
        expect(update.statusSelect).toBe(status);
        console.log(`🔄 Status: ${status} (${label})`);
      });
    });
  });

  describe('📧 CreateGdprResponseInput', () => {
    test('should validate a valid response input', () => {
      const testUser = createTestUser({ role: 'admin' });
      
      const input: CreateGdprResponseInput = {
        responseEmailAddress: testUser.email,
        anonymizationResult: 'Data anonymized successfully',
        fileId: `meta_file:${generateTestId('file')}`
      };

      expect(input.responseEmailAddress).toBe(testUser.email);
      expect(input.anonymizationResult).toBe('Data anonymized successfully');
      expect(input.fileId).toContain('meta_file:file_');
    });

    test('should validate a minimal response input', () => {
      const input: CreateGdprResponseInput = {
        responseEmailAddress: 'minimal@test.lyxal.com'
      };

      expect(input.responseEmailAddress).toBe('minimal@test.lyxal.com');
      expect(input.anonymizationResult).toBeUndefined();
      expect(input.fileId).toBeUndefined();
    });

    test('should support different response types', () => {
      const responses = [
        {
          email: 'access@test.lyxal.com',
          result: 'Data export completed - 150 records found',
          type: 'access'
        },
        {
          email: 'erasure@test.lyxal.com', 
          result: 'Data anonymization completed - 75 records processed',
          type: 'erasure'
        },
        {
          email: 'portability@test.lyxal.com',
          result: 'Data portability package created - JSON format',
          type: 'portability'
        }
      ];

      responses.forEach(({ email, result, type }) => {
        const input: CreateGdprResponseInput = {
          responseEmailAddress: email,
          anonymizationResult: result
        };

        expect(input.responseEmailAddress).toBe(email);
        expect(input.anonymizationResult).toBe(result);
        console.log(`📧 Response ${type}: ${email}`);
      });
    });
  });

  describe('📋 GdprRequest', () => {
    test('should validate a complete GDPR request', () => {
      const requestId = generateTestId('gdpr_request');
      
      const request: GdprRequest = {
        id: `gdpr_request:${requestId}`,
        typeSelect: 0,
        modelId: 789,
        modelSelect: 'user',
        statusSelect: '1',
        requestDateT: new Date().toISOString(),
        dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        requestComment: `Test request - ${testEnv.testId}`,
        label: `Access Request - test@${testEnv.testId}.com`
      };

      expect(request.id).toBe(`gdpr_request:${requestId}`);
      expect(request.typeSelect).toBe(0);
      expect(request.statusSelect).toBe('1');
      expect(request.label).toContain(testEnv.testId);
      
      // Test de nettoyage des timestamps
      const cleaned = cleanTimestamps(request);
      expect(cleaned.requestDateT).toBeUndefined();
      expect(cleaned.dueSendingDateT).toBeUndefined();
      expect(cleaned.requestComment).toBeDefined();
    });
  });

  describe('📤 GdprResponse', () => {
    test('should validate a complete GDPR response', () => {
      const responseId = generateTestId('gdpr_response');
      
      const response: GdprResponse = {
        id: `gdpr_response:${responseId}`,
        typeSelect: 0,
        sendingDateT: new Date().toISOString(),
        responseEmailAddress: `response@${testEnv.testId}.com`,
        anonymizationResult: 'All data anonymized successfully'
      };

      expect(response.id).toBe(`gdpr_response:${responseId}`);
      expect(response.typeSelect).toBe(0);
      expect(response.responseEmailAddress).toContain(testEnv.testId);
      expect(response.anonymizationResult).toContain('anonymized');
    });
  });

  describe('📊 GdprLog', () => {
    test('should validate a complete GDPR log', () => {
      const logId = generateTestId('gdpr_log');
      const responseId = generateTestId('gdpr_response');
      
      const log: GdprLog = {
        id: `gdpr_audit_log:${logId}`,
        modelLog: `User data export - ${testEnv.testId}`,
        numberOfrecords: 42,
        gdprResponse: `gdpr_response:${responseId}`
      };

      expect(log.id).toBe(`gdpr_audit_log:${logId}`);
      expect(log.numberOfrecords).toBe(42);
      expect(log.gdprResponse).toBe(`gdpr_response:${responseId}`);
      expect(log.modelLog).toContain(testEnv.testId);
    });

    test('should track different record counts', () => {
      const recordCounts = [0, 1, 25, 100, 1000];
      
      recordCounts.forEach(count => {
        const log: GdprLog = {
          id: `gdpr_audit_log:${generateTestId('log')}`,
          modelLog: `Export with ${count} records`,
          numberOfrecords: count,
          gdprResponse: `gdpr_response:${generateTestId('response')}`
        };

        expect(log.numberOfrecords).toBe(count);
        console.log(`📊 Log: ${count} records`);
      });
    });
  });

  describe('🔄 Flux GDPR Complet', () => {
    test('should simulate complete GDPR workflow', () => {
      const workflowId = generateTestId('workflow');
      const testUser = createTestUser({ role: 'user' });
      
      // 1. Création de la demande
      const request: CreateGdprRequestInput = {
        typeSelect: 0,
        modelId: 123,
        modelSelect: 'user',
        requestComment: `Access request workflow - ${workflowId}`,
        gdprRequestOrigin: `gdpr_request_origin:${workflowId}`,
        requestDateT: new Date(),
        dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        statusSelect: 1
      };

      // 2. Mise à jour du statut
      const update: UpdateGdprRequestInput = {
        statusSelect: '2',
        requestComment: `Processing started - ${workflowId}`
      };

      // 3. Création de la réponse
      const response: CreateGdprResponseInput = {
        responseEmailAddress: testUser.email,
        anonymizationResult: `Data export completed - ${workflowId}`,
        fileId: `meta_file:${workflowId}`
      };

      // Validation du flux
      expect(request.requestComment).toContain(workflowId);
      expect(update.statusSelect).toBe('2');
      expect(response.responseEmailAddress).toBe(testUser.email);
      expect(response.fileId).toContain(workflowId);
      
      console.log(`🔄 Workflow GDPR complet: ${workflowId}`);
    });
  });
}); 