import { Env } from './types';
import { handleAuth } from './routes/auth';
import { handleProgress } from './routes/progress';
import { handleManifest } from './routes/manifest';
import { handleUnlock } from './routes/unlock';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS for mobile clients
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      });
    }

    try {
      if (path === '/api/mobile/auth' && request.method === 'POST') return handleAuth(request, env);
      if (path === '/api/mobile/progress' && request.method === 'POST') return handleProgress(request, env);
      if (path === '/api/mobile/manifest' && request.method === 'GET') return handleManifest(request, env);
      if (path === '/api/mobile/unlock' && request.method === 'POST') return handleUnlock(request, env);

      return new Response('Not found', { status: 404 });
    } catch (err) {
      console.error('Worker error:', err);
      return new Response('Internal error', { status: 500 });
    }
  },
};
