__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.WDB()
print a
db = a.Create("test", {"type":"CFGDB","size": 1000000, "logging":True, "fields":{"a":(0, True),"b":(1, True), "c":(2, False)}})
print db.schema, db._id
for i in range(100):
    db = db + {"a":i, "b":3.14, "c":"hello world"}
print "CLOSE DB",db.CLOSE()
#print "DROP DB",db.DROP()


