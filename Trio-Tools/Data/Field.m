//
//  Field.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "Field.h"

@implementation Field
@synthesize fieldname;
@synthesize value;
@synthesize floatValue;
@synthesize uiControlType;
@synthesize textfieldKeyboardType;
@synthesize objectValue;
@synthesize stringValue;
@synthesize maxLen;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.fieldname = [[NSString alloc] init];
        self.objectValue = [[NSObject alloc] init];
        self.stringValue = [[NSString alloc] init];
    }
    
    return self;
}
@end
