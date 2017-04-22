//
//  ViewController.m
//  SocketClient
//
//  Created by 包红来 on 2017/4/19.
//  Copyright © 2017年 包红来. All rights reserved.
//

#import "ViewController.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <mach/mach_time.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAction:(id)sender {
//    [self test];
    [self testTime];
}

- (void) test {
//    char * host ="172.16.60.48";
    char * host ="192.168.2.1";
    int port = 8889;
    // 创建 socket
    int socketFd = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFd) {
        printf("创建失败\n");
        return;
    }
    
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname(host);
    if (NULL == remoteHostEnt) {
        close(socketFd);
        printf("无法解析服务器的主机名\n");
        return;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // 设置 socket 参数
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons(port);
//    int flags = fcntl(socketFd, F_GETFL,0);
//    fcntl(socketFd,F_SETFL, flags | O_NONBLOCK);
    
    int sendbuf = 128;
    int len = sizeof(sendbuf);
    int sendBuf2 = 0;
    
    //设置发送缓冲区大小
    setsockopt(socketFd, SOL_SOCKET, SO_SNDBUF, &sendbuf, sizeof(sendbuf));
    getsockopt(socketFd, SOL_SOCKET, SO_SNDBUF, &sendBuf2, (socklen_t*)&len);
    printf("sendBuf2:%d\n",sendBuf2);
    
    // 连接 socket
    printf("开始连接\n");
    int ret = connect(socketFd, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFd);
        printf("连接失败\n");
        return ;
    }
    
    printf("连接成功\n");
    int dataLen = 4196;
    char data[dataLen];
    for (int i =0; i<dataLen; ++i) {
        data[i] = i%128;
    }
    ret = send(socketFd, data, dataLen, 0);
    if (ret == -1) {
        printf("发送失败\n");
    } else {
        printf("发送了 %d 字节数据\n",ret);
    }
    
}


- (void) testTime {
    uint64_t start = mach_absolute_time();
    sleep(1);
    uint64_t end = mach_absolute_time();
    
    uint64_t elapsed = end - start;
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    uint64_t nanos = elapsed * info.numer / info.denom;
    CGFloat secs = nanos*1.0/NSEC_PER_SEC;
    NSLog(@"cost:%fms",secs);
}

@end
