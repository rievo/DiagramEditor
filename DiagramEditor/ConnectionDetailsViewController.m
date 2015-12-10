//
//  ConnectionDetailsViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "ConnectionDetailsViewController.h"
#import "AppDelegate.h"

@interface ConnectionDetailsViewController ()

@end

@implementation ConnectionDetailsViewController

@synthesize conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    nameTextField.delegate = self;
    nameTextField.text = conn.name;
    // Do any additional setup after loading the view.
    
    dele = [UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField.text.length >0){
        conn.name = textField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    }else{
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * new = [nameTextField.text stringByReplacingCharactersInRange:range withString:string];

    if(new.length > 0){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
        conn.name = new;
        return YES;
    }
    else
        return NO;
}



- (IBAction)removeCurrentConnection:(id)sender {
    [dele.connections removeObject:conn];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"repaintCanvas" object:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
