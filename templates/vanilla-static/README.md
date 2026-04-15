# Vanilla Static Template

One HTML file. No build step. No dependencies. Deploy anywhere static.

## Run

```bash
open index.html              # macOS
xdg-open index.html          # Linux
# or serve with any static server:
python3 -m http.server 8000
```

## Ship

Any static host works — GitHub Pages, Cloudflare Pages, Netlify, Vercel.

For GitHub Pages: Settings → Pages → Source: `main` / root. Done.

## When to use
- Calculators, visualizers, one-page tools
- Landing pages with a bit of interactivity
- Demos and prototypes
- Anything under ~500 LOC where a framework is overkill

## When to outgrow it
- Routing across multiple pages
- Shared state across components
- Server-side rendering / SEO for dynamic content
- Auth / database integration

Then copy into a `nextjs-supabase/`-style template.
