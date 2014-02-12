//
//  LoginVC.m
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController)
    {
        [self.navigationController setBackgroundImage:[UIImage imageNamed:@"background1"] animated:NO];
    }
    
    self.usernameTextField.layer.cornerRadius = 5.0;
    self.passwordTextField.layer.cornerRadius = 5.0;
    
    //
    // TODO: Add paddings for UITextField's
    //
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //
    // Should give up keyboard when we return.
    //
    
    [textField resignFirstResponder];
    [textField endEditing:YES];
    
    return YES;
}

- (IBAction)loginButtonTap:(UIButton *)sender
{
    ANKAuthScope requestedScopes = ANKAuthScopeStream;
    
    id handler = ^(BOOL success, NSError *error)
    {
        if (success)
        {
            NSLog(@"we are authenticated and ready to make API calls!");
        }
        else
        {
            NSLog(@"could not authenticate, error: %@", error);
        }
    };
    
    [ANKClient sharedClient].webAuthCompletionHandler = handler;
    
    // create a URLRequest to kick off the auth process...
    NSURLRequest *request = [[ANKClient sharedClient] webAuthRequestForClientID:@"xxxxxx"
                                                                    redirectURI:@"myapp://auth"
                                                                     authScopes:requestedScopes
                                                                          state:nil
                                                              appStoreCompliant:YES];
    
    // authenticate, calling the handler block when complete
    /*[[ANKClient sharedClient] authenticateUsername:self.usernameTextField.text
                                          password:self.passwordTextField.text
                                          clientID:APP_NET_CLIENT_ID
                               passwordGrantSecret:APP_NET_CLIENT_TOKEN
                                        authScopes:requestedScopes
                                 completionHandler:handler];*/
    
    UIViewController* authController = [[ANKOAuthViewController alloc] initWithWebAuthRequest:request client:[ANKClient sharedClient] completion:^(ANKClient *authedClient, NSError *error, ANKOAuthViewController *controller)
    {
        
    }];
}

@end
