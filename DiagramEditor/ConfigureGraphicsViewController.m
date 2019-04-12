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
#import "CreateGraphicRViewController.h"


@implementation ConfigureGraphicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    table.delegate = self;
    table.dataSource = self;
    
    [table setAllowsSelection:NO];
    table.backgroundColor = [UIColor clearColor];
    table.separatorColor = [UIColor clearColor];
    
    dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UITapGestureRecognizer * recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [recog setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:recog];
}

-(void)handleTap:(UITapGestureRecognizer *)recog{
    [self.view endEditing:YES];
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
            cell.associatedComponent = c.associatedComponent;
            [cell prepareComponent];
            cell.delegate = self;
            
            return cell;
        }else{ //It is an edge
            EdgeVisualInfoTableViewCell * cell = (EdgeVisualInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EdgeVisualInfoTableViewCell"];
            
            cell.conn = c.associatedComponent;
            
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EdgeVisualInfoTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            return cell;
        }
    }else if(indexPath.row == 1){ //References header
        
        if([_nodes containsObject:c]){
            HeaderTableViewCell * cell = (HeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
            
            if(cell== nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.label.text = @"References";
            return cell;
            
        }else{
            HeaderTableViewCell * cell = (HeaderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
            
            if(cell== nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.label.text = @"Source reference?";
            return cell;

        }
        
    }else{ //Reference visual info (if the class is an Edge, it will show other info
        
        if([_nodes containsObject:c]){ //It is a node
            Reference * thisReference = [c.references objectAtIndex:indexPath.row -2];
            
            
            ReferenciVisualInfoTableViewCell * cell = (ReferenciVisualInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReferenciVisualInfoTableViewCell"];
            if(cell == nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReferenciVisualInfoTableViewCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            cell.ref = (RemovableReference *)thisReference;
            [cell prepare];
            cell.nameLabel.text = thisReference.name;
            
            return cell;
        }else{ //This class is an edge, set wich reference will be the source
            Reference * thisReference = [c.references objectAtIndex:indexPath.row -2];
            
            SubsetionTableViewCell * cell = (SubsetionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"subsetionTableViewCell"];
            
            cell.associatedElement = thisReference;
            
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
        }else{ //I need to know wich reference will be the source and wich one will be the target
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SubsetionTableViewCell" owner:self options:nil];
            UIView * cell = [nib objectAtIndex:0];
            return cell.bounds.size.height;
        }
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"finishCreateGraphicR"]){
        
        
        CreateGraphicRViewController * vc = (CreateGraphicRViewController *)segue.destinationViewController;
        vc.root = _root;
        vc.classes = _classes;
        
        vc.visibles = _visibles;
        vc.hidden = _hidden;
        
        vc.nodes = _nodes;
        vc.edges = _edges;
        
        vc.selectedJson = _selectedJson;
    }
}

#pragma mark NodeVisualInfo delegate
-(void)didTouchImageButton:(NodeVisualInfoTableViewCell *)cell{
    
    updatingCell = cell;
    UIAlertController *alertController;

    UIAlertAction *  fromCameraAction = [UIAlertAction actionWithTitle:@"Take a photo"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [self showCameraOnCell:cell];
                                                               }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                          }];
    UIAlertAction * albumAction = [UIAlertAction actionWithTitle:@"Choose from album"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self showGalleryOnCell:cell];
                                                          }];
    
    UIAlertAction *  fromGoogle = [UIAlertAction actionWithTitle:@"Google"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   
                                                               }];
    
    
    alertController = [UIAlertController alertControllerWithTitle:nil
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];

   

    [alertController addAction:fromCameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    [alertController addAction:fromGoogle];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = cell.photoButton;
    popPresenter.sourceRect = cell.photoButton.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)showCameraOnCell:(NodeVisualInfoTableViewCell*)cell{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

-(void)showGalleryOnCell:(NodeVisualInfoTableViewCell*)cell{
    picker= [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self presentViewController:picker animated:YES completion:nil];
    else
    {
        popover =[[UIPopoverController alloc]initWithContentViewController:picker];
        [popover presentPopoverFromRect:cell.photoButton.frame
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionUnknown
                               animated:YES];
    }
}


#pragma mark - ImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)pick didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [pick dismissViewControllerAnimated:YES completion:nil];
    
    if(popover != nil)
        [popover dismissPopoverAnimated:YES];
    
    
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    
    float wIwant = 120;
    float resulth = image.size.height * wIwant /image.size.width;
    
    UIImage * resized = [self imageWithImage:image convertToSize:CGSizeMake(wIwant, resulth)];
    
    
    updatingCell.associatedComponent.isImage = YES;
    updatingCell.associatedComponent.image = resized;
    updatingCell = nil;
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)pick
{
    updatingCell.associatedComponent.isImage = NO;
    updatingCell.associatedComponent.image =  nil;
    updatingCell = nil;
    [pick dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
