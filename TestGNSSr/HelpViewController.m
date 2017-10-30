//
//  HelpViewController.m
//  TestGNSSr
//
//  Created by Edwin Groothuis on 30/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectZero];
    sv.backgroundColor = [UIColor whiteColor];
    self.view = sv;

    CGRect frame = [[UIScreen mainScreen] bounds];
    NSInteger width = frame.size.width - 20;
    NSInteger y = 20;
    UILabel *l;

    l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 0)];
    l.text = @"TestGNSSr:\n\n"
    "When placing geocaches or when looking for geocaches it is always important to know how good or bad the received signal is. "
    "This app will provide you with the reported coordinates and the historic statistics. "
    "\n\n"
    "The idea for this app came after this Facebook post:"
    "\n\n"
    "Try this thought experiment: Attach your GPS receiver to a tripod. Turn it on and record its position every ten minutes for 24 hours. Next day, plot the 144 coordinates your receiver calculated. What do you suppose the plot would look like?\n"
    "Do you imagine a cloud of points scattered around the actual location? That's a reasonable expectation. Now, imagine drawing a circle or ellipse that encompasses about 95 percent of the points. What would the radius of that circle or ellipse be? (In other words, what is your receiver's positioning error?)\n"
    "\n"
    "So, to once and for all show how good, or bad, iPhones are for geocaching, here is the hard proof."
    ;
    l.numberOfLines = 0;
    [l sizeToFit];
    [self.view addSubview:l];
    y += l.frame.size.height;
    y += 20;

    l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 0)];
    l.text = @"Numbers page\n\n"
    "The numbers page reports the location and the height as reported by the Core Location service. The requested accuracy is 'kCLLocationAccuracyBest', which is 'Use the highest level of accuracy'.\n"
    "\n"
    "In the overview you will see:\n"
    "* The time the probes started and the last update.\n"
    "* The current accuracy as reported by the GNSSr chip.\n"
    "* The height details: current, minimum, maximum and delta between min and max.\n"
    "* The latitude details: current, minimum, maximum and delta in degrees and meters.\n"
    "* The longitude details: current, minimum, maximum and delta in degrees and meters.\n"
    ;
    l.numberOfLines = 0;
    [l sizeToFit];
    [self.view addSubview:l];
    y += l.frame.size.height;
    y += 20;

    l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 0)];
    l.text = @"Graph page\n\n"
    "The graph page reports a scattered heatmap of the data retrieved. The square with the white cross is the last receive position. The graph is logically 1000 x 1000 pixels, reduced to a phyical size of (screenwidth) x (screenwidth).\n"
    "\n"
    "Under the graph you will see:\n"
    "* Time time of the last update.\n"
    "* The coordinate with the highest count.\n"
    "* The count of the current coordinate.\n"
    "* The fluctuations in the received data in meters\n"
    "* The distance of the current coordinates to the previous coordinates.\n"
    ;
    l.numberOfLines = 0;
    [l sizeToFit];
    [self.view addSubview:l];
    y += l.frame.size.height;
    y += 20;

    l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 0)];
    l.text = @"Questions?\n"
    "Please contact me on gnssrtest@mavetju.org\n"
    ;
    l.numberOfLines = 0;
    [l sizeToFit];
    [self.view addSubview:l];
    y += l.frame.size.height;
    y += 20;

    y += 20;
    sv.contentSize = CGSizeMake(width, y);
    [self.view sizeToFit];
}

@end
