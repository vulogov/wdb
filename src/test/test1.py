__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.Whitedb("1001", 10240000, True, True)
print a
print "DB size",len(a)
print "DB total size",a.dbsize()
print "DB free space",a.free()
print "Dump DB", a.dump("/tmp/dbdump")
print "LOAD DB",a.load("/tmp/dbdump")
print "Start logging",a.startlogging()
print "Stop logging",a.stoplogging()
print "Close DB",a.close()
print "Drop DB",a.drop()


