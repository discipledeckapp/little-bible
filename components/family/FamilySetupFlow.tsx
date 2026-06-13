'use client';

import { useState } from 'react';
import { AVATARS, FAITH_GOALS } from '@/types/family';
import { createFamily, addMember } from '@/lib/family-client';
import { useFamily } from './FamilyContext';

type SetupStep = 'name' | 'child' | 'more' | 'goals' | 'ready';

interface DraftChild {
  name: string;
  age: number | null;
  avatarId: string;
  faithGoals: string[];
}

const AGES = [4, 5, 6, 7, 8, 9];

export default function FamilySetupFlow() {
  const { mutate, setShowSetup } = useFamily();

  const [step, setStep]                 = useState<SetupStep>('name');
  const [familyName, setFamilyName]     = useState('');
  const [children, setChildren]         = useState<DraftChild[]>([{ name: '', age: null, avatarId: 'lion', faithGoals: [] }]);
  const [activeChildIdx, setActiveChildIdx] = useState(0);
  const [saving, setSaving]             = useState(false);
  const [error, setError]               = useState('');

  const activeChild = children[activeChildIdx];
  const usedAvatars = children.filter((_, i) => i !== activeChildIdx).map((c) => c.avatarId);

  function updateChild(idx: number, patch: Partial<DraftChild>) {
    setChildren((prev) => prev.map((c, i) => (i === idx ? { ...c, ...patch } : c)));
  }

  function addAnotherChild() {
    const nextAvatars = Object.keys(AVATARS).filter((a) => !children.some((c) => c.avatarId === a));
    setChildren((prev) => [
      ...prev,
      { name: '', age: null, avatarId: nextAvatars[0] ?? 'star', faithGoals: [] },
    ]);
    setActiveChildIdx(children.length);
    setStep('child');
  }

  async function handleFinish() {
    setSaving(true);
    setError('');
    try {
      await createFamily(familyName.trim() || null);
      for (const child of children) {
        if (!child.name.trim()) continue;
        await addMember({
          name: child.name.trim(),
          age: child.age,
          avatarId: child.avatarId,
          faithGoals: child.faithGoals,
        });
      }
      await mutate();
      setShowSetup(false);
    } catch {
      setError('Something went wrong. Please try again.');
      setSaving(false);
    }
  }

  const stepOrder: SetupStep[] = ['name', 'child', 'more', 'goals', 'ready'];
  const stepIdx = stepOrder.indexOf(step);
  const progress = Math.round(((stepIdx + 1) / stepOrder.length) * 100);

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-amber-950/60 backdrop-blur-sm px-4 pb-4 sm:pb-0">
      <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">

        {/* Progress bar */}
        <div className="h-1.5 bg-amber-100">
          <div className="h-1.5 bg-amber-400 transition-all duration-500" style={{ width: `${progress}%` }} />
        </div>

        <div className="px-6 py-7 space-y-6 max-h-[88vh] overflow-y-auto">

          {/* ── STEP 1: Family Name ── */}
          {step === 'name' && (
            <div className="space-y-5">
              <div className="text-center">
                <div className="text-5xl mb-3" aria-hidden="true">📖</div>
                <h2 className="font-display text-2xl font-bold text-stone-800">Welcome to Little Bible</h2>
                <p className="text-stone-500 text-sm mt-1.5">
                  Let's set up your family's Bible. It takes 2 minutes.
                </p>
              </div>

              <div>
                <label className="block text-sm font-bold text-stone-600 mb-1.5" htmlFor="family-name">
                  Your family name <span className="text-stone-400 font-normal">(optional)</span>
                </label>
                <input
                  id="family-name"
                  type="text"
                  placeholder="e.g. The Johnson Family"
                  value={familyName}
                  onChange={(e) => setFamilyName(e.target.value)}
                  maxLength={50}
                  className="w-full border-2 border-stone-200 focus:border-amber-400 rounded-2xl px-4 py-3.5 text-base font-semibold text-stone-800 focus:outline-none transition-colors placeholder:font-normal placeholder:text-stone-300"
                />
                <p className="text-stone-400 text-xs mt-1.5 ml-1">
                  Shown on your family dashboard — you can always change it later.
                </p>
              </div>

              <button
                onClick={() => setStep('child')}
                className="w-full bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                Continue →
              </button>
            </div>
          )}

          {/* ── STEP 2: Add Child ── */}
          {step === 'child' && (
            <div className="space-y-5">
              <div>
                <p className="text-amber-500 text-xs font-extrabold uppercase tracking-widest mb-1">
                  {activeChildIdx === 0 ? 'First child' : `Child ${activeChildIdx + 1}`}
                </p>
                <h2 className="font-display text-xl font-bold text-stone-800">Who will be reading?</h2>
              </div>

              {/* Avatar grid */}
              <div>
                <p className="text-xs font-bold text-stone-500 mb-2">Choose an avatar</p>
                <div className="grid grid-cols-6 gap-2">
                  {Object.entries(AVATARS).map(([id, avatar]) => {
                    const taken = usedAvatars.includes(id);
                    return (
                      <button
                        key={id}
                        onClick={() => !taken && updateChild(activeChildIdx, { avatarId: id })}
                        disabled={taken}
                        aria-label={avatar.label}
                        className={`aspect-square rounded-2xl text-2xl flex items-center justify-center transition-all border-2 ${
                          activeChild.avatarId === id
                            ? 'border-amber-400 bg-amber-50 ring-2 ring-amber-200 scale-105'
                            : taken
                            ? 'border-stone-100 bg-stone-50 opacity-30 cursor-not-allowed'
                            : 'border-stone-200 bg-stone-50 hover:border-amber-300 hover:bg-amber-50'
                        }`}
                      >
                        {avatar.emoji}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Name */}
              <div>
                <label className="block text-xs font-bold text-stone-500 mb-1.5" htmlFor="child-name">
                  Name
                </label>
                <input
                  id="child-name"
                  type="text"
                  placeholder="e.g. Sarah"
                  value={activeChild.name}
                  onChange={(e) => updateChild(activeChildIdx, { name: e.target.value })}
                  maxLength={30}
                  autoFocus
                  className="w-full border-2 border-stone-200 focus:border-amber-400 rounded-2xl px-4 py-3 text-base font-semibold text-stone-800 focus:outline-none transition-colors placeholder:font-normal placeholder:text-stone-300"
                />
              </div>

              {/* Age */}
              <div>
                <p className="text-xs font-bold text-stone-500 mb-1.5">Age</p>
                <div className="flex gap-2 flex-wrap">
                  {AGES.map((a) => (
                    <button
                      key={a}
                      onClick={() => updateChild(activeChildIdx, { age: activeChild.age === a ? null : a })}
                      className={`px-4 py-2 rounded-xl text-sm font-extrabold border-2 transition-all ${
                        activeChild.age === a
                          ? 'border-amber-400 bg-amber-100 text-amber-800'
                          : 'border-stone-200 text-stone-500 hover:border-amber-200'
                      }`}
                    >
                      {a}
                    </button>
                  ))}
                  <button
                    onClick={() => updateChild(activeChildIdx, { age: activeChild.age === 10 ? null : 10 })}
                    className={`px-4 py-2 rounded-xl text-sm font-extrabold border-2 transition-all ${
                      activeChild.age === 10
                        ? 'border-amber-400 bg-amber-100 text-amber-800'
                        : 'border-stone-200 text-stone-500 hover:border-amber-200'
                    }`}
                  >
                    9+
                  </button>
                </div>
              </div>

              <button
                onClick={() => {
                  if (!activeChild.name.trim()) { setError('Please enter a name.'); return; }
                  setError('');
                  setStep('more');
                }}
                className="w-full bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                Continue →
              </button>
              {error && <p className="text-red-500 text-sm text-center">{error}</p>}
            </div>
          )}

          {/* ── STEP 3: More children? ── */}
          {step === 'more' && (
            <div className="space-y-5">
              <div className="text-center">
                <h2 className="font-display text-xl font-bold text-stone-800">
                  {activeChildIdx === 0
                    ? `${children[0].name} is in! 🎉`
                    : 'Anyone else?'}
                </h2>
                <p className="text-stone-500 text-sm mt-1.5">
                  You can always add more children later.
                </p>
              </div>

              {/* Summary of children added */}
              <div className="space-y-2">
                {children.map((c, i) => (
                  <div key={i} className="flex items-center gap-3 bg-amber-50 rounded-2xl px-4 py-3 border border-amber-100">
                    <span className="text-2xl" aria-hidden="true">{AVATARS[c.avatarId]?.emoji ?? '📖'}</span>
                    <div>
                      <p className="font-bold text-stone-800 text-sm">{c.name}</p>
                      {c.age && <p className="text-stone-400 text-xs">Age {c.age}</p>}
                    </div>
                  </div>
                ))}
              </div>

              {children.length < 4 && (
                <button
                  onClick={addAnotherChild}
                  className="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl border-2 border-dashed border-amber-200 text-amber-600 hover:bg-amber-50 font-bold text-sm transition-colors"
                >
                  + Add another child
                </button>
              )}

              <button
                onClick={() => setStep('goals')}
                className="w-full bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                Continue →
              </button>
            </div>
          )}

          {/* ── STEP 4: Faith Goals ── */}
          {step === 'goals' && (
            <div className="space-y-5">
              <div>
                <p className="text-amber-500 text-xs font-extrabold uppercase tracking-widest mb-1">Optional</p>
                <h2 className="font-display text-xl font-bold text-stone-800">
                  What do you hope for {children[0].name}?
                </h2>
                <p className="text-stone-400 text-sm mt-1">
                  Helps us suggest the right chapters. You can always change these.
                </p>
              </div>

              <div className="grid grid-cols-2 gap-2">
                {FAITH_GOALS.map((g) => {
                  const selected = activeChild.faithGoals.includes(g.id);
                  return (
                    <button
                      key={g.id}
                      onClick={() => {
                        const goals = selected
                          ? activeChild.faithGoals.filter((id) => id !== g.id)
                          : [...activeChild.faithGoals, g.id];
                        updateChild(activeChildIdx, { faithGoals: goals });
                      }}
                      className={`flex items-center gap-2.5 px-4 py-3 rounded-2xl border-2 text-left text-sm font-bold transition-all ${
                        selected
                          ? 'border-amber-400 bg-amber-50 text-amber-800'
                          : 'border-stone-200 text-stone-600 hover:border-amber-200 hover:bg-amber-50/50'
                      }`}
                    >
                      <span className="text-base shrink-0" aria-hidden="true">{g.emoji}</span>
                      {g.label}
                      {selected && <span className="ml-auto text-amber-500 text-xs">✓</span>}
                    </button>
                  );
                })}
              </div>

              <button
                onClick={() => setStep('ready')}
                className="w-full bg-amber-500 hover:bg-amber-600 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                {activeChild.faithGoals.length === 0 ? 'Skip →' : 'Save Goals →'}
              </button>
            </div>
          )}

          {/* ── STEP 5: Ready ── */}
          {step === 'ready' && (
            <div className="space-y-6 text-center">
              <div>
                <div className="text-6xl mb-3" aria-hidden="true">🌳</div>
                <h2 className="font-display text-2xl font-bold text-stone-800">
                  {familyName.trim() ? `${familyName.trim()}'s Bible is ready!` : 'Your Family Bible is ready!'}
                </h2>
                <p className="text-stone-500 text-sm mt-2 leading-relaxed">
                  All 66 books of God's Word, faithfully adapted for your {children.length === 1 ? 'child' : 'children'}.
                </p>
              </div>

              <div className="space-y-2 text-left">
                {children.filter((c) => c.name.trim()).map((c, i) => (
                  <div key={i} className="flex items-center gap-3 bg-stone-50 rounded-2xl px-4 py-3">
                    <span className="text-2xl">{AVATARS[c.avatarId]?.emoji}</span>
                    <div>
                      <p className="font-bold text-stone-800 text-sm">{c.name}</p>
                      <p className="text-stone-400 text-xs">
                        {c.age ? `Age ${c.age}` : 'Ready to read'}
                      </p>
                    </div>
                    <span className="ml-auto text-amber-500 text-sm font-bold">🌱 0 seeds</span>
                  </div>
                ))}
              </div>

              {error && <p className="text-red-500 text-sm">{error}</p>}

              <button
                onClick={handleFinish}
                disabled={saving}
                className="w-full bg-amber-500 hover:bg-amber-600 disabled:opacity-60 text-white font-extrabold text-base py-4 rounded-2xl transition-all active:scale-95 shadow-sm"
              >
                {saving ? 'Setting up...' : 'Start Reading Together →'}
              </button>
            </div>
          )}

        </div>

        {/* Step dots */}
        <div className="flex justify-center gap-2 pb-5" aria-hidden="true">
          {stepOrder.map((s) => (
            <div key={s} className={`rounded-full transition-all ${s === step ? 'w-6 h-2 bg-amber-500' : 'w-2 h-2 bg-stone-200'}`} />
          ))}
        </div>

      </div>
    </div>
  );
}
