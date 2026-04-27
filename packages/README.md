# Growly Packages

This directory contains the shared packages for the Growly Flutter monorepo.

## Packages

### growly_core
Core package containing domain models, database schemas, and shared providers.

**Location:** `growly_core/`

**Key exports:**
- `domain/models/` - Child profiles, learning progress, screen time models
- `core/database/` - Drift database, Hive cache, Supabase sync
- `shared/providers/` - Auth and child state providers

### growly_ui_kit
Reusable UI components and themes for both parent and child apps.

**Location:** `growly_ui_kit/`

**Key exports:**
- `theme/` - Parent and child-friendly themes
- `widgets/` - Common widgets (cards, badges, progress rings)

### growly_ai_tutor
AI tutoring service layer with prompt templates and tutoring engine.

**Location:** `growly_ai_tutor/`

**Key exports:**
- `ai/services/` - AI tutor service with Gemini API integration
- `ai/prompts/` - Age-specific prompt templates (2-5, 6-9, 10-12, 13-18)
- `tutor/engine/` - Hint-first tutoring logic

### growly_parental_control
Platform channels for native parental control features on Android and iOS.

**Location:** `growly_parental_control/`

**Key exports:**
- `native/` - Android and iOS platform channel implementations
- `monitoring/` - Screen time tracking service
- `rules/` - Parental control rules engine

## Setup

Run `melos bootstrap` from the monorepo root to install dependencies for all packages.

## Dependencies

All packages depend on `growly_core` which provides the foundational types and database schemas.