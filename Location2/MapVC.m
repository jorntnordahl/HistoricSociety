//
//  MapVC.m
//  Location2
//
//  Created by Jorn Nordahl on 3/5/13.
//  Copyright (c) 2013 Jorn Nordahl. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDirection currentHeading;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;
@property (weak, nonatomic) IBOutlet UIButton *locateMeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigateButton;


// local properties:
@property (nonatomic, strong) CLPlacemark *lastFoundPlace;


@end

@implementation MapVC

/*-(CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        //_locationManager.delegate = self;
    }
    return _locationManager;
}*/

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

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // add keyboard listener to the view:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // diable bottom toolbar buttons:
    self.navigateButton.enabled = NO;


    // initialize our AudioSession -
    // this function has to be called once before calling any other AudioSession functions
    //AudioSessionInitialize(NULL, NULL, interruptionListener, NULL);

    // set our default audio session state
    //[self setSessionActiveWithMixing:NO];

    //NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Hero" ofType:@"aiff"]];
    //_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //self.audioPlayer.delegate = self;	// so we know when the sound finishes playing

    //_okToPlaySound = YES;

    // Note: we are using Core Location directly to get the user location updates.
    // We could normally use MKMapView's user location update delegation but this does not work in
    // the background.  Plus we want "kCLLocationAccuracyBestForNavigation" which gives us a better accuracy.
    //
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object

    // By default use the best accuracy setting (kCLLocationAccuracyBest)
    //
    // You mau instead want to use kCLLocationAccuracyBestForNavigation, which is the highest possible
    // accuracy and combine it with additional sensor data.  Note that level of accuracy is intended
    // for use in navigation applications that require precise position information at all times and
    // are intended to be used only while the device is plugged in.
    //
    BOOL navigationAccuracy = YES;//[self.toggleNavigationAccuracyButton isOn];
    self.locationManager.desiredAccuracy =
    (navigationAccuracy ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest);

    // hide the prefs UI for user tracking mode - if MKMapView is not capable of it
    /*if (![self.map respondsToSelector:@selector(setUserTrackingMode:animated:)])
    {
        self.trackUserButton.hidden = self.trackUserLabel.hidden = YES;
    }*/

    [self.locationManager startUpdatingLocation];

    // create the container view which we will use for flip animation (centered horizontally)
    //_containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    //[self.view addSubview:self.containerView];

    //[self.containerView addSubview:self.map];

    // add our custom flip button as the nav bar's custom right view
    /*UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect frame = infoButton.frame;
    frame.size.width = 40.0f;
    infoButton.frame = frame;
    [infoButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
    _flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.rightBarButtonItem = self.flipButton;

    // create our done button as the nav bar's custom right view for the flipped view (used later)
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                                   action:@selector(flipAction:)];
     */
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
    
    
}
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    [self startStandardUpdates];
    [self startSignificantChangeUpdates];
    [self startHeadingEvents];
    
    // add keyboard listener to the view:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // add zooming to current location:
    [self zoomToCurrentLocation];
    
    
    //self.wantsFullScreenLayout = YES;
    
    //self.locationManager = [[CLLocationManager alloc] init];
    //self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // track the user (the map follows the user's location and heading)
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
    
    //[self.locationManager startUpdatingLocation];
    
    //[self.view addSubview:self.mapView];
}*/

/*
-(void) zoomToCurrentLocation
{
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];
}*/

/*
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
*/
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
/*- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
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
}*/

/*
- (void)startHeadingEvents {
    // Start location services to get the true heading.
    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 5;
        [self.locationManager startUpdatingHeading];
    }
}*/

/*
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    //[self updateHeadingDisplays];
}*/

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
    
    // clear the current found place:
    self.lastFoundPlace = nil;
    self.navigateButton.enabled = NO;
    
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
                        
                        // remember the first found place:
                        if (self.lastFoundPlace == nil)
                        {
                            self.lastFoundPlace = aPlacemark;
                            self.navigateButton.enabled = YES;
                        }
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

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {
        /*if ([self.toggleAudioButton isOn])
		{
			[self setSessionActiveWithMixing:YES]; // YES == duck if other audio is playing
			[self playSound];
		}*/
        
        NSLog(@"-----------------------------------------------------");
        NSLog(@"old latitude %+.6f, longitude %+.6f\n",
              oldLocation.coordinate.latitude,
              oldLocation.coordinate.longitude);
        NSLog(@"new latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);

		
		// make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if (!self.crumbs)
            {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                self.crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:self.crumbs];
                
                // On the first location update only, zoom map to user location
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.mapView setRegion:region animated:YES];
            }
            else
            {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                //
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    // There is a non null update rect.
                    // Compute the currently visible map zoom scale
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}

-(MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if (!self.crumbView)
    {
        self.crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}

/*- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(!self.crumbView)
    {
        self.crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}*/

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

- (IBAction)doNavigateToLastFoundLocation:(id)sender
{
    NSLog(@"Navigating...");
    if (self.lastFoundPlace)
    {
        CLLocation *location = self.lastFoundPlace.location;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000);
        
        
        //CLLocation *location = [[CLLocation alloc] initWithLatitude:self.lastFoundPlace.l
                                //self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]; //Get your location and create a CLLocation
        //MKCoordinateRegion region; //create a region.  No this is not a pointer
        //region.center = location.coordinate;  // set the region center to your current location
        MKCoordinateSpan span; // create a range of your view
        span.latitudeDelta = BASE_RADIUS / 0.01;  // span dimensions.  I have BASE_RADIUS defined as 0.0144927536 which is equivalent to 1 mile
        span.longitudeDelta = BASE_RADIUS / 0.01;  // span dimensions
        region.span = span; // Set the region's span to the new span.
        [self.mapView setRegion:region animated:YES]; // to set the map to the newly created region

    }
}

@end
