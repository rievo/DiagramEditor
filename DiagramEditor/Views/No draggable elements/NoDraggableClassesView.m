//
//  NoDraggableClassesView.m
//  DiagramEditor
//
//  Created by Diego on 29/2/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "NoDraggableClassesView.h"
#import "AppDelegate.h"
#import "PaletteItem.h"
#import "Connection.h"

@implementation NoDraggableClassesView

@synthesize itemsArray, delegate, connection;

-(void)awakeFromNib{
    [super awakeFromNib];
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    [table setDataSource:self];
    [table setDelegate:self];
    
    UITapGestureRecognizer * tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapgr.delegate = self;
    [background addGestureRecognizer:tapgr];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iShouldClose:)
                                                 name:@"closeHiddenClassList"
                                               object:nil];
}

-(void)iShouldClose:(NSNotification *)not{
    [self removeFromSuperview];
}

#pragma mark UITapGestureRecognizer delegate methods

-(void)handleTap:(UITapGestureRecognizer *)recog{
    //[delegate closeHILV:self withSelectedComponent:nil andConnection:connection];
    
    [self removeFromSuperview];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    [self endEditing:YES];
    if (touch.view != background) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}

#pragma mark UITableView Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return itemsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}




- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell;
    
    PaletteItem * pi = [itemsArray objectAtIndex:indexPath.row];
    
    
    cell= [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 0.5;
    cell.textLabel.text = pi.className;//[NSString stringWithFormat:@"--: "];
    return cell;
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PaletteItem * selected = [itemsArray objectAtIndex:indexPath.row];
    
    
    
    //Saco cuántas instancias tengo de esta clase
    NSMutableArray * instancesArray = [dele.elementsDictionary objectForKey:selected.className];
    if(instancesArray.count == 0){
        //No va a poder seleccionar ninguna instancia, no le dejo seguir
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"This class has no instances so none can be selected\nCreate a new instance later and associate it from the connection details view"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        BOOL required = false;
        BOOL referenceLimitReached = false;
        BOOL isPossibleToMakeANewAssignation = false;
        
        for(Reference * ref in connection.references){
            if([ref.target isEqualToString:selected.className]){
                NSNumber * min = ref.min;
                NSNumber * max = ref.max;
                
                //Saco cuántas referencias de este tipo tengo
                NSMutableArray * tempArray = [connection.instancesOfClassesDictionary objectForKey:ref.target];
                if(tempArray == nil){
                    //No tengo ninguna referencia de esta clase, puedo hacer la conexión
                    isPossibleToMakeANewAssignation = true;
                }else{
                    if(tempArray.count < max.integerValue){
                        //Todavía tengo espacio para una
                        isPossibleToMakeANewAssignation = true;
                    }else{
                        //No puedo asociar una instancia más de esta clase
                        referenceLimitReached = true;
                    }
                }
                
                if(min.integerValue > 0){ //Es obligatorio que haga la conexión
                    required = true;
                }
            }
        }
        
        
        
        
        [delegate closeDraggableLisView:selected
                       WithReturnedItem:selected
                          andConnection:connection
                  isRequiredAssignation:required
               isReferencesLimitReached:referenceLimitReached
        isPossibleToMakeANewAssignation:isPossibleToMakeANewAssignation];
    }
    
    
    
    
    //[delegate closeDraggableListWithReturnedItem:selected];
    /*[delegate closeDraggableLisView:self
                  WithReturnedItem:selected
                      andConnection:connection];*/
    
}


-(void)reloadInfo{
    [table reloadData];
}

- (IBAction)cancelAssociatingComponent:(id)sender {
    
    [self removeFromSuperview];
}




@end
