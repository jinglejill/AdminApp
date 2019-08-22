//
//  MainMenuViewController.m
//  AdminApp
//
//  Created by Thidaporn Kijkamjai on 27/6/2562 BE.
//  Copyright © 2562 Jummum Tech. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goToBranchList:(id)sender
{
    [self performSegueWithIdentifier:@"segBranchList" sender:self];
}
@end
