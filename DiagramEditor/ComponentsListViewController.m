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
#import "Connection.h"
#import "PaletteItem.h"
#import "ClassAttribute.h"

@interface ComponentsListViewController ()

@end

@implementation ComponentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    componentsTable.delegate = self;
    componentsTable.dataSource = self;
    dele = [[UIApplication sharedApplication]delegate];
    
    filteredArray = [[NSMutableArray alloc] init];
    searchBar.delegate = self;
    
    isFiltered = NO;
    
    classesArray = [[NSMutableArray alloc] init];
    attrsArray = [[NSMutableArray alloc] init];
    
    
    //Set classes array
    PaletteItem * temp = nil;
    
    NSMutableArray * atrsStringsArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i< dele.paletteItems.count; i++){
        
        //Fill classes Array
        temp = [dele.paletteItems objectAtIndex:i];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:temp.className]; //Default search everything
        [classesArray addObject:dic];
        
        
        //Fill attrs array
        for(ClassAttribute * atr in temp.attributes){
            
            if([atr.type isEqualToString:@"EString"]){
                if(![atrsStringsArray containsObject:atr.name]){
                    [atrsStringsArray addObject:atr.name];
                }
            }
            
        }
    }
    
    //atrsStringsArray holds attrs names, for each one of them, make the dictionary
    
    for(NSString * name in atrsStringsArray){
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:name];
        [attrsArray addObject:dic];
    }
    
    
    
    //Fill allComponentsArray
    allElementsArray = [[NSMutableArray alloc] init];
    
    for(Component * comp in dele.components){
        [allElementsArray addObject:comp];
    }
    
    for(Connection * conn in dele.connections){
        [allElementsArray addObject:conn];
    }
    
    
    NSArray * dicKeys = [dele.elementsDictionary allKeys];
    
    for(NSString * key in dicKeys){
        NSMutableArray * thisKeyArray = [dele.elementsDictionary objectForKey:key];
        
        //For each element on this array...
        for(Component * comp in thisKeyArray){
            [allElementsArray addObject:comp];
        }
    }
    
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
    
    NSInteger rows = 0;
    
    if(isFiltered)
        rows = filteredArray.count;
    else
        rows = allElementsArray.count;
    return rows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:MyIdentifier] ;
        
        
        /*if(isFiltered){ //Get from filtered array
            if([[filteredArray objectAtIndex:indexPath.row] isKindOfClass:[Component class]]){
                Component * temp = [filteredArray objectAtIndex:indexPath.row];
                cell.textLabel.text = temp.className;
                cell.detailTextLabel.text = @"Node";
            }else if([[filteredArray objectAtIndex:indexPath.row] isKindOfClass:[Connection class]]){
                Connection * conn = [filteredArray objectAtIndex:indexPath.row];
                cell.textLabel.text = conn.className;
                cell.detailTextLabel.text = @"Connection";
            }
        }else{ //Get from all components*/
            if([[allElementsArray objectAtIndex:indexPath.row] isKindOfClass:[Component class]]){
                Component * temp = [allElementsArray objectAtIndex:indexPath.row];
                cell.textLabel.text = temp.className;
                cell.detailTextLabel.text = @"Node";
            }else if([[allElementsArray objectAtIndex:indexPath.row] isKindOfClass:[Connection class]]){
                Connection * conn = [allElementsArray objectAtIndex:indexPath.row];
                cell.textLabel.text = conn.className;
                cell.detailTextLabel.text = @"Connection";
            }
        //}
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    /*
     Component * temp = nil;
     
     if(isFiltered){
     temp = [filteredArray objectAtIndex:indexPath.row];
     }else{
     temp = [dele.components objectAtIndex:indexPath.row];
     }
     
     
     cell.textLabel.text = temp.className;
     cell.backgroundColor = [UIColor clearColor];*/
    
    return cell;
}

/*
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
 Component * temp = [dele.components objectAtIndex:indexPath.row];
 
 [self performSegueWithIdentifier:@"showComponentDetails" sender:temp];
 
 }*/

-(void)doFilterForText:(NSString *)text{
    
    //if(text.length == 0){
     //   isFiltered = NO;
    //}else{
        isFiltered = YES;
        filteredArray = [[NSMutableArray alloc] init];
        
        for(int i = 0; i< allElementsArray.count; i++){
            
            BOOL allowForClass = false;
            
            
            if([[allElementsArray objectAtIndex:i]isKindOfClass:[Component class]]){
                Component * temp = [allElementsArray objectAtIndex:i];
                allowForClass = [self areWeAllowingInstancesOfClassName:temp.className];
            }else if([[allElementsArray objectAtIndex:i]isKindOfClass:[Connection class]]){
                Connection * conn = [allElementsArray objectAtIndex:i];
                allowForClass = [self areWeAllowingInstancesOfClassName:conn.className];
            }
            
            //If allowForclass == NO, nos lo saltamos
            if(allowForClass == YES){
                if([[allElementsArray objectAtIndex:i]isKindOfClass:[Component class]]){
                    Component * temp = [allElementsArray objectAtIndex:i];
                    
                    if(text.length == 0){ // solo tengo en cuenta la clase
                        [filteredArray addObject:temp];
                    }else{
                        for(ClassAttribute * atr in temp.attributes){ //Para cada atributo, si el current value contiene la cadena (y no está añadido) lo añado a filtered
                            NSRange range = [atr.currentValue rangeOfString:text options:NSCaseInsensitiveSearch];
                            if(range.location != NSNotFound)
                            {
                                if(![filteredArray containsObject:temp]){
                                    [filteredArray addObject:temp];
                                }
                            }
                        }
                    }
                    
                    
                }else if([[allElementsArray objectAtIndex:i]isKindOfClass:[Connection class]]){
                    Connection * temp = [allElementsArray objectAtIndex:i];
                    
                    if(text.length == 0){
                        [filteredArray addObject:temp];
                    }else{
                        for(ClassAttribute * atr in temp.attributes){ //Para cada atributo, si el current value contiene la cadena (y no está añadido) lo añado a filtered
                            NSRange range = [atr.currentValue rangeOfString:text options:NSCaseInsensitiveSearch];
                            if(range.location != NSNotFound)
                            {
                                if(![filteredArray containsObject:temp]){
                                    [filteredArray addObject:temp];
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
    //}
}
#pragma  mark UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text{
    if(text.length == 0){
        isFiltered = NO;
    }else{
        isFiltered = YES;
        filteredArray = [[NSMutableArray alloc] init];
        
        [self doFilterForText:text];
        
        /*
         for(Component * com in dele.components){
         NSRange nameRange = [com.className rangeOfString:text options:NSCaseInsensitiveSearch];
         
         if(nameRange.location != NSNotFound)
         {
         [filteredArray addObject:com];
         }
         }*/
    }
    [componentsTable reloadData];
}

-(BOOL)areWeAllowingInstancesOfClassName: (NSString *)name{
    BOOL result = YES;
    
    
    return result;
}


- (IBAction)showClassesFilter:(id)sender {
    
    classFilter =    [[[NSBundle mainBundle] loadNibNamed:@"ClassesFilterView"
                                                    owner:self
                                                  options:nil] objectAtIndex:0];
    
    classFilter.delegate = self;
    
    [classFilter setFrame:self.view.frame];
    
    
    classFilter.classesArray = classesArray;
    
    [classFilter prepare];
    
    [self.view addSubview:classFilter];
}

- (IBAction)showAttributesFilter:(id)sender {
    attrFilter = [[[NSBundle mainBundle]loadNibNamed:@"AttributesFilterView" owner:self options:nil]objectAtIndex:0];
    attrFilter.delegate = self;
    [attrFilter setFrame:self.view.frame];
    attrFilter.attrsArray = attrsArray;
    
    
    [attrFilter prepare];
    
    [self.view addSubview:attrFilter];
    
}

- (IBAction)closeList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ClassesFilterViewDelegate
-(void)closedClassedFilterView{
    [self doFilterForText:searchBar.text];
}

#pragma mark AttributesFilgerviewDelegate
-(void)closedAttributesFilterView{
    [self doFilterForText:searchBar.text];
}
@end
