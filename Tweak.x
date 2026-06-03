#import <substrate.h>
#import <Foundation/Foundation.h>

@interface FBCrashFixProtocol : NSURLProtocol
@end

@implementation FBCrashFixProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	if ([NSURLProtocol propertyForKey:@"FBCrashFixHandled" inRequest:request]) return NO;
	NSString *host = [request valueForHTTPHeaderField:@"Host"] ?: request.URL.host;
	if (![host isEqualToString:@"api.facebook.com"]) return NO;
	if (![request.URL.path hasPrefix:@"/method/"]) return NO;
	return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

- (void)startLoading {
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[queue addOperationWithBlock:^{
		NSMutableURLRequest *newReq = [self.request mutableCopy];
		[NSURLProtocol setProperty:@YES forKey:@"FBCrashFixHandled" inRequest:newReq];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:newReq returningResponse:&response error:&error];
		if (error) {
			[self.client URLProtocol:self didFailWithError:error];
			return;
		}
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (httpResponse.statusCode == 404) {
			NSHTTPURLResponse *newResponse = [[NSHTTPURLResponse alloc] initWithURL:httpResponse.URL statusCode:400 HTTPVersion:@"HTTP/1.1" headerFields:httpResponse.allHeaderFields];
			NSString *body = @"{\"error_code\":1,\"error_msg\":\"The request could not be understood by the server due to malformed syntax.\"}";
			data = [body dataUsingEncoding:NSUTF8StringEncoding];
			response = newResponse;
		}
		[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
		[self.client URLProtocol:self didLoadData:data];
		[self.client URLProtocolDidFinishLoading:self];
	}];
}

- (void)stopLoading {
}

@end

%ctor {
	[NSURLProtocol registerClass:[FBCrashFixProtocol class]];
}