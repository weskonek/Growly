# Growly Backend - Supabase

Backend infrastructure for Growly using Supabase (PostgreSQL, Auth, Realtime, Edge Functions).

## Directory Structure

```
backend/
├── supabase/
│   ├── config.toml           # Supabase CLI configuration
│   ├── migrations/           # Database migrations
│   │   ├── 00001_initial_schema.sql
│   │   ├── 00002_add_rls_policies.sql
│   │   └── 00003_add_realtime.sql
│   ├── functions/           # Edge Functions (Deno)
│   │   ├── ai-tutor/        # AI tutor with Gemini API
│   │   ├── sync-handler/    # Offline sync handler
│   │   └── notifications/   # Push notifications
│   └── seed/                # Seed data
└── scripts/                 # Utility scripts
```

## Quick Start

### 1. Install Supabase CLI
```bash
# macOS
brew install supabase/tap/supabase

# Or via npm
npm install -g supabase
```

### 2. Link to Supabase Project
```bash
cd backend/supabase
supabase login
supabase link --project-ref <your-project-ref>
```

### 3. Apply Migrations
```bash
# Apply all migrations
supabase db reset

# Or push to linked project
supabase db push
```

### 4. Set Environment Variables
```bash
# Copy environment template
cp ../../.env.example .env.local

# Set secrets
supabase secrets set GEMINI_API_KEY=your-key
```

### 5. Deploy Edge Functions
```bash
supabase functions deploy ai-tutor
supabase functions serve
```

## Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `parent_profiles` | Parent user data (extends Supabase Auth) |
| `child_profiles` | Child profiles with PIN |
| `learning_progress` | Learning activity tracking |
| `screen_time_records` | Usage statistics |
| `app_restrictions` | App whitelist/blacklist |
| `schedules` | Time-based mode switching |
| `badges` | Achievement badges |
| `reward_systems` | Stars and streaks |
| `ai_tutor_sessions` | AI chat history |

### Key Features

- **Row Level Security (RLS)**: Parents can only access their own children's data
- **Realtime**: Cross-device sync via Supabase Realtime
- **Audit Logs**: COPPA compliance tracking

## Edge Functions

### AI Tutor (`ai-tutor`)
- Integrates with Gemini API
- Age-appropriate prompt templates
- Content safety filters
- Session logging for analytics

### Environment Variables Required
```bash
GEMINI_API_KEY=your-key
SUPABASE_SERVICE_ROLE_KEY=your-key
```

## CI/CD

See `.github/workflows/` for GitHub Actions configuration.

## Migration Workflow

```bash
# Create new migration
supabase migration new add_new_feature

# Apply locally
supabase db reset

# Apply to staging
supabase db push --environment staging

# Apply to production
supabase db push --environment production
```

## Notes

- Never commit `.env.local` or secrets to git
- Use separate Supabase projects for dev/staging/prod
- Run migrations before deploying Edge Functions
- Check `supabase/logs` for Edge Function debugging