-- Make MobileEntitlement device-scoped instead of user-scoped.
--
-- The mobile app has no login flow, so a purchase almost never has a User to
-- attach to. The old table required userId NOT NULL and carried a
-- UNIQUE(userId, productId), which made it impossible to record a real
-- purchase. The store-signed receipt is what authenticates an unlock, and
-- transactionId is the only idempotency key that can be relied on.
--
-- SQLite cannot relax a NOT NULL column in place, so the table is rebuilt.

PRAGMA foreign_keys=OFF;

CREATE TABLE "new_MobileEntitlement" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT,
  "deviceId" TEXT,
  "productId" TEXT NOT NULL,
  "platform" TEXT NOT NULL,
  "transactionId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'active',
  "verifiedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "revokedAt" DATETIME,
  CONSTRAINT "MobileEntitlement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO "new_MobileEntitlement"
  ("id", "userId", "productId", "platform", "transactionId", "status", "verifiedAt", "revokedAt")
SELECT
  "id", "userId", "productId", "platform", "transactionId", "status", "verifiedAt", "revokedAt"
FROM "MobileEntitlement";

-- Dropping the old table also drops MobileEntitlement_userId_productId_key.
DROP TABLE "MobileEntitlement";
ALTER TABLE "new_MobileEntitlement" RENAME TO "MobileEntitlement";

CREATE UNIQUE INDEX "MobileEntitlement_transactionId_key" ON "MobileEntitlement"("transactionId");
CREATE INDEX "MobileEntitlement_userId_status_idx" ON "MobileEntitlement"("userId", "status");
CREATE INDEX "MobileEntitlement_deviceId_idx" ON "MobileEntitlement"("deviceId");

PRAGMA foreign_keys=ON;
