//
//  CommandField.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "CommandFields.h"

@implementation CommandFields

@synthesize fields;
@synthesize featureName;
@synthesize readWrite;
@synthesize readCommandID;
@synthesize writeCommandID;
@synthesize commandPrefix;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.featureName = [[NSString alloc] init];
        self.fields = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
