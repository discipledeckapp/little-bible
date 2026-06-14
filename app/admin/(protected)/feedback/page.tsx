import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'Feedback' };

export default function FeedbackPage() {
  return (
    <div className="p-8 max-w-6xl mx-auto w-full">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-stone-900">Feedback</h1>
        <p className="text-stone-500 text-sm mt-0.5">User feedback, bug reports, and feature requests</p>
      </div>

      <div className="bg-white rounded-2xl border border-stone-200 p-12 text-center">
        <p className="text-4xl mb-4">◷</p>
        <p className="text-stone-700 font-semibold text-lg mb-2">Feedback Collection Coming Soon</p>
        <p className="text-stone-400 text-sm max-w-sm mx-auto leading-relaxed">
          Add a feedback widget to the public app that submits to{' '}
          <code className="bg-stone-100 px-1.5 py-0.5 rounded text-xs font-mono">/api/feedback</code>{' '}
          and it will appear here.
        </p>
        <div className="mt-8 bg-stone-50 rounded-xl p-4 text-left max-w-md mx-auto">
          <p className="text-xs font-bold text-stone-500 uppercase tracking-widest mb-3">Planned event types</p>
          <div className="space-y-2">
            {['Bug report', 'Content concern', 'Feature request', 'General feedback'].map(t => (
              <div key={t} className="flex items-center gap-2 text-sm text-stone-600">
                <span className="w-2 h-2 rounded-full bg-stone-300 shrink-0" />
                {t}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
