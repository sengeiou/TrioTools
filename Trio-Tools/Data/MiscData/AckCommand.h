//
//  AckCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/9/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AckCommand : NSObject

-(NSData*)getCommand:(int)commandID;

@end
