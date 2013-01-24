//
//  RoomDetailController.h
//  Words
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//
//  Created on 12-12-16.
//  Copyright (c) 2012年 imlab.cc All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Gamecenter.pb.h"


@protocol RoomDetailControllerDelegate;

@interface RoomDetailController : UIViewController<UITableViewDelegate>{

    IBOutlet UITableView					*tabelView;
    NSArray *statuss;
    NSArray *usrNames;

    
    id <RoomDetailControllerDelegate> delegate;
    IBOutlet UINavigationItem *titleItem;			

    int roomID;
    
    NSURLConnection  *readyRequest;
    NSURLConnection *mRoomRequest;
    
    NSURL* roomURL;
    NSTimer *timer;
    BOOL isJoind;
    
    UITextView *logTxt;
    
    NSString *roomName;
    
}

@property (nonatomic, assign) id < RoomDetailControllerDelegate> delegate;
//@property (nonatomic, retain) NSArray *datas;
@property (nonatomic, retain) NSArray *statuss;
@property (nonatomic, retain) NSURLConnection  *readyRequest;
@property (nonatomic, retain) NSURLConnection  *mRoomRequest;

@property (nonatomic, retain) NSArray *usrNames;
@property (nonatomic, retain) NSTimer *timer;


//-(void)updateData:(NSArray*)data StatusArray:(NSArray*)StatusArray;
-(void)startGame;
-(void)refreshRoom;
-(void)setRoomPath:(NSString*)path Title:title RoomID:(int)room;
-(void)join;
-(IBAction)userReady:(UIBarItem*)sender;
-(void)toggleLogsView:(UISwitch*)sender;

@end



@protocol RoomDetailControllerDelegate

- (void)RoomDetailControllerDidFinish:(RoomDetailController*)detailView;
- (void)RoomDetailControllerDidFinishAndJoin:(RoomDetailController*)detailView;

@end
