//
//  GraphViewController.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 28/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "GraphViewController.h"
#import "Tools.h"
#import "Coordinate.h"

@interface GraphViewController () <ToolsDelegate>

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) UILabel *labelClock, *labelMaxCount, *labelMaxCountLast;
@property (nonatomic, retain) UILabel *labelDeltaX, *labelDeltaY;
@property (nonatomic, retain) UILabel *labelDistancePrevious;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray<Coordinate *> *coords;
@property (nonatomic        ) NSInteger width, maxCount, maxCountLast;
@property (nonatomic        ) CLLocationDegrees minLat, minLon, maxLat, maxLon;
@property (nonatomic, retain) Coordinate *lastCoord, *prevCoord;

@end

@implementation GraphViewController

- (instancetype)init
{
    self = [super init];

    [self valuesRestart];
    [tools addDelegate:self];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect frame = [[UIScreen mainScreen] bounds];
    self.width = frame.size.width - 20;
    NSInteger y = 20;

    UILabel *label;

    NSTimeZone *tz = [NSTimeZone localTimeZone];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"HH:mm:ss";
    self.dateFormatter.timeZone = tz;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, self.width, self.width)];
    [self.view addSubview:self.imageView];
    y += self.imageView.frame.size.height;
    y += 20;

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:@"Restart" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(valuesRestart) forControlEvents:UIControlEventTouchDown];
    b.frame = CGRectMake(10, y, self.width, 20);
    [self.view addSubview:b];
    y += b.frame.size.height;
    y += 20;

    self.labelClock = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelClock];
    y += self.labelClock.frame.size.height;
    self.labelMaxCount = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelMaxCount];
    y += self.labelMaxCount.frame.size.height;
    self.labelMaxCountLast = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelMaxCountLast];
    y += self.labelMaxCountLast.frame.size.height;
    y += 20;

    label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    label.text = @"Fluctuation:";
    [self.view addSubview:label];
    y += label.frame.size.height;
    self.labelDeltaX = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelDeltaX];
    y += self.labelDeltaX.frame.size.height;
    self.labelDeltaY = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelDeltaY];
    y += self.labelDeltaY.frame.size.height;
    y += 20;

    label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    label.text = @"Distance to previous spot:";
    [self.view addSubview:label];
    y += label.frame.size.height;
    self.labelDistancePrevious = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelDistancePrevious];
    y += self.labelDistancePrevious.frame.size.height;
    y += 20;

    [tools addDelegate:self];
}

- (void)valuesRestart
{
    self.minLat = 180;
    self.minLon = 180;
    self.maxLat = -180;
    self.maxLon = -180;

    self.prevCoord = nil;
    self.lastCoord = nil;

    self.coords = [NSMutableArray arrayWithCapacity:10000];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(showIntervalled) withObject:nil];
}

- (void)didUpdateLocation:(CLLocation *)location
{
    @synchronized(self.coords) {
        Coordinate *c = [[Coordinate alloc] init];
        c.lat = location.coordinate.latitude;
        c.lon = location.coordinate.longitude;
        c.height = location.altitude;
        [self.coords addObject:c];
        self.minLat = MIN(self.minLat, location.coordinate.latitude);
        self.minLon = MIN(self.minLon, location.coordinate.longitude);
        self.maxLat = MAX(self.maxLat, location.coordinate.latitude);
        self.maxLon = MAX(self.maxLon, location.coordinate.longitude);
    }
}

- (UIColor *)valueToHeatColour:(CGFloat)value
{
    CGFloat h = (1 - value);
    CGFloat s = 1;
    CGFloat l = value;// * 0.5;
    return [UIColor colorWithHue:h saturation:s brightness:l alpha:1];
}

- (void)showIntervalled
{
#define SIZEX 1000
#define SIZEY 1000
#define MARGINX 10
#define MARGINY 10
    NSInteger *values = malloc(SIZEX * SIZEY * sizeof(NSInteger));
    while (1) {
        @autoreleasepool {
            NSInteger X = self.width;
            NSInteger Y = self.width;
            NSInteger maxValue;
            CLLocationDegrees minLon = self.minLon;
            CLLocationDegrees minLat = self.minLat;
            CLLocationDegrees maxLon = self.maxLon;
            CLLocationDegrees maxLat = self.maxLat;
            CGFloat deltaY = maxLat - minLat;
            CGFloat deltaX = maxLon - minLon;
            if (deltaX == 0) {
                minLon -= 0.000001;
                maxLon += 0.000001;
                deltaX = maxLon - minLon;
            }
            if (deltaY == 0) {
                minLat -= 0.000001;
                maxLat += 0.000001;
                deltaY = maxLat - minLat;
            }
            memset(values, '\0', sizeof(NSInteger) * SIZEX * SIZEY);

#define xx(__f__) MARGINX + X * (__f__) / SIZEX
#define yy(__f__) MARGINY + Y * (__f__) / SIZEY
#define VALUEXY values[x * SIZEY + y]

            UIGraphicsBeginImageContextWithOptions(CGSizeMake(2 * MARGINX + X, 2 * MARGINY + Y), NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();

            // White background
            CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
            CGContextFillRect(context, CGRectMake(0, 0, self.width, self.width));

            CGContextSetLineWidth(context, 1);
            Coordinate *c = nil, *clast = nil;
            maxValue = 0;
            NSInteger lastX = 0, lastY = 0;
            @synchronized(self.coords) {
                NSEnumerator *e = [self.coords objectEnumerator];
                // Place the
                while ((c = [e nextObject]) != nil) {
                    NSInteger x = (SIZEX - 1) * (c.lon - minLon) / deltaX;
                    NSInteger y = (SIZEY - 1) * (c.lat - minLat) / deltaY;
                    if (x < 0 || x >= SIZEX) continue;
                    if (y < 0 || y >= SIZEY) continue;
                    VALUEXY++;
                    maxValue = MAX(maxValue, VALUEXY);
                    self.maxCountLast = VALUEXY;
                    lastX = x;
                    lastY = y;
                    clast = c;
                };
                if (clast.lat != self.lastCoord.lat || clast.lon != self.lastCoord.lon) {
                    if (self.lastCoord == nil)
                        self.lastCoord = clast;
                    self.prevCoord = self.lastCoord;
                    self.lastCoord = clast;
                }
            }
            for (NSInteger x = 0; x < SIZEX; x++) {
                for (NSInteger y = 0; y < SIZEY; y++) {
                    if (VALUEXY == 0)
                        continue;
                    CGContextSetFillColorWithColor(context, [[self valueToHeatColour:logf(1.0 * VALUEXY) / logf(maxValue)] CGColor]);
                    CGContextFillRect(context, CGRectMake(xx(x) - 3, yy(y) - 3, 6, 6));
                }
            }
            for (NSInteger x = 0; x < 100; x++) {
                CGContextSetFillColorWithColor(context, [[self valueToHeatColour:x / 100.0] CGColor]);
                CGContextFillRect(context, CGRectMake(2 * xx(x), yy(10), 2, 5));
            }
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
            CGContextMoveToPoint(context, xx(lastX) - 2, yy(lastY) - 2);
            CGContextAddLineToPoint(context, xx(lastX) + 2, yy(lastY) + 2);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context, xx(lastX) + 2, yy(lastY) - 2);
            CGContextAddLineToPoint(context, xx(lastX) - 2, yy(lastY) + 2);
            CGContextStrokePath(context);

            // Make an image
            @synchronized(self.image) {
                self.image = UIGraphicsGetImageFromCurrentImageContext();
            }
            UIGraphicsEndImageContext();

            self.maxCount = maxValue;
            [self show];
        }

        [NSThread sleepForTimeInterval:1];
    }
    free(values);

}

- (void)show
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        @synchronized(self.image) {
            self.imageView.image = self.image;
        }
        self.labelClock.text = [NSString stringWithFormat:@"Last update: %@", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time(NULL)]]];
        self.labelMaxCount.text = [NSString stringWithFormat:@"Max count in coordinates: %ld", self.maxCount];
        self.labelMaxCountLast.text = [NSString stringWithFormat:@"Count in last coordinate: %ld", self.maxCountLast];
        self.labelDeltaX.text = [NSString stringWithFormat:@"ΔX: %0.3f meters",
            [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                     to:CLLocationCoordinate2DMake(self.minLat, self.maxLon)]];
        self.labelDeltaY.text = [NSString stringWithFormat:@"ΔY: %0.3f meters",
            [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                     to:CLLocationCoordinate2DMake(self.maxLat, self.minLon)]];
        self.labelDistancePrevious.text = [NSString stringWithFormat:@"Distance %0.3f meters",
                                           [Tools coordinates2distance:CLLocationCoordinate2DMake(self.lastCoord.lat, self.lastCoord.lon)
                                                                    to:CLLocationCoordinate2DMake(self.prevCoord.lat, self.prevCoord.lon)]];

    }];
}

@end
