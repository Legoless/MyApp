//
//  StreamVC.h
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "AppNetUser.h"

/*!
 * Displays App.net unified stream
 */
@interface StreamVC : UITableViewController

/*!
 * App.net client instance that loads the stream
 */
@property (nonatomic, strong) ANKClient* client;

/*!
 * App.net user with valid access token
 */
@property (nonatomic, strong) AppNetUser* appNetUser;

@end
