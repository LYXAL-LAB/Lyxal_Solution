# 📄 Dossier de Preuve de Réalisation & Consolidation — Module 04 : Calendars

> **Statut de Réalisation** : **`UI IMPLEMENTED — READY FOR REVIEW 🟡`**  
> **Source de Vérité** : Code physique vérifié et consolidé dans [`lyxal_booking`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking)

---

## 📋 1. Cartographie Exhaustive des Primitives SurrealQL (`functions/integrations/`)

| Fonction SurrealQL | Fichier `.surql` Physique Harmonisé | Rôle & Signature |
| :--- | :--- | :--- |
| `fn::booking_create_calendar_source` | [`functions/integrations/fn_create_calendar_source.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_create_calendar_source.surql) | Création atomique d'une source distante (CalDAV, EWS, Google, Outlook, ICS) |
| `fn::booking_list_calendar_sources` | [`functions/integrations/fn_list_calendar_sources.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_list_calendar_sources.surql) | Lecture des sources connectées d'un utilisateur |
| `fn::booking_get_calendar_source` | [`functions/integrations/fn_get_calendar_source.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_get_calendar_source.surql) | Lecture détaillée d'une source par ID |
| `fn::booking_delete_calendar_source` | [`functions/integrations/fn_delete_calendar_source.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_delete_calendar_source.surql) | Suppression propre d'une source et de ses secrets |
| `fn::booking_set_write_calendar` | [`functions/integrations/fn_set_write_calendar.surql`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/functions/integrations/fn_set_write_calendar.surql) | Sélection du calendrier d'écriture cible |

---

## 🔒 2. Architecture du Flux Google OAuth2 Server-Side (100% Découplé)

```text
┌────────────────────────┐      ┌─────────────────────────┐      ┌─────────────────────────┐
│ WORKSPACE FRONTEND (UI)│ ──1─►│ AXUM API GET /connect   │ ──2─►│ GOOGLE AUTHORIZE URL    │
│ CalendarsPage.tsx      │      │ (State + PKCE Verifier) │      │ accounts.google.com     │
└────────────────────────┘      └─────────────────────────┘      └────────────┬────────────┘
            ▲                                                                 │
            │                                                                 │ (Redirection Navigateur)
            │ (HTTP 302 Redirect)                                             ▼
┌───────────┴────────────┐                                       ┌─────────────────────────┐
│ /workspace/calendars   │ ◄──────────────────────────────────3─ │ AXUM API GET /callback  │
│ ?oauth=success         │                                       │ (Échange Code, Token    │
│                        │                                       │  Chiffré & Source DB)   │
└────────────────────────┘                                       └─────────────────────────┘
```

### Étapes du Flux Canonique :
1. **Demande de Connexion (`GET /api/v1/calendars/google/connect`)** :  
   - Invoque `calendar_sources::get_google_oauth_url`, génère le state et le verifier PKCE S256, et retourne l'URL d'autorisation Google.
2. **Autorisation Distante** :  
   - L'utilisateur s'authentifie sur Google et valide le consentement. Google redirige le navigateur directement vers l'API Axum : `GET /api/v1/calendars/google/callback?code=...&state=...`.
3. **Consommation & Échange Serveur (`GET /api/v1/calendars/google/callback`)** :  
   - Validation atomique du `state`, échange du code contre les tokens via HTTPS POST, chiffrement des tokens avec `encrypt_caldav_password` et création de la source dans SurrealDB via `calendar_sources::create_source`.
4. **Redirection 302 HTTP & Refresh UI** :  
   - L'API Axum retourne `axum::response::Redirect::to("/workspace/calendars?oauth=success")`.
   - `CalendarsPage.tsx` intercepte `?oauth=success`, affiche un Toast de confirmation, nettoie l'URL avec `window.history.replaceState` et recharche la liste des sources.
   - **La méthode `handleGoogleCallback` a été totalement supprimée du SDK Client** (aucun code OAuth2 ne transite dans le JavaScript frontend).

---

## 🔍 3. Audit Physique des Découpages

- **UI React ([`CalendarsPage.tsx`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/workspace/modules/calendars/CalendarsPage.tsx))** :  
  - **0 `fetch()`, 0 `axios`, 0 `XMLHttpRequest`**.
  - Appelle uniquement `calendarsClient.*`.
- **Axum Handlers ([`calendars.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/web/api/v1/calendars.rs))** :  
  - **0 `reqwest`, 0 `crypto`, 0 `surrealdb::query`**.
  - Délégation intégrale au service neutre `calendar_sources::*`.
- **Service Neutre ([`calendar_sources.rs`](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_booking/engine/src/services/calendar_sources.rs))** :  
  - Seul point d'orchestration pour `encrypt_caldav_password`, `validate_outbound_url` (protection SSRF), et la persistance des sources.

---

## 🔗 Chaîne de Parité Validée
```text
CalendarsPage.tsx (UI React Workspace - 0 fetch direct)
        │
        ▼ (Appels SDK fortement typés)
calendarsClient.ts (SDK Client TypeScript - 0 callback OAuth JS)
        │
        ▼ (Appels REST HTTP /api/v1/calendars)
web/api/v1/calendars.rs (Axum Handlers - Redirection 302 HTTP sur /callback)
        │
        ▼ (Services Neutres Rust)
services::calendar_sources (set_write_calendar, get_google_oauth_url, encrypt_caldav_password, validate_outbound_url)
        │
        ▼ (Mutations atomiques SurrealQL)
fn::booking_create_calendar_source, fn::booking_list_calendar_sources, fn::booking_set_write_calendar
```
