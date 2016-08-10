//
//  ValidateUserRequest.m
//  Trio-Tracker
//
//  Created by Berkley Bernales on 1/13/14.
//  Copyright (c) 2014 Savvysherpa. All rights reserved.
//

#import "WCFRequest.h"
#import "JSONWebserviceHelper.h"


@interface WCFRequest ()

@end

@implementation WCFRequest

@synthesize url;

-(id)initWithUrl:(NSString*)webUrl method:(NSString*)webMethod request:(NSMutableDictionary*)requestData
{
    self = [super init];
    if(self)
    {
        self.request = [[NSMutableDictionary alloc] initWithDictionary:requestData];
        NSString *stringURL = [NSString stringWithFormat:@"%@%@",webUrl,webMethod];
        self.url = [NSURL URLWithString:stringURL];
    }
    return self;
}

- (WCFResponse*)sendRequest
{
    
    //NSDictionary *deviceDict = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    
    JSONWebserviceHelper *service = [[JSONWebserviceHelper alloc]init];
    //<HACK> Modify this call to run in another thread.
    return [service postRequest:self.url jsonData:self.request];
}

@end
