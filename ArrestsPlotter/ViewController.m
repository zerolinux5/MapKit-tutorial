//
//  ViewController.m
//  ArrestsPlotter
//
//  Created by Jesus Magana on 6/30/14.
//  Copyright (c) 2014 ZeroLinux5. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"

#define METERS_PER_MILE 1609.344

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude= -76.580806;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [self.MKMapView setRegion:viewRegion animated:YES];
}

- (IBAction)refreshTapped:(id)sender {
    // 1
    MKCoordinateRegion mapRegion = [self.MKMapView region];
    CLLocationCoordinate2D centerLocation = mapRegion.center;
    
    // 2
    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
    NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];
    NSString *json = [NSString stringWithFormat:formatString,
                      centerLocation.latitude, centerLocation.longitude, 0.5*METERS_PER_MILE];
    
    // 3
    NSURL *url = [NSURL URLWithString:@"http://data.baltimorecity.gov/api/views/INLINE/rows.json?method=index"];
    
    // 4
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    request.requestMethod = @"POST";
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    // 5
    [request setDelegate:self];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSLog(@"Response: %@", responseString);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // 6
    [request startAsynchronous];
}
@end
