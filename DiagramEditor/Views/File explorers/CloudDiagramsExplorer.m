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
#import "CloudFileCollectionViewCell.h"

@implementation CloudDiagramsExplorer

@synthesize delegate;



-(void)awakeFromNib{
    
    [super awakeFromNib];
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [background addGestureRecognizer:tapgr];
    [tapgr setDelegate:self];

    
    //Recover diagrams from server
    
    filesArray = [[NSMutableArray alloc] init];
    
    [self loadFilesFromServer];
    
    
    //table.delegate = self;
    //table.dataSource = self;aa
    collection.dataSource = self;
    collection.delegate = self;
    
    //[collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
   
    [collection registerNib:[UINib nibWithNibName:@"CloudFileCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cell"];
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
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
                     
                     [df updatePreviewForString:[fileDic objectForKey:@"imageString"]];
                     [filesArray addObject:df];
                 }
                 
                 
                 //Reload table
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //[table reloadData];
                     [collection reloadData];
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


#pragma mark UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return filesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DiagramFile * df = [filesArray objectAtIndex:indexPath.row];
    
    CloudFileCollectionViewCell * cell = (CloudFileCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"Cell"
                                forIndexPath:indexPath];
    
    
    
    cell.nameLabel.text = df.name;
    cell.preview.image = df.previewImage;

    return cell;
    

    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self removeFromSuperview];
    DiagramFile * file = [filesArray objectAtIndex:indexPath.row];
    [delegate closeExplorerWithSelectedDiagramFile:file];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}
/*
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}*/
 /*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 50, 0, 0);
}*/


#pragma mark – UICollectionViewDelegateFlowLayout

//Da el tamaño de las celdas
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     DiagramFile * df = [filesArray objectAtIndex:indexPath.row];
    
    float xIWant = 100;
    
    float xIHave =df.previewImage.size.width;
    float yIHave =df.previewImage.size.height;

    
    return CGSizeMake(xIWant, yIHave * xIWant / xIHave);
}

@end
