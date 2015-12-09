//
//  EditorViewController.m
//  DiagramEditor
//
//  Created by Diego Vaquero Melchor on 9/12/15.
//  Copyright © 2015 Diego Vaquero Melchor. All rights reserved.
//

#import "EditorViewController.h"
#import "ComponentDetailsViewController.h"

@interface EditorViewController ()

@end

@implementation EditorViewController

@synthesize canvas;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dele = [[UIApplication sharedApplication]delegate];
    [canvas prepareCanvas];
    dele.can = canvas;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showComponentDetails:)
                                                 name:@"showCompNot"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showComponentDetails:(NSNotification *)not{
    NSLog(@"Showing component's details");
    Component * temp = not.object;

    [self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//Just for test purposing
- (IBAction)addElement:(id)sender {
    Component * temp = [[Component alloc] initWithFrame:CGRectMake(50, 50, 40, 40)];
    [dele.components addObject:temp];
    [canvas addSubview:temp];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showComponentDetails"])
    {
        // Get reference to the destination view controller
        ComponentDetailsViewController *vc = [segue destinationViewController];
        vc.comp = sender;
        // Pass any objects to the view controller here, like...
        //[vc setMyObjectHere:object];
    }
}
@end
