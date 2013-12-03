//
//  RouteCreationDestinationViewController.m
//  Barnacle
//
//  Created by Warren Mar on 11/28/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteCreationDestinationViewController.h"
#import <MapKit/MapKit.h>
#import "RouteCreationDateViewController.h"
#import "StandardAnnotation.h"

@interface RouteCreationDestinationViewController ()
@property CLPlacemark *destination;
@property (weak, nonatomic) IBOutlet UILabel *locationDescription;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation RouteCreationDestinationViewController
@synthesize origin;

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
    self.title = @"Destination";
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(pushSelectDate)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)];
    [self.mapView addGestureRecognizer:tapRecognizer];

}

- (void)pushSelectDate
{
    [self performSegueWithIdentifier:@"pushSelectDate" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushSelectDate"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setOrigin:)]) {
            RouteCreationDateViewController *vc = [segue destinationViewController];
            [vc setOrigin: self.origin];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setDestination:)]) {
            RouteCreationDateViewController *vc = [segue destinationViewController];
            [vc setDestination: self.destination];
        }
        
    }
}

// Handle touch event
- (void)mapViewTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint pointTappedInMapView = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D geoCoordinatesTapped = [_mapView convertPoint:pointTappedInMapView toCoordinateFromView:_mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoCoordinatesTapped.latitude longitude:geoCoordinatesTapped.longitude];

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
    // Geocode
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
        }
        CLPlacemark *placemark = [placemarks lastObject];
        self.destination = placemark;
        NSDictionary *address = placemark.addressDictionary;
        NSArray *formattedAddress = [address valueForKey:@"FormattedAddressLines"];
        [placemark.addressDictionary description];
        self.locationDescription.text = [formattedAddress componentsJoinedByString:@"\n"];;
    }];
    for (id annotation in [self.mapView annotations]){
        [self.mapView removeAnnotation:annotation];
    }
    [self.mapView addAnnotation:[[StandardAnnotation alloc] initWithLocation:location]];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
