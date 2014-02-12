//
//  AppNetUser.h
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#define APP_NET_DEFAULT_USER @"DefaultUser"

/*!
 * Thin model wrapper around SSKeychain to ensure security of the tokens.
 */
@interface AppNetUser : NSObject

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* accessToken;

- (void)save;

+ (NSArray *)allAccounts;
+ (AppNetUser *)accountForUsername:(NSString *)username;

+ (AppNetUser *)defaultUser;

@end
