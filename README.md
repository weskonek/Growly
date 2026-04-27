# 🌱 Growly

> **AI-Powered Digital Growth Platform for Kids & Teens**
> 
> Mengubah screen time menjadi growth time — parental control + AI tutor adaptif untuk anak usia 2 tahun sampai SMA.

---

## 🏗️ Struktur Monorepo

```
Growly/
├── apps/
│   ├── parent_app/          # Flutter app untuk orang tua
│   └── child_app/           # Flutter app untuk device anak
├── packages/
│   ├── core/                # Shared logic, models, utils
│   ├── ui_kit/              # Shared design system & components
│   ├── ai_tutor/            # AI tutor engine & prompt templates
│   └── parental_control/    # Parental control native bridges
├── backend/
│   ├── supabase/            # Database schema, RLS policies, migrations
│   └── functions/           # Supabase Edge Functions
├── docs/
│   ├── architecture.md
│   ├── db_schema.md
│   └── api_contracts.md
└── scripts/                 # Dev tooling & CI helpers
```

## 🚀 Tech Stack

| Layer | Tech |
|-------|------|
| Mobile App | Flutter 3.x (monorepo, Melos) |
| State Management | Riverpod + AsyncNotifier |
| Navigation | GoRouter |
| Backend | Supabase (Postgres, Auth, Storage, Realtime) |
| Edge Functions | Deno (Supabase Edge Functions) |
| AI | OpenAI GPT-4o (gateway via Edge Function) |
| Notifications | FCM (Android) + APNs (iOS) |
| Native Android | Kotlin (UsageStats, DeviceAdmin, Accessibility) |
| Native iOS | Swift (Screen Time / FamilyControls API) |

## 📱 App Targets

- **Parent App** — Setup family, atur kebijakan, lihat dashboard progress & insights
- **Child App** — Safe launcher, learning hub, AI tutor, reward system

## 🧩 Modul Utama

1. **Auth & Identity** — parent login, family workspace, child profile binding
2. **Parental Control Core** — app lock, screen time rules, school mode, safe mode
3. **Learning Core** — kurikulum per usia, lesson engine, rewards, offline packs
4. **AI Core** — tutor engine per age band (2–5, 6–9, 10–12, 13–18), hint-first pedagogy
5. **Analytics & Reporting** — screen time, learning time, risk flags, weekly digest
6. **Compliance & Safety** — consent, audit logs, data retention, COPPA-like

## 🗄️ Database

Supabase + PostgreSQL. Lihat detail di [`docs/db_schema.md`](docs/db_schema.md).

## 🏁 Mulai Development

```bash
# Install Melos (monorepo tool for Flutter)
dart pub global activate melos

# Bootstrap semua packages
melos bootstrap

# Jalankan parent app
cd apps/parent_app && flutter run

# Jalankan child app
cd apps/child_app && flutter run
```

## 📄 Dokumentasi

- [Arsitektur Sistem](docs/architecture.md)
- [Database Schema](docs/db_schema.md)
- [API Contracts](docs/api_contracts.md)

---

*Built with ❤️ by PT Tekno Konek Solusi — Weskonek*
