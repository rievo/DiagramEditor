//
//  VisibleClassesViewController.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "VisibleClassesViewController.h"
#import "NodeEdgeCell.h"
#import "RefineParametersViewController.h"


@interface VisibleClassesViewController ()

@end

@implementation VisibleClassesViewController

@synthesize classesArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    table.delegate = self;
    table.dataSource= self;
    
    visibles = [[NSMutableArray alloc] initWithArray:classesArray]; //All visibles by default
    hidden = [[NSMutableArray alloc] init];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(leftSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [table addGestureRecognizer:recognizer];
    
    dele = [[UIApplication sharedApplication]delegate];
    
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    nodes = [[NSMutableArray alloc] init];
    edges = [[NSMutableArray alloc] init];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancelVisibleClasses:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){ //Visibles
        return  visibles.count;
    }else{ //Hidden classes
        return hidden.count;
    }
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section == 0){ //Visible, custom cell
        NodeEdgeCell * cell = (NodeEdgeCell *) [tableView dequeueReusableCellWithIdentifier:@"NodeEdgeCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NodeEdgeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        JsonClass * class = [visibles objectAtIndex:indexPath.row];
        
        
        cell.associatedClass = class;
        cell.nameLabel.text = class.name;
        
        return cell;
        
    }else{ //Hidden, default cell;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ecoreDefaultCell"];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ecoreDefaultCell"] ;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        JsonClass * class = [hidden objectAtIndex:indexPath.row];
        
        
        cell.textLabel.text = class.name;
        cell.textLabel.textColor = dele.blue4;
        cell.backgroundColor = dele.blue1;
        
        return cell;
    }
}


- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //do you right swipe stuff here. Something usually using theindexPath that you get that way
    CGPoint location = [gestureRecognizer locationInView:table];
    NSIndexPath *indexPath = [table indexPathForRowAtPoint:location];
    
    if(indexPath.section == 0){ //From visible to hidden
        JsonClass * c = [visibles objectAtIndex:indexPath.row];
        
        [visibles removeObject:c];
        [hidden addObject:c];
        [table reloadData];
    }else{ //From hidden to visible
        JsonClass * c = [hidden objectAtIndex:indexPath.row];
        
        [hidden removeObject:c];
        [visibles addObject:c];
        [table reloadData];
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){ //Visibles
        return @"Visibles";
    }else{ //Hidden
        return @"Hidden";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = dele.blue4;
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    if(section == 0){//Visible
        header.textLabel.text = @"Visible classes";
    }else{ //Hidden
        header.textLabel.text = @"Hidden classes";
    }
    

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
    if(indexPath.section == 0){
        return 73.0;
    }else{
        return 50.0;
    }
}


#pragma mark Move to next screen
- (IBAction)goNextScreen:(id)sender {
    
    
    //For each visible class, I need to know if it is a node or an edge
    
    for(JsonClass * c in visibles){
        if(c.visibleMode == 0){ //This class will be a node
            [nodes addObject:c];
        }else if(c.visibleMode == 1){ //This class will be an edge
            [edges addObject:c];
        }else{
            
        }
    }
    
    
    //Move to next screen
    dispatch_async(dispatch_get_main_queue(),^{
        [self performSegueWithIdentifier:@"showRefineParameters" sender:self];
    });
    
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if([segue.identifier isEqualToString:@"showRefineParameters"]){

         RefineParametersViewController * vc = (RefineParametersViewController *)segue.destinationViewController;
         vc.root = _root;
         vc.classes = classesArray;
         
         vc.visibles = visibles;
         vc.hidden = hidden;
         
         vc.nodes = nodes;
         vc.edges = edges;
     }
 }





@end
