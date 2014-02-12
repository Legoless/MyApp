//
//  StreamVC.m
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "StreamVC.h"

@interface StreamVC ()

@property (nonatomic, strong) NSArray* stream;

@end

@implementation StreamVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.client fetchUnifiedStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
        NSLog(@"Response: %@ Error: %@", responseObject, error);
        
        //
        // There might be an invalid token in certain cases, pop just to make sure
        //
        
        if (error)
        {
            //
            // Delete user's credentials
            //
            [self.appNetUser deleteObject];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }];
}

@end
