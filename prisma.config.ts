import { defineConfig } from 'prisma/config';
import { config } from 'dotenv';

// Load .env.local so Prisma CLI picks up credentials during migrations
config({ path: '.env.local' });

export default defineConfig({
  datasource: {
    // Direct (non-pooled) Neon URL for migrations
    url: process.env.DIRECT_URL ?? process.env.DATABASE_URL ?? '',
  },
});
