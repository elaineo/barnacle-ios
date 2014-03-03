//
//  BarnacleRouteFetcher.h
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define BARNACLE_ROUTE_KEY @"routekey"
#define BARNACLE_STATUS @"status"
#define BARNACLE_STATUSINT @"statusint"
#define BARNACLE_DELIVEND @"delivend"
#define BARNACLE_POST_URL @"post_url"
#define BARNACLE_LOC_START @"locstart"
#define BARNACLE_LOC_END @"locend"

@interface BarnacleRouteFetcher : NSObject
+ (NSDictionary*)getIntervalDictionary;
+ (NSDictionary*)getIntervalValueDictionary;
+ (NSArray *)latestRoutes;
+ (BOOL) login: (NSString*) fbid firstName: (NSString*) firstName lastName: (NSString*) lastName email: (NSString*) email;
+ (BOOL) isLoggedIn;
+ (BOOL) endDrive;
+ (BOOL) switchStatus:(NSString*) routeKey;
+ (BOOL) deleteRoute:(NSString*) routeKey;
+ (BOOL) updateLocation: (CLLocation*) location locationString: (NSString*) locstr msg: (NSString*) msg; 
+ (NSDictionary *) createRouteFrom:(CLPlacemark*) origin to: (CLPlacemark*) destination by: (NSDate*) date;
+ (NSString*) trackSubmit: (NSString*) routeKey;
+ (BOOL) trackConfirm: (NSString*) routeKey withCode: (NSString*) code;
@end
