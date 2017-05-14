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
    [self testSocket];
//    [self testTime];
}


static int connect_nonb(int sockfd, const struct sockaddr *saptr, socklen_t salen, int nsec)
{
    int     flags, n, error;
    socklen_t   len;
    fd_set  rset, wset;
    struct timeval  tval;
    
    // 设置 socket 为非阻塞
    if ((flags = fcntl(sockfd, F_GETFL, 0)) == -1) {
        perror("fcntl F_GETFL");
    }
    if (fcntl(sockfd, F_SETFL, flags | O_NONBLOCK) == -1) {
        perror("fcntl F_SETFL");
    }
    
    error = 0;
    // 发起非阻塞 connect
    if ((n = connect(sockfd, saptr, salen)) < 0) {
        // EINPROGRESS 表示连接建立已启动但是尚未完成
        if (errno != EINPROGRESS) {
            return -1;
        }
    } else if (n == 0) {
        // 连接已经建立，当服务器处于客户端所在的主机时可能发生这种情况
        goto done;
    }
    
    FD_ZERO(&rset);
    FD_SET(sockfd, &rset);
    wset = rset;
    tval.tv_sec = nsec;
    tval.tv_usec = 0;
    
    // 等待套接字变为可读或可写，在 select 上等待连接完成
    if ((n = select(sockfd+1, &rset, &wset, NULL, nsec ? &tval:NULL)) == 0) {
        // select 返回0，说明超时发生，需要关闭套接字，以防止已经启动的三次握手继续下去
        close(sockfd);
        errno = ETIMEDOUT;
        return -1;
    } else if (n == -1) {
        close(sockfd);
        perror("select");
        return -1;
    }
    
    if (FD_ISSET(sockfd, &rset) || FD_ISSET(sockfd, &wset)) {
        len = sizeof(error);
        // 获取待处理错误，如果建立成功，error 为0；
        // 如果连接建立发生错误，该值就是对应错误的 errno 值
        if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &len) < 0) {
            // Berkeley 实现将在 error 中返回待处理错误，getsocket 本身返回 0
            // Solaris 实现将 getsocket 返回 -1，并把 errno 变量设置为待处理错误
            return -1;
        }
    } else {
        fprintf(stderr, "select error: socket not set");
    }
    
    
done:
    
    // 关闭非阻塞状态
    if (fcntl(sockfd, F_SETFL, flags) == -1) {
        perror("fcntl");
    }
    
    if (error) {
        close(sockfd);
        errno = error;
        return -1;
    }
    
    return 0;
}

- (void) testSocket {
//    char * host ="172.16.60.48";
    char * host ="192.168.2.1";
    int port = 8888;
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
//    setsockopt(socketFd, SOL_SOCKET, SO_SNDBUF, &sendbuf, sizeof(sendbuf));
    getsockopt(socketFd, SOL_SOCKET, SO_SNDBUF, &sendBuf2, (socklen_t*)&len);
    struct timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;
    setsockopt(socketFd, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout));
    printf("sendBuf2:%d\n",sendBuf2);
    
    // 连接 socket
    NSLog(@"开始连接\n");
    int ret = 0;
    ret = connect(socketFd, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFd);
        NSLog(@"连接失败\n");
        return ;
    }
//    if (connect_nonb(socketFd, (struct sockaddr *)&socketParameters, sizeof(socketParameters), 2) < 0) {
//        NSLog(@"连接失败");
//        return;
//    }
    
    NSLog(@"连接成功\n");
    int dataLen = 131072;
    char data[dataLen];
    for (int i =0; i<dataLen; ++i) {
        data[i] = i%128;
    }
    ret = send(socketFd, data, dataLen, 0);
    if (ret == -1) {
        NSLog(@"发送失败\n");
    } else {
        NSLog(@"发送了 %d 字节数据\n",ret);
    }
     close(socketFd);
    
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
