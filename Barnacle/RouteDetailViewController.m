//
//  RouteDetailViewController.m
//  Barnacle
//
//  Created by Warren Mar on 10/15/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "Route.h"
#import "BarnacleRouteFetcher.h"
#import "RoutesCDTVC.h"

@interface RouteDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locstart;
@property (weak, nonatomic) IBOutlet UILabel *locend;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *delivend;
@property (weak, nonatomic) IBOutlet UISwitch *active;

@end

@implementation RouteDetailViewController


- (void)setRoute:(Route *)route
{
    _route = route;
    [self updateUI];
}

- (void) updateUI{
//    self.title = self.route.routekey;
    self.title = @"Details";
    self.locstart.text = self.route.locstart;
    self.locend.text = self.route.locend;
    switch (self.route.statusint) {
        case 0:
            self.statusLabel.text = @"Route is active";
            break;
        case 1:
            self.statusLabel.text = @"Route is inactive";
            break;
        default:
            break;
    }
    if (self.route.statusint <= 1) {
        [self active].hidden = NO;
    } else {
        [self active].hidden = YES;
    }
    if (self.route.statusint == 0) {
        self.active.on = YES;
    } else {
        self.active.on = NO;
    }
    self.delivend.text = self.route.delivend;
}

- (IBAction)changeStatus:(UISwitch*)sender {
    if (sender.on) {
        [self route].statusint = 0;
        self.route.status = @"Active";
    } else {
        [self route].statusint = 1;
        self.route.status = @"Inactive";
    }
    [self updateUI];
    dispatch_queue_t fetchQ = dispatch_queue_create("Status Update", NULL);
    dispatch_async(fetchQ, ^{
        [BarnacleRouteFetcher switchStatus: self.route.routekey];
    });
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
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(promptDelete)];
}

- (IBAction)openTrackerPage:(id)sender {
    NSURL *url = [NSURL URLWithString: [@"http://www.gobarnacle.com" stringByAppendingString:self.route.posturl]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)promptDelete {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Delete"
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex){
        case 0:{
            NSLog(@"delete %@", self.route.routekey);
            dispatch_queue_t fetchQ = dispatch_queue_create("Status Update", NULL);
            dispatch_async(fetchQ, ^{
                [BarnacleRouteFetcher deleteRoute: self.route.routekey ];
                            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                                NSArray *vcs = self.navigationController.viewControllers;
                                UIViewController *vc = [vcs objectAtIndex: 1];
                                RoutesCDTVC * rcv = (RoutesCDTVC *)vc;
                                [rcv refresh];

                                
                            });
            });
            break;
        }
        case 1:
            NSLog(@"cancel");
            break;
        default:
            break;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
