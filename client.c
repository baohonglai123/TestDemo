#include <arpa/inet.h>
#include <netdb.h>
#include <stdlib.h>
  
int main()  
{  
    char * host ="192.168.2.2";
    int port = 8899;
    // 创建 socket
    int socketFd = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFd) {
        printf("创建失败\n");
        return -1;
    }
    
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname(host);
    if (NULL == remoteHostEnt) {
        close(socketFd);
        printf("无法解析服务器的主机名\n");
        return -1;
    }
    
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // 设置 socket 参数
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons(port);
    
    // 连接 socket
    int ret = connect(socketFd, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFd);
        printf("连接失败\n");
        return -1;
    }
    
    printf("连接成功\n");
    return 0;
}  