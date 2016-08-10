//
//  CommandList.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "CommandList.h"

@implementation CommandList

@synthesize commandList = _commandList;

- (id)init {
    
    if ((self = [super init])) {
        self.commandList = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
