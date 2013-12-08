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
#import "StandardAnnotation.h"

@interface TrackerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *updateIntervalDisplay;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property BOOL autoUpdateState;
@property (weak, nonatomic) IBOutlet UITextField *msg;
@property double interval;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UIStepper *intervalIncrementer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property CLLocation *lastLocation;
@property (weak, nonatomic) UITextField *activeField;
@end

@implementation TrackerViewController {
    CLLocationManager *locationManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"End Drive"
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}


- (IBAction)autoUpdateSwitch:(id)sender {
    UISwitch *stepper = (UISwitch *) sender;
    if ([stepper isOn]) {
        self.autoUpdateState = YES;
    } else {
        self.autoUpdateState = NO;
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
    NSLog(@"%1.0f", stepper.value);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    self.scrollView.contentSize=CGSizeMake(320,1000);
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    
    self.scrollView.scrollIndicatorInsets = contentInsets;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    NSLog(@"activefield");
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)updateLocation:(id)sender {
    NSLog(@"button press to update location");
    if ([CLLocationManager deferredLocationUpdatesAvailable]) {
        NSLog(@"deffered okay");
    } else {
        NSLog(@"deffered bad");
    }
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        
        NSLog(@"Background updates are available for the app.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }
    [locationManager startMonitoringSignificantLocationChanges];
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
        if (location) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks lastObject];
                NSDictionary *address = placemark.addressDictionary;
                NSArray *formattedAddress = [address valueForKey:@"FormattedAddressLines"];
                NSString *locstr = [formattedAddress componentsJoinedByString:@" "];
                [BarnacleRouteFetcher updateLocation: location locationString:locstr msg:self.msg.text];
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
