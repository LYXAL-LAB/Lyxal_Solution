# Lyxal Module Runtime

> **The Universal Module Lifecycle Engine for Lyxal OS**

## Overview

**Lyxal Module Runtime (LMR)** is the core orchestration engine of **Lyxal OS**.

Its mission is simple:

> Ensure that every module installed in Lyxal OS always matches its desired state.

Unlike traditional applications where installation, database migrations, service startup, and updates are performed manually, Lyxal Module Runtime continuously reconciles the system automatically.

A module is no longer just source code.

A module is a **self-describing package** capable of installing, updating, repairing, monitoring and removing itself without human intervention.

---

# Philosophy

Everything in Lyxal OS is a module.

Examples:

* Scheduler
* Notification
* Calendar
* Storage
* Authentication
* CRM
* ERP
* BIM
* AI Studio
* Mail
* RTC
* Drive

Every module follows exactly the same lifecycle.

```
Discover

↓

Validate

↓

Install

↓

Migrate

↓

Configure

↓

Start

↓

Monitor

↓

Repair

↓

Update

↓

Remove
```

The runtime manages the complete lifecycle.

---

# Design Goals

* Fully automatic installation
* Zero manual database migration
* Self-healing infrastructure
* Declarative architecture
* Hot module installation
* Version-aware updates
* Dependency management
* Multi-tenant ready
* SurrealDB native
* Rust native

---

# Core Concepts

## Desired State

Lyxal Runtime never asks:

> What should I execute?

Instead it asks:

> What should the system look like?

Example:

```text
Scheduler

Version = 1.5.0

Enabled = true
```

The runtime computes every action required to reach that state.

---

## Actual State

The runtime continuously inspects:

* installed version
* database schema
* indexes
* functions
* workers
* API routes
* permissions
* health
* dependencies

---

## Reconciliation

```
Desired State

↓

Actual State

↓

Difference

↓

Automatic Repair
```

No manual intervention.

---

# Module Structure

Example:

```
scheduler/

Cargo.toml

manifest.toml

schema/

functions/

permissions/

workers/

events/

routes/

migrations/

assets/

src/
```

Every module follows the exact same structure.

---

# Manifest

Example:

```toml
[module]

name = "scheduler"

version = "1.4.0"

description = "Distributed scheduler"

enabled = true

author = "Lyxal"
```

Dependencies:

```toml
[dependencies]

notification = ">=1.0"

storage = ">=2.0"
```

Capabilities:

```toml
[capabilities]

workers = true

api = true

database = true

events = true
```

---

# Database Migrations

Each module contains its own migrations.

```
migrations/

0001_init.surql

0002_jobs.surql

0003_retry.surql

0004_permissions.surql
```

The runtime automatically:

* detects missing migrations
* validates checksums
* executes migrations
* stores execution history
* supports rollback policies

No migration command is required.

---

# Runtime Database

The runtime stores its internal state inside SurrealDB.

Example tables:

```
system_module

system_module_release

system_module_dependency

system_module_configuration

system_migration

system_health

system_worker

system_event

system_capability
```

---

# Module Lifecycle

## Discovery

Search installed modules.

↓

## Validation

Validate manifest.

↓

## Dependency Resolution

Resolve dependency graph.

↓

## Installation

Create database objects.

↓

## Migration

Execute required migrations.

↓

## Configuration

Load runtime configuration.

↓

## Startup

Launch workers.

Register APIs.

Register events.

↓

## Health Monitoring

Monitor runtime health.

↓

## Self-Healing

Repair missing resources automatically.

↓

## Update

Install newer release.

↓

## Removal

Clean shutdown.

Delete runtime resources.

---

# Self-Healing

The runtime periodically verifies that every module is healthy.

Examples:

Missing function?

→ recreate automatically

Missing index?

→ recreate automatically

Worker stopped?

→ restart automatically

Permission missing?

→ restore automatically

Event deleted?

→ recreate automatically

The runtime continuously converges toward the desired state.

---

# Module Installation

```
Install Module

↓

Read Manifest

↓

Validate

↓

Resolve Dependencies

↓

Execute Migrations

↓

Register APIs

↓

Start Workers

↓

Health Check

↓

Ready
```

---

# Hot Installation

Modules can be installed while Lyxal OS is running.

No restart required.

---

# Module Updates

Updates are declarative.

Example:

```
Desired Version

↓

Installed Version

↓

Migration Plan

↓

Automatic Update
```

---

# Dependency Graph

Example:

```
Calendar

│

├── Scheduler

├── Notification

└── Storage
```

Dependencies are automatically resolved before startup.

---

# Runtime API

Example operations:

```
Install Module

Update Module

Remove Module

Enable Module

Disable Module

Repair Module

Restart Module

Validate Module

Health Check

List Modules
```

---

# Health Status

Each module exposes its runtime state.

Example:

```
Scheduler

✔ Installed

✔ Enabled

✔ Version 1.4.0

✔ Healthy

✔ Database OK

✔ Workers 8 / 8

✔ API Registered

✔ Events Active
```

---

# Multi-Tenant Support

Lyxal Runtime supports tenant isolation.

Each tenant may have:

* different modules
* different versions
* different configuration
* different permissions

while sharing the same runtime engine.

---

# Marketplace Ready

Third-party developers can build modules by following the runtime specification.

A valid module only needs:

```
manifest.toml

migrations/

src/
```

Optional:

```
workers/

events/

permissions/

routes/

assets/
```

No custom installer is required.

---

# Future Features

* Module Marketplace
* Signed Modules
* Version Channels
* Rollback Engine
* Remote Deployment
* Cluster Synchronization
* Runtime Policies
* Feature Flags
* Progressive Rollouts
* Remote Module Registry
* Automatic Backups
* Module Snapshots
* Distributed Runtime
* AI-assisted Diagnostics

---

# Architecture

```
                Lyxal OS

                     │

        ┌────────────┴────────────┐

        │                         │

 Module Runtime          SurrealDB

        │

        ├──────── Scheduler

        ├──────── Notification

        ├──────── Calendar

        ├──────── Storage

        ├──────── RTC

        ├──────── CRM

        ├──────── Drive

        ├──────── Mail

        └──────── Future Modules
```

---

# Vision

Lyxal Module Runtime is not simply a migration engine.

It is the operating system responsible for the complete lifecycle of every module inside Lyxal OS.

Its responsibility is to ensure that the platform remains consistent, healthy, secure and continuously aligned with its declared state.

The objective is simple:

> **Describe the desired state once. Let Lyxal Module Runtime do the rest.**
