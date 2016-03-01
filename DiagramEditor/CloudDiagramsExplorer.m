//
//  CloudDiagramsExplorer.m
//  DiagramEditor
//
//  Created by Diego on 1/3/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "CloudDiagramsExplorer.h"
#import "DiagramFile.h"
#import "AppDelegate.h"

@implementation CloudDiagramsExplorer

@synthesize delegate;



-(void)awakeFromNib{
    
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];

    
    //Recover diagrams from server
    
    filesArray = [[NSMutableArray alloc] init];
    
    [self loadFilesFromServer];
    
    
    table.delegate = self;
    table.dataSource = self;
    
    dele = [[UIApplication sharedApplication]delegate];
    
}

-(void)loadFilesFromServer{
    
    [filesArray removeAllObjects];
    
    
    NSLog(@"Loading files from server");
    NSURL *url = [NSURL URLWithString:@"https://diagrameditorserver.herokuapp.com/diagrams?json=true"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {

             NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:NULL];
             
             NSString * code = [dic objectForKey:@"code"];
             if([code isEqualToString:@"200"]){
                 //everything ok
                 NSArray * array = [dic objectForKey:@"array"]; //Array de NSDictionary

                 for(NSDictionary * fileDic in array){
                     DiagramFile * df = [[DiagramFile alloc] init];
                     df.name = [fileDic objectForKey:@"name"];
                     df.dateString = [fileDic objectForKey:@"dateString"];
                     df.content = [fileDic objectForKey:@"content"];
                     [filesArray addObject:df];
                 }
                 
                 
                 //Reload table
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [table reloadData];
                 });
             }
             
         }
     }];
}



-(void)handleTap: (UITapGestureRecognizer *)recog{
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}



#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filesArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    DiagramFile * temp = [filesArray objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = temp.name;
        cell.textLabel.textColor = dele.blue4;
        cell.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.text = temp.dateString;
        cell.detailTextLabel.textColor = dele.blue4;
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self removeFromSuperview];
    DiagramFile * file = [filesArray objectAtIndex:indexPath.row];
    [delegate closeExplorerWithSelectedDiagramFile:file];
}


@end
