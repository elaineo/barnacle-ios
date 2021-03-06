//
//  BarnacleAppDelegate.h
//  Barnacle
//
//  Created by Warren Mar on 9/24/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BarnacleAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) CLLocationManager *locationManager;
@end
