//
//  SupportedModelList.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "SupportedModelList.h"

@implementation SupportedModelList

@synthesize supportedModelList;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.supportedModelList = [[NSMutableArray alloc] init];
    }
    return  self;
}

@end
