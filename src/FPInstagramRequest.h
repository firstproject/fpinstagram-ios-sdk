//
//  FPInstagramRequest.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPInstagramRequest;
typedef void (^FPRequestCompletionBlock)(FPInstagramRequest * request, id responseObject);
typedef void (^FPRequestFailureBlock)(FPInstagramRequest * request, NSError * error);

@class FPInstagramSession;
@interface FPInstagramRequest : NSObject

@property (nonatomic, assign) FPInstagramSession	* session;
@property (nonatomic, retain, readonly) NSError		* error;
@property (nonatomic, retain, readonly) id			responseObject;

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters;

- (void)startWithCompletionBlock:(FPRequestCompletionBlock)completionBlock
					failureBlock:(FPRequestFailureBlock)failureBlock;

@end
