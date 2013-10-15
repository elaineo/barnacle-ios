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
            NSLog(@"newA");
    Route *route = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Route"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"locstart" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"key = %@", [routeDictionary[BARNACLE_ROUTE_KEY] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!context){
        NSLog(@"null context");
    }
    if (!matches || ([matches count] > 1) ){
        NSLog(@"error");
        NSLog([error description]);
        // handle error
    } else if (![matches count]) {
        NSLog(@"new");
        route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:context];
        route.key = routeDictionary[BARNACLE_ROUTE_KEY];
        route.locstart = routeDictionary[BARNACLE_LOC_START];
        route.locend = routeDictionary[BARNACLE_LOC_END];
    } else {
        route = [matches lastObject];
    }
    NSLog([route.key description]);
    NSLog([route description]);
    return route;
}
@end
