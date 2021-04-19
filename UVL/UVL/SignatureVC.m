//
//  SignatureVC.m
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "SignatureVC.h"
#import "TESignatureView.h"
#import "UVLAppglobals.h"

@interface SignatureVC ()
{
    __weak IBOutlet TESignatureView *signtureView;
}
@end

@implementation SignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
}
-(void)home:(UIBarButtonItem *)sender
{
    [self.delegate sendSignatureBack:[signtureView getSignatureImage]];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)resetButtonPressed:(id)sender {
    [signtureView clearSignature];
}

-(IBAction)saveButtonPressed:(id)sender {
   // [[UVLAppglobals sharedAppGlobals] setSignatureImage:[signtureView getSignatureImage]];
    [self.delegate sendSignatureBack:[signtureView getSignatureImage]];
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
