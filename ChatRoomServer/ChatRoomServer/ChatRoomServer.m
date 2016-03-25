//
//  ChatRoomServer.m
//  ChatRoomServer
//
//  Created by DavidLee on 16/3/25.
//  Copyright © 2016年 DavidLee. All rights reserved.
//

#import "ChatRoomServer.h"
#import "GCDAsyncSocket.h"

@interface ChatRoomServer()<GCDAsyncSocketDelegate>

@property(nonatomic,strong)GCDAsyncSocket *serverSocket;
@property(nonatomic,strong)dispatch_queue_t globalQueue;
@property(nonatomic,strong)NSMutableArray  *clientSocketArray;


@end

@implementation ChatRoomServer

#pragma mark - 懒加载
-(NSMutableArray *)clientSocketArray
{
    if (!_clientSocketArray) {
        self.clientSocketArray = [[NSMutableArray alloc] init];
    }
    
    return _clientSocketArray;
}

/** 重新初始化方法 */
-(instancetype)init
{
    if (self = [super init]) {
        
        self.globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.globalQueue];
    }
    
    return self;
}


/** 开启聊天服务器 */
-(void)setupChatRoomServer
{
    //1，打开监听端口
    NSError *error = nil;
    [self.serverSocket acceptOnPort:54321 error:&error];
    
    if (!error) {
        NSLog(@"服务开启成功");
    }else{
        NSLog(@"服务开启失败");
    }
    
}

#pragma mark - GCDAsyncSocketDelegate
/** 有客户端和服务器连接 */
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"%s",__func__);
    //保存新的Socket
    [self.clientSocketArray addObject:newSocket];
   
    //读取客户端数据才能调用didReadData(sock是服务器端的socket只负责客户端的连接不负责数据的读取)
    [newSocket readDataWithTimeout:-1 tag:102];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:tag];
}

/** 接收到客户端数据 */
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"%s",__func__);
    
    
    //接收到的数据
    NSString *receiveString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",receiveString);
    //去掉回车和换行
    [receiveString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [receiveString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    //判断是登录的指令还是客户端的消息指令
    if ([receiveString hasPrefix:@"iam"]) {//登录指令
        NSString *userName = [[receiveString componentsSeparatedByString:@":"] firstObject];
        NSString *repString = [userName stringByAppendingString:@"登录"];
        //返回客户端消息
        [sock writeData:[repString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    if ([receiveString hasPrefix:@"msg"]) {//消息指令
       NSString *msgString = [[receiveString componentsSeparatedByString:@":"] lastObject];
        //返回客户端消息
        [sock writeData:[msgString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    
    if ([receiveString isEqualToString:@"quit"]) {//断开连接
        //断开连接
        [sock disconnect];
        //移除socket
        [self.clientSocketArray removeObject:sock];
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"%s",__func__);
}

@end










