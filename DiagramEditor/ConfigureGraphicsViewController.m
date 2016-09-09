//
//  ConfigureGraphicsViewController.m
//  DiagramEditor
//
//  Created by Diego on 8/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "ConfigureGraphicsViewController.h"
#import "HeaderTableViewCell.h"
#import "NodeVisualInfoTableViewCell.h"
#import "EdgeVisualInfoTableViewCell.h"
#import "ReferenciVisualInfoTableViewCell.h"

#import "SubsetionTableViewCell.h"


@implementation ConfigureGraphicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    table.delegate = self;
    table.dataSource = self;
    
    [table setAllowsSelection:NO];
    
    dele = [[UIApplication sharedApplication]delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark UITableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _visibles.count; //Visible classes
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Each class will have their attributes + references + attr header + ref header
    JsonClass * c = [_visibles objectAtIndex:section];
    
    return c.references.count + 1 + 1; //References + references header + visual row (shape,color...)
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    JsonClass * c = [_visibles objectAtIndex:indexPath.section];
    
    if(indexPath.row == 0){ //Visual info (maybe it is a node or an edge), show the right info
        
        
        if([_nodes containsObject:c]){ //It is a node
            NodeVisualInfoTableViewCell * cell = (NodeVisualInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NodeVisualInfoTableViewCell"];
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NodeVisualInfoTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            return cell;
        }else{ //It is an edge
            EdgeVisualInfoTableViewCell * cell = (EdgeVisualInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EdgeVisualInfoTableViewCell"];
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EdgeVisualInfoTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            return cell;
        }
    }else if(indexPath.row == 1){ //References header
        HeaderTableViewCell * cell = (HeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        
        if(cell== nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.label.text = @"References";
        return cell;
    }else{ //Reference visual info (if the class is an Edge, it will show other info
        
        if([_nodes containsObject:c]){ //It is a node
            Reference * thisReference = [c.references objectAtIndex:indexPath.row -2];
            
            
            ReferenciVisualInfoTableViewCell * cell = (ReferenciVisualInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReferenciVisualInfoTableViewCell"];
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenciVisualInfoTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.nameLabel.text = thisReference.name;
            
            return cell;
        }else{ //This class is an edge, set wich reference will be the source
            Reference * thisReference = [c.references objectAtIndex:indexPath.row -2];
            
            SubsetionTableViewCell * cell = (SubsetionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"subsetionTableViewCell"];
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubsetionTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            
            cell.label.text = thisReference.name;
            
            return cell;
            
        }
        
    }
    
    return  nil;
}





-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    JsonClass * c = [_visibles objectAtIndex:section];
    return c.name;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = dele.blue4;
    
    JsonClass * c = [_visibles objectAtIndex:section];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    header.textLabel.text = c.name;
    
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    JsonClass * c = [_visibles objectAtIndex:indexPath.section];
    
    
    if([_nodes containsObject:c]){
        if(indexPath.row == 0 ){ //Node info
            
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NodeVisualInfoTableViewCell" owner:self options:nil];
            UIView * cell = [nib objectAtIndex:0];
            return cell.bounds.size.height;
        }else if(indexPath.row == 1){
            return 45.0;
        }else{
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenciVisualInfoTableViewCell" owner:self options:nil];
            UIView * cell = [nib objectAtIndex:0];
            return cell.bounds.size.height;
        }
    }else{
        if(indexPath.row == 0 ){ //Node info
            
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NodeVisualInfoTableViewCell" owner:self options:nil];
            UIView * cell = [nib objectAtIndex:0];
            return cell.bounds.size.height;
        }else if(indexPath.row == 1){
            return 45.0;
        }else{
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubsetionTableViewCell" owner:self options:nil];
            UIView * cell = [nib objectAtIndex:0];
            return cell.bounds.size.height;
        }
    }
    

}


@end
