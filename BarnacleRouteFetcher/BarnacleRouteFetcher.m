//
//  BarnacleRouteFetcher.m
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "BarnacleRouteFetcher.h"
#import <CoreLocation/CoreLocation.h>


@implementation BarnacleRouteFetcher

static NSDictionary* intervalDic = nil;
+ (NSDictionary*)getIntervalDictionary {
    if (intervalDic == nil) {
        intervalDic = @{@0: @"5 minutes",
                        @1: @"10 minutes",
                        @2: @"15 minutes",
                        @3: @"20 minutes",
                        @4: @"30 minutes",
                        @5: @"45 minutes",
                        @6: @"hour",
                        @7: @"2 hours",
                        @8: @"3 hours",
                        @9: @"4 hours",
                        @10: @"6 hours",
                        @11: @"8 hours",
                        @12: @"12 hours",
                        @13: @"24 hours"};
        
    }
    return intervalDic;
}


static NSDictionary* intervalValueDic = nil;
+ (NSDictionary*)getIntervalValueDictionary {
    if (intervalValueDic == nil) {
        intervalValueDic = @{@0: @300,
                        @1: @600,
                        @2: @900,
                        @3: @1200,
                        @4: @1800,
                        @5: @2700,
                        @6: @3600,
                        @7: @7200,
                        @8: @10800,
                        @9: @14400,
                        @10: @21600,
                        @11: @28800,
                        @12: @43200,
                        @13: @86400};
        
    }
    return intervalValueDic;
}

+ (NSDictionary*) postJSON:(NSDictionary*) json url: (NSURL*) url error: (NSError*) error{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    NSDictionary* jsonReponse = [NSJSONSerialization
                                 JSONObjectWithData:urlData
                                 options:kNilOptions
                                 error:&error];
    return jsonReponse;
}


+ (NSArray*) latestRoutes {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/getroutes"]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSError *error;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: urlData options:NSJSONReadingMutableContainers error:&error];
    return [JSON valueForKeyPath:@"routes"];
}

+ (BOOL) deleteRoute:(NSString*) routeKey {
    NSDictionary *jsonDict = @{@"routekey" : routeKey,
                               @"status" : @0};
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/status"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}


+ (BOOL) switchStatus:(NSString*) routeKey {
    NSDictionary *jsonDict = @{@"routekey" : routeKey,
                               @"status" : @1};
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/status"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}

+ (BOOL) createRouteFrom:(CLPlacemark*) origin to: (CLPlacemark*) destination by: (NSDate*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    NSString* locstart = [[origin.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "];
    NSString* locend = [[destination.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "];
    
    NSDictionary *jsonDict = @{@"tzoffset" : @0,
                               @"startlat" : [NSNumber numberWithFloat:origin.location.coordinate.latitude],
                               @"startlon" : [NSNumber numberWithFloat:origin.location.coordinate.longitude],
                               @"destlat" :  [NSNumber numberWithFloat:destination.location.coordinate.latitude],
                               @"destlon" : [NSNumber numberWithFloat:destination.location.coordinate.longitude],
                               @"locstart": locstart,
                               @"locend" : locend,
                               @"delivend": stringFromDate};
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/create"] error:error];
    NSLog(@"create");
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}


+ (BOOL) updateLocation: (CLLocation*) location locationString: (NSString*) locstr msg: (NSString*) msg {
    NSLog(@"update location");
    NSDictionary *jsonDict = @{@"lat" : [NSNumber numberWithDouble:location.coordinate.latitude],
                               @"lon" : [NSNumber numberWithDouble:location.coordinate.longitude],
                               @"locstr" : locstr,
                               @"msg" : msg};
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/updateloc"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}

@end
