/**
 * App store availability and links.
 *
 * Keep every store URL and "is it out yet?" check here — before this existed
 * the "coming soon" state was hard-coded in five separate components, which is
 * why launching on one platform meant hunting through the whole site.
 *
 * When iOS ships, set APP_STORE_URL and everything else follows.
 */

/**
 * Canonical Play Store listing.
 *
 * Deliberately stripped of the `hl` and `ah` parameters that Play adds to
 * shared links: `hl=en-US` forces English on every visitor regardless of their
 * locale, and `ah=` is a per-share signature that does not belong in source.
 */
export const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=org.littlebible.little_bible';

/** Android package name — must match `applicationId` in mobile/android/app/build.gradle.kts. */
export const ANDROID_PACKAGE_ID = 'org.littlebible.little_bible';

/** iOS has not shipped yet. Set this to the App Store URL on launch. */
export const APP_STORE_URL: string | null = null;

export const ANDROID_AVAILABLE = true;
export const IOS_AVAILABLE = APP_STORE_URL !== null;

/** True once the app is downloadable on at least one platform. */
export const APP_AVAILABLE = ANDROID_AVAILABLE || IOS_AVAILABLE;
