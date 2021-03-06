//
//  RouteCreationViewController.m
//  Barnacle
//
//  Created by Warren Mar on 11/28/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteCreationViewController.h"
#import "RouteCreationDestinationViewController.h"
#import <MapKit/MapKit.h>
#import "StandardAnnotation.h"

@interface RouteCreationViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *locationDescription;
@property CLPlacemark* origin;
@end

@implementation RouteCreationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Origin";
	// Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = //[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:nil];
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(pushDestination)];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)];
    [self.mapView addGestureRecognizer:tapRecognizer];
}

- (void)pushDestination{
        [self performSegueWithIdentifier:@"pushSelectDestination" sender:self];
}

// Handle touch event
- (void)mapViewTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            /* equivalent to touchesBegan:withEvent: */
            break;
            
        case UIGestureRecognizerStateChanged:
            /* equivalent to touchesMoved:withEvent: */
            break;
            
        case UIGestureRecognizerStateEnded:
            /* equivalent to touchesEnded:withEvent: */
            break;
            
        case UIGestureRecognizerStateCancelled:
            /* equivalent to touchesCancelled:withEvent: */
            break;
            
        default:
            break;
    }
    CLLocation* location = [[CLLocation alloc] initWithLatitude:geoCoordinatesTapped.latitude longitude:geoCoordinatesTapped.longitude];    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
        }
        CLPlacemark *placemark = [placemarks lastObject];
        self.origin = placemark;
        NSDictionary *address = placemark.addressDictionary;
        NSArray *formattedAddress = [address valueForKey:@"FormattedAddressLines"];
        self.locationDescription.text = [formattedAddress componentsJoinedByString:@"\n"];;
    }];
    for (id annotation in [self.mapView annotations]){
        [self.mapView removeAnnotation:annotation];
    }
    [self.mapView addAnnotation:[[StandardAnnotation alloc] initWithLocation:location]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 if ([segue.identifier isEqualToString:@"pushSelectDestination"]) {
           if ([segue.destinationViewController respondsToSelector:@selector(setOrigin:)]) {
                 RouteCreationDestinationViewController *vc = [segue destinationViewController];
               [vc setOrigin: self.origin];
            }
      }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
