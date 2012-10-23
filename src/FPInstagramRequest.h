//
//  FPInstagramRequest.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPInstagramSession;
@class FPInstagramRequest;

typedef void (^FPRequestCompletionBlock)(FPInstagramRequest * request, id responseObject);
typedef void (^FPRequestFailureBlock)(FPInstagramRequest * request, NSError * error);


@interface FPInstagramRequest : NSObject

@property (nonatomic, unsafe_unretained) FPInstagramSession	* session;
@property (nonatomic, strong, readonly) NSError		* error;
@property (nonatomic, strong, readonly) id			responseObject;

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters;

- (void)startWithCompletionBlock:(FPRequestCompletionBlock)completionBlock
					failureBlock:(FPRequestFailureBlock)failureBlock;

@end
