//
//  JSONWebserviceHelper.h
//  AccelerometerExample
//
//  Created by Berkley Bernales on 3/26/13.
//
//

#import <Foundation/Foundation.h>
#import "WCFResponse.h"

@interface JSONWebserviceHelper : NSObject{
    NSMutableURLRequest * request;
}

@property (nonatomic,retain)NSMutableURLRequest* request;

-(WCFResponse*)postRequest:(NSURL*)url jsonData:(NSDictionary*)data;
-(WCFResponse*)getRequest:(NSURL *)url jsonData:(NSDictionary *)data;
-(WCFResponse*)getRequest:(NSURL*)url;

@end
