import type { Metadata } from 'next';
import Link from 'next/link';
import Header from '@/components/layout/Header';
import Footer from '@/components/layout/Footer';

// ─────────────────────────────────────────────────────────────────────────────
// VERIFY BEFORE PUBLISHING
//
// These three values are legally operative. GDPR Art. 13 requires an
// identifiable controller and a working contact route; COPPA requires operator
// contact details. Confirm the mailbox actually receives mail and that the
// controller name matches the entity that will answer a regulator.
// ─────────────────────────────────────────────────────────────────────────────
const CONTACT_EMAIL = 'littlebible.org@gmail.com';
const CONTROLLER = 'Little Bible';
const EFFECTIVE_DATE = '3 August 2026';

export const metadata: Metadata = {
  title: 'Privacy Policy — Little Bible',
  description:
    "How Little Bible handles your family's information. The app keeps everything on your device. The website collects only what an account needs. We never sell data, never show ads, and never track children.",
  alternates: { canonical: 'https://littlebible.org/privacy' },
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen flex flex-col bg-[var(--color-background)]">
      <Header />

      {/* ── Hero ── */}
      <section className="hero-bg py-14 px-4 text-center">
        <div className="max-w-3xl mx-auto">
          <h1
            className="text-4xl sm:text-5xl font-bold text-white mb-4 leading-tight"
            style={{ fontFamily: 'var(--font-display)' }}
          >
            Privacy Policy
          </h1>
          <p className="text-amber-100/90 text-lg">
            Little Bible is made for children aged 4–7. We treat their
            information the way we would want ours treated.
          </p>
          <p className="text-amber-200/70 text-sm mt-4">
            Effective {EFFECTIVE_DATE}
          </p>
        </div>
      </section>

      <main className="flex-1 px-4 py-12">
        <div className="max-w-3xl mx-auto">
          {/* ── The short version ── */}
          <section className="bg-amber-50 border border-amber-200 rounded-2xl p-6 sm:p-8 mb-12">
            <h2
              className="text-2xl font-bold text-amber-950 mb-4"
              style={{ fontFamily: 'var(--font-display)' }}
            >
              The short version
            </h2>
            <ul className="space-y-3 text-stone-700 leading-relaxed">
              <li>
                <strong className="text-amber-950">
                  The Little Bible app keeps everything on your device.
                </strong>{' '}
                Your child&rsquo;s nickname, progress, verses and drawings never
                leave the phone or tablet. The app makes no network requests at
                all.
              </li>
              <li>
                <strong className="text-amber-950">
                  The website collects only what an account needs.
                </strong>{' '}
                If you sign in at littlebible.org, we store your name and email
                and whatever you choose to add — such as a child&rsquo;s first
                name and age for a family profile.
              </li>
              <li>
                <strong className="text-amber-950">
                  We never sell or share your data for advertising.
                </strong>{' '}
                There are no ads, no advertising identifiers, no third-party
                analytics or tracking scripts, and no profiling of children.
              </li>
              <li>
                <strong className="text-amber-950">
                  Children never give us anything directly.
                </strong>{' '}
                Every field is entered by a parent, and any parent can ask us to
                delete it all.
              </li>
            </ul>
          </section>

          <Prose>
            <H2>Who we are</H2>
            <P>
              {CONTROLLER} publishes littlebible.org and the Little Bible mobile
              app. We are the data controller for the information described
              below. You can reach us at{' '}
              <a
                href={`mailto:${CONTACT_EMAIL}`}
                className="text-amber-700 underline underline-offset-2 hover:text-amber-900"
              >
                {CONTACT_EMAIL}
              </a>
              .
            </P>
            <P>
              This policy covers two separate things, and they behave very
              differently. Please read the one that applies to you.
            </P>

            {/* ── App ── */}
            <H2>1. The Little Bible mobile app</H2>
            <P>
              <strong>
                The app does not send your information anywhere. It stores
                everything locally on the device and makes no network requests.
              </strong>{' '}
              There is no account, no sign-in, and no server that receives app
              data.
            </P>
            <P>What the app stores on the device:</P>
            <Ul>
              <li>
                A child profile: the nickname you type, an age band, a chosen
                avatar, and whether the introduction has been seen.
              </li>
              <li>
                Progress: stories completed, verses being learned and when they
                are next due for practice, seeds earned, and days active.
              </li>
              <li>
                Settings: a parent PIN for the Parent Hub and a background-music
                preference, held in the device&rsquo;s secure storage.
              </li>
              <li>Any picture your child colours in.</li>
            </Ul>
            <P>
              All of this lives in a database on the device. Deleting the app
              deletes it. We never receive a copy, and we cannot see it.
            </P>
            <P>
              <strong>No analytics, no crash reporting, no advertising.</strong>{' '}
              The app contains no analytics SDK, no crash-reporting SDK, no
              advertising SDK and no social-media SDK. It collects no advertising
              identifier and no device identifier.
            </P>
            <P>
              <strong>Reminders</strong> are scheduled on the device itself. No
              push server is involved and no token is sent to us.
            </P>
            <P>
              <strong>Reading aloud.</strong> Where the app uses your
              device&rsquo;s built-in speech engine, the text of the story or
              verse is passed to that engine. On some Android devices the
              default speech engine is provided by Google and may process text on
              its servers to generate the voice. That is your device&rsquo;s
              speech setting, not something Little Bible sends. You can change
              the engine in your device settings.
            </P>
            <P>
              <strong>Purchases.</strong> If you unlock the full library, the
              purchase is handled entirely by Apple or Google. We never see your
              card details, name or address. The app records only that the
              unlock is active.
            </P>
            <P>
              If we ever add optional cloud backup, it will be off by default,
              will require a parent to turn it on, and we will update this policy
              and tell you before it happens.
            </P>

            {/* ── Website ── */}
            <H2>2. The littlebible.org website</H2>
            <P>
              You can read the entire Bible on the website without an account and
              without signing in. If you choose to create an account, here is
              what we hold.
            </P>

            <H3>Account information</H3>
            <P>
              We offer sign-in with Google. When you use it we receive and store
              your name, email address and profile picture from Google, plus the
              tokens needed to keep you signed in. We set one session cookie so
              you stay signed in between visits. We do not use advertising or
              tracking cookies.
            </P>

            <H3>Family profiles — including information about children</H3>
            <P>
              If you create a family, you may add a child&rsquo;s first name or
              nickname, their age, an avatar and colour, and faith goals. You may
              also save prayers, which are free text and may mention your family.
            </P>
            <P>
              <strong>
                This information is provided by you, the parent — never collected
                from a child directly.
              </strong>{' '}
              Please use a first name or nickname rather than a full name. We ask
              for nothing more than this, and you can delete any profile at any
              time.
            </P>

            <H3>Progress</H3>
            <P>
              We store which chapters and stories have been read, activity
              results, memory-verse progress, seeds, streaks and milestones, so
              that progress is there when you come back.
            </P>

            <H3>Usage measurement</H3>
            <P>
              We record simple product events — for example, that a chapter was
              opened or a story completed — together with the story or chapter
              involved and, if you are signed in, your account id. These records
              contain <strong>no IP address and no browser fingerprint</strong>,
              and we use them only to understand which content helps families. We
              use no third-party analytics service.
            </P>

            <H3>Donations</H3>
            <P>
              Donations are processed by Stripe or Paystack. They receive your
              payment details directly; we never see or store card numbers. We
              keep only the amount, the currency and the status, so we can
              account for the gift.
            </P>

            <H3>App notifications list</H3>
            <P>
              If you ask to be told when the app launches, we store your
              preference, your country and whether you want email or push.
            </P>

            <H2>Children&rsquo;s privacy</H2>
            <P>
              Little Bible is intended for children, and we build to that
              standard rather than the minimum.
            </P>
            <Ul>
              <li>No advertising of any kind, and no advertising identifiers.</li>
              <li>No third-party trackers, analytics services or social plugins.</li>
              <li>No behavioural profiling and no personalised recommendations.</li>
              <li>No public profiles, no social features, no messaging, no user-generated content visible to anyone else.</li>
              <li>No selling, renting or sharing of personal information — ever.</li>
              <li>No location collection, no contacts, no microphone, no camera.</li>
              <li>Purchases and account settings sit behind a parent gate.</li>
            </Ul>
            <P>
              We do not knowingly let a child create an account. Accounts are for
              parents and guardians, and information about a child only ever
              reaches us because a parent typed it in.
            </P>
            <P>
              If you believe a child has given us information without a
              parent&rsquo;s involvement, email{' '}
              <a
                href={`mailto:${CONTACT_EMAIL}`}
                className="text-amber-700 underline underline-offset-2 hover:text-amber-900"
              >
                {CONTACT_EMAIL}
              </a>{' '}
              and we will delete it promptly.
            </P>

            <H2>Why we are allowed to hold this (UK/EU)</H2>
            <Ul>
              <li>
                <strong>Contract</strong> — to give you the account and progress
                tracking you asked for.
              </li>
              <li>
                <strong>Consent</strong> — for the launch notification list,
                which you can withdraw at any time.
              </li>
              <li>
                <strong>Legitimate interests</strong> — to keep the service
                secure and to understand, in aggregate, which content helps
                families.
              </li>
              <li>
                <strong>Legal obligation</strong> — to keep donation records.
              </li>
            </Ul>

            <H2>Who else is involved</H2>
            <P>
              We use a small number of providers, and only to run the service:
            </P>
            <Ul>
              <li>
                <strong>Cloudflare</strong> — hosting, database and content
                delivery.
              </li>
              <li>
                <strong>Google</strong> — sign-in, if you choose it.
              </li>
              <li>
                <strong>Stripe</strong> and <strong>Paystack</strong> — donation
                processing.
              </li>
              <li>
                <strong>Apple</strong> and <strong>Google Play</strong> — app
                purchases, handled entirely by them.
              </li>
            </Ul>
            <P>
              None of them may use your information for their own advertising. We
              may also disclose information if the law genuinely requires it.
            </P>

            <H2>Where your information is held</H2>
            <P>
              Our infrastructure is provided by Cloudflare and may store and
              process data in countries outside your own, including the United
              States. Where required, transfers rely on Standard Contractual
              Clauses or an equivalent safeguard.
            </P>

            <H2>How long we keep it</H2>
            <Ul>
              <li>Account and family information: until you delete it or ask us to.</li>
              <li>Progress: for as long as the account exists.</li>
              <li>Usage events: up to 24 months, then deleted.</li>
              <li>Donation records: as long as financial law requires.</li>
              <li>App data: on your device only, until you delete the app.</li>
            </Ul>

            <H2>Your rights</H2>
            <P>
              You can ask us to show you what we hold, correct it, delete it, give
              you a copy to take elsewhere, or stop a particular use. Parents may
              exercise these rights on behalf of their children. Email{' '}
              <a
                href={`mailto:${CONTACT_EMAIL}`}
                className="text-amber-700 underline underline-offset-2 hover:text-amber-900"
              >
                {CONTACT_EMAIL}
              </a>{' '}
              and we will reply within 30 days. There is no charge.
            </P>
            <P>
              If you are in the UK or EU and are unhappy with our response, you
              may complain to your data protection authority — in the UK, the
              Information Commissioner&rsquo;s Office.
            </P>

            <H2>Security</H2>
            <P>
              Traffic is encrypted in transit. The parent PIN is held in your
              device&rsquo;s secure keystore. Access to production data is limited
              to those who need it. No system is perfect, and we will tell
              affected users and the relevant authority promptly if a breach ever
              puts personal data at risk.
            </P>

            <H2>Changes to this policy</H2>
            <P>
              If we change how we handle information — particularly if the app
              ever begins sending data off the device — we will update the date
              at the top and, for anything significant, tell account holders
              directly. We will not apply a material change retroactively without
              telling you.
            </P>

            <H2>Contact</H2>
            <P>
              Questions, requests or concerns:{' '}
              <a
                href={`mailto:${CONTACT_EMAIL}`}
                className="text-amber-700 underline underline-offset-2 hover:text-amber-900"
              >
                {CONTACT_EMAIL}
              </a>
              . We read every message.
            </P>
          </Prose>

          <div className="mt-12 pt-8 border-t border-amber-200 text-center">
            <Link
              href="/"
              className="text-amber-700 hover:text-amber-900 font-semibold"
            >
              ← Back to Little Bible
            </Link>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}

// ─── Small typographic helpers ───────────────────────────────────────────────

function Prose({ children }: { children: React.ReactNode }) {
  return <div className="space-y-1">{children}</div>;
}

function H2({ children }: { children: React.ReactNode }) {
  return (
    <h2
      className="text-2xl font-bold text-amber-950 mt-10 mb-3"
      style={{ fontFamily: 'var(--font-display)' }}
    >
      {children}
    </h2>
  );
}

function H3({ children }: { children: React.ReactNode }) {
  return (
    <h3 className="text-lg font-bold text-amber-900 mt-6 mb-2">{children}</h3>
  );
}

function P({ children }: { children: React.ReactNode }) {
  return <p className="text-stone-700 leading-relaxed mb-4">{children}</p>;
}

function Ul({ children }: { children: React.ReactNode }) {
  return (
    <ul className="list-disc pl-6 space-y-2 text-stone-700 leading-relaxed mb-4">
      {children}
    </ul>
  );
}
