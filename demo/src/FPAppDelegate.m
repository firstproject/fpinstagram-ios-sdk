//
//  FPAppDelegate.m
//  FBInstagramDemo
//
//  Created by Developer on 9/17/12.
//  Copyright (c) 2012 First Project. All rights reserved.
//

#import "FPAppDelegate.h"

#import "FPViewController.h"

#import "FPInstagram.h"

@interface FPAppDelegate () <FPInstagramAuthDialogDelegate, FPInstagramAuthControllerDelegate>

@end

@implementation FPAppDelegate

- (void)dealloc {
	[_window release];
	[_viewController release];
	[_navigationController release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	// Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		self.viewController = [[[FPViewController alloc] initWithNibName:@"FPViewController_iPhone" bundle:nil] autorelease];
	} else {
		self.viewController = [[[FPViewController alloc] initWithNibName:@"FPViewController_iPad" bundle:nil] autorelease];
	}
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	
	FPInstagramSession * session = [FPInstagramSession activeSession];
	session.clientId = @"b72e99385b6446c183b57c7ef472943c";
	session.redirectURI = @"http://www.catgrid.com/success";

	FPInstagramAuthController * authController = [[[FPInstagramAuthController alloc] initWithSession:session] autorelease];
//	authController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
//																						style:UIBarButtonItemStylePlain
//																					   target:self
//																					   action:@selector(cancelButtonPressed:)]
//													   autorelease];
//	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:authController] autorelease];
	authController.delegate = self;
	[authController present];
//	[self.window.rootViewController presentModalViewController:self.navigationController animated:YES];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FPInstagramAuthDialogDelegate

- (void)instagramAuthDialogDidFinish:(FPInstagramAuthDialog *)dialog {
	[dialog release];
//	[[FPInstagramSession activeSession] getPath:@"/users/self/feed" completionBlock:^(FPInstagramRequest *request, id responseObject) {
//		NSLog(@"%@", responseObject);
//	} failureBlock:^(FPInstagramRequest *request, NSError *error) {
//		
//	}];
}

- (void)instagramAuth:(FPInstagramAuthDialog *)dialog dialogDidFailWithError:(NSError *)error {
	[dialog release];
	NSLog(@"%@", error);
}

#pragma mark - FPInstagramAuthControllerDelegate

- (void)cancelButtonPressed:(id)sender {
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//	self.navigationController = nil;
}

- (void)instagramAuthControllerDidCancel:(FPInstagramAuthController *)controller {
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//	self.navigationController = nil;
}

- (void)instagramAuthControllerDidFinish:(FPInstagramAuthController *)controller {
	
	[[FPInstagramSession activeSession] getPath:@"/users/self/feed" completionBlock:^(FPInstagramRequest *request, id responseObject) {
		NSLog(@"%@", responseObject);
		[[FPInstagramSession activeSession] clear];
	} failureBlock:^(FPInstagramRequest *request, NSError *error) {
		
	}];
	
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//	self.navigationController = nil;
}

- (void)instagramAuthController:(FPInstagramAuthController *)controller didFailWithError:(NSError *)error {
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//	self.navigationController = nil;
}

@end
