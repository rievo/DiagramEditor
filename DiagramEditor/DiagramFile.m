//
//  DiagramFile.m
//  DiagramEditor
//
//  Created by Diego on 1/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DiagramFile.h"

@implementation DiagramFile

@synthesize name, content, dateString;

- (instancetype)init
{
    self = [super init];
    if (self) {
        name = @"";
        content = @"";
        dateString = @"";
    }
    return self;
}


@end
