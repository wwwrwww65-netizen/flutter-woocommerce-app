import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import fetch from 'node-fetch';
import { z } from 'zod';

admin.initializeApp();

const getConfig = () => ({
  openaiKey: functions.config().openai?.key as string,
  rateLimit: Number(functions.config().rate?.limit ?? 50),
  wpBaseUrl: functions.config().wp?.base_url as string,
  wcKey: functions.config().wc?.consumer_key as string,
  wcSecret: functions.config().wc?.consumer_secret as string,
  appleSecret: functions.config().apple?.iap_secret as string,
  googleServiceAccountB64: functions.config().google?.service_account as string,
});

const requireAuth = (context: functions.https.CallableContext) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Auth required');
};

const rateLimiter = async (uid: string, limit: number) => {
  const ref = admin.firestore().collection('rate').doc(uid);
  await admin.firestore().runTransaction(async (tx) => {
    const now = Date.now();
    const doc = await tx.get(ref);
    const hour = 3600_000;
    let count = 0;
    let resetAt = now + hour;
    if (doc.exists) {
      const data = doc.data() as any;
      count = data.count ?? 0;
      resetAt = data.resetAt ?? now + hour;
      if (now > resetAt) {
        count = 0;
        resetAt = now + hour;
      }
    }
    if (count + 1 > limit) throw new functions.https.HttpsError('resource-exhausted', 'Rate limit exceeded');
    tx.set(ref, { count: count + 1, resetAt }, { merge: true });
  });
};

export const apiAiChat = functions.region('us-central1').https.onCall(async (data, context) => {
  // Allow anonymous demo use if no auth, but strongly recommend auth in prod
  if (!context.auth) {
    const cfg = getConfig();
    const Schema = z.object({ message: z.string().min(1) });
    const parsed = Schema.parse(data);
    if (!cfg.openaiKey) return { reply: `رد تجريبي (بدون تسجيل): ${parsed.message}` };
  } else {
    const cfg = getConfig();
    await rateLimiter(context.auth!.uid, cfg.rateLimit);
  }
  const cfg = getConfig();

  const Schema = z.object({
    message: z.string().min(1),
    sendDeviceContext: z.boolean().optional(),
    sendArticleContext: z.boolean().optional(),
    hasImage: z.boolean().optional(),
  });
  const parsed = Schema.parse(data);

  if (!cfg.openaiKey) {
    // Demo fallback if no key configured
    return { reply: `رد تجريبي: ${new Date().toISOString()} — تم استلام رسالتك: "${parsed.message}"` };
  }

  // Minimal completion call (placeholder)
  const prompt = parsed.message;

  const resp = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${cfg.openaiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: 'You are a helpful troubleshooting assistant.' },
        { role: 'user', content: prompt },
      ],
      temperature: 0.2,
    }),
  });
  if (!resp.ok) throw new functions.https.HttpsError('internal', `AI error: ${resp.statusText}`);
  const json: any = await resp.json();
  const reply = json.choices?.[0]?.message?.content ?? '';
  return { reply };
});

export const apiIapValidate = functions.region('us-central1').https.onCall(async (data, context) => {
  requireAuth(context);
  const cfg = getConfig();
  const Schema = z.object({
    platform: z.enum(['google', 'apple']),
    receipt: z.any(),
  });
  const parsed = Schema.parse(data);

  // NOTE: Implement proper validation with respective APIs. Placeholder response below.
  if (parsed.platform === 'apple') {
    if (!cfg.appleSecret) throw new functions.https.HttpsError('failed-precondition', 'Apple secret missing');
    // Validate with App Store (placeholder)
    return { valid: true, productId: 'monthly_premium', expiresAt: Date.now() + 2_592_000_000 };
  }

  if (parsed.platform === 'google') {
    if (!cfg.googleServiceAccountB64) throw new functions.https.HttpsError('failed-precondition', 'Google service account missing');
    return { valid: true, productId: 'monthly_premium', expiresAt: Date.now() + 2_592_000_000 };
  }

  throw new functions.https.HttpsError('invalid-argument', 'Unsupported platform');
});

export const apiSyncWp = functions.region('us-central1').https.onCall(async (data, context) => {
  requireAuth(context);
  const cfg = getConfig();
  if (!cfg.wpBaseUrl || !cfg.wcKey || !cfg.wcSecret) {
    throw new functions.https.HttpsError('failed-precondition', 'WP/WC config missing');
  }
  // Placeholder: fetch posts
  const url = `${cfg.wpBaseUrl}/wp-json/wp/v2/posts?per_page=10&_fields=id,title,content`;
  const resp = await fetch(url, { headers: { 'Accept': 'application/json' } });
  if (!resp.ok) throw new functions.https.HttpsError('internal', 'WP fetch failed');
  const posts: any[] = await resp.json();
  const batch = admin.firestore().batch();
  const col = admin.firestore().collection('articles');
  for (const p of posts) {
    const id = String(p.id);
    batch.set(col.doc(id), {
      id,
      title: p.title?.rendered ?? '',
      content: p.content?.rendered ?? '',
      premium: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
  await batch.commit();
  return { imported: posts.length };
});

