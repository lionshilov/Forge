# Next.js + Supabase Template

A Next.js 15 (App Router) + Supabase starter. Auth-ready, type-safe, deployable to Vercel in one click.

## What's included
- Next.js 15 with App Router + Server Components
- Supabase JS client (anon + service role helpers)
- TypeScript strict mode
- Tailwind CSS
- `.env.example` with every variable you need
- Middleware stub for auth-guarded routes

## Setup

```bash
# 1. Install
pnpm install         # or npm install / yarn

# 2. Copy env
cp .env.example .env.local

# 3. Fill .env.local from your Supabase project:
#    Settings → API → Project URL + anon key (and service role if needed)

# 4. Run
pnpm dev
```

Open http://localhost:3000.

## Deploy

- **Vercel**: connect the repo, paste the env vars from `.env.local` into Vercel's env settings, deploy.
- Any Node host works — Supabase is just an HTTP client, no special infra required.

## File tree
```
.
├── app/
│   ├── layout.tsx            # Root layout with global styles
│   ├── page.tsx              # Landing page (shows your Supabase connection status)
│   └── globals.css           # Tailwind directives
├── lib/
│   ├── supabase/
│   │   ├── client.ts         # Browser-side client
│   │   └── server.ts         # Server-side client (cookies-aware)
│   └── env.ts                # Typed env var access
├── .env.example
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── postcss.config.js
└── next.config.mjs
```

## Conventions (override via project_context/CONVENTIONS.md)
- Server Components by default. Mark client components with `'use client'` only when needed.
- Data fetching in Server Components or route handlers, never in Client Components.
- Secrets: `NEXT_PUBLIC_*` is public — anything sensitive stays server-only.
