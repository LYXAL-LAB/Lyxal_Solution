# `lyxal_secrets` — procédures d'exploitation

Procédures pour la personne qui exploite un serveur `lyxal-server` hébergeant le coffre-fort. Le
fonctionnement est décrit par le [`README.md`](README.md) ; la configuration de l'hôte par
[`apps/lyxal-server/README.md`](../../apps/lyxal-server/README.md).

Les adresses citées sont celles de l'API de l'hôte (`/api/v1/secrets/*`), appelées avec le jeton
d'une personne qui a les droits indiqués. Les fonctions SurrealQL (`fn::secrets_*`) sont les
mêmes opérations, utilisables depuis une session SurrealDB.

## 0. Ce qu'il faut savoir avant tout

* Le coffre-fort a **sa propre clé maîtresse**, `LYXAL__SECRETS__MASTER_KEY` : 32 octets en
  Base64 (44 caractères), avec son identifiant `LYXAL__SECRETS__MASTER_KEY_ID`. Elle n'est
  **jamais** dans la base ni dans un fichier de configuration ; une clé écrite dans un fichier
  arrête le démarrage.
* La clé maîtresse scelle la clé de chaque organisation, qui scelle les valeurs. **Sans la clé
  maîtresse, aucune valeur ne s'ouvre, même avec une sauvegarde complète de la base.**
* Elle scelle aussi la clé « fichiers » de chaque organisation, qui scelle la clé de chaque
  fichier d'un bucket chiffré de `lyxal_storage` (le courrier, par exemple). **Sans la clé
  maîtresse, ces fichiers ne s'ouvrent plus non plus**, même avec une sauvegarde du support et
  de la base ; sans elle, aucun fichier n'y est écrit (`STORAGE_ENCRYPTION_UNAVAILABLE`).
* Sans clé maîtresse, le serveur démarre quand même : les fiches restent visibles, aucune valeur
  n'est écrite ni lue (`SECRETS_CRYPTO_UNAVAILABLE`), et la sonde de santé du module est
  dégradée.
* Le journal du coffre-fort est chaîné par organisation : chaque entrée porte l'empreinte de la
  précédente. `POST /audit/verify` (droit `secrets.audit.read`) dit s'il est intact.
* Le worker de maintenance passe toutes les 10 minutes : purge à échéance, alertes, rotations,
  rescellement après une rotation de clé, expiration des demandes, des accès et des partages.

## 1. Sauvegarde et restauration

### Sauvegarder

1. Sauvegarder la base SurrealDB comme le reste de Lyxal OS (export ou sauvegarde du stockage).
   Les valeurs y sont scellées : la sauvegarde seule ne révèle rien.
2. Sauvegarder **à part** la clé maîtresse et son identifiant, dans un second gestionnaire de
   secrets ou un coffre physique (OWASP 2.9), jamais à côté de la sauvegarde de la base.
3. Pendant une rotation de la clé maîtresse (§2), sauvegarder aussi l'ancienne clé tant que le
   rescellement n'est pas terminé.
4. Noter la date de chaque sauvegarde et l'identifiant de la clé maîtresse en service à ce
   moment : une sauvegarde ne s'ouvre qu'avec la clé qui était en service quand elle a été prise
   (ou la suivante, si le rescellement était terminé).

### Restaurer

1. Restaurer la base.
2. Fournir au serveur la clé maîtresse qui correspond à la sauvegarde (variables
   d'environnement), puis le démarrer.
3. Vérifier :
   * la sonde de santé du module (`/health`) : pas de clé d'organisation scellée par une clé
     maîtresse absente ;
   * une lecture d'essai d'un secret connu par un module ou une personne autorisée ;
   * `POST /audit/verify` pour chaque organisation : journal intact.

### Limite à connaître

Une version **détruite** disparaît de la base en service, mais reste dans les sauvegardes plus
anciennes jusqu'à leur expiration. Pour une destruction après une fuite, appliquer aussi la
politique de conservation des sauvegardes.

## 2. Garde et rotation de la clé maîtresse

### Créer la clé

1. Tirer 32 octets aléatoires sur une machine de confiance, par exemple :
   `openssl rand -base64 32` (le résultat fait 44 caractères).
2. Choisir un identifiant daté, par exemple `vault-2027`.
3. Ranger la clé dans le gestionnaire de secrets de l'infrastructure, puis la fournir au serveur
   par `LYXAL__SECRETS__MASTER_KEY` et `LYXAL__SECRETS__MASTER_KEY_ID`.
4. Ne jamais la copier dans un ticket, un message, un dépôt ou un fichier de configuration.

### Changer la clé (au moins une fois par an, ou après un doute)

1. Créer la nouvelle clé (ci-dessus).
2. Fournir **les deux** clés et redémarrer :
   ```text
   LYXAL__SECRETS__MASTER_KEY                nouvelle clé
   LYXAL__SECRETS__MASTER_KEY_ID             vault-2027
   LYXAL__SECRETS__PREVIOUS_MASTER_KEY       ancienne clé (lecture seule)
   LYXAL__SECRETS__PREVIOUS_MASTER_KEY_ID    vault-2026
   ```
3. Attendre que le worker rescelle les clés des organisations. La sonde de santé annonce la fin :
   « l'ancienne clé maîtresse … peut être retirée ».
4. Retirer les variables `PREVIOUS_*` et redémarrer.
5. Garder l'ancienne clé, hors ligne, aussi longtemps que des sauvegardes prises avant le
   rescellement sont conservées (§1), puis la détruire.

### Perte de la clé maîtresse

Sans la clé maîtresse en service (ni l'ancienne pendant une rotation), **aucune valeur ne peut
être rouverte** : c'est voulu, personne d'autre ne peut les lire non plus. Il faut alors :

1. fournir une nouvelle clé maîtresse ;
2. considérer toutes les valeurs comme perdues, et en écrire de nouvelles, chez chaque service
   extérieur concerné (les fiches, droits, protections et journal restent en place).

## 3. Accès d'urgence

### Qui peut l'utiliser

* La permission `secrets.access.emergency` n'est donnée à **aucun rôle d'office**. L'attribuer
  explicitement à une ou deux personnes de confiance par organisation, qui ont le double facteur.
* Elle permet :
  * de s'accorder un accès d'une heure au plus à un secret ou un dossier
    (`POST /access/emergency`, motif obligatoire) ;
  * d'appliquer un changement protégé avant ses approbations
    (`POST /requests/{id}/apply` avec `emergency: true` et un motif).
* Une personne doit avoir le double facteur récent ; sinon la demande est refusée.

### Pendant l'urgence

1. Donner un motif précis : il est journalisé et publié (`secrets.access.emergency`,
   `secrets.request.applied` avec `emergency`).
2. Ne prendre que l'accès nécessaire (le plus petit chemin, la plus courte durée).
3. Pour une fuite, utiliser plutôt la rotation d'urgence (§4).

### Après l'urgence

1. Lire le journal de l'organisation (`GET /audit`) : entrées `access.emergency`,
   `request.apply`, et les lectures (`secret.read`) faites pendant l'accès.
2. Faire relire l'acte par un autre gestionnaire des accès.
3. Retirer l'accès s'il court encore (`POST /grants/{id}/revoke`).
4. Si la permission avait été donnée pour l'occasion, la retirer.

## 4. Compromission

### Un secret a fuité

1. **Couper tout de suite** : rotation d'urgence (`POST /secrets/{id}/rotations` avec
   `emergency: true`). La version en service est désactivée immédiatement ; si un rotateur
   existe, une nouvelle valeur est créée, installée, testée et mise en service ; sinon, écrire
   soi-même une nouvelle valeur (`POST /secrets/{id}/versions`), après l'avoir changée chez le
   service extérieur.
2. **Retirer les partages** actifs de ce secret (`GET /shares`, puis `POST /shares/{id}/revoke`).
3. **Revoir les accès** temporaires qui couvrent son chemin (`GET /grants`) et les retirer si
   besoin.
4. **Lire le journal** (`GET /audit?secret=…`) : qui a lu la valeur, quand, depuis quelle
   adresse et quelle session.
5. **Détruire** l'ancienne version une fois la nouvelle en service
   (`POST /secrets/{id}/versions/{n}/destroy`), si une protection ne l'empêche pas (sinon par une
   demande approuvée), puis appliquer la politique de conservation des sauvegardes (§1).

### La clé d'une organisation est en cause

1. Changer la clé de l'organisation : `POST /tenant-key/rotate` (droit
   `secrets.settings.manage`).
2. Le worker rescelle toutes les versions de l'organisation, puis détruit l'ancienne clé ; la
   sonde de santé suit les rescellements en attente.
3. Si des valeurs ont pu être lues, traiter chaque secret concerné comme une fuite.

### La clé maîtresse est en cause

1. Changer la clé maîtresse (§2), sans attendre l'échéance annuelle.
2. Changer ensuite la clé de chaque organisation (`POST /tenant-key/rotate`).
3. Si la base a pu être copiée en même temps que la clé, considérer toutes les valeurs comme
   connues : rotation de chaque secret (§4, « un secret a fuité »).

### Le journal semble altéré

1. Lancer `POST /audit/verify` pour l'organisation : il donne le premier rang où la chaîne casse.
2. Une entrée modifiée, retirée ou recréée ne peut venir que d'une session système de la base
   (un utilisateur ne peut pas écrire dans le journal) : traiter l'événement comme un accès
   administrateur non autorisé à la base.
3. Conserver une copie de la base en l'état, changer les identifiants système de SurrealDB, puis
   appliquer « la clé maîtresse est en cause ».
