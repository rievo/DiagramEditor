//
//  MCManager.m
//  ConnectivityTest
//
//  Created by Diego on 15/3/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import "MCManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation MCManager

@synthesize peerId, session, browser, advertiser;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        
        peerId = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        session = [[MCSession alloc] initWithPeer:peerId];
        session.delegate = self;
        
        
        //Para cuando haga la búsqueda
        browser = [[MCBrowserViewController alloc] initWithServiceType:SERVICE_NAME
                                                               session:session];
        //browser.maximumNumberOfPeers = 15;
        [browser setMaximumNumberOfPeers:15];
        //Para cuando me promocione
        advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:SERVICE_NAME
                                                          discoveryInfo:nil
                                                                session:session];
    }
    return self;
}

-(void)startAdvertising{
    NSLog(@"Empiezo a spamear el servicio %@ que hago", SERVICE_NAME);
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

-(void)session:(MCSession *)sess peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{

    NSDictionary * userInfo = @{@"peerID":peerID, @"state":@(state)};
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangedState
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{

    
    NSDictionary * userInfo = @{@"peerID":peerID, @"data":data};
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedData
                                                            object:nil
                                                          userInfo:userInfo];
    });
    
}

-(void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID{
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}

@end
