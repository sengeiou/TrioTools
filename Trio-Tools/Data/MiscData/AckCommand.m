//
//  AckCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/9/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "AckCommand.h"

#define ACK_COMMAND_SIZE 3

@implementation AckCommand


-(NSData*)getCommand:(int)commandID
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    commandLen = ACK_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = 0x1B;
    buffer[1] = 0x68;

    
    buffer [2] = commandID;

    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}
@end
