cdef extern from "stdlib.h":
    ctypedef void const_void "const void"

cdef extern from "whitedb/dbapi.h":

    ctypedef ptrdiff_t wg_int
    ctypedef void* DB
    ctypedef void* REC
    ctypedef struct wg_query_arg:
        gint column
        gint cond
        gint value
    ctypedef wg_query_arg* QUERY
    DB wg_attach_database(char* dbasename, wg_int size) nogil
    DB wg_attach_existing_database(char* dbasename)
    int wg_detach_database(const void* dbase) nogil
    int wg_delete_database(char* dbasename) nogil
    void wg_print_db(DB db)
    wg_int wg_start_write(DB dbase)
    wg_int wg_start_read(DB dbase)
    wg_int wg_end_write(DB dbase, wg_int lock)
    wg_int wg_end_read(DB dbase, wg_int lock)
    wg_int wg_database_size(DB db) nogil
    wg_int wg_database_freesize(DB db) nogil
    wg_int wg_dump(DB db,char* fileName) nogil
    wg_int wg_import_dump(DB db, char* fileName) nogil
    wg_int wg_start_logging(DB db) nogil
    wg_int wg_stop_logging(DB db) nogil
    wg_int wg_replay_log(DB db, char *filename) nogil
    REC wg_create_record(DB db, wg_int length) nogil
    wg_int wg_delete_record(DB db, REC rec) nogil
    wg_int wg_get_record_len(DB db, REC record) nogil
    REC wg_get_first_record(DB db) nogil
    REC wg_get_next_record(DB db, REC record) nogil
    wg_int wg_set_field(DB db, REC record, wg_int fieldnr, wg_int data) nogil
    wg_int wg_get_field(DB db, REC record, wg_int fieldnr) nogil
    wg_int wg_get_field_type(DB db, REC record, wg_int fieldnr) nogil
    wg_int wg_set_int_field(DB db, REC record, wg_int fieldnr, wg_int data) nogil
    wg_int wg_set_double_field(DB db, REC record, wg_int fieldnr, double data) nogil
    wg_int wg_set_str_field(DB db, REC record, wg_int fieldnr, char* data) nogil
    wg_int wg_decode_int(DB db, wg_int data) nogil
    double wg_decode_double(void* db, wg_int data) nogil
    char* wg_decode_str(void* db, wg_int data) nogil
    wg_int wg_encode_blob(DB db, char* str, char* type, wg_int len)
    char* wg_decode_blob(DB db, wg_int data) nogil

cdef extern from "whitedb/indexapi.h":
    wg_int wg_create_index(DB db, wg_int column, wg_int type,wg_int *matchrec, wg_int reclen)
    wg_int wg_drop_index(DB db, wg_int index_id)
    wg_int wg_column_to_index_id(DB db, wg_int column, wg_int type,wg_int *matchrec, wg_int reclen)