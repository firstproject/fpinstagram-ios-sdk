//
//  FPInstagramRequest.m
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import "FPInstagramRequest.h"
#import "FPInstagramSession.h"


static NSString * const kBaseURI	= @"https://api.instagram.com/v1/";

@interface FPInstagramRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLRequest		* request;
@property (nonatomic, strong) NSURLConnection	* connection;
@property (nonatomic, strong) NSMutableData		* receiveData;
@property (nonatomic, copy) FPRequestCompletionBlock	completionBlock;
@property (nonatomic, copy) FPRequestFailureBlock		failureBlock;
@property (nonatomic, strong, readwrite) NSError		* error;
@property (nonatomic, strong, readwrite) id			responseObject;
@end

@implementation FPInstagramRequest

@synthesize completionBlock	= _completionBlock;
@synthesize failureBlock	= _failureBlock;

@synthesize connection	= _connection;
@synthesize receiveData	= _receiveData;

@synthesize session		= _session;
@synthesize error		= _error;

static NSArray * FPMakePairs(NSDictionary * parameters) {
	NSMutableArray * keysValues = [NSMutableArray array];
	[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[keysValues addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
	}];
	return [keysValues copy];
}

- (void)dealloc {
	_session = nil;
	[_connection cancel];
}

- (NSMutableURLRequest *)requestPath:(NSString *)path
						  parameters:(NSDictionary *)parameters
						  httpMethod:(NSString *)httpMethod {
	
	NSMutableDictionary * mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
	[mutableParameters setObject:self.session.clientId forKey:@"client_id"];
	[mutableParameters setObject:self.session.accessToken forKey:@"access_token"];
	
	NSMutableURLRequest * request = nil;
	NSArray * pairs = FPMakePairs(mutableParameters);
	NSString * urlString = [kBaseURI stringByAppendingPathComponent:path];
	if ([httpMethod isEqualToString:@"GET"]) {
		NSURL * url = [NSURL URLWithString:[urlString stringByAppendingFormat:@"/?%@", [pairs componentsJoinedByString:@"&"]]];
		request = [NSMutableURLRequest requestWithURL:url];
	} else if ([httpMethod isEqualToString:@"POST"]) {
		NSURL * url = [NSURL URLWithString:urlString];
		request = [NSMutableURLRequest requestWithURL:url];
		[request setHTTPBody:[[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[request setHTTPMethod:httpMethod];
	return request;
}

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters {
	self.request = [self requestPath:path parameters:parameters httpMethod:@"GET"];
}

- (void)startWithCompletionBlock:(FPRequestCompletionBlock)completionBlock failureBlock:(FPRequestFailureBlock)failureBlock {
	if (!_connection) {
		self.completionBlock = completionBlock;
		self.failureBlock = failureBlock;
		_connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
		if (_connection) {
			self.receiveData = [NSMutableData data];
		}
	}
}

#pragma mark - Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_receiveData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSError * error = nil;
	[self setResponseObject:[NSJSONSerialization JSONObjectWithData:_receiveData options:0 error:&error]];

	[self setError:error];
	[self setConnection:nil];
	[self setReceiveData:nil];
	
	if (_error) {
		if (self.failureBlock) {
			self.failureBlock(self, _error);
		}
	} else {
		if (self.completionBlock) {
			self.completionBlock(self, _responseObject);
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self setConnection:nil];
	[self setReceiveData:nil];
	[self setResponseObject:nil];
	[self setError:error];
	
	if (self.failureBlock) {
		self.failureBlock(self, _error);
	}
}

@end
