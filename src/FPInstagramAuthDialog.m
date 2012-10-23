//
//  FPAuthDialog.m
//  FPInstagram
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import "FPInstagramAuthDialog.h"
#import "FPInstagramSession.h"

#define DIALOG_PADDING	0.0f

static NSString * const kAuthURIFormat = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token";

@interface FPInstagramAuthDialog () <UIWebViewDelegate>
@property (nonatomic, getter = isShowing) BOOL	showing;
@property (nonatomic, strong) UIWebView			* webView;
@property (nonatomic, strong) UIActivityIndicatorView	* loadingAcitivity;

@end

@implementation FPInstagramAuthDialog

@synthesize showing;
@synthesize webView	= _webView;
@synthesize loadingAcitivity	= _loadingAcitivity;

@synthesize session		= _session;
@synthesize delegate	= _delegate;

- (void)dealloc {
	_delegate = nil;
}

- (id)initWithInstagram:(FPInstagramSession *)session {
	self = [super initWithFrame:CGRectZero];
	if (self) {
		self.backgroundColor = nil;
		
		_session = session;
		
		_webView = [[UIWebView alloc] init];
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_webView.delegate = self;
		[self addSubview:_webView];
		
		_loadingAcitivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_loadingAcitivity.center = CGPointMake(CGRectGetWidth(_loadingAcitivity.bounds) / 2.0,
											   CGRectGetHeight(_loadingAcitivity.bounds) / 2.0);
		_loadingAcitivity.hidesWhenStopped = YES;
		_loadingAcitivity.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin
		| UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_loadingAcitivity];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [self initWithInstagram:nil];
	if (self) {
		// Initialization code
	}
	return self;
}

- (void)setBackgroundColor:(UIColor *)color {
	[super setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
}

- (void)reload {
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:kAuthURIFormat, self.session.clientId, self.session.redirectURI]];
	NSURLRequest * reqiuest = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:reqiuest];
}

- (void)show {
	if (!self.showing) {
		self.showing = YES;
		
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
		[window addSubview:self];
		
		CGRect selfFrame = window.bounds;
		selfFrame.origin.y = CGRectGetMaxY(statusBarFrame);
		selfFrame.size.height -= CGRectGetMaxY(statusBarFrame);
		self.frame = selfFrame;
		_webView.frame = CGRectMake(DIALOG_PADDING, DIALOG_PADDING,
									CGRectGetWidth(self.bounds) - DIALOG_PADDING * 2.0,
									CGRectGetHeight(self.bounds) - DIALOG_PADDING * 2.0);
		_webView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01f, 0.01f);
		[UIView animateWithDuration:0.5 animations:^{
			_webView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.3 animations:^{
				_webView.transform = CGAffineTransformIdentity;
			} completion:^(BOOL finished) {
				[self reload];
			}];
		}];
	}
}

- (void)dismiss {
	if (self.showing) {
		[UIView animateWithDuration:0.5 animations:^{
			_webView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01f, 0.01f);
		} completion:^(BOOL finished) {
			self.showing = NO;
			[self removeFromSuperview];
		}];
	}
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {

	BOOL result = YES;
	NSString * absoluteString = [[request URL] absoluteString];
	NSRange redirectURIRange = [absoluteString rangeOfString:self.session.redirectURI];
	if (redirectURIRange.location == 0) {
		NSString * query = [absoluteString substringFromIndex:NSMaxRange(redirectURIRange)];
		
		NSRange queryMarkRnage = [query rangeOfString:@"?"];
		if (queryMarkRnage.location != NSNotFound) {
			query = [query substringFromIndex:NSMaxRange(queryMarkRnage)];
		} else {
			NSRange grillMarkRange = [query rangeOfString:@"#"];
			if (grillMarkRange.location != NSNotFound) {
				query = [query substringFromIndex:NSMaxRange(grillMarkRange)];
			}
		}
		
		NSMutableDictionary  * parameters = [NSMutableDictionary dictionary];
		NSArray * parametersAndValues = [query componentsSeparatedByString:@"&"];
		for (NSString * string in parametersAndValues) {
			NSArray * parameterAndValue = [string componentsSeparatedByString:@"="];
			NSString * key = [parameterAndValue objectAtIndex:0];
			NSString * value = [parameterAndValue objectAtIndex:1];
			[parameters setObject:value
						   forKey:key];
		}
		
		NSLog(@"parameters %@", parameters);
		if ([parameters objectForKey:@"error"]) {
			if ([self.delegate respondsToSelector:@selector(instagramAuth:dialogDidFailWithError:)]) {
				NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										   [parameters objectForKey:@"error_description"], NSLocalizedDescriptionKey,
										   nil];
				NSError * error = [NSError errorWithDomain:@"com.fpinstagram.ErrorDomain"
													  code:-1
												  userInfo:userInfo];
				NSLog(@"%@", error);
				if ([self.delegate respondsToSelector:@selector(instagramAuth:dialogDidFailWithError:)]) {
					[self.delegate instagramAuth:self dialogDidFailWithError:error];
				}
				
			}
		} else if ([parameters objectForKey:@"access_token"]) {
			self.session.accessToken = [parameters objectForKey:@"access_token"];
			if ([self.delegate respondsToSelector:@selector(instagramAuthDialogDidFinish:)]) {
				[self.delegate instagramAuthDialogDidFinish:self];
			}
		}
		[self dismiss];
		
		result = NO;
	}
	return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self.loadingAcitivity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.loadingAcitivity stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self.loadingAcitivity stopAnimating];
}

@end
