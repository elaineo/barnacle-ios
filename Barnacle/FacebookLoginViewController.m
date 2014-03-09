//
//  FacebookLoginViewController.m
//  Barnacle
//
//  Created by Warren Mar on 9/29/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BarnacleRouteFetcher.h"

@interface FacebookLoginViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *manageRouteButton;
@property (weak, nonatomic) IBOutlet UIButton *trackDeliveryButton;

@end

@implementation FacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.readPermissions = @[@"basic_info", @"email", @"user_location"];
// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateUI];
    
}

-(void) updateUI {
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        [self.manageRouteButton setHidden:NO];
        [self.trackDeliveryButton setHidden:NO];
    } else {
        [self.manageRouteButton setHidden:YES];
        [self.trackDeliveryButton setHidden:YES];
    }
    NSUserDefaults *fetchDefaults = [NSUserDefaults standardUserDefaults];
    BOOL autoUpdateState = [fetchDefaults boolForKey:@"autoUpdateLocation"];
    if (autoUpdateState) {
        [self.trackDeliveryButton setTitle:@"Manage Tracking" forState:UIControlStateNormal];
    } else {
        [self.trackDeliveryButton setTitle:@"Track Delivery" forState:UIControlStateNormal];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {

}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {

}


- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self.manageRouteButton setHidden:NO];
    [self.trackDeliveryButton setHidden:NO];
    // Fetch user data
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         if (!error && ![BarnacleRouteFetcher isLoggedIn]) {
             // login
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:user.id forKey:@"fbid"];
            [defaults setValue:user.first_name forKey:@"first_name"];
            [defaults setValue:user.last_name forKey:@"last_name"];
            [defaults setValue:[user objectForKey:@"email"]forKey:@"email"];
             [BarnacleRouteFetcher login:user.id firstName:user.first_name lastName:user.last_name email:[user objectForKey:@"email"]];

         } else {
             
         }
     }];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [self.manageRouteButton setHidden:YES];
    [self.trackDeliveryButton setHidden:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)barnacleButonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString: @"http://www.gobarnacle.com"];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (IBAction)buttonPressed:(id)sender {

}


@end
