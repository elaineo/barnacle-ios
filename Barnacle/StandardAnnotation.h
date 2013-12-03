//
//  StandardAnnotation.h
//  Barnacle
//
//  Created by Warren Mar on 12/2/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface StandardAnnotation : NSObject<MKAnnotation>
@property CLLocation* location;
-(id)initWithLocation: (CLLocation*) loc;
@end
