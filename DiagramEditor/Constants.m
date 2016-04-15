//
//  Constants.m
//  DiagramEditor
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "Constants.h"


NSString *const SERVICE_NAME = @"demiso";


#pragma mark decorators
NSString *const NO_DECORATION = @"nodecoration";
NSString *const INPUT_ARROW = @"inputarrow";
NSString *const DIAMOND = @"diamond";
NSString *const FILL_DIAMOND = @"filldiamond";
NSString *const INPUT_CLOSED_ARROW = @"inputclosedarrow";
NSString *const INPUT_FILL_CLOSED_ARROW = @"inputfillclosedarrow";
NSString *const OUTPUT_ARROW = @"outputarrow";
NSString *const OUTPUT_CLOSED_ARROW = @"outputclosedarrow";
NSString *const OUTPUT_FILL_CLOSED_ARROW = @"outputfillclosedarrow";


#pragma mark styles
NSString *const SOLID = @"solid";
NSString *const DASH = @"dash";
NSString *const DOT = @"dot";
NSString *const DASH_DOT = @"dash_dot";


#pragma mark Collaboration
NSString * const kInitialInfoFromServer = @"kInitialInfoFromServer";
NSString * const kChangedState = @"kChangedState";
NSString * const kReceivedData = @"kReceivedData";
NSString * const kUpdateData = @"kUpdateData";
NSString * const kIWantToBeMaster = @"kIWantToBeMaster";
NSString * const kYouAreTheNewMaster = @"kYouAreTheNewMaster";
NSString * const kMasterPetitionDenied = @"kMasterPetitionDenied";

@implementation Constants

@end
