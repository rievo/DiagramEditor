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

@implementation SessionUsersView

@synthesize table, isHidden;

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
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(somebodyChangedState:) name:kChangedState object:nil];

    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapgr];
    
    isHidden = false;
    goodCenter = self.center;
}



-(void)handleTap:(UITapGestureRecognizer *)recog{
    NSLog(@"tocado");
    
    [self showOrHide];
}

-(void)showOrHide{
    if(isHidden == YES){ //Show
        NSLog(@"show");
        /*[UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                            
                             CGPoint newcenter = goodCenter;
                             newcenter.x = newcenter.x + self.bounds.size.width -20;
                             
                             [self setCenter:newcenter];
                         }
                         completion:nil];*/
        //Animate in
        isHidden = NO;
    }else{ //Hide
        NSLog(@"Hide");
        /*[UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             [self setCenter:goodCenter];
                         }
                         completion:nil];*/
        //Animate out
        isHidden = YES;
    }
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
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = peer.displayName;
       
        cell.backgroundColor = [UIColor clearColor];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        [cell.textLabel setMinimumScaleFactor:0.5];
        
        
        
        if(peer  == dele.myPeerInfo.peerID){
            cell.textLabel.textColor = dele.blue0;
        }else{
            cell.textLabel.textColor = dele.blue1;
        }
    }
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


@end
