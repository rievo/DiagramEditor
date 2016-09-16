//
//  PaletteFile.h
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 13/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaletteFile : NSObject


@property NSString * name;
@property NSString * content;
@property BOOL fromServer;

@property NSString * ecoreURI;


@end
