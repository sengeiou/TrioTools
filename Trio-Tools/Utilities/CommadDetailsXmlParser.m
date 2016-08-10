//
//  CommadDetailsXmlParser.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/14/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "CommadDetailsXmlParser.h"
#import "CommandList.h"
#import "CommandFields.h"
#import "Field.h"

#import "GDataXMLNode.h"

@implementation CommadDetailsXmlParser



+ (NSString *)dataFilePath:(NSString*)filename forSaving:(BOOL)forSave {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:filename];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
    {
        return documentsPath;
    }
    else
    {
        filename = [filename substringToIndex:[filename length]-4];
        return [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
    }
}

+(CommandList*)parseCommandDetailsXml:(NSString*)filename
{

    
    NSString *filePath = [self dataFilePath:filename forSaving:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) { return nil; }
    
    CommandList *commandList = [[CommandList alloc] init];

    NSArray *featureMembers = [doc nodesForXPath:@"//Commands/Feature" error:nil];
    
    NSLog(@"Features member count:%d",[featureMembers count]);
    for (GDataXMLElement *featureMember in featureMembers)
    {
        // Let's fill these in!
        CommandFields *commandFields = [[CommandFields alloc] init];
        
        // Feature Name node
        NSArray *featureNames = [featureMember elementsForName:@"FeatureName"];
        if (featureNames.count > 0) {
            GDataXMLElement *fName = (GDataXMLElement *) [featureNames objectAtIndex:0];
            commandFields.featureName = fName.stringValue;
        } else continue;
        
        // Read/Write node
        NSArray *readWrites = [featureMember elementsForName:@"ReadWrite"];
        if (readWrites.count > 0) {
            GDataXMLElement *rw = (GDataXMLElement *) [readWrites objectAtIndex:0];
            commandFields.readWrite = rw.stringValue.boolValue;
        } else continue;
        
        // Command prefix node
        NSArray *commandPrefixes = [featureMember elementsForName:@"CommandPrefix"];
        if (commandPrefixes.count > 0) {
            GDataXMLElement *commandPrefix = (GDataXMLElement *) [commandPrefixes objectAtIndex:0];
            commandFields.commandPrefix = commandPrefix.stringValue.intValue;
        } else continue;
        
        // Read Command ID node
        NSArray *readCommandIDs = [featureMember elementsForName:@"ReadCommandID"];
        if (readCommandIDs.count > 0) {
            GDataXMLElement *readCommandID = (GDataXMLElement *) [readCommandIDs objectAtIndex:0];
            commandFields.readCommandID = readCommandID.stringValue.intValue;
        } else continue;
        
        // Write Command ID node
        NSArray *writeCommandIDs = [featureMember elementsForName:@"WriteCommandID"];
        if (writeCommandIDs.count > 0) {
            GDataXMLElement *writeCommandID = (GDataXMLElement *) [writeCommandIDs objectAtIndex:0];
            commandFields.writeCommandID = writeCommandID.stringValue.intValue;
        } else continue;


        NSArray *fieldMembers = [featureMember elementsForName:@"Fields"];
        if (fieldMembers.count > 0)
        {
            for (GDataXMLElement *element in fieldMembers)
            {
                Field *field = [[Field alloc] init];
                
                for (GDataXMLNode *childName in element.children)
                {
                    if([childName.name isEqualToString:@"FieldName"])
                    {
                        field.fieldname = childName.stringValue;
                    }
                    else if([childName.name isEqualToString:@"Value"])
                    {
                        field.value = childName.stringValue.intValue;
                    }
                    else if([childName.name isEqualToString:@"WriteUIControl"])
                    {
                        field.uiControlType = childName.stringValue.intValue;
                    }
                    else if([childName.name isEqualToString:@"KeyBoardType"])
                    {
                        field.textfieldKeyboardType = childName.stringValue.intValue;
                    }
                    else if([childName.name isEqualToString:@"MaxLength"])
                    {
                        field.maxLen = childName.stringValue.intValue;
                    }
                    else if([childName.name isEqualToString:@"StringValue"])
                    {
                        field.stringValue = childName.stringValue;
                    }
                        
                }
                [commandFields.fields addObject:field];
            }
            
        }
        [commandList.commandList addObject:commandFields];
    }

    
    return commandList;
}

@end
