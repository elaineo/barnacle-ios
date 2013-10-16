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

@end

@implementation RouteDetailViewController


- (void)setRoute:(Route *)route
{
    _route = route;
    self.title = _route.routekey;
    self.locstart.text = route.locstart;
    self.locend.text = route.locend;
    self.locstart.alpha = 0.5;
    NSLog(route.locend);
    NSLog(@"setroute");
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
