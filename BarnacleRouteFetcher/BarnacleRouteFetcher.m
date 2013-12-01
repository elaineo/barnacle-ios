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
                               @"startlat" : [NSNumber numberWithFloat:origin.location.coordinate.longitude],
                               @"startlon" : [NSNumber numberWithFloat:origin.location.coordinate.longitude],
                               @"destlat" :  [NSNumber numberWithFloat:destination.location.coordinate.latitude],
                               @"destlon" : [NSNumber numberWithFloat:destination.location.coordinate.longitude],
                               @"locstart": locstart,
                               @"locend" : locend,
                               @"delivend": stringFromDate};
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/create"] error:error];
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
