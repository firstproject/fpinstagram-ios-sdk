//
//  FPInstagramAuthController.m
//  FPInstagram
//
//  Created by Developer on 9/18/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import "FPInstagramAuthController.h"
#import "FPInstagramSession.h"

static NSString * const kAuthURIFormat = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token";

@interface FPInstagramAuthController () <UIWebViewDelegate>
@property (nonatomic, weak) FPInstagramSession		* session;
@property (nonatomic, strong) UIWebView					* webView;
@property (nonatomic, strong) UIActivityIndicatorView	* loadingAcitivity;
@end

@implementation FPInstagramAuthController
@synthesize session				= _session;
@synthesize delegate			= _delegate;
@synthesize webView				= _webView;
@synthesize loadingAcitivity	= _loadingAcitivity;

- (void)dealloc {
	_delegate = nil;
	_session = nil;
}

- (id)initWithSession:(FPInstagramSession *)session {
	self = [self initWithNibName:nil bundle:nil];
	if (self) {
		_session = session;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
																				 style:UIBarButtonItemStylePlain
																				target:self
																				action:@selector(cancelButtonPressed:)];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.delegate = self;
	[self.view addSubview:_webView];
	
	_loadingAcitivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_loadingAcitivity.hidesWhenStopped = YES;
	_loadingAcitivity.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin
	| UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.view addSubview:_loadingAcitivity];
	_loadingAcitivity.center = [self.view convertPoint:self.view.center fromView:_loadingAcitivity];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reload];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)present {
	if (![self isViewLoaded]) {
		
		UIViewController * windowRootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		[windowRootController presentModalViewController:[[UINavigationController alloc] initWithRootViewController:self]
												animated:YES];
	}
}

- (void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonPressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(instagramAuthControllerDidCancel:)]) {
		[self.delegate instagramAuthControllerDidCancel:self];
	}
	[self dismiss];
}

- (void)reload {
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:kAuthURIFormat, self.session.clientId, self.session.redirectURI]];
	NSURLRequest * reqiuest = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:reqiuest];
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
		
		NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
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
				if ([self.delegate respondsToSelector:@selector(instagramAuthController:didFailWithError:)]) {
					[self.delegate instagramAuthController:(FPInstagramAuthController *)self didFailWithError:error];
				}
				
			}
		} else if ([parameters objectForKey:@"access_token"]) {
			self.session.accessToken = [parameters objectForKey:@"access_token"];
			if ([self.delegate respondsToSelector:@selector(instagramAuthControllerDidFinish:)]) {
				[self.delegate instagramAuthControllerDidFinish:(FPInstagramAuthController *)self];
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
