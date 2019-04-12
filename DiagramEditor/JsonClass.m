//
//  JsonClass.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "JsonClass.h"

@implementation JsonClass

@synthesize references,parents,attributes, abstract,name, visibleMode;

- (instancetype)init
{
    self = [super init];
    if (self) {
        name = @"unknown";
        abstract = false;
        parents = [[NSMutableArray alloc] init];
        attributes = [[NSMutableArray alloc] init];
        references = [[NSMutableArray alloc] init];
        visibleMode = -1;
        _containmentReference = nil;
        _associatedComponent = nil;
        _isRootClass = NO;
    }
    return self;
}

@end
