cimport cwhitedb
try:
    import simplejson
except:
    raise ImportError,"simplejson is required module"

cdef extern from "whitedb/dbapi.h":
    cdef int WG_NULLTYPE
    cdef int WG_RECORDTYPE
    cdef int WG_INTTYPE
    cdef int WG_DOUBLETYPE
    cdef int WG_STRTYPE
    cdef int WG_XMLLITERALTYPE
    cdef int WG_URITYPE
    cdef int WG_BLOBTYPE
    cdef int WG_CHARTYPE
    cdef int WG_FIXPOINTTYPE
    cdef int WG_DATETYPE
    cdef int WG_TIMETYPE
cdef extern from "whitedb/indexapi.h":
    cdef int WG_INDEX_TYPE_TTREE


NULLTYPE=WG_NULLTYPE
RECORDTYPE=WG_RECORDTYPE
INTTYPE=WG_INTTYPE
DOUBLETYPE=WG_DOUBLETYPE
STRTYPE=WG_STRTYPE
XMLLITERALTYPE=WG_XMLLITERALTYPE
URITYPE=WG_URITYPE
BLOBTYPE=WG_BLOBTYPE
CHARTYPE=WG_CHARTYPE
FIXPOINTTYPE=WG_FIXPOINTTYPE
DATETYPE=WG_DATETYPE
TIMETYPE=WG_TIMETYPE

INDEX_TYPE_TTREE=WG_INDEX_TYPE_TTREE

cdef class Record:
    cdef void* db
    cdef void* record
    cdef object rlen
    cdef object ready
    def __cinit__(self, rlen):
        self.ready = False
        self.rlen  = rlen

    cdef create(self, void* db):
        self.db = <void*>db
        self.record = <void*>cwhitedb.wg_create_record(self.db, self.rlen)
        if self.record is not NULL:
            self.ready = True
        else:
            raise MemoryError()
        return self.ready

    cdef make(self, void* db, void* rec):
        if self.ready == True:
            return False
        self.db = <void*>db
        self.record = <void*>rec
        self.ready = True
        self.rlen = len(self)

    def __call__(self):
        out = []
        for f in range(len(self)):
            out.append(self.get(f))
        return out
    def __len__(self):
        if not self.ready:
            return 0
        return cwhitedb.wg_get_record_len(self.db, self.record)

    def delete(self):
        if not self.ready:
            return
        cwhitedb.wg_delete_record(self.db, self.record)

    def set_field(self, int fld, object data, object _type=None):
        import types
        if not self.ready:
            return False
        if type(data) == types.IntType:
            res = <int>cwhitedb.wg_set_int_field(<void*>self.db, <void*>self.record, fld, data)
        elif type(data) == types.FloatType:
            res = <int>cwhitedb.wg_set_double_field(<void*>self.db, <void*>self.record, fld, data)
        elif type(data) == types.StringType and _type==None:
            res = <int>cwhitedb.wg_set_str_field(<void*>self.db, <void*>self.record, fld, data)
        elif type(data) == types.StringType and _type == BLOBTYPE:
            blob = cwhitedb.wg_encode_blob(<void*>self.db, data, <char*>0, len(data))
            res = <int>cwhitedb.wg_set_field(<void*>self.db, <void*>self.record, fld, blob)
        elif type(data) == types.StringType and _type == DATETYPE:
            res = None
        else:
            res = -1
        if res != 0:
            return False
        return True
    def set(self, int fld, object data):
        return self.set_field(fld, data)

    def get(self, int fld):
        if not self.ready:
            return None
        _t = cwhitedb.wg_get_field_type(<void*>self.db, <void*>self.record, fld)
        _d = cwhitedb.wg_get_field(<void*>self.db, <void*>self.record, fld)
        if _t == INTTYPE:
            res = cwhitedb.wg_decode_int(<void*>self.db, _d)
        elif _t == DOUBLETYPE:
            res = cwhitedb.wg_decode_double(<void*>self.db, _d)
        elif _t == STRTYPE:
            res = cwhitedb.wg_decode_str(<void*>self.db, _d)
        elif _t == BLOBTYPE:
            res = cwhitedb.wg_decode_blob(<void*>self.db, _d)
        else:
            res = None
        return res

    def next(self):
        if not self.ready:
            return None
        _rec = <void*>cwhitedb.wg_get_next_record(<void*>self.db, <void*>self.record)
        if _rec is NULL:
            return None
        rec = Record(0)
        rec.make(self.db, _rec)
        return rec




cdef class Cursor:
    cdef void* db
    cdef object ready
    def __cinit__(self):
        self.ready = False
    cdef create(self, void* db):
        if self.ready == True:
            return
        self.db = <void*>db
    def first(self):
        _rec = <void*>cwhitedb.wg_get_first_record(<void*>self.db)
        if _rec is NULL:
            return None
        rec = Record(0)
        rec.make(self.db, _rec)
        return rec
    def query(self, **q):
        return





cdef class Whitedb:
    cdef void* db
    cdef object name
    cdef object size
    cdef object ready
    cdef object isLog
    cdef object rw_lock
    cdef object ro_lock
    def __cinit__(self, _name, _size, _create=True, _log=False):
        self.name = _name
        self.size = _size
        self.ready = False
        self.isLog = False
        self.rw_lock = 0
        self.ro_lock = 0
        if _create:
            self.db = <void*>cwhitedb.wg_attach_database(self.name, self.size)
        else:
            self.db = <void*>cwhitedb.wg_attach_existing_database(self.name)
        if <int>self.db != 0:
            self.ready = True
            if _log:
                self.startlogging()
    def __dealloc__(self):
        self.close()
    def close(self):
        if not self.ready:
            return False
        if self.isLog == True:
            self.stoplogging()
        res = cwhitedb.wg_detach_database(self.db)
        # print "C",self.name,res
        self.ready = False
        if res != 0:
            return False
        return True
    def drop(self):
        # print "D",self.name,self.ready
        if self.ready:
            if self.close() != True:
                return False
        res = cwhitedb.wg_delete_database(self.name)
        # print "DROP",res
        if res == 0:
            self.ready = False
        if res != 0:
            return False
        return True
    def dbsize(self):
        if not self.ready:
            return -2
        return cwhitedb.wg_database_size(self.db)
    def __len__(self):
        return self.dbsize() - self.free()
    def free(self):
        if not self.ready:
            return -2
        return cwhitedb.wg_database_freesize(self.db)
    def dump(self, fname):
        if not self.ready:
            return -2
        return cwhitedb.wg_dump(self.db, fname)
    def load(self, fname):
        if not self.ready:
            return -2
        return cwhitedb.wg_import_dump(self.db, fname)
    def startlogging(self):
        if not self.ready:
            return -2
        if self.isLog == True:
            self.stoplogging()
        self.isLog = True
        return cwhitedb.wg_start_logging(self.db)
    def stoplogging(self):
        if not self.ready:
            return -2
        if self.isLog == False:
            return -1
        self.isLog = False
        return cwhitedb.wg_stop_logging(self.db)
    def record(self, rlen):
        if not self.ready:
            return None
        rec = Record(rlen)
        if rec.create(<void*>self.db):
            return rec
        return None
    def cursor(self):
        cur = Cursor()
        cur.create(<void*>self.db)
        return cur
    def display(self):
        cwhitedb.wg_print_db(<void*>self.db)
    def start_write(self):
        if self.rw_lock != 0:
            cwhitedb.wg_end_write(self.db, self.rw_lock)
        self.rw_lock = cwhitedb.wg_start_write(self.db)
    def start_read(self):
        if self.ro_lock != 0:
            cwhitedb.wg_end_read(self.db, self.ro_lock)
        self.ro_lock = cwhitedb.wg_start_read(self.db)
    def commit(self):
        if self.rw_lock != 0:
            cwhitedb.wg_end_write(self.db, self.rw_lock)
            self.rw_lock = 0
        if self.ro_lock != 0:
            cwhitedb.wg_end_read(self.db, self.ro_lock)
            self.ro_lock = 0
    def listOfJournals(self):
        return []
    def create_index(self, fld):
        if not self.ready:
            return False
        ix = cwhitedb.wg_column_to_index_id(self.db, fld, INDEX_TYPE_TTREE, NULL, 0)
        if ix != -1:
            return True
        res = cwhitedb.wg_create_index(self.db, fld, INDEX_TYPE_TTREE, NULL, 0)
        if res != 0:
            return False
        return True
    def drop_index(self, fld):
        if not self.ready:
            return False
        ix = cwhitedb.wg_column_to_index_id(self.db, fld, INDEX_TYPE_TTREE, NULL, 0)
        if ix == -1:
            return False
        res = cwhitedb.wg_drop_index(self.db, ix)
        if res != 0:
            return False
        return True

class KEYDB:
    def INIT(self):
        pass

class TIMESERIESDB:
    def INIT(self):
        pass

DRIVERS={'KEYDB':KEYDB, 'TIMESERIESDB':TIMESERIESDB}

class DB:
    def __init__(self, _id, name, schema):
        self._id = _id
        self.name = name
        self.schema = schema
        if "size" not in schema.keys():
            self.size = 16777216
            self.schema["size"] = self.size
        else:
            self.size = self.schema["size"]
        if "logging" not in self.schema.keys():
            self.logging = True
            self.schema["logging"] = self.logging
        else:
            self.logging = self.schema["logging"]
        if schema.has_key("type") and schema["type"] in DRIVERS.keys():
            _b = list(self.__class__.__bases__)
            _b.append(DRIVERS[schema["type"]])
            self.__class__.__bases__ = tuple(_b)
        self.db = Whitedb(str(_id), self.size, True, self.logging)
    def DB(self):
        return self.db
    def CLOSE(self):
        return self.db.close()
    def DROP(self):
        return self.db.drop()
    def INDEX(self, fld):
        self.db.create_index(fld)
    def DROP_INDEX(self, fld):
        self.db.drop_index(fld)
    def __add__(self, rec):
        _rec = self.db.record(len(self.schema["fields"].keys()))
        self.db.start_write()
        if self.logging:
            self.db.startlogging()
        for k in rec.keys():
            if k not in self.schema["fields"].keys():
                continue
            _rec.set(self.schema["fields"][k][0],rec[k])
        if self.logging:
            self.db.stoplogging()
        self.db.commit()
        return self



class WDB:
    def __init__(self, catalogdb="10051", catalogsize=16777216):
        self.catalogdb = catalogdb
        self.catalogsize = catalogsize
        self.catalog = Whitedb(self.catalogdb, self.catalogsize, True, True)
        self.catalog.create_index(0)
        self.catalog.create_index(1)
        self.dir = {}
        self.reloadCatalog()
    def reloadCatalog(self):
        cur = self.catalog.cursor()
        rec = cur.first()
        if not rec:
            return self.dir
        while True:
            _id = rec.get(0)
            _name = rec.get(1)
            _schema = simplejson.loads(rec.get(2))
            if _id not in self.dir.keys():
                self.dir[_id] = {}
            self.dir[_id]["name"] = _name
            self.dir[_id]["schema"] = _schema
            rec = rec.next()
            if not rec:
                break
    def getDB(self, _id):
        if _id not in self.dir.keys():
            return None
        return DB(_id, self.dir[_id]["name"], self.dir[_id]["schema"])
    def Create(self, name, schema):
        self.reloadCatalog()
        for m in self.dir.keys():
            if name == self.dir[m]["name"]:
                db = self.getDB(m)
                db.INDEX(0)
                return db
        self.catalog.start_write()
        ids = self.dir.keys()
        ids.sort()
        if len(ids) == 0:
            nextid = int(self.catalogdb)+1
        else:
            nextid = ids[-1:][0]+1
        self.dir[nextid] = {}
        self.dir[nextid]["name"] = name
        self.dir[nextid]["schema"] = schema
        self.catalog.startlogging()
        rec = self.catalog.record(3)
        rec.set(0, nextid)
        rec.set(1, name)
        rec.set(2, simplejson.dumps(schema))
        self.catalog.stoplogging()
        self.catalog.commit()
        db = DB(nextid, name, schema)
        for f in schema["fields"].keys():
            if schema["fields"][f][1] == True:
                db.INDEX(schema["fields"][f][0])
        return db
    def DROP(self):
        for _db in self.dir.keys():
            db = self.getDB(_db)
            db.CLOSE()
            if db.DROP() != True:
                return False
        self.catalog.close()
        return self.catalog.drop()





