'use client';

import { createBrowserClient } from '@supabase/ssr';
import { env } from '@/lib/env';

export function getSupabaseBrowserClient() {
  return createBrowserClient(env.supabaseUrl, env.supabaseAnonKey);
}
