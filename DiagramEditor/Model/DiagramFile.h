//
//  DiagramFile.h
//  DiagramEditor
//
//  Created by Diego on 1/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DiagramFile : NSObject

@property NSString * dateString;
@property NSString * name;
@property NSString * content;
@property UIImage * previewImage;


-(void)updatePreviewForString:(NSString *)string;

@end
