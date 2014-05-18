//
//  WXCondition.h
//  SimpleWeather
//
//  Created by ucuc on 2014/05/19.
//  Copyright (c) 2014年 ucuc. All rights reserved.
//

#import "MTLModel.h"
// 罠
#import <Mantle.h>

// 1.The MTLJSONSerializing protocol tells the Mantle serializer
//   that this object has instructions on how to map JSON to Objective-C properties.
@interface WXCondition : MTLModel <MTLJSONSerializing>

// 2.These are all of your weather data properties.
//   You’ll be using a couple of them,
//   but its nice to have access to all of the data in the event
//   that you want to extend your app down the road.
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

// 3.This is simply a helper method to map weather conditions to image files.
- (NSString *)imageName;

@end
