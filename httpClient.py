#!/usr/bin/env python
# -*- coding: utf-8 -*-

from socket import *

HOST = '192.168.2.2'       #服务器的主机名
PORT = 8898          #端口号
BUFSIZ = 1024         #缓冲区
ADDR = (HOST,PORT)     #地址

tcpCliSocket = socket(AF_INET,SOCK_STREAM)    #创建客户端套接字
tcpCliSocket.connect(ADDR)          #连接服务器

request = "GET /index HTTP/1.1\r\n"
reqeust_headers = "Host:"+HOST+"\r\n"
tcpCliSocket.send(request.encode('utf-8'))
tcpCliSocket.send(reqeust_headers.encode('utf-8'))

while True:                #通信循环
    data = tcpCliSocket.recv(BUFSIZ)     #接受服务器返回信息
    if not data:        #如果服务器未返回信息，关闭通信循环
        break
    print('get:',data.decode('utf-8'))

tcpCliSocket.close()