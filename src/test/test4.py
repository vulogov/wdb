__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.WDB()
print a
db = a.Create("test", {"size": 1000000, "logging":True, "fields":{"a":(0, False),"b":(1, False), "c":(2, False)}})
print db.schema, db._id
db = db + {"a":42, "b":3.14, "c":"hello world"}
db.DROP()


