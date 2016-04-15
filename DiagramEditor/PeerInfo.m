//
//  PeerInfo.m
//  DiagramEditor
//
//  Created by Diego on 14/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "PeerInfo.h"

@implementation PeerInfo


@synthesize peerID, peerUUID;



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.peerID forKey:@"peerID"];
    [coder encodeObject:self.peerUUID forKey:@"peerUUID"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    

    
    self = [super init];
    
    if (self) {
        
        self.peerUUID = [coder decodeObjectForKey:@"peerUUID"];
        self.peerID = [coder decodeObjectForKey:@"peerID"];
        
    }
    return self;
}

@end
