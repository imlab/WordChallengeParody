//
//  ViewController.h
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
//  Created on 12-12-12.
//  Copyright (c) 2012年 imlab.cc All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "RoomController.h"

#define SERVER_HOST @"http://localhost:8000"

@interface ViewController : UIViewController<LoginViewControllerDelegate ,RoomControllerDelegate>{
    
    NSArray *words;
    NSString *theWord;
    NSArray *allButtons;
    NSArray *allLabels;

    int txtCount;
    int scores;
    
    IBOutlet UILabel *scoreLable;
    IBOutlet UILabel *timeLabel;
    IBOutlet UITextView *statusTxt;
    IBOutlet UITextView *rankTxt;
    IBOutlet UIButton *replayBT;;

    
    IBOutlet UILabel *lb1;
    IBOutlet UILabel *lb2;
    IBOutlet UILabel *lb3;
    IBOutlet UILabel *lb4;
    IBOutlet UILabel *lb5;
    IBOutlet UILabel *lb6;
    IBOutlet UIButton *bt1;
    IBOutlet UIButton *bt2;
    IBOutlet UIButton *bt3;
    IBOutlet UIButton *bt4;
    IBOutlet UIButton *bt5;
    IBOutlet UIButton *bt6;

    NSTimer *timer;
    
    
    NSURLConnection *HTTPRequest;
    
    NSArray *usrNames;
    
    
    IBOutlet UITextView* logTxt;
    IBOutlet UILabel* logLb;
    IBOutlet UIView *gameView;
    IBOutlet UISwitch *logSwitch;
    IBOutlet UIButton *clearButton;


}
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSURLConnection *HTTPRequest;
@property (nonatomic, retain)  NSArray *usrNames;
//@property (nonatomic, retain)  NSString *myName;


-(IBAction)randomWord;
-(IBAction)chooseText:(UIButton*)sender;
-(void)checkWord;
-(IBAction)deleteText;
-(void)saveUserScore;
-(void)showLogin;
-(IBAction)showRoomList;
-(void)onTimer;
-(void)updateGameStatus;
-(IBAction)replay;



+(NSString*)requestIncrease:(int)requestID ;
+(void)saveRequestDate:(NSDate*)date To:(int)requestID;
-(IBAction)toggleLogs:(id)sender;
-(IBAction)clearLogs;
+ (uint)getDataCounters;
+ (void)saveOldWifi;

-(void)setupUIforLogs;
+(BOOL)getIsLogs;
+(void)setIsLogs:(BOOL)b;

@end
