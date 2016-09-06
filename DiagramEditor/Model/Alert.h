//
//  Alert.h
//  DiagramEditor
//
//  Created by Diego on 17/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Component.h"

@interface Alert : UIImageView<NSCoding>


@property MCPeerID * who;
@property NSString * text;
@property NSDate * date;
@property UIImage * attach;
@property Component * associatedComponent;
@property CLLocation * location;

@property NSString * aCId;
@property int identifier;

@end
