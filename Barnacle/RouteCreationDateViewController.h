//
//  RouteCreationDateViewController.h
//  Barnacle
//
//  Created by Warren Mar on 11/28/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface RouteCreationDateViewController : UIViewController<UIActionSheetDelegate>
@property CLPlacemark* origin;
@property CLPlacemark* destination;
@end
