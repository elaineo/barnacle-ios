//
//  RouteDetailViewController.h
//  Barnacle
//
//  Created by Warren Mar on 10/15/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface RouteDetailViewController : UIViewController<UIActionSheetDelegate>

@property (nonatomic, strong) Route *route;

@end
