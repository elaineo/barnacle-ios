//
//  RoutesCDTVC.h
//  Barnacle
//
//  Created by Warren Mar on 10/14/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RoutesCDTVC : CoreDataTableViewController
- (IBAction)refresh;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
