//
//  MyCollectionViewController.m
//  connections
//
//  Created by Tyler Cap on 2/5/15.
//  Copyright (c) 2015 Tyler Cap. All rights reserved.
//

@import GoogleMobileAds;

#import "MyCollectionViewController.h"

static NSString * const CellIdentifier = @"TileCell";
static NSString * const ButtonIdentifier = @"ButtonCell";
static NSString * const LabelIdentifier = @"LabelCell";
static NSString * const BannerIdentifier = @"BannerCell";

//static NSString * const BannerAdId = @"ca-app-pub-8484316959485082/7478851650";
//static NSString * const InterstitialAdId = @"ca-app-pub-8484316959485082/8955584856";

static NSString * const BannerAdId = @"ca-app-pub-8484316959485082/2150010457";

static NSString * const youLost = @"You Lost";
static NSString * const youWon = @"You Win!";

@implementation MyCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    self.model = [[Model alloc]init];
    [self loadGame];
     
    _headerSections = 1;
    _footerSections = 2;
    
    self.playerCards = [[NSMutableArray alloc] initWithCapacity:6];
    self.tiles = [[NSMutableArray alloc] initWithCapacity:9];
    for( int i = 0; i < 9; i++ ){
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
        [self.tiles addObject:items];
    }
    
//    [self loadInterstitial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // display the opponent
    self.navigationItem.title = [self.model getOpponentDisplayName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSString *)determineWhoGoesNext:(GPGTurnBasedMatch *)match {
//    if (!match) {
//        // This isn't really a state I should be in.
//        // Probably raise an exception here.
//        return nil;
//    }
//    
//    // First, we can look at where I am in the
//    // deterministically-ordered participants array.
//    NSUInteger myIndex = [match.participants indexOfObject:match.localParticipant];
//    if (myIndex == NSNotFound) {
//        return nil;
//    }
//    
//    // Next, let's look at how many people in total are in the
//    // round-robin match. This includes participants as well as
//    // players for auto-match.
//    NSInteger totalPlayers = match.participants.count + match.matchConfig.minAutoMatchingPlayers;
//    
//    if (totalPlayers == 1) {
//        // You're the only one left! You shouldn't really get to
//        // this state normally because the
//        // match should switch to a completed state.
//        // Probably the safest thing to do now is just return
//        // the current player again.
//        return match.localParticipantId;
//    }
//    
//    NSUInteger playerToGoNext = (myIndex + 1) % totalPlayers;
//    
//    // Remember, this number might be larger than the participant
//    // array. If it is, that means we're
//    // ready to invite our next automatch player
//    NSString *nextParticipantId;
//    if (playerToGoNext < match.participants.count) {
//        nextParticipantId =
//        ((GPGTurnBasedParticipant *)match.participants[playerToGoNext]).participantId;
//    } else {
//        // Setting our participantID to nil is our way of
//        // telling the system, "Please add the next auto-match player"
//        nextParticipantId = nil;
//    }
//    return nextParticipantId;
//}

- (void)loadGame
{
    // load the game from google play
    [self.model loadFromData:_match];
        
    self.myTurn = self.match.myTurn;
    if( self.myTurn ){
        self.owner = self.model.ownersTurn;
    }
    else{
        if( self.model.ownersTurn == 1 ){
            self.owner = 2;
        }
        else{
            self.owner = 1;
        }
    }
}

-(NSInteger)highlightedTileClicked:(NSInteger)value
                               row:(NSInteger)row
                            column:(NSInteger)column
{
    // remove all highlighting before setting the owner
    Boolean winner = NO;
    for( int i = 0; i < _playerCards.count; i++ ){
        MyCollectionViewCell *card = [_playerCards objectAtIndex:i];
        if(card.isHighlighted){
            NSInteger newValue = [_model newPlayerOption:i owner:self.owner];
            [card updateValue:newValue];
            
            // update model
            if( _removeClicked ){
                // just removing the previous owner
                [_model setOwnerAt:0 row:row column:column];
            }
            else{
                [_model setOwnerAt:self.owner row:row column:column];
            }
            winner = [_model checkForWinner:self.owner row:row column:column];
            
            if( winner ){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:youWon
                                                                message:@"Would you like to challenge your opponent to a rematch?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles:@"Rematch", nil];
                [alert show];
            }
        }
    }
    
    NSInteger currentOwner = self.owner;
    [self submitMove:winner];
    
    //returns the owner int
    return currentOwner;
}

- (void)submitMove:(Boolean)winner
{
    // submit the updated model to google play and set it to the other player's turn
    if( self.model.ownersTurn == 1 ){
        self.model.ownersTurn = 2;
    }
    else{
        self.model.ownersTurn = 1;
    }
    NSData *data = [self.model storeToData];

    GPGTurnBasedParticipant *opponent = [_model getOpponent];
    NSLog(opponent.displayName);
    
//    NSString *nextPlayer = [self determineWhoGoesNext:_match];
    
    if( winner ){
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        GPGTurnBasedParticipantResult *myResult = [[GPGTurnBasedParticipantResult alloc] initWithParticipantId:_match.localParticipantId];
        myResult.placing = 1;
        myResult.result = GPGTurnBasedParticipantResultStatusWin;
        [results addObject:myResult];
        
        GPGTurnBasedParticipantResult *oppResult = [[GPGTurnBasedParticipantResult alloc] initWithParticipantId:opponent.participantId];
        oppResult.placing = 2;
        oppResult.result = GPGTurnBasedParticipantResultStatusLoss;
        [results addObject:oppResult];
        
        [self.match finishWithData:data results:results completionHandler:^(NSError *error)
         {
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:@"Unable To Submit Move"
                                             message:@"Check you internet connection, or try again later."
                                            delegate:self
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
             } else {
                 NSLog(@"Successfully submitted move!");
             }
         }];
    }
    else{
        [self.match takeTurnWithNextParticipantId:opponent.participantId data:data results:_match.results completionHandler:^(NSError *error)
         {
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:@"Unable To Submit Move"
                                             message:@"Check you internet connection, or try again later."
                                            delegate:self
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil] show];
             } else {
                 NSLog(@"Successfully submitted move!");
             }
         }];
    }
    
    self.myTurn = NO;
    [_resignButton setEnabled:NO];
    [self.collectionView reloadData];
}

- (void)resign
{
    NSData *data = [self.model storeToData];
    GPGTurnBasedParticipant *opponent = [_model getOpponent];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    GPGTurnBasedParticipantResult *myResult = [[GPGTurnBasedParticipantResult alloc] initWithParticipantId:_match.localParticipantId];
    myResult.placing = 2;
    myResult.result = GPGTurnBasedParticipantResultStatusLoss;
    [results addObject:myResult];
    
    GPGTurnBasedParticipantResult *oppResult = [[GPGTurnBasedParticipantResult alloc] initWithParticipantId:opponent.participantId];
    oppResult.placing = 1;
    oppResult.result = GPGTurnBasedParticipantResultStatusWin;
    [results addObject:oppResult];
    
    [self.match finishWithData:data results:results completionHandler:^(NSError *error)
    {
          if (error) {
              [[[UIAlertView alloc] initWithTitle:@"Unable To Submit Move"
                                          message:@"Check you internet connection, or try again later."
                                         delegate:self
                                cancelButtonTitle:@"Okay"
                                otherButtonTitles:nil] show];
          } else {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:youLost
                                                              message:@"Would you like to challenge your opponent to a rematch?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Close"
                                                    otherButtonTitles:@"Rematch", nil];
              [alert show];
          }
    }];
    
    self.myTurn = NO;
    [_resignButton setEnabled:NO];
    [self.collectionView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( [alertView.title isEqualToString:youWon] || [alertView.title isEqualToString:youLost] )
    {
        if( buttonIndex == 0 ){
            // go back to home screen
        }
        if( buttonIndex == 1 ){
            // start a rematch
            [self.lobby submitRematch:self.match];
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }
    }
}

-(void)highlightOptions:(Boolean)highlight
               forValue:(NSInteger)value
{
    if( highlight ){
        for( int col = 0; col < _playerCards.count; col++ ){
            MyCollectionViewCell *cell = [_playerCards objectAtIndex:col];
            [cell highlightPlayerCard:NO];
        }
    }
    
    for( int row = 0; row < _tiles.count; row++ ){
        NSMutableArray *rowArr = [_tiles objectAtIndex:row];
        for( int col = 0; col < rowArr.count; col++ ){
            MyCollectionViewCell *cell = [rowArr objectAtIndex:col];
            
            if( value >= 0 && cell.value == value && cell.owner == 0 ){
                _removeClicked = NO;
                [cell highlightTile:highlight];
            }
            else if( value == -2 && cell.owner != 0 && cell.owner != self.owner ){
                // can remove other players card
                _removeClicked = YES;
                [cell highlightTile:highlight];
            }
            else if( value == -1 && cell.owner == 0 ){
                // can be played in any open space
                _removeClicked = NO;
                [cell highlightTile:highlight];
            }
        }
    }
}

//- (void)loadInterstitial
//{
//    self.interstitial = [[GADInterstitial alloc] init];
//    self.interstitial.adUnitID = InterstitialAdId;
//
//    GADRequest *request = [GADRequest request];
//    self.interstitial.delegate = self;
//    [self.interstitial loadRequest:request];
//}

//- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
//    [self loadInterstitial];
//}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.model getSections] + _headerSections + _footerSections;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    if(section == 0){
        // banner ad
        return 1;
    }
    else if(section == (_headerSections + [self.model getSections])){
        // game description
        return 1;
    }
    else if(section == (_headerSections + [self.model getSections] + 1)){
        // 6 "cards" and submit/resign button
        return 7;
    }
    
    return [self.model getItems];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *specialtyCell = [self getSpecialCell:collectionView
                                        cellForItemAtIndexPath:indexPath];
    if( specialtyCell != nil ){
        return specialtyCell;
    }
    
    MyCollectionViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    
    NSInteger row = [indexPath section] - _headerSections;
    NSInteger column = [indexPath item];
    
    NSMutableArray *rowArray = [self.tiles objectAtIndex:row];
    [rowArray insertObject:myCell atIndex:column];
    
    NSInteger value = [self.model getValueAt:row column:column];
    NSInteger owner = [self.model getOwnerAt:row column:column];
    
    [myCell setLabel:value row:row column:column owner:owner players:NO parent:self myTurn:self.myTurn];
    
    return myCell;
}

-(UICollectionViewCell *)getSpecialCell:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger item = [indexPath item];
    
    UICollectionViewCell *cell = nil;
    if( section == 0 ){
        /*if( _bannerAdCell != nil ){
            cell = _bannerAdCell;
        }
        else{*/
            MyBannerCell *bannerCell = [collectionView
                                        dequeueReusableCellWithReuseIdentifier:BannerIdentifier
                                        forIndexPath:indexPath];
            
            
            bannerCell.bannerAd.adUnitID = BannerAdId;
            bannerCell.bannerAd.rootViewController = self;
            [bannerCell.bannerAd loadRequest:[GADRequest request]];
            
            _bannerAdCell = bannerCell;
            cell = bannerCell;
        //}
    }
    else if(section == (_headerSections + [self.model getSections])){
        MyLabelCell *labelCell = [collectionView
                                  dequeueReusableCellWithReuseIdentifier:LabelIdentifier
                                  forIndexPath:indexPath];
        
        [labelCell showHowTo];
        
        cell = labelCell;
    }
    else if(section == (_headerSections + [self.model getSections] + 1)){
        if( item == 6 ){
            MyButtonCell *buttonCell = [collectionView
                                        dequeueReusableCellWithReuseIdentifier:ButtonIdentifier
                                        forIndexPath:indexPath];
            
            UIColor *backColor = [UIColor colorWithRed:0.0 green:0.9 blue:0.01 alpha:1.0];
            UIColor *textColor = [UIColor colorWithWhite:0.0 alpha:1.0];
            [buttonCell setLabel:@"Resign"
                   disabledLabel:@"Opponent's\nTurn"
                       backColor:backColor
                       textColor:textColor
                         rounded:YES];
            
            [buttonCell.button addTarget:self
                                  action:@selector(resign)
                        forControlEvents:UIControlEventTouchUpInside];
            
            _resignButton = buttonCell;
            cell = buttonCell;
            [buttonCell setEnabled:_myTurn];
        }
        else{
            MyCollectionViewCell *myCell = [collectionView
                                            dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                            forIndexPath:indexPath];
            
            NSInteger value = [self.model getPlayerOption:item owner:self.owner];
            
            [myCell setLabel:value row:-1 column:item owner:self.owner players:YES parent:self myTurn:self.myTurn];
            cell = myCell;
            
            [_playerCards insertObject:myCell atIndex:item];
        }
    }
    
    return cell;
}

@end