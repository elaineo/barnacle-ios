//
//  TrackerViewController.m
//  Barnacle
//
//  Created by Warren Mar on 10/27/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "TrackerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BarnacleRouteFetcher.h"
#import "ImageUtils.h"
#import "BarnacleAppDelegate.h"
#import "StandardAnnotation.h"
#import "UIKit/UIKit.h"

@interface TrackerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateIntervalDisplay;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property BOOL autoUpdateState;
@property BOOL sendMessageLock;
@property (weak, nonatomic) IBOutlet UITextField *msg;
@property double interval;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *intervalIncrementer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property CLLocation *lastLocation;
@property NSString* imageLink;
@property (weak, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end

@implementation TrackerViewController {
    CLLocationManager *locationManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sendMessageLock = false;
        self.imageLink = nil;
    }
    return self;
}

- (void) updateIntervalDisplayUI {
    if (self.autoUpdateState) {
        NSDictionary *intervalDict = [BarnacleRouteFetcher getIntervalDictionary];
        NSString *t = [intervalDict objectForKey:[NSNumber numberWithDouble:self.interval]];
//        intervalDict[[[NSNumber numberWithDouble:self.interval] integerValue]];
        self.updateIntervalDisplay.text = [NSString stringWithFormat:@"update every %@", t];
        [self.autoSwitch setOn:YES];
    } else {
        self.updateIntervalDisplay.text = @"Auto Update Off";
        [self.autoSwitch setOn:NO];
    }
}

- (IBAction)endDrive:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to confirm your arrival?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Confirm"
                                              otherButtonTitles:@"No, Just End Drive", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex){
        case 0:{
            [self performSegueWithIdentifier:@"pushConfirm" sender:self];
            break;
        }
        case 1:
        {
            dispatch_queue_t fetchQ = dispatch_queue_create("Status Update", NULL);
            dispatch_async(fetchQ, ^{
                [BarnacleRouteFetcher endDrive];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            });

            break;
        }
        default:
            break;
    }

}

- (IBAction)autoUpdateSwitch:(id)sender {
    UISwitch *stepper = (UISwitch *) sender;
    BarnacleAppDelegate* appdelegate = (BarnacleAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([stepper isOn]) {
        self.autoUpdateState = YES;
        [appdelegate.locationManager startMonitoringSignificantLocationChanges];
    } else {
        self.autoUpdateState = NO;
        [appdelegate.locationManager stopMonitoringSignificantLocationChanges];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[stepper isOn] forKey:@"autoUpdateLocation"];
    [defaults synchronize];
    [self updateIntervalDisplayUI];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (IBAction)changeUpdateInterval:(id)sender {
    UIStepper *stepper = (UIStepper *) sender;
    self.interval = stepper.value;
    [self updateIntervalDisplayUI];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [BarnacleRouteFetcher getIntervalValueDictionary];
    double intervalSeconds = [dict[[NSNumber numberWithDouble:self.interval]] doubleValue];
    [defaults setDouble:self.interval forKey:@"autoUpdateLocationInterval"];
    [defaults setDouble:intervalSeconds forKey:@"autoUpdateLocationIntervalTime"];
    [defaults synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    // Grab user defaults
    NSUserDefaults *fetchDefaults = [NSUserDefaults standardUserDefaults];
    self.autoUpdateState = [fetchDefaults boolForKey:@"autoUpdateLocation"];
    self.interval = [fetchDefaults doubleForKey:@"autoUpdateLocationInterval"];
    [self.intervalIncrementer setValue:self.interval];
    [self updateIntervalDisplayUI];
    //
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]
                     CGRectValue].size;
    // 64.0 pixels for navigation bar
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    
    self.scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible: CGRectMake(0, 1500, 320, 500) animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
   [self.scrollView scrollRectToVisible:    CGRectMake(0, 0, 320, 500) animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)updateLocation:(id)sender {
//    NSLog(@"button press to update location");
//    if ([CLLocationManager deferredLocationUpdatesAvailable]) {
//        NSLog(@"deffered okay");
//    } else {
//        NSLog(@"deffered bad");
//    }
//    
//    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
//        
//        NSLog(@"Background updates are available for the app.");
//    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
//    {
//        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
//    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
//    {
//        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
//    }
    self.sendMessageLock = false;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"tracker");
    CLLocation* location = (CLLocation*)[locations lastObject];
    if (location && !self.sendMessageLock) {
        self.sendMessageLock = true;
        NSString* message = self.msg.text;
        if (self.imageLink) {
            message = self.imageLink;
            self.imageLink = nil;
        }
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSDictionary *address = placemark.addressDictionary;
            NSArray *formattedAddress = [address valueForKey:@"FormattedAddressLines"];
            NSString *locstr = [formattedAddress componentsJoinedByString:@" "];
            
            dispatch_queue_t fetchQ = dispatch_queue_create("Tracker Message", NULL);
            dispatch_async(fetchQ, ^{
                [BarnacleRouteFetcher updateLocation: location locationString:locstr msg:message];                        dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tracker"
                                                                    message:@"Message Sent!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                });
            });
        }];
        
    }
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.25;
    span.longitudeDelta = 0.25;
    
    region.span = span;
    region.center = location.coordinate;
    for (id annotation in [self.mapView annotations]){
        [self.mapView removeAnnotation:annotation];
    }
    [self.mapView addAnnotation:[[StandardAnnotation alloc] initWithLocation:location]];

    
    [[self mapView] setRegion:region animated:YES];
    [locationManager stopUpdatingLocation];
    
}

- (void)locationManagerDidPauseLocationUpdates{
    NSLog(@"pause");
}
- (void) locationManagerDidResumeLocationUpdates{
    NSLog(@"resume");
}

- (IBAction)takePhoto:(id)sender {
    @try
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;        

        [self presentViewController:picker animated:YES completion:nil];
    }
    @catch (NSException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is not available  " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Send Image");
    UIImage* image = (UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [ImageUtils imageWithImage:image scaledToDimension:1280.0];
    
  //
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//     NSData *imageData = UIImagePNGRepresentation(image);
//    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[imageData length]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add image data
    NSString* FileParamConstant = @"file";

    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL i
    NSString *uploadUrl = [BarnacleRouteFetcher imageUploadUrl];
    [request setURL:[NSURL URLWithString:uploadUrl]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    NSDictionary* jsonReponse = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:kNilOptions
                                 error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

    self.imageLink = [jsonReponse valueForKey:@"url"];
    self.sendMessageLock = false;
    [locationManager startUpdatingLocation];
    

//
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    if (connection) {
//
//        // response data of the request
//    }

//
    [self dismissViewControllerAnimated:YES completion:nil];
}





//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    // Append the new data to receivedData.
//    // receivedData is an instance variable declared elsewhere.
//    NSError* error;
//    
//    NSDictionary* jsonReponse = [NSJSONSerialization
//                                 JSONObjectWithData:data
//                                 options:kNilOptions
//                                 error:&error];
//    NSLog([error description]);
//    NSLog([jsonReponse valueForKey:@"url"]);
//    self.imageLink = [jsonReponse valueForKey:@"url"];
//    self.sendMessageLock = false;
//    [locationManager startUpdatingLocation];
//
//}
//



//-(NSURLRequest *)connection:(NSURLConnection *)connection
//            willSendRequest:(NSURLRequest *)request
//           redirectResponse:(NSURLResponse *)redirectResponse {
//    if (redirectResponse) {
//        NSLog(@"AAA");
//    }
//    return request;
//}

//- (void) locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
//{
//    NSLog(@"finish differ");
//    switch ([error code]) {
//        case kCLErrorLocationUnknown:
//            NSLog(@"unknonw");
//            break;
//        case kCLErrorDenied:
//            NSLog(@"denied");
//            break;
//        case kCLErrorDeferredCanceled:
//            NSLog(@"cancel");
//            break;
//        default:
//            NSLog(@"default error");
//            break;
//    }
//}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    NSLog(@"didUpdateToLocation: %@", newLocation);
//    CLLocation *currentLocation = newLocation;
//    
//    if (currentLocation != nil) {
//        self.longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
//        self.latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
//    }
//    [BarnacleRouteFetcher updateLocation: currentLocation];
//    //
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.25;
//    span.longitudeDelta = 0.25;
//
//    region.span = span;
//    region.center = currentLocation.coordinate;
//    [[self mapview] setRegion:region animated:YES];
//}

@end
