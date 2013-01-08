#include <DBIXS.h>

#undef dNOOP
#define dNOOP extern int __attribute__ ((unused)) Perl___notused

#include "Connection.h"
#include "ParameterMetaData.h"

struct imp_drh_st {
	dbih_drc_t com; /* MUST be first element in structure */
};

struct imp_dbh_st {
	dbih_dbc_t com; /* MUST be first element in structure */
	NuoDB::Connection* conn;
};

struct imp_sth_st {
	dbih_stc_t com; /* MUST be first element in structure */
	NuoDB::PreparedStatement *pstmt;
	NuoDB::ResultSet *rs;
};

#define dbd_init		nuodb_dr_init
#define dbd_db_login6_sv	nuodb_db_login6_sv
#define dbd_db_do		nuodb_db_do
#define dbd_st_prepare_sv	nuodb_st_prepare_sv
#define dbd_st_fetch		nuodb_st_fetch
#define dbd_st_destroy		nuodb_st_destroy
#define dbd_db_destroy		nuodb_db_destroy
#define dbd_db_disconnect	nuodb_db_disconnect

void do_error (SV *h, int rc, char *what);

const char * dbd_st_analyze(SV *sth);
const char * dbd_db_version(SV *dbh);
