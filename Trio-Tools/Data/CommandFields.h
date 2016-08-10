//
//  CommandField.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandFields : NSObject

@property(strong, nonatomic)NSMutableArray *fields;
@property(strong, nonatomic)NSString *featureName;
@property(assign)BOOL readWrite;
@property(assign)int commandPrefix;
@property(assign)int readCommandID;
@property(assign)int writeCommandID;

@end
