ALTER TABLE "User" ADD COLUMN "wantsEmailDigest" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ADD COLUMN "wantsNotifications" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ADD COLUMN "cloudSyncEnabled" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "User" ADD COLUMN "consentedAt" DATETIME;

CREATE TABLE "MobileProgress" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "profileId" TEXT NOT NULL,
  "operation" TEXT NOT NULL,
  "payload" TEXT NOT NULL,
  "clientId" TEXT NOT NULL,
  "createdAt" DATETIME NOT NULL,
  "receivedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "MobileProgress_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "MobileEntitlement" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "productId" TEXT NOT NULL,
  "platform" TEXT NOT NULL,
  "transactionId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'active',
  "verifiedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "revokedAt" DATETIME,
  CONSTRAINT "MobileEntitlement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "MobileProgress_userId_clientId_key" ON "MobileProgress"("userId", "clientId");
CREATE INDEX "MobileProgress_userId_profileId_receivedAt_idx" ON "MobileProgress"("userId", "profileId", "receivedAt");
CREATE UNIQUE INDEX "MobileEntitlement_transactionId_key" ON "MobileEntitlement"("transactionId");
CREATE UNIQUE INDEX "MobileEntitlement_userId_productId_key" ON "MobileEntitlement"("userId", "productId");
CREATE INDEX "MobileEntitlement_userId_status_idx" ON "MobileEntitlement"("userId", "status");
