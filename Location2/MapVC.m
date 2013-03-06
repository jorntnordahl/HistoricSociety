//
//  MapVC.m
//  Location2
//
//  Created by Jorn Nordahl on 3/5/13.
//  Copyright (c) 2013 Jorn Nordahl. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

@end

@implementation MapVC

-(CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

-(CLGeocoder *) geocoder
{
    if (!_geocoder)
    {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self startStandardUpdates];
    //[self startSignificantChangeUpdates];
    //[self startHeadingEvents];
    
    // add keyboard listener to the view:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // add zooming to current location:
    //[self zoomToCurrentLocation];
    
    
    //self.wantsFullScreenLayout = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    //[self.view addSubview:self.mapView];
}

-(void) zoomToCurrentLocation
{
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.mapView showsUserLocation]) {
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 1; // Change these values to change the zoom
        span.longitudeDelta = 1;
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
    }
}

-(void)dismissKeyboard {
    [self.addressField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    //if (nil == self.locationManager)
     //   self.locationManager = [[CLLocationManager alloc] init];
    
    //self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
}

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    //if (nil == self.locationManager)
    //    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

- (void)startHeadingEvents {
    /*if (!self.locationManager) {
        CLLocationManager* theManager = [[CLLocationManager alloc] init];
        
        // Retain the object in a property.
        self.locationManager = theManager;
        self.locationManager.delegate = self;
    }*/
    
    // Start location services to get the true heading.
    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 5;
        [self.locationManager startUpdatingHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    //[self updateHeadingDisplays];
}

- (IBAction)doLocateClicked:(UIBarButtonItem *)sender {
    [self locationForString];
}

-(IBAction)editingEnded:(id)sender{
    [sender resignFirstResponder];
    [self locationForString];
}

- (IBAction)touchedUpOutside:(id)sender {
 [sender resignFirstResponder];
}

-(void) locationForString
{
    NSString *name = self.addressField.text;
    NSLog(@"Locating Address: %@", name);
    
    if (self.geocoder)
    {
        [self.geocoder geocodeAddressString:name completionHandler:^(NSArray* placemarks, NSError* error)
        {
            if (error)
            {
                [self.view addSubview: [[ToastAlert alloc] initWithText: [error localizedDescription]]];
                NSLog(@"Error: %@", [error localizedDescription]);
            }
            else
            {
                if (placemarks)
                {
                    [self.view addSubview: [[ToastAlert alloc] initWithText: [NSString stringWithFormat:@"Found %d", [placemarks count]]]];
                    for (CLPlacemark *aPlacemark in placemarks)
                    {   
                        NSLog(@"Found Location %@", [aPlacemark description]);
                        MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:aPlacemark  ];
                        [self.mapView addAnnotation:placemark];
                    }
                }
                else
                {
                    [self.view addSubview: [[ToastAlert alloc] initWithText: @"%@ can't be found."]];
                    NSLog(@"No Locations found");
                }
            }
        }];
    }
    else
    {
        NSLog(@"No GeoCoder");
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(newLocation)
    {
        if((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) && (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if(!self.crumbs)
            {
                self.crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:self.crumbs];
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.mapView setRegion:region animated:YES];
            }
            else
            {
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if(!MKMapRectIsNull(updateRect))
                {
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width/self.mapView.visibleMapRect.size.width);
                    
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(!self.crumbView)
    {
        self.crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}

#define BASE_RADIUS 0.0144927536

- (IBAction)doLocateMe:(id)sender {
    
    MKCoordinateRegion region;
    region.center = self.mapView.userLocation.coordinate;

    //CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]; //Get your location and create a CLLocation
    //MKCoordinateRegion region; //create a region.  No this is not a pointer
    //region.center = location.coordinate;  // set the region center to your current location
    MKCoordinateSpan span; // create a range of your view
    span.latitudeDelta = BASE_RADIUS / 0.01;  // span dimensions.  I have BASE_RADIUS defined as 0.0144927536 which is equivalent to 1 mile
    span.longitudeDelta = BASE_RADIUS / 0.01;  // span dimensions
    region.span = span; // Set the region's span to the new span.
    [self.mapView setRegion:region animated:YES]; // to set the map to the newly created region
}

@end
