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
@property (nonatomic, retain) UILabel *labelTextFluctuation, *labelTextDistancePrevious;
@property (nonatomic, retain) UIButton *buttonRestart;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray<Coordinate *> *coords;
@property (nonatomic        ) NSInteger width, maxCount, maxCountLast;
@property (nonatomic        ) CLLocationDegrees minLat, minLon, maxLat, maxLon;
@property (nonatomic, retain) Coordinate *lastCoord, *prevCoord;
@property (nonatomic        ) BOOL running;

@end

@implementation GraphViewController

- (instancetype)init
{
    self = [super init];

    [self valuesRestart];
    [tools addDelegate:self];

    self.running = NO;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];


    NSTimeZone *tz = [NSTimeZone localTimeZone];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"HH:mm:ss";
    self.dateFormatter.timeZone = tz;

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.imageView];

    self.buttonRestart = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buttonRestart setTitle:@"Restart" forState:UIControlStateNormal];
    [self.buttonRestart addTarget:self action:@selector(valuesRestart) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.buttonRestart];

#define LABEL(__var__) \
    __var__ = [[UILabel alloc] initWithFrame:CGRectZero]; \
    __var__.text = @"|"; \
    [self.view addSubview:__var__];

    LABEL(self.labelClock);
    LABEL(self.labelMaxCount);
    LABEL(self.labelMaxCountLast);

    LABEL(self.labelTextFluctuation);
    LABEL(self.labelDeltaX);
    LABEL(self.labelDeltaY);
    self.labelTextFluctuation.text = @"Fluctuation:";

    LABEL(self.labelTextDistancePrevious);
    LABEL(self.labelDistancePrevious);
    self.labelTextDistancePrevious.text = @"Distance to previous spot:";

    [tools addDelegate:self];
}

- (NSInteger)placeLayouts
{
    CGRect frame = [self viewFrame];
    self.width = [self viewWidth];
    NSInteger y = frame.origin.y;

    CGSize size;

    self.imageView.frame = CGRectMake(10, y, self.width - 20, self.width);
    y += self.imageView.frame.size.height;

    self.buttonRestart.frame = CGRectMake(10, y, self.width - 20, 20);
    y += self.buttonRestart.frame.size.height;

#define SIZE(__var__) \
    size = [__var__ sizeThatFits:CGSizeMake(self.width - 20, 0)]; \
    __var__.frame = CGRectMake(10, y, self.width - 20, size.height); \
    y += __var__.frame.size.height;

    SIZE(self.labelClock)
    SIZE(self.labelMaxCount)
    SIZE(self.labelMaxCountLast)
    y += self.labelMaxCountLast.font.lineHeight;

    SIZE(self.labelTextFluctuation)
    SIZE(self.labelDeltaX)
    SIZE(self.labelDeltaY)
    y += self.labelDeltaY.font.lineHeight;

    SIZE(self.labelTextDistancePrevious)
    SIZE(self.labelDistancePrevious)

    return y;
}

- (void)resizeLabels
{
    NSInteger y = [self placeLayouts];

    while (y > [self viewHeight]) {
        UIFont *f = [self.labelClock.font fontWithSize:self.labelClock.font.pointSize - 1];
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([v isKindOfClass:[UILabel class]] == YES) {
                UILabel *l = (UILabel *)v;
                l.font = f;
            }
        }];

        y = [self placeLayouts];
    };
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
    [self resizeLabels];

    if (self.running == NO) {
        self.running = YES;
        [self performSelectorInBackground:@selector(showIntervalled) withObject:nil];
    }
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
#define VALUEXY VALUEXY_(x, y)
#define VALUEXY_(__x__, __y__) values[__x__ + SIZEX * __y__]

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
                // Place the coordinates
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
                    float radius = 5 * logf(1.0 * VALUEXY);
                    CGContextFillRect(context, CGRectMake(xx(x) - radius / 2, yy(y) - radius / 2, radius, radius));
                }
            }

            // legend at the top left
            for (NSInteger x = 0; x < 100; x++) {
                CGContextSetFillColorWithColor(context, [[self valueToHeatColour:x / 100.0] CGColor]);
                CGContextFillRect(context, CGRectMake(2 * xx(x), yy(10), 2, 5));
            }

            float radius = 5 * logf(1.0 * VALUEXY_(lastX, lastY));
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
            CGContextMoveToPoint(context, xx(lastX) - radius / 2, yy(lastY) - radius / 2);
            CGContextAddLineToPoint(context, xx(lastX) + radius / 2, yy(lastY) + radius / 2);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context, xx(lastX) + radius / 2, yy(lastY) - radius / 2);
            CGContextAddLineToPoint(context, xx(lastX) - radius / 2, yy(lastY) + radius / 2);
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
        self.labelMaxCount.text = [NSString stringWithFormat:@"Max count in coordinates: %ld", (long)self.maxCount];
        self.labelMaxCountLast.text = [NSString stringWithFormat:@"Count in last coordinate: %ld", (long)self.maxCountLast];
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
