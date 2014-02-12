//
//  PostTableViewCell.m
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    //
    // Get rid of the padding/margin in UITextView, new iOS 7 method.
    //
    
    self.contentTextView.textContainer.lineFragmentPadding = 0.0;
    self.contentTextView.textContainerInset = UIEdgeInsetsZero;
    
}

@end
