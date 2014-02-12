//
//  PostTableViewCell.h
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * Table view cell representing a single post
 */
@interface PostTableViewCell : UITableViewCell

/*!
 * Displays date or time in right corner
 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

/*!
 * Displays username and/or handle
 */
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

/*!
 * Displays avatar of user
 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

/*!
 * Displays content text with links
 */
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
