import { defineConfig } from 'prisma/config';

// Cloudflare D1 (SQLite). The runtime connection is provided by the
// @prisma/adapter-d1 driver adapter (lib/prisma.ts). This local file url is
// only used by Prisma CLI commands (studio / migrate diff) — never at runtime.
export default defineConfig({
  datasource: {
    url: 'file:./prisma/.local.db',
  },
});
