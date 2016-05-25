//
//  DrawnAlert.h
//  DiagramEditor
//
//  Created by Diego on 25/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface DrawnAlert : NSObject


@property MCPeerID * who;
@property NSDate * date;
@property NSValue * offset;
@property UIBezierPath * path;

@end
