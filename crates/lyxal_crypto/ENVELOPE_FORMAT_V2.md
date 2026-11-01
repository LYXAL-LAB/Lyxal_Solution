# Protocole enc:v2 — spécification implémentée, réception CTO en attente

Cette section suffit à une implémentation indépendante de l'enveloppe, de son AAD et de ses règles de rejet. « DOIT » désigne une obligation du protocole proposé. Tous les nombres de taille sont en **octets**, sauf indication contraire. Toutes les bornes sont inclusives. Le nom « AAD V2 / lyxal:v2 » désigne ce schéma ; son préfixe binaire exact est celui indiqué ci-dessous, sans autre préfixe implicite.

## 1 Suite, entrée et représentation transport

Suite unique : AES-256-GCM selon NIST SP 800-38D, clé 32 octets, nonce 12 octets, tag complet 16 octets. Aucun tag tronqué, padding de plaintext, compression, KDF implicite ou paramètre négocié. Les bytes de la clé sont utilisés directement par AES-256-GCM. La clé n'est ni un mot de passe ni une chaîne Base64 à interpréter par AES. Plaintext quelconque, y compris vide, de 0 à 1 048 576 octets.

Le transport est la chaîne ASCII exacte :

```text
enc:v2:<key_id>:<payload_base64url>
```

Les deux premiers composants et les trois `:` sont des littéraux sensibles à la casse. `key_id` est défini au §2. `payload_base64url` utilise uniquement l'alphabet RFC 4648 §5 `A-Z a-z 0-9 - _`, sans `=`, whitespace, saut de ligne, BOM ni terminaison NUL. Les bits inutilisés du dernier caractère DOIVENT être nuls : `encode(decode(s)) == s`. Aucun décodage URL/percent, JSON, Unicode ou transport additionnel n'est réalisé par le crate. Une couche HTTP/JSON peut transporter cette chaîne mais doit transmettre sa valeur exacte à `parse`.

Le payload décodé est exactement :

| Offsets demi-ouverts | Contenu |
|---|---|
| `[0,12)` | nonce de 12 octets |
| `[12,n-16)` | ciphertext, éventuellement vide |
| `[n-16,n)` | tag de 16 octets |

`n` est compris entre 28 et 1 048 604. Le ciphertext a la même longueur que le plaintext. La longueur Base64 sans padding d'un binaire de n octets est `B(n)=ceil(4*n/3)`, calculée avec arithmétique vérifiée. Longueur texte = `8 + len(key_id) + B(n)` : minimum 47, maximum **1 398 211**. Maximum du composant Base64 : **1 398 139**. Aucun ajout après le tag n'est accepté comme extension : il ferait partie d'un autre ciphertext dont le tag doit être vérifié.

## 2 Valeurs, identités et champs obligatoires

Tous les champs sont obligatoires dans leur mode. `None`, chaîne vide, tenant implicite, espace ajouté puis supprimé ou encodage de secours sont interdits. Les expressions ci-dessous correspondent à l'intégralité du champ, avec classes **ASCII**, sans option insensible à la casse.

| Champ | Règle exacte | Taille |
|---|---|---|
| key_id | `[A-Za-z0-9._-]{1,64}` | 1..64 |
| tenant | `[A-Za-z0-9_-]{1,128}` | 1..128 |
| module, resource, field | `[a-z][a-z0-9_]{0,63}` chacun | 1..64 chacun |
| purpose global | `[a-z][a-z0-9._-]{0,127}` | 1..128 |
| record_id | UTF-8 strict de valeurs scalaires Unicode ; contraintes ci-dessous | 1..1024 |

`record_id` : séquences UTF-8 surlongues, substituts UTF-16 et bytes invalides interdits ; U+0000..U+001F et U+007F..U+009F interdits partout. Premier/dernier scalaire interdit s'il appartient à la liste figée suivante : U+0009..U+000D, U+0020, U+0085, U+00A0, U+1680, U+2000..U+200A, U+2028, U+2029, U+202F, U+205F, U+3000. Il ne faut pas utiliser une version variable de `trim`/`is_whitespace` pour définir cette liste. Les caractères intérieurs non interdits, dont `:`, espaces ordinaires et Unicode, sont conservés tels quels. Une forme composée et une forme décomposée restent **distinctes** : aucun NFC/NFKC, lowercase, case-folding ou normalisation d'espace. Les séquences de format Unicode non explicitement interdites restent exactes ; elles ne sont pas affichées dans les diagnostics de contexte.

`Acme` et `acme` sont deux tenants différents ; `rec_A` et `rec_a` sont deux records différents. Les champs interdits sont rejetés, jamais transformés. `.`/`..` peuvent être des key IDs mais ne sont jamais des noms de fichier dérivés. L'hôte fournit l'identité autorisée ; le protocole n'implémente aucune autorisation ni interprétation d'un ID SurrealDB.

## 3 Encodage binaire exact de l'AAD

Définir `LP(s) = U32BE(len(UTF8(s))) || UTF8(s)`. U32BE est un entier non signé de 4 octets, ordre réseau, aucune représentation décimale, aucun terminateur ni séparateur additionnel. Tous les champs sont bornés avant conversion/allocation. Pour les champs ASCII, UTF8(s) est identique aux bytes ASCII.

Constante `P`, **32 octets**, incluant le NUL final :

```text
ASCII : lyxal:crypto:enc:v2:aes-256-gcm suivi de 00
HEX   : 6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d00
```

Mode tenant, octet `01` :

```text
AAD = P || 01 || LP(key_id) || LP(tenant) || LP(module)
        || LP(resource) || LP(record_id) || LP(field)
```

Mode global, octet `02` :

```text
AAD = P || 02 || LP(key_id) || LP(purpose)
```

Aucun autre mode n'existe. Les octets `01`/`02` sont binaires, pas des chaînes ASCII. En mode global, aucun emplacement vide pour tenant/module/resource/record/field n'est inséré. En mode tenant, aucun purpose global n'est ajouté. L'AAD maximum vaut **1465 octets** en tenant, **233 octets** en global. Les deux domaines ont des ensembles d'encodages disjoints. Les champs LP sont injectifs sur les valeurs validées ; une comparaison par caractères ou un séparateur `:` ne peut pas remplacer les longueurs.

L'enveloppe ne transporte **pas** le contexte : `open` reçoit le contexte autorisé de l'hôte, et reconstruit l'AAD avec le key ID exact de l'enveloppe. Mode et purpose ne sont jamais devinés ni testés successivement jusqu'à un succès. Version et suite sont authentifiées par `P`, key ID par son LP, mode par son octet, identité/usage par les LP suivants. Le préfixe texte est fixe et strictement validé ; il ne peut donc pas diverger du domaine authentifié. Le nonce et le ciphertext sont liés au tag par GCM lui-même. Aucun header variable n'est laissé non authentifié.

## 4 Scellement, ouverture et règles de rejet

Scellement : valider les tailles/contexte -> capturer un snapshot -> obtenir sa clé active -> produire un nonce CSPRNG de 12 bytes -> calculer AAD -> AES-GCM -> concaténer nonce/ciphertext/tag -> Base64URL canonique. Échec CSPRNG => erreur, jamais nonce nul ou compteur de secours. Les nonces déterministes des fixtures sont exclusivement des paramètres du calcul de référence et de tests privés, jamais de l'API publique.

Parsing : (1) rejeter taille >1 398 211 avant allocation ; (2) exiger ASCII et exactement quatre composants séparés par trois `:` ; (3) exiger `enc`, version canonique et composants non vides ; (4) version reconnue seule `v2`, ancienne `v1`/autre version numérique canonique => `UnsupportedVersion` ; (5) valider key ID et longueur Base64 avant décodage ; (6) contrôler alphabet, longueur modulo 4 différente de 1, absence de padding et bits terminaux nuls ; (7) décoder dans une allocation bornée ; (8) exiger payload de 28..1 048 604 bytes. `v02`, `V2`, `ENC`, marqueurs de version non numériques ou avec zéros initiaux ne sont pas canoniques et donnent `InvalidEnvelope`. Aucun entier de version non borné n'est alloué/converti ; pour classifier une version inconnue, au plus trois chiffres ASCII après `v`, premier non nul. Autres syntaxes invalides => `InvalidEnvelope`, sans entrée reflétée. Les entrées trop grandes => `InputTooLarge`. Une version inconnue peut être rejetée sans valider son ciphertext ; ce rejet n'est pas une authentification.

Ouverture : exiger enveloppe parsée V2 -> capturer un snapshot -> clé absente/révoquée refusée -> reconstruire AAD exact -> vérifier le tag complet -> rendre seulement alors les bytes déchiffrés protégés. Tag/nonce/ciphertext/key ID/contexte incompatibles donnent `AuthenticationFailed` si la clé est résolue. Ne pas exposer de plaintext partiel ni de source d'erreur contenant les bytes. Une enveloppe parsée, son key ID ou un `encode` réussi **ne prouvent jamais son authenticité**. Rejet et effacement du buffer sensible sur tout échec d'AEAD.

## 5 Vecteurs déterministes littéraux et indépendants

Provenance ciblée de la révision A-R2 : calcul de référence avec Python `cryptography 50.0.0`, backend **OpenSSL 4.0.1 (9 juin 2026)**, sans appel, compilation ni exécution de `lyxal_crypto`. Contrôle préalable NIST AES-256-GCM : clé 32 bytes nuls, nonce 12 bytes nuls, plaintext/AAD vides => tag `530f8afbc74536b9a963b4f1c4cb738b`. Chaque résultat ci-dessous a aussi été rouvert avec ce moteur indépendant. Cette provenance indépendante, établie avant l'implémentation Rust V2, ne suffisait pas à valider celle-ci. La vérification croisée par RustCrypto est exécutée par les tests littéraux envelope_v2_fixtures et les tests AAD privés, sans recalculer leurs attendus.

Clé publique de **test uniquement**, commune aux trois cas :

```text
KEY_HEX=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
```

T1 : mode tenant ; key_id=`k1`, tenant=`Acme`, module=`booking`, resource=`setting`, record_id=`rec_é` avec é=U+00E9 (`c3 a9`, six bytes pour le record complet), field=`password` ; plaintext ASCII `Lyxal V2`.

```text
NONCE_HEX=000102030405060708090a0b
PLAINTEXT_HEX=4c7978616c205632
AAD_LENGTH=91
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0001000000026b310000000441636d6500000007626f6f6b696e670000000773657474696e67000000067265635fc3a90000000870617373776f7264
CIPHERTEXT_HEX=0b7bae7aa9c59429
TAG_HEX=53c1553b0ebca1ea8330528d323cd795
PAYLOAD_HEX=000102030405060708090a0b0b7bae7aa9c5942953c1553b0ebca1ea8330528d323cd795
ENVELOPE=enc:v2:k1:AAECAwQFBgcICQoLC3uueqnFlClTwVU7Dryh6oMwUo0yPNeV
```

T0 : mêmes champs et AAD littéral que T1, plaintext vide, nonce distinct.

```text
NONCE_HEX=0c0d0e0f1011121314151617
PLAINTEXT_HEX=
AAD_LENGTH=91
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0001000000026b310000000441636d6500000007626f6f6b696e670000000773657474696e67000000067265635fc3a90000000870617373776f7264
CIPHERTEXT_HEX=
TAG_HEX=845ec723ee39605093e62576050a3b57
PAYLOAD_HEX=0c0d0e0f1011121314151617845ec723ee39605093e62576050a3b57
ENVELOPE=enc:v2:k1:DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw
```

G1 : mode global ; key_id=`k1`, purpose=`smtp.password`, plaintext ASCII `Lyxal V2`, nonce distinct.

```text
NONCE_HEX=18191a1b1c1d1e1f20212223
PLAINTEXT_HEX=4c7978616c205632
AAD_LENGTH=56
AAD_HEX=6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0002000000026b310000000d736d74702e70617373776f7264
CIPHERTEXT_HEX=5f663871b769337d
TAG_HEX=fd4a1e69ef1af40920d5c5458fcd3efe
PAYLOAD_HEX=18191a1b1c1d1e1f202122235f663871b769337dfd4a1e69ef1af40920d5c5458fcd3efe
ENVELOPE=enc:v2:k1:GBkaGxwdHh8gISIjX2Y4cbdpM339Sh5p7xr0CSDVxUWPzT7-
```

Ces constantes sont des oracles à recopier littéralement dans les tests de conformité, jamais à recalculer pour modifier le résultat attendu. Les bytes ASCII `Lyxal V2` n'incluent aucun saut de ligne. Les limites UTF-8 et la terminaison des blocs de documentation ne font pas partie des entrées.

Vecteurs de rejet minimaux : ` enc:v2:...`, `enc:V2:...`, `enc:v02:...`, `enc:v2: k1:...`, composant supplémentaire, payload avec `=`, `+` ou `/`, Base64 de longueur modulo 4 égale à 1, payload décodé de 27 bytes, payload >maximum. Variante non canonique exacte de T0 : remplacer le dernier `w` par `x` dans `DA0ODxAREhMUFRYXhF7HI-45YFCT5iV2BQo7Vw` conserve les bytes décodés chez un décodeur permissif mais DOIT être refusé pour bits terminaux non nuls. Pour T1, remplacer le key ID par `k2` alors que k2 contient la même clé DOIT échouer à l'authentification ; changer `Acme` en `acme` ou le mode en global doit également échouer, sans fallback. Deux IDs différents pointant le même matériel ne créent pas deux budgets de nonce (SECURITY.md (budgets de clés)).

Conserver SHA-256, BLAKE3, HMAC-SHA256, HKDF-SHA256, Argon2id v19 et OsRng. Aucun chiffrement maison ni nouveau protocole négociable. `v2` est une rupture explicite : `ENVELOPE_FORMAT_V1.md` restera historique, et la spécification du présent paragraphe est publiée dans ce document en phase B. Aucun adaptateur V1 automatique ni migration de données extérieure.

