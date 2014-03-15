//
//  TrackerViewController.h
//  Barnacle
//
//  Created by Warren Mar on 10/27/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface TrackerViewController : UIViewController<CLLocationManagerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDelegate>

@end
