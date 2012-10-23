//
//  FBInstagramSession.m
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import "FPInstagramSession.h"
#import "FPInstagramRequest.h"

static FPInstagramSession	* ActiveSession = nil;

@implementation FPInstagramSession

@synthesize clientId	= _clientId;
@synthesize redirectURI	= _redirectURI;
@synthesize accessToken	= _accessToken;

+ (id)activeSession {
	if (!ActiveSession) {
		ActiveSession = [[FPInstagramSession alloc] init];
	}
	return ActiveSession;
}

- (void)getPath:(NSString *)path
completionBlock:(FPRequestCompletionBlock)completionBlock
   failureBlock:(FPRequestFailureBlock)failureBlock {
	
	FPInstagramRequest * request = [[FPInstagramRequest alloc] init];
	request.session = self;
	[request getPath:path parameters:nil];
	[request startWithCompletionBlock:completionBlock
						 failureBlock:failureBlock];
}

- (void)clear {
	NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"http://instagram.com"]];

	for (NSHTTPCookie * cookie in cookies) {
		[cookieStorage deleteCookie:cookie];
	}
}

@end
