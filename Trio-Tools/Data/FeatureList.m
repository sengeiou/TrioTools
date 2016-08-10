//
//  CommandList.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "FeatureList.h"

@implementation FeatureList

@synthesize featureList;
@synthesize groupName;

- (id)initWithGroupName:(NSString*)name featureList:(NSMutableArray*)features
{
    self = [super init];
    if (self) {
        self.groupName = name;
        self.featureList = features;
    }
    return self;
}

@end
