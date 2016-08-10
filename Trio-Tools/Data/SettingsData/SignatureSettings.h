//
//  SignatureSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignatureSettings : NSObject

@property(assign)int signatureSamplingTime;
@property(assign)int signatureSamplingCycle;
@property(assign)int signatureSamplingFrequency;
@property(assign)int signatureGenerationThreshold;
@property(assign)int UserProfileTotalBlocks;
@property(assign)int UserProfileNoOfRecordingPerDay;

@end
