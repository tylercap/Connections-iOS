//
//  MyCollectionViewCell.m
//  connections
//
//  Created by Tyler Cap on 2/5/15.
//  Copyright (c) 2015 Tyler Cap. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

-(void)updateValue:(NSInteger)value
{
    [self highlightPlayerCard];
    
    self.value = value;
    self.title.text = [self getEmoji:value];
}

-(void)setLabel:(NSInteger)value
            row:(NSInteger)row
         column:(NSInteger)column
      cardOwner:(NSInteger)cardOwner
    deviceOwner:(NSInteger)deviceOwner
        players:(Boolean)playerCard
         parent:(UIViewController *)parent
         myTurn:(Boolean)myTurn;
{
    self.value = value;
    self.row = row;
    self.column = column;
    self.parentController = parent;
    self.cardOwner = cardOwner;
    self.deviceOwner = deviceOwner;
    self.playerCard = playerCard;
    self.myTurn = myTurn;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self.title setFont:[UIFont systemFontOfSize:24]];
    }
    
    self.title.text = [self getEmoji:value];
    
    self.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    self.layer.borderWidth = 1.2;
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    [self setBackground];
    
    if( myTurn ){
        if( playerCard ){
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(highlightPlayerCard)];
            
            [self addGestureRecognizer:singleTapGestureRecognizer];
        }
        else{
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileClicked)];
            
            [self addGestureRecognizer:singleTapGestureRecognizer];
        }
    }
    else{
        self.userInteractionEnabled = NO;
    }
}

- (void)setBackground
{
    if( _isHighlighted ){
        self.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.2 alpha:1.0];
    }
    else{
        //        switch( _owner ){
        //            case 1:
        //                self.backgroundColor = [UIColor colorWithRed:0.3 green:0.5 blue:1 alpha:0.5];
        //                break;
        //            case 2:
        //                self.backgroundColor = [UIColor colorWithRed:1 green:0.35 blue:0.3 alpha:0.5];
        //                break;
        //            default:
        //                self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        //                break;
        //        }
        
        if( _cardOwner == 1 || _cardOwner == 2 ){
            if( _cardOwner == _deviceOwner ){
                self.backgroundColor = [UIColor colorWithRed:0.3 green:0.5 blue:1 alpha:0.5];
            }
            else{
                self.backgroundColor = [UIColor colorWithRed:1 green:0.35 blue:0.3 alpha:0.5];
            }
        }
        else{
            self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        }
    }
}

- (void)tileClicked
{
    if(_isHighlighted){
        MyCollectionViewController *mcvc = (MyCollectionViewController*)_parentController;
        
        _cardOwner = [mcvc highlightedTileClicked:_value row:_row column:_column];
        
        [self setBackground];
    }
}

- (void)highlightTile:(Boolean)highlight
{
    _isHighlighted = highlight;
    [self setBackground];
}

- (void)highlightPlayerCard
{
    [self highlightPlayerCard:!_isHighlighted];
}

- (void)highlightPlayerCard:(Boolean)highlight
{
    MyCollectionViewController *mcvc = (MyCollectionViewController*)_parentController;
    
    if(highlight){
        [mcvc highlightOptions:YES forValue:_value];
        //        self.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.2 alpha:1.0];
    }
    else{
        [mcvc highlightOptions:NO forValue:_value];
    }
    _isHighlighted = highlight;
    [self setBackground];
}

// set up with 45 for a 10 x 9
// instead will only need 38 for a 9 x 8 with 2 extra "wild" and "remove" characters
- (NSString*)getEmoji:(NSInteger)value
{
    NSString *str;
    switch( value ){
        case -2:
            str = @"\U000026A1"; // lightning
            break;
        case -1:
            str = @"\U0001F340"; // four leaf clover
            break;
        case 0:
            str = @"\U0001F603";
            break;
        case 1:
            str = @"\U0001F3C8";
            break;
        case 2:
            str = @"\U0001F4A9";
            break;
        case 3:
            str = @"\U0001F431";
            break;
        case 4:
            str = @"\U0001F680";
            break;
        case 5:
            str = @"\U0001F3C0";
            break;
        case 6:
            str = @"\U0001F64A";
            break;
        case 7:
            str = @"\U0001F3AF";
            break;
        case 8:
            str = @"\U0001F385";
            break;
        case 9:
            str = @"\U0000231B";
            break;
        case 10:
            str = @"\U000023F0";
            break;
        case 11:
            str = @"\U00002600";
            break;
        case 12:
            str = @"\U00002614";
            break;
        case 13:
            str = @"\U00002615";
            break;
        case 14:
            str = @"\U0001F364";
            break;
        case 15:
            str = @"\U000026BD";
            break;
        case 16:
            str = @"\U0001F383";
            break;
        case 17:
            str = @"\U000026F3";
            break;
        case 18:
            str = @"\U0001F37B";
            break;
        case 19:
            str = @"\U0001F36A";
            break;
        case 20:
            str = @"\U0001F335";
            break;
        case 21:
            str = @"\U0001F339";
            break;
        case 22:
            str = @"\U0001F33B";
            break;
        case 23:
            str = @"\U0001F33D";
            break;
        case 24:
            str = @"\U0001F369";
            break;
        case 25:
            str = @"\U0001F344";
            break;
        case 26:
            str = @"\U0001F346";
            break;
        case 27:
            str = @"\U0001F347";
            break;
        case 28:
            str = @"\U0001F349";
            break;
        case 29:
            str = @"\U0001F34A";
            break;
        case 30:
            str = @"\U0001F34D";
            break;
        case 31:
            str = @"\U0001F352";
            break;
        case 32:
            str = @"\U0001F354";
            break;
        case 33:
            str = @"\U0001F355";
            break;
        case 34:
            str = @"\U0001F357";
            break;
        case 35:
            str = @"\U0001F35F";
            break;
            //        case 36:
            //            str = @"\U0001F6B6";
            //            break;
            //        case 37:
            //            str = @"\U0001F64F";
            //            break;
            //        case 38:
            //            str = @"\U0001F30F";
            //            break;
            //        case 39:
            //            str = @"\U0001F308";
            //            break;
            //        case 40:
            //            str = @"\U000026C4";
            //            break;
            //        case 41:
            //            str = @"\U0001F6B2";
            //            break;
            //        case 42:
            //            str = @"\U0001F691";
            //            break;
        default:
            str = @"";
    }
    
    NSData *data = [str dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    data = [valueUnicode dataUsingEncoding:NSUTF8StringEncoding];
    NSString *valueEmoji = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    return valueEmoji;
}

@end