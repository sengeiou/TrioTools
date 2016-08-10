//
//  ValidateUserRequest.h
//  Trio-Tracker
//
//  Created by Berkley Bernales on 1/13/14.
//  Copyright (c) 2014 Savvysherpa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCFResponse.h"

@interface WCFRequest : NSObject{
    NSURL *url;
}


-(id)initWithUrl:(NSString*)webUrl method:(NSString*)webMethod request:(NSMutableDictionary*)requestData;
- (WCFResponse*)sendRequest;

@property (nonatomic,retain) NSURL* url;
@property (nonatomic,strong) NSMutableDictionary *request;

@end
