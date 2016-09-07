//
//  SelectRootClasViewController.m
//  DiagramEditor
//
//  Created by Diego on 7/9/16.
//  Copyright © 2016 Diego Vaquero Melchor. All rights reserved.
//

#import "SelectRootClassViewController.h"
#import "JsonClass.h"
#import "ClassAttribute.h"
#import "VisibleClassesViewController.h"

@interface SelectRootClassViewController ()

@end

@implementation SelectRootClassViewController

@synthesize selectedJson;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseJSonFile];
    
    extension = @"";
    classesArray = [[NSMutableArray alloc] init];
    
    table.delegate = self;
    table.dataSource = self;
    
    dele = [[UIApplication sharedApplication]delegate];
    
    [self parseJSonFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)cancelRootClassSelection:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)parseJSonFile{
    NSError *jsonError;
    
    //JsonDic es el fichero JSON (ecore)
    NSMutableDictionary *jsonDict = [NSJSONSerialization
                                     JSONObjectWithData:[selectedJson.content dataUsingEncoding:NSUTF8StringEncoding]
                                     options:NSJSONReadingMutableContainers
                                     error:&jsonError];
    
    extension = [jsonDict objectForKey:@"name"];

    NSArray * classes = [jsonDict objectForKey:@"classes"];
    
    for(NSDictionary * classDic in classes){ //Parse class dic
        
        JsonClass * c = [[JsonClass alloc]  init];
        
        
        //Parse class name
        NSString * className = [classDic objectForKey:@"name"];
        c.name = className;
        
        
        //Parse abstract attribute
        NSString * isAbstractStr = [classDic objectForKey:@"abstract"];
        if([isAbstractStr isEqualToString:@"false"]){
            c.abstract = false;
        }else if([isAbstractStr isEqualToString:@"true"]){
            c.abstract = true;
        }else{
            c.abstract = false;
        }
        
        
        //Parse parents
        NSArray * parentsArray = [classDic objectForKey:@"parents"];
        c.parents = [[NSMutableArray alloc] initWithArray:parentsArray];
        
        
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        //Parse attributes
        NSArray * attrDicArray = [classDic objectForKey:@"attributes"];
        for(NSDictionary * attrDic in attrDicArray){
            ClassAttribute * attr = [[ClassAttribute alloc] init];
            
            
            attr.name = [attrDic objectForKey:@"name"];
            attr.defaultValue = [attrDic objectForKey:@"default"];
            attr.type = [attrDic objectForKey:@"type"];
            
            NSNumber * min = [f numberFromString:[attrDic objectForKey:@"min"]];
            attr.min = min;
            
            NSNumber * max = [f numberFromString:[attrDic objectForKey:@"max"]];
            attr.max = max;
            
            [c.attributes addObject:attr];
        }
        
        
        //Parse references
        NSArray * refDicArray= [classDic objectForKey:@"references"];
        for(NSDictionary * refDic in refDicArray){
            Reference * ref = [[Reference alloc] init];
            
            ref.name = [refDic objectForKey:@"name"];
            ref.target = [refDic objectForKey:@"target"];
            ref.opposite = [refDic objectForKey:@"opposite"];
            
            NSNumber * min = [f numberFromString:[refDic objectForKey:@"min"]];
            ref.min = min;
            
            NSNumber * max = [f numberFromString:[refDic objectForKey:@"max"]];
            ref.max = max;
            
            NSString * contStr = [classDic objectForKey:@"containment"];
            if([contStr isEqualToString:@"false"]){
                ref.containment = false;
            }else if([contStr isEqualToString:@"true"]){
                ref.containment = true;
            }else{
                ref.containment = false;
            }
            
            [c.references addObject:ref];
        }
        
        
        
        [classesArray addObject:c];
        
    }
    
    
    [table reloadData];

}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"setVisibleClasses"]){
   
        VisibleClassesViewController * vc = (VisibleClassesViewController*) segue.destinationViewController;
        vc.root = rootClass;
        vc.classesArray = classesArray;
    }
}


#pragma mark UITableview methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return classesArray.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ecoreCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ecoreCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    JsonClass * class = [classesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = class.name;
    cell.backgroundColor = dele.blue1;
    cell.textLabel.textColor = dele.blue4;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self performSegueWithIdentifier:@"setVisibleClasses" sender:self];
    });
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


@end
