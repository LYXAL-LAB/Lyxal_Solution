# ✅ SECURITY_TODO_CURSOR.md — LYXALAUTH

Ce fichier définit les tâches obligatoires à exécuter pour porter le module `lyxalauth` à un **score de sécurité 10/10**.  
Aucune tâche ne doit être ignorée. Chaque section doit être accompagnée d'un `rapport.md` expliquant ce qui a été implémenté.



---

## 🔥 PRIORITÉ 1 — Obligations critiques (bloquant)

### 🔒 Rate Limiting (DoS/DDOS)
- [x] Implémenter un middleware `rateLimiter.ts` dans `gateway/middleware/`
- [x] Basé sur IP ou clé API
- [x] Utiliser TTL/RAM/local memory ou Redis compatible
- [x] Appliquer aux routes mutables (`POST`, `PATCH`, `DELETE`)
- [x] Créer `rapport.md` dans `gateway/middleware/`

### 🔒 Protection CSRF
- [x] Intégrer un middleware CSRF sur toutes les routes `POST` sensibles
- [x] Reposant sur token dans cookie + header
- [x] Compatible avec frontend moderne (SameSite+Secure)
- [x] Créer `rapport.md` expliquant le fonctionnement

### 🔒 Masquage des données sensibles dans les logs
- [x] Ajouter un filtre dans `logger.ts` pour :
  - tokens JWT
  - emails
  - mots de passe hashés
- [x] Aucun log ne doit contenir d'info exploitable
- [x] Créer `rapport.md` dans `core/utils/` ou `logger/`

---

## 🟡 PRIORITÉ 2 — Renforcement structurel

### 🧱 Logging structuré
- [x] Format JSON structuré (niveau, message, tag)
- [x] Ajouter un `requestId` dans tous les logs (UUID)
- [x] Regrouper les logs dans `logger.event()`, `logger.warn()`, etc.
- [x] Créer `rapport.md` dans `core/logger/`

### ❌ Amélioration de la gestion des erreurs
- [x] Utiliser des erreurs typées (`AuthError`, `RateLimitError`, etc.)
- [x] Retourner des messages clairs et sécurisés au frontend
- [x] Centraliser les codes dans `core/errors/`
- [x] Créer `rapport.md` dans `core/errors/`

### ✅ Validation Zod stricte pour tous les endpoints
- [ ] Vérifier que chaque route `gateway/routes/*.ts` applique `validateZod(...)`
- [ ] Ajouter des schémas Zod manquants dans `validators/`
- [ ] Créer `rapport.md` dans `gateway/validators/`

---

## 🟢 PRIORITÉ 3 — Améliorations de fond

### 📊 Ajouter métriques/performance
- [ ] Middleware de mesure de temps d'exécution par route
- [ ] Envoi dans console (ou future intégration Grafana/Prometheus)
- [ ] Créer `rapport.md` dans `gateway/middleware/`

### 🛡️ Documentation sécurité
- [ ] Ajouter section "Security" dans `README.md`
- [ ] Décrire :
  - flux de token
  - audit trail
  - protections actives
  - gestion des sessions

### 📣 Monitoring & alertes
- [ ] Ajout d'un système de log forwarding possible (Railway, Logtail…)
- [ ] Middleware `onError` qui loggue en production
- [ ] Créer `rapport.md` dans `gateway/middleware/`

---

## 📌 Objectif final

- Score 10/10 sécurité
- Zéro token exposé
- Zéro attaque CSRF possible
- Zero spam/DoS non contrôlé
- Logs 100% auditables