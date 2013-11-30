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
    //    NSString *data = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: urlData options:NSJSONReadingMutableContainers error:&error];
    return [JSON valueForKeyPath:@"routes"];
}

+ (BOOL) deleteRoute:(NSString*) routeKey {
    NSArray *objects = [NSArray arrayWithObjects: routeKey, [NSNumber numberWithInt:0], nil];
    NSArray *keys = [NSArray arrayWithObjects: @"routekey", @"status", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/status"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}


+ (BOOL) switchStatus:(NSString*) routeKey {
    NSArray *objects = [NSArray arrayWithObjects: routeKey, [NSNumber numberWithInt:1], nil];
    NSArray *keys = [NSArray arrayWithObjects: @"routekey", @"status", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
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
    
    
    NSArray *objects = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:0],
                        [NSNumber numberWithFloat:origin.location.coordinate.latitude],
                        [NSNumber numberWithFloat:origin.location.coordinate.longitude],
                        [NSNumber numberWithFloat:destination.location.coordinate.latitude],
                        [NSNumber numberWithFloat:destination.location.coordinate.longitude],
                        locstart,
                        locend,
                        stringFromDate,
                        nil];
    NSArray *keys = [NSArray arrayWithObjects: @"tzoffset",
                     @"startlat",
                     @"startlon",
                     @"destlat",
                     @"destlon",
                     @"locstart",
                     @"locend",
                     @"delivend",
                     nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/create"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}


+ (BOOL) updateLocation: (CLLocation*) location locationString: (NSString*) locstr msg: (NSString*) msg {
    double lat = location.coordinate.latitude;
    double lon = location.coordinate.longitude;
    NSArray *objects = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:lat],
                        [NSNumber numberWithDouble:lon],
                        locstr,
                        msg, nil];
    NSArray *keys = [NSArray arrayWithObjects: @"lat", @"lon", @"locstr", @"msg", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    NSError *error;
    NSDictionary *jsonResponse = [self postJSON:jsonDict url:[NSURL URLWithString:@"http://www.gobarnacle.com/track/updateloc"] error:error];
    if ([@"ok" isEqualToString:[jsonResponse objectForKey:@"status"]]) {
        return YES;
    }
    return NO;
}

@end
