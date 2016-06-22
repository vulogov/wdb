__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.Whitedb("1001", 10240000)
rec = a.record(3)
print rec
print "REC size",len(rec)
a.start_write()
print "Set int",rec.set(0, 42)
print "Set float",rec.set(1, 3.14)
print "Set str",rec.set(2, "hello world\000binary")
a.commit()
print "Get 0",rec.get(0)
print "Get 1",rec.get(1)
print "Get 2",rec.get(2)
a.start_write()
print "Set int",rec.set(0, 41)
a.commit()
print "Get 0",rec.get(0)
a.display()
a.close()
#a.drop()




