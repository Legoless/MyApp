//
//  PostTableViewCell.h
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
