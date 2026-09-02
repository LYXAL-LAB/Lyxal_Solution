# 📜 Third Party Licenses & Architectural Attributions

Le crate `lyxal_event` a été développé nativement pour l'écosystème Lyxal OS et la base de données SurrealDB. Dans le cadre de sa conception architecturale, certains patterns et algorithmes de pointe issus de projets open source reconnus ont été adaptés.

---

## 1. Hexeract (`nubster-opensources/hexeract`)

* **Licence** : Duale MIT / Apache-2.0
* **Auteur / Copyright** : (c) 2026 Nubster
* **Éléments adaptés dans `lyxal_event`** :
  * **Algorithme de calcul du bail (Lease Scaling)** : Dimensionnement du bail de locking à `batch_len * dispatch_timeout` pour empêcher l'expiration prématurée des livraisons en queue de lot lors d'un traitement séquentiel.
  * **Algorithme de Retry avec Full Jitter** : Calcul de backoff exponentiel borné `min(max_delay, base_delay * 2^attempts)` combiné à un tirage uniforme avec `fastrand` pour éliminer les réveils synchrones (*thundering herd*).
  * **Registre de Handlers par Effacement de Type (`ErasedHandler` / `TypedHandler`)** : Permet l'enregistrement de handlers strongly-typed `Handler<E>` sans recours à une enum monolithique globale.
  * **Contexte d'exécution (`HandlerContext`)** : Transmission des identifiants (`MessageId`, `CorrelationId`) et du token d'annulation coopératif `CancellationToken` (avec child token pour l'isolation des timeouts).

### Notice MIT — Hexeract
```text
MIT License

Copyright (c) 2026 Nubster

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 2. Oxide Outbox (`Vancoola/oxide-outbox`)

* **Licence** : MIT
* **Auteur / Copyright** : (c) 2026 Dennis S. Dale
* **Éléments adaptés dans `lyxal_event`** :
  * **Séparation Producteur / Worker** : Ségrégation nette entre l'interface d'émission `EventPublisher` et le moteur d'exécution `EventWorker`.
  * **Garbage Collector dédié** : Architecture de nettoyage périodique asynchrone des événements et livraisons archivés selon une politique de rétention paramétrable.

### Notice MIT — Oxide Outbox
```text
The MIT License (MIT)

Copyright (c) 2026 Dennis S. Dale

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
```

---

## 3. Implémentations Originales Lyxal OS

Les éléments suivants constituent des créations et implémentations originales pour Lyxal OS :
* Modélisation et schémas relationnels/graphes SurrealDB (`event_outbox`, `event_subscription`, `event_delivery`, `event_dead_letter`).
* Fonctions transactionnelles SurrealQL (`fn::event_publish`, `fn::event_fanout`, `fn::event_recover_pending_fanouts`, `fn::event_claim_batch`, `fn::event_delivery_success`, `fn::event_delivery_failure`, `fn::event_dead_letter_replay`, `fn::event_purge_garbage`).
* Wrapper SurrealDB `EventStore` conforme à `LyxalSurrealCall` et `LyxalResult<T>`.
* Isolation stricte multi-instance (`instance_id`, `namespace`, `database`).
* Intégration bidirectionnelle native avec `DEFINE EVENT` SurrealDB et publication Rust.
