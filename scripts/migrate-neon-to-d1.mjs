/**
 * One-off data migration: Neon Postgres -> Cloudflare D1.
 *
 * Reads every table from Neon with raw `pg` (so we get real JS types: arrays,
 * Dates, jsonb objects) and writes to D1 through Prisma's HTTP D1 adapter, which
 * handles all SQLite encoding (DateTime, booleans) for us. We only transform the
 * columns whose TYPE changed in the D1 schema:
 *   - text[]  -> JSON string   (completedChapters, faithGoals)
 *   - jsonb   -> JSON string   (AnalyticsEvent.props, AdminAuditLog.details)
 *
 * Usage:
 *   CLOUDFLARE_ACCOUNT_ID=... CLOUDFLARE_DATABASE_ID=... CLOUDFLARE_D1_TOKEN=... \
 *     node scripts/migrate-neon-to-d1.mjs [--wipe]
 *
 * --wipe  Delete all rows in D1 first (reverse FK order). Use at real cutover.
 *
 * The Neon connection string is read from DIRECT_URL / DATABASE_URL in .env.local.
 */
import { config } from 'dotenv';
import pg from 'pg';
import { PrismaClient } from '@prisma/client';
import { PrismaD1Http } from '@prisma/adapter-d1';

config({ path: '.env.local' });

const WIPE = process.argv.includes('--wipe');

const { CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_DATABASE_ID, CLOUDFLARE_D1_TOKEN } = process.env;
if (!CLOUDFLARE_ACCOUNT_ID || !CLOUDFLARE_DATABASE_ID || !CLOUDFLARE_D1_TOKEN) {
  console.error('Missing CLOUDFLARE_ACCOUNT_ID / CLOUDFLARE_DATABASE_ID / CLOUDFLARE_D1_TOKEN');
  process.exit(1);
}
const neonUrl = process.env.DIRECT_URL || process.env.DATABASE_URL;
if (!neonUrl) {
  console.error('Missing DIRECT_URL / DATABASE_URL for Neon');
  process.exit(1);
}

// Insert order respects foreign keys (parents first).
const ORDER = [
  'User', 'Account', 'Session', 'VerificationToken',
  'UserProgress',
  'Family', 'FamilyMember', 'MemberProgress', 'MemberSession',
  'FamilyStreak', 'FamilyPrayer', 'FamilyMilestone',
  'Donation', 'AnalyticsEvent', 'ContentReview', 'AdminAuditLog',
  'AppInterest', 'ActivityRecord', 'MemoryVerseProgress',
];

// Prisma delegate name per table (lower-cased first letter).
const delegate = (t) => t.charAt(0).toLowerCase() + t.slice(1);

// Per-table transforms for columns whose type changed in the D1 schema.
const arrToJson = (v) => JSON.stringify(Array.isArray(v) ? v : []);
const jsonToStr = (v) => (v === null || v === undefined ? null : JSON.stringify(v));

const TRANSFORMS = {
  UserProgress:   (r) => ({ ...r, completedChapters: arrToJson(r.completedChapters) }),
  FamilyMember:   (r) => ({ ...r, faithGoals: arrToJson(r.faithGoals) }),
  MemberProgress: (r) => ({ ...r, completedChapters: arrToJson(r.completedChapters) }),
  AnalyticsEvent: (r) => ({ ...r, props: jsonToStr(r.props) }),
  AdminAuditLog:  (r) => ({ ...r, details: jsonToStr(r.details) }),
};

async function main() {
  const pool = new pg.Pool({ connectionString: neonUrl });
  const adapter = new PrismaD1Http({ CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_DATABASE_ID, CLOUDFLARE_D1_TOKEN });
  const prisma = new PrismaClient({ adapter });

  try {
    if (WIPE) {
      console.log('Wiping D1 tables (reverse FK order)…');
      for (const t of [...ORDER].reverse()) {
        const n = await prisma[delegate(t)].deleteMany({});
        console.log(`  cleared ${t}: ${n.count}`);
      }
    }

    const summary = [];
    for (const table of ORDER) {
      const { rows } = await pool.query(`SELECT * FROM "${table}"`);
      const xform = TRANSFORMS[table];
      let written = 0;
      for (const raw of rows) {
        const data = xform ? xform(raw) : raw;
        try {
          await prisma[delegate(table)].create({ data });
          written++;
        } catch (e) {
          console.error(`  ! ${table} id=${raw.id ?? '?'}: ${String(e.message).split('\n')[0]}`);
        }
      }
      summary.push({ table, source: rows.length, written });
      console.log(`${table.padEnd(22)} source=${rows.length}  written=${written}`);
    }

    console.log('\n=== Parity check ===');
    let ok = true;
    for (const { table, source } of summary) {
      const d1count = await prisma[delegate(table)].count();
      const match = d1count === source;
      if (!match) ok = false;
      console.log(`${table.padEnd(22)} neon=${source}  d1=${d1count}  ${match ? 'OK' : 'MISMATCH'}`);
    }
    console.log(ok ? '\nAll tables match ✅' : '\nParity MISMATCH ❌');
    process.exitCode = ok ? 0 : 2;
  } finally {
    await pool.end();
    await prisma.$disconnect();
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
