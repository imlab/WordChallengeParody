//
//  RoomController.h
//  Words
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.

//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.

//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//
//  Created on 12-12-16.
//  Copyright (c) 2012年 imlab.cc All rights reserved.
//

#import "Gamecenter.pb.h"

#import <UIKit/UIKit.h>
#import "RoomDetailController.h"
@protocol RoomControllerDelegate;

@interface RoomController : UIViewController<UITableViewDelegate,RoomDetailControllerDelegate>{

    IBOutlet UITableView					*tabelView;
    NSArray *datas;
    
    NSURLConnection *mHTTPConnection;

    NSMutableArray *roomsArray;
    id <RoomControllerDelegate> delegate;
    int  roomID;

    UITextView *logTxt;
    
}
@property (nonatomic, assign) id < RoomControllerDelegate> delegate;

@property (nonatomic, retain) NSURLConnection *mHTTPConnection;
@property (nonatomic, assign) int roomID;


-(void)requestRoomList;
-(IBAction)refreshTable:(id)sender;
-(void)toggleLogsView:(UISwitch*)sender;

@end


@protocol RoomControllerDelegate

- (void)RoomControllerDidFinish:(RoomController*)roomCtrl UsrNames:names;

@end
