//
//  WXClient.m
//  SimpleWeather
//
//  Created by ucuc on 2014/05/19.
//  Copyright (c) 2014年 ucuc. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h" 

@interface WXClient ()

@property (nonatomic, strong) NSURLSession *session;

@end


@implementation WXClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    
    // 1.Returns the signal.
    //   Remember that this will not execute until this signal is subscribed to.
    //   -fetchJSONFromURL: creates an object for other methods and objects to use;
    //   this behavior is sometimes called the factory pattern.
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 2.Creates an NSURLSessionDataTask (also new to iOS 7) to fetch data from the URL.
        //   You’ll add the data parsing later.
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // TODO: Handle retrieved data
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    // 1.When JSON data exists and there are no errors,
                    //   send the subscriber the JSON serialized as either an array or dictionary.
                    [subscriber sendNext:json];
                }
                else {
                    // 2.If there is an error in either case, notify the subscriber.
                    [subscriber sendError:jsonError];
                }
            }
            else {
                // 2
                [subscriber sendError:error];
            }
            
            // 3.Whether the request passed or failed,
            //   let the subscriber know that the request has completed.
            [subscriber sendCompleted];
        }];
        
        // 3.Starts the the network request once someone subscribes to the signal.
        [dataTask resume];
        
        // 4.Creates and returns an RACDisposable object which handles any cleanup
        //   when the signal when it is destroyed.
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        // 5.Adds a “side effect” to log any errors that occur.
        //   Side effects don’t subscribe to the signal;
        //   rather, they return the signal to which they’re attached for method chaining.
        //   You’re simply adding a side effect that logs on error.
        NSLog(@"%@",error);
    }];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    // 1.Format the URL from a CLLocationCoordinate2D object using its latitude and longitude.
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.Use the method you just built to create the signal.
    //   Since the returned value is a signal, you can call other ReactiveCocoa methods on it.
    //   Here you map the returned value — an instance of NSDictionary — into a different value.
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 3.Use MTLJSONAdapter to convert the JSON into an WXCondition object,
        //   using the MTLJSONSerializing protocol you created for WXCondition.
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1.Use -fetchJSONFromURL again and map the JSON as appropriate. Note how much code you’re saving by reusing this call!
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 2.Build an RACSequence from the “list” key of the JSON. RACSequences let you perform ReactiveCocoa operations on lists.
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 3.Map the new list of objects. This calls -map: on each object in the list, returning a list of new objects.
        return [[list map:^(NSDictionary *item) {
            // 4.Use MTLJSONAdapter again to convert the JSON into a WXCondition object.
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            // 5.Using -map on RACSequence returns another RACSequence, so use this convenience method to get the data as an NSArray.
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
