//
//  Route.h
//  Barnacle
//
//  Created by Warren Mar on 10/15/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Route : NSManagedObject

@property (nonatomic, retain) NSString * routekey;
@property (nonatomic, retain) NSString * locend;
@property (nonatomic, retain) NSString * locstart;
@property (nonatomic) int32_t statusint;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * delivend;
@property (nonatomic, retain) NSString * posturl;

@end
