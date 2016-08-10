//
//  SupportedModelXmlParser.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SupportedModelList;

@interface SupportedModelXmlParser : NSObject

+ (SupportedModelList*) parseSupportedTrioModelXml;

@end
