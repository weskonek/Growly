# Growly Admin Web

Admin dashboard for Growly platform.

## Setup

### 1. Install Dependencies

```bash
cd apps/admin_web
npm install
```

### 2. Environment Variables

Copy `.env.example` to `.env.local` and fill in your Supabase credentials:

```bash
cp .env.example .env.local
```

Required variables:
- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anon key
- `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key (server-side only!)

### 3. Run Migration

Apply the admin_users migration to your Supabase database:

```bash
# Using Supabase CLI
supabase db push

# Or manually run the SQL in:
# backend/supabase/migrations/00006_admin_users.sql
```

### 4. Create Admin User

Insert an admin user directly in Supabase:

```sql
INSERT INTO public.admin_users (id, name, email, role)
VALUES (
  'your-user-id-from-auth-users',
  'Admin Name',
  'admin@growly.id',
  'superadmin'
);
```

### 5. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## Features

- **Dashboard** - Overview metrics
- **Users** - Manage parent accounts
- **Children** - View all child profiles
- **AI Moderation** - Review flagged AI tutor sessions
- **Audit Logs** - COPPA compliance logs

## Project Structure

```
src/
├── app/
│   ├── login/          # Login page
│   ├── dashboard/      # Protected dashboard routes
│   └── layout.tsx      # Root layout
├── components/
│   ├── ui/             # Base UI components (Radix UI)
│   └── dashboard/      # Dashboard-specific components
├── lib/
│   └── supabase/       # Supabase clients
├── actions/            # Server actions
└── types/              # TypeScript types
```

## Tech Stack

- Next.js 14 (App Router)
- Supabase
- Tailwind CSS
- Radix UI
- Recharts (for analytics)
- Sonner (toast notifications)
