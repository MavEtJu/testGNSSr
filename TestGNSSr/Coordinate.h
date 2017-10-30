//
//  Coordinate.h
//  TestGNSSr
//
//  Created by Edwin Groothuis on 30/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface Coordinate : NSObject

@property (nonatomic) CLLocationDegrees lat, lon;
@property (nonatomic) CLLocationDistance height;

@end
