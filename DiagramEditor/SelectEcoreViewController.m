//
//  SelectEcoreViewController.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SelectEcoreViewController.h"

#import "Constants.h"
#import "JsonClass.h"
#import "SelectRootClassViewController.h"

#define getJsons @"https://diagrameditorserver.herokuapp.com/jsons?json=true"

@interface SelectEcoreViewController ()

@end

@implementation SelectEcoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ecoresTable.dataSource = self;
    ecoresTable.delegate = self;
    
    jsonsArray = [[NSMutableArray alloc] init];
    
    selectedJson = nil;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    [self populateTable];
}

-(void)populateTable{
    NSThread * thread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(loadEcoresFromServer)
                                                  object:nil];
    [thread start];
    
}

-(void)loadEcoresFromServer{
    NSLog(@"Loading jsons from server");
    NSNumber * versionNumber =  [NSNumber numberWithInteger:graphicRVersion];
    NSString * urlStr = [NSString stringWithFormat:@"%@&version=%@", getJsons, [versionNumber description]];
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
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
                 
                 jsonsArray = [[NSMutableArray alloc] init] ; //Remove previous jsons
                 
                 NSArray * array = [dic objectForKey:@"array"];
                 
                 for(int i = 0; i< [array count]; i++){
                     NSDictionary * ins = [array objectAtIndex:i];
                     EcoreFile * ef = [[EcoreFile alloc] init];
                     ef.name = [ins objectForKey:@"name"];
                     ef.content = [ins objectForKey:@"content"];
                     
                     [jsonsArray addObject:ef];
                 }
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [ecoresTable reloadData];
                 });
                 
                 
                 
                 
             }else{
                 NSLog(@"Error: %@", connectionError);
             }
             
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelCreatingPalette:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableView methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return jsonsArray.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ecoreCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ecoreCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    EcoreFile * ef = [jsonsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = ef.name;
    cell.textLabel.textColor = dele.blue4;
    cell.backgroundColor = dele.blue1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    EcoreFile * selected = [jsonsArray objectAtIndex:indexPath.row];
    selectedJson = selected;
    
    dispatch_async(dispatch_get_main_queue(),^{
       [self performSegueWithIdentifier:@"selectRootClass" sender:self];
    });
    
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



#pragma mark Segue stuff
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"selectRootClass"]){
        SelectRootClassViewController *controller = (SelectRootClassViewController *) segue.destinationViewController;
        controller.selectedJson = selectedJson;
    }
}


@end
