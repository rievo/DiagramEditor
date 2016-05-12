//
//  PeerInfo.h
//  DiagramEditor
//
//  Created by Diego on 14/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@interface PeerInfo : NSObject<NSCoding>


@property NSString * peerUUID;
@property MCPeerID * peerID;


@end
