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

+ (NSArray *)latestRoutes;
+ (BOOL) switchStatus:(NSString*) routeKey;
+ (BOOL) deleteRoute:(NSString*) routeKey;
+ (BOOL) updateLocation: (CLLocation*) location locationString: (NSString*) locstr msg: (NSString*) msg; 
+ (BOOL) createRouteFrom:(CLPlacemark*) origin to: (CLPlacemark*) destination by: (NSDate*) date;
@end
