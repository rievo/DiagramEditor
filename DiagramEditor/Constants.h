//
//  Constants.h
//  DiagramEditor
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const SERVICE_NAME;


#pragma mark Decorators
FOUNDATION_EXPORT NSString *const NO_DECORATION;
FOUNDATION_EXPORT NSString *const INPUT_ARROW;
FOUNDATION_EXPORT NSString *const DIAMOND;
FOUNDATION_EXPORT NSString *const FILL_DIAMOND;
FOUNDATION_EXPORT NSString *const INPUT_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const INPUT_FILL_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_CLOSED_ARROW;
FOUNDATION_EXPORT NSString *const OUTPUT_FILL_CLOSED_ARROW;


#pragma mark Styles
FOUNDATION_EXPORT NSString *const SOLID;
FOUNDATION_EXPORT NSString *const DASH;
FOUNDATION_EXPORT NSString *const DOT;
FOUNDATION_EXPORT NSString *const DASH_DOT;


#pragma mark Decorators
#define decoratorSize 10


#pragma mark Scale nodes on editor view
#define scaleFactor 1.3f


#define handSize 15


#pragma mark Canvas constants
#define canvasxmargin 15
#define ymargin 10
#define curveMove 60
#define defradius 5
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)
#define lineWitdh 2.0



#pragma mark Collaboration
FOUNDATION_EXPORT NSString *const kInitialInfoFromServer;
FOUNDATION_EXPORT NSString *const kChangedState;
FOUNDATION_EXPORT NSString *const kReceivedData;
FOUNDATION_EXPORT NSString *const kUpdateData;
FOUNDATION_EXPORT NSString *const kIWantToBeMaster;
FOUNDATION_EXPORT NSString *const kYouAreTheNewMaster;
FOUNDATION_EXPORT NSString *const kMasterPetitionDenied;

#pragma mark Resend timer
#define resendTime 0.2

@interface Constants : NSObject

@end
