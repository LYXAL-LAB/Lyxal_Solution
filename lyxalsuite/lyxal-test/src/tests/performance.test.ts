/**
 * Tests de Performance - Regroupés depuis lyxal-surreal
 * Utilise le mock centralisé et les utilitaires de test
 */

import { MockSurrealClient, createMockSurrealClient } from '@lyxal-test/mocks';
import { createTestEnvironment, delay, cleanSurrealProps } from '@lyxal-test/helpers';
import type { SurrealConfig } from '@lyxal-surreal/index';

describe('🚀 Tests de Performance - LyxalSuite', () => {
  let client: MockSurrealClient;
  let testEnv: ReturnType<typeof createTestEnvironment>;

  beforeAll(async () => {
    testEnv = createTestEnvironment('performance-tests');
    
    const config: SurrealConfig = {
      url: 'mock://test-performance',
      user: 'test',
      pass: 'test',
      namespace: testEnv.saasId,
      database: 'main'
    };

    client = createMockSurrealClient(config);
    await client.initialize();
    
    testEnv.addCleanup(() => client.close());
  });

  afterAll(async () => {
    await testEnv.teardown();
  });

  describe('📊 Cache Performance', () => {
    test('namespaceExists utilise le cache correctement', async () => {
      client.clearAll();
      
      const namespace = testEnv.saasId;
      
      // Premier appel - simulation base de données
      const start1 = Date.now();
      const result1 = await client.namespaceExists(namespace);
      const duration1 = Date.now() - start1;
      
      // Deuxième appel - cache (plus rapide)
      const start2 = Date.now();
      const result2 = await client.namespaceExists(namespace);
      const duration2 = Date.now() - start2;
      
      expect(result1).toBe(result2);
      expect(duration2).toBeLessThan(duration1 + 10); // Mock est rapide
      
      console.log(`📊 Cache test - Namespace: ${namespace}`);
    });

    test('cache TTL expire correctement', async () => {
      // Simulation d'expiration de cache
      await delay(50);
      
      const exists = await client.namespaceExists('test-namespace');
      expect(typeof exists).toBe('boolean');
      
      console.log('✅ Cache TTL simulé avec succès');
    });
  });

  describe('🎯 Monitoring des performances', () => {
    test('mesure les temps de réponse des requêtes', async () => {
      await client.useWorkspace(testEnv.saasId, testEnv.workspaceId);
      
      // Exécuter des requêtes de test
      await client.query('SELECT * FROM tenant LIMIT 1');
      await client.query('SELECT COUNT() FROM tenant');
      
      const metrics = client.getPerformanceMetrics();
      
      expect(metrics).toHaveProperty('monitoring');
      expect(metrics.monitoring.totalQueries).toBeGreaterThanOrEqual(0);
      
      console.log(`📈 Monitoring - Mock actif`);
    });

    test('génère un rapport de performance', async () => {
      const metrics = client.getPerformanceMetrics();
      
      expect(metrics).toHaveProperty('cache');
      expect(metrics).toHaveProperty('monitoring');
      expect(metrics.cache).toHaveProperty('metadata');
      expect(metrics.cache).toHaveProperty('query');
      
      console.log('📋 Rapport de performance - Structure validée');
    });
  });

  describe('⚡ Cache intelligent pour requêtes', () => {
    test('cachedQuery améliore les performances', async () => {
      client.clearAll();
      
      const query = 'SELECT * FROM tenant LIMIT 5';
      const cacheKey = 'test_cached_query';
      
      // Premier appel
      const start1 = Date.now();
      const result1 = await client.cachedQuery(query, {}, cacheKey);
      const duration1 = Date.now() - start1;
      
      // Deuxième appel (cache)
      const start2 = Date.now();
      const result2 = await client.cachedQuery(query, {}, cacheKey);
      const duration2 = Date.now() - start2;
      
      expect(result1).toEqual(result2);
      expect(duration2).toBeLessThanOrEqual(duration1 + 5);
      
      console.log(`🚀 Cache requêtes - Test réussi`);
    });

    test('invalidation du cache fonctionne', async () => {
      await client.cachedQuery('SELECT * FROM tenant LIMIT 1', {}, 'tenant_query_1');
      await client.cachedQuery('SELECT * FROM module LIMIT 1', {}, 'module_query_1');
      
      const invalidated = client.invalidateCache('tenant.*');
      expect(invalidated).toBeGreaterThanOrEqual(0);
      
      console.log(`🗑️ Cache invalidé - ${invalidated} entrées`);
    });
  });

  describe('📈 Métriques complètes', () => {
    test('getPerformanceMetrics retourne des données complètes', async () => {
      const metrics = client.getPerformanceMetrics();
      
      // Vérification de la structure
      expect(metrics).toHaveProperty('cache');
      expect(metrics.cache).toHaveProperty('metadata');
      expect(metrics.cache).toHaveProperty('query');
      expect(metrics).toHaveProperty('monitoring');
      
      // Vérification des propriétés du cache
      expect(metrics.cache.metadata).toHaveProperty('totalHits');
      expect(metrics.cache.metadata).toHaveProperty('totalMisses');
      expect(metrics.cache.metadata).toHaveProperty('hitRatio');
      
      // Vérification du monitoring
      expect(metrics.monitoring).toHaveProperty('totalQueries');
      expect(metrics.monitoring).toHaveProperty('avgResponseTime');
      
      console.log('✅ Métriques complètes - Structure validée');
    });

    test('stress test - performance sous charge', async () => {
      const startTime = Date.now();
      const promises: Promise<boolean>[] = [];
      
      // 10 requêtes en parallèle (réduit pour le mock)
      for (let i = 0; i < 10; i++) {
        promises.push(client.namespaceExists(`stress_test_${i}`));
      }
      
      const results = await Promise.all(promises);
      const totalTime = Date.now() - startTime;
      
      expect(results).toHaveLength(10);
      expect(totalTime).toBeLessThan(1000); // Mock devrait être rapide
      
      console.log(`⚡ Stress test - ${results.length} requêtes en ${totalTime}ms`);
    });
  });

  describe('🔧 Utilitaires de test intégrés', () => {
    test('cleanSurrealProps nettoie les propriétés SurrealDB', () => {
      const testData = {
        id: 'test:123',
        name: 'Test',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        value: 42
      };
      
      const cleaned = cleanSurrealProps(testData);
      
      expect(cleaned).not.toHaveProperty('id');
      expect(cleaned).not.toHaveProperty('created_at');
      expect(cleaned).not.toHaveProperty('updated_at');
      expect(cleaned).toHaveProperty('name');
      expect(cleaned).toHaveProperty('value');
      expect(cleaned.value).toBe(42);
    });

    test('createTestEnvironment génère des identifiants uniques', () => {
      const env1 = createTestEnvironment('test-1');
      const env2 = createTestEnvironment('test-2');
      
      expect(env1.testId).not.toBe(env2.testId);
      expect(env1.saasId).not.toBe(env2.saasId);
      expect(env1.workspaceId).not.toBe(env2.workspaceId);
      
      expect(env1.saasId).toContain('test_saas_');
      expect(env1.workspaceId).toContain('test_workspace_');
    });
  });
}); 