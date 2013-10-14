//
//  Route.h
//  Barnacle
//
//  Created by Warren Mar on 10/13/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Route : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * locstart;
@property (nonatomic, retain) NSString * locend;

@end
