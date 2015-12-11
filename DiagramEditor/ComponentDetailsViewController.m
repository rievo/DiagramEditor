//
//  ComponentDetailsViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ComponentDetailsViewController.h"
#import "Component.h"
#import "AppDelegate.h"
#import "Connection.h"


@interface ComponentDetailsViewController ()

@end

@implementation ComponentDetailsViewController

@synthesize comp;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    outConnectionsTable.delegate = self;
    outConnectionsTable.dataSource = self;
    
    // Do any additional setup after loading the view.
    nameTextField.text = comp.name;
    
    CGRect oldFrame = previewComponent.frame;
    temp = [[Component alloc] initWithFrame:CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height)];
    temp.name = comp.name;
    [temp updateNameLabel];
    temp.connections = [NSMutableArray arrayWithArray:comp.connections];
    temp.type = comp.type;
    temp.shapeType = comp.shapeType;
    
    for (UIGestureRecognizer *recognizer in temp.gestureRecognizers) {
        [temp removeGestureRecognizer:recognizer];
    }
    for (UIGestureRecognizer *recognizer in previewComponent.gestureRecognizers) {
        [previewComponent removeGestureRecognizer:recognizer];
    }
    
    [previewComponent addSubview:temp];
    
    [temp setNeedsDisplay];
    
    nameTextField.delegate = self;
    dele = [[UIApplication sharedApplication]delegate];

    typeLabel.text = comp.type;
    
    Connection * tc = nil;
    connections = [[NSMutableArray alloc] init];
    for(int i = 0; i< dele.connections.count; i++){
        tc = [dele.connections objectAtIndex:i];
        if(tc.source == comp)
           [connections addObject:tc];
    }
    
    [outConnectionsTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLocalConenctions{
    Connection * tc = nil;
    connections = [[NSMutableArray alloc] init];
    for(int i = 0; i< dele.connections.count; i++){
        tc = [dele.connections objectAtIndex:i];
        if(tc.source == comp)
            [connections addObject:tc];
    }
    
    [outConnectionsTable reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        comp.name = textField.text;
        temp.name = textField.text;
        [temp updateNameLabel];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * new = [nameTextField.text stringByReplacingCharactersInRange:range withString:string];
    if(new.length > 0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        comp.name = new;
        temp.name = new;
        [temp updateNameLabel];
        return YES;
    }
    else
        return NO;
}


- (IBAction)deleteCurrentComponent:(id)sender {
    
    //Remove all connections for this element
    Connection * conn = nil;
    NSMutableArray * connsToRemove = [[NSMutableArray alloc] init];
    for(int i = 0; i<dele.connections.count; i++){
        conn = [dele.connections objectAtIndex:i];
        
        if(conn.target == comp || conn.source == comp){
            //Remove this connection
            [connsToRemove addObject:conn ];
        }
    }
    
    for(int i = 0; i<connsToRemove.count; i++){
        conn = [connsToRemove objectAtIndex:i];
        [dele.connections removeObject:conn];
    }
    
    
    //Remove this component
    [comp removeFromSuperview];
    [dele.components removeObject:comp];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
}




#pragma mark UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return connections.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    Connection * c = [connections objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor];

    cell.textLabel.text = c.name;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        Connection * toDelete = [connections objectAtIndex:indexPath.row];
        
        [dele.connections removeObject:toDelete];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        [self updateLocalConenctions];
    }
}
@end
