//
//  Message.h
//  DiagramEditor
//
//  Created by Diego on 11/5/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>


@interface Message : NSObject


@property NSString * content;
@property NSDate * date;
@property MCPeerID * who;

@end
