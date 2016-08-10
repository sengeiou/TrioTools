//
//  CommadDetailsXmlParser.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommandList;

@interface CommadDetailsXmlParser : NSObject

+(CommandList*)parseCommandDetailsXml:(NSString*)filename;



@end
