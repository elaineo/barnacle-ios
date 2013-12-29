//
//  RouteCreationDateViewController.m
//  Barnacle
//
//  Created by Warren Mar on 11/28/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteCreationDateViewController.h"
#import "BarnacleRouteFetcher.h"
#import "RoutesCDTVC.h"
#import "StandardAnnotation.h"
@interface RouteCreationDateViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation RouteCreationDateViewController

@synthesize origin;
@synthesize destination;

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
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(promptCreate)];
    [self.datePicker setMinimumDate:[[NSDate alloc] init]];
    [self.mapView addAnnotation:[[StandardAnnotation alloc] initWithLocation: self.origin.location]];
    [self.mapView addAnnotation:[[StandardAnnotation alloc] initWithLocation: self.destination.location]];

}

- (void)promptCreate {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Create"
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"action sheet");
    switch(buttonIndex){
        case 0:{
            [BarnacleRouteFetcher createRouteFrom:self.origin to:self.destination by:self.datePicker.date];
            NSArray *vcs = self.navigationController.viewControllers;
            UIViewController *vc = [vcs objectAtIndex: 1];
            [self.navigationController popToViewController:vc animated:YES];
            RoutesCDTVC * rcv = (RoutesCDTVC *)vc;
            [rcv refresh];
            break;
        }
        case 1:
        {
            NSArray *vcs = self.navigationController.viewControllers;
            UIViewController *vc = [vcs objectAtIndex: 1];
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
