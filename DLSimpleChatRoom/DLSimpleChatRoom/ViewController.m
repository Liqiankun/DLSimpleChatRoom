//
//  ViewController.m
//  DLSimpleChatRoom
//
//  Created by DavidLee on 16/3/19.
//  Copyright © 2016年 DavidLee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate>

@property(nonatomic,strong)NSInputStream *inputStream;
@property(nonatomic,strong)NSOutputStream *outputStream;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)login:(id)sender {
    NSString *string = @"iam:DavidLee";
    NSData *strData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.outputStream write:strData.bytes maxLength:strData.length];
}


- (IBAction)signin:(id)sender {
    
    //与服务器简历建立链接
    NSString *hostPath = @"192.168.87.113";
    int portNumber = 12345;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,(__bridge CFStringRef)hostPath, portNumber, &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *)(readStream);
    self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
   
    switch (eventCode) {
        case NSStreamEventOpenCompleted:{
            NSLog(@"成功链接");
        }
            break;
        case NSStreamEventHasBytesAvailable:{
            [self readData];
             NSLog(@"有数据可读");
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:{
            NSLog(@"可以发送数据");
        }
            break;
            
        case NSStreamEventErrorOccurred:{
            NSLog(@"链接失败");
        }
            break;
            
        case NSStreamEventEndEncountered:{
            NSLog(@"正常断开");
        }
            break;
            
        default:
            break;
    }
}

-(void)readData
{
    //定义一个缓冲区
    uint8_t buf[1024];
   NSInteger len =  [self.inputStream read:buf maxLength:sizeof(buf)];
    //把缓存区的字节转为字符串
   NSString *receiveStr =  [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
    NSLog(@"receivedMSG%@",receiveStr);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
