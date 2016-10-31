//
//  MatchesShoesViewController.m
//  FittedSolution
//
//  Created by Waqar Ali on 06/10/2016.
//  Copyright © 2016 Waqar Ali. All rights reserved.
//

#import "MatchesShoesViewController.h"

#define Dress           @"Dress - Dress Port Modern"
#define Dress_Casual    @"Dress/Casual - Total Motion Fusion"
#define Casual          @"Casual - Get your kicks"

@interface MatchesShoesViewController ()
{
    NSArray *shoes, *category_A_Shoes, *category_B_Shoes, *category_C_Shoes;
    
    int totalMatchedItems;
    NSInteger category_A_count;
    NSInteger category_B_count;
    NSInteger category_C_count;
    
    NSInteger noOfCategories_R;
    
    UIScrollView *scrollViewA;
    UIScrollView *scrollViewB;
    UIScrollView *scrollViewC;
    
    UIButton *buttonLeft_Category_A;
    UIButton *buttonLeft_Category_B;
    UIButton *buttonLeft_Category_C;
    
    UIButton *buttonRight_Category_A;
    UIButton *buttonRight_Category_B;
    UIButton *buttonRight_Category_C;
}

@property (assign, nonatomic) NSInteger              numberOfCategories;
@property (strong, nonatomic) NSArray <NSString *> * categories;

@end

@implementation MatchesShoesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _categories = [[NSArray alloc] initWithObjects:Dress, Dress_Casual, Casual, nil];
    
    
    category_A_Shoes = [[NSArray alloc] initWithObjects:@"dressport modern+", @"DresSports 2 Lite Apron Toe", @"DresSports 2 Lite Bike Toe Slip-On", @"DresSports 2 Lite Plain Toe Oxford", @"DresSports 2 Lite Wingtip", @"DresSports Luxe Apron Toe Oxford", @"DresSports Luxe Bike Toe Slip-On", @"DresSports Luxe Cap Toe Oxford", @"DresSports Luxe Wingtip Oxford", @"DresSports Modern Apron Toe", @"DresSports Modern Bike Toe Slip-On", @"DresSports Modern Cap Toe", @"DresSports Modern Chelsea", @"DresSports Modern Wingtip", nil];
    category_B_Shoes = [[NSArray alloc] initWithObjects:@"Get Your Kicks Blucher", @"Get Your Kicks Mudguard Blucher", @"Get Your Kicks Slip On", nil];
    category_C_Shoes = [[NSArray alloc] initWithObjects:@"Total Motion Fusion Chukka", @"Total Motion Fusion Plain Toe", @"Total Motion Fusion Wing Tip", @"Total Motion PD Slip-On", @"Total Motion PS Chelsea", @"Total Motion PS Plain Toe", @"Total Motion PS Wing Tip", nil];
    
    
    //  random work
    
    noOfCategories_R = [self randomNumberBetween:1 maxNumber:3];

    if (noOfCategories_R == 1)
    {
        _categories = [[NSArray alloc] initWithObjects:Dress, nil];
    }
    else if (noOfCategories_R == 2)
    {
        _categories = [[NSArray alloc] initWithObjects:Dress, Dress_Casual, nil];
    }
    else if(noOfCategories_R == 3)
    {
        _categories = [[NSArray alloc] initWithObjects:Dress, Dress_Casual, Casual, nil];
    }
    
    //
    
    shoes =  [[NSArray alloc] initWithObjects:@"dressport modern+", @"DresSports 2 Lite Apron Toe", @"DresSports 2 Lite Bike Toe Slip-On", @"DresSports 2 Lite Plain Toe Oxford", @"DresSports 2 Lite Wingtip", @"DresSports Luxe Apron Toe Oxford", @"DresSports Luxe Bike Toe Slip-On", @"DresSports Luxe Cap Toe Oxford", @"DresSports Luxe Wingtip Oxford", @"DresSports Modern Apron Toe", @"DresSports Modern Bike Toe Slip-On", @"DresSports Modern Cap Toe", @"DresSports Modern Chelsea", @"DresSports Modern Wingtip", @"Get Your Kicks Blucher", @"Get Your Kicks Mudguard Blucher", @"Get Your Kicks Slip On", @"Total Motion Fusion Chukka", @"Total Motion Fusion Plain Toe", @"Total Motion Fusion Wing Tip", @"Total Motion PD Slip-On", @"Total Motion PS Chelsea", @"Total Motion PS Plain Toe", @"Total Motion PS Wing Tip", nil];
    
    [self createAndLoadViews];
}

-(void)viewWillDisappear:(BOOL)animated
{
    category_int = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - buttons action

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - helper methods

-(void)createAndLoadViews
{
    int count = 0;
    
    UILabel      * categoryName;
    UILabel      * countLabel;
    UIImageView  * countBackgound;
    UIView       * scrollViewContainer;
    UIScrollView * scrollView;
    UIButton     * buttonRight;
    UIButton     * buttonLeft;
    
    categoryName = [[UILabel alloc] initWithFrame:CGRectMake(17, 24, 50, 21)];
    
    for (NSString * category in _categories)
    {
        if (count > 0)
        {
            categoryName          = [[UILabel alloc] initWithFrame:CGRectMake(17, scrollViewContainer.frame.origin.y+scrollViewContainer.frame.size.height+10, 50, 21)];
        }
        
        categoryName              = [self adjustWidthOfLabel:categoryName forText:category];
        categoryName.textColor    = [UIColor darkGrayColor];
        
        // category countBackground image
        countBackgound            = [[UIImageView alloc] initWithFrame:CGRectMake(categoryName.frame.origin.x+categoryName.frame.size.width+10, categoryName.frame.origin.y-2, 17,17)];
        countBackgound.image      = [UIImage imageNamed:@"CountBackground"];
        
        // category count label
        countLabel                = [[UILabel alloc] initWithFrame:countBackgound.frame];
        countLabel.textColor      = [UIColor whiteColor];
        countLabel.font           = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        countLabel.textAlignment  = NSTextAlignmentCenter;
        
        
        // category shoes scrollview container
        scrollViewContainer                  = [[UIView alloc] initWithFrame:CGRectMake(0, categoryName.frame.origin.y+categoryName.frame.size.height+10, self.view.frame.size.width, 110)];
        scrollViewContainer.backgroundColor  = [UIColor colorWithRed:0.86 green:0.87 blue:0.86 alpha:1.0];
        scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // scrollview
        scrollView                = [[UIScrollView alloc] initWithFrame:CGRectMake(30,6,self.view.frame.size.width-60, 98)];
        scrollView.tag            = count;
        [self setupHorizontalScrollView:scrollView withShoes:shoes];
        [scrollViewContainer addSubview:scrollView];
        
        // left right arrow buttons
        buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(1, 30, 28, 52)];
        [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
        [buttonLeft addTarget: self action: @selector(buttonLeftClicked:) forControlEvents: UIControlEventTouchUpInside];
        [scrollViewContainer addSubview:buttonLeft];
        
        buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-29, 30, 28, 52)];
        [buttonRight setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        [buttonRight addTarget: self action: @selector(buttonRightClicked:) forControlEvents: UIControlEventTouchUpInside];
        [scrollViewContainer addSubview:buttonRight];
        
        // add subviews to main container
        [_mainViewContainer addSubview:categoryName];
        [_mainViewContainer addSubview:countBackgound];
        [_mainViewContainer addSubview:countLabel];
        [_mainViewContainer addSubview:scrollViewContainer];
        
        
        if (count == 0)
        {
            countLabel.text           = [NSString stringWithFormat:@"%ld",(long)category_A_count];
            totalMatchedItems += category_A_count;
            
            buttonLeft.tag = 0;
            buttonRight.tag = 1;
            
            buttonLeft_Category_A = buttonLeft;
            buttonRight_Category_A = buttonRight;
            
            if (category_A_count > 3)
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            }
            else
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
                
                buttonLeft.userInteractionEnabled = NO;
                buttonRight.userInteractionEnabled = NO;
            }
        }
        else if (count == 1)
        {
            countLabel.text           = [NSString stringWithFormat:@"%ld",(long)category_B_count];
            totalMatchedItems += category_B_count;
            
            buttonLeft.tag = 2;
            buttonRight.tag = 3;
            
            buttonLeft_Category_B = buttonLeft;
            buttonRight_Category_B = buttonRight;
            
            if (category_B_count > 3)
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            }
            else
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
                
                buttonLeft.userInteractionEnabled = NO;
                buttonRight.userInteractionEnabled = NO;
            }
        }
        else if (count == 2)
        {
            countLabel.text           = [NSString stringWithFormat:@"%ld",(long)category_C_count];
            totalMatchedItems += category_C_count;
            
            buttonLeft.tag = 4;
            buttonRight.tag = 5;
            
            buttonLeft_Category_C = buttonLeft;
            buttonRight_Category_C = buttonRight;
            
            if (category_C_count > 3)
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            }
            else
            {
                [buttonLeft setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
                
                buttonLeft.userInteractionEnabled = NO;
                buttonRight.userInteractionEnabled = NO;
            }
        }
        
        count +=1;
    }
    _totalMatchesLabel.text = [NSString stringWithFormat:@"Total Matched Items: %d",totalMatchedItems];
}

- (int)randomNumberBetween:(int)min maxNumber:(int)max
{
    return min + arc4random_uniform(max - min + 1);
}

-(UILabel *)adjustWidthOfLabel:(UILabel *)label forText:(NSString *)text
{
    UIFont *font                =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    NSDictionary * attributes   = @{NSFontAttributeName:font};
    CGSize size                 = [text sizeWithAttributes:attributes];
    
    [label setFont:font];
    [label setFrame:CGRectMake(label.frame.origin.x,label.frame.origin.y,size.width,size.height)];
    [label setText:text];
    
    return label;
}

int category_int = 0;

- (void)setupHorizontalScrollView:(UIScrollView *)scrollView withShoes:(NSArray *)shoesArray
{
    scrollView.delegate = self;
    
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    
    UIImageView *imageThumbnail;
    UIView *imageThumbnailContainer;
    
    float padding = 7.5;
    
    imageThumbnailContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, 6, 77, 86)];
    imageThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageThumbnailContainer.frame.size.width, imageThumbnailContainer.frame.size.height)];
    
    float xAxis = padding;
    
    
    // random work
    NSMutableArray *shoes_Array = [shoesArray mutableCopy];
    
    if (category_int == 0)
    {
        scrollViewA = scrollView;
        
        NSInteger r= [self randomNumberBetween:1 maxNumber:13];
        [shoes_Array removeAllObjects];
        for (int j=0 ; j<r ; j++)
        {
            [shoes_Array addObject:[category_A_Shoes objectAtIndex:j]];
        }
        category_A_count = shoes_Array.count;
    }
    if (category_int == 1)
    {
        scrollViewB = scrollView;
        
        NSInteger r= [self randomNumberBetween:1 maxNumber:2];
        [shoes_Array removeAllObjects];
        for (int j=0 ; j<r ; j++)
        {
            [shoes_Array addObject:[category_B_Shoes objectAtIndex:j]];
        }
        category_B_count = shoes_Array.count;
    }
    if (category_int == 2)
    {
        scrollViewC = scrollView;
        
        NSInteger r= [self randomNumberBetween:1 maxNumber:7];
        [shoes_Array removeAllObjects];
        for (int j=0 ; j<r ; j++)
        {
            [shoes_Array addObject:[category_C_Shoes objectAtIndex:j]];
        }
        category_C_count = shoes_Array.count;
    }
    category_int +=1;
    //
    
    
    for(int i=0 ; i < shoes_Array.count ; i++)
    {
        CGRect frame;
        
        if (i>0)
        {
            imageThumbnailContainer = [[UIView alloc] initWithFrame:CGRectMake(padding, 6, 77, 86)];
            imageThumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageThumbnailContainer.frame.size.width, imageThumbnailContainer.frame.size.height)];
            
            frame.origin.x = xAxis ;
            frame.origin.y = 6;
            frame.size     = imageThumbnailContainer.frame.size;
            
            imageThumbnailContainer.frame = frame;
        }
        
        xAxis = xAxis + imageThumbnailContainer.frame.size.width + padding;
        
        imageThumbnail.image = [UIImage imageNamed: [NSString stringWithFormat:@"%@.PNG",[shoes_Array objectAtIndex:i]]];
        imageThumbnail.tag = i+1;
        [imageThumbnailContainer addSubview:imageThumbnail];
        
        // add tap gesture to thumbnail
        imageThumbnail.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showThumbnailTapped:)];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture setNumberOfTouchesRequired:1];
        [imageThumbnail addGestureRecognizer:tapGesture];
        
        [scrollView addSubview:imageThumbnailContainer];
    }

    scrollView.contentSize = CGSizeMake( (shoes_Array.count * imageThumbnailContainer.frame.size.width) + (shoes_Array.count * padding) + padding, scrollView.frame.size.height);
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIScrollView *scroll_View ;
    if (scrollView.tag == 0)
    {
        scroll_View = scrollViewA;
    }
    else if (scrollView.tag == 1)
    {
        scroll_View = scrollViewB;
    }
    else if (scrollView.tag == 2)
    {
        scroll_View = scrollViewC;
    }
    
    float scrollViewWidth = scroll_View.frame.size.width;
    float scrollContentSizeWidth = scroll_View.contentSize.width;
    float scrollOffset = scroll_View.contentOffset.x;
    
    if (scrollOffset == 0)
    {
        NSLog(@"Right -- Start");
        
        if (scrollView.tag == 0 && category_A_count > 3)
        {
            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
        else if (scrollView.tag == 1 && category_B_count > 3)
        {
            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
        else if (scrollView.tag == 2 && category_C_count > 3)
        {
            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
    }
    else if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
    {
        NSLog(@"Right -- End");
        
        if (scrollView.tag == 0 && category_A_count > 3)
        {
            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
        else if (scrollView.tag == 1 && category_B_count > 3)
        {
            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
        else if (scrollView.tag == 2 && category_C_count > 3)
        {
            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
    }
}


- (void) buttonLeftClicked:(id)sender
{
    UIScrollView *scroll_View;
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 0)
    {
        scroll_View = scrollViewA;
    }
    else if (button.tag == 2)
    {
        scroll_View = scrollViewB;
    }
    else if (button.tag == 4)
    {
        scroll_View = scrollViewC;
    }
    
    float width = CGRectGetWidth(scroll_View.frame);
    float height = CGRectGetHeight(scroll_View.frame);
    float newPosition = scroll_View.contentOffset.x+width-7;
    CGRect toVisible = CGRectMake(newPosition, 0, width, height);
    
    [scroll_View scrollRectToVisible:toVisible animated:YES];
    
    
    
    float scrollViewWidth = scroll_View.frame.size.width;
    float scrollContentSizeWidth = scroll_View.contentSize.width;
    float scrollOffset = scroll_View.contentOffset.x;
    
    if (scrollOffset == 0)
    {
        NSLog(@"Left -- Start");
        
//        if (button.tag == 0)
//        {
//            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 2)
//        {
//            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 4)
//        {
//            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
    }
    else if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
    {
        NSLog(@"Left -- End");
        
        if (button.tag == 0 && category_A_count > 3)
        {
            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
        else if (button.tag == 2 && category_B_count > 3)
        {
            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
        else if (button.tag == 4 && category_C_count > 3)
        {
            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
        }
    }
    
//    // check the end of scrollview
//    CGFloat rightInset = scroll_View.contentInset.right;
//    CGFloat rightEdge = scroll_View.contentOffset.x + scroll_View.frame.size.width - rightInset;
//    if (rightEdge == scroll_View.contentSize.width)
//    {
//        NSLog(@"End of scrol view");
//        
//        if (button.tag == 0)
//        {
//            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 2)
//        {
//            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 4)
//        {
//            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//    }
}

- (void) buttonRightClicked:(id)sender
{
    UIScrollView *scroll_View;
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 1)
    {
        scroll_View = scrollViewA;
    }
    else if (button.tag == 3)
    {
        scroll_View = scrollViewB;
    }
    else if (button.tag == 5)
    {
        scroll_View = scrollViewC;
    }
    
    float width = CGRectGetWidth(scroll_View.frame);
    float height = CGRectGetHeight(scroll_View.frame);
    float newPosition = scroll_View.contentOffset.x-width+7;
    CGRect toVisible = CGRectMake(newPosition, 0, width, height);
    
    [scroll_View scrollRectToVisible:toVisible animated:YES];
    
    
    float scrollViewWidth = scroll_View.frame.size.width;
    float scrollContentSizeWidth = scroll_View.contentSize.width;
    float scrollOffset = scroll_View.contentOffset.x;
    
    if (scrollOffset == 0)
    {
        NSLog(@"Right -- Start");
        
        if (button.tag == 1 && category_A_count > 3)
        {
            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
        else if (button.tag == 3 && category_B_count > 3)
        {
            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
        else if (button.tag == 5 && category_C_count > 3)
        {
            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
        }
    }
    else if (scrollOffset + scrollViewWidth == scrollContentSizeWidth)
    {
        NSLog(@"Right -- End");
        
//        if (button.tag == 1)
//        {
//            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_A setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 3)
//        {
//            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_B setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 5)
//        {
//            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"LeftArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_C setImage:[UIImage imageNamed:@"RightArrowON"] forState:UIControlStateNormal];
//        }
    }
    
    
//    // check the start of scrollview
//    CGFloat leftInset = scroll_View.contentInset.left;
//    CGFloat leftEdge = scroll_View.frame.size.width - scroll_View.contentOffset.x - leftInset;
//    if (leftEdge == scroll_View.contentSize.width)
//    {
//        NSLog(@"Start of scrol view");
//        
//        if (button.tag == 0)
//        {
//            [buttonLeft_Category_A setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_A setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 2)
//        {
//            [buttonLeft_Category_B setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_B setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
//        }
//        else if (button.tag == 4)
//        {
//            [buttonLeft_Category_C setImage:[UIImage imageNamed:@"RightArrowOFF"] forState:UIControlStateNormal];
//            [buttonRight_Category_C setImage:[UIImage imageNamed:@"LeftArrowON"] forState:UIControlStateNormal];
//        }
//    }
}

- (void)showThumbnailTapped:(id)sender
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)sender;

    if(tapRecognizer.view.tag < 0)
    {
        for(UIImageView *subview in [tapRecognizer.view.superview subviews])
        {
            if (subview.tag == -9999)
            {
                [subview removeFromSuperview];
            }
        }
        tapRecognizer.view.tag = (tapRecognizer.view.tag) + 2 * (-tapRecognizer.view.tag);
    }
    else
    {
        CGRect frame = CGRectMake(tapRecognizer.view.frame.origin.x, tapRecognizer.view.frame.origin.y, 25 , 25);
        UIImageView * selectHoverImageView = [[UIImageView alloc] initWithFrame:frame];
        selectHoverImageView.image = [UIImage imageNamed:@"SelectHover"];
        selectHoverImageView.tag = -9999;
        [tapRecognizer.view.superview addSubview:selectHoverImageView];
        
        tapRecognizer.view.tag = (tapRecognizer.view.tag) - 2 * (tapRecognizer.view.tag);
    }
}

-(void)getCategoryNameOfShoeNamed:(NSString *)shoeImageName
{
    NSString * categoryName;
    
    if ([shoeImageName containsString:@"DresSports"] || [shoeImageName containsString:@"dressport"])
    {
        categoryName = Dress;
    }
    else if([shoeImageName containsString:@"Total Motion"])
    {
        categoryName = Dress_Casual;
    }
    else if([shoeImageName containsString:@"Get Your Kicks"])
    {
        categoryName = Casual;
    }
}

#pragma mark- scrollview delegate method

//-(void)scrollViewDidScroll:(UIScrollView *)sender
//{
//    CGFloat pageWidth = sender.frame.size.width;
//    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    
//    //self.pageControl.currentPage = page;
//}

//        if(count == 1)
//        {
//            // Category 1
//            categoryName              = [[UILabel alloc] initWithFrame:CGRectMake(17, 24, 50, 21)];
//            categoryName              = [self adjustWidthOfLabel:categoryName forText:category];
//
//            countBackgound            = [[UIImageView alloc] initWithFrame:CGRectMake(categoryName.frame.origin.x+categoryName.frame.size.width+10, categoryName.frame.origin.y-2, 17,17)];
//            countBackgound.image      = [UIImage imageNamed:@"CountBackground"];
//
//            countLabel.textColor      = [UIColor whiteColor];
//            countLabel                = [[UILabel alloc] initWithFrame:countBackgound.frame];
//            countLabel.font           = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
//            countLabel.textAlignment  = NSTextAlignmentCenter;
//            countLabel.text           = @"15";
//
//            scrollViewContainer       = [[UIView alloc] initWithFrame:CGRectMake(0, categoryName.frame.origin.y+categoryName.frame.size.height+10, self.view.frame.size.width, 110)];
//            scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//        }
//        else if (count == 2)
//        {
//            // Category 2
//            //categoryName               = [[UILabel alloc] initWithFrame:CGRectMake(17, 215, 50, 21)];
//
//            categoryName               = [[UILabel alloc] initWithFrame:CGRectMake(17, scrollViewContainer.frame.origin.y+scrollViewContainer.frame.size.height+10, 50, 21)];
//            categoryName               = [self adjustWidthOfLabel:categoryName forText:category];
//
//            countBackgound             = [[UIImageView alloc] initWithFrame:CGRectMake(categoryName.frame.origin.x+categoryName.frame.size.width+10, categoryName.frame.origin.y-2, 17,17)];
//            countBackgound.image       = [UIImage imageNamed:@"CountBackground"];
//
//            countLabel.textColor       = [UIColor whiteColor];
//            countLabel                 = [[UILabel alloc] initWithFrame:countBackgound.frame];
//            countLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
//            countLabel.textAlignment   = NSTextAlignmentCenter;
//            countLabel.text            = @"15";
//
//            scrollViewContainer       = [[UIView alloc] initWithFrame:CGRectMake(0, categoryName.frame.origin.y+categoryName.frame.size.height+10, self.view.frame.size.width, 110)];
//        }
//        else if (count == 3)
//        {
//            // Category 3
//            //categoryName              = [[UILabel alloc] initWithFrame:CGRectMake(17, 374, 50, 21)];
//
//            categoryName              = [[UILabel alloc] initWithFrame:CGRectMake(17, scrollViewContainer.frame.origin.y+scrollViewContainer.frame.size.height+10, 50, 21)];
//            categoryName              = [self adjustWidthOfLabel:categoryName forText:category];
//
//            countBackgound            = [[UIImageView alloc] initWithFrame:CGRectMake(categoryName.frame.origin.x+categoryName.frame.size.width+10, categoryName.frame.origin.y-2, 17,17)];
//            countBackgound.image      = [UIImage imageNamed:@"CountBackground"];
//
//            countLabel.textColor      = [UIColor whiteColor];
//            countLabel                = [[UILabel alloc] initWithFrame:countBackgound.frame];
//            countLabel.font           = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
//            countLabel.textAlignment  = NSTextAlignmentCenter;
//            countLabel.text           = @"5";
//
//            scrollViewContainer       = [[UIView alloc] initWithFrame:CGRectMake(0, categoryName.frame.origin.y+categoryName.frame.size.height+10, self.view.frame.size.width, 110)];
//
//        }


@end



