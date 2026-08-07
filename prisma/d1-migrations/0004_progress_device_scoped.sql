-- Make MobileProgress device-scoped as well as user-scoped.
--
-- Companion to 0003. `/api/mobile/progress` now accepts two auth schemes: a
-- session cookie (userId) or a device-token Bearer (deviceId). Rows arriving by
-- the second route have no user, so userId must be nullable and deviceId must
-- exist with its own uniqueness and lookup indexes.
--
-- SQLite cannot relax a NOT NULL column in place, so the table is rebuilt.

PRAGMA foreign_keys=OFF;

CREATE TABLE "new_MobileProgress" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT,
  "deviceId" TEXT,
  "profileId" TEXT NOT NULL,
  "operation" TEXT NOT NULL,
  "payload" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "createdAt" DATETIME NOT NULL,
  "receivedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "MobileProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO "new_MobileProgress"
  ("id", "userId", "profileId", "operation", "payload", "clientId", "createdAt", "receivedAt")
SELECT
  "id", "userId", "profileId", "operation", "payload", "clientId", "createdAt", "receivedAt"
FROM "MobileProgress";

DROP TABLE "MobileProgress";
ALTER TABLE "new_MobileProgress" RENAME TO "MobileProgress";

CREATE UNIQUE INDEX "MobileProgress_userId_clientId_key" ON "MobileProgress"("userId", "clientId");
CREATE UNIQUE INDEX "MobileProgress_deviceId_clientId_key" ON "MobileProgress"("deviceId", "clientId");
CREATE INDEX "MobileProgress_userId_profileId_receivedAt_idx" ON "MobileProgress"("userId", "profileId", "receivedAt");
CREATE INDEX "MobileProgress_deviceId_profileId_receivedAt_idx" ON "MobileProgress"("deviceId", "profileId", "receivedAt");

PRAGMA foreign_keys=ON;
