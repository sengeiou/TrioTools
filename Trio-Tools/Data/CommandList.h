//
//  CommandList.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandList : NSObject{
    NSMutableArray *_commandList;
}

@property (nonatomic, retain) NSMutableArray *commandList;

@end
