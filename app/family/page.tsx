'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useSession, signIn } from 'next-auth/react';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';
import ChildProfileCard from '@/components/family/ChildProfileCard';
import FamilyTreeVisual from '@/components/family/FamilyTreeVisual';
import FamilySetupFlow from '@/components/family/FamilySetupFlow';
import { useFamily } from '@/components/family/FamilyContext';
import { AVATARS, FAITH_GOALS } from '@/types/family';
import { deleteMember, addMember, updateFamily } from '@/lib/family-client';

export default function FamilyPage() {
  const { status } = useSession();
  const { family, totalSeeds, loading, mutate, showSetup, setShowSetup } = useFamily();
  const router = useRouter();

  const [editingName, setEditingName]   = useState(false);
  const [nameInput, setNameInput]       = useState('');
  const [addingChild, setAddingChild]   = useState(false);
  const [newChild, setNewChild]         = useState({ name: '', age: '' as string | number, avatarId: 'lion' });
  const [savingName, setSavingName]     = useState(false);
  const [savingChild, setSavingChild]   = useState(false);
  const [deletingId, setDeletingId]     = useState<string | null>(null);

  if (status === 'loading' || loading) {
    return (
      <div className="min-h-screen flex flex-col">
        <Header />
        <div className="flex-1 flex items-center justify-center">
          <div className="w-8 h-8 border-4 border-amber-200 border-t-amber-500 rounded-full animate-spin" />
        </div>
      </div>
    );
  }

  if (status === 'unauthenticated') {
    return (
      <div className="min-h-screen flex flex-col bg-[#FFFBF5]">
        <Header />
        <main className="flex-1 max-w-md mx-auto w-full px-4 py-16 text-center space-y-6">
          <div className="text-6xl mb-4">📖</div>
          <h1 className="font-display text-2xl font-bold text-stone-800">
            Create your Family Bible
          </h1>
          <p className="text-stone-500 leading-relaxed">
            Sign in to set up profiles for your children, track reading progress, and grow your family tree.
          </p>
          <button
            onClick={() => signIn('google', { callbackUrl: '/family' })}
            className="w-full flex items-center justify-center gap-3 bg-white hover:bg-stone-50 text-stone-700 font-bold py-4 rounded-2xl border-2 border-stone-200 shadow-sm transition-all active:scale-95"
          >
            <GoogleIcon />
            Sign in with Google
          </button>
        </main>
        <Footer />
      </div>
    );
  }

  if (showSetup) return <FamilySetupFlow />;
  if (!family) return null;

  async function handleSaveName() {
    setSavingName(true);
    await updateFamily({ name: nameInput.trim() || null });
    await mutate();
    setSavingName(false);
    setEditingName(false);
  }

  async function handleAddChild() {
    if (!newChild.name.trim()) return;
    setSavingChild(true);
    await addMember({
      name: newChild.name.trim(),
      age: newChild.age ? parseInt(String(newChild.age)) : null,
      avatarId: newChild.avatarId,
    });
    await mutate();
    setSavingChild(false);
    setAddingChild(false);
    setNewChild({ name: '', age: '', avatarId: 'lion' });
  }

  async function handleDeleteMember(id: string) {
    setDeletingId(id);
    await deleteMember(id);
    await mutate();
    setDeletingId(null);
  }

  return (
    <div className="min-h-screen flex flex-col bg-[#FFFBF5]">
      <Header />

      <main className="flex-1 max-w-2xl mx-auto w-full px-4 py-8 space-y-8">

        {/* Back */}
        <Link href="/" className="inline-flex items-center gap-1.5 text-sm text-amber-600 hover:text-amber-800 font-semibold transition-colors">
          ← Home
        </Link>

        {/* Family name */}
        <section className="bg-white rounded-3xl border border-stone-100 shadow-sm overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-100 flex items-center justify-between">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Family</h2>
            <button
              onClick={() => { setNameInput(family.name ?? ''); setEditingName(true); }}
              className="text-amber-600 text-sm font-bold hover:text-amber-800"
            >
              {editingName ? '' : 'Edit'}
            </button>
          </div>

          <div className="px-6 py-5">
            {editingName ? (
              <div className="flex gap-2">
                <input
                  autoFocus
                  type="text"
                  value={nameInput}
                  onChange={(e) => setNameInput(e.target.value)}
                  placeholder="e.g. The Johnson Family"
                  maxLength={50}
                  className="flex-1 border-2 border-stone-200 focus:border-amber-400 rounded-2xl px-4 py-2.5 text-sm font-bold text-stone-800 focus:outline-none"
                />
                <button
                  onClick={handleSaveName}
                  disabled={savingName}
                  className="bg-amber-500 text-white font-bold px-4 py-2.5 rounded-2xl text-sm disabled:opacity-60 hover:bg-amber-600 transition-colors"
                >
                  Save
                </button>
                <button onClick={() => setEditingName(false)} className="text-stone-400 px-2 font-bold">✕</button>
              </div>
            ) : (
              <p className="font-extrabold text-stone-800 text-xl">
                {family.name ?? <span className="text-stone-400 font-normal italic">No family name set</span>}
              </p>
            )}
          </div>
        </section>

        {/* Children */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest">Children</h2>
            {family.members.length < 6 && (
              <button
                onClick={() => setAddingChild(true)}
                className="text-sm font-bold text-amber-600 hover:text-amber-800 bg-amber-50 hover:bg-amber-100 border border-amber-200 rounded-xl px-3 py-1.5 transition-colors"
              >
                + Add child
              </button>
            )}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
            {family.members.map((m) => (
              <div key={m.id} className="relative">
                <ChildProfileCard member={m} />
                <button
                  onClick={() => handleDeleteMember(m.id)}
                  disabled={deletingId === m.id}
                  className="absolute top-3 left-3 text-stone-300 hover:text-red-400 text-xs font-bold transition-colors p-1 rounded-lg hover:bg-red-50"
                  aria-label={`Remove ${m.name}`}
                >
                  {deletingId === m.id ? '...' : '✕'}
                </button>
              </div>
            ))}
          </div>

          {/* Add child form */}
          {addingChild && (
            <div className="bg-white rounded-3xl border-2 border-amber-200 p-5 space-y-4">
              <h3 className="font-bold text-stone-700">Add a child</h3>

              <div className="grid grid-cols-6 gap-2">
                {Object.entries(AVATARS).map(([id, av]) => (
                  <button
                    key={id}
                    onClick={() => setNewChild((c) => ({ ...c, avatarId: id }))}
                    className={`aspect-square rounded-2xl text-2xl flex items-center justify-center border-2 transition-all ${
                      newChild.avatarId === id ? 'border-amber-400 bg-amber-50' : 'border-stone-200 hover:border-amber-200'
                    }`}
                    aria-label={av.label}
                  >
                    {av.emoji}
                  </button>
                ))}
              </div>

              <input
                type="text"
                placeholder="Name"
                value={newChild.name}
                onChange={(e) => setNewChild((c) => ({ ...c, name: e.target.value }))}
                maxLength={30}
                autoFocus
                className="w-full border-2 border-stone-200 focus:border-amber-400 rounded-2xl px-4 py-3 text-sm font-semibold focus:outline-none"
              />

              <div className="flex gap-2 flex-wrap">
                {[4,5,6,7,8,9].map((a) => (
                  <button
                    key={a}
                    onClick={() => setNewChild((c) => ({ ...c, age: c.age === a ? '' : a }))}
                    className={`px-3 py-1.5 rounded-xl text-xs font-extrabold border-2 transition-all ${
                      Number(newChild.age) === a ? 'border-amber-400 bg-amber-100 text-amber-800' : 'border-stone-200 text-stone-500'
                    }`}
                  >
                    {a}
                  </button>
                ))}
              </div>

              <div className="flex gap-2">
                <button
                  onClick={handleAddChild}
                  disabled={!newChild.name.trim() || savingChild}
                  className="flex-1 bg-amber-500 disabled:opacity-50 text-white font-bold py-3 rounded-2xl text-sm hover:bg-amber-600 transition-colors"
                >
                  {savingChild ? 'Adding...' : 'Add child'}
                </button>
                <button
                  onClick={() => setAddingChild(false)}
                  className="px-4 py-3 rounded-2xl text-stone-400 font-bold text-sm hover:bg-stone-100 transition-colors"
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
        </section>

        {/* Family Tree */}
        <section>
          <h2 className="font-bold text-stone-700 text-sm uppercase tracking-widest mb-4">Family Tree</h2>
          <FamilyTreeVisual totalSeeds={totalSeeds} members={family.members} />
        </section>

      </main>
      <Footer />
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true">
      <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
      <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
      <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
      <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
    </svg>
  );
}
