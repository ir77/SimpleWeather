//
//  WXManager.m
//  SimpleWeather
//
//  Created by ucuc on 2014/05/19.
//  Copyright (c) 2014年 ucuc. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>

@interface WXManager ()

// 1.Declare the same properties you added in the public interface, but this time declare them as readwrite so you can change the values behind the scenes.
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// 2.Declare a few other private properties for location finding and data fetching.
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end

@implementation WXManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        // 1.Creates a location manager and sets it’s delegate to self.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // 2.Creates the WXClient object for the manager. This handles all networking and data parsing, following our separation of concerns best practice.
        _client = [[WXClient alloc] init];
        
        // 3.The manager observes the currentLocation key on itself using a ReactiveCocoa macro which returns a signal. This is similar to Key-Value Observing but is far more powerful.
        [[[[RACObserve(self, currentLocation)
            // 4.In order to continue down the method chain, currentLocation must not be nil.
            ignore:nil]
           
           // 5.-flattenMap: is very similar to -map:, but instead of mapping each value, it flattens the values and returns one object containing all three signals. In this way, you can consider all three processes as a single unit of work.

           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               // 6.Deliver the signal to subscribers on the main thread.
           }] deliverOn:RACScheduler.mainThreadScheduler]
         // 7.It’s not good practice to interact with the UI from inside your model, but for demonstration purposes you’ll display a banner whenever an error occurs.
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 1.Always ignore the first location update because it is almost always cached.

    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // 2.Once you have a location with the proper accuracy, stop further updates.
    if (location.horizontalAccuracy > 0) {
        // 3.Setting the currentLocation key triggers the RACObservable you set earlier in the init implementation.
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}

@end
