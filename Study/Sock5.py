# Socks5 
import socket
import struct
import select

import sys

from socketserver import BaseRequestHandler,ThreadingTCPServer,TCPServer

class Sock5(BaseRequestHandler):
    """sock5 协议的实现
    """

    VERSION = b'\05'

    AGREE = b'\02'

    USERNAME = ""
    PASSWORD = ""


    def __getMsg(self):
        exDate = self.request.recv(4)
        msg = {}
        msg['ver'] = exDate[0]
        msg['cmd'] = exDate[1]
        msg['rsv'] = exDate[2]
        msg['atyp'] = exDate[3]
        msg['dstAddr'] = self.__getMsgDstAddr(msg['atyp'])
        msg['dstPort'] =  struct.unpack(">H",self.request.recv(2))[0]
        return msg
    def __getMsgDstAddr(self,atyp):
        if atyp == 1:
            return socket.inet_ntoa(self.request.recv(4))
        elif atyp == 3:
            length = self.request.recv(1)[0]
            return socket.gethostbyname(self.request.recv(length))
        elif atyp == 4:
            return self.request.recv(16)
        return None
    def __checkServeStatus(self,msg):
        rep = {}
        self.remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
        self.remote.connect((msg['dstAddr'], msg['dstPort']))
        # TimeoutError: [Errno 110] Connection timed out
        remInfo = self.remote.getsockname()
        rep['atyp'] = b'\x01'
        rep['bndAddr'] = socket.inet_aton(remInfo[0])
        rep['bndPort'] = struct.pack(">H",remInfo[1])
        return rep

    def __checkUser(self):
        exDate = self.request.recv(2)
        if exDate[0] != 1 :
            print("错误的鉴定版本:",exDate[0])
        oData = self.request.recv(exDate[1] + 1 )
        uname = oData[0:exDate[1]]
        upwd = self.request.recv(oData[-1])
        print(uname,upwd)
        return True

    def close(self):
        self.request.close()

    def auth(self):
        data = self.request.recv(1024)
        self.methods = data[2:2+data[1]]
        if Sock5.AGREE in self.methods:
            self.request.sendall(Sock5.VERSION + Sock5.AGREE)
        else:
            self.close()
            print("未发现可接收的认证方法:" + self.methods)
        return True
    
    def method(self):
        print("debug",Sock5.AGREE)
        if Sock5.AGREE == b'\00':
            return True
        elif Sock5.AGREE == b'\02':
            return self.__checkUser()
        else:
            print("认证方法未实现:" + Sock5.AGREE)
            return False


    def req(self):
        msg = self.__getMsg()
        rep = self.__checkServeStatus(msg)
        rep['rep'] = b'\x00' #return succeed
        self.rep(rep)
        return msg

    def rep(self,rep):
        rep['ver'] = Sock5.VERSION
        rep['rsv'] = b'\x00'
        data = rep['ver'] + rep['rep'] + rep['rsv'] + rep['atyp'] + rep['bndAddr'] + rep['bndPort']
        self.request.sendall(data)
        return data

    def exchange(self):
        while True:
            # ConnectionResetError: [Errno 104] Connection reset by peer
            r, _, _ = select.select([self.request, self.remote], [], [])
            if self.request in r :
                data = self.request.recv(10240)
                if not data: break
                self.remote.send(data)
            if self.remote in r:
                data = self.remote.recv(10240)
                if not data: break
                self.request.send(data)

    def handle(self):
        try:
            if self.auth() == False:
                return
            if self.method() == False:
                return
            
            print('req info..', self.req() )
            self.exchange()
            print('req close..')
        except:
            print("req fail:", sys.exc_info()[0])



if __name__ == '__main__':
    # ThreadingTCPServer.allow_reuse_address = True
    # serv = ThreadingTCPServer(('', 1234), Sock5)
    TCPServer.allow_reuse_address = True
    serv = TCPServer(('', 1234), Sock5)
    serv.serve_forever()
