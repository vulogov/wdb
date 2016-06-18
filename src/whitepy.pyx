cimport cwhitedb

cdef class Whitedb:
    cdef void* db
    cdef object name
    cdef object size
    cdef object ready
    cdef object isLog
    def __cinit__(self, _name, _size, _create=True, _log=False):
        self.name = _name
        self.size = _size
        self.ready = False
        self.isLog = _log
        if _create:
            self.db = <void*>cwhitedb.wg_attach_database(self.name, self.size)
        else:
            self.db = <void*>cwhitedb.wg_attach_existing_database(self.name)
        if <int>self.db != 0:
            self.ready = True
            if self.isLog:
                self.startlogging()
    def close(self):
        if not self.ready:
            return -2
        if self.isLog == True:
            self.stoplogging()
        return cwhitedb.wg_detach_database(self.db)
    def drop(self):
        if not self.ready:
            return -2
        return cwhitedb.wg_delete_database(self.name)
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
            return -1
        self.isLog = True
        return cwhitedb.wg_start_logging(self.db)
    def stoplogging(self):
        if not self.ready:
            return -2
        if not self.isLog == False:
            return -1
        self.isLog = False
        return cwhitedb.wg_stop_logging(self.db)



