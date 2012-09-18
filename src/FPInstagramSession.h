//
//  FBInstagramSession.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPInstagramRequest.h"

@interface FPInstagramSession : NSObject

@property (nonatomic, copy) NSString	* clientId;
@property (nonatomic, copy) NSString	* redirectURI;
@property (nonatomic, copy) NSString	* accessToken;

+ (id)activeSession;

- (void)getPath:(NSString *)path
completionBlock:(FPRequestCompletionBlock)completionBlock
   failureBlock:(FPRequestFailureBlock)failureBlock;
//- (void)cancelRequestForPath:(NSString *)path;

@end
