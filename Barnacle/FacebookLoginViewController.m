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
             NSMutableURLRequest *request = [NSMutableURLRequest
                                             requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/signup/fb"]];
             NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          user.id, @"id",
                                          user.first_name, @"first_name",
                                          user.last_name, @"last_name",
                                          [user objectForKey:@"email"], @"email",                    user.location[@"name"], @"location",nil];
             NSError *error;
             NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
             [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
             [request setHTTPMethod:@"POST"];
             [request setHTTPBody:postData];
             NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
             if (!connection) {
                 NSLog(@"error");
             }
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

- (IBAction)buttonPressed:(id)sender {

}


@end
