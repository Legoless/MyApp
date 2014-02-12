//
//  AppNetUser.m
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "AppNetUser.h"
#import <SSKeychain/SSKeychain.h>

#define APP_NET_SERVICE @"App.net"

@implementation AppNetUser

- (NSString *)username
{
    //
    // Lazy load default username
    //
    
    if (!_username)
    {
        _username = APP_NET_DEFAULT_USER;
    }
    
    return _username;
}

- (void)save
{
    //
    // Check if we are valid
    //
    
    if (![self.username length] || ![self.accessToken length])
    {
        return;
    }
    
    NSError* error;
    
    [SSKeychain setPassword:self.accessToken forService:APP_NET_SERVICE account:self.username error:&error];
}

+ (NSArray *)allAccounts
{
    NSArray* appNetAccounts = [SSKeychain accountsForService:APP_NET_SERVICE];
    
    NSMutableArray* accounts = [NSMutableArray array];
    
    //
    // Create objects for all accounts
    //
    
    for (NSDictionary* account in appNetAccounts)
    {
        AppNetUser* user = [[AppNetUser alloc] init];
        user.username = account[kSSKeychainAccountKey];
        user.accessToken = [SSKeychain passwordForService:APP_NET_SERVICE account:user.username];
        
        [accounts addObject:user];
    }
    
    return [accounts copy];
}

+ (AppNetUser *)defaultUser
{
    return [self accountForUsername:APP_NET_DEFAULT_USER];
}

+ (AppNetUser *)accountForUsername:(NSString *)username
{
    NSError* error;
    
    NSString* password = [SSKeychain passwordForService:APP_NET_SERVICE account:username error:&error];
    
    if (password)
    {
        AppNetUser* user = [[AppNetUser alloc] init];
        user.username = username;
        user.accessToken = password;
        
        return user;
    }
    
    return nil;
}

@end
