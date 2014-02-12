//
//  NSDate+Formatting.h
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)

/*!
 * Returns human readable time since now, similar to TweetBot
 */
- (NSString *)readableTimeSinceNow;

@end
