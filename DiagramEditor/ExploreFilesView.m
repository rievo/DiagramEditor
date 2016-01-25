//
//  ExploreFilesView.m
//  DiagramEditor
//
//  Created by Diego on 25/1/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ExploreFilesView.h"

@implementation ExploreFilesView

@synthesize filesTable, delegate, background;


-(void)awakeFromNib{
    filesTable.delegate = self;
    filesTable.dataSource = self;
    
    files = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSString * finalPath = [documentsDirectory stringByAppendingString:@"/diagrams"];
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:finalPath error:nil];
    
    for(int i = 0; i<allFiles.count; i++){
        [files addObject: [allFiles objectAtIndex:i]];
    }
    
    [filesTable reloadData];
    dele = [UIApplication sharedApplication].delegate;
    
    tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
}



#pragma mark UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [files count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
        cell.textLabel.text = [files objectAtIndex:indexPath.row];
        cell.textLabel.textColor = dele.blue4;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * pathToFile = [files objectAtIndex:indexPath.row];
    
    [self setHidden:YES];
    [self removeFromSuperview];
    
    //Do something with that path
    [delegate reactToFile:pathToFile];
}


#pragma mark UITapGestureRecognizers
-(void)handleTap: (UITapGestureRecognizer *)tapgr{
    [self setHidden:YES];
    [self removeFromSuperview];
}



@end
