//
//  LoginViewController.m
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
//  Created on 12-12-14.
//  Copyright (c) 2012年 imlab.cc All rights reserved.
//

#import "LoginViewController.h"
#import "Login.pb.h"
#import "ViewController.h"
static  NSString *myName;

@implementation LoginViewController

@synthesize delegate,mHTTPConnection,userID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        

    }
    return self;
}


+(NSString*)getMyName{
    return myName;
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

    // Do any additional setup after loading the view from its nib.
    //**在由presentModalViewController调用时此处不起作用;
    
    [userNameT becomeFirstResponder];
    
    userNameT.delegate = self;
    userPassWordT.delegate = self;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    [self sendLoginRequest];
    return YES;
}


-(void)sendLoginRequest{
    NSLog(@"name %@   pass %@",[userNameT text],[userPassWordT text]);
    
    //StoryRequest builder
    LoginRequest_Builder * loginBuilder = [LoginRequest builder];
    
    [loginBuilder setUsername:[userNameT text]];
    [loginBuilder setPassword:[userPassWordT text]];
    
    //build StoryRequest to be sent to server
    LoginRequest* login = [loginBuilder build];		//newStoryRequestBuilder is invalid from this point onward, do not use again
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pbauth/login", SERVER_HOST]];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[login data]];
    [theRequest setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    self.mHTTPConnection = theConnection;
    [theConnection release];
    
    [ViewController saveRequestDate:[NSDate date] To:0];

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
    
  //NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  //NSLog(@"data %@",s);

    LoginResponse *loginResponse;

    NSLog(@"didReceiveData");

    @try {
        loginResponse = [LoginResponse parseFromData:data];

        if(loginResponse.status == LoginResponse_StatusTypeSuccess){
            
            self.userID=loginResponse.userId;
            [self done];
        }
        
        NSLog(@"loginResponse is %i %i", loginResponse.status,LoginResponse_StatusTypeSuccess);
 
        [ViewController requestIncrease:0];
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
    @finally {
        NSLog(@"@finally");
    }
    
}


// -------------------------------------------------------------------------------
//	connection:didFailWithError:error 返回的错误信息
// -------------------------------------------------------------------------------

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connect fail"
                                                   message:[error localizedDescription]
                                                  delegate:self
                                         cancelButtonTitle:@"Try Again"
                                         otherButtonTitles:@"Cancel",nil];
    
    [alert show];
    [alert release];
}


// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection 数据请求完毕，这个时候，用法是多线程的时候，通过这个通知，关部子线程
// -------------------------------------------------------------------------------
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"--connectionDidFinishLoading");
}


#pragma marks -- UIAlertViewDelegate --  
//根据被点击按钮的索引处理点击事件  
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  
{  
    if(alertView.title == @"Connect fail"){
    
        if(buttonIndex==0){
            [self sendLoginRequest];
        }
        
    }
}  

- (void)done {

	[self.delegate loginViewControllerDidFinish:self];	
    myName = userNameT.text;
 
}


- (void)dealloc {

    [mHTTPConnection release];
    
    NSLog(@"login released");
    [super dealloc];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
