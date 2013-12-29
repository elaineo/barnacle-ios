//
//  ConfirmArrivalViewController.m
//  Barnacle
//
//  Created by Warren Mar on 12/27/13.
//  Copyright (c) 2013 Warren Mar. All rights reserved.
//

#import "ConfirmArrivalViewController.h"
#import "BarnacleRouteFetcher.h"

@interface ConfirmArrivalViewController ()
@property (weak, nonatomic) IBOutlet UILabel *routeInfo;
@property (weak, nonatomic) IBOutlet UITextField *confirmCodeTextField;
@end

@implementation ConfirmArrivalViewController

- (IBAction)confirmCodePushed:(id)sender {
    if ([BarnacleRouteFetcher trackConfirm:self.route.routekey withCode:self.confirmCodeTextField.text] == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delivery"
                                                        message:@"Delivery confirmed!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delivery"
                                                        message:@"Wrong Code!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)submitPushed:(id)sender {
    dispatch_queue_t fetchQ = dispatch_queue_create("Send Confirm", NULL);
    dispatch_async(fetchQ, ^{
        NSString* status = [BarnacleRouteFetcher trackSubmit:self.route.routekey];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delivery"
                                                            message:status
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

            [self.navigationController popViewControllerAnimated:YES];
        });
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
    self.title = @"Arrival";
    self.confirmCodeTextField.delegate = self;
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRoute:(Route *)route
{
    _route = route;
    [self updateUI];
}

- (void) updateUI
{
    self.routeInfo.text = self.route.locend;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
