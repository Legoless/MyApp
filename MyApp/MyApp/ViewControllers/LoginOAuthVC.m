//
//  LoginOAuthVC.m
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "LoginOAuthVC.h"
#import "StreamVC.h"
#import "AppNetUser.h"

@interface LoginOAuthVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LoginOAuthVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setBackgroundImage:[UIImage imageNamed:@"background2"]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //
    // Check for login, redirect immediately if available
    //
    
    AppNetUser* user = [AppNetUser defaultUser];
    
    ANKAuthScope requestedScopes = ANKAuthScopeStream;
    
    // Create a URLRequest to kick off the auth process...
    NSURLRequest *request = [[ANKClient sharedClient] webAuthRequestForClientID:APP_NET_CLIENT_ID redirectURI:@"myapp://auth" authScopes:requestedScopes state:nil appStoreCompliant:YES];
    
    if (user.accessToken)
    {
        id streamVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamVC"];

        [ANKClient sharedClient].accessToken = user.accessToken;

        [streamVC setClient:[ANKClient sharedClient]];
        [streamVC setAppNetUser:user];
        
        [self.navigationController pushViewController:streamVC animated:NO];
        
        return;
    }
    
    self.webView.delegate = self;
    
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"Loading Request: %@", request);
    
    //
    // Parse request, could've used a library here, but not necessary.
    //
    
    NSString* requestURL = [request.URL description];
    
    // Check for correct prefix
    if ([requestURL hasPrefix:@"myapp://auth"])
    {
        //
        // Parse out code
        //
        
        NSRange codeRange = [requestURL rangeOfString:@"code="];
        
        if (codeRange.location != NSNotFound)
        {
            // Add 5, because 'code=' is 5 characters long
            NSString* code = [requestURL substringFromIndex:codeRange.location + 5];
            
            //
            // Make sure there is no parameters after the code
            //
            
            NSRange codeRange = [code rangeOfString:@"&"];
            
            if (codeRange.location != NSNotFound)
            {
                code = [code substringToIndex:codeRange.location];
            }
            
            ANKAuthScope requestedScopes = ANKAuthScopeStream;
            
            // Create a URLRequest to kick off the auth process...
            [[ANKClient sharedClient] webAuthRequestForClientID:APP_NET_CLIENT_ID redirectURI:@"myapp://auth" authScopes:requestedScopes state:nil appStoreCompliant:YES];
            
            [ANKClient sharedClient].webAuthCompletionHandler = ^(BOOL success, NSError* error)
            {
                if (success)
                {
                    //
                    // Save token to default user for now
                    //
                    
                    AppNetUser* user = [[AppNetUser alloc] init];
                    user.username = APP_NET_DEFAULT_USER;
                    user.accessToken = [ANKClient sharedClient].accessToken;
                    
                    [user save];
                    
                    //
                    // Perform Segue to Stream view controller, but since this method could be called on another thread,
                    // need to make sure segue happens back on main thread.
                    //
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [self performSegueWithIdentifier:@"StreamSegue" sender:self];
                    });
                }
                else
                {
                    NSLog(@"Error authenticating: %@", error);
                }
            };

            
            [[ANKClient sharedClient] authenticateWebAuthAccessCode:code forClientID:APP_NET_CLIENT_ID clientSecret:APP_NET_CLIENT_SECRET];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"StreamVC"])
    {
        //
        // Send shared client to StreamVC, since there is only one user at the moment.
        //
        
        [segue.destinationViewController setClient:[ANKClient sharedClient]];
        [segue.destinationViewController setAppNetUser:[AppNetUser defaultUser]];
    }
}

@end
