//
//  WXManager.h
//  SimpleWeather
//
//  Created by ucuc on 2014/05/19.
//  Copyright (c) 2014年 ucuc. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
// 1.Note that you’re not importing WXDailyForecast.h; you’ll always use WXCondition as the forecast class. WXDailyForecast only exists to help Mantle transform JSON to Objective-C.
#import "WXCondition.h"

@interface WXManager : NSObject
<CLLocationManagerDelegate>

// 2.Use instancetype instead of WXManager so subclasses will return the appropriate type.
+ (instancetype)sharedManager;

// 3.These properties will store your data. Since WXManager is a singleton, these properties will be accessible anywhere. Set the public properties to readonly as only the manager should ever change these values privately.
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4.This method starts or refreshes the entire location and weather finding process.
- (void)findCurrentLocation;

@end