//
//  MCManager.m
//  ConnectivityTest
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import "MCManager.h"
#import "AppDelegate.h"

@implementation MCManager

@synthesize peerId, session, browser, advertiser;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        dele = [[UIApplication sharedApplication]delegate];
        
        
        peerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        session = [[MCSession alloc] initWithPeer:peerId];
        session.delegate = self;
        
        
        //Para cuando haga la búsqueda
        browser = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_NAME
                                                               session:session];
        
        //Para cuando me promocione
        advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_NAME
                                                          discoveryInfo:nil
                                                                session:session];
    }
    return self;
}

-(void)startAdvertising{
    NSLog(@"Empiezo a spamear el servicio %@", SERVICE_NAME);
    if (advertiser == nil) {
        advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_NAME
                                                          discoveryInfo:nil
                                                                session:session];
    }
    [advertiser start];
}

-(void)stopAdvertising{
    NSLog(@"Pararé de spamear :(");
    [advertiser stop];
    advertiser = nil;
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if(state == MCSessionStateConnected){
        //receivingAppDeleGoEditor
        //Load editor or prepare for first data exchange
        [[NSNotificationCenter defaultCenter]postNotificationName:@"receivingAppDeleGoEditor"
                                                           object: nil];

    }else if(state == MCSessionStateConnecting){
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Disconnected from session"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //Actualizamos
    [dele recoverInfoFromData:data];
    
    //Repaint canvas
     [[NSNotificationCenter defaultCenter]postNotificationName:@"receivedNewAppdelegate"
                                                        object: nil];
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

@end
