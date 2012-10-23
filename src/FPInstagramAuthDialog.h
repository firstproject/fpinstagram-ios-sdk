//
//  FPAuthDialog.h
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FPInstagramSession;
@protocol FPInstagramAuthDialogDelegate;

@interface FPInstagramAuthDialog : UIView

@property (nonatomic, unsafe_unretained) FPInstagramSession	* session;
@property (nonatomic, unsafe_unretained) id<FPInstagramAuthDialogDelegate>	delegate;

- (id)initWithInstagram:(FPInstagramSession *)session;

- (void)show;
- (void)dismiss;

@end

@protocol FPInstagramAuthDialogDelegate <NSObject>

@optional
- (void)instagramAuthDialogDidFinish:(FPInstagramAuthDialog *)dialog;
- (void)instagramAuth:(FPInstagramAuthDialog *)dialog dialogDidFailWithError:(NSError *)error;

@end
