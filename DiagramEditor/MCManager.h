//
//  MCManager.h
//  ConnectivityTest
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@class AppDelegate;

@interface MCManager : NSObject<MCSessionDelegate, NSStreamDelegate>{
    AppDelegate * dele;
    
    
    NSMutableData * data;
    //NSInteger bytesRead;
}

@property (strong, nonatomic) MCPeerID * peerId;
@property (strong, nonatomic) MCSession * session;
@property (strong, nonatomic) MCBrowserViewController * browser;
@property (strong, nonatomic) MCAdvertiserAssistant * advertiser;


-(void)startAdvertising;
-(void)stopAdvertising;


@end
