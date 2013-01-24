//
//  ViewController.m
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

#import "ViewController.h"
#import "LoginViewController.h"
#import "Gamecenter.pb.h"

//=========================== for logs view

#include <arpa/inet.h> 
#include <net/if.h> 
#include <ifaddrs.h> 
#include <net/if_dl.h>
static int requestCount=0;
static int oldSize;

static NSDate* requestDates[5];  
static BOOL isLogs = YES;
static NSString * requestInfos[5]={@"Login",@"RoomList",@"UserList",@"Ready",@"inGame"};
static UITextView* LogTxt;
static UILabel* LogLb;
static uint oldSent;
static uint oldReceive;

//===========================


static int btID[6]={0,0,0,0,0,0};
static BOOL haslogined = NO;;
static int seconds = 120;
static int roomID;
static int userID;



@implementation ViewController

@synthesize timer,HTTPRequest,usrNames;


#pragma Mark - Logs functions

+(BOOL)getIsLogs
{
    return isLogs;
}
+(void)setIsLogs:(BOOL)b
{
     isLogs = b;
}

+ (uint)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc; 
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name=[[[NSString alloc]init]autorelease];
    
    success = getifaddrs(&addrs) == 0;
    if (success) 
    {
        cursor = addrs;
        while (cursor != NULL) 
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            //NSLog(@"ifa_name %s == %@n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN 
            if (cursor->ifa_addr->sa_family == AF_LINK) 
            {
                if ([name hasPrefix:@"en"]) 
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    //NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"]) 
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    //NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    //NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                } 
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }   
    
    LogLb.text = [NSString stringWithFormat:@"  Sent:%d bytes   Received:%d bytes",WiFiSent+WWANSent-oldSent,WiFiReceived+WWANReceived-oldReceive];
    
    return WiFiSent+WiFiReceived+WWANSent+WWANReceived;
    //return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil];
}


+ (void)saveOldWifi
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc; 
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name=[[[NSString alloc]init]autorelease];
    
    success = getifaddrs(&addrs) == 0;
    if (success) 
    {
        cursor = addrs;
        while (cursor != NULL) 
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
//            NSLog(@"ifa_name %s == %@n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK) 
            {
                if ([name hasPrefix:@"en"]) 
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"]) 
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                } 
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }   
    
    oldSent = WiFiSent+WWANSent;
    oldReceive = WiFiReceived+WWANReceived;
    
    //return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil];
}



-(IBAction)clearLogs
{
    requestCount = 0;
    LogTxt.text  = @"";
    oldSize = [ViewController getDataCounters];

}

-(IBAction)toggleLogs:(id)sender
{
    isLogs = !isLogs;
    [self setupUIforLogs];
}

+(NSString*)requestIncrease:(int)requestID
{
    requestCount++;
    NSTimeInterval costTime = [requestDates[requestID] timeIntervalSinceNow];
    uint size = [ViewController getDataCounters];
    
    NSString *str = [NSString stringWithFormat:@"%@Requests: %d    Time: %0.3f   Size:%d    [%@]\n",LogTxt.text,requestCount,-costTime,size-oldSize,requestInfos[requestID]];
        
    if(isLogs){
        LogTxt.text  = str;
    }
        
    oldSize = size;
    return str;
  
}

+(void)saveRequestDate:(NSDate*)date To:(int)requestID{

    if(requestDates[requestID]!=nil){
        [requestDates[requestID] release];
    }
    
    requestDates[requestID]=[date retain];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    oldSize = [ViewController getDataCounters];
    [ViewController saveOldWifi];
    
    LogTxt = logTxt;
    LogLb = logLb;
    
    [super viewDidLoad];

    NSString *Path = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
    NSError *error;
    NSString *txt = [NSString stringWithContentsOfFile:Path encoding:NSUTF8StringEncoding error:&error];
    
    if (txt == nil) {
        // an error occurred
        NSLog(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    
    words = [[txt componentsSeparatedByString:@"\n"]retain];

    allButtons = [[NSArray alloc]initWithObjects:bt1,bt2,bt3,bt4,bt5,bt6, nil];
    allLabels = [[NSArray alloc]initWithObjects:lb1,lb2,lb3,lb4,lb5,lb6, nil];

    [self randomWord];

    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    
    if([userDefult objectForKey:@"Score"]==nil){
        scores = 0;
    }else{
        scores = [[userDefult objectForKey:@"Score"]intValue];
    }
        
//    
//    if([userDefult objectForKey:@"isLogs"]==nil){
//        
//        
//        isLogs = YES;
//        
//    }else{
//        
//        isLogs = [[userDefult objectForKey:@"isLogs"]boolValue];
//        
//    }
    
}

-(void)setupUIforLogs{
    
    logTxt.hidden = !isLogs;
    clearButton.hidden = !isLogs;
    logLb.hidden = !isLogs;

    [UIView beginAnimations:@"updateUI" context:nil];
    [UIView setAnimationDuration:0.1];
    
    if(isLogs){
        gameView.center = CGPointMake(160, 290);
    }else{
        gameView.center = CGPointMake(160, 200);
    }
    
    [UIView commitAnimations];
}


-(void)showLogin{
    
    LoginViewController *controller = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    
	controller.delegate = self;
 
	[self presentModalViewController:controller animated:NO];
	[controller release];
}



-(void)loginViewControllerDidFinish:(LoginViewController*)loginView;
{
    
    if(haslogined==NO){
        haslogined = YES;
        userID = loginView.userID;
        
        [self dismissModalViewControllerAnimated:NO];
        [self showRoomList];
    }
    
}

- (void)RoomControllerDidFinish:(RoomController*)roomCtrl UsrNames:names{
    
    roomID = roomCtrl.roomID;
    self.usrNames = [names retain];
    [names release];
    
    [self dismissModalViewControllerAnimated:NO];
    
    //start game
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    seconds = 120;
    timeLabel.text = @"02:00";
    timeLabel.text = @"Score: 0";
    
    scores=0;
    
    rankTxt.hidden=YES;
    replayBT.hidden=YES;
    
    NSLog(@"OOOOOOOOOOOOOOOOOislog %i",isLogs);
    logSwitch.on = isLogs;
    [self setupUIforLogs];
    
}


-(void)onTimer{
	
    seconds--;

    int min =seconds/60;
    int sec =seconds-60*min;	
    
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    
    // check all users point
    [self updateGameStatus];
    
    // times out
    if(seconds==0){
        [self.timer invalidate];
        return;
    }
    
}


-(void)updateGameStatus{
    
    GameStatusRequest_Builder * requestBuilder = [GameStatusRequest builder];
    
    requestBuilder.userId = userID;
    requestBuilder.points = scores;
    requestBuilder.time = seconds;

    //build StoryRequest to be sent to server
    GameStatusRequest* request = [requestBuilder build];		//newStoryRequestBuilder is invalid from this point onward, do not use again
    
    NSString *path = [NSString stringWithFormat:@"%@/gamecenter/room/%i/updategame", SERVER_HOST, roomID];
    
    NSURL* url = [NSURL URLWithString:path];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    
    [theRequest setHTTPBody:[request data]];
    [theRequest setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    self.HTTPRequest = theConnection;
    [theConnection release];    
    
    [ViewController saveRequestDate:[NSDate date] To:4];

    return;
}

-(IBAction)replay{
    
    //start game
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];	
    
    seconds = 120;
    timeLabel.text = @"02:00";
    timeLabel.text = @"Score: 0";
    
    scores=0;
    
    rankTxt.hidden=YES;
    replayBT.hidden=YES;

}

-(IBAction)showRoomList{
    
    RoomController *controller = [[RoomController alloc]initWithNibName:@"RoomController" bundle:nil];
    controller.delegate=self;
	
	[self presentModalViewController:controller animated:NO];
   
	[controller release];
    
    NSLog(@"showRoomList,,");
    
    if([self.timer isValid]){
        [self.timer invalidate];
    }
    
}


-(IBAction)randomWord{
    
    [self checkWord];
    
    int r = arc4random()%([words count]);

    theWord = [words objectAtIndex:r];
    NSString * t;
    int wordLen = [theWord length];
    
    NSMutableArray * tempButtons = [NSMutableArray arrayWithArray:allButtons];
    
    NSString* abc[26] = {@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"};
    
    for(int i =0; i<6;i++){
        
        [[allLabels objectAtIndex:i]setText:@""];

        r = arc4random()%([tempButtons count]);
        
        if(i<wordLen){
            t = [theWord substringWithRange:NSMakeRange(i, 1)];
        }else{
            t = abc[arc4random()%26];
        }
        [[tempButtons objectAtIndex:r]setTitle:t forState:UIControlStateNormal];
        [[tempButtons objectAtIndex:r]setHidden:NO];
        
        [tempButtons removeObjectAtIndex:r];
    }
    tempButtons = nil;
    
    txtCount = 0;

    NSLog(@"the word is %@",theWord);
}

-(IBAction)deleteText{

    if(txtCount<=0)
        return;

    txtCount--;
    
    [[allLabels objectAtIndex:txtCount]setText:@""];
    [[allButtons objectAtIndex:btID[txtCount]]setHidden:NO];
}

-(IBAction)chooseText:(UIButton*)sender{
    
    
    [[allLabels objectAtIndex:txtCount]setText:[[sender titleLabel]text]];


    btID[txtCount]=sender.tag;

    
    [sender setHidden:YES];
    
    
    txtCount ++;

}

-(void)checkWord{
    

    if(txtCount==0)return;
    
    NSMutableArray *userArray = [[NSMutableArray alloc]init];
    

    for(int i = 0; i<txtCount; i++){
    
        [userArray addObject:[[allLabels objectAtIndex:i]text]];
    
    }
    
    NSString *userString =  [userArray componentsJoinedByString:@""];
    
    NSLog(@"user inputed word: %@",userString);
    
    if([words containsObject:userString]){
    
        NSLog(@"Bingo!!");
        
        scores ++;
        

    
    }
    
    [scoreLable setText:[NSString stringWithFormat:@"Score: %i",scores]];
    
    [userArray release];
    userArray = nil;

}

-(void)saveUserScore{
    
    
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    [userDefult setObject:[NSNumber numberWithInt:scores] forKey:@"Score"];

    
    [userDefult setObject:[NSNumber numberWithBool:isLogs] forKey:@"isLogs"];

}


#pragma mark - HTTPConnection Delegete methords
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response 通过response的响应，判断是否连接存在
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"--didReceiveResponse");
    
    
    
}


// -------------------------------------------------------------------------------
//	connection:didReceiveData:data，通过data获得请求后，返回的数据，数据类型NSData
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSLog(@"Main--didReceiveData %@",data);
    
   
    @try {
        
        
        GameStatusResponse *response = [GameStatusResponse parseFromData:data];
        
        
        
        
        int c = [response.statusList count];
        
        GameStatusResponse_UserGameStatus *statusList;
        
        NSMutableString *str = [[NSMutableString alloc]init];
        
        for(int i = 0; i < c;i++){
            
            statusList = [response statusListAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@'s Score = %i  ;     ",[usrNames objectAtIndex:i] ,statusList.points]];
            
            
        }
        
        statusTxt.text = str;
        
        [str release];
        
        
        
        
        
        if(seconds==0){
            
            NSMutableString *rankStr = [[NSMutableString alloc]initWithString:@"Rank \n\n"];
            
            for(int i = 0; i < c;i++){
                
                statusList = [response statusListAtIndex:i];
                [rankStr appendString:[NSString stringWithFormat:@"%@  Score Is %i\n     ",[usrNames objectAtIndex:i] ,statusList.points]];
                
                
            }
            
            
            rankTxt.text = rankStr;
            rankTxt.hidden=NO;
            replayBT.hidden=NO;
            
            [rankStr release];
            
            
        }
        
        
        
        [ViewController requestIncrease:4];
        
        
    }
    
    @catch (NSException *exception) {

        
        NSLog(@"Caught %@  %@",[exception name],[exception reason]);
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[exception name]
                                                       message:[exception reason]
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil,nil];
        
        [alert show];
        [alert release];
        
    }

}


// -------------------------------------------------------------------------------
//	connection:didFailWithError:error 返回的错误信息
// -------------------------------------------------------------------------------

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"--fail");
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connect fail"
                                                   message:[error localizedDescription]
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil,nil];
    
    [alert show];
    [alert release];
    
    
    
}


// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection 数据请求完毕，这个时候，用法是多线程的时候，通过这个通知，关部子线程
// -------------------------------------------------------------------------------
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
   // NSLog(@"Main--connectionDidFinishLoading");
    
    
}






- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

  

}

- (void)viewDidAppear:(BOOL)animated
{

    
    if(haslogined==NO){
        // haslogined = YES;
        [self showLogin];
    }
    
    [super viewDidAppear:animated];
    
    
    

    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{

	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void) dealloc {
    if(timer)[timer release];
    
    [HTTPRequest release];
    [words release];
    
    [allButtons release];
    [allLabels release];
    
    allButtons = nil;
    allLabels = nil;
    [super dealloc];
}
@end
