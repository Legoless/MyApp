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

/*!
 * Username of the App.net account
 */
@property (nonatomic, strong) NSString* username;

/*!
 * Access token to access App.net API
 */
@property (nonatomic, strong) NSString* accessToken;

/*!
 * Saves User to keychain
 */
- (void)save;

/*!
 * Deletes User from keychain
 */
- (void)deleteObject;

/*!
 * Returns all App.net accounts in keychain
 */
+ (NSArray *)allAccounts;

/*!
 * Returns App.net user for username in keychain
 *
 * @param Username string
 */
+ (AppNetUser *)accountForUsername:(NSString *)username;

/*!
 * Returns default App.net user
 */
+ (AppNetUser *)defaultUser;

@end
