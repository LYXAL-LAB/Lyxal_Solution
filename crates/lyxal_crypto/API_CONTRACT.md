# Contrat public — API V1 de production / enc:v2

Implémentation phase B, soumise à réception CTO. La version Cargo reste 0.1.0 ;
aucune publication 1.0.0 n'est implicite. L'ancienne API est remplacée, sans shim.
Le [protocole V2](ENVELOPE_FORMAT_V2.md) est la référence des octets persistants.
Toutes les erreurs retournent `CryptoError`, sans entrée, PHC, clé ni chemin reflété.

## Types sensibles

| Type | Construction | Accès / conversions nommés |
|---|---|---|
| SecretBytes | new(Vec<u8>) -> Result ; longueur ET capacité <=1 Mio | expose_secret -> &[u8], len, is_empty, into_utf8 -> Result<SecretString> |
| SecretString | new(String) -> Result ; mêmes bornes, UTF-8 | expose_secret -> &str, len en bytes, is_empty, into_bytes -> SecretBytes |
| EncryptionKey | import(SecretBytes) exige 32 bytes ; generate -> Result via OsRng faillible | aucun export public brut ; partage explicite par Arc |
| HmacKey | import(SecretBytes) exige 32 bytes ; generate -> Result | type distinct de la clé AES, aucun export brut |
| PasswordHash | parse(&str) valide PHC et budgets ; hash_password construit un hash | expose_phc -> &str, needs_rehash -> bool |

`Debug` donne exactement `<Type>([REDACTED])`. Ces types ne proposent ni Clone/Copy,
Default, Display, Deref, comparaisons Eq/PartialEq/Ord, Hash, sérialisation implicite,
ni conversions/emprunts personnalisés vers des buffers bruts. Les implémentations
identitaires standard From<T> for T / Into<T> / Borrow<T> for T restent permises.
Send, Sync, Unpin et ZeroizeOnDrop sont vérifiés par le banc de contrats.
Aucune méthode publique Zeroize ne transforme une clé vivante en clé nulle.
Les conversions nommées transfèrent l'allocation ; les données invalides sont effacées.
Une exposition explicite autorise l'appelant à copier : ces copies lui appartiennent.

## Identité, contexte et enveloppe

`KeyId::parse(&str)` accepte exactement `[A-Za-z0-9._-]{1,64}`, sans trim.
KeyId est une métadonnée non secrète : Clone/Eq/Hash/Ord/Debug/Display permis.
`SecretContext::with_tenant(tenant,module,resource,record_id,field)` exige des valeurs
exactes selon V2 ; `global(purpose)` crée un domaine distinct, non vide.
Aucun tenant implicite et aucune normalisation Unicode/casse/espaces.
`SecretContext` est clonable/comparable ; son Debug masque les identités.

`EncryptedEnvelope::parse(&str)` valide uniquement format canonique et tailles.
`encode()` expose volontairement le ciphertext. `key_id()` retourne une métadonnée
non authentifiée jusqu'à `open`. Champs privés ; aucun constructeur arbitraire,
Display ou fallback V1. Maximum texte 1 398 211 bytes, payload 1 048 604 bytes.

## Trousseau, résolution et rotation

- KeyRingBuilder::new ; insert(KeyId,EncryptionKey,KeyUse) ; insert_resolved(ResolvedKey,KeyUse).
- insert_revoked(KeyId) importe un tombstone sans matériel, depuis un registre hôte fiable.
- from_snapshot(&KeyRing) partage les Arc sans copier le matériel et conserve les tombstones.
- activate(&KeyId) sélectionne une clé connue non révoquée ; l'ancienne devient decrypt-only.
- revoke(&KeyId) refuse l'active, retire le matériel et conserve l'ID ; revoked est irréversible.
- build(self) exige exactement une active et <=64 IDs, tombstones compris.
- Toute insertion dupliquée ou mutation échouée laisse les entrées existantes inchangées.
- KeyRing::active_id et state exposent des métadonnées ; validate_successor vérifie la succession.

Un snapshot est immuable. validate_successor refuse tout ID perdu, tombstone réactivé
ou matériel remplacé sous un ID existant ; comparaison de clés par subtle.
Il ne remplace pas le registre durable ID/matériel de l'hôte, en particulier au restart.

`ResolvedKey::new(KeyId,Arc<EncryptionKey>)` crée une paire explicite ; `id()` expose
uniquement son identifiant. Les providers remettent cette paire au builder.
`KeyResolver: Send + Sync` fournit `snapshot() -> Result<Arc<KeyRing>>` uniquement.
`StaticKeyResolver::new(Arc<KeyRing>)` ne rafraîchit ni fichiers ni environnement.
`Arc<T: KeyResolver>` délègue sans copie de clé.

`CryptoEngine<R>::new(R)` puis :

| Méthode | Résultat et garanties |
|---|---|
| seal(&SecretBytes,&SecretContext) | Result<EncryptedEnvelope> ; un snapshot, sa clé active, nonce OS neuf |
| open(&EncryptedEnvelope,&SecretContext) | Result<SecretBytes> ; une capture, refus absent/révoqué, authentification avant sortie |
| reencrypt_if_needed(&EncryptedEnvelope,&SecretContext) | Result<ReencryptResult> ; authentifie même si ID actif ; Current ou Rotated(EncryptedEnvelope), relatifs au snapshot capturé |

Aucune seconde capture lors de rotation, aucun fallback à un ancien snapshot après
échec du resolver. L'hôte publie un successeur validé sous verrou/CAS et peut devoir
refaire une migration si une nouvelle génération a été publiée entre-temps.
Révoquer un nouveau snapshot n'annule pas les anciens Arc détenus ou opérations en vol.

## Providers

`EnvironmentKeyProvider::load(name,KeyId)` charge explicitement 44 caractères Base64
standard canoniques pour 32 bytes ; aucun trim, reload implicite ou suppression de variable.
Le contenu source de l'environnement et les copies OS restent hors de l'effacement local.

`FileKeyProvider::new(path,id,policy).load()` suit SECURITY.md : chemin absolu,
répertoire privé de confiance, fichiers réguliers 0600/0400, pas de symlinks observés,
44 bytes Base64 plus éventuellement un seul LF. Lecture et allocations bornées.
RequireExisting ne génère rien ; AllowGenerateDevelopment publie sans remplacement,
synchronise fichier/répertoire et distingue durabilité incertaine/nettoyage échoué.
Autres plateformes non qualifiées : UnsupportedStorage, pas de fallback moins sûr.
Aucune API ne supprime une ancienne clé persistante.

## Passwords, MAC, KDF et hash

Création Argon2id v19 : m=65536 KiB, t=3, p=1, sel=16 bytes, digest=32.
Mot de passe <=1024 bytes ; minimum métier hors crate. PHC <=512 bytes, algorithme/version
exacts, paramètres m/t/p uniques, sel décodé 16..32, digest exactement32, Base64 non paddé
strict. Les ordres de paramètres sont acceptés, mais nombres à zéros initiaux interdits.
Budgets vérification : 8*p<=m<=131072 KiB, 1<=t<=5, 1<=p<=4, avant workspace Argon2.
Aucune extension PHC implicite. Mauvais format/coût => erreur, pas mismatch.

hash_password(&SecretString) -> Result<PasswordHash> ;
verify_password(&SecretString,&PasswordHash) -> Result<PasswordVerification> :
Mismatch ou Verified { needs_rehash }. Rehash si un coût est inférieur à la cible ;
aucun downgrade automatique d'un profil compatible au moins aussi élevé dans tous les coûts.
Profils incomparables signalés sans promesse de renforcement mathématique universel.
La concurrence, les comptes, sessions et rate limits appartiennent à l'hôte.

HMAC-SHA256 : sign_hmac_sha256(&HmacKey,data)->Result<[u8;32]>,
verify_hmac_sha256(&HmacKey,data,tag)->Result<bool>. Tag exactement32 ; format invalide
=> InvalidTagEncoding, mismatch=>false. Variantes hex : sortie minuscule64, vérification64
sans trim et sans allocation proportionnelle à l'entrée. Les clés arbitrairement courtes
ne sont pas offertes par l'API publique ; ne pas modifier une clé de protocole externe
par padding/dérivation improvisée pour satisfaire ce type.

hkdf_sha256(&SecretBytes,salt,info,len)->Result<SecretBytes> : sortie1..8160,
info non vide<=1024 ; IKM de bonne entropie et admission du salt emprunté à l'hôte.
Pas une KDF de mot de passe, pas de sortie brute par défaut.

SHA-256/BLAKE3 one-shot/hex/streaming sont conservés ; entrées ordinaires, pas de garantie
de traitement comme conteneur secret et jamais de remplacement d'Argon2 pour un mot de passe.
Les fonctions AES bas niveau, nonces choisis et helpers de HMAC à clés courtes sont privés.
