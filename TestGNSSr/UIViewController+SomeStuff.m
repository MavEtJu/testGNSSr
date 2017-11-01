//
//  ViewController.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 1/11/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "UIViewController+SomeStuff.h"

@implementation UIViewController (SomeStuff)

- (CGRect)viewFrame
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    NSInteger h0 = [UIApplication sharedApplication].statusBarFrame.size.height;
    NSInteger h1 = self.navigationController.navigationBar.frame.size.height;
    NSInteger h2 = self.tabBarController.tabBar.frame.size.height;
    frame = CGRectMake(frame.origin.x, frame.origin.y + h0 + h1, frame.size.width, frame.size.height - h2 - h1 - h0);
    return frame;
}

- (CGFloat)viewWidth
{
    return [self viewFrame].size.width;
}

- (CGFloat)viewHeight
{
    return [self viewFrame].size.height;
}

@end
