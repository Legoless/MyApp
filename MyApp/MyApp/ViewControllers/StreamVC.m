//
//  StreamVC.m
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <SVPullToRefresh/SVPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "StreamVC.h"

#import "NSDate+Formatting.h"
#import "PostTableViewCell.h"

@interface StreamVC ()

@property (nonatomic, strong) NSMutableArray* stream;

@property (nonatomic, strong) ANKAPIResponseMeta* responseMeta;

@end

@implementation StreamVC

//
// Lazy instantiation of stream array
//
- (NSMutableArray *)stream
{
    if (!_stream)
    {
        _stream = [NSMutableArray array];
    }
    
    return _stream;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^
    {
        [weakSelf loadPosts];
    }];
    
    [self loadPosts];
}

- (void)loadPosts
{
    // Handle pagination
    if (self.responseMeta)
    {
        //
        // Get last read ID.
        //
        
        if ([self.stream count])
        {
            ANKPost* post = [self.stream lastObject];
            
            self.client.pagination = [ANKPaginationSettings settingsWithSinceID:self.responseMeta.minID beforeID:post.postID count:10.0];
        }
    }
    
    //
    // Get posts
    //
    
    [self.client fetchUnifiedStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
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
        else
        {
            NSInteger streamCount = [self.stream count];
            
            [self.stream addObjectsFromArray:responseObject];
            self.responseMeta = meta;
            
            // Create index paths to insert
            NSMutableArray* indexPaths = [NSMutableArray array];
            
            for (NSInteger i = 0; i < [responseObject count]; i++)
            {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:streamCount + i inSection:0];
                
                [indexPaths addObject:indexPath];
            }
            
            //
            // Insert stuff to tableview
            //
            
            [self.tableView beginUpdates];
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView endUpdates];
            
            // Stop infinite scroll
            [self.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stream count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    if (!cell)
    {
        cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PostCell"];
    }
    
    ANKPost* post = self.stream[indexPath.row];
    
    cell.usernameLabel.text = post.user.username;
    cell.dateLabel.text = [post.createdAt readableTimeSinceNow];
    cell.contentTextView.text = post.text;
    cell.contentTextView.textColor = [UIColor whiteColor];
    
    NSURL* imageURL = [post.user.avatarImage URLForSize:cell.avatarImageView.frame.size];
    
    [cell.avatarImageView setImageWithURL:imageURL];
    
    return cell;
}

@end
