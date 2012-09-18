//
//  FPInstagramAuthController.h
//  FPInstagram
//
//  Created by Developer on 9/18/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FPInstagramSession;
@protocol FPInstagramAuthControllerDelegate;

@interface FPInstagramAuthController : UIViewController

@property (nonatomic, assign) id<FPInstagramAuthControllerDelegate>	delegate;

- (id)initWithSession:(FPInstagramSession *)session;
- (void)present;

@end

@protocol FPInstagramAuthControllerDelegate <NSObject>

@optional
- (void)instagramAuthControllerDidCancel:(FPInstagramAuthController *)controller;
- (void)instagramAuthControllerDidFinish:(FPInstagramAuthController *)controller;
- (void)instagramAuthController:(FPInstagramAuthController *)controller didFailWithError:(NSError *)error;

@end
