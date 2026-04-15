import { getSupabaseServerClient } from '@/lib/supabase/server';

export default async function HomePage() {
  const supabase = getSupabaseServerClient();
  const { error } = await supabase.auth.getSession();
  const connected = !error;

  return (
    <main className="max-w-2xl mx-auto px-6 py-16">
      <h1 className="text-3xl font-semibold tracking-tight mb-4">My App</h1>
      <p className="text-gray-400 leading-relaxed mb-8">
        Next.js + Supabase starter, bootstrapped with Forge. Edit{' '}
        <code className="bg-gray-800 px-1.5 py-0.5 rounded">app/page.tsx</code> to get started.
      </p>
      <div className="p-4 rounded-lg border border-gray-800 bg-gray-900/50">
        <div className="text-sm text-gray-400 mb-1">Supabase connection</div>
        <div className={connected ? 'text-green-400' : 'text-red-400'}>
          {connected ? '✓ Connected' : '✗ Check your .env.local'}
        </div>
      </div>
    </main>
  );
}
