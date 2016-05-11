//
//  ChatView.h
//  ChatTest
//
//  Created by Diego on 5/5/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ChatView : UIView<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>{
    CGFloat animatedDistance;
    __weak IBOutlet UITextView *tv;
    __weak IBOutlet UITableView *table;
    
    NSMutableArray * messagesArray;
    
    NSMutableDictionary * dic;
    AppDelegate * dele;
}

- (IBAction)sendMessage:(id)sender;

-(void)prepare;

@property (weak, nonatomic) IBOutlet UIView *background;

@end
