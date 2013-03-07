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




@end
