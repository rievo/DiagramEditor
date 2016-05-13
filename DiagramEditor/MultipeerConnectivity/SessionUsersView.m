//
//  SessionUsersView.m
//  DiagramEditor
//
//  Created by Diego on 11/4/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SessionUsersView.h"
#import "AppDelegate.h"
#import "MCManager.h"
#import "Constants.h"

@implementation SessionUsersView

@synthesize table;

-(void)awakeFromNib{

}



-(void)recoverUsersFromAppDelegateSession{
    dele = [[UIApplication sharedApplication]delegate];
    NSArray * peers = dele.manager.session.connectedPeers;
    
    usersArray = [[NSMutableArray alloc] init];
    for(id thing in peers){
        [usersArray addObject:thing];
    }
    
    //Add myself
    
    [usersArray addObject:dele.myPeerInfo.peerID];
    [table reloadData];
}

-(void)prepare{
    table.dataSource = self;
    table.delegate = self;
    [table setLayoutMargins:UIEdgeInsetsZero];
    [table setSeparatorInset:UIEdgeInsetsZero];
    [self recoverUsersFromAppDelegateSession];
    [table reloadData];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(somebodyChangedState:)
                                                name:kChangedState
                                              object:nil];

    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTap:)];
    [tapgr setCancelsTouchesInView:NO];
    tapgr.delegate = self;
    [self addGestureRecognizer:tapgr];
    
    goodCenter = self.center;
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdateMasterButton:)
                                                 name:kUpdateMasterButton
                                               object:nil];*/
}

-(void)handleUpdateMasterButton: (NSNotification *)not{
    [self recoverUsersFromAppDelegateSession];
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
}



-(void)somebodyChangedState:(NSNotification *)not{
    
    NSDictionary * dic = not.userInfo;
    
    MCPeerID * peer = [dic objectForKey:@"peeerID"];
    MCSessionState state = [[dic objectForKey:@"state"]integerValue];
    
    /*if(state == MCSessionStateNotConnected){
        //Me he desconectado
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Ha sido desconectado"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }*/
    
    NSLog(@"%@ changed state to %ld", peer.displayName, (long)state);
    [self recoverUsersFromAppDelegateSession];
}

#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [usersArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cellUser";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    MCPeerID * peer = [usersArray objectAtIndex:indexPath.row];
    //if (cell == nil)
    //{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        
       
        cell.backgroundColor = [UIColor clearColor];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        [cell.textLabel setMinimumScaleFactor:0.5];
        
        cell.textLabel.textColor = dele.blue1;
        
        NSString * text = peer.displayName;
        
        
        if(peer  == dele.serverId.peerID){
            text = [text stringByAppendingString:@" (S)"];
        }
        
        if(peer.displayName == dele.currentMasterId.peerID.displayName){
            text = [text stringByAppendingString:@" (M)"];
        }
        
        cell.textLabel.text = text;
    //}
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //Obviously, if this returns no, the edit option won't even populate
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Nothing gets called here if you invoke `tableView:editActionsForRowAtIndexPath:` according to Apple docs so just leave this method blank
}

-(NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *expel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                     title:@"Expel"
                                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [self expelPeerAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *promote = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                       title:@"Promote"
                                                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        [self promotePeerAtIndexPath:indexPath];
    }];
    
    expel.backgroundColor = dele.blue1;
    promote.backgroundColor = dele.blue2;
    
    return @[expel, promote]; //array with all the buttons you want. 1,2,3, etc...
}


-(void)expelPeerAtIndexPath:(NSIndexPath *)ip{
    MCPeerID * pid = [usersArray objectAtIndex:ip.row];
    NSLog(@"Expel : %@", pid.displayName);
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:pid forKey:@"who"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kUsersTableExpelPeer
                                                       object:nil
                                                     userInfo:dic];
    
    [table endEditing:YES];

}

-(void)promotePeerAtIndexPath:(NSIndexPath *)ip{
    MCPeerID * pid = [usersArray objectAtIndex:ip.row];
    NSLog(@"Promote: %@", pid.displayName);
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setObject:pid forKey:@"who"];
    [[NSNotificationCenter defaultCenter]postNotificationName:kUsersTablePromotePeer
                                                       object:nil
                                                     userInfo:dic];
    [table endEditing:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if(touch.view == background){
        return YES;
    }else{
        return NO;
    }

    
}

@end