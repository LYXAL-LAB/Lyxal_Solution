# Cal.com Dependencies Analysis

This list is primarily derived from `apps/web/package.json`, which represents the main web application.

## Core Dependencies
- **Next.js**: `15.5.4` (Framework)
- **React**: `^18.2.0` (UI Library)
- **Prisma**: `workspace:*` (ORM - managed in monorepo)
- **tRPC**: `workspace:*` (Type-safe API)
- **Tailwind CSS**: `^4` (Styling - via devDependencies)
- **NextAuth.js**: `^4.22.1` (Authentication)
- **Zod**: `^3.22.4` (Schema Validation)

## Internal Monorepo Packages (Workspace)
These are internal packages used by the web app:
- `@calcom/app-store`
- `@calcom/dayjs`
- `@calcom/embed-core`
- `@calcom/embed-react`
- `@calcom/features`
- `@calcom/lib`
- `@calcom/platform-enums`
- `@calcom/platform-types`
- `@calcom/prisma`
- `@calcom/trpc`
- `@calcom/ui`

## Third-Party Integrations & Utilities
- **Google APIs**: `@googleapis/calendar`, `@googleapis/oauth2`, etc.
- **Stripe**: `@stripe/stripe-js`, `@stripe/react-stripe-js`, `stripe`
- **Daily.co**: `@daily-co/daily-js`, `@daily-co/daily-react` (Video)
- **Radix UI**: Various `@radix-ui/*` components (Headless UI)
- **React Hook Form**: `@hookform/*`, `react-hook-form` (Forms)
- **TanStack Query**: `@tanstack/react-query` (Data Fetching)
- **Sentry**: `@sentry/nextjs` (Error Monitoring)
- **Lodash**: `lodash` (Utilities)
- **Nodemailer**: `nodemailer` (Email)
- **i18next**: `next-i18next` (Internationalization)
- **FullCalendar/Day.js**: `rrule`, `dayjs` (Calendar logic)

## Dev Dependencies (Notable)
- **TypeScript**: `^5.9.0-beta`
- **Turbo**: `^2.5.5` (Build System)
- **Playwright**: `@playwright/test` (E2E Testing)
- **Vitest**: `vitest` (Unit Testing)
- **ESLint/Prettier**: Linting and formatting
