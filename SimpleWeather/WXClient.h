//
//  WXClient.h
//  SimpleWeather
//
//  Created by ucuc on 2014/05/19.
//  Copyright (c) 2014年 ucuc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
@import CoreLocation;
//#import <MapKit/MapKit.h>

@interface WXClient : NSObject

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
