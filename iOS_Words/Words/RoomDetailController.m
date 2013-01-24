//
//  RoomDetailController.m
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

#import "RoomDetailController.h"
#import "LoginViewController.h"
#import "ViewController.h"



@implementation RoomDetailController

@synthesize delegate,statuss,readyRequest,mRoomRequest,usrNames,timer;

-(void)setRoomPath:(NSString*)path Title:title RoomID:(int)room{

    roomURL = [NSURL URLWithString:path];
    roomID = room;
    roomName = title;

}

-(void)onTimer{
    
    [self refreshRoom];
}



-(void)refreshRoom{

    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:roomURL];
    [theRequest setHTTPMethod:@"GET"];
    //[theRequest setHTTPBody:[login data]];
    [theRequest setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    self.mRoomRequest = theConnection;
    [theConnection release];   
    
    [ViewController saveRequestDate:[NSDate date] To:2];

}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *headView;
    int headViewHeight;
    
    if([ViewController getIsLogs]==YES){
        headViewHeight = 150;
    }else{
        headViewHeight = 50;
    }
    
    headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, headViewHeight)];
    
    UISwitch *logSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(10, headViewHeight-40, 80, 40)];
    [logSwitch addTarget:self action:@selector(toggleLogsView:) forControlEvents:UIControlEventValueChanged];
    logSwitch.on = [ViewController getIsLogs];
    [headView addSubview:logSwitch];
    [logSwitch release];
    
    
    logTxt = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    logTxt.backgroundColor = [UIColor blackColor];
    logTxt.textColor = [UIColor greenColor];
    logTxt.editable = NO;
    logTxt.hidden = ![ViewController getIsLogs];
    [headView addSubview:logTxt];
    [logTxt release];
    
    tabelView.tableHeaderView = headView;
    titleItem.title = roomName;

    [self refreshRoom];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];	

    // Uncomment the following line to preserve selection between presentations.
     //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)toggleLogsView:(UISwitch*)sender{
    
    UIView *headerView = tabelView.tableHeaderView;
    
    if(sender.on==YES){
        [headerView setFrame:CGRectMake(0, 0, 320, 150)];
        logTxt.hidden=NO;
        sender.frame = CGRectMake(10, 110, 80, 40);
    }else{
        [headerView setFrame:CGRectMake(0, 0, 320, 50)];
        logTxt.hidden=YES;
        sender.frame = CGRectMake(10, 15, 80, 40);
    }
    
    tabelView.tableHeaderView = headerView;
    [ViewController setIsLogs:sender.on];

    NSLog(@"logs value changed - %i ",sender.on);
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [usrNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSInteger row = [indexPath row];
    
    
    if([[usrNames objectAtIndex:row]isEqualToString:[LoginViewController getMyName]]){
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@       Status:%i",[usrNames objectAtIndex:row],isJoind];

    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@       Status:%@",[usrNames objectAtIndex:row],[statuss objectAtIndex:row]];
    }
    
    return cell;
    
}


-(IBAction)back{
    
    isJoind = 0;
    
    if([timer isValid]){
        [timer invalidate];
    }
    
    [self.delegate RoomDetailControllerDidFinish:self];
}

-(IBAction)userReady:(UIBarItem*)sender{

    [sender setEnabled:NO];
    [self join];

}


-(void)join{
    
    isJoind = 1;
        
    NSString *path = [NSString stringWithFormat:@"%@/gamecenter/room/%i/startgame", SERVER_HOST, roomID];
        
    NSURL* url = [NSURL URLWithString:path];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"GET"];
    [theRequest setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
        
    NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    self.readyRequest = theConnection;
    [theConnection release];    
        
    [ViewController saveRequestDate:[NSDate date] To:3];

    [self refreshRoom];
}

-(void)startGame{
    
    [timer invalidate];
    [self.delegate RoomDetailControllerDidFinishAndJoin:self];	

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - HTTPConnection Delegete methords
// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response 通过response的响应，判断是否连接存在
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
   // NSLog(@"--didReceiveResponse");

}


// -------------------------------------------------------------------------------
//	connection:didReceiveData:data，通过data获得请求后，返回的数据，数据类型NSData
// -------------------------------------------------------------------------------
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    if(connection == self.mRoomRequest){
        
        @try{
            
            RoomStatusResponse *response = [RoomStatusResponse parseFromData:data];
           
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            NSMutableArray *statusArr = [[NSMutableArray alloc]init];
           
           
            User *user;
            int c = [response.users count];
           
            for(int i = 0; i < c ; i++){
                user = [response.users objectAtIndex:i];
                // str = [NSString stringWithFormat:@"%@    Status: %i",user.userName,user.userStatus];
                // NSLog(@"user s username %@ ",str);
                [arr addObject:user.userName];
               
                [statusArr addObject:[NSString stringWithFormat:@"%i",user.userStatus]];
            
                NSLog(@"!!!!! Response of RoomStatusResponse = { name: %@  status:%i }",user.userName,user.userStatus);
            }
        
            self.usrNames = arr;
            self.statuss = statusArr;
           
            [tabelView reloadData];
            [arr release];
            [statusArr release];
            arr = nil;
            statusArr = nil;
        
            if([ViewController getIsLogs]==YES){
        
                logTxt.text =[ViewController requestIncrease:2];
                NSLog(@"%@   - %@",logTxt,logTxt.text);
            
            }
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
    } else if(connection == self.readyRequest) {
        
        @try{
            
            GameStatusResponse *response = [GameStatusResponse parseFromData:data];
           
            int c = [response.statusList count];
           
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            NSMutableArray *arr2 = [[NSMutableArray alloc]init];
           
            GameStatusResponse_UserGameStatus *statusList;
           
            BOOL isReady=YES;
           
            for(int i = 0; i < c;i++){
                statusList = [response statusListAtIndex:i];
               
                [arr addObject:[NSString stringWithFormat:@"%i",statusList.userStatus]];
                [arr2 addObject:statusList.userName];
                
                if(statusList.userStatus==0){
                    isReady = NO;
                }
               
                NSLog(@"********* Response of GameStatusResponse = { name: %@  status:%i }",statusList.userName,statusList.userStatus);
            }
           
            self.statuss = arr;
            self.usrNames = arr2;
           
            [arr release];
            [arr2 release];
            arr = nil;
            arr2 = nil;
           
            [tabelView reloadData];
           
           
            if([ViewController getIsLogs]==YES){
                logTxt.text =[ViewController requestIncrease:3];
            }
           
            NSTimer *time;
           
            // check for startGame
            if(isReady){
                time = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(startGame) userInfo:nil repeats:NO];
            }else{
                time = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(join) userInfo:nil repeats:NO];
            }
            
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
    //NSLog(@"Detail--connectionDidFinishLoading");
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    
}

- (void)dealloc {
    if(logTxt)[logTxt release];
    
    [usrNames release];
    [timer release];
    [statuss release];
    [mRoomRequest release];
    [readyRequest release];
    NSLog(@"detail released");
    [super dealloc];
	
}


@end
