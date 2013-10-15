//
//  FacebookLoginViewController.m
//  Barnacle
//
//  Created by Warren Mar on 9/29/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookLoginViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation FacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginView.readPermissions = @[@"basic_info", @"email", @"user_location"];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
                 NSLog(@"pressed");
    // Fetch user data
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         if (!error) {
             NSString *userInfo = @"";
             
             // Example: typed access (name)
             // - no special permissions required
             
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Name: %@\n\n",
                          user.id]];
             
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Name: %@\n\n",
                          user.first_name]];
             
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Name: %@\n\n",
                          user.last_name]];
             
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"email: %@\n\n",
                          [user objectForKey:@"email"]]];
             
             // Example: partially typed access, to location field,
             // name key (location)
             // - requires user_location permission
             userInfo = [userInfo
                         stringByAppendingString:
                         [NSString stringWithFormat:@"Location: %@\n\n",
                          user.location[@"name"]]];
             
//             NSLog(userInfo);
             
//             // login
//             NSMutableURLRequest *request = [NSMutableURLRequest
//                                             requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/signup/fb"]];
//             NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                          user.id, @"id",
//                                          user.first_name, @"first_name",
//                                          user.last_name, @"last_name",
//                                          [user objectForKey:@"email"], @"email",                    user.location[@"name"], @"location",nil];
//             NSError *error;
//             NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
//             [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//             [request setHTTPMethod:@"POST"];
//             [request setHTTPBody:postData];
//             NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//             
//             
//             request = [NSMutableURLRequest
//                        requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/getroutes"]];
//             [request setHTTPMethod:@"GET"];
//             NSURLResponse *response;
//             NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
//             NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
////             NSLog(data);
//             NSDictionary *JSON =
//             [NSJSONSerialization JSONObjectWithData: urlData options: NSJSONReadingMutableContainers
//                                               error: &error];
//             NSLog([JSON description]);

         } else {

         }
      }];
}


@end
