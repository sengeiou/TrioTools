//
//  CommandTypeXmlParser.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeatureGroup;

@interface FeatureTypeXmlParser : NSObject

+ (FeatureGroup*) parseCommandType:(NSString*)filename;


@end
