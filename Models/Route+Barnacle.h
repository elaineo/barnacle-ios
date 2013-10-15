//
//  Route+Barnacle.h
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "Route.h"

@interface Route (Barnacle)
+ (Route*) routeWithBarnacleInfo:(NSDictionary*) routeDictionary inManagedObjectConext:(NSManagedObjectContext*) context;
@end
