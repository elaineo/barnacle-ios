//
//  Route+Barnacle.m
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "Route+Barnacle.h"
#import "BarnacleRouteFetcher.h"

@implementation Route (Barnacle)
+ (Route*) routeWithBarnacleInfo:(NSDictionary*) routeDictionary inManagedObjectConext:(NSManagedObjectContext*) context{
    Route *route = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Route"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:BARNACLE_LOC_START ascending:YES]];
    [BARNACLE_ROUTE_KEY stringByAppendingString:@" = %@"];
    request.predicate = [NSPredicate predicateWithFormat:    [BARNACLE_ROUTE_KEY stringByAppendingString:@" = %@"], [routeDictionary[BARNACLE_ROUTE_KEY] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!context){
        NSLog(@"null context");
    }
    if (!matches || ([matches count] > 1) ){
        NSLog(@"error");
        NSLog(@"%@", [error description]);
        // handle error
    } else if (![matches count]) {
        NSLog(@"new");
        route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        route.routekey = routeDictionary[BARNACLE_ROUTE_KEY];
        route.delivend = routeDictionary[BARNACLE_DELIVEND];
        route.posturl = routeDictionary[BARNACLE_POST_URL];
        route.locstart = routeDictionary[BARNACLE_LOC_START];
        route.locend = routeDictionary[BARNACLE_LOC_END];
        route.statusint = [routeDictionary[BARNACLE_STATUSINT] integerValue];
        NSLog(@"%d",  route.statusint);
        if ( route.statusint == 0) {
            NSLog(@"PANDA");
        }
        switch ([routeDictionary[BARNACLE_STATUSINT] integerValue]) {
            case 0:
                route.status = @"Active";
                break;
            case 1:
                route.status = @"Inactive";
                                break;
            case 2:
                route.status = @"Waiting Confirmation";
                                break;
            case 3:
                route.status = @"Completed";
                                break;
            default:
                route.status = @"undefined";
                                break;
        }
//        route.statusint = routeDictionary[BARNACLE_STATUSINT];
    } else {
        route = [matches lastObject];
    }
    return route;
}
@end
