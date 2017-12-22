//
//  LMSeverUDP.m
//  UDP服务端
//
//  Created by 刘明 on 16/8/16.
//  Copyright © 2016年 LM. All rights reserved.
//

#import "LMSeverUDP.h"
#import "GCDAsyncUdpSocket.h"
@interface LMSeverUDP()<GCDAsyncUdpSocketDelegate>
@property(nonatomic,strong)GCDAsyncUdpSocket* udpServer;
@end
@implementation LMSeverUDP
-(void)start{
    self.udpServer = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    int port = 12345;
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
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"收到%@,%@",data,address);
    [self.udpServer sendData:data toAddress:address withTimeout:-1 tag:0];
}

@end
