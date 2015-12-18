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
    
    return [dele.components count];    //count number of row from counting array hear cataGorry is An Array
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
    
    Component * temp = [dele.components objectAtIndex:indexPath.row];
    cell.textLabel.text = temp.name;
    cell.backgroundColor = [UIColor clearColor];
    //cell.textLabel.textColor = dele.blue4;
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Component * temp = [dele.components objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
    
}*/



@end
