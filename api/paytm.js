const PaytmChecksum = require('paytmchecksum');

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
        const { amount, customerId, orderId, isTest } = req.body;

        // In production, get these from process.env instead of the client request
        const mid = process.env.PAYTM_MID;
        const merchantKey = process.env.PAYTM_MERCHANT_KEY;
        const website = process.env.PAYTM_WEBSITE || (isTest ? 'WEBSTAGING' : 'DEFAULT');
        
        if (!mid || !merchantKey) {
             return res.status(500).json({ success: false, errorMessage: "Vercel environment variables PAYTM_MID or PAYTM_MERCHANT_KEY are missing" });
        }

        const baseUrl = isTest ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in';
        
        const paytmParams = {};
        paytmParams.body = {
            requestType: 'Payment',
            mid: mid,
            websiteName: website,
            orderId: orderId,
            callbackUrl: `${baseUrl}/theia/paytmCallback?ORDER_ID=${orderId}`,
            txnAmount: { value: amount, currency: 'INR' },
            userInfo: { custId: customerId },
        };

        const signature = await PaytmChecksum.generateSignature(JSON.stringify(paytmParams.body), merchantKey);
        paytmParams.head = { signature: signature };

        const response = await fetch(`${baseUrl}/theia/api/v1/initiateTransaction?mid=${mid}&orderId=${orderId}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(paytmParams)
        });

        const data = await response.json();
        
        const resultInfo = data.body?.resultInfo;
        if (resultInfo?.resultCode === '0000') {
            return res.status(200).json({
                success: true,
                txnToken: data.body.txnToken,
                orderId: orderId,
                amount: amount,
                mid: mid
            });
        } else {
             return res.status(400).json({
                success: false,
                errorMessage: `Paytm Error: ${resultInfo?.resultMsg} (code: ${resultInfo?.resultCode})`
             });
        }

    } catch (error) {
        console.error(error);
        return res.status(500).json({ success: false, errorMessage: error.message });
    }
};
