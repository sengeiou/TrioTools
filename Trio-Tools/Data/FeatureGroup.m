//
//  CommandTypes.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "FeatureGroup.h"

@implementation FeatureGroup
@synthesize featureGroupList = _featureGroupList;

- (id)init {
    
    if ((self = [super init])) {
        self.featureGroupList = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
