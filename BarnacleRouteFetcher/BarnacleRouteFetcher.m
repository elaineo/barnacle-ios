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

+ (NSArray*) latestRoutes {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/getroutes"]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSError *error;
     NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
//    NSString *data = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: urlData options:NSJSONReadingMutableContainers error:&error];
//    NSLog([JSON description]);
    return [JSON valueForKeyPath:@"routes"];
}

+ (BOOL) deleteRoute:(NSString*) routeKey {
    NSArray *objects = [NSArray arrayWithObjects: routeKey, [NSNumber numberWithInt:0], nil];
    NSArray *keys = [NSArray arrayWithObjects: @"routekey", @"status", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/status"]];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    return YES;

}

+ (BOOL) switchStatus:(NSString*) routeKey {
    NSArray *objects = [NSArray arrayWithObjects: routeKey, [NSNumber numberWithInt:1], nil];
    NSArray *keys = [NSArray arrayWithObjects: @"routekey", @"status", nil];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/status"]];


    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    return YES;
    
    

}

+ (BOOL) createRouteFrom:(CLPlacemark*) origin to: (CLPlacemark*) destination by: (NSDate*) date {
//    { "tzoffset" : destTZ,
//        "startlat" : startLat,
//        "startlon" : startLon,
//        "destlat"  : destLat,
//        "destlon"  : destLon,
//        "locstart" : //get the string inside gray box #1,
//        "locend"   : //get the string inside gray box #2,
//        "delivend" : //get calendar date in the form of "MM/DD/YYYYY" }
    NSLog([date description]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    NSLog(stringFromDate);
    NSLog([origin description]);
    NSLog([destination description]);
    

    
    NSArray *objects = [NSArray arrayWithObjects:
                        [NSNumber numberWithInteger:0],
                        [NSNumber numberWithFloat:origin.location.coordinate.latitude],
                        [NSNumber numberWithFloat:origin.location.coordinate.longitude],
                               [NSNumber numberWithFloat:destination.location.coordinate.latitude],
                               [NSNumber numberWithFloat:destination.location.coordinate.longitude],
                        @"a",
                        @"b",
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
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/create"]];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];

    
    return YES;
}

+ (BOOL) updateLocation: (CLLocation*) location {
    double lat = location.coordinate.latitude;
    double lon = location.coordinate.longitude;
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lon], @"location string", @"message placeholder", nil];
    NSArray *keys = [NSArray arrayWithObjects: @"lat", @"lon", @"locstr", @"msg"];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects
                                                         forKeys:keys ];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(jsonString);
    NSString* targetUrl = @"http://www.gobarnacle.com/track/updateloc";
    // TODO fix me after debug
//    targetUrl = @"http://warrenmar.appspot.com/warren/test";
    NSLog(@"updategeo");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: targetUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
//    [request setValue:@"application/json" forKey:@"Accept"];
//    [request setValue:@"application/json" forKey:@"Content-Type"];
//    [request s]
//    [request setHTTPBody: jsonData];
    NSURLResponse *response;

    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];

    return YES;
}




@end
