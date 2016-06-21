//
//  LinkPalette.m
//  DiagramEditor
//
//  Created by Diego on 14/6/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "LinkPalette.h"

@implementation LinkPalette

@synthesize instances, anEReference, lineStyle, paletteName, colorDic, anDiagramElement, className, referenceInClass, isExpandableItem, expandableIndex, targetDecoratorName, sourceDecoratorName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        instances = [[NSMutableArray alloc] init];
    }
    return self;
}



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:instances forKey:@"instances"];
    [coder encodeObject:anEReference forKey:@"anEReference"];
    [coder encodeObject:lineStyle forKey:@"lineStyle"];
    [coder encodeObject:paletteName forKey:@"paletteName"];
    [coder encodeObject:colorDic forKey:@"colorDic"];
    [coder encodeObject:targetDecoratorName forKey:@"targetDecoratorName"];
    [coder encodeObject:sourceDecoratorName forKey:@"sourceDecoratorName"];
    [coder encodeObject:anDiagramElement forKey:@"anDiagramElement"];
    [coder encodeObject:className forKey:@"className"];
    [coder encodeObject:referenceInClass forKey:@"referenceInClass"];
    [coder encodeBool:isExpandableItem forKey:@"isExpandableItem"];
    [coder encodeInt:expandableIndex forKey:@"expandableIndex"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.instances = [coder decodeObjectForKey:@"instances"];
        self.anEReference = [coder decodeObjectForKey:@"anEReference"];
        self.lineStyle = [coder decodeObjectForKey:@"lineStyle"];
        self.paletteName = [coder decodeObjectForKey:@"paletteName"];
        self.colorDic = [coder decodeObjectForKey:@"colorDic"];
        self.targetDecoratorName = [coder decodeObjectForKey:@"targetDecoratorName"];
        self.sourceDecoratorName = [coder decodeObjectForKey:@"sourceDecoratorName"];
        self.anDiagramElement = [coder decodeObjectForKey:@"anDiagramElement"];
        self.className = [coder decodeObjectForKey:@"className"];
        self.referenceInClass = [coder decodeObjectForKey:@"referenceInClass"];
        self.isExpandableItem = [coder decodeBoolForKey:@"isExpandableItem"];
        self.expandableIndex = [coder decodeIntForKey:@"expandableIndex"];


    }
    return self;
}


-(NSString *)description{
    return [NSString stringWithFormat:@"............\n"
            "Class: %@\nReference: %@\nPaletteName: %@\nReferenceInClass: %@\n"
            @"............\n", className, anEReference, paletteName, referenceInClass];
}


@end
