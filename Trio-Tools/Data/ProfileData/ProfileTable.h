//
//  ProfileTable.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileTable : NSObject


@property(assign)int  profileYear;
@property(assign)int  profileMonth;
@property(assign)int  profileDay;
@property(assign)int  profileHour;
@property(assign)int  profileMin;

@property(assign)int  startBlock;
@property(assign)int  endBlock;
@property(assign)BOOL profileFlag;

@property(strong, nonatomic)NSMutableArray * profileDataBlocksFlagPerByteArray;
@property(strong, nonatomic)NSMutableArray * profileDataBlocksFlagArray;

@end
