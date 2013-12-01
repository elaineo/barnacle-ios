//
//  BarnacleAppDelegate.m
//  Barnacle
//
//  Created by Warren Mar on 9/24/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "BarnacleAppDelegate.h"
#import "BarnacleRouteFetcher.h"
@interface BarnacleAppDelegate()
@property NSDate* lastUpdate;
@end

@implementation BarnacleAppDelegate

@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBLoginView class];
    // Default User Preferences
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults registerDefaults:@{@"autoUpdateLocation": [NSNumber numberWithBool:NO]}];
    [standardDefaults registerDefaults:@{@"autoUpdateLocationInterval": [NSNumber numberWithDouble:15.0]}];
    [standardDefaults synchronize];
    // location manager
    self.lastUpdate = [[NSDate alloc] initWithTimeIntervalSince1970: 0];
    self.locationManager = [[CLLocationManager alloc] init];
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
//        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];

    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // add app-specific handling code here
    return wasHandled;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location");
    CLLocation* location = (CLLocation*)[locations lastObject];
    NSUserDefaults *fetchDefaults = [NSUserDefaults standardUserDefaults];
    BOOL autoUpdateState = [fetchDefaults boolForKey:@"autoUpdateLocation"];
    float interval = [fetchDefaults doubleForKey:@"autoUpdateLocationInterval"];
    if (autoUpdateState) {
        if ([[NSDate date] timeIntervalSinceDate:self.lastUpdate] > interval) {
            self.lastUpdate = [NSDate date];
            if (location) {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                    CLPlacemark *placemark = [placemarks lastObject];
                    NSDictionary *address = placemark.addressDictionary;
                    NSArray *formattedAddress = [address valueForKey:@"FormattedAddressLines"];
                    NSString *locstr = [formattedAddress componentsJoinedByString:@" "];
                    [BarnacleRouteFetcher updateLocation: location locationString:locstr msg:@""];
                }];
                
            }
        }
    }
}

@end
