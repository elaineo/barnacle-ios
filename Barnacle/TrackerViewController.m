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

@interface TrackerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *updateIntervalDisplay;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property BOOL autoUpdateState;
@property double interval;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property BOOL defferingUpdates;
@property (weak, nonatomic) IBOutlet UIStepper *intervalIncrementer;

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
        self.updateIntervalDisplay.text = [NSString stringWithFormat:@"update every %1.0f minutes", self.interval];
        [self.autoSwitch setOn:YES];
    } else {
        self.updateIntervalDisplay.text = @"Auto Update Off";
        [self.autoSwitch setOn:NO];
    }
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


- (IBAction)changeUpdateInterval:(id)sender {
    UIStepper *stepper = (UIStepper *) sender;
    self.interval = stepper.value;
    [self updateIntervalDisplayUI];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:stepper.value forKey:@"autoUpdateLocationInterval"];
    [defaults synchronize];

    NSLog(@"%1.0f", stepper.value);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Grab user defaults
    NSUserDefaults *fetchDefaults = [NSUserDefaults standardUserDefaults];
    self.autoUpdateState = [fetchDefaults boolForKey:@"autoUpdateLocation"];
    self.interval = [fetchDefaults doubleForKey:@"autoUpdateLocationInterval"];
    [self.intervalIncrementer setValue:self.interval];
    [self updateIntervalDisplayUI];
    self.defferingUpdates = NO;
    //
    locationManager = [[CLLocationManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;// kCLLocationAccuracyThreeKilometers;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    [locationManager startUpdatingLocation];
    
    NSTimeInterval time = 10.0;
    [locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:time];
    locationManager.pausesLocationUpdatesAutomatically = NO;
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
    CLLocation* location = (CLLocation*)[locations lastObject];
    NSLog([location description]);
    NSLog(@"update locations");
    [BarnacleRouteFetcher updateLocation: location];
    if (!self.defferingUpdates) {
            NSTimeInterval time = 10.0;
        [locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:time];
        self.defferingUpdates = YES;
    }
}

- (void)locationManagerDidPauseLocationUpdates{
    NSLog(@"pause");
}
- (void) locationManagerDidResumeLocationUpdates{
    NSLog(@"resume");
}


- (void) locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    self.defferingUpdates = NO;
    switch ([error code]) {
        case kCLErrorLocationUnknown:
            NSLog(@"unknonw");
            break;
        case kCLErrorDenied:
            NSLog(@"denied");
            break;
        case kCLErrorDeferredCanceled:
            NSLog(@"cancel");
            break;
        default:
            NSLog(@"default error");
            break;
    }
}

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
