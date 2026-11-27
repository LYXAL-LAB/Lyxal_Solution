# Contrat public — API de `lyxal_crypto` / enc:v2

API figée (`.agents/rules/lyxal_standards_and_checklist.md` §11.3) : ajouts seulement, validés par le
CTO ; version Cargo 0.1.0.
Le [protocole V2](ENVELOPE_FORMAT_V2.md) et le [format de flux v1](STREAM_FORMAT_V1.md) sont les
références des octets persistants.
Toutes les erreurs retournent `CryptoError` (`#[non_exhaustive]` : de nouvelles variantes peuvent
s'ajouter, aucune n'est retirée), sans entrée, PHC, clé, chemin ni message de `rustls` reflété.

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
| EcdsaP256SigningKey | import_pkcs8(SecretBytes) : PKCS#8 P-256 en DER ou PEM `PRIVATE KEY`, clé publique incluse contrôlée (absente : recalculée depuis le scalaire) ; generate -> Result (aléa du système, AWS-LC) | public_key_uncompressed -> [u8;65], sign_es256 -> Result<[u8;64]>, export_pkcs8 -> SecretBytes (rangement d'une clé VAPID générée dans le coffre-fort seulement) |
| RsaSigningKey | import_pkcs8(SecretBytes) : PKCS#8 RSA 2048 à 4096 bits en DER ou PEM `PRIVATE KEY` ; generate(RsaModulusBits) -> Result (aléa du système, AWS-LC) | sign_rs256 -> Result<Vec<u8>>, public_key -> RsaPublicKey, modulus_bits ; export_pkcs8 -> SecretBytes (PKCS#8 pour le coffre-fort seulement, C6) |
| Ed25519SigningKey | import_pkcs8(SecretBytes) : PKCS#8 v1 ou v2 Ed25519 en DER ou PEM `PRIVATE KEY` ; generate -> Result (aléa du système, AWS-LC) | sign -> Result<[u8;64]>, public_key -> Ed25519PublicKey ; export_pkcs8 -> SecretBytes (PKCS#8 v2 pour le coffre-fort seulement, C6) |
| DkimSigningKey | énumération `Rsa(RsaSigningKey)` / `Ed25519(Ed25519SigningKey)` | algorithm, sign(&DkimSignedData), public_key_record_bytes ; aucun export propre |
| StreamKey | generate -> Result via OsRng (32 bytes, une clé par fichier) ; open(&CryptoEngine,&EncryptedEnvelope,&SecretContext) exige 32 bytes | seal -> EncryptedEnvelope (`enc:v2`) seulement ; aucun export brut |
| StreamEncryptor / StreamDecryptor | new (clé de segments dérivée, tampon de clair effacés) | aucun accès à la clé ; voir « Chiffrement de fichiers en flux » |
| TlsCertifiedKey | from_pem(&[u8], SecretBytes), from_der(Vec<Vec<u8>>, SecretBytes) ; clé vérifiée contre le certificat | aucun export ; clé tenue par `rustls` / `aws-lc-rs` en mémoire C (pas de ZeroizeOnDrop promis, SECURITY.md) |

`Debug` donne exactement `<Type>([REDACTED])`. Ces types ne proposent ni Clone/Copy,
Default, Display, Deref, comparaisons Eq/PartialEq/Ord, Hash, sérialisation implicite,
ni conversions/emprunts personnalisés vers des buffers bruts. Les implémentations
identitaires standard From<T> for T / Into<T> / Borrow<T> for T restent permises.
Send, Sync, Unpin et ZeroizeOnDrop sont vérifiés par le banc de contrats (ZeroizeOnDrop
excepté pour TlsCertifiedKey).
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
`verify_external_hmac_sha1(&ExternalHmacKey,data,tag)->Result<bool>`, calculée par `aws-lc-rs`
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
G3), calculée par `aws-lc-rs` (décision C1 du lot 2 du programme courrier : signatures et
messages identiques, mêmes vecteurs) ; aucune vérification ES256, aucune autre courbe (la
vérification RS256 est offerte par `RsaPublicKey`, section suivante). Les clés sont gardées en
octets PKCS#8 effacés à la libération et relues par `aws-lc-rs` à chaque signature (l'objet
transitoire d'AWS-LC vit en mémoire C) ; aucun scalaire privé exposé.
Entrée de clé de 16 Kio au plus (`InputTooLarge`) ; clé illisible, d'une autre courbe ou d'un
autre algorithme, PKCS#1 ou SEC1 nu, PEM d'une autre étiquette ou chiffré : `InvalidKeyEncoding`.

- `EcdsaP256SigningKey::sign_es256(data) -> Result<[u8;64]>` : JWS ES256 (RFC 7518 §3.4),
  SHA-256 puis ECDSA P-256 à nonce aléatoire, signature `r || s` de taille fixe ; jetons VAPID de
  Web Push et jetons du fournisseur APNs. `public_key_uncompressed` : point non compressé
  `0x04 || x || y` (paramètre `k` de VAPID, `applicationServerKey` des navigateurs).
  `export_pkcs8` existe seulement pour ranger dans le coffre-fort une paire VAPID générée par
  l'hôte ; la copie appartient à l'appelant. Une clé dont la clé publique incluse ne correspond
  pas au scalaire est refusée (`InvalidKeyEncoding`) ; sans clé publique, celle-ci est recalculée
  depuis le scalaire par AWS-LC.
- `RsaSigningKey::sign_rs256(data) -> Result<Vec<u8>>` : JWS RS256 (RFC 7518 §3.3),
  RSASSA-PKCS1-v1_5 SHA-256, déterministe, longueur du module ; jeton du compte de service Google
  échangé contre un jeton d'accès FCM.
- `webpush_encrypt(ua_public: &[u8;65], auth_secret: &[u8;16], plaintext) -> Result<Vec<u8>>` :
  RFC 8291, codage `aes128gcm` de la RFC 8188 ; paire ECDH P-256 éphémère (`aws_lc_rs::agreement`) et
  sel de 16 octets (`OsRng`) neufs par message, HKDF-SHA256 (RFC 8291 §3.3–3.4 :
  `"WebPush: info" 0x00 || ua_public || as_public` sous `auth_secret`, puis
  `"Content-Encoding: aes128gcm" 0x00` et `"Content-Encoding: nonce" 0x00` sous le sel),
  AES-128-GCM ; en-tête `sel || rs || idlen || as_public` avec `rs` = `WEBPUSH_RECORD_SIZE`
  (4096), un seul enregistrement terminé par le délimiteur `0x02`, sans bourrage. Corps =
  texte + `WEBPUSH_OVERHEAD_BYTES` (103) ; texte de `WEBPUSH_MAX_PLAINTEXT_BYTES` (4079) au plus
  (`InputTooLarge`) ; clé du navigateur hors courbe ou compressée : `InvalidKeyEncoding`. La
  limite de 4096 octets du corps entier imposée par les services push appartient à l'appelant.

Tests : vecteur de la RFC 8291 annexe A (valeurs intermédiaires et message final, clé
éphémère et sel injectés) ; déchiffrement par un navigateur simulé ; signatures ES256
vérifiées par la vérification ECDSA d'`aws-lc-rs` (tests seulement), RS256 par `RsaPublicKey` ; import de la paire connue de la
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

## Signatures RSA et Ed25519 (P6 b, d)

Extension validée par le CTO le 20 novembre 2026 (programme courrier, lot 2, décisions C1, C2,
C3 et C6). Calculée par `aws-lc-rs`, seul moteur asymétrique du crate ; la crate `rsa` n'est
jamais utilisée (faille « Marvin », RUSTSEC-2023-0071). Clés privées gardées en PKCS#8 effacé à
la libération et relues par `aws-lc-rs` à chaque signature ; entrée de clé privée de 16 Kio au
plus (`InputTooLarge`), DER ou PEM `PRIVATE KEY` ; clé publique DER de 2 Kio au plus.

Résultat d'une vérification : `Ok(true)` signature valide ; `Ok(false)` signature fausse ;
`Err(InvalidSignatureEncoding)` signature de mauvaise longueur (64 octets pour Ed25519, longueur
du module pour RSA) ; `Err(InvalidKeyEncoding)` clé illisible ou trop longue ; `Err(KeyTooWeak)`
clé RSA plus courte que le minimum de l'usage. Même découpage que `verify_hmac_sha256` (format
invalide = erreur, mauvaise valeur = `false`).

- `RsaModulusBits::{Rsa2048, Rsa3072, Rsa4096}`.
- `RsaSigningKey::generate(RsaModulusBits) -> Result` : aléa du système (AWS-LC,
  `RandomUnavailable` en cas d'échec) ; une clé de 4096 bits se génère hors de la boucle
  asynchrone (`spawn_blocking`), comme Argon2id. `import_pkcs8(SecretBytes) -> Result` : 2048 à
  4096 bits (sinon `InvalidKeyEncoding`). `sign_rs256(data) -> Result<Vec<u8>>`,
  `public_key() -> RsaPublicKey`, `modulus_bits() -> u32`, `export_pkcs8() -> SecretBytes`
  (PKCS#8 v1, rangement dans le coffre-fort `lyxal_secrets` seulement ; la copie appartient à
  l'appelant).
- `RsaPublicKey` (donnée publique : `Clone`, `PartialEq`, `Debug` lisible) :
  `from_spki_der(&[u8])` (SubjectPublicKeyInfo, RFC 5280), `from_pkcs1_der(&[u8])` (RSAPublicKey,
  RFC 8017) : chacune exige sa forme ; `to_spki_der() -> Vec<u8>`, `modulus_bits() -> u32` ;
  `verify_rs256(data, signature) -> Result<bool>` : RSASSA-PKCS1-v1_5 SHA-256, clé de 2048 à
  8192 bits (plus courte `KeyTooWeak`, plus longue `InvalidKeyEncoding`).
- `Ed25519SigningKey` (RFC 8032, PKCS#8 v2 effacé) : `generate() -> Result` ;
  `import_pkcs8(SecretBytes) -> Result` : PKCS#8 v1 (forme d'`openssl genpkey`) ou v2 (clé
  publique contrôlée contre la clé privée), DER ou PEM ; `export_pkcs8() -> SecretBytes`
  (PKCS#8 v2, coffre-fort seulement) ; `public_key() -> Ed25519PublicKey` ;
  `sign(data) -> Result<[u8; 64]>` (Ed25519 « pur », déterministe).
- `Ed25519PublicKey` (donnée publique, `Copy`) : `from_bytes(&[u8])` exactement 32 octets
  (sinon `InvalidKeyEncoding` ; le point est décodé à la vérification : une clé qui n'est pas
  un point donne `Ok(false)`), `as_bytes() -> &[u8; 32]`, `verify(data, signature) ->
  Result<bool>`.

Tests : RFC 8032 §7.1 (TEST 1, 2, 3, 1024, SHA(abc) : clé publique dérivée et signature
identiques), Wycheproof `ed25519_test.json` et `rsa_signature_{2048,3072,4096}_sha256_test.json`
(tous les cas : « valid » vérifie, « invalid » jamais) ; clés générées, exportées puis importées ;
clé PKCS#8 v1 d'OpenSSL ; refus des clés faibles, PKCS#1, d'un autre algorithme ou incohérentes.

## DKIM (P6 c)

Extension validée par le CTO le 20 novembre 2026 (programme courrier, lot 2, décisions C4 et C5).
`lyxal_crypto` fait tout ce qui décide des octets signés et la signature ; la lecture des balises
`DKIM-Signature`, le choix des en-têtes selon `h=`, le DNS, `t=` / `x=`, `i=` / `d=`, la politique
sur `l=` et les résultats appartiennent aux crates du courrier (lots 5 à 7). Canonicalisation
portée de `mail-auth` 0.16.0 (`Apache-2.0 OR MIT`, [`SOURCES.md`](SOURCES.md)).

- `DkimAlgorithm::{RsaSha256, Ed25519Sha256}` : `as_tag()` (`"rsa-sha256"`, `"ed25519-sha256"`),
  `from_tag(&str) -> Option` (casse ASCII ignorée ; `rsa-sha1` et tout autre : `None`, RFC 8301).
- `DkimCanonicalization::{Simple, Relaxed}` (RFC 6376 §3.4).
- `DkimBodyHasher::new(DkimCanonicalization, length_limit: Option<u64>)`, `update(&[u8])`,
  `finish() -> DkimBodyHash { digest: [u8; 32], canonical_length: u64 }` : SHA-256 du corps
  canonicalisé, en morceaux de taille quelconque (même résultat quel que soit le découpage, CRLF
  coupé compris). `length_limit` (valeur de `l=`, vérification seulement, jamais produite) borne
  les octets **canonicalisés** hachés (RFC 6376 §3.5) ; `canonical_length` compte tout le corps
  canonicalisé, pour comparer à `l=`. Fins de ligne : un LF isolé compte comme fin de ligne, un CR
  isolé est retiré (comportement de `mail-auth`) ; le lot 5 refuse en amont les fins de ligne
  isolées.
- `DkimHeaderCanonicalizer::new(DkimCanonicalization)` ; `push_header(name, raw_value) ->
  Result` : en-tête choisi par `h=`, nom brut (octets avant le premier `:`) et valeur brute
  (après ce `:`, repliements compris, **sans** CRLF final) ; un en-tête absent n'est pas poussé.
  `finish(signature_name, signature_raw_value) -> Result<DkimSignedData>` : en-tête de signature
  (`DKIM-Signature`, ou `ARC-Message-Signature` / `ARC-Seal` au lot 7) ajouté en dernier, valeur
  de chaque balise `b=` vidée (espaces qui l'entourent compris ; `bh=` et `B=` gardés : noms de
  balises sensibles à la casse, RFC 6376 §3.2), sans CRLF final. Données signées de
  `DKIM_MAX_SIGNED_DATA_BYTES` (256 Kio) au plus (`InputTooLarge`). `DkimSignedData::as_bytes()`.
- `DkimSigningKey::{Rsa(RsaSigningKey), Ed25519(Ed25519SigningKey)}` (`Debug` masqué) :
  `algorithm()`, `sign(&DkimSignedData) -> Result<Vec<u8>>` (RSA : RSASSA-PKCS1-v1_5 SHA-256 des
  données, clé de 2048 bits au moins ; Ed25519 : Ed25519 de SHA-256(données), RFC 8463 §3),
  `public_key_record_bytes() -> Vec<u8>` (valeur `p=` avant Base64 : SubjectPublicKeyInfo pour
  RSA, 32 octets pour Ed25519).
- `DkimKeyType::{Rsa, Ed25519}` (balise `k=`) ; `DkimPublicKey::from_record(DkimKeyType, p) ->
  Result` : `p=` décodé ; RSA en SubjectPublicKeyInfo ou RSAPublicKey nu, **1024** à 4096 bits
  (RFC 8301 §3.2 : seule place où 1024 bits est accepté ; plus courte `KeyTooWeak`, plus longue
  ou illisible `InvalidKeyEncoding`) ; Ed25519 exactement 32 octets ; `p=` vide (clé révoquée)
  `InvalidKeyEncoding`. `key_type()`, `verify(DkimAlgorithm, &DkimSignedData, signature) ->
  Result<bool>` : `a=` différent de `k=` `AlgorithmMismatch`, signature de mauvaise longueur
  `InvalidSignatureEncoding` (pour l'appelant : `permerror`), signature fausse `Ok(false)`
  (`fail`).

Tests : RFC 8463 annexe A (les deux signatures vérifient ; la clé Ed25519 de la RFC redonne
exactement `b=`), corpus de `mail-auth` (simple/simple avec RSAPublicKey nu, relaxed/simple),
message signé pour Lyxal par OpenSSL (le crate redonne les mêmes signatures RSA et Ed25519),
cas de canonicalisation de `mail-auth` et référence ligne à ligne de la RFC 6376 sur tous les
corps courts, propriétés (découpage indifférent, signature puis vérification pour les deux
algorithmes et les quatre combinaisons), refus des clés et signatures mal formées ; oracle
indépendant `tools/check_dkim_fixtures.py` (canonicalisation réécrite depuis la RFC, OpenSSL) ;
cibles de fuzzing `dkim_canonicalize` et `dkim_public_key`.

## TLS serveur (P6 a)

Extension validée par le CTO le 20 novembre 2026 (programme courrier, lot 2, décisions C3 et C7).
`lyxal_crypto` construit **toute** la configuration TLS des serveurs ; les hôtes ne font que
brancher les connexions (`tokio_rustls::TlsAcceptor`, `STARTTLS`) avec la version de `rustls`
réexportée (`lyxal_crypto::rustls`). Aucune configuration TLS n'est construite ailleurs (garde-fou
`scripts/ci/check_crypto_dependencies.py`). `lyxal_crypto` ne lit aucun fichier : les octets du
certificat et de la clé viennent de l'hôte (fichiers de certbot ou `lyxal_secrets`), qui se charge
aussi du rechargement.

- `TlsCertifiedKey::from_pem(chain_pem, SecretBytes) -> Result` : chaîne PEM (blocs
  `CERTIFICATE`, feuille d'abord, 10 au plus, 64 Kio au plus, autres blocs ignorés) et clé PEM
  `PRIVATE KEY` (PKCS#8), `RSA PRIVATE KEY` (PKCS#1) ou `EC PRIVATE KEY` (SEC1, bloc
  `EC PARAMETERS` ignoré), un seul bloc de clé, 16 Kio au plus.
  `from_der(Vec<Vec<u8>>, SecretBytes) -> Result` : chaîne DER (mêmes bornes) et clé PKCS#8 DER.
  Clés acceptées : RSA de 2048 bits ou plus, ECDSA P-256 et P-384, Ed25519. Erreurs : entrée trop
  grande `InputTooLarge` ; chaîne vide, illisible ou de plus de 10 certificats
  `InvalidCertificate` ; clé illisible, chiffrée (`ENCRYPTED PRIVATE KEY` ou en-têtes
  `Proc-Type`), absente, en double, RSA de moins de 2048 bits, P-521 ou d'un autre algorithme
  `InvalidKeyEncoding` ; clé d'un autre certificat `CertificateKeyMismatch`.
- `TlsCertificateStore::new(Option<TlsCertifiedKey>) -> Arc<Self>` ; `set_default(Option<..>)` ;
  `insert(server_name, TlsCertifiedKey) -> Result` (nom DNS, casse ASCII ignorée, ou joker
  `*.domaine` avec au moins deux étiquettes après le joker ; adresse IP, nom invalide ou non
  couvert par le certificat : `InvalidCertificate`) ; `remove(server_name) -> bool`. Choix à la
  poignée de main : nom exact demandé (SNI), puis joker d'un seul niveau (`*.parent`), puis
  certificat par défaut (client sans SNI, adresse IP, nom inconnu) ; aucun : la poignée de main
  échoue par une alerte TLS, sans `panic!`. Remplacement atomique : les nouvelles poignées de main
  voient le nouveau certificat, les connexions ouvertes gardent l'ancien. Le contrôle d'un joker
  vérifie que le certificat couvre `lyxal-wildcard-probe.<domaine>`.
- `TlsServerOptions { min_version: TlsMinVersion, alpn_protocols: Vec<Vec<u8>>,
  session_cache_entries: usize }`, `Default` = `Tls12`, aucun ALPN, 4 096 entrées ;
  `TlsMinVersion::{Tls12, Tls13}`.
- `tls_server_config(Arc<TlsCertificateStore>, &TlsServerOptions) -> Result<Arc<ServerConfig>>` :
  fournisseur `aws-lc-rs` passé à `ServerConfig::builder_with_provider` (jamais
  `ServerConfig::builder()`, qui s'arrête par un `panic!` quand les deux fournisseurs de `rustls`
  sont compilés, cas du workspace) ; TLS 1.3 et 1.2 (ou 1.3 seul) ; suites et groupes du
  fournisseur (AES-GCM, ChaCha20-Poly1305 ; X25519MLKEM768, X25519, P-256, P-384 : C3) ; pas de
  0-RTT (`max_early_data_size = 0`), pas de données avant la fin de la poignée de main, pas de
  certificat client, aucun journal des clés de session ; cache de sessions de la taille demandée
  (0 : aucune reprise de session). ALPN de plus de 8 noms ou nom vide ou de plus de 255 octets,
  cache de plus de 65 536 entrées : `InputTooLarge`.

Tests : poignées de main réelles en mémoire (client `rustls` de test vérifiant la chaîne contre une
autorité de test) en TLS 1.2 et 1.3 avec des clés RSA, ECDSA P-256 / P-384 et Ed25519 ; refus d'un
client TLS 1.2 par l'option `Tls13` ; ALPN ; SNI, joker et défaut ; échec propre sans certificat ;
remplacement à chaud ; reprise de session ; clés et chaînes invalides ; non-régression du
`panic!` de `ServerConfig::builder()` avec les deux fournisseurs actifs ; poignée de main de bout
en bout par `tokio-rustls` (`TlsAcceptor`) sur un tube en mémoire.

## TLS client (lot 6, E12)

Extension validée par le CTO le 27 novembre 2026 (programme courrier, lot 6, décision E12,
question Q1 ; décision C8 du lot 2). `lyxal_crypto` construit **toute** la configuration TLS des
clients ; les hôtes ne font que brancher les connexions (`tokio_rustls::TlsConnector`, après
`STARTTLS`) avec la version de `rustls` réexportée. Le vérificateur du mode opportuniste n'existe
que dans ce crate ; aucun vérificateur de certificat n'est construit ailleurs.

- `TlsServerVerification::{Opportunistic, WebPki}` :
  - `Opportunistic` (RFC 7435, TLS opportuniste du courrier, comme `smtp_tls_security_level =
    may` de Postfix) : toute feuille X.509 lisible est acceptée, sans contrôle de la chaîne, des
    dates ni du nom ; la **signature de la poignée de main** (`ServerKeyExchange` en TLS 1.2,
    `CertificateVerify` en TLS 1.3) est toujours vérifiée par les algorithmes du fournisseur
    `aws-lc-rs` contre la clé du certificat présenté (`BadSignature` sinon). Ne protège que
    d'une écoute passive (SECURITY.md).
  - `WebPki` : chaîne vérifiée contre les autorités de la crate `webpki-roots` (version figée
    `=1.0.11` ; les racines du système ne sont jamais lues), dates contrôlées à l'horloge du
    système, nom contrôlé contre le `ServerName` de la connexion ; sans liste de révocation.
- `TlsClientOptions { verification, min_version: TlsMinVersion, alpn_protocols: Vec<Vec<u8>>,
  session_cache_entries: usize }`, `Default` = `WebPki`, `Tls12`, aucun ALPN, 256 entrées.
- `tls_client_config(&TlsClientOptions) -> Result<Arc<ClientConfig>>` : fournisseur `aws-lc-rs`
  passé à `ClientConfig::builder_with_details` (jamais `ClientConfig::builder()`, même raison que
  le serveur) ; TLS 1.3 et 1.2 (ou 1.3 seul) ; pas de 0-RTT (`enable_early_data = false`), pas de
  certificat client, aucun journal des clés de session ; SNI envoyé pour un nom DNS, jamais pour
  une adresse IP (RFC 6066 §3, règle de `rustls`) : l'appelant passe le nom du MX ; cache de
  sessions de la taille demandée (0 : aucune reprise). Mêmes bornes que le serveur (ALPN de plus
  de 8 noms, nom vide ou de plus de 255 octets, cache de plus de 65 536 entrées :
  `InputTooLarge`).
- `TlsPeerInfo { version: &'static str, cipher_suite: &'static str, verified: bool }` ;
  `tls_peer_info(&ClientConnection, TlsServerVerification) -> Option<TlsPeerInfo>` : version
  (`TLSv1.2`, `TLSv1.3`) et suite (nom de `rustls`, par exemple `TLS13_AES_256_GCM_SHA384`)
  négociées ; `verified` vaut `true` en mode `WebPki` ; `None` tant que la poignée de main n'est
  pas finie. Le mode est passé par l'appelant : une connexion `rustls` ne garde pas son
  vérificateur.

Tests : poignées de main réelles en mémoire contre le serveur de `tls_server_config` ; mode
opportuniste : certificat auto-signé, autorité inconnue et nom faux acceptés, date échue
acceptée, signature de poignée de main falsifiée refusée en TLS 1.2 et 1.3 ; mode `WebPki` :
auto-signé et autorité inconnue refusés (`UnknownIssuer`) ; chaîne valide acceptée, nom faux et
certificat échu refusés (essais unitaires, autorité de test à date fixe) ; TLS 1.2 et 1.3,
minimum 1.3 ; SNI (nom DNS envoyé, adresse IP jamais) ; reprise de session ; bornes ; aucun
fournisseur de processus installé ; bout en bout par `tokio-rustls` (`TlsConnector`).

## Chiffrement de fichiers en flux (P6 i)

Extension validée par le CTO le 20 novembre 2026 (programme courrier, lot 2, décisions C9 et
C10). Format : [`STREAM_FORMAT_V1.md`](STREAM_FORMAT_V1.md) (référence des octets persistants).
Une clé par fichier, tirée au hasard, scellée par `enc:v2` et rangée dans la fiche du fichier
(jamais dans le fichier) ; contenu découpé en segments de 64 Kio, chacun AES-256-GCM, le dernier
marqué « dernier » ; lecture d'une plage sans tout déchiffrer. Module synchrone : aucune
dépendance `tokio` ni `futures` ; l'adaptateur asynchrone appartient au consommateur (lot 4).

- Constantes : `STREAM_HEADER_BYTES` (47), `STREAM_SEGMENT_BYTES` (65 536), `STREAM_TAG_BYTES`
  (16). `stream_ciphertext_len(plaintext_len) -> Result<u64>` : `47 + n + 16 × max(1, ⌈n / 65 536⌉)`,
  `InputTooLarge` au-delà de 2^48 octets.
- `StreamKey::generate() -> Result` (OsRng, `RandomUnavailable`) ;
  `seal(&CryptoEngine, &SecretContext) -> Result<EncryptedEnvelope>` : un scellement `enc:v2` sous
  la clé active (une invocation du budget de cette clé, SECURITY.md) ;
  `StreamKey::open(&CryptoEngine, &EncryptedEnvelope, &SecretContext) -> Result` : authentifié,
  exactement 32 octets (`InvalidKeyLength` sinon). Changer la clé de l'organisation revient à
  resceller ces clés par `reencrypt_if_needed`, sans réécrire les fichiers.
- `StreamEncryptor::new(&StreamKey, &SecretContext) -> Result<(Self, [u8; 47])>` : sel (32
  octets) et préfixe de nonce (7 octets) neufs tirés par OsRng ; l'en-tête rendu s'écrit en
  premier. `update(&[u8], &mut Vec<u8>) -> Result` ajoute à la sortie chaque segment complet
  chiffré (un segment plein reste en attente tant qu'on ne sait pas s'il est le dernier) ;
  `finish(self, &mut Vec<u8>) -> Result<u64>` chiffre le dernier segment et rend la taille du
  clair. Plus de 2^48 octets : `InputTooLarge` ; après une erreur, tout appel est refusé
  (`EncryptionFailed`).
- `StreamDecryptor::new(&StreamKey, &SecretContext, header, ciphertext_len) -> Result` : en-tête
  de 47 octets et taille totale du fichier chiffré (en-tête compris) connue de la fiche ; en-tête
  mal formé ou taille incohérente `InvalidStreamHeader`, version inconnue `UnsupportedVersion`
  (avant tout déchiffrement ; l'en-tête est authentifié par chaque segment). `plaintext_len()`,
  `segment_count()` ; `plan_range(Range<u64>) -> Result<StreamSpan>` : segments et octets chiffrés
  à lire pour une plage du clair, fin exclue (`StreamSpan { first_segment, last_segment,
  ciphertext, skip_in_first, take }` ; plage vide : le segment de sa position ; début après la
  fin ou fin au-delà du clair : `InputTooLarge`) ; `decrypt_segment(index, ciphertext) ->
  Result<SecretBytes>` : rang hors du fichier ou longueur fausse `InvalidStreamHeader` ; segment
  modifié, déplacé ou étranger, fichier tronqué ou prolongé, autre contexte ou autre clé
  `AuthenticationFailed`. Le dernier segment est reconnu à son rang, déduit de la taille totale.
- AAD = domaine `"lyxal:crypto:stream:v1:aes-256-gcm" 0x00` ‖ en-tête ‖ identité du
  `SecretContext` (encodage `enc:v2` §3 sans `key_id`) : jamais vide.

**Lecture en flux** : un segment rendu est authentique, mais les segments suivants ne sont pas
encore vérifiés ; une altération plus loin est détectée au segment concerné. L'appelant doit alors
**interrompre** sa réponse (fermer la connexion IMAP ou HTTP), jamais la terminer comme réussie.
Comme pour `enc:v2`, le remplacement par une ancienne version complète du même fichier sous le
même contexte n'est pas détecté (rejeu) ; il appartient à l'hôte.

Le niveau A protège les octets rangés (disque, sauvegarde, stockage S3), pas les champs en base
(objet, expéditeur, index) ; la déduplication des fichiers chiffrés devient impossible ; une clé
d'organisation perdue rend ses fichiers illisibles (C10).

Tests : vecteurs littéraux de `STREAM_FORMAT_V1.md` (calculés par OpenSSL, contrôlés par
`tools/check_stream_fixtures.py` et par le crate), vecteurs Wycheproof AES-256-GCM de la primitive
des segments, allers-retours aux frontières de segment (0, 1, 65 535, 65 536, 65 537 octets,
plusieurs Mio), plages, altérations (bit modifié, troncature, échange, ajout, autre fichier, autre
contexte, autre clé), propriétés `proptest`, cible de fuzzing `stream_open`.
