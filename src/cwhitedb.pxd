cdef extern from "stdlib.h":
    ctypedef void const_void "const void"

cdef extern from "whitedb/dbapi.h":
    ctypedef ptrdiff_t wg_int
    void* wg_attach_database(char* dbasename, wg_int size) nogil
    void* wg_attach_existing_database(char* dbasename)
    int wg_detach_database(const void* dbase) nogil
    int wg_delete_database(char* dbasename) nogil
    wg_int wg_database_size(void *db)
    wg_int wg_database_freesize(void *db)
    wg_int wg_dump(void * db,char* fileName)
    wg_int wg_import_dump(void * db,char* fileName)
    wg_int wg_start_logging(void *db)
    wg_int wg_stop_logging(void *db)
    wg_int wg_replay_log(void *db, char *filename)
