//
//  Model.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "Model.h"

@implementation Model

@synthesize modelName;
@synthesize modelNumber;

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.modelName = [[NSString alloc] init];
    }
    
    return self;
}

@end
