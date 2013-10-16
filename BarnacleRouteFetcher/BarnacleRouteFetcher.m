//
//  BarnacleRouteFetcher.m
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "BarnacleRouteFetcher.h"



@implementation BarnacleRouteFetcher

+ (NSArray*) latestRoutes {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.gobarnacle.com/track/getroutes"]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSError *error;
     NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    NSString *data = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    NSLog(data);
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: urlData options:NSJSONReadingMutableContainers error:&error];
    return [JSON valueForKeyPath:@"routes"];
}

@end
