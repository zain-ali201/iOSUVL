//
//  LoginViewController.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "LoginViewController.h"
#import "ApiManager.h"
#import "DriverDO.h"
#import "AppDelegate.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    UIGestureRecognizer *tapper;
    NSMutableDictionary *serviceParams;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initalizeContent];
    
    #if (DEBUG)
    {
        _email.text = @"online@urbanvehiclelogistics.co.uk";
        _password.text = @"urban1";
    }
    #endif
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
}

#pragma mark Intializing the View
-(void)initalizeContent{
//    _email.text  = @"keith.bernard@urbanvehiclelogistics.co.uk";
//    _password.text = @"cam1234";
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

#pragma mark TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:_email]) {
        [_password becomeFirstResponder];
    }
    else
        [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark Email verification
-(BOOL)validateEmail:(NSString *)candidate {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

-(IBAction)loginPressed:(id)sender
{
//    _email.text = @"online@urbanvehiclelogistics.co.uk";
//    _password.text = @"urban1";
    NSLog(@"%@%@",_email.text,_password.text);
    if(![self validateEmail:_email.text] || [_password.text isEqualToString:@""])
    {
        [self showAlertView:nil message:@"Please fill out fields with some valid data."];
    }
    else{
        [self prepareServerCall];
    }
}

#pragma mark ServerCall
-(void)prepareServerCall
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:@"login" forKey:@"request"];
    [serviceParams setValue:@"driver" forKey:@"user_type"];
    [serviceParams setValue:_email.text forKey:@"user_email"];
    [serviceParams setValue:_password.text forKey:@"user_password"];
     [serviceParams setValue:token forKey:@"mobile_phone_id"];
    [self makeServerCall];
}

-(void)makeServerCall{
    [ApiManager getRequest:serviceParams success:^(id result){
        if([result objectForKey:@"error"] == nil){
            DriverDO *driver = [[DriverDO alloc] initWithDictionary:result];
            [[NSUserDefaults standardUserDefaults] setObject:driver.dId forKey:@"DriverID"];
            [[NSUserDefaults standardUserDefaults] setObject:driver.dapiKey forKey:@"ApiKey"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
        }
        else{
            NSString *err = [result objectForKey:@"error"];
            [self showAlertView:nil message:err];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark Show AlertView
-(void)showAlertView:(NSString *)tittle message:(NSString *)message{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:tittle
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Dismiss"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
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
