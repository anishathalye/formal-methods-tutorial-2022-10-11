from z3 import *

x = BitVec('x', 32)
t = (x & BitVecVal(0xffff0000, 32)) & BitVecVal(0x0000ffff, 32)
print(t)
