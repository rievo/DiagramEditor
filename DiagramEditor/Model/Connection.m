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
#import "ColorPalette.h"
#import "ClassAttribute.h"

#import "Constants.h"

@implementation Connection


@synthesize  source, target, arrowPath,controlPoint, className, attributes, sourceDecorator, targetDecorator, references, instancesOfClassesDictionary, lineWidth, lineStyle, lineColorNameString, lineColor, debugDescription;
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
        sourceDecorator = NO_DECORATION;
        targetDecorator = NO_DECORATION;
        references = [[NSMutableArray alloc] init];
        
        instancesOfClassesDictionary = [[NSMutableDictionary alloc] init];
        lineColorNameString = @"black";
        lineColor = [ColorPalette colorForString:@"black"];
        lineStyle = SOLID;
        lineWidth = [NSNumber numberWithFloat:2.0];
            
    }
    return self;
}

-(void)retrieveAttributesForThisClassName{
    AppDelegate * dele = [[UIApplication sharedApplication]delegate];
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.className isEqualToString:className]){ //Match, retrieve attributes
            
            NSData * buffer = [ NSKeyedArchiver archivedDataWithRootObject:pi.attributes];
            NSMutableArray * refs = [NSKeyedUnarchiver unarchiveObjectWithData:buffer];
            attributes = refs;
            break;
        }
    }
}

-(void)retrieveConnectionGraphicInfo{
    AppDelegate * dele = [[UIApplication sharedApplication]delegate];
    
    for(PaletteItem * pi in dele.paletteItems){
        if([pi.className isEqualToString:className]){ //Match, retrieve attributes
            self.lineColor = pi.lineColor;
            self.lineWidth = pi.lineWidth;
            self.lineColorNameString = pi.lineColorNameString;
            self.lineStyle = pi.lineStyle;
            break;
        }
    }
}



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.target forKey:@"target"];
    [coder encodeObject:self.source  forKey:@"source"];
    [coder encodeObject:arrowPath  forKey:@"arrowPath"];
    [coder encodeObject:className  forKey:@"className"];
    
    [coder encodeObject:attributes  forKey:@"attributes"];
    [coder encodeObject:self.references  forKey:@"references"];
    
    [coder encodeObject:self.sourceDecorator  forKey:@"sourceDecorator"];
    [coder encodeObject:self.targetDecorator  forKey:@"targetDecorator"];
    
    [coder encodeObject:self.lineWidth  forKey:@"lineWidth"];
    [coder encodeObject:self.lineStyle  forKey:@"lineStyle"];
    [coder encodeObject:self.lineColor  forKey:@"lineColor"];
    [coder encodeObject:self.lineColorNameString forKey:@"lineColorNameString"];
    
    [coder encodeObject:instancesOfClassesDictionary forKey:@"instancesOfClassesDictionary"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.target = [coder decodeObjectForKey:@"target"];
        self.source = [coder decodeObjectForKey:@"source"];
        self.arrowPath = [coder decodeObjectForKey:@"arrowPath"];
        self.className = [coder decodeObjectForKey:@"className"];
        
        self.attributes = [coder decodeObjectForKey:@"attributes"];
        self.references = [coder decodeObjectForKey:@"references"];
        
        self.sourceDecorator = [coder decodeObjectForKey:@"sourceDecorator"];
        self.targetDecorator = [coder decodeObjectForKey:@"targetDecorator"];
        
        self.lineWidth =[coder decodeObjectForKey:@"lineWidth"];
        self.lineStyle = [coder decodeObjectForKey:@"lineStyle"];
        self.lineColor = [coder decodeObjectForKey:@"lineColor"];
        self.lineColorNameString = [coder decodeObjectForKey:@"lineColorNameString"];
        
        self.instancesOfClassesDictionary = [coder decodeObjectForKey:@"instancesOfClassesDictionary"];

    }
    return self;
}

-(NSString *)getName{
    NSString * temp = @"";
    
    for(ClassAttribute * ca in attributes){
        if(ca.isLabel == YES){
            temp = [temp stringByAppendingString:ca.currentValue];
            temp = [temp stringByAppendingString:@""];
        }
    }
    
    temp = [temp stringByAppendingString:className];
    
    return temp;
}


@end
