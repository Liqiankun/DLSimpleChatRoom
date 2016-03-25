//
//  main.m
//  ChatRoomServer
//
//  Created by DavidLee on 16/3/25.
//  Copyright © 2016年 DavidLee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatRoomServer.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //实现聊天服务器
        ChatRoomServer *chatServer = [[ChatRoomServer alloc] init];
        [chatServer setupChatRoomServer];
        
        //开启主循环
        [[NSRunLoop currentRunLoop] run];
        
        
    }
    return 0;
}
