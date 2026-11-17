# Contrat public — API de `lyxal_crypto` / enc:v2

API figée (`.agents/rules/lyxal_standards_and_checklist.md` §11.3), version Cargo 0.1.0.
Le [protocole V2](ENVELOPE_FORMAT_V2.md) est la référence des octets persistants.
Toutes les erreurs retournent `CryptoError`, sans entrée, PHC, clé ni chemin reflété.

## Types sensibles

| Type | Construction | Accès / conversions nommés |
|---|---|---|
| SecretBytes | new(Vec<u8>) -> Result ; longueur ET capacité <=1 Mio | expose_secret -> &[u8], len, is_empty, into_utf8 -> Result<SecretString> |
| SecretString | new(String) -> Result ; mêmes bornes, UTF-8 | expose_secret -> &str, len en bytes, is_empty, into_bytes -> SecretBytes |
| EncryptionKey | import(SecretBytes) exige 32 bytes ; generate -> Result via OsRng faillible | aucun export public brut ; partage explicite par Arc |
| HmacKey | import(SecretBytes) exige 32 bytes ; generate -> Result | type distinct de la clé AES, aucun export brut |
| ExternalHmacKey | import(SecretBytes) 1 à 1024 bytes, tels quels ; jamais générée | clé d'un protocole externe (webhooks), type distinct de HmacKey, aucun export brut |
| PasswordHash | parse(&str) valide PHC et budgets ; hash_password construit un hash | expose_phc -> &str, needs_rehash -> bool |
| TotpSecret | generate(&TotpConfig) -> Result via OsRng (20 bytes SHA-1, 32 SHA-256) ; import(SecretBytes) exige 16..=64 bytes | expose_secret -> &[u8] (stockage chiffré), to_base32 -> SecretString |
| EcdsaP256SigningKey | import_pkcs8(SecretBytes) : PKCS#8 P-256 en DER ou PEM `PRIVATE KEY`, clé publique incluse ; generate -> Result (`ring::rand::SystemRandom`, aléa du système) | public_key_uncompressed -> [u8;65], sign_es256 -> Result<[u8;64]>, export_pkcs8 -> SecretBytes (rangement d'une clé VAPID générée dans le coffre-fort seulement) |
| RsaSigningKey | import_pkcs8(SecretBytes) : PKCS#8 RSA 2048 à 4096 bits en DER ou PEM `PRIVATE KEY` ; jamais générée | sign_rs256 -> Result<Vec<u8>> ; aucun export |

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
ne sont pas offertes par `HmacKey` ; ne pas modifier une clé de protocole externe
par padding/dérivation improvisée pour satisfaire ce type.

Clé HMAC d'un protocole externe (secret de signature des webhooks d'un fournisseur, extension
validée par le CTO le 17 novembre 2026) : `ExternalHmacKey::import(SecretBytes)` accepte 1 à
`MAX_EXTERNAL_HMAC_KEY_BYTES` (1024) octets, utilisés tels quels (la RFC 2104 complète ou
condense elle-même) ; jamais générée, type distinct de `HmacKey`, `Debug` masqué, effacée à la
libération. `sign_external_hmac_sha256(&ExternalHmacKey,data)->Result<[u8;32]>`,
`verify_external_hmac_sha256(&ExternalHmacKey,data,tag)->Result<bool>` (temps constant, tag
exactement 32, format invalide => InvalidTagEncoding). Réservée à la vérification ou à la
signature imposée par un service extérieur ; les clés de la plateforme restent des `HmacKey`.

Vérification HMAC-SHA1 d'un protocole externe (signature `X-Twilio-Signature` des retours
Twilio, décision K8 validée par le CTO le 17 novembre 2026) :
`verify_external_hmac_sha1(&ExternalHmacKey,data,tag)->Result<bool>`, calculée par `ring`
(`HMAC_SHA1_FOR_LEGACY_USE_ONLY`) et comparée en temps constant ; tag exactement 20 octets,
format invalide => InvalidTagEncoding, mismatch => false. **Vérification seulement** : aucune
fonction de signature HMAC-SHA1 n'est offerte, et SHA-1 n'est jamais utilisé pour une donnée de
la plateforme.

hkdf_sha256(&SecretBytes,salt,info,len)->Result<SecretBytes> : sortie1..8160,
info non vide<=1024 ; IKM de bonne entropie et admission du salt emprunté à l'hôte.
Pas une KDF de mot de passe, pas de sortie brute par défaut.

SHA-256/BLAKE3 one-shot/hex/streaming sont conservés ; entrées ordinaires, pas de garantie
de traitement comme conteneur secret et jamais de remplacement d'Argon2 pour un mot de passe.
Les fonctions AES bas niveau, nonces choisis et helpers de HMAC à clés courtes sont privés.

## Notifications push : ES256, RS256 et Web Push (décision K8)

Extension validée par le CTO le 17 novembre 2026 (programme `lyxal_notification`, décisions K8 et
G3), calculée par `ring` ; rien d'autre (aucune vérification de ces signatures, aucune autre
courbe). Les clés sont gardées en octets PKCS#8 effacés à la libération et relues par `ring` à
chaque signature (l'état transitoire de `ring` n'est pas effacé) ; aucun scalaire privé exposé.
Entrée de clé de 16 Kio au plus (`InputTooLarge`) ; clé illisible, d'une autre courbe ou d'un
autre algorithme, PKCS#1 ou SEC1 nu, PEM d'une autre étiquette ou chiffré : `InvalidKeyEncoding`.

- `EcdsaP256SigningKey::sign_es256(data) -> Result<[u8;64]>` : JWS ES256 (RFC 7518 §3.4),
  SHA-256 puis ECDSA P-256 à nonce aléatoire, signature `r || s` de taille fixe ; jetons VAPID de
  Web Push et jetons du fournisseur APNs. `public_key_uncompressed` : point non compressé
  `0x04 || x || y` (paramètre `k` de VAPID, `applicationServerKey` des navigateurs).
  `export_pkcs8` existe seulement pour ranger dans le coffre-fort une paire VAPID générée par
  l'hôte ; la copie appartient à l'appelant.
- `RsaSigningKey::sign_rs256(data) -> Result<Vec<u8>>` : JWS RS256 (RFC 7518 §3.3),
  RSASSA-PKCS1-v1_5 SHA-256, déterministe, longueur du module ; jeton du compte de service Google
  échangé contre un jeton d'accès FCM.
- `webpush_encrypt(ua_public: &[u8;65], auth_secret: &[u8;16], plaintext) -> Result<Vec<u8>>` :
  RFC 8291, codage `aes128gcm` de la RFC 8188 ; paire ECDH P-256 éphémère (`ring::agreement`) et
  sel de 16 octets (`OsRng`) neufs par message, HKDF-SHA256 (RFC 8291 §3.3–3.4 :
  `"WebPush: info" 0x00 || ua_public || as_public` sous `auth_secret`, puis
  `"Content-Encoding: aes128gcm" 0x00` et `"Content-Encoding: nonce" 0x00` sous le sel),
  AES-128-GCM ; en-tête `sel || rs || idlen || as_public` avec `rs` = `WEBPUSH_RECORD_SIZE`
  (4096), un seul enregistrement terminé par le délimiteur `0x02`, sans bourrage. Corps =
  texte + `WEBPUSH_OVERHEAD_BYTES` (103) ; texte de `WEBPUSH_MAX_PLAINTEXT_BYTES` (4079) au plus
  (`InputTooLarge`) ; clé du navigateur hors courbe ou compressée : `InvalidKeyEncoding`. La
  limite de 4096 octets du corps entier imposée par les services push appartient à l'appelant.

Tests : vecteur de la RFC 8291 annexe A (valeurs intermédiaires et message final, clé
éphémère et sel injectés) ; déchiffrement par un navigateur simulé ; signatures ES256 et RS256
vérifiées par la vérification de `ring` (tests seulement) ; import de la paire connue de la
RFC 8291 ; signature RS256 égale à celle calculée par OpenSSL sur une clé RSA-2048 réservée aux
tests (`tests/fixtures/`).

## TOTP (RFC 6238)

Codes à usage unique des applications d'authentification, pour le double facteur de `lyxal_auth`.

- `TotpAlgorithm::{Sha1, Sha256}` ; `TotpConfig { algorithm, digits, step_seconds }`, champs
  publics, `Default` = SHA-1, 6 chiffres, pas de 30 s. Bornes vérifiées à chaque appel :
  digits 6..=8, step_seconds 15..=120.
- `totp_generate(&TotpSecret,&TotpConfig,unix_seconds)->Result<SecretString>` : code du pas
  `unix_seconds / step_seconds`, zéros initiaux conservés.
- `totp_verify(&TotpSecret,&TotpConfig,code,unix_seconds,window)->Result<Option<u64>>` :
  fenêtre 0..=2 pas de chaque côté ; tous les pas candidats sont calculés et comparés en temps
  constant (`subtle`) ; renvoie le numéro de pas accepté, que l'hôte enregistre pour refuser la
  réutilisation d'un même pas. Code de mauvaise longueur ou non numérique => `None`, pas une erreur.
- `totp_uri(&TotpSecret,&TotpConfig,issuer,account)->Result<SecretString>` : URI
  `otpauth://totp/<issuer>:<account>?secret=..&issuer=..&algorithm=..&digits=..&period=..`,
  Base32 sans remplissage, émetteur et compte encodés en pourcentage (hors caractères non
  réservés RFC 3986) ; chacun 1..=256 bytes, sans `:` ni caractère de contrôle.
- Paramètre hors bornes => `CryptoError::InvalidTotpParameter`, sans valeur reflétée.

HMAC-SHA1 est utilisé dans ce module (exigé par la RFC 6238 et les applications) sans y être
exposé comme primitive ; la seule autre utilisation est la vérification
`verify_external_hmac_sha1` ci-dessus. Le rythme des essais, l'anti-rejeu par pas, le stockage chiffré
du secret et les codes de secours appartiennent à l'hôte.
