//
//  ViewController.m
//  HRSTemplesOfFood
//
//  Created by Sebastian Osthoff on 29/03/16.
//  Copyright © 2016 HRS. All rights reserved.
//

#import "TOFMapOverviewViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <SafariServices/SafariServices.h>

@interface TOFMapOverviewViewController () <MKMapViewDelegate,  CLLocationManagerDelegate, SFSafariViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong, readwrite) CLLocationManager* locationManager;
@property (nonatomic, strong, readwrite) NSArray* locations;
@property (nonatomic, strong, readwrite) id<MKAnnotation> selectedAnnotation;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (nonatomic, assign, readwrite) BOOL isShowingMenu;

@end

@implementation TOFMapOverviewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIView animateWithDuration:1 animations:^{
        self.menuButton.transform = CGAffineTransformTranslate(self.menuButton.transform, 0, 100);
        self.directionsButton.transform = CGAffineTransformTranslate(self.directionsButton.transform, 0, 100);
    }];
    
    self.locations = [self locationsFromDictionary][@"lunchLocations"];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    
    [self addAnnotationFromLocationDictionary:[self selectRandomAnnotation]];
}

- (NSDictionary*)selectRandomAnnotation
{
    NSArray* locations = [self locations];
    NSUInteger r = arc4random_uniform((uint32_t)locations.count);
    NSDictionary* location = locations[r];
    return location;
}

- (NSDictionary*)locationsFromDictionary
{
    return @{@"lunchLocations" : @[
                     @{@"name" : @"meat.ing",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9333891),
                       @"longitude" : @(6.956118),
                       @"menuURL" : @"http://www.meating-koeln.de/#!menu/c5hf"
                         },
                     @{@"name" : @"La Baia Dóro",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9331053),
                       @"longitude" : @(6.9593632),
                       @"menuURL" : @"http://www.labaiadoro.de/index.php/speisekarte"
                       },
                     @{@"name" : @"Taj Mahal ",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9355623),
                       @"longitude" : @(6.9544758),
                       @"menuURL" : @"http://www.tajmahal-koeln-restaurant.de/liste1.htm"
                       },
                     @{@"name" : @"Yay Trong Kham Korat",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9287931),
                       @"longitude" : @(6.9572003),
                       @"menuURL" : @"http://www.thaikorat.de/v1/media/speisekarte2012.pdf"
                       },
                     @{@"name" : @"Bei der Tante",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9355594),
                       @"longitude" : @(6.9522207),
                       @"menuURL" : @"http://www.bei-dr-tant.de/wochenkarte/"
                       },
                     @{@"name" : @"Café Stanton",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9360079),
                       @"longitude" : @(6.953179),
                       @"menuURL" : @"http://www.cafe-stanton.de/Stanton/Speisen/Business_Lunch"
                       },
                     @{@"name" : @"Cyclo",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9358498),
                       @"longitude" : @(6.9593239),
                       @"menuURL" : @"http://koeln-cyclo.de/Speisekarte.pdf"
                       },
                     @{@"name" : @"Pizza Hut",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9363043),
                       @"longitude" : @(6.9512555),
                       @"menuURL" : @"http://www.pizzahut.de/viel-mehr-als-pizza/speisekarten-ihres-restaurants/"
                       },
                     @{@"name" : @"Das kleine Steakhaus",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9372983),
                       @"longitude" : @(6.9561341),
                       @"menuURL" : @"http://www.daskleinesteakhaus.de/index.php/angebote"
                       },
                     @{@"name" : @"Café Laura",
                       @"stars" : @"⭐️⭐️⭐️⭐️",
                       @"latitude" : @(50.9339702),
                       @"longitude" : @(6.9561509),
                       @"menuURL" : @"http://www.cafelaura.de/files/speisekarte-web.pdf"
                       },
                     ]
             };
}


- (void)addAnnotationFromLocationDictionary:(NSDictionary*)dict
{
    MKPointAnnotation* annotation = [MKPointAnnotation new];
    CLLocationCoordinate2D coord;
    coord.latitude = [dict[@"latitude"] doubleValue];
    coord.longitude = [dict[@"longitude"] doubleValue];
    annotation.title = dict[@"name"];
    annotation.subtitle = dict[@"stars"];
    annotation.coordinate = coord;
    
    [self.mapView addAnnotation:annotation];
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self deselectAnnotation];
        [self addAnnotationFromLocationDictionary:[self selectRandomAnnotation]];
    }
}

- (void)deselectAnnotation
{
    self.selectedAnnotation = nil;
    
    if (self.isShowingMenu) {
        self.isShowingMenu = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.menuButton.transform = CGAffineTransformTranslate(self.menuButton.transform, 0, 100);
            self.directionsButton.transform = CGAffineTransformTranslate(self.directionsButton.transform, 0, 100);
        }];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation* annotation = view.annotation;
    self.selectedAnnotation = annotation;

    if (!self.isShowingMenu) {
        self.isShowingMenu = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.menuButton.transform = CGAffineTransformTranslate(self.menuButton.transform, 0, -100);
            self.directionsButton.transform = CGAffineTransformTranslate(self.directionsButton.transform, 0, -100);
        }];
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self deselectAnnotation];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5
                         animations:^{ annView.frame = endFrame; }];
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.025;
    mapRegion.span.longitudeDelta = 0.025;
    
    [mapView setRegion:mapRegion animated: YES];
}


- (IBAction)tappedOpenDirections:(id)sender {
    
    MKPlacemark* restaurantPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.selectedAnnotation.coordinate addressDictionary:nil];
    
    MKMapItem* restaurantLocation = [[MKMapItem alloc] initWithPlacemark:restaurantPlacemark];
    restaurantLocation.name = self.selectedAnnotation.title;
    
    [MKMapItem openMapsWithItems:@[restaurantLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking}];
}

- (IBAction)tappedOpenMenu:(id)sender {

    NSString* name = self.selectedAnnotation.title;
    
    NSDictionary* location;
    for (NSDictionary* dict in self.locations) {
        if ([name isEqualToString:dict[@"name"]]) {
            location = dict;
            break;
        }
    }

    SFSafariViewController* menuController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:location[@"menuURL"]] entersReaderIfAvailable:YES];
    [self presentViewController:menuController animated:YES completion:nil];
}


@end
