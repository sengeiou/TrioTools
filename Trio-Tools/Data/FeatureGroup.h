//
//  CommandTypes.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureGroup : NSObject{
    NSMutableArray *_featureGroupList;
}

@property (nonatomic, retain) NSMutableArray *featureGroupList;

@end
