//
//  RouteDetailViewController.m
//  Barnacle
//
//  Created by Warren Mar on 10/15/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "RouteDetailViewController.h"
#import "Route.h"

@interface RouteDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locstart;
@property (weak, nonatomic) IBOutlet UILabel *locend;
@property (weak, nonatomic) IBOutlet UILabel *statusValue;
@property (weak, nonatomic) IBOutlet UILabel *delivend;

@end

@implementation RouteDetailViewController



- (void)setRoute:(Route *)route
{
    _route = route;
    [self updateUI];
}

- (void) updateUI{
    self.title = self.route.routekey;
    self.locstart.text = self.route.locstart;
    self.locend.text = self.route.locend;
    self.statusValue.text =  [NSString stringWithFormat:@"%d", self.route.statusint];
    self.delivend.text = self.route.delivend;
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
