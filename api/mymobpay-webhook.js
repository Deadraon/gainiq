const crypto = require('crypto');
const admin = require('firebase-admin');

// Helper to initialize Firebase Admin safely
function getFirestoreDb() {
    if (admin.apps.length > 0) {
        return admin.firestore();
    }

    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY;

    if (!projectId || !clientEmail || !privateKey) {
        console.warn("Firebase Admin environment variables are missing. Firestore auto-activation via webhook will be skipped.");
        return null;
    }

    try {
        admin.initializeApp({
            credential: admin.credential.cert({
                projectId: projectId,
                clientEmail: clientEmail,
                privateKey: privateKey.replace(/\\n/g, '\n'),
            }),
        });
        return admin.firestore();
    } catch (err) {
        console.error("Failed to initialize Firebase Admin:", err);
        return null;
    }
}

module.exports = async (req, res) => {
    // Enable CORS for testing if needed
    res.setHeader('Access-Control-Allow-Credentials', true);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, X-MyMobPay-Signature, X-MyMobPay-Event'
    );

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    if (req.method !== 'POST') {
        return res.status(405).json({ error: "Method not allowed" });
    }

    try {
        const signature = req.headers['x-mymobpay-signature'];
        const event = req.headers['x-mymobpay-event'];
        const apiKey = process.env.MYMOBPAY_API_KEY;

        if (!apiKey) {
            return res.status(500).json({ error: "MYMOBPAY_API_KEY not configured on server" });
        }

        if (!signature) {
            return res.status(401).json({ error: "Missing signature header" });
        }

        // 1. Verify Webhook Signature
        // The HMAC secret is the raw api_key UUID (without test_/live_ prefix)
        let secretKey = apiKey;
        if (secretKey.startsWith('test_')) secretKey = secretKey.replace('test_', '');
        if (secretKey.startsWith('live_')) secretKey = secretKey.replace('live_', '');

        const payloadString = JSON.stringify(req.body);
        const expectedSig = crypto
            .createHmac('sha256', secretKey)
            .update(payloadString)
            .digest('hex');

        if (signature !== expectedSig) {
            console.error("Signature mismatch:", { received: signature, expected: expectedSig });
            return res.status(401).json({ error: "Invalid signature" });
        }

        console.log(`Webhook signature verified. Event: ${event}`);

        // 2. Handle payment.verified event
        if (event === 'payment.verified') {
            const { order_id, amount, external_ref, status, mode } = req.body;

            if (status !== 'verified') {
                return res.status(200).json({ message: "Status not verified. Skipping fulfillment." });
            }

            // Parse external_ref: "userId|planName" (e.g. "uid123|pro")
            if (!external_ref || !external_ref.includes('|')) {
                console.error("Invalid external_ref format:", external_ref);
                return res.status(400).json({ error: "Invalid external_ref" });
            }

            const [userId, planName] = external_ref.split('|');

            console.log(`Fulfilling order for User: ${userId}, Plan: ${planName}, Amount: ${amount}`);

            // Initialize Firestore database
            const db = getFirestoreDb();
            if (db) {
                const now = new Date();
                const expires = new Date();
                expires.setDate(now.getDate() + 30); // 30-day billing cycle

                const subscriptionData = {
                    plan: planName.toLowerCase(),
                    startedAt: now.toISOString(),
                    expiresAt: expires.toISOString()
                };

                // Update the user's subscription record in Firestore
                await db.collection('users').doc(userId).set({
                    subscription: subscriptionData
                }, { merge: true });

                console.log(`Firestore updated successfully for user ${userId}`);
            } else {
                console.warn("Firestore not updated because Firebase Admin is not initialized.");
            }
        }

        return res.status(200).json({ received: true });

    } catch (error) {
        console.error("Webhook processing error:", error);
        return res.status(500).json({ error: error.message });
    }
};
