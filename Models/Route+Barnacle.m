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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locstart" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"key = %@", [routeDictionary[BARNACLE_ROUTE_KEY] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1) ){
        // handle error
    } else if (![matches count]) {
        route.key = routeDictionary[BARNACLE_ROUTE_KEY];
        route.locstart = routeDictionary[BARNACLE_LOC_START];
        route.locend = routeDictionary[BARNACLE_LOC_END];
    } else {
        route = [matches lastObject];
    }
    return route;
}
@end
