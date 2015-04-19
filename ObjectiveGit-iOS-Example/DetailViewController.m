//
//  DetailViewController.m
//  ObjectiveGit-iOS-Example
//
//  Created by Adrian on 11/11/2013.
//  Copyright (c) 2013 You. All rights reserved.
//

#import "DetailViewController.h"
#import <ObjectiveGit/ObjectiveGit.h>
#import <git2/common.h>

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    NSString *const CACertificateFile_DigiCert = @"DigiCertHighAssuranceEVRootCA.pem";
    NSString *const certFilePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:CACertificateFile_DigiCert];
    NSLog(@"Loading certificate: %@", certFilePath);
    
    const char *file = certFilePath.UTF8String;
    const char *path = NULL;
    
    int returnValue = git_libgit2_opts(GIT_OPT_SET_SSL_CERT_LOCATIONS, file, path);
    if (returnValue != 0) {
        NSLog(@"Error setting SSL certificate location");
    }
    
	if (self.detailItem) {
		GTRepository* repo = nil;
		NSString* url = [self.detailItem valueForKey:@"gitURL"];
		NSError* error = nil;
		NSFileManager* fileManager = [NSFileManager defaultManager];
		NSURL* appDocsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
		NSURL* localURL = [NSURL URLWithString:url.lastPathComponent relativeToURL:appDocsDir];
		
        NSURL*nsUrl = [NSURL URLWithString:url];
        if (![fileManager fileExistsAtPath:localURL.path isDirectory:nil]) {
//            repo = [GTRepository
//                    cloneFromURL:nsUrl
//                    toWorkingDirectory: localURL
//                    options: @{GTRepositoryCloneOptionsTransportFlags: @YES}
//                    error: &error
//                    transferProgressBlock: ^(const git_transfer_progress * progress, BOOL *stop) {
//                    }
//                    checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
//                        NSLog(@"%lu/%lu", (unsigned long)completedSteps, (unsigned long)totalSteps);
//                    }
//                ];
			repo =
                [GTRepository
                    cloneFromURL:[NSURL URLWithString:url]
                    toWorkingDirectory:localURL
                    options:@{GTRepositoryCloneOptionsTransportFlags: @YES}
                    error:&error
                 transferProgressBlock:^(const git_transfer_progress *progress, BOOL *stop) {
				
                                                  }
            checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
				NSLog(@"%lu/%lu", (unsigned long)completedSteps, (unsigned long)totalSteps);
			}];
			if (error) {
				NSLog(@"%@", error);
			}
		}
        else {
			repo = [GTRepository repositoryWithURL:localURL error:&error];
			if (error) {
				NSLog(@"%@", error);
			}

		}
		GTReference* head = [repo headReferenceWithError:&error];
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		}
        
        GTCommit* commit = [repo lookUpObjectByOID: head.targetOID  error:&error];
//		GTCommit* commit = [repo lookupObjectBySHA: head.targetSHA error:&error];
		if (error) {
			NSLog(@"%@", error.localizedDescription);
		}
		self.detailDescriptionLabel.text = [NSString stringWithFormat:@"Last commit message: %@", commit.messageSummary];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Helper functions

@end
