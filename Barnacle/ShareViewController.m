//
//  ShareViewController.m
//  Barnacle
//
//  Created by Warren Mar on 12/27/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "ShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender {
    NSLog(@"share");
    NSURL* url = [NSURL URLWithString:@"https://developers.facebook.com/ios"];
    if ([FBDialogs canPresentShareDialogWithParams:nil]) {
    
    } else {
        NSLog(@"cannot share");
    }
    
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"https://example.com/book/Snow-Crash.html"];
    BOOL canShare = [FBDialogs canPresentShareDialogWithParams:params];
    if (canShare) {
        // FBDialogs call to open Share dialog
    }
    
    [FBDialogs presentShareDialogWithLink:url
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    [action setObject:@"https://example.com/book/Snow-Crash.html" forKey:@"book"];
    
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:@"books.reads"
                                 previewPropertyName:@"book"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                 if(error) {
                                                     NSLog(@"Error: %@", error.description);
                                                 } else {
                                                     NSLog(@"Success!");
                                                 }
                                             }];
}
@end
