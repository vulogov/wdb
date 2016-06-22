__author__ = 'Vladimir Ulogov'

import whitepy

a = whitepy.Whitedb("1001", 10240000)
c = a.cursor()
rec = c.first()
if rec:
    print rec
    print "Rec len",len(rec)
    _rec = rec
    while True:
        print "record",_rec()
        _rec = rec.next()
        rec.delete()
        rec = _rec
        if not rec:
            break

a.close()





