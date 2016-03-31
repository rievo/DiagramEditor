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

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize components, connections, paletteItems, blue4, blue3, originalCanvasRect, currentPaletteFileName, subPalette, graphicR, evc, blue0, blue1, blue2, elementsDictionary, manager, ecoreContent, output;

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
    
    
    manager = [[MCManager alloc] init];
    
    return YES;
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
}

-(PaletteItem *) getPaletteItemForClassName:(NSString *)name{
    for(PaletteItem * pi in paletteItems){
        if([pi.className isEqualToString:@"name"]){
            return  pi;
        }
    }
    
    return nil;
}
@end
