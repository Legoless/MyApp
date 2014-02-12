//
//  NSDate+Formatting.m
//  MyApp
//
//  Created by Dal Rupnik on 12/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

- (NSString *)readableTimeSinceNow
{
    NSTimeInterval time = [self timeIntervalSinceNow];
    
    time = fabs(round(time));
    
    long longTime = (long)time;
    
    // Seconds
    if (time < 60.0)
    {
        return [NSString stringWithFormat:@"%lds", (longTime % 60)];
    }
    // Minutes
    else if (time < 3600.0)
    {
        longTime = longTime / 60.0;
        
        return [NSString stringWithFormat:@"%ldm", longTime];
    }
    // Hours
    else if (time < (3600.0 * 24.0) )
    {
        longTime = longTime / (3600);
        
        return [NSString stringWithFormat:@"%ldh", longTime];
    }
    else
    {
        
        longTime = longTime / (3600 * 24.0);
        
        return [NSString stringWithFormat:@"%ldd", longTime];
    }
}

@end
