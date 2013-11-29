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

@interface RouteCreationViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationCoordinate2D origin;
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
    self.origin = geoCoordinatesTapped;
    NSLog(@"%f", geoCoordinatesTapped.latitude);
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
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        NSLog(@"prepare for segue");
 if ([segue.identifier isEqualToString:@"pushSelectDestination"]) {
           if ([segue.destinationViewController respondsToSelector:@selector(setOrigin:)]) {
                NSLog(@"preform");
                 RouteCreationDestinationViewController *vc = [segue destinationViewController];
                vc.origin = self.origin;
            }
      }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
