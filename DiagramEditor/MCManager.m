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

-(void)session:(MCSession *)sess peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if(state == MCSessionStateConnected){
        
        NSLog(@"Session peer connected");
        //receivingAppDeleGoEditor
        
        //Create stream
        NSError * error = nil;
        
        NSOutputStream * output = [session startStreamWithName:@"stream"
                                                        toPeer:peerID
                                                         error:&error];
        
        if(error){return;}
        
        [output scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [output open];
        
        dele.output = output;
        
        //Load editor or prepare for first data exchange
        [[NSNotificationCenter defaultCenter]postNotificationName:@"receivingAppDeleGoEditor"
                                                           object: nil];

    }else if(state == MCSessionStateConnecting){
        NSLog(@"Connecting...");
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:@"%@ disconnected from session", peerId]                                                        delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //Actualizamos
    /*[dele recoverInfoFromData:data];
    
    //Repaint canvas
     [[NSNotificationCenter defaultCenter]postNotificationName:@"receivedNewAppdelegate"
                                                        object: nil];*/
}

-(void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID{
    
    NSLog(@"session didReceiveStreamWithNameFromPeer");
    stream.delegate = self;
    [stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [stream open];
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


#pragma mark NSStreamDelegate
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    NSLog(@"stream handle event");
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            data = [NSMutableData data];
            break;
            
        case NSStreamEventEndEncountered:
            data = [NSMutableData data];
            break;
            
        case NSStreamEventHasBytesAvailable:{
            NSInputStream * is = (NSInputStream *)stream;

            
            NSUInteger bytesRead = 0;
            
            /*len = [(NSInputStream *)stream read:buf maxLength:1024];*/

            
            while ([is hasBytesAvailable]) {
                uint8_t buf[1024];
                bytesRead = [(NSInputStream *)stream read:buf maxLength:1024];
                [data appendBytes:(const void *)buf length:bytesRead];
                //bytesRead = bytesRead + len;
            }
            
            //NSLog(@"data: %@", data);
            
            NSLog(@"bytesread = %lu", bytesRead);
            
            NSString * recovered = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Recovered: %@", recovered);
            
            data = [NSMutableData data];
            
            //[dele recoverInfoFromData:data];
            //data es lo que quiero
            // [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];

            break;
        }
            
        default:
            break;
    }
}

@end
