const crypto = require('crypto');

// Generate checksum using HMAC-SHA256? Let's check what the Dart code did.
const mid = 'AuRbXg58569717520407';
const key = 'H6N&3QaXJV0rfi8D';

const body = {
    requestType: 'Payment',
    mid: mid,
    websiteName: 'WEBSTAGING',
    orderId: 'GAINIQ12345_12345',
    callbackUrl: 'https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=GAINIQ12345_12345',
    txnAmount: { value: '100.00', currency: 'INR' },
    userInfo: { custId: 'CUST_123' },
};

const bodyJson = JSON.stringify(body);
const hmac = crypto.createHmac('sha256', key).update(bodyJson).digest('hex');

const payload = {
    body: body,
    head: { signature: hmac }
};

fetch('https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?mid=' + mid + '&orderId=GAINIQ12345_12345', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
})
.then(res => res.json())
.then(data => console.log(JSON.stringify(data, null, 2)))
.catch(err => console.error(err));
