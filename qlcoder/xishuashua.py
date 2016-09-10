import os
import hashlib
import binascii
from multiprocessing import Process, Lock, Value
import sys

T = '20160909雪特'
H = '000000'
mutex = Lock()
v = Value('i', 424)
END = 425

def gen(n):
    t = T + str(n)
    i = 0
    h = ''
    while h != H:
        i += 1
        h = binascii.b2a_hex(hashlib.md5((t + str(i)).encode('utf-8')).digest()).decode('utf-8')[:6]
    with mutex:
        print("%s %s" % (n, i))
    

def get_n():
    n = None
    global v
    if v.value < END:
        n = v.value
        v.value += 1
    return n


def pro():
    n = get_n()
    while n:
        print(n, file=sys.stderr, flush=True)
        gen(n)
        n = get_n()


if __name__ == '__main__':
    ps = []
    for i in range(0, 4):
        p = Process(target=pro)
        p.start()
        ps.append(p)
    for p in ps:
        p.join()

