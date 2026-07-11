import { defineCloudflareConfig } from "@opennextjs/cloudflare";
import kvIncrementalCache from "@opennextjs/cloudflare/overrides/incremental-cache/kv-incremental-cache";

export default defineCloudflareConfig({
  // Uses the NEXT_INC_CACHE_KV binding for ISR/revalidation.
  // The app is largely SSG; this only matters if revalidate/ISR is added later.
  incrementalCache: kvIncrementalCache,
});
