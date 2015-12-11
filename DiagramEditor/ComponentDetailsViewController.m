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
    // Do any additional setup after loading the view.
    nameTextField.text = comp.name;
    previewComponent = comp;
    [previewComponent setNeedsDisplay];
    
    nameTextField.delegate = self;
    dele = [[UIApplication sharedApplication]delegate];

    typeLabel.text = comp.type;
    
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

#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        comp.name = textField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * new = [nameTextField.text stringByReplacingCharactersInRange:range withString:string];
    if(new.length > 0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        comp.name = new;
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


@end
