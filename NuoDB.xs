#include "dbdimp.h"

DBISTATE_DECLARE;

int dbd_db_login  (SV *dbh, imp_dbh_t *imp_dbh, char *dbname, char *uid, char *pwd);
void     dbd_init (dbistate_t *dbistate);

int      dbd_discon_all (SV *drh, imp_drh_t *imp_drh);
SV      *dbd_take_imp_data (SV *h, imp_xxh_t *imp_xxh, void *foo);

/* Support for dbd_dr_data_sources and dbd_db_do added to Driver.xst in DBI v1.33 */
/* dbd_dr_data_sources: optional: defined by a driver that calls a C */
/* function to get the list of data sources */
AV      *dbd_dr_data_sources(SV *drh, imp_drh_t *imp_drh, SV *attrs);

int      dbd_db_login6_sv (SV *dbh, imp_dbh_t *imp_dbh, SV *dbname, SV *uid, SV *pwd, SV*attribs);
int      dbd_db_login6 (SV *dbh, imp_dbh_t *imp_dbh, char *dbname, char *uid, char *pwd, SV*attribs);
int      dbd_db_login  (SV *dbh, imp_dbh_t *imp_dbh, char *dbname, char *uid, char *pwd); /* deprecated */
/* Note: interface of dbd_db_do changed in v1.33 */
/* Old prototype: dbd_db_do (SV *sv, char *statement); */
/* dbd_db_do: optional: defined by a driver if the DBI default version is too slow */
int      dbd_db_do4 (SV *dbh, imp_dbh_t *imp_dbh, char *statement, SV *params);
int      dbd_db_commit     (SV *dbh, imp_dbh_t *imp_dbh);
int      dbd_db_rollback   (SV *dbh, imp_dbh_t *imp_dbh);
int      dbd_db_disconnect (SV *dbh, imp_dbh_t *imp_dbh);
void     dbd_db_destroy    (SV *dbh, imp_dbh_t *imp_dbh);
int      dbd_db_STORE_attrib (SV *dbh, imp_dbh_t *imp_dbh, SV *keysv, SV *valuesv);
SV      *dbd_db_FETCH_attrib (SV *dbh, imp_dbh_t *imp_dbh, SV *keysv);
SV      *dbd_db_last_insert_id (SV *dbh, imp_dbh_t *imp_dbh, SV *catalog, SV *schema, SV *table, SV *field, SV *attr);
AV      *dbd_db_data_sources (SV *dbh, imp_dbh_t *imp_dbh, SV *attr);

int      dbd_st_prepare (SV *sth, imp_sth_t *imp_sth, char *statement, SV *attribs);
int      dbd_st_prepare_sv (SV *sth, imp_sth_t *imp_sth, SV *statement, SV *attribs);
int      dbd_st_rows    (SV *sth, imp_sth_t *imp_sth);
int      dbd_st_execute (SV *sth, imp_sth_t *imp_sth);
AV      *dbd_st_fetch   (SV *sth, imp_sth_t *imp_sth);
int      dbd_st_finish3 (SV *sth, imp_sth_t *imp_sth, int from_destroy);
int      dbd_st_finish  (SV *sth, imp_sth_t *imp_sth); /* deprecated */
void     dbd_st_destroy (SV *sth, imp_sth_t *imp_sth);
int      dbd_st_blob_read (SV *sth, imp_sth_t *imp_sth, int field, long offset, long len, SV *destrv, long destoffset);
int      dbd_st_STORE_attrib (SV *sth, imp_sth_t *imp_sth, SV *keysv, SV *valuesv);
SV      *dbd_st_FETCH_attrib (SV *sth, imp_sth_t *imp_sth, SV *keysv);
SV      *dbd_st_execute_for_fetch (SV *sth, imp_sth_t *imp_sth, SV *fetch_tuple_sub, SV *tuple_status);

int      dbd_bind_ph  _((SV *sth, imp_sth_t *imp_sth, SV *param, SV *value, IV sql_type, SV *attribs, int is_inout, IV maxlen));

#include <stdlib.h>
#include <stdio.h>

// #include "Connection.h"
// #include "SQLException.h"

MODULE = DBD::NuoDB	PACKAGE = DBD::NuoDB

INCLUDE: NuoDB.knowngood.xsi.h

MODULE = DBD::NuoDB	PACKAGE = DBD::NuoDB

MODULE = DBD::NuoDB     PACKAGE = DBD::NuoDB::dr

MODULE = DBD::NuoDB    PACKAGE = DBD::NuoDB::db

const char *
version(dbh)
	SV* dbh
CODE:
	RETVAL = dbd_db_version(dbh);
OUTPUT:
	RETVAL

const char *
x_version(dbh)
	SV* dbh
CODE:
	RETVAL = dbd_db_version(dbh);
OUTPUT:
	RETVAL

MODULE = DBD::NuoDB    PACKAGE = DBD::NuoDB::st

const char *
analyze(sth)
	SV* sth
CODE:
	RETVAL = dbd_st_analyze(sth);
OUTPUT:
	RETVAL

const char *
x_analyze(sth)
	SV* sth
CODE:
	RETVAL = dbd_st_analyze(sth);
OUTPUT:
	RETVAL
