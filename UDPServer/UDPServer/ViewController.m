//
//  ViewController.m
//  UDPServer
//
//  Created by MM on 2018/11/8.
//  Copyright © 2018年 MM. All rights reserved.
//

#import "ViewController.h"
#import "GCD/GCDAsyncUdpSocket.h"

@interface ViewController ()<GCDAsyncUdpSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ipContent;
@property (weak, nonatomic) IBOutlet UITextField *portContent;
@property (weak, nonatomic) IBOutlet UITextView *connectedClients;
@property (weak, nonatomic) IBOutlet UITextView *sendContent;
@property (weak, nonatomic) IBOutlet UITextView *receiveContent;
@property (weak, nonatomic) IBOutlet UIButton *monitorBtn;
@property(nonatomic,strong)GCDAsyncUdpSocket* udpServer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.sendContent.layer.borderWidth = 0.5;
    
    self.receiveContent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.receiveContent.layer.borderWidth = 0.5;
    
    self.udpServer = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];

}

- (IBAction)monitorAction:(UIButton *)sender {
    if (sender.isSelected == NO) {
        [sender setSelected:YES];
        int port = [self.portContent.text intValue];
        NSError *error = nil;
        if (![self.udpServer bindToPort:port error:&error]) {
            NSLog(@"Error starting server (bind): %@", error);
            return;
        }
        if (![self.udpServer enableBroadcast:YES error:&error]) {
            NSLog(@"Error enableBroadcast (bind): %@", error);
            return;
        }
        if (![self.udpServer joinMulticastGroup:@"224.0.0.1"  error:&error]) {
            NSLog(@"Error joinMulticastGroup (bind): %@", error);
            return;
        }
        if (![self.udpServer beginReceiving:&error]) {
            [self.udpServer close];
            NSLog(@"Error starting server (recv): %@", error);
            return;
        }
        NSLog(@"udp servers success starting %hd", [self.udpServer localPort]);
    }else{
        [sender setSelected:NO];
        [self.udpServer close];
    }
    [self.view endEditing:YES];
}
- (IBAction)sendClearAction:(UIButton *)sender {
    self.sendContent.text = @"";
}
- (IBAction)sendAction:(UIButton *)sender {
    NSData *data = [self.sendContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpServer sendData:data toHost:self.ipContent.text port:[self.portContent.text intValue] withTimeout:-1 tag:0];
    [self.view endEditing:YES];
}
- (IBAction)receiveClearAction:(UIButton *)sender {
    self.receiveContent.text = @"";
}
#pragma mark - GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到%@,%@",str,address);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.receiveContent.text = str;
    });
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"connectAddress:%@",address);
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    NSLog(@"error%@",error);
}
@end
