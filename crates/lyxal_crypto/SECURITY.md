# Sécurité — garanties locales et préconditions de déploiement

Cette bibliothèque n'est pas certifiée. RustCrypto fournit les primitives symétriques ; AWS-LC
(`aws-lc-rs`, code C et assembleur issu de BoringSSL, appelé par FFI) est le seul moteur
asymétrique (signatures RSA, ECDSA P-256 et Ed25519, génération de clés, ECDH du Web Push,
HMAC-SHA1 des retours Twilio) et, avec `rustls`, fait le TLS côté serveur et côté client ; le crate encadre
leurs contrats. La crate `rsa` n'est jamais utilisée (calcul en temps variable,
RUSTSEC-2023-0071 « Marvin ») ; `ring` n'est plus une dépendance du crate. Aucun code unsafe propre n'est autorisé
(`forbid(unsafe_code)`) ; les dépendances peuvent comporter des backends unsafe, C ou
assembleur, dont les garanties sont distinctes (une faille mémoire d'AWS-LC est hors de ce
`forbid`).

## Frontières de confiance

Les enveloppes et PHC peuvent être hostiles. Le contexte vient de l'identité autorisée
par l'hôte : la bibliothèque n'authentifie pas un utilisateur et ne vérifie pas ses droits.
L'AAD V2 lie suite/version/key_id/mode/identité/usage. Une ancienne enveloppe valide au même
contexte peut être rejouée : anti-rollback, révisions et transactions appartiennent à l'hôte.
La clé compromise permet de déchiffrer/forger ; aucun wrapper ne protège un processus
entièrement compromis ou un administrateur contrôlant sa mémoire.

## Budgets de clés — aucune protection distribuée automatique

Nonces OS aléatoires96, tags128. Pour q nonces uniformes indépendants,
Pr[collision] <= q(q-1)/2^97. À q=2^24, cette borne est <2^-49 ; elle ne constitue
pas la sécurité globale GCM, qui dépend aussi des blocs traités et tentatives de falsification.
Politique opérationnelle recommandée à l'hôte : <=2^24 scellements par matériel,
<=2^20 authentifications AEAD échouées avant blocage/rotation/investigation.
Le crate NE COMPTE PAS ces budgets globalement et ne fournit pas de compteur durable.
Renommage d'ID, alias de matériel, restart et réactivation ne réinitialisent jamais le budget.
L'hôte réserve les invocations avant usage, conserve les réservations au résultat inconnu,
agrège les instances et refuse une active épuisée. La taille d'un plaintext est bornée à1Mio.
Aucun quota documentaire ne doit être annoncé comme automatiquement imposé par le crate.

L'admission doit viser le snapshot réellement utilisé : capturer S, réserver durablement
une invocation de son matériel actif, puis exécuter un seul scellement (ou rechiffrement
potentiel) avec StaticKeyResolver(S). Ne pas réserver pour un ID puis laisser un resolver
dynamique en choisir un autre. Une réservation couvre au plus un scellement possible ;
si l'issue est inconnue, elle reste consommée. Le résultat Current peut être facturé
conservativement. L'hôte peut aussi intégrer une admission conservatrice dans son resolver,
mais aucune admission globale n'est fournie automatiquement par la bibliothèque.

## Clés et snapshots

L'hôte conserve un registre durable ID/matériel/états/tombstones et les budgets, puis le
restaure avant admission du trafic. insert_revoked importe les tombstones sans la clé
retirée. Ne pas publier un registre restauré sans en garantir l'authenticité/intégrité.
Construire hors verrou, puis comparer au snapshot courant avec validate_successor et
échanger l'Arc dans une même section critique/CAS. Ne jamais oublier un tombstone ;
capacité64 IDs, y compris révoqués, sans compaction automatique.
Une opération capture exactement une génération. Current authentifie et n'est relatif
qu'à cette génération ; il ne prouve pas une migration complète de la base.
Utiliser transactions/CAS pour enregistrer un rechiffrement sans écraser une modification
concurrente. Migration, révocation et destruction sont trois actions distinctes.
Les anciens Arc/opérations peuvent encore fonctionner : arrêter les anciennes instances
si la révocation doit être immédiate. Sauvegardes/rétention/destruction restent à l'hôte.

## Fichier : profil Linux x86_64 et répertoire de confiance

Profil cible à qualifier sur ext4/XFS locaux ; pas de promesse NFS/SMB/FUSE/overlay.
Un succès sur overlay cloud ne prouve pas la durabilité après panne électrique.
Parent absolu précréé, propriétaire administré par l'hôte, mode0700 (ou0500 pour lecture),
fichier régulier0600/0400 et même propriétaire. Aucune réparation automatique de droits.
Les liens et objets spéciaux observés sont refusés ; comparaison d'identité et metadata
avant/après ouverture ; contenu Base64 canonique borné44 bytes, éventuel LF unique.
Ces contrôles std NE SONT PAS un parcours anti-TOCTOU universel : un acteur pouvant
modifier les parents, agir comme le même UID hostile ou contrôler le processus est hors
modèle. Si ces préconditions ne sont pas assurées, ne pas utiliser ce backend ; un backend
OS no-follow/descripteur-relatif requiert conception et autorisation distinctes.

AllowGenerateDevelopment ne convient pas à la politique production : l'hôte doit l'interdire.
Création exclusive d'un temporaire privé dans le même répertoire, écriture complète et
sync_all, hard_link sans remplacement, sync répertoire, nettoyage du seul temporaire propre
et nouvelle sync. Le gagnant concurrent est rechargé et synchronisé. Un final corrompu,
tronqué, manquant en strict ou insecure n'est jamais remplacé pour « réparer » une clé.
Tout lecteur synchronise fichier/répertoire avant succès sur le profil qualifié.

Atomicité : le nom final apparaît absent ou complet. Durabilité : dépend des sync et du
filesystem/contrôleur qualifiés. Nettoyage : concerne les noms temporaires, distinct de la clé.
Avant publication, erreur sans nouveau final ; un temporaire orphelin reste possible après crash.
Après publication et avant durabilité confirmée : DurabilityUncertain, aucune clé rendue,
final conservé pour relecture/validation/synchronisation explicite. Après confirmation mais
nettoyage échoué : CleanupFailed, final conservé ; aucune régénération ni suppression du final.
Ne jamais promouvoir automatiquement un temporaire trouvé au redémarrage. Une clé perdue
n'est pas récupérable en générant d'autres bytes sous le même identifiant.

## Mémoire et ressources

Buffers possédés protégés avant remplissage ; sorties AES déchiffrées et workspace Argon2
entourés de zeroize sur succès et erreurs. Base64/PHC temporaires contrôlés protégés.
SecretBytes/String refusent longueur ou capacité >1Mio ; PHC et coûts bornés avant Argon2.
Le coût d'effacer un buffer externe déjà excessif ne peut être borné rétroactivement.
Limiter les calculs concurrents et utiliser un dispatch bloquant approprié à l'hôte.

Zeroize ne promet pas d'effacer toutes copies/transferts de pile, registres, états internes
HMAC/HKDF, anciens buffers OS, environnement source, swap, dumps ou sauvegardes. Features
AES/GHASH/POLYVAL/Argon2 vérifiées sur le backend visé ; cela ne qualifie pas tous les
backends ARM ou autres. mem::forget, ManuallyDrop, fuite d'Arc, abort ou processus tué
peuvent empêcher l'exécution des destructeurs. Aucune lecture après free ne sert de preuve.
L'exposition explicite de plaintext/PHC rend l'appelant responsable de ses copies et logs.

## Chiffrement de fichiers en flux (format v1)

Chaque fichier a sa clé (`StreamKey`, 32 octets d'OsRng), scellée par `enc:v2` : **un
scellement par fichier** sous la clé de l'organisation, compté dans le budget ci-dessus (2^24
scellements recommandés par matériel ; 100 comptes recevant 50 000 messages par an et par compte
imposent une rotation environ tous les trois ans). La rotation passe par `reencrypt_if_needed`
sur les clés scellées, sans réécrire les fichiers. Les segments sont chiffrés sous une clé dérivée
(HKDF-SHA256, sel de 32 octets propre au fichier) avec des nonces construits (préfixe aléatoire
de 7 octets, rang, indicateur « dernier ») : jamais deux fois le même nonce sous une même clé de
segments, 2^32 segments au plus par fichier.

Un segment n'est rendu qu'après vérification de son tag, mais les segments **suivants** ne sont
pas encore vérifiés : sur une erreur plus loin, l'appelant interrompt sa réponse (connexion IMAP
ou HTTP fermée), jamais ne la termine comme réussie. Troncature, ajout, échange, segment d'un
autre fichier, en-tête modifié et autre contexte sont détectés ; le rejeu d'une ancienne version
complète du même fichier sous le même contexte ne l'est pas (hôte). Le format protège les octets
rangés (disque, sauvegarde, S3), pas les champs en base ni le serveur en marche. Une clé
maîtresse ou d'organisation perdue rend les fichiers concernés illisibles : la sauvegarde des
clés de `lyxal_secrets` est vitale. Effacer la clé scellée d'un fichier le rend illisible, même
dans les sauvegardes du stockage. Les tampons de clair et la clé de segments sont effacés à la
libération ; les octets chiffrés écrits par l'appelant ne sont pas secrets.

## Signatures et clés asymétriques

Les clés privées (ES256, RS256, Ed25519, DKIM) sont gardées en PKCS#8 dans des tampons effacés à
la libération, sans `Clone` ni sérialisation, `Debug` masqué ; chaque signature les relit dans un
objet AWS-LC transitoire en **mémoire C**, libéré par `EVP_PKEY_free` (son effacement par AWS-LC
n'est pas vérifié). `export_pkcs8` n'existe que pour ranger une clé générée dans le coffre-fort
`lyxal_secrets` : la copie appartient à l'appelant. Les clés sont tirées de l'aléa du système par
AWS-LC (`RAND_bytes`) ; une génération RSA de 4096 bits bloque le fil (à exécuter hors de la
boucle asynchrone). RSA signe en temps constant (arithmétique d'AWS-LC) ; Ed25519 et RS256 sont
déterministes (aucun aléa à la signature), ES256 tire un nonce neuf.

Clés RSA : 2048 à 4096 bits pour signer ; 2048 à 8192 bits pour `verify_rs256` ; **1024** à 4096
bits pour la vérification DKIM seulement (RFC 8301 §3.2 : beaucoup de domaines publient encore des
clés de 1024 bits ; elles ne prouvent qu'une authenticité faible). Une vérification distingue le
format invalide (erreur : `permerror`) de la signature fausse (`false` : `fail`). Une clé publique
Ed25519 de 32 octets qui n'est pas un point valide n'est pas refusée à la lecture : elle ne vérifie
aucune signature.

## DKIM

La canonicalisation (portée de `mail-auth`) et l'assemblage des données signées déterminent
exactement les octets signés : un écart d'un octet avec les autres serveurs fait échouer des
signatures, ou en accepterait de fausses. Ils sont couverts par les vecteurs RFC 8463, un corpus
réel, une canonicalisation de référence écrite indépendamment (`tools/check_dkim_fixtures.py`),
des propriétés et du fuzzing ; l'audit externe les inclut (ROADMAP). Limites à traiter par les
crates du courrier (lot 5) :

- **`l=`** : une signature avec `l=` laisse non signé ce qui suit les `l` premiers octets
  canonicalisés ; un attaquant peut y ajouter du contenu. Le crate donne `canonical_length` ; le
  refus ou le marquage d'un `l=` plus court que le corps appartient au vérificateur.
- **Fins de ligne isolées** : un LF isolé compte comme fin de ligne et un CR isolé est retiré du
  corps, comme `mail-auth` ; le serveur SMTP refuse en amont les fins de ligne isolées dans
  `DATA` (« contrebande » SMTP).
- **En-têtes** : le choix des en-têtes selon `h=` (du bas vers le haut, en-têtes absents
  sur-signés), les dates `t=` / `x=`, l'alignement `i=` / `d=`, les balises en double et
  `rsa-sha1` (refusé, RFC 8301) sont des règles du vérificateur. Les données signées sont bornées
  à 256 Kio.

## TLS côté serveur

La configuration est construite par `tls_server_config` seulement (garde-fou CI) : TLS 1.2 et 1.3,
pas de 0-RTT (rejouable), pas de certificat client, aucun journal des clés de session,
fournisseur `aws-lc-rs` explicite. La clé privée est remise à `rustls` / AWS-LC, qui la gardent
en **mémoire C** : son effacement à la libération par AWS-LC n'est pas vérifié (connu pour
BoringSSL). Les copies Rust faites par le crate (PEM décodé) sont effacées ; l'entrée
`SecretBytes` aussi ; les `PrivateKeyDer` de `rustls-pki-types` n'implémentent pas
`ZeroizeOnDrop` et ne sont construits qu'en emprunt sur ces tampons effacés. Le rechargement des
certificats (fichiers de certbot, `lyxal_secrets`) appartient à l'hôte. Rustls n'offre ni
TLS 1.0 / 1.1 ni suites CBC ni échange de clés RSA (RFC 8996, 9325) : de vieux clients ne
peuvent pas se connecter. X25519, ChaCha20-Poly1305 et l'échange hybride X25519MLKEM768 sont
négociés à l'intérieur de TLS seulement (C3), jamais offerts comme primitives aux modules.

## TLS côté client

La configuration est construite par `tls_client_config` seulement (garde-fou CI) : TLS 1.2 et
1.3, pas de 0-RTT, pas de certificat client, aucun journal des clés de session, fournisseur
`aws-lc-rs` explicite.

- **Mode opportuniste** (`Opportunistic`, RFC 7435) : le certificat n'est **pas** authentifié
  (ni chaîne, ni dates, ni nom). Seule la signature de la poignée de main est vérifiée contre la
  clé du certificat présenté : la connexion est chiffrée avec la clé de qui a répondu. Il ne
  protège donc **que d'une écoute passive** ; un attaquant actif sur le chemin (DNS falsifié,
  détournement de route) présente son propre certificat et lit le courrier, ou retire
  `STARTTLS` de la réponse `EHLO` (repli en clair). C'est la pratique des serveurs de courrier
  tant que le domaine destinataire ne publie ni MTA-STS ni DANE (lot 7) ; `verified: false` est
  noté à chaque envoi.
- **Mode vérifié** (`WebPki`) : chaîne, dates et nom vérifiés contre les autorités figées de
  `webpki-roots` (les mêmes sur chaque nœud ; mise à jour par la version de la crate). Pas de
  liste de révocation ni d'OCSP : un certificat révoqué mais non échu est accepté.

## Validation et signalement

Les contrôles automatiques et manuels sont décrits dans le README (section « Vérification »).
Les scans RustSec sont datés ; l'absence d'alerte connue ne prouve pas l'absence de vulnérabilité.
Signaler tout incident au responsable sécurité/CTO LYXAL OS ; ne jamais joindre une clé réelle
ou un secret dans une trace publique. Aucune journalisation de contenu sensible n'est offerte.
