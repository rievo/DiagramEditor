//
//  ColorPalette.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 11/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ColorPalette.h"


@implementation ColorPalette


+(UIColor *)colorForString:(NSString *)str{
    UIColor * temp = nil;
    
    if([str isEqualToString:@"white"]){
        return [ColorPalette white];
    }else if([str isEqualToString:@"black"]){
        return [ColorPalette black];
    }else if([str isEqualToString:@"blue"]){
        return [ColorPalette blue];
    }else if([str isEqualToString:@"chocolate"]){
        return [ColorPalette chocolate];
    }else if([str isEqualToString:@"gray"]){
        return [ColorPalette gray];
    }else if([str isEqualToString:@"green"]){
        return [ColorPalette green];
    }else if([str isEqualToString:@"orange"]){
        return [ColorPalette orange];
    }else if([str isEqualToString:@"purple"]){
        return [ColorPalette purple];
    }else if([str isEqualToString:@"red"]){
        return [ColorPalette red];
    }else if([str isEqualToString:@"yellow"]){
        return [ColorPalette yellow];
    }else if([str isEqualToString:@"light_blue"]){
        return [ColorPalette lightBlue];
    }else if([str isEqualToString:@"light_chocolate"]){
        return [ColorPalette lightChocolate];
    }else if([str isEqualToString:@"light_gray"]){
        return [ColorPalette lightGray];
    }else if([str isEqualToString:@"light_green"]){
        return [ColorPalette lightGreen];
    }else if([str isEqualToString:@"light_orange"]){
        return [ColorPalette lightOrange];
    }else if([str isEqualToString:@"light_purple"]){
        return [ColorPalette lightPurple];
    }else if([str isEqualToString:@"light_red"]){
        return [ColorPalette lightRed];
    }else if([str isEqualToString:@"light_yellow"]){
        return [ColorPalette lightYellow];
    }else if([str isEqualToString:@"dark_blue"]){
        return [ColorPalette darkBlue];
    }else if([str isEqualToString:@"dark_chocolate"]){
        return [ColorPalette darkChocolate];
    }else if([str isEqualToString:@"dark_gray"]){
        return [ColorPalette darkGray];
    }else if([str isEqualToString:@"dark_green"]){
        return [ColorPalette darkGreen];
    }else if([str isEqualToString:@"dark_orange"]){
        return [ColorPalette darkOrange];
    }else if([str isEqualToString:@"dark_purple"]){
        return [ColorPalette darkPurple];
    }else if([str isEqualToString:@"dark_red"]){
        return [ColorPalette darkRed];
    }else if([str isEqualToString:@"dark_yellow"]){
        return [ColorPalette darkYellow];
    }else{
        return nil;
    }
    
    return temp;
}

+(UIColor *)white{
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+(UIColor *)black{
    return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
}


+(UIColor *)blue{
    return [UIColor colorWithRed:114.0/255.0 green:159.0/255.0 blue:207.0/255.0 alpha:1.0];
}


+(UIColor *)chocolate{
    return [UIColor colorWithRed:233.0/255.0 green:185.0/255.0 blue:110.0/255.0 alpha:1.0];
}


+(UIColor *)gray{
    return [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0];
}


+(UIColor *)green{
    return [UIColor colorWithRed:138.0/255.0 green:226.0/255.0 blue:52.0/255.0 alpha:1.0];
}

+(UIColor *)orange{
     return [UIColor colorWithRed:252.0/255.0 green:175.0/255.0 blue:62.0/255.0 alpha:1.0];
}


+(UIColor *)purple{
    return [UIColor colorWithRed:173.0/255.0 green:127.0/255.0 blue:168.0/255.0 alpha:1.0];
}


+(UIColor *)red{
    return [UIColor colorWithRed:239.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1.0];
}

+(UIColor *)yellow{
    return [UIColor colorWithRed:252.0/255.0 green:233.0/255.0 blue:79.0/255.0 alpha:1.0];
}


+(UIColor *)lightBlue{
    return [UIColor colorWithRed:194.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+(UIColor *)lightChocolate{
    return [UIColor colorWithRed:238.0/255.0 green:201.0/255.0 blue:142.0/255.0 alpha:1.0];
}

+(UIColor *)lightGray{
    return [UIColor colorWithRed:209/255.0 green:209/255.0 blue:209.0/255.0 alpha:1.0];
}

+(UIColor *)lightGreen{
    return [UIColor colorWithRed:204.0/255.0 green:242.0/255.0 blue:166.0/255.0 alpha:1.0];
}

+(UIColor *)lightOrange{
    return [UIColor colorWithRed:253.0/255.0 green:206.0/255.0 blue:137.0/255.0 alpha:1.0];
}

+(UIColor *)lightPurple{
    return [UIColor colorWithRed:217.0/255.0 green:196.0/255.0 blue:215.0/255.0 alpha:1.0];
}

+(UIColor *)lightRed{
    return [UIColor colorWithRed:246.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0];
}

+(UIColor *)lightYellow{
    return [UIColor colorWithRed:255.0/255.0 green:245.0/255.0 blue:181.0/255.0 alpha:1.0];
}

+(UIColor *)darkBlue{
    return [UIColor colorWithRed:39.0/255.0 green:76.0/255.0 blue:114.0/255.0 alpha:1.0];
}


+(UIColor *)darkChocolate{
    return [UIColor colorWithRed:154.0/255.0 green:103.0/255.0 blue:23.0/255.0 alpha:1.0];
}


+(UIColor *)darkGray{
    return [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
}

+(UIColor *)darkOrange{
    return [UIColor colorWithRed:224.0/255.0 green:133.0/255.0 blue:3.0/255.0 alpha:1.0];
}

+(UIColor *)darkPurple{
    return [UIColor colorWithRed:114.0/255.0 green:73.0/255.0 blue:110.0/255.0 alpha:1.0];
}

+(UIColor *)darkRed{
    return [UIColor colorWithRed:156.0/255.0 green:12.0/255.0 blue:12.0/255.0 alpha:1.0];
}

+(UIColor *)darkYellow{
    return [UIColor colorWithRed:214.0/255.0 green:197.0/255.0 blue:66.0/255.0 alpha:1.0];
}




+(UIColor *)darkGreen{
    return [UIColor colorWithRed:77.0/255.0 green:137.0/255.0 blue:20.0/255.0 alpha:1.0];
}





@end
