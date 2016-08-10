//
//  WCFResponse.h
//  AccelerometerApp
//
//  Created by Berkley Bernales on 4/3/13.
//  Copyright (c) 2013 Berkley Bernales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCFResponse : NSObject

@property (strong, nonatomic) NSDictionary* data;
@property (assign, nonatomic) NSInteger statusCode;
@property (strong, nonatomic) NSString * responseData;

@end
