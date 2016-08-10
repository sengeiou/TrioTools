//
//  JSONWebserviceHelper.m
//  AccelerometerExample
//
//  Created by Berkley Bernales on 3/26/13.
//
//

#import "JSONWebserviceHelper.h"
#import "Definitions.h"

@implementation JSONWebserviceHelper

@synthesize request;

-(WCFResponse*)postRequest:(NSURL *)url jsonData:(NSDictionary *)data
{
    NSString *strToLog = [[NSString alloc] init];
    NSData * jsonData = nil;
    NSString * jsonString = nil;
    WCFResponse * wcfResponse = [[WCFResponse alloc]init];
    wcfResponse.data = data;

    if([NSJSONSerialization isValidJSONObject:data])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *temp = [NSString stringWithFormat:@"Request data: %@",jsonString];
        NSLog(@"%@", temp);
    }
    
    self.request = [NSMutableURLRequest requestWithURL:url];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [self.request setHTTPShouldHandleCookies:NO];
    [self.request setTimeoutInterval:60.0];
    //[self.request setValue:jsonString forHTTPHeaderField:@"json"];
    [self.request setHTTPMethod:@"POST"];
    [self.request setHTTPBody:jsonData];
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    NSString *response = nil;
    if (errorReturned)
    {
        NSLog(@"Post request failed.");
        
    }
    else
    {
        response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        strToLog = [NSString stringWithFormat:@"Response: %@",response];
        NSLog(@"%@", response);
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)theResponse;
    
    NSLog(@"Status code: %ld",(long)httpResponse.statusCode);
    strToLog = [NSString stringWithFormat:@"Status code: %ld",(long)httpResponse.statusCode];
    wcfResponse.statusCode = httpResponse.statusCode;
    wcfResponse.responseData = response;
    
    return wcfResponse;
}

-(WCFResponse*)getRequest:(NSURL *)url jsonData:(NSDictionary *)data
{
    NSString *strToLog = [[NSString alloc] init];
    NSData * jsonData = nil;
    NSString * jsonString = nil;
    WCFResponse * wcfResponse = [[WCFResponse alloc]init];
    wcfResponse.data = data;
    
    if([NSJSONSerialization isValidJSONObject:data])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
       
        NSString *temp = [NSString stringWithFormat:@"Request data: %@",jsonString];
        NSLog(@"%@", temp);
    }
    NSLog(@"URL: %@",url);
    
    self.request = [NSMutableURLRequest requestWithURL:url];
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [self.request setHTTPShouldHandleCookies:NO];
    [self.request setTimeoutInterval:60.0];
    //[self.request setValue:jsonString forHTTPHeaderField:@"json"];
    [self.request setHTTPMethod:@"GET"];
    [self.request setHTTPBody:jsonData];
    
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    NSString *response = nil;
    if (errorReturned)
    {
        NSLog(@"Get request failed.");
    }
    else
    {
        response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        strToLog = [NSString stringWithFormat:@"Response: %@",response];
        NSLog(@"%@", response);
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)theResponse;
    strToLog = [NSString stringWithFormat:@"Status code: %ld",(long)httpResponse.statusCode];
    NSLog(@"Status code: %ld",(long)httpResponse.statusCode);
    wcfResponse.statusCode = httpResponse.statusCode;
    wcfResponse.responseData = response;
    
    return wcfResponse;
    
}

-(WCFResponse*)getRequest:(NSURL *)url
{
     WCFResponse * wcfResponse = [[WCFResponse alloc]init];
    self.request = [NSMutableURLRequest requestWithURL:url];
    [self.request setHTTPMethod:@"GET"];
 
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    NSString *response = nil;
    if (errorReturned)
    {
        NSLog(@"Post request failed.");
    }
    else
    {
        response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", response);
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)theResponse;
    
    NSLog(@"%ld",(long)httpResponse.statusCode);
    wcfResponse.statusCode = httpResponse.statusCode;
    wcfResponse.responseData = response;
    
    return wcfResponse;
}

@end
