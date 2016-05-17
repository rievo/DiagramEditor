//
//  Alert.h
//  DiagramEditor
//
//  Created by Diego on 17/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface Alert : UIImageView


@property MCPeerID * who;
@property NSString * text;

@end
