#!/usr/bin/env python
# -*- coding: utf-8 -*-

from socket import *

HOST = '192.168.2.2'       #服务器的主机名
PORT = 8898          #端口号
BUFSIZ = 1024         #缓冲区
ADDR = (HOST,PORT)     #地址

tcpCliSocket = socket(AF_INET,SOCK_STREAM)    #创建客户端套接字
tcpCliSocket.connect(ADDR)          #连接服务器

while True:                #通信循环
    data = raw_input()       #客户端输入信息
    print("data:%s"%data)
    if not data:     #如果输入信息为空，则跳出循环，关闭通信
        break

    data = data.encode('ascii')           
    tcpCliSocket.send(data)     #发送客户端信息
    data = tcpCliSocket.recv(BUFSIZ)     #接受服务器返回信息
    if not data:        #如果服务器未返回信息，关闭通信循环
        break
    print('get:',data.decode('ascii'))

tcpCliSocket.close()