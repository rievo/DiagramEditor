//
//  AppDelegate.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "AppDelegate.h"
#import "Canvas.h"
#import "Connection.h"
#import "ConfigureDiagramViewController.h"
#import "EditorViewController.h"
#import "PaletteItem.h"
#import "ClassAttribute.h"
#import "ChatView.h"
#import "Message.h"
#import "Alert.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize components, connections, paletteItems, blue4, blue3, originalCanvasRect, currentPaletteFileName, subPalette, graphicR, evc, blue0, blue1, blue2, elementsDictionary, manager, ecoreContent, loadingADiagram, fingeredComponent, serverId, currentMasterId, myPeerInfo, myUUIDString, chat, notesArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    connections = [[NSMutableArray alloc] init];
    components = [[NSMutableArray alloc] init];
    
    paletteItems = [[NSMutableArray alloc] init];
    
    blue0 = [[UIColor alloc]initWithRed:91.0/256.0 green:109.0/256.0 blue:146.0/256.0 alpha:1.0];
    blue1 = [[UIColor alloc]initWithRed:182/256.0 green:191/256.0 blue:209/256.0 alpha:1.0];
    blue2 = [[UIColor alloc]initWithRed:130/256.0 green:144/256.0 blue:173/256.0 alpha:1.0];
    blue3 = [[UIColor alloc]initWithRed:58/256.0 green:78/256.0 blue:120/256.0 alpha:1.0];
    blue4 = [[UIColor alloc]initWithRed:34/256.0 green:54/256.0 blue:96/256.0 alpha:1.0];
    
    currentPaletteFileName = nil;
    subPalette = nil;
    graphicR = nil;
    evc = nil;
    
    elementsDictionary = [[NSMutableDictionary alloc] init];
    
    loadingADiagram  = NO;
    
    manager = [[MCManager alloc] init];
    
    //Load my peer Id
    
    
    serverId = nil;
    currentMasterId = nil;
    
    fingeredComponent = nil;
    
    
    //Get my uuid
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * UUID = [prefs stringForKey:@"UUID"];
    if(!UUID){
        NSString * myuuid = [[NSUUID UUID] UUIDString];
        [prefs setObject:myuuid forKey:@"UUID"];
    }
    
    myPeerInfo = [[PeerInfo alloc] init];
    myPeerInfo.peerUUID = UUID;
    myPeerInfo.peerID =[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
    //Escucho las notificaciones
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveData:) name:kReceivedData object:nil];
    
    
    currentMasterId = nil;
    serverId = nil;
    
    chat = nil;
    /*
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(somebodyChangedState:)
                                                name:kChangedState
                                              object:nil];
    */
    
    //Create Palettes folder if doesn't exists
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    NSString *palettePath = [documentsDirectory stringByAppendingPathComponent:@"/Palettes"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:palettePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:palettePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    //Create Jsons folder
    NSString * jsonPath = [documentsDirectory stringByAppendingPathComponent:@"/Jsons"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:jsonPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    return YES;
}


-(void)didReceiveData: (NSNotification *)not{
    //NSLog(@"received data");
    
    NSDictionary * dic = [not userInfo];
    
    NSData * receivedData = [dic objectForKey:@"data"];
    
    NSDictionary * dataDic = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    
    NSString * msg = [dataDic objectForKey:@"msg"];
    
    if([msg isEqualToString:kInitialInfoFromServer]){ //First message
        //Replace all
        NSData * appDeleData = [dataDic objectForKey:@"data"];
        NSDictionary * dic = [NSKeyedUnarchiver unarchiveObjectWithData:appDeleData];
        
        //NSLog(@"-> %@",[[dic allKeys]description]);
        self.components = [dic objectForKey:@"components"];
        self.connections = [dic objectForKey:@"connections"];
        self.currentPaletteFileName = [dic objectForKey:@"currPalFilNam"];
        self.paletteItems = [dic objectForKey:@"paletteItems"];
        self.subPalette = [dic objectForKey:@"subpalette"];
        self.elementsDictionary = [dic objectForKey:@"elementsDictionary"];
        
        self.serverId = [dic objectForKey:@"serverId"];
        self.currentMasterId = [dic objectForKey:@"currentMasterId"];
        
        loadingADiagram = YES;
        
        if(chat == nil){
            chat = [[[NSBundle mainBundle] loadNibNamed:@"ChatView"
                                                       owner:self
                                                     options:nil] objectAtIndex:0];
            
            [chat prepare];
        }
        
        ConfigureDiagramViewController * cc = (ConfigureDiagramViewController *)  self.window.rootViewController;
        [cc performSegueWithIdentifier:@"showEditor" sender:self];
    }else if([msg isEqualToString:kUpdateData]){
        

        //Lo hago sí o sí
        NSData * appdeleData = [dataDic objectForKey:@"data"];
        NSDictionary * dic = [NSKeyedUnarchiver unarchiveObjectWithData:appdeleData];
        
        
        
        //Solo sobreescribo todo si no soy el máster
        
        if([self amITheMaster]){
            
        }else{
            NSArray * subViews = [self.can subviews];
            for(UIView * sub in subViews){
                if(![sub isKindOfClass:[UIImageView class]])
                    [sub removeFromSuperview];
            }
            
            self.components = [dic objectForKey:@"components"];
            self.connections = [dic objectForKey:@"connections"];
            self.elementsDictionary = [dic objectForKey:@"elementsDictionary"];
            
            for(int i = 0; i< components.count; i++){
                [self.can addSubview: [components objectAtIndex:i]];
                [[components objectAtIndex:i]prepare];
            }
        }
        
        
        
        //Lo hago sí o sí
        
        self.serverId = [dic objectForKey:@"serverId"];
        self.currentMasterId = [dic objectForKey:@"currentMasterId"];
        

        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMasterButton object:nil];

        
    }else if([msg isEqualToString:kIWantToBeMaster]){
        
        NSString * myName = self.myPeerInfo.peerID.displayName;
        NSString * serverName = self.serverId.peerID.displayName;
        
        if([myName isEqualToString:serverName]){
            MCPeerID * who = [dataDic objectForKey:@"peerID"];
            NSLog(@"\n\n\n--------------\n%@ ask to be the new master\n----------\n\n", who.displayName);
            
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            [dic setObject:who forKey:@"peerID"];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kIWantToBeMaster object:nil userInfo:dic];
        }else{ //Somebody has asked for being the new master, but not me
            
        }
        
        
    }else if([msg isEqualToString:kYouAreTheNewMaster]){
        //[self reactToIAmTheNewMaster];
        MCPeerID * who = [dataDic objectForKey:@"peerID"];
        
        if([who.displayName isEqualToString: myPeerInfo.peerID.displayName]){
            NSLog(@"\n\n\n--------------\n%@ granted me to be the master\n----------\n\n", who.displayName);
            [[NSNotificationCenter defaultCenter]postNotificationName:kYouAreTheNewMaster object:nil userInfo:dic];
        }else{ //Somebody is the new master
            NSLog(@"I'm not the receiver, just ignore this");
            
            //Update máster button
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMasterButton object:nil];
        }
        
    }else if([msg isEqualToString:kMasterPetitionDenied]){
        MCPeerID * who = [dataDic objectForKey:@"peerID"];
        
        if([who.displayName isEqualToString: myPeerInfo.peerID.displayName]){
            NSLog(@"\n\n\n--------------\n%@ dennied me to be the master\n----------\n\n", who.displayName);
            [[NSNotificationCenter defaultCenter]postNotificationName:kMasterPetitionDenied object:nil userInfo:dic];
        }else{
            NSLog(@"I'm not the receiver, just ignore this");
        }
    }else if([msg isEqualToString:kNewMasterData]){
        if([self amITheServer]){ //If I am the server, I should update my self with master's info
            
            NSData * appdeleData = [dataDic objectForKey:@"data"];
            NSDictionary * dic = [NSKeyedUnarchiver unarchiveObjectWithData:appdeleData];
            
            NSArray * subViews = [self.can subviews];
            for(UIView * sub in subViews){
                [sub removeFromSuperview];
            }
            
            self.components = [dic objectForKey:@"components"];
            self.connections = [dic objectForKey:@"connections"];
            self.elementsDictionary = [dic objectForKey:@"elementsDictionary"];
            
            
            for(int i = 0; i< components.count; i++){
                [self.can addSubview: [components objectAtIndex:i]];
                [[components objectAtIndex:i]prepare];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMasterButton object:nil];

        }
    }else if([msg isEqualToString:kNewAlert]){
        NSValue * whereVal = [dataDic objectForKey:@"where"];
        //CGPoint where = [whereVal CGPointValue];
        
        NSString * type = [dataDic objectForKey:@"alertType"];
        MCPeerID * who = [dataDic objectForKey:@"who"];
        
        //NSString * noteText = [dataDic objectForKey:@"noteText"];
        Alert * alert = [dataDic objectForKey:@"note"];
        
        //NSLog(@"%@ manda una alerta de tipo %@ en la pos (%f,%f)", who.displayName, type, where.x, where.y);
       
        
        NSMutableDictionary * relinfo = [[NSMutableDictionary alloc] init];
        [relinfo setObject:whereVal forKey:@"where"];
        [relinfo setObject:who forKey:@"who"];
        [relinfo setObject:type forKey:@"alertType"];
        
        if(alert != nil){
            [relinfo setObject:alert forKey:@"note"];
        }
    
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewAlert object:nil userInfo:relinfo];
    }else if([msg isEqualToString:kDisconnectYourself]){
        MCPeerID * who = [dataDic objectForKey:@"peerID"];
        if([who.displayName isEqualToString:myPeerInfo.peerID.displayName]){ //It's for me
            [manager.session disconnect];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoOut
                                                                object:nil
                                                              userInfo:nil];
        }else{
            NSLog(@"Somebody has been kicked from session");
        }
    }else if([msg isEqualToString:kNewChatMessage]){

        
        Message * message = [dataDic objectForKey:@"message"];
        NSLog(@"%@ said: %@", message.who.displayName, message.content);
        
        NSMutableDictionary * relinfo = [[NSMutableDictionary alloc] init];
        [relinfo setObject:message forKey:@"message"];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewChatMessage
                                                            object:nil
                                                          userInfo:relinfo];
    }
}




- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


-(int)getOutConnectionsForComponent: (Component *)comp
                             ofType: (NSString * )type{
    
    int count = 0;
    
    for(Connection * con in connections){
        if(con.source == comp && [con.className isEqualToString:type]){
            count++;
        }
    }
    return count;
}


-(int)getInConnectionsForComponent: (Component *)comp
                            ofType: (NSString *)type{
    
    int count = 0;
    
    for(Connection * con in connections){
        if(con.target == comp && [con.className isEqualToString:type]){
            count++;
        }
    }
    return count;
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSString * content = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    
    ConfigureDiagramViewController * cc = (ConfigureDiagramViewController *)  self.window.rootViewController;
    
    cc.contentToParse = content;
    [cc parseRemainingContent];
    
    [cc performSegueWithIdentifier:@"showEditor" sender:self];
    
    
    
    return YES;
}


-(NSData *)packAppDelegate{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    if (components != nil)
        [dic setObject:components forKey:@"components"];
    if(connections != nil)
        [dic setObject:connections forKey:@"connections"];
    if(elementsDictionary != nil)
        [dic setObject:elementsDictionary forKey:@"elementsDictionary"];
    if(paletteItems != nil)
        [dic setObject:paletteItems forKey:@"paletteItems"];
    if(currentPaletteFileName != nil)
        [dic setObject:currentPaletteFileName forKey:@"currPalFilNam"];
    if(subPalette != nil)
        [dic setObject:subPalette forKey:@"subpalette"];
    if(graphicR != nil)
        [dic setObject:graphicR forKey:@"graphicR"];
    
    //Server info
    if(serverId != nil)
        [dic setObject:serverId forKey:@"serverId"];
    
    //Master info
    if(currentMasterId != nil)
        [dic setObject:currentMasterId forKey:@"currentMasterId"];
    
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    return data;
}

-(NSData *) packElementsInfo{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    if (components != nil)
        [dic setObject:components forKey:@"components"];
    if(connections != nil)
        [dic setObject:connections forKey:@"connections"];
    if(elementsDictionary != nil)
        [dic setObject:elementsDictionary forKey:@"elementsDictionary"];
    
    //Server info
    if(serverId != nil)
        [dic setObject:serverId forKey:@"serverId"];
    
    //Master info
    if(currentMasterId != nil)
        [dic setObject:currentMasterId forKey:@"currentMasterId"];
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    return data;
}


-(void)recoverInfoFromData: (NSData *)data{
    NSMutableDictionary *myDictionary = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    components = [myDictionary objectForKey:@"components"];
    connections  = [myDictionary objectForKey:@"connections"];
    elementsDictionary  = [myDictionary objectForKey:@"elementsDictionary"];
    paletteItems = [myDictionary objectForKey:@"paletteItems"];
    currentPaletteFileName  = [myDictionary objectForKey:@"currPalFilNam"];
    subPalette = [myDictionary objectForKey:@"subpalette"];
    graphicR = [myDictionary objectForKey:@"graphicR"];
    serverId = [myDictionary objectForKey:@"serverId"];
    currentMasterId = [myDictionary objectForKey:@"currentMasterId"];
    
    NSLog(@"\n--------------------\nEl master es %@\n--------------------\n", currentMasterId.peerID.displayName);
}

-(PaletteItem *) getPaletteItemForClassName:(NSString *)name{
    for(PaletteItem * pi in paletteItems){
        if([pi.className isEqualToString:@"name"]){
            return  pi;
        }
    }
    
    return nil;
}

-(void) completeClassAttribute:(ClassAttribute *)ca
                  withClasName:(NSString *)className{
    
    for(PaletteItem * pi in paletteItems){
        
        if([pi.className isEqualToString:className]){
            for(ClassAttribute * tempatt in pi.attributes){
                if([tempatt.name isEqualToString:ca.name]){
                    
                    //tempatt have what we want
                    ca.defaultValue = tempatt.defaultValue;
                    ca.max = [NSNumber numberWithInteger:tempatt.max.intValue];
                    ca.min = [NSNumber numberWithInteger:tempatt.min.intValue];
                    ca.type = [tempatt.type copy];
                    
                    if([pi.labelsAttributesArray containsObject:tempatt.name]){ //EL nombre de este atributo está entre los marcados como label
                        ca.isLabel = YES;
                    }
                }
            }
        }
        
    }
}

-(BOOL)amITheMaster{
    BOOL result = false;
    
    if([self.currentMasterId.peerID.displayName isEqualToString:myPeerInfo.peerID.displayName]){
        result = true;
    }else{
        result = false;
    }
    
    return result;
}

-(BOOL)amITheServer{
    BOOL result = false;
    
    if([self.serverId.peerID.displayName isEqualToString:myPeerInfo.peerID.displayName]){
        result = true;
    }else{
        result = false;
    }
    
    return result;
}

/*
-(void)somebodyChangedState:(NSNotification *)not{
    
    NSDictionary * dic = not.userInfo;
    
    MCPeerID * peer = [dic objectForKey:@"peeerID"];
    MCSessionState state = [[dic objectForKey:@"state"]integerValue];
    
    if([peer.displayName isEqualToString:myPeerInfo.peerID.displayName] && state == MCSessionStateNotConnected){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Ha sido desconectado"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    

}*/
@end
