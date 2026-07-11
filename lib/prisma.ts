import { PrismaClient } from '@prisma/client';
import { PrismaD1 } from '@prisma/adapter-d1';
import { getCloudflareContext } from '@opennextjs/cloudflare';

// The D1 binding type, derived from PrismaD1's own constructor so we don't have
// to pull in the global workerd runtime types (which would override the DOM
// `Response.json(): any` that the existing client/server code relies on).
type D1Binding = ConstructorParameters<typeof PrismaD1>[0];

// On Cloudflare Workers the D1 binding lives on the per-request context, so we
// cannot build a single module-level client the way the Neon/pg setup did.
// Instead we lazily create (and cache) one PrismaClient per D1 binding instance
// and expose it through a Proxy so existing `import { prisma }` call sites keep
// working unchanged — every property access resolves the current request's DB.
const clients = new WeakMap<object, PrismaClient>();

function resolveClient(): PrismaClient {
  const { env } = getCloudflareContext();
  const db = (env as unknown as { DB: D1Binding }).DB;
  if (!db) {
    throw new Error('D1 binding "DB" is not available in the Cloudflare context');
  }
  let client = clients.get(db as object);
  if (!client) {
    client = new PrismaClient({ adapter: new PrismaD1(db), log: ['error'] });
    clients.set(db as object, client);
  }
  return client;
}

export const prisma = new Proxy({} as PrismaClient, {
  get(_target, prop, receiver) {
    const client = resolveClient();
    const value = Reflect.get(client, prop, receiver);
    return typeof value === 'function' ? value.bind(client) : value;
  },
});
