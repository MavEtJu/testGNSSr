//
//  Tools.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 28/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Tools.h"
#import <CoreLocation/CoreLocation.h>

@interface Tools () <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *LM;
@property (nonatomic, retain) NSMutableArray *delegates;

@end

@implementation Tools

- (instancetype)init
{
    self = [super init];

    self.delegates = [NSMutableArray arrayWithCapacity:2];

    self.LM = [[CLLocationManager alloc] init];
    [self.LM  requestWhenInUseAuthorization];
    self.LM.distanceFilter = kCLDistanceFilterNone;
    self.LM.desiredAccuracy = kCLLocationAccuracyBest;
    self.LM.delegate = self;
    [self.LM startUpdatingLocation];

    return self;
}

- (void)addDelegate:(id<ToolsDelegate>)d
{
    [self.delegates addObject:d];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [locations enumerateObjectsUsingBlock:^(CLLocation * _Nonnull location, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.delegates enumerateObjectsUsingBlock:^(id<ToolsDelegate> _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
            [d didUpdateLocation:location];
        }];
    }];
}

+ (CLLocationDegrees)toRadians:(CLLocationDegrees)f
{
    return f * M_PI / 180;
}

+ (float)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    float R = 6371000; // radius of Earth in metres
    float φ1 = [self toRadians:c1.latitude];
    float φ2 = [self toRadians:c2.latitude];
    float Δφ = [self toRadians:c2.latitude - c1.latitude];
    float Δλ = [self toRadians:c2.longitude - c1.longitude];

    float a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2);
    float c = 2 * atan2(sqrt(a), sqrt(1 - a));

    float d = R * c;
    return d;
}

+ (NSString *)coordinate:(CLLocationDegrees)ll
{
    float dummy;
    int degrees = (int)fabs(ll);
    float mins = modff(fabs(ll), &dummy);
    return [NSString stringWithFormat:@"%d° %03.10f", degrees, mins * 60];
}

@end
