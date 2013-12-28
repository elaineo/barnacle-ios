//
//  ConfirmArrivalViewController.m
//  Barnacle
//
//  Created by Warren Mar on 12/27/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "ConfirmArrivalViewController.h"

@interface ConfirmArrivalViewController ()
@property (weak, nonatomic) IBOutlet UILabel *routeInfo;
@property (weak, nonatomic) IBOutlet UITextField *confirmCodeTextField;
@end

@implementation ConfirmArrivalViewController

- (IBAction)confirmCodePushed:(id)sender {
}

- (IBAction)submitPushed:(id)sender {
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
    self.title = @"Arrival";
    [self updateUI];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRoute:(Route *)route
{
    NSLog(@"confirm arrival route set");
    _route = route;
    [self updateUI];
}

- (void) updateUI
{
    self.routeInfo.text = self.route.locend;
    NSLog(self.route.locend);
}

@end
