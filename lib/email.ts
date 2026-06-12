const ZEPTOMAIL_URL = 'https://api.zeptomail.com/v1.1/email';

interface Recipient {
  email: string;
  name?: string;
}

interface SendEmailOptions {
  to: Recipient[];
  subject: string;
  htmlBody: string;
  textBody?: string;
}

export async function sendEmail({ to, subject, htmlBody, textBody }: SendEmailOptions) {
  const token = process.env.ZEPTOMAIL_TOKEN;
  if (!token || token === 'REPLACE_ME') return;

  const body = {
    from: {
      address: process.env.ZEPTOMAIL_FROM_EMAIL ?? 'noreply@littlebible.org',
      name:    process.env.ZEPTOMAIL_FROM_NAME  ?? 'Little Bible',
    },
    to: to.map(r => ({ email_address: { address: r.email, name: r.name ?? '' } })),
    subject,
    htmlbody: htmlBody,
    textbody: textBody ?? subject,
  };

  try {
    await fetch(ZEPTOMAIL_URL, {
      method:  'POST',
      headers: {
        'Authorization': `Zoho-enczapikey ${token}`,
        'Content-Type':  'application/json',
        'Accept':        'application/json',
      },
      body: JSON.stringify(body),
    });
  } catch {
    // email is non-critical — swallow errors
  }
}

export function welcomeEmailHtml(name: string): string {
  const displayName = name || 'Friend';
  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:40px 16px;background:#FFFBF5;font-family:Georgia,serif;">
  <div style="max-width:520px;margin:0 auto;background:#fff;border-radius:24px;padding:40px 36px;border:1px solid #FDE68A;">

    <div style="text-align:center;margin-bottom:32px;">
      <div style="font-size:56px;margin-bottom:12px;">🌱</div>
      <h1 style="margin:0 0 6px;font-size:26px;color:#92400E;font-weight:bold;">Welcome to Little Bible!</h1>
      <p style="margin:0;color:#A8A29E;font-size:15px;">God's Word for Little Hearts</p>
    </div>

    <p style="color:#44403C;font-size:16px;line-height:1.75;margin:0 0 16px;">Hi ${displayName},</p>
    <p style="color:#44403C;font-size:16px;line-height:1.75;margin:0 0 16px;">
      We're so glad your family is here. Little Bible is built for one purpose —
      to help your children know, love, and remember God's Word from their earliest years.
    </p>

    <div style="background:#FEF3C7;border-radius:16px;padding:20px 24px;margin:24px 0;border:1px solid #FDE68A;">
      <p style="color:#92400E;font-weight:bold;margin:0 0 8px;font-size:13px;text-transform:uppercase;letter-spacing:0.08em;">Start Here</p>
      <p style="color:#78350F;font-size:15px;margin:0;line-height:1.7;">
        Open Proverbs and begin your first family devotion.
        It only takes 5 minutes — and Lumi grows a little every time you do. 🌿
      </p>
    </div>

    <div style="text-align:center;margin:32px 0;">
      <a href="https://littlebible.org/proverbs/1"
         style="display:inline-block;background:#F59E0B;color:#451A03;font-weight:bold;font-size:16px;padding:14px 36px;border-radius:16px;text-decoration:none;">
        Start Bible Time →
      </a>
    </div>

    <hr style="border:none;border-top:1px solid #F5F5F4;margin:32px 0;">
    <p style="color:#A8A29E;font-size:13px;text-align:center;margin:0;line-height:1.7;">
      Free · Open source · Faithful to Scripture<br>
      <a href="https://littlebible.org" style="color:#D97706;text-decoration:none;">littlebible.org</a>
    </p>
  </div>
</body>
</html>`;
}
