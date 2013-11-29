//
//  RouteCreationDestinationViewController.m
//  Barnacle
//
//  Created by Warren Mar on 11/28/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteCreationDestinationViewController.h"
#import <MapKit/MapKit.h>

@interface RouteCreationDestinationViewController ()
//@property CLLocationCoordinate2D origin;

@end

@implementation RouteCreationDestinationViewController
@synthesize origin = _origin;

- (void)setOrigin:(CLLocationCoordinate2D)origin
{
    _origin = origin;
    NSLog(@"set origin");
}

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
    NSLog(@"%f", self.origin.latitude);
}

- (void)pushSelectDate
{
    [self performSegueWithIdentifier:@"pushSelectDate" sender:self];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
