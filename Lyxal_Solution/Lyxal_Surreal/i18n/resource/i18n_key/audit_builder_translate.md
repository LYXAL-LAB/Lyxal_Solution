# Audit du Module `i18n_translate`

Ce document présente un audit du code du module `i18n_translate` en se concentrant sur la cohérence, les erreurs potentielles et les manques fonctionnels.

## 1. Erreurs Critiques et Bugs Potentiels

### a) Erreur de Copier-Coller dans `i18n_translation_update_text.surql`

Le fichier `i18n_translation_update_text.surql` contient une erreur critique dans son premier bloc de vérification.

-   **Problème :** Les lignes 61 à 96 tentent de valider une clé i18n en utilisant les variables `$name` et `$description`. Cependant, la fonction ne reçoit pas ces variables en paramètre, ce qui provoquera une erreur à l'exécution. Ce bloc de code semble être un copier-coller d'une autre fonction (`i18n_key_create.surql`) et est invalide dans ce contexte.
-   **Correction :** Ce bloc de code (lignes 61 à 96) doit être entièrement supprimé. La logique de la fonction doit commencer par les validations pertinentes comme celle de l'utilisateur ou du texte non vide.

### b) Variable `$langue_id` non définie dans la Gestion d'Erreurs

Plusieurs fonctions tentent de traduire les messages d'erreur mais échoueront car la variable `$langue_id` nécessaire n'est pas disponible.

-   **Fichiers concernés :**
    -   `builder_i18n_key_create.surql` (ex: lignes 80-81)
    -   `builder_i18n_translation_create.surql` (ex: lignes 96-97)
-   **Problème :** Ces fonctions appellent `fn::builder_i18n_translation_get($msg_key_str, $langue_id)` dans leurs blocs de gestion d'erreur, mais leur signature ne contient pas le paramètre `$langue_id`. La variable est donc non définie, ce qui provoquera une erreur.
-   **Correction :** Ajouter `$langue_id: option<string>` aux paramètres de ces fonctions ou, à défaut, retourner le code d'erreur brut (`reason_code`) sans tenter de le traduire.

## 2. Incohérences et Redondances

### a) Cohérence de la Gestion d'Erreurs

-   **Positif :** La structure de gestion d'erreur est très cohérente à travers tous les fichiers, utilisant un schéma prévisible : `vérification -> si échec -> logging -> return`.
-   **Négatif (Redondance) :** Cette cohérence est obtenue au prix d'une forte redondance. Chaque bloc de gestion d'erreur (environ 25-30 lignes) est quasiment identique.
-   **Recommandation :** Créer une fonction utilitaire (`helper`) de gestion d'erreur, par exemple `fn::builder_return_error(...)`, pour centraliser la création de l'objet de retour, le logging et la résolution i18n. Cela réduirait significativement la taille des fonctions et la duplication de code.

### b) Utilisation Incohérente du Pattern `$step_valid`

-   **Problème :** Le fichier `builder_i18n_translation_delete_edges.surql` utilise un pattern `LET $step_valid = true;` suivi de `IF $step_valid = true { ... }` pour gérer le flux de contrôle. Les autres fonctions utilisent un "early return" (un `RETURN` direct dans le bloc d'erreur), ce qui est généralement considéré comme plus lisible.
-   **Recommandation :** Standardiser l'approche en favorisant le "early return" pour une meilleure clarté du code.

## 3. Manquements Fonctionnels

L'API du module est incomplète pour une gestion administrative complète.

-   **Manque : `fn::builder_i18n_key_update`**
    Il n'existe aucune fonction pour modifier une clé de traduction existante (par exemple, pour corriger une faute dans sa description).

-   **Manque : `fn::builder_i18n_key_list`**
    Il n'y a pas de fonction pour lister toutes les clés de traduction disponibles. C'est un manque majeur pour toute interface de gestion qui permettrait aux administrateurs ou traducteurs de voir les clés à traduire.

-   **Manque : Gestion du Cycle de Vie des Langues**
    Le module dépend de l'existence des langues (`i18n_language`) et vérifie si elles sont actives, mais ne fournit aucune fonction pour les créer, lister, mettre à jour ou supprimer.

-   **Manque : Implémentation des Permissions**
    Le code mentionne des permissions futures (`-- plus tard permissions`) et vérifie un `$user_id`, mais aucune logique de contrôle d'accès n'est réellement implémentée.

## Synthèse et Recommandations

-   **Points Forts :**
    -   Bonne utilisation des transactions pour les opérations sensibles.
    -   Fonction de liste performante avec pagination.
    -   Bonne cohérence dans la structure de retour et le nommage des fonctions.

-   **Points Faibles :**
    -   Présence de **bugs critiques** qui empêcheront plusieurs fonctions de s'exécuter correctement.
    -   **Forte redondance** du code de gestion d'erreur.
    -   **Manque de fonctionnalités essentielles** pour une gestion complète du module i18n.

### Plan d'Action Recommandé

1.  **Priorité Haute :** Corriger les erreurs critiques mentionnées au point 1.
2.  **Priorité Moyenne :** Implémenter les fonctions manquantes, en particulier `fn::builder_i18n_key_list` et `fn::builder_i18n_key_update`.
3.  **Priorité Basse (Refactoring) :** Centraliser la gestion d'erreur dans une fonction helper pour améliorer la maintenabilité.
