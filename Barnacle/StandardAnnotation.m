//
//  StandardAnnotation.m
//  Barnacle
//
//  Created by Warren Mar on 12/2/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "StandardAnnotation.h"



@implementation StandardAnnotation
@synthesize location;
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
-(id)initWithLocation: (CLLocation*) loc {
    self = [super init];
    if (self) {
        self.location = loc;
    }
    return self;
}

-(CLLocationCoordinate2D) coordinate
{
    return location.coordinate;
}
@end
