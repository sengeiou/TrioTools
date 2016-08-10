//
//  CommandList.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureList : NSObject

@property(strong,nonatomic)NSString *groupName;
@property(strong,nonatomic)NSMutableArray *featureList;

- (id)initWithGroupName:(NSString*)name featureList:(NSMutableArray*)features;
@end
