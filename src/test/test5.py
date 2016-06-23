__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.WDB()
#print a
#db = a.Create("cfg", {"type":"KEYDB","size": 1000000, "logging":True, "fields":{"key":(0, True),"val":(1, False)}})
#print db.schema, db._id
#for i in range(100):
#    db = db + {"a":i, "b":3.14, "c":"hello world"}
print "DROP DB",a.DROP()


