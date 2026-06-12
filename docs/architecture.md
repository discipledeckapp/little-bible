# Little Bible — Architecture Notes

## Content Layer

Content is stored as static JSON files under `public/data/{lang}/{book}/`.
The server reads files at request time using Node's `fs` module via `lib/content.ts`.
No API route or database is needed in the current phase.

### Extending to Supabase / PostgreSQL

Replace the `fs.readFileSync` calls in `lib/content.ts` with `fetch` calls to a
REST or tRPC API. The function signatures stay the same — nothing else in the app changes.

## Routing

| URL              | Page                              |
|------------------|-----------------------------------|
| `/`              | Homepage — book & chapter library |
| `/proverbs/1`    | Proverbs Chapter 1 reader         |
| `/genesis/1`     | Genesis Chapter 1 reader          |
| `/{book}/{ch}`   | Any book, any chapter             |

Routes are statically pre-generated via `generateStaticParams` at build time.
In development (`npm run dev`) they resolve dynamically on each request.

## State Management

| State             | Location          | Notes                              |
|-------------------|-------------------|------------------------------------|
| Reading mode      | localStorage      | Persists across pages              |
| Verse reviews     | localStorage      | One entry per book+chapter         |
| Current verse     | React state       | Resets on page load                |

## Planned Books (in order of priority)

1. Proverbs (in progress)
2. Psalms
3. Genesis
4. Matthew
5. John
6. Romans
7. Exodus

## Flutter / API Layer

The types in `types/index.ts` map directly to Dart model classes:

```dart
class Verse {
  final String book;
  final int chapter;
  final int verse;
  final String kjv;
  final String littleBible;
  // ...
}
```

When an API layer is added, the same JSON schema is served from an endpoint
and consumed identically by both the Next.js app and the Flutter app.
