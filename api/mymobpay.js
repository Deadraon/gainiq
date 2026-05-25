module.exports = async (req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Credentials', true);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
    );

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    if (req.method !== 'POST') {
        return res.status(405).json({ error: "Method not allowed" });
    }

    try {
        const { amount, customerId, planName, customerPhone, customerName } = req.body;

        // Retrieve MyMobPay API Key from environment
        const apiKey = process.env.MYMOBPAY_API_KEY;
        
        if (!apiKey) {
             return res.status(500).json({ 
                 success: false, 
                 errorMessage: "Vercel environment variable MYMOBPAY_API_KEY is missing" 
             });
        }

        // We embed customerId and planName inside external_ref for webhook identification
        const externalRef = `${customerId}|${planName}`;
        
        const payload = {
            api_key: apiKey,
            amount: parseFloat(amount),
            customer_name: customerName || "GainIQ Customer",
            customer_phone: customerPhone || "",
            note: `GainIQ ${planName.toUpperCase()} Plan`,
            callback_url: `https://gainiq-ten.vercel.app/api/mymobpay-callback`,
            external_ref: externalRef,
            project: "GainIQ"
        };

        // Create the order on MyMobPay
        const response = await fetch("https://mymob.tech/api/orders", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            const errText = await response.text();
            return res.status(response.status).json({
                success: false,
                errorMessage: `MyMobPay API error: ${errText}`
            });
        }

        const data = await response.json();
        
        // Return order details to client, including the api_key prefix (test_ or live_)
        // so client can redirect, but keeping the secret part secure if desired, or 
        // returning the api_key so the client doesn't need it hardcoded.
        return res.status(200).json({
            success: true,
            orderId: data.orderId,
            orderAmount: data.orderAmount,
            mode: data.mode,
            apiKey: apiKey // Return the api key so Flutter can use it directly in payment page URL
        });

    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, errorMessage: error.message });
    }
};
