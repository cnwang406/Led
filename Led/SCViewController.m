//
//  SCViewController.m
//  Led
//
//  Created by cnwang on 12/24/13.
//  Copyright (c) 2013 cnwang. All rights reserved.
//

#import "SCViewController.h"

#define ColorLed0 blueColor
#define ColorLed1 yellowColor
#define ColorLed2 greenColor
#define ColorLed3 RedColor

#define SparkCoreID "53ff6f065067544847331087"
#define SparkCoreToken "e229c8cd9bd3dba61710b6b7230086bb0f1c0ee5"



@interface SCViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *Led0;
@property (weak, nonatomic) IBOutlet UISwitch *led1;
@property (weak, nonatomic) IBOutlet UISwitch *led2;
@property (weak, nonatomic) IBOutlet UISwitch *led3;
@property (weak, nonatomic) IBOutlet UIButton *allOff;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *ledSwitch;
@property (weak, nonatomic) IBOutlet UITextView *textOutput;

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self allOff];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)switchLeds:(id)sender {
    
    UISwitch *sw = sender;
    NSLog(@"%@",sender);
    
    NSString *param = [NSString stringWithFormat:@"l%lu,%@",(unsigned long)[self.ledSwitch indexOfObject:sender],(sw.on)?@"HIGH":@"LOW"];
    NSLog(@"param=%@",param);
    [self makeAPIRequestWithMessage:param withFunction:@"led"];
    
    NSLog(@"switch %lu changed state to %@", (unsigned long)[self.ledSwitch indexOfObject:sender],
          (sw.on)?@"ON":@"Off");
}

- (IBAction)allOffBbutton:(id)sender {
    
    UISwitch *sw=[[UISwitch alloc]init];
    for (sw in self.ledSwitch){
        NSLog(@"%@",((sw.on))?@"ON":@"Off");
        [sw setOn:NO animated:YES];
    }
    
    NSString *msg = @"";
    [self makeAPIRequestWithMessage:msg withFunction:@"alloff"];
    
}

- (IBAction)allOnButton:(id)sender {
    UISwitch *sw=[[UISwitch alloc]init];
    for (sw in self.ledSwitch){
        
        
        
        NSLog(@"%@",((sw.on))?@"ON":@"Off");
        [sw setOn:YES animated:YES];
        NSString *param = [NSString stringWithFormat:@"l%lu,%@",(unsigned long)[self.ledSwitch indexOfObject:sw],(sw.on)?@"HIGH":@"LOW"];
        [self makeAPIRequestWithMessage:param withFunction:@"led"];

    }

}




- (void)makeAPIRequestWithMessage:(NSString *)param withFunction:(NSString *)function
{
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"https://api.spark.io/v1/devices/%s/%@", SparkCoreID,function]];
    NSLog(@"url=%@",url);
    
    [self cleanResult];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
//    [req setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    
    NSString *msg;
    if ([param isEqualToString:@""]) {
        msg = [NSString stringWithFormat:@"access_token=%s",SparkCoreToken];}
    else {
        msg = [NSString stringWithFormat:@"access_token=%s&amp;params=%@",SparkCoreToken,param];
    }
    
    NSLog(@"msg=%@",msg);
    NSData *body = [NSData dataWithBytes:[msg cStringUsingEncoding:NSASCIIStringEncoding]
                                  length:[msg length]];
    
    //NSASCIIStringEncoding or NSUTF8StringEncoding ?
    //NSLog(@"%@",body);
    [req setHTTPBody:body];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        receivedData = [NSMutableData data];
        
    } else {
        NSLog(@"no connection");
            [self showResult:nil];
    }
}

//- (void)makeLeftAPIRequest
//{
//    leftMessageDate = [NSDate date];
//    int outValue = (int)(pow(leftSlider.value / leftSlider.maximumValue, 2) * 255);
//    NSString *bodyString = [NSString stringWithFormat:@"message=L%d", outValue];
//    [self makeAPIRequestWithMessage:bodyString];
//}
-(void) cleanResult{
    self.textOutput.text=nil;
}
- (void) showResult :(NSData *)data{
    if (data){
    NSDictionary *propertyListResult = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:NULL];
    //        NSArray *photos = [propertyListResult valueForKeyPath: FLICKR_RESULTS_PHOTOS];
    NSLog(@" Result= %@",propertyListResult);
    self.textOutput.text = [NSString stringWithFormat:@"%@",propertyListResult];
    } else {
        self.textOutput.text = @"""""";
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    NSLog(@"%@ for len=%lu",receivedData, (unsigned long)[receivedData length]);
    //        NSMutableString *string = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    
    [self showResult:data];

    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // debug
    if (false) {
        NSLog(@"Succeeded! Received %lu bytes of data", (unsigned long)[receivedData length]);
        char data[80];
        memset(data, 0, 80);
        [receivedData getBytes:data length:79];
        NSLog(@"%s", data);
    }
}



@end
