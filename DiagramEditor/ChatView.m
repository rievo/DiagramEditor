//
//  ChatView.m
//  ChatTest
//
//  Created by Diego on 5/5/16.
//  Copyright © 2016 Diego. All rights reserved.
//

#import "ChatView.h"
#import "ChatTableViewCell.h"

#define LABEL_WIDTH 200
#define TOP_MARGIN 10
#define BOTTOM_MARGIN 10


#import "Message.h"

@implementation ChatView

@synthesize background;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)sendMessage:(id)sender {
    [self sendMessageAndClear];
}

-(void)prepare{
    //tf.delegate = self;
    messagesArray = [[NSMutableArray alloc] init];
    tv.delegate = self;
    
    [table setDelegate:self];
    [table setDataSource:self];

    dic = [[NSMutableDictionary alloc] init];
    
    dele = [[UIApplication sharedApplication]delegate];
}

-(void)sendMessageAndClear{
    //Send message
    
    Message * mess = [[Message alloc] init];
    mess.content = tv.text;
    mess.date = [NSDate date];
    mess.who = dele.myPeerInfo.peerID;
    
   
    [messagesArray addObject:mess];
    [table reloadData];
    
    
    //Clear textfield
    [tv setText:@""];
    [tv endEditing:YES];
}



#pragma mark UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [messagesArray count];    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    static NSString *MyIdentifier = @"ChatCellId";
    ChatTableViewCell * cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if(cell == nil){
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"ChatTableViewCell"
                                                      owner:self
                                                    options:nil];
        cell = nib[0];
        Message * msg = messagesArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n", msg.content];
        cell.textLabel.numberOfLines = 0;
        [dic setObject:cell forKey:indexPath];
    
    }
    
    
    
    return cell;
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    ChatTableViewCell * cell  = [dic objectForKey:indexPath];
    CGSize labelSize = [cell.textLabel sizeThatFits:CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX)];
    
    if(indexPath.row > messagesArray.count)
        return 0;
    else
     return (TOP_MARGIN + labelSize.height + BOTTOM_MARGIN);
    

}

/*
+ (CGFloat)heightWithText:(NSString *)text
{
    SizingLabel.text = text;
    CGSize labelSize = [SizingLabel sizeThatFits:CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX)];
    
    return (TOP_MARGIN + labelSize.height + BOTTOM_MARGIN);
}*/

#pragma mark UITextView

-(void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect textFieldRect =
    [self convertRect:textView.bounds fromView:textView];
    CGRect viewRect =
    [self convertRect:self.bounds fromView:self];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self setFrame:viewFrame];
    
    [UIView commitAnimations];
}




-(void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self setFrame:viewFrame];
    
    [UIView commitAnimations];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}





@end
