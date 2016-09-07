//
//  RefineParametersViewController.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "RefineParametersViewController.h"
#import "HeaderTableViewCell.h"
#import "SubsetionTableViewCell.h"

#import "ClassAttribute.h"
#import "Reference.h"

@interface RefineParametersViewController ()

@end

@implementation RefineParametersViewController

@synthesize visibles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    table.dataSource = self;
    table.delegate = self;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    [table setAllowsSelection:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)cancelRefineParameters:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToNextScreen:(id)sender {
    
}

#pragma mark UITableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return visibles.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Each class will have their attributes + references + attr header + ref header
    JsonClass * c = [visibles objectAtIndex:section];
    
    return c.attributes.count + c.references.count + 2;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    JsonClass * c = [visibles objectAtIndex:indexPath.section];
    
    NSLog(@"Sección %ld , %@", (long)indexPath.section, c.name);
    NSLog(@"Sub %ld", (long)indexPath.row);
    
    if(indexPath.row == 0){ //Attributes header
        HeaderTableViewCell * cell = (HeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        
        if(cell== nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.label.text = @"Attributes";
        return cell;
    }else if(indexPath.row > 0 && indexPath.row < c.attributes.count + 1){ //Is an attribute
        
        SubsetionTableViewCell * cell = (SubsetionTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"subsectionCell"];
        
        ClassAttribute * attr = [c.attributes objectAtIndex:indexPath.row -1];
        
        if(cell== nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubsetionTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.label.text = attr.name;
        return cell;
    }else if(indexPath.row == c.attributes.count + 1){ //References header
        HeaderTableViewCell * cell = (HeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        
        if(cell== nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.label.text = @"References";
        return cell;
    }else{ //Reference
        SubsetionTableViewCell * cell = (SubsetionTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"subsectionCell"];
        
        Reference * ref = [c.references objectAtIndex:indexPath.row -2 - c.attributes.count];
        
        if(cell== nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubsetionTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.label.text = ref.name;
        return cell;
    }
        
     return  nil;
}





-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    JsonClass * c = [visibles objectAtIndex:section];
    return c.name;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = dele.blue4;
    
    JsonClass * c = [visibles objectAtIndex:section];
    
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
    JsonClass * c = [visibles objectAtIndex:indexPath.section];
    
    if(indexPath.row == 0 || indexPath.row == c.attributes.count + 1){ //The section header
        return 30.0;
    }else{
        return 45.0;
    }
}


@end
