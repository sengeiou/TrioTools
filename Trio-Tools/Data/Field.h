//
//  Field.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Field : NSObject

@property(strong, nonatomic)NSString *fieldname;
@property(assign)long long value;
@property(assign)float floatValue;
@property(assign)int uiControlType;
@property(assign)int textfieldKeyboardType;
@property(strong,nonatomic)NSObject * objectValue;
@property(strong, nonatomic)NSString * stringValue;
@property(assign)int maxLen;
@end
