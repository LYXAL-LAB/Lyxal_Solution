lyxalauth/gateway
Objectif : extraire et centraliser tous les schémas Zod, les typer correctement, les documenter, et assurer leur usage strict depuis les middlewares et routes.

📦 ÉTAPES POUR CHAQUE ROUTE
À suivre pour chaque dossier de route dans gateway/routes

1. 🛠️ CRÉATION DES SCHÉMAS (si manquants)

Créer validators/schemas/{nomRoute}Schemas.ts	☐
Créer chaque schéma avec nom standardisé (createXxxSchema, etc.)	☐
Définir des messages d'erreurs explicites dans chaque champ	☐
Utiliser le typage z.infer<> pour tous les schémas	☐
Ajouter un bloc JSDoc pour chaque schéma exporté	☐

2. 🧰 CENTRALISATION DES VALIDATIONS
Tâche	
Créer un fichier validators/{nomRoute}Validation.ts 	☐
Importer les schémas depuis schemas	☐
Créer des fonctions de validation réutilisables (si logique commune)	☐

3. 🔄 MISE À JOUR DES MIDDLEWARES
Tâche	
Supprimer tout schéma défini dans middlewares/*.ts	☐
Importer les schémas depuis validators/schemas	☐
Appliquer la validation directement dans les fonctions Hono	☐

4. 🧪 TESTS UNITAIRES
Tâche	
Créer un fichier tests/validators/{nomRoute}.test.ts	☐
Tester les cas valides et invalides pour chaque schéma	☐

5. 🪵 LOGGING STRUCTURÉ
Tâche	
Utiliser core/logger/structuredLogger.ts dans chaque route/middleware	☐

6. 📚 DOCUMENTATION
Tâche	
Ajouter un bloc README.md dans validators/schemas/docs/{nomRoute}.md expliquant la structure	☐
Ajouter un exemple d'utilisation de chaque schéma	☐

7. 🧹 NETTOYAGE DES MIDDLEWARES REDONDANTS
Tâche
Vérifier l'existence de fichiers redondants dans middleware/{nomRoute}Validation.ts	☐
Supprimer ces fichiers et s'assurer que les routes utilisent validators/{nomRoute}Validation.ts	☐
S'assurer qu'aucun import ne fait référence aux anciens fichiers	☐

> Chaque fichier de route doit être traité **intégralement**, étape par étape, dans l'ordre de cette liste. Aucune route ne doit être commencée si la précédente n'est pas terminée.

---

## 📋 Liste des routes à migrer

- [x] `account`
- [x] `application`
- [x] `assets`
- [x] `auth`
- [x] `authn`
- [x] `captcha`
- [x] `configs`
- [x] `connectors`
- [x] `customPhrases`
- [x] `dashboard`
- [x] `domains`
- [x] `emailTemplates`
- [x] `experience`
- [x] `hooks`
- [x] `interaction`
- [x] `logs`
- [x] `myAccount`
- [x] `oneTimeTokens`
- [x] `organizations`
- [x] `organizationInvitations`
- [x] `organizationRoles`
- [x] `organizationScopes`
- [x] `phrases`
- [x] `roles`
- [x] `resources`
- [x] `samlAuth`
- [x] `samlApplications`
- [x] `sentinel`
- [x] `signInExperience`
- [x] `ssoconnectorproviders`
- [x] `status`
- [x] `subjectTokens`
- [x] `swaggers`
- [x] `systemAppConfig`
- [x] `users`
- [x] `verification`
- [x] `verificationCode`
- [x] `wellKnown`