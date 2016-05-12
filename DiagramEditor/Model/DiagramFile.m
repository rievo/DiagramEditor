//
//  DiagramFile.m
//  DiagramEditor
//
//  Created by Diego on 1/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "DiagramFile.h"

@implementation DiagramFile

@synthesize name, content, dateString, previewImage;

- (instancetype)init
{
    self = [super init];
    if (self) {
        name = @"";
        content = @"";
        dateString = @"";
        previewImage = nil;
    }
    return self;
}

-(void)updatePreviewForString:(NSString *)string{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    UIImage * image = [UIImage imageWithData:decodedData];
    previewImage = image;
}


@end
