//
//  GraphViewController.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 28/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "GraphViewController.h"
#import "Tools.h"

@interface GraphViewController () <ToolsDelegate>

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) UILabel *labelClock, *labelMaxCount;
@property (nonatomic, retain) UILabel *labelDeltaX, *labelDeltaY;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray *coords;
@property (nonatomic        ) NSInteger width, maxCount;
@property (nonatomic        ) CLLocationDegrees minLat, minLon, maxLat, maxLon;

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
    y += 20;

    self.labelDeltaX = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelDeltaX];
    y += self.labelDeltaX.frame.size.height;
    self.labelDeltaY = [[UILabel alloc] initWithFrame:CGRectMake(10, y, self.width, 20)];
    [self.view addSubview:self.labelDeltaY];
    y += self.labelDeltaY.frame.size.height;
    y += 20;

    [tools addDelegate:self];
}

- (void)valuesRestart
{
    self.minLat = 180;
    self.minLon = 180;
    self.maxLat = -180;
    self.maxLon = -180;

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
        [self.coords addObject:location];
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
    while (1) {
        NSInteger X = self.width;
        NSInteger Y = self.width;
        NSInteger *values = calloc(SIZEX * SIZEY, sizeof(NSInteger));
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

#define xx(__f__) X * (__f__) / SIZEX
#define yy(__f__) Y * (__f__) / SIZEY

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(X, Y), NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();

        // White background
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, self.width, self.width));

        // Al coordinates. The older the coordinates, the lighters they will be.
        CGContextSetLineWidth(context, 1);
        CLLocation *c = nil;
        maxValue = 0;
        NSInteger lastX = 0, lastY = 0;
        @synchronized(self.coords) {
            NSEnumerator *e = [self.coords objectEnumerator];
            while ((c = [e nextObject]) != nil) {
                NSInteger x = (SIZEX - 1) * (c.coordinate.longitude - minLon) / deltaX;
                NSInteger y = (SIZEY - 1) * (c.coordinate.latitude - minLat) / deltaY;
                if (x < 0 || x > SIZEX) continue;
                if (y < 0 || y > SIZEY) continue;
                values[x * SIZEY + y]++;
                maxValue = MAX(maxValue, values[x * SIZEY + y]);
                lastX = x;
                lastY = y;
            };
        }
        for (NSInteger x = 0; x < SIZEX; x++) {
            for (NSInteger y = 0; y < SIZEY; y++) {
                if (values[x * SIZEY + y] == 0)
                    continue;
                CGContextSetFillColorWithColor(context, [[self valueToHeatColour:logf(1.0 * values[x * SIZEY + y]) / logf(maxValue)] CGColor]);
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

        free(values);
        [NSThread sleepForTimeInterval:1];
    }

}

- (void)show
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        @synchronized(self.image) {
            self.imageView.image = self.image;
        }
        self.labelClock.text = [NSString stringWithFormat:@"Last update: %@", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time(NULL)]]];
        self.labelMaxCount.text = [NSString stringWithFormat:@"Max count in coordinate: %ld", self.maxCount];
        self.labelDeltaX.text = [NSString stringWithFormat:@"deltaX: %0.10f meters",
            [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                     to:CLLocationCoordinate2DMake(self.minLat, self.maxLon)]];
        self.labelDeltaY.text = [NSString stringWithFormat:@"deltaY: %0.10f meters",
            [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                     to:CLLocationCoordinate2DMake(self.maxLat, self.minLon)]];

    }];
}

@end
