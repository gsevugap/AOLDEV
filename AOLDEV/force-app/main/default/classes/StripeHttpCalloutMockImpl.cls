global class StripeHttpCalloutMockImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
    	 HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
    	if(req.getEndpoint().contains('/products')){
         res.setBody('{"id":"prod_E70QY4svw3qTmW","object":"product","active":true,"attributes":[],"caption":null,"created":1544200964,"deactivate_on":[],"description":null,"images":[],"livemode":false,"metadata":{},"name":"Digital","package_dimensions":null,"shippable":null,"statement_descriptor":null,"type":"service","unit_label":null,"updated":1544200964,"url":null}');
    	} else if(req.getEndpoint().contains('/plans')){
    		res.setBody('{"id":"plan_E70QRZZTHXNb1D","object":"plan","active":true,"aggregate_usage":null,"amount":800,"billing_scheme":"per_unit","created":1544200964,"currency":"usd","interval":"month","interval_count":1,"livemode":false,"metadata":{},"nickname":"Monthly","product":"prod_E70QY4svw3qTmW","tiers":null,"tiers_mode":null,"transform_usage":null,"trial_period_days":null,"usage_type":"licensed"}');	
    	}
         res.setStatusCode(200);
         return res;
    }
}