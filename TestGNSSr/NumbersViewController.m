//
//  ViewController.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 28/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "NumbersViewController.h"
#import "Tools.h"

@interface NumbersViewController () <ToolsDelegate>

@property (nonatomic, retain) UILabel *labelH, *labelMinH, *labelMaxH, *labelDeltaH;
@property (nonatomic, retain) UILabel *labelLon, *labelMinLon, *labelMaxLon, *labelDeltaLon, *labelDeltaLonM, *labelDeltaLonD;
@property (nonatomic, retain) UILabel *labelLat, *labelMinLat, *labelMaxLat, *labelDeltaLat, *labelDeltaLatM, *labelDeltaLatD;
@property (nonatomic, retain) UILabel *labelClock, *labelStart;
@property (nonatomic, retain) UILabel *labelAccuracy;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic        ) CLLocationDistance h, minH, maxH, deltaH;
@property (nonatomic        ) CLLocationDegrees lat, minLat, maxLat, deltaLat;
@property (nonatomic        ) CLLocationDistance lon, minLon, maxLon, deltaLon;
@property (nonatomic        ) CLLocationDistance horizontalAccuracy;

@end

@implementation NumbersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.

    NSTimeZone *tz = [NSTimeZone localTimeZone];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"HH:mm:ss";
    self.dateFormatter.timeZone = tz;

    CGRect frame = [[UIScreen mainScreen] bounds];
    NSInteger width = frame.size.width - 20;
    NSInteger y = 20;

    self.labelClock = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelClock];
    y += self.labelClock.frame.size.height;
    self.labelStart = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelStart];
    y += self.labelStart.frame.size.height;
    y += 20;

    self.labelAccuracy = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelAccuracy];
    y += self.labelAccuracy.frame.size.height;
    y += 20;

    self.labelH = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelH];
    y += self.labelH.frame.size.height;
    self.labelMinH = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMinH];
    y += self.labelMinH.frame.size.height;
    self.labelMaxH = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMaxH];
    y += self.labelMaxH.frame.size.height;
    self.labelDeltaH = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaH];
    y += self.labelDeltaH.frame.size.height;
    y += 20;

    self.labelLat = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelLat];
    y += self.labelLat.frame.size.height;
    self.labelMinLat = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMinLat];
    y += self.labelMinLat.frame.size.height;
    self.labelMaxLat = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMaxLat];
    y += self.labelMaxLat.frame.size.height;
    self.labelDeltaLat = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLat];
    y += self.labelDeltaLat.frame.size.height;
    self.labelDeltaLatD = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLatD];
    y += self.labelDeltaLatD.frame.size.height;
    self.labelDeltaLatM = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLatM];
    y += self.labelDeltaLatM.frame.size.height;
    y += 20;

    self.labelLon = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelLon];
    y += self.labelLon.frame.size.height;
    self.labelMinLon = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMinLon];
    y += self.labelMinLon.frame.size.height;
    self.labelMaxLon = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelMaxLon];
    y += self.labelMaxLon.frame.size.height;
    self.labelDeltaLon = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLon];
    y += self.labelDeltaLon.frame.size.height;
    self.labelDeltaLonD = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLonD];
    y += self.labelDeltaLonD.frame.size.height;
    self.labelDeltaLonM = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width, 20)];
    [self.view addSubview:self.labelDeltaLonM];
    y += self.labelDeltaLonM.frame.size.height;
    y += 20;

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:@"Restart" forState:UIControlStateNormal];
    [b addTarget:self action:@selector(valuesRestart) forControlEvents:UIControlEventTouchDown];
    b.frame = CGRectMake(10, y, width, 20);
    [self.view addSubview:b];
    y += b.frame.size.height;
    y += 20;

    self.labelStart.text = [NSString stringWithFormat:@"Time started: %@", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time(NULL)]]];
}

- (instancetype)init
{
    self = [super init];

    [self valuesRestart];
    [tools addDelegate:self];

    return self;
}

- (void)valuesRestart
{
    self.labelStart.text = [NSString stringWithFormat:@"Time started: %@", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time(NULL)]]];
    self.minLat = 180;
    self.maxLat = -180;
    self.minLon = 180;
    self.maxLon = -180;
    self.minH = 1000000;
    self.maxH = -1000000;
}

- (void)didUpdateLocation:(CLLocation *)location;
{
    self.lat = location.coordinate.latitude;
    self.minLat = MIN(self.lat, self.minLat);
    self.maxLat = MAX(self.lat, self.maxLat);
    self.deltaLat = self.maxLat - self.minLat;

    self.lon = location.coordinate.longitude;
    self.minLon = MIN(self.lon, self.minLon);
    self.maxLon = MAX(self.lon, self.maxLon);
    self.deltaLon = self.maxLon - self.minLon;

    self.h = location.altitude;
    self.minH = MIN(self.h, self.minH);
    self.maxH = MAX(self.h, self.maxH);
    self.deltaH = self.maxH - self.minH;

    self.horizontalAccuracy = location.horizontalAccuracy;

    [self show];
}

- (void)show
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.labelClock.text = [NSString stringWithFormat:@"Last update: %@", [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time(NULL)]]];
        self.labelAccuracy.text = [NSString stringWithFormat:@"Accuracy: %0.3f meters", self.horizontalAccuracy];

        self.labelLat.text = [NSString stringWithFormat:@"Lat: %0.10f °", self.lat];
        self.labelMinLat.text = [NSString stringWithFormat:@"min: %0.10f °", self.minLat];
        self.labelMaxLat.text = [NSString stringWithFormat:@"max: %0.10f °", self.maxLat];
        self.labelDeltaLat.text = [NSString stringWithFormat:@"Δ: %0.10f °", self.deltaLat];
        self.labelDeltaLatD.text = [NSString stringWithFormat:@"Δ: %@", [Tools coordinate:self.deltaLat]];
        self.labelDeltaLatM.text = [NSString stringWithFormat:@"Δ: %0.3f meters",
                                    [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                                             to:CLLocationCoordinate2DMake(self.maxLat, self.minLon)]];

        self.labelLon.text = [NSString stringWithFormat:@"Lon: %0.10f °", self.lon];
        self.labelMinLon.text = [NSString stringWithFormat:@"min: %0.10f °", self.minLon];
        self.labelMaxLon.text = [NSString stringWithFormat:@"max: %0.10f °", self.maxLon];
        self.labelDeltaLon.text = [NSString stringWithFormat:@"Δ: %0.10f °", self.deltaLon];
        self.labelDeltaLonD.text = [NSString stringWithFormat:@"Δ: %@", [Tools coordinate:self.deltaLon]];
        self.labelDeltaLonM.text = [NSString stringWithFormat:@"Δ: %0.3f meters",
                                    [Tools coordinates2distance:CLLocationCoordinate2DMake(self.minLat, self.minLon)
                                                             to:CLLocationCoordinate2DMake(self.minLat, self.maxLon)]];

        self.labelH.text = [NSString stringWithFormat:@"Height: %0.3f meters", self.h];
        self.labelMinH.text = [NSString stringWithFormat:@"min: %0.3f meters", self.minH];
        self.labelMaxH.text = [NSString stringWithFormat:@"max: %0.3f meters", self.maxH];
        self.labelDeltaH.text = [NSString stringWithFormat:@"Δ: %0.3f meters", self.deltaH];
    }];
}



@end
