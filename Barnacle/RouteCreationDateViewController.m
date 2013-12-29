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
#import <FacebookSDK/FacebookSDK.h>
@interface RouteCreationDateViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property BOOL canFBShare;

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
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:@"https://example.com/book/Snow-Crash.html"];
    self.canFBShare = [FBDialogs canPresentShareDialogWithParams:params];
    if (self.canFBShare) {
        NSLog(@"can share");
    }
}

- (void)promptCreate {
    if (self.canFBShare) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Create and Share"
                                                  otherButtonTitles:@"Create", nil];
        [sheet showInView:self.view];
        
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Create"
                                                  otherButtonTitles:nil];
        [sheet showInView:self.view];
    }
}

- (void) createAndShare
{
    NSDictionary* response = [BarnacleRouteFetcher createRouteFrom:self.origin to:self.destination by:self.datePicker.date];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gobarnacle.com%@", [[response objectForKey:@"route"] objectForKey:@"post_url"]]];
    NSLog([url description]);
    [FBDialogs presentShareDialogWithLink:url
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSArray *vcs = self.navigationController.viewControllers;
                                          UIViewController *vc = [vcs objectAtIndex: 1];
                                          [self.navigationController popToViewController:vc animated:YES];
                                          RoutesCDTVC * rcv = (RoutesCDTVC *)vc;
                                          [rcv refresh];

                                      }
                                  }];
    
}

- (void) create {
    [BarnacleRouteFetcher createRouteFrom:self.origin to:self.destination by:self.datePicker.date];
    NSArray *vcs = self.navigationController.viewControllers;
    UIViewController *vc = [vcs objectAtIndex: 1];
    [self.navigationController popToViewController:vc animated:YES];
    RoutesCDTVC * rcv = (RoutesCDTVC *)vc;
    [rcv refresh];
}

- (void) cancel {
    NSArray *vcs = self.navigationController.viewControllers;
    UIViewController *vc = [vcs objectAtIndex: 1];
    [self.navigationController popToViewController:vc animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex){
        case 0:{
            if (self.canFBShare) {
                [self createAndShare];
            } else {
                [self create];
            }
            break;
        }
        case 1:
        {
            if (self.canFBShare) {
                [self create];
            } else {
                [self cancel];
            }
            break;
        }
        case 2:
            [self cancel];
            break;
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
