__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.Whitedb("1001", 10240000, True, True)
print a
print len(a)
print a.dbsize()
print a.free()
print a.dump("/tmp/dbdump")
print a.load("/tmp/dbdump")
print a.startlogging()
print a.stoplogging()
print a.close()
print a.drop()


