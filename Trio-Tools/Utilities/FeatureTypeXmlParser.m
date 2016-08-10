//
//  CommandTypeXmlParser.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/12/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "FeatureTypeXmlParser.h"

#import "GDataXMLNode.h"

#import "FeatureGroup.h"
#import "FeatureList.h"

#import "Definitions.h"

@implementation FeatureTypeXmlParser

+ (NSString *)dataFilePath:(NSString*)filename forSaving:(BOOL)forSave
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml",filename]];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
    }
}

+ (FeatureGroup*) parseCommandType:(NSString*)filename
{
    NSString *filePath = [self dataFilePath:filename forSaving:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) { return nil; }
    
    FeatureGroup *featureTypes = [[FeatureGroup alloc] init];
    //NSArray *partyMembers = [doc.rootElement elementsForName:@"Player"];
    NSArray *featureMembers = [doc nodesForXPath:@"//Features/FeaturesGroup" error:nil];
    for (GDataXMLElement *featureMember in featureMembers)
    {
        // Let's fill these in!
        NSString *featureGroupName;
        
        // Group Name
        NSArray *groupNames = [featureMember elementsForName:@"GroupName"];
        if (groupNames.count > 0) {
            GDataXMLElement *groupName = (GDataXMLElement *) [groupNames objectAtIndex:0];
            featureGroupName = groupName.stringValue;
        } else continue;
        
        // Command Name
        NSArray *featureNames = [featureMember elementsForName:@"FeatureName"];
        NSMutableArray *featureNamesArray = [[NSMutableArray alloc] init];
        if (featureNames.count > 0) {
            for (NSString *featurename in featureNames){
                GDataXMLElement *firstLevel = (GDataXMLElement *)featurename;
                [featureNamesArray addObject:firstLevel.stringValue];
            }
           
        } else continue;
        FeatureList *featureList = [[FeatureList alloc] initWithGroupName:featureGroupName featureList:featureNamesArray];
        [featureTypes.featureGroupList addObject:featureList];
    }
    

    return featureTypes;
}

@end
