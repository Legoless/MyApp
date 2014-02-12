//
//  StreamVC.m
//  MyApp
//
//  Created by Dal Rupnik on 10/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <SVPullToRefresh/SVPullToRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <M13ProgressSuite/M13ProgressViewRing.h>

#import "StreamVC.h"

#import "NSDate+Formatting.h"
#import "PostTableViewCell.h"

@interface StreamVC ()

// Thread-Safe stream
@property (atomic, strong) NSMutableArray* stream;

@property (nonatomic, strong) ANKAPIResponseMeta* responseMeta;

@property (nonatomic, strong) UIImageView* glowImageView;

@property (nonatomic, strong) UIImageView* backgroundImageView;

@property (nonatomic, strong) NSTimer* streamTimer;

@property (nonatomic, strong) M13ProgressViewRing* ring;

@end

@implementation StreamVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.stream = [NSMutableArray array];
    
    //
    // Load first batch of posts
    //
    
    __unsafe_unretained typeof (self) weakSelf = self;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^
    {
        [weakSelf loadPosts];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //
    // Workaround for navigation segue
    //
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background2"]];
    
    // Fix the frame to mimic the entire background
    CGRect frame = self.backgroundImageView.frame;
    frame.origin.y -= 20.0;
    
    self.backgroundImageView.frame = frame;
    
    [self.view addSubview:self.backgroundImageView];
    
    //
    // Start timers and loading ring
    //
    
    self.streamTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadNewPosts:) userInfo:nil repeats:YES];
    
    if (![self.stream count])
    {
        self.ring = [[M13ProgressViewRing alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0 - 20.0, self.view.frame.size.height / 2.0 - 20.0, 40.0, 40.0)];
        self.ring.secondaryColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        self.ring.showPercentage = NO;
        self.ring.indeterminate = YES;
        
        [self.view addSubview:self.ring];
    }
    
    [self.tableView.infiniteScrollingView setCustomView:self.ring forState:SVInfiniteScrollingStateAll];
    
    [self loadPosts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    //
    // Put a slight gradient view on top
    //
    
    self.glowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient-glow"]];
    
    [self.navigationController.view addSubview:self.glowImageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.glowImageView removeFromSuperview];
    
    [self.streamTimer invalidate];
    self.streamTimer = nil;
}

- (void)loadNewPosts:(id)sender
{
    if (![self.stream count])
    {
        return;
    }
    
    ANKPost* post = [self.stream firstObject];
    
    self.client.pagination = [ANKPaginationSettings settingsWithSinceID:post.postID beforeID:nil count:10.0];
    
    //
    // Get posts
    //
    
    [self.client fetchUnifiedStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
        //NSLog(@"Response: %@", responseObject);
        
        responseObject = [responseObject filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDeleted = NO"]];
        
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
        else if ([responseObject count])
        {
            [self.ring removeFromSuperview];
            
            [self.stream insertObjects:responseObject atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [responseObject count])]];
            
            // Create index paths to insert
            NSMutableArray* indexPaths = [NSMutableArray array];

            for (NSInteger i = 0; i < [responseObject count]; i++)
            {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                
                [indexPaths addObject:indexPath];
            }

            //
            // Insert stuff to tableview
            //

            [self.tableView beginUpdates];

            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

            [self.tableView endUpdates];
        }
        
        [self refreshTimes];
    }];

}

- (void)refreshTimes
{
    //
    // Refreshes only time in all cells, most noticeable with seconds
    //
    
    for (NSInteger i = 0; i < [self.stream count]; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        PostTableViewCell* cell = (PostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        ANKPost* post = self.stream[i];
        
        cell.dateLabel.text = [post.createdAt readableTimeSinceNow];
    }
}

- (void)loadPosts
{
    //NSLog(@"Loading posts");
    
    // Handle pagination
    if (self.responseMeta)
    {
        //
        // Get last read ID.
        //
        
        if ([self.stream count])
        {
            ANKPost* post = [self.stream lastObject];
            
            //NSLog(@"Setting pagination at: SinceID: %@ BeforeID: %@", self.responseMeta.minID, post.postID);
            
            self.client.pagination = [ANKPaginationSettings settingsWithSinceID:nil beforeID:post.postID count:10.0];
        }
    }
    
    //
    // Get posts
    //
    
    [self.client fetchUnifiedStreamForCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
        responseObject = [responseObject filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDeleted = NO"]];
        
        //
        // There might be an invalid token in certain cases, pop just to make sure
        //
        
        if (error)
        {
            NSLog(@"Error: %@", error);
            
            //
            // Delete user's credentials
            //

            [self.appNetUser deleteObject];

            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        else
        {
            [self.ring removeFromSuperview];
            NSLog(@"Response: %@", responseObject);
            
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
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
            
            // Stop infinite scroll
            [self.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // Calculate size of row based on content text
    //
    
    ANKPost* post = self.stream[indexPath.row];
    
    CGSize size = [post.text boundingRectWithSize:CGSizeMake(231.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0 ] } context:nil].size;
    
    //NSLog(@"Size: %f", size.height);
    
    if (size.height > 20.0)
    {
        return size.height + 9.0 + 40.0;
    }
    
    return 80.0;
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
    
    //
    // Setup handle and username
    //
    
    NSMutableAttributedString* user = [[NSMutableAttributedString alloc] initWithString:post.user.name attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0], NSForegroundColorAttributeName : [UIColor whiteColor] } ];
    
    [user appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" @%@", post.user.username] attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0], NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.8] }]];
    
    //
    // Cell data
    //
    
    cell.usernameLabel.attributedText = user;
    cell.dateLabel.text = [post.createdAt readableTimeSinceNow];
    cell.contentTextView.text = post.text;
    cell.contentTextView.textColor = [UIColor whiteColor];
    cell.contentTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    cell.contentTextView.scrollEnabled = NO;
    cell.contentTextView.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:129.0 / 255.0 green:204.0 / 255.0 blue:255.0 / 255.0 alpha:1.0] };
    
    NSURL* imageURL = [post.user.avatarImage URLForSize:cell.avatarImageView.frame.size];
    
    cell.avatarImageView.layer.cornerRadius = 25.0;
    cell.avatarImageView.clipsToBounds = YES;
    cell.avatarImageView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.6] CGColor];
    cell.avatarImageView.layer.borderWidth = 1.0;
    
    [cell.avatarImageView setImageWithURL:imageURL];
    
    return cell;
}

@end
