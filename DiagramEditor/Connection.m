//
//  Connection.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "Connection.h"
#import "Component.h"
#import "AppDelegate.h"
#import "PaletteItem.h"

@implementation Connection


@synthesize  source, target, arrowPath,controlPoint, className, attributes, sourceDecorator, targetDecorator, references, instancesOfClassesDictionary;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        source = nil;
        target = nil;
        arrowPath = nil;
        //name = @"";
        controlPoint = CGPointMake(0, 0);
        className = @"";
        attributes = [[NSMutableArray alloc] init];
        sourceDecorator = @"noDecoration";
        targetDecorator = @"noDecoration";
        references = [[NSMutableArray alloc] init];
        
        instancesOfClassesDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)retrieveAttributesForThisClassName{
    AppDelegate * dele = [[UIApplication sharedApplication]delegate];
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.className isEqualToString:className]){ //Match, retrieve attributes
            
            NSData * buffer = [ NSKeyedArchiver archivedDataWithRootObject:pi.references];
            NSMutableArray * refs = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
            references = refs;
            break;
        }
    }
}



@end
