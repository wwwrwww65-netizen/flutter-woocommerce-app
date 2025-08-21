Mobile Troubleshooter Backend (Firebase Functions)

Prerequisites

- Firebase CLI installed and authenticated
- Node.js 20+

Setup

1. firebase init functions (choose TypeScript, ESLint, npm)
2. Copy env placeholders and set config:

   firebase functions:config:set openai.key="<<AI_API_KEY>>" rate.limit="50" wp.base_url="<<WP_BASE_URL>>" wc.consumer_key="<<WOOCOMMERCE_CONSUMER_KEY>>" wc.consumer_secret="<<WOOCOMMERCE_CONSUMER_SECRET>>" apple.iap_secret="<<APP_STORE_SHARED_SECRET>>" google.service_account="<<GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64>>"

3. Deploy:

   firebase deploy --only functions

Functions

- apiAiChat: Moderates and forwards chat to AI provider using server-side key, with simple rate-limit per uid/ip.
- apiIapValidate: Validates Google Play and App Store receipts server-side and returns entitlement status.
- apiSyncWp: Fetches and normalizes content from WordPress/WooCommerce source.

Secrets

- Stored via Firebase env config; never checked into source.

Demo data

- demo-data/: 10 sample articles (some premium). Import to Firestore or seed SQLite.

Placeholders

- <<AI_API_KEY>>, <<WOOCOMMERCE_CONSUMER_KEY>>, <<WOOCOMMERCE_CONSUMER_SECRET>>, <<WP_BASE_URL>>, <<APP_STORE_SHARED_SECRET>>, <<GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64>>

