//
//  LoginOAuthVC.m
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "LoginOAuthVC.h"
#import "StreamVC.h"

@interface LoginOAuthVC () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LoginOAuthVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;

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
    NSURLRequest *request = [[ANKClient sharedClient] webAuthRequestForClientID:APP_NET_CLIENT_ID redirectURI:@"myapp://auth" authScopes:requestedScopes state:nil appStoreCompliant:YES];
    
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
            
            [[ANKClient sharedClient] authenticateWebAuthAccessCode:code forClientID:APP_NET_CLIENT_ID clientSecret:APP_NET_CLIENT_SECRET];
            
            //
            // Perform Segue to Stream view controller, but since this method could be called on another thread,
            // need to make sure segue happens back on main thread.
            //
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self performSegueWithIdentifier:@"StreamVC" sender:self];
            });

            
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"StreamVC"])
    {
    }
}

@end
