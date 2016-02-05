//
//  ComponentsListViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 17/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ComponentsListViewController.h"
#import "AppDelegate.h"
#import "Component.h"

@interface ComponentsListViewController ()

@end

@implementation ComponentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    componentsTable.delegate = self;
    componentsTable.dataSource = self;
    dele = [[UIApplication sharedApplication]delegate];
    
    filteredArray = [[NSMutableArray alloc] init];
    searchBar.delegate = self;
    
    isFiltered = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = 0;
    
    if(isFiltered)
        rows = filteredArray.count;
    else
        rows = dele.components.count;
    return rows;
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
    }
    
    Component * temp = nil;
    
    if(isFiltered){
        temp = [filteredArray objectAtIndex:indexPath.row];
    }else{
        temp = [dele.components objectAtIndex:indexPath.row];
    }
    
    
    cell.textLabel.text = temp.className;
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Component * temp = [dele.components objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
    
}*/


#pragma  mark UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text{
    if(text.length == 0){
        isFiltered = NO;
    }else{
        isFiltered = YES;
        filteredArray = [[NSMutableArray alloc] init];
        
        for(Component * com in dele.components){
            NSRange nameRange = [com.className rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound)
            {
                [filteredArray addObject:com];
            }
        }
    }
    [componentsTable reloadData];
}


- (IBAction)closeList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
