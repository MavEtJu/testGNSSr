//
//  Tools.h
//  TestGNSSr
//
//  Created by Edwin Groothuis on 28/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ToolsDelegate

- (void)didUpdateLocation:(CLLocation *)location;

@end

@interface Tools : NSObject

- (void)addDelegate:(id<ToolsDelegate>)d;

+ (float)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSString *)coordinate:(CLLocationDegrees)ll;

@end

extern Tools *tools;
