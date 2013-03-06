//
//  MapVC.h
//  Location2
//
//  Created by Jorn Nordahl on 3/5/13.
//  Copyright (c) 2013 Jorn Nordahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
//#import <MKPlaceMark.h>
#import "ToastAlert.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"

@interface MapVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDirection currentHeading;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;


@end
