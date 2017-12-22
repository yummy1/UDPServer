//
//  main.m
//  UDP服务端
//
//  Created by 刘明 on 16/8/16.
//  Copyright © 2016年 LM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMSeverUDP.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        LMSeverUDP * udp = [[LMSeverUDP alloc]init];
        [udp start];
        [[NSRunLoop mainRunLoop]run];
        
    }
    return 0;
}
