//
//  SupportedModelXmlParser.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "SupportedModelXmlParser.h"

#import "SupportedModelList.h"
#import "GDataXMLNode.h"
#import "Model.h"

@implementation SupportedModelXmlParser

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

+ (SupportedModelList*) parseSupportedTrioModelXml
{
    SupportedModelList *supportedModels = [[SupportedModelList alloc] init];
    
    NSString *commandsFilename = @"SupportedModels.xml";
    NSString *filePath = [self dataFilePath:commandsFilename forSaving:FALSE];
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) { return nil; }
    
    //NSArray *partyMembers = [doc.rootElement elementsForName:@"Player"];
    NSArray *modelMembers = [doc nodesForXPath:@"//SupportedModels/Model" error:nil];
    for (GDataXMLElement *modelMember in modelMembers) {
        
        // Let's fill these in!
        Model *model = [[Model alloc] init];
        
        // Model Name
        NSArray *modelNames = [modelMember elementsForName:@"Name"];
        if (modelNames.count > 0) {
            GDataXMLElement *modelName = (GDataXMLElement *) [modelNames objectAtIndex:0];
            model.modelName = modelName.stringValue;
        } else continue;
        
        // Model Number
        NSArray *modelNumbers = [modelMember elementsForName:@"Number"];
        if (modelNumbers.count > 0)
        {
            GDataXMLElement *modelNumber = (GDataXMLElement *) [modelNumbers objectAtIndex:0];
            model.modelNumber = modelNumber.stringValue.intValue;
            
        } else continue;
        
        [supportedModels.supportedModelList addObject:model];
    }

    return supportedModels;
}

@end
