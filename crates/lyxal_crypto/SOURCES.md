# Provenance du code et des vecteurs repris

`lyxal_crypto` est sous licence `MIT OR Apache-2.0` (workspace). Il ne reçoit aucun code AGPL,
GPL ni `LicenseRef-SEL` (règle de provenance du programme courrier, §4.1). Ce fichier liste tout
ce qui vient d'ailleurs, avec sa licence et sa version figée.

| Élément | Origine | Licence | Où |
| :--- | :--- | :--- | :--- |
| Vecteurs AES-GCM | Projet Wycheproof (C2SP), `testvectors_v1/aes_gcm_test.json`, commit `65ca494727a52944c204441c860b039e6786b99b` ; SHA-256 du fichier : `985e5ecc172e181eaf49e89508b9470dcf478002eb7e8559c707eb42dc97dfe7` | Apache-2.0 (texte complet copié : `tests/fixtures/wycheproof/LICENSE`) | `tests/fixtures/wycheproof/aes_gcm_test.json`, lu par le test privé `stream::vectors::wycheproof_aes_256_gcm_segment_primitive` (cas à clé de 256 bits, nonce de 96 bits, tag de 128 bits : 66 cas) |
| Certificats et clés de test TLS | Générés pour ce dépôt par OpenSSL (commandes : `tests/fixtures/README.md`) | ceux du dépôt | `tests/fixtures/tls_test_only/`, tests seulement |
| Vecteurs du format de flux v1 | Calculés pour ce dépôt par Python `cryptography` 50.0.1 (OpenSSL) | ceux du dépôt | `STREAM_FORMAT_V1.md` §7 |

Le fichier Wycheproof est copié tel quel, jamais modifié ; une mise à jour change le commit et
l'empreinte ci-dessus dans la même demande de fusion.
