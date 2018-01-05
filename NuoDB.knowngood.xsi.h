#  $Id: Driver.xst 14772 2011-03-25 21:45:26Z mjevans $
#  Copyright (c) 1997-2002  Tim Bunce  Ireland
#  Copyright (c) 2002       Jonathan Leffler
#
#  You may distribute under the terms of either the GNU General Public
#  License or the Artistic License, as specified in the Perl README file.


#include "Driver_xst.h"


MODULE = DBD::NuoDB  PACKAGE = DBD::NuoDB

REQUIRE:    1.929
PROTOTYPES: DISABLE

BOOT:
    items = 0;  /* avoid 'unused variable' warning */
    DBISTATE_INIT;
    /* XXX this interface will change: */
    DBI_IMP_SIZE("DBD::NuoDB::dr::imp_data_size", sizeof(imp_drh_t));
    DBI_IMP_SIZE("DBD::NuoDB::db::imp_data_size", sizeof(imp_dbh_t));
    DBI_IMP_SIZE("DBD::NuoDB::st::imp_data_size", sizeof(imp_sth_t));
    dbd_init(DBIS);


# ------------------------------------------------------------
# driver level interface
# ------------------------------------------------------------
MODULE = DBD::NuoDB  PACKAGE = DBD::NuoDB::dr


void
dbixs_revision(...)
    PPCODE:
    ST(0) = sv_2mortal(newSViv(DBIXS_REVISION));


#ifdef dbd_discon_all

# disconnect_all renamed and ALIAS'd to avoid length clash on VMS :-(
void
discon_all_(drh)
    SV *        drh
    ALIAS:
        disconnect_all = 1
    CODE:
    D_imp_drh(drh);
    if (0) ix = ix;     /* avoid unused variable warning */
    ST(0) = dbd_discon_all(drh, imp_drh) ? &PL_sv_yes : &PL_sv_no;

#endif /* dbd_discon_all */


#ifdef dbd_dr_data_sources

void
data_sources(drh, attr = Nullsv)
    SV *drh
    SV *attr
    PPCODE:
    {
        D_imp_drh(drh);
        AV *av = dbd_dr_data_sources(drh, imp_drh, attr);
        if (av) {
            int i;
            int n = AvFILL(av)+1;
            EXTEND(sp, n);
            for (i = 0; i < n; ++i) {
                PUSHs(AvARRAY(av)[i]);
            }
        }
    }

#endif


# ------------------------------------------------------------
# database level interface
# ------------------------------------------------------------
MODULE = DBD::NuoDB    PACKAGE = DBD::NuoDB::db


void
_login(dbh, dbname, username, password, attribs=Nullsv)
    SV *        dbh
    SV *        dbname
    SV *        username
    SV *        password
    SV *        attribs
    CODE:
    {
    D_imp_dbh(dbh);
#if !defined(dbd_db_login6_sv)
    STRLEN lna;
    char *u = (SvOK(username)) ? SvPV(username,lna) : "";
    char *p = (SvOK(password)) ? SvPV(password,lna) : "";
#endif
#ifdef dbd_db_login6_sv
    ST(0) = dbd_db_login6_sv(dbh, imp_dbh, dbname, username, password, attribs) ? &PL_sv_yes : &PL_sv_no;
#elif defined(dbd_db_login6)
    ST(0) = dbd_db_login6(dbh, imp_dbh, SvPV_nolen(dbname), u, p, attribs) ? &PL_sv_yes : &PL_sv_no;
#else
    ST(0) = dbd_db_login( dbh, imp_dbh, SvPV_nolen(dbname), u, p) ? &PL_sv_yes : &PL_sv_no;
#endif
    }


void
selectall_arrayref(...)
    PREINIT:
    SV *sth;
    SV **maxrows_svp;
    SV **tmp_svp;
    SV *attr = &PL_sv_undef;
    imp_sth_t *imp_sth;
    CODE:
    if (items > 2) {
        attr = ST(2);
        if (SvROK(attr) &&
                (DBD_ATTRIB_TRUE(attr,"Slice",5,tmp_svp) || DBD_ATTRIB_TRUE(attr,"Columns",7,tmp_svp))
        ) {
            /* fallback to perl implementation */
            SV *tmp =dbixst_bounce_method((char*)"DBD::NuoDB::db::SUPER::selectall_arrayref", items);
            SPAGAIN;
            ST(0) = tmp;
            XSRETURN(1);
        }
    }
    /* --- prepare --- */
    if (SvROK(ST(1))) {
        MAGIC *mg;
        sth = ST(1);
        /* switch to inner handle if not already */
        if ( (mg = mg_find(SvRV(sth),'P')) )
            sth = mg->mg_obj;
    }
    else {
        sth = dbixst_bounce_method((char*)"prepare", 3);
        SPAGAIN; SP -= items; /* because stack might have been realloc'd */
        if (!SvROK(sth))
            XSRETURN_UNDEF;
        /* switch to inner handle */
        sth = mg_find(SvRV(sth),'P')->mg_obj;
    }
    imp_sth = (imp_sth_t*)(DBIh_COM(sth));
    /* --- bind_param --- */
    if (items > 3) {    /* need to bind params before execute */
        if (!dbdxst_bind_params(sth, imp_sth, items-2, ax+2) ) {
            XSRETURN_UNDEF;
        }
    }
    /* --- execute --- */
    DBIc_ROW_COUNT(imp_sth) = 0;
    if ( dbd_st_execute(sth, imp_sth) <= -2 ) { /* -2 == error */
        XSRETURN_UNDEF;
    }
    /* --- fetchall --- */
    maxrows_svp = DBD_ATTRIB_GET_SVP(attr, "MaxRows", 7);
    ST(0) = dbdxst_fetchall_arrayref(sth, &PL_sv_undef, (maxrows_svp) ? *maxrows_svp : &PL_sv_undef);


void
selectrow_arrayref(...)
    ALIAS:
        selectrow_array = 1
    PREINIT:
    int is_selectrow_array = (ix == 1);
    imp_sth_t *imp_sth;
    SV *sth;
    AV *row_av;
    PPCODE:
    if (SvROK(ST(1))) {
        MAGIC *mg;
        sth = ST(1);
        /* switch to inner handle if not already */
        if ( (mg = mg_find(SvRV(sth),'P')) )
            sth = mg->mg_obj;
    }
    else {
        /* --- prepare --- */
        sth = dbixst_bounce_method((char*)"prepare", 3);
        SPAGAIN; SP -= items; /* because stack might have been realloc'd */
        if (!SvROK(sth)) {
            if (is_selectrow_array) { XSRETURN_EMPTY; } else { XSRETURN_UNDEF; }
        }
        /* switch to inner handle */
        sth = mg_find(SvRV(sth),'P')->mg_obj;
    }
    imp_sth = (imp_sth_t*)(DBIh_COM(sth));
    /* --- bind_param --- */
    if (items > 3) {    /* need to bind params before execute */
        if (!dbdxst_bind_params(sth, imp_sth, items-2, ax+2) ) {
            if (is_selectrow_array) { XSRETURN_EMPTY; } else { XSRETURN_UNDEF; }
        }
    }
    /* --- execute --- */
    DBIc_ROW_COUNT(imp_sth) = 0;
    if ( dbd_st_execute(sth, imp_sth) <= -2 ) { /* -2 == error */
        if (is_selectrow_array) { XSRETURN_EMPTY; } else { XSRETURN_UNDEF; }
    }
    /* --- fetchrow_arrayref --- */
    row_av = dbd_st_fetch(sth, imp_sth);
    if (!row_av) {
        if (GIMME == G_SCALAR)
            PUSHs(&PL_sv_undef);
    }
    else if (is_selectrow_array) {
        int i;
        int num_fields = AvFILL(row_av)+1;
        if (GIMME == G_SCALAR)
            num_fields = 1; /* return just first field */
        EXTEND(sp, num_fields);
        for(i=0; i < num_fields; ++i) {
            PUSHs(AvARRAY(row_av)[i]);
        }
    }
    else {
        PUSHs( sv_2mortal(newRV((SV *)row_av)) );
    }
    /* --- finish --- */
#ifdef dbd_st_finish3
    dbd_st_finish3(sth, imp_sth, 0);
#else
    dbd_st_finish(sth, imp_sth);
#endif


#ifdef dbd_db_do4 /* deebeedee-deebee-doo, deebee-doobee-dah? */

void
do(dbh, statement, params = Nullsv)
    SV *        dbh
    char *      statement
    SV *        params
    CODE:
    {
    D_imp_dbh(dbh);
    IV retval;
    retval = dbd_db_do4(dbh, imp_dbh, statement, params);
    /* remember that dbd_db_do4 must return <= -2 for error     */
    if (retval == 0)            /* ok with no rows affected     */
        XST_mPV(0, "0E0");      /* (true but zero)              */
    else if (retval < -1)       /* -1 == unknown number of rows */
        XST_mUNDEF(0);          /* <= -2 means error            */
    else
        XST_mIV(0, retval);     /* typically 1, rowcount or -1  */
    }

#endif


#ifdef dbd_db_last_insert_id

void
last_insert_id(dbh, catalog, schema, table, field, attr=Nullsv)
    SV *        dbh
    SV *        catalog
    SV *        schema
    SV *        table
    SV *        field
    SV *        attr
    CODE:
    {
    D_imp_dbh(dbh);
    ST(0) = dbd_db_last_insert_id(dbh, imp_dbh, catalog, schema, table, field, attr);
    }

#endif


void
commit(dbh)
    SV *        dbh
    CODE:
    D_imp_dbh(dbh);
    if (DBIc_has(imp_dbh,DBIcf_AutoCommit) && DBIc_WARN(imp_dbh))
        warn("commit ineffective with AutoCommit enabled");
    ST(0) = dbd_db_commit(dbh, imp_dbh) ? &PL_sv_yes : &PL_sv_no;


void
rollback(dbh)
    SV *        dbh
    CODE:
    D_imp_dbh(dbh);
    if (DBIc_has(imp_dbh,DBIcf_AutoCommit) && DBIc_WARN(imp_dbh))
        warn("rollback ineffective with AutoCommit enabled");
    ST(0) = dbd_db_rollback(dbh, imp_dbh) ? &PL_sv_yes : &PL_sv_no;


void
disconnect(dbh)
    SV *        dbh
    CODE:
    D_imp_dbh(dbh);
    if ( !DBIc_ACTIVE(imp_dbh) ) {
        XSRETURN_YES;
    }
    /* Check for disconnect() being called whilst refs to cursors       */
    /* still exists. This possibly needs some more thought.             */
    if (DBIc_ACTIVE_KIDS(imp_dbh) && DBIc_WARN(imp_dbh) && !PL_dirty) {
        STRLEN lna;
        warn("%s->disconnect invalidates %d active statement handle(s) %s",
            SvPV(dbh,lna), (int)DBIc_ACTIVE_KIDS(imp_dbh),
            "(either destroy statement handles or call finish on them before disconnecting)");
    }
    ST(0) = dbd_db_disconnect(dbh, imp_dbh) ? &PL_sv_yes : &PL_sv_no;
    DBIc_ACTIVE_off(imp_dbh);   /* ensure it's off, regardless */


void
STORE(dbh, keysv, valuesv)
    SV *        dbh
    SV *        keysv
    SV *        valuesv
    CODE:
    D_imp_dbh(dbh);
    if (SvGMAGICAL(valuesv))
        mg_get(valuesv);
    ST(0) = &PL_sv_yes;
    if (!dbd_db_STORE_attrib(dbh, imp_dbh, keysv, valuesv))
        if (!DBIc_DBISTATE(imp_dbh)->set_attr(dbh, keysv, valuesv))
            ST(0) = &PL_sv_no;


void
FETCH(dbh, keysv)
    SV *        dbh
    SV *        keysv
    CODE:
    D_imp_dbh(dbh);
    SV *valuesv = dbd_db_FETCH_attrib(dbh, imp_dbh, keysv);
    if (!valuesv)
        valuesv = DBIc_DBISTATE(imp_dbh)->get_attr(dbh, keysv);
    ST(0) = valuesv;    /* dbd_db_FETCH_attrib did sv_2mortal   */


void
DESTROY(dbh)
    SV *        dbh
    PPCODE:
    /* keep in sync with default DESTROY in DBI.xs */
    D_imp_dbh(dbh);
    ST(0) = &PL_sv_yes;
    if (!DBIc_IMPSET(imp_dbh)) {        /* was never fully set up       */
        STRLEN lna;
        if (DBIc_WARN(imp_dbh) && !PL_dirty && DBIc_DBISTATE(imp_dbh)->debug >= 2)
             PerlIO_printf(DBIc_LOGPIO(imp_dbh),
                "         DESTROY for %s ignored - handle not initialised\n",
                    SvPV(dbh,lna));
    }
    else {
        if (DBIc_IADESTROY(imp_dbh)) {            /* wants ineffective destroy */
            DBIc_ACTIVE_off(imp_dbh);
            if (DBIc_DBISTATE(imp_dbh)->debug)
                 PerlIO_printf(DBIc_LOGPIO(imp_dbh), "         DESTROY %s skipped due to InactiveDestroy\n", SvPV_nolen(dbh));
        }
        if (DBIc_ACTIVE(imp_dbh)) {
            if (!DBIc_has(imp_dbh,DBIcf_AutoCommit)) {
                /* Application is using transactions and hasn't explicitly disconnected.
                    Some databases will automatically commit on graceful disconnect.
                    Since we're about to gracefully disconnect as part of the DESTROY
                    we want to be sure we're not about to implicitly commit changes
                    that are incomplete and should be rolled back. (The DESTROY may
                    be due to a RaiseError, for example.) So we rollback here.
                    This will be harmless if the application has issued a commit,
                    XXX Could add an attribute flag to indicate that the driver
                    doesn't have this problem. Patches welcome.
                */
                if (DBIc_WARN(imp_dbh) /* only warn if likely to be useful... */
                &&  DBIc_is(imp_dbh, DBIcf_Executed) /* has not just called commit/rollback */
            /*  && !DBIc_is(imp_dbh, DBIcf_ReadOnly) -- is not read only */
                && (!PL_dirty || DBIc_DBISTATE(imp_dbh)->debug >= 3)
                ) {
                    warn("Issuing rollback() due to DESTROY without explicit disconnect() of %s handle %s",
                        SvPV_nolen(*hv_fetch((HV*)SvRV(dbh), "ImplementorClass", 16, 1)),
                        SvPV_nolen(*hv_fetch((HV*)SvRV(dbh), "Name", 4, 1))
                    );
                }
                dbd_db_rollback(dbh, imp_dbh);                  /* ROLLBACK! */
            }
            dbd_db_disconnect(dbh, imp_dbh);
            DBIc_ACTIVE_off(imp_dbh);   /* ensure it's off, regardless */
        }
        dbd_db_destroy(dbh, imp_dbh);
    }


#ifdef dbd_take_imp_data

void
take_imp_data(h)
    SV * h
    CODE:
    D_imp_xxh(h);
    /* dbd_take_imp_data() returns &sv_no (or other defined but false value)
     * to indicate "preparations complete, now call SUPER::take_imp_data" for me.
     * Anything else is returned to the caller via sv_2mortal(sv), typically that
     * would be &sv_undef for error or an SV holding the imp_data.
     */
    SV *sv = dbd_take_imp_data(h, imp_xxh, NULL);
    if (SvOK(sv) && !SvTRUE(sv)) {
        SV *tmp = dbixst_bounce_method((char*)"DBD::NuoDB::db::SUPER::take_imp_data", items);
        SPAGAIN;
        ST(0) = tmp;
    } else {
        ST(0) = sv_2mortal(sv);
    }

#endif

#ifdef dbd_db_data_sources

void
data_sources(dbh, attr = Nullsv)
    SV *dbh
    SV *attr
    PPCODE:
    {
        D_imp_dbh(dbh);
        AV *av = dbd_db_data_sources(dbh, imp_dbh, attr);
        if (av) {
            int i;
            int n = AvFILL(av)+1;
            EXTEND(sp, n);
            for (i = 0; i < n; ++i) {
                PUSHs(AvARRAY(av)[i]);
            }
        }
    }

#endif

# -- end of DBD::NuoDB::db

# ------------------------------------------------------------
# statement interface
# ------------------------------------------------------------
MODULE = DBD::NuoDB    PACKAGE = DBD::NuoDB::st


void
_prepare(sth, statement, attribs=Nullsv)
    SV *        sth
    SV *        statement
    SV *        attribs
    CODE:
    {
    D_imp_sth(sth);
    DBD_ATTRIBS_CHECK("_prepare", sth, attribs);
#ifdef dbd_st_prepare_sv
    ST(0) = dbd_st_prepare_sv(sth, imp_sth, statement, attribs) ? &PL_sv_yes : &PL_sv_no;
#else
    ST(0) = dbd_st_prepare(sth, imp_sth, SvPV_nolen(statement), attribs) ? &PL_sv_yes : &PL_sv_no;
#endif
    }


#ifdef dbd_st_rows

void
rows(sth)
    SV *        sth
    CODE:
    D_imp_sth(sth);
    XST_mIV(0, dbd_st_rows(sth, imp_sth));

#endif /* dbd_st_rows */


#ifdef dbd_st_bind_col

void
bind_col(sth, col, ref, attribs=Nullsv)
    SV *        sth
    SV *        col
    SV *        ref
    SV *        attribs
    CODE:
    {
    IV sql_type = 0;
    D_imp_sth(sth);
    if (SvGMAGICAL(ref))
        mg_get(ref);
    if (attribs) {
        if (SvNIOK(attribs)) {
            sql_type = SvIV(attribs);
            attribs = Nullsv;
        }
        else {
            SV **svp;
            DBD_ATTRIBS_CHECK("bind_col", sth, attribs);
            /* XXX we should perhaps complain if TYPE is not SvNIOK */
            DBD_ATTRIB_GET_IV(attribs, "TYPE",4, svp, sql_type);
        }
    }
    switch(dbd_st_bind_col(sth, imp_sth, col, ref, sql_type, attribs)) {
    case 2:     ST(0) = &PL_sv_yes;        /* job done completely */
                break;
    case 1:     /* fallback to DBI default */
                ST(0) = (DBIc_DBISTATE(imp_sth)->bind_col(sth, col, ref, attribs))
                    ? &PL_sv_yes : &PL_sv_no;
                break;
    default:    ST(0) = &PL_sv_no;         /* dbd_st_bind_col has called set_err */
                break;
    }
    }

#endif /* dbd_st_bind_col */

void
bind_param(sth, param, value, attribs=Nullsv)
    SV *        sth
    SV *        param
    SV *        value
    SV *        attribs
    CODE:
    {
    IV sql_type = 0;
    D_imp_sth(sth);
    if (SvGMAGICAL(value))
        mg_get(value);
    if (attribs) {
        if (SvNIOK(attribs)) {
            sql_type = SvIV(attribs);
            attribs = Nullsv;
        }
        else {
            SV **svp;
            DBD_ATTRIBS_CHECK("bind_param", sth, attribs);
            /* XXX we should perhaps complain if TYPE is not SvNIOK */
            DBD_ATTRIB_GET_IV(attribs, "TYPE",4, svp, sql_type);
        }
    }
    ST(0) = dbd_bind_ph(sth, imp_sth, param, value, sql_type, attribs, FALSE, 0)
                ? &PL_sv_yes : &PL_sv_no;
    }


void
bind_param_inout(sth, param, value_ref, maxlen, attribs=Nullsv)
    SV *        sth
    SV *        param
    SV *        value_ref
    IV          maxlen
    SV *        attribs
    CODE:
    {
    IV sql_type = 0;
    D_imp_sth(sth);
    SV *value;
    if (!SvROK(value_ref) || SvTYPE(SvRV(value_ref)) > SVt_PVMG)
        croak("bind_param_inout needs a reference to a scalar value");
    value = SvRV(value_ref);
    if (SvREADONLY(value))
        croak("Modification of a read-only value attempted");
    if (SvGMAGICAL(value))
        mg_get(value);
    if (attribs) {
        if (SvNIOK(attribs)) {
            sql_type = SvIV(attribs);
            attribs = Nullsv;
        }
        else {
            SV **svp;
            DBD_ATTRIBS_CHECK("bind_param", sth, attribs);
            DBD_ATTRIB_GET_IV(attribs, "TYPE",4, svp, sql_type);
        }
    }
    ST(0) = dbd_bind_ph(sth, imp_sth, param, value, sql_type, attribs, TRUE, maxlen)
                ? &PL_sv_yes : &PL_sv_no;
    }


void
execute(sth, ...)
    SV *        sth
    CODE:
    D_imp_sth(sth);
    int retval;
    if (items > 1) {    /* need to bind params */
        if (!dbdxst_bind_params(sth, imp_sth, items, ax) ) {
            XSRETURN_UNDEF;
        }
    }
    /* XXX this code is duplicated in selectrow_arrayref above  */
    if (DBIc_ROW_COUNT(imp_sth) > 0) /* reset for re-execute */
        DBIc_ROW_COUNT(imp_sth) = 0;
    retval = dbd_st_execute(sth, imp_sth);
    /* remember that dbd_st_execute must return <= -2 for error */
    if (retval == 0)            /* ok with no rows affected     */
        XST_mPV(0, "0E0");      /* (true but zero)              */
    else if (retval < -1)       /* -1 == unknown number of rows */
        XST_mUNDEF(0);          /* <= -2 means error            */
    else
        XST_mIV(0, retval);     /* typically 1, rowcount or -1  */


#ifdef dbd_st_execute_for_fetch

void
execute_for_fetch(sth, fetch_tuple_sub, tuple_status = Nullsv)
    SV *        sth
    SV *        fetch_tuple_sub
    SV *        tuple_status
    CODE:
    {
    D_imp_sth(sth);
    ST(0) = dbd_st_execute_for_fetch(sth, imp_sth, fetch_tuple_sub, tuple_status);
    }

#endif



void
fetchrow_arrayref(sth)
    SV *        sth
    ALIAS:
        fetch = 1
    CODE:
    D_imp_sth(sth);
    AV *av;
    if (0) ix = ix;     /* avoid unused variable warning */
    av = dbd_st_fetch(sth, imp_sth);
    ST(0) = (av) ? sv_2mortal(newRV((SV *)av)) : &PL_sv_undef;


void
fetchrow_array(sth)
    SV *        sth
    ALIAS:
        fetchrow = 1
    PPCODE:
    D_imp_sth(sth);
    AV *av;
    av = dbd_st_fetch(sth, imp_sth);
    if (av) {
        int i;
        int num_fields = AvFILL(av)+1;
        EXTEND(sp, num_fields);
        for(i=0; i < num_fields; ++i) {
            PUSHs(AvARRAY(av)[i]);
        }
        if (0) ix = ix; /* avoid unused variable warning */
    }


void
fetchall_arrayref(sth, slice=&PL_sv_undef, batch_row_count=&PL_sv_undef)
    SV *        sth
    SV *        slice
    SV *        batch_row_count
    CODE:
    if (SvOK(slice)) {  /* fallback to perl implementation */
        SV *tmp = dbixst_bounce_method((char*)"DBD::NuoDB::st::SUPER::fetchall_arrayref", 3);
        SPAGAIN;
        ST(0) = tmp;
    }
    else {
        ST(0) = dbdxst_fetchall_arrayref(sth, slice, batch_row_count);
    }


void
finish(sth)
    SV *        sth
    CODE:
    D_imp_sth(sth);
    D_imp_dbh_from_sth;
    if (!DBIc_ACTIVE(imp_sth)) {
        /* No active statement to finish        */
        XSRETURN_YES;
    }
    if (!DBIc_ACTIVE(imp_dbh)) {
        /* Either an explicit disconnect() or global destruction        */
        /* has disconnected us from the database. Finish is meaningless */
        DBIc_ACTIVE_off(imp_sth);
        XSRETURN_YES;
    }
#ifdef dbd_st_finish3
    ST(0) = dbd_st_finish3(sth, imp_sth, 0) ? &PL_sv_yes : &PL_sv_no;
#else
    ST(0) = dbd_st_finish(sth, imp_sth) ? &PL_sv_yes : &PL_sv_no;
#endif


void
blob_read(sth, field, offset, len, destrv=Nullsv, destoffset=0)
    SV *        sth
    int field
    long        offset
    long        len
    SV *        destrv
    long        destoffset
    CODE:
    {
    D_imp_sth(sth);
    if (!destrv)
        destrv = sv_2mortal(newRV(sv_2mortal(newSV(0))));
    if (dbd_st_blob_read(sth, imp_sth, field, offset, len, destrv, destoffset))
         ST(0) = SvRV(destrv);
    else ST(0) = &PL_sv_undef;
    }


void
STORE(sth, keysv, valuesv)
    SV *        sth
    SV *        keysv
    SV *        valuesv
    CODE:
    D_imp_sth(sth);
    if (SvGMAGICAL(valuesv))
        mg_get(valuesv);
    ST(0) = &PL_sv_yes;
    if (!dbd_st_STORE_attrib(sth, imp_sth, keysv, valuesv))
        if (!DBIc_DBISTATE(imp_sth)->set_attr(sth, keysv, valuesv))
            ST(0) = &PL_sv_no;


# FETCH renamed and ALIAS'd to avoid case clash on VMS :-(
void
FETCH_attrib(sth, keysv)
    SV *        sth
    SV *        keysv
    ALIAS:
    FETCH = 1
    CODE:
    D_imp_sth(sth);
    SV *valuesv;
    if (0) ix = ix;     /* avoid unused variable warning */
    valuesv = dbd_st_FETCH_attrib(sth, imp_sth, keysv);
    if (!valuesv)
        valuesv = DBIc_DBISTATE(imp_sth)->get_attr(sth, keysv);
    ST(0) = valuesv;    /* dbd_st_FETCH_attrib did sv_2mortal   */


void
DESTROY(sth)
    SV *        sth
    PPCODE:
    /* keep in sync with default DESTROY in DBI.xs */
    D_imp_sth(sth);
    ST(0) = &PL_sv_yes;
    if (!DBIc_IMPSET(imp_sth)) {        /* was never fully set up       */
        STRLEN lna;
        if (DBIc_WARN(imp_sth) && !PL_dirty && DBIc_DBISTATE(imp_sth)->debug >= 2)
             PerlIO_printf(DBIc_LOGPIO(imp_sth),
                "         DESTROY for %s ignored - handle not initialised\n",
                    SvPV(sth,lna));
    }
    else {
        if (DBIc_IADESTROY(imp_sth)) {  /* wants ineffective destroy    */
            DBIc_ACTIVE_off(imp_sth);
            if (DBIc_DBISTATE(imp_sth)->debug)
                 PerlIO_printf(DBIc_LOGPIO(imp_sth), "         DESTROY %s skipped due to InactiveDestroy\n", SvPV_nolen(sth));
        }
        if (DBIc_ACTIVE(imp_sth)) {
            D_imp_dbh_from_sth;
            if (!PL_dirty && DBIc_ACTIVE(imp_dbh)) {
#ifdef dbd_st_finish3
                dbd_st_finish3(sth, imp_sth, 1);
#else
                dbd_st_finish(sth, imp_sth);
#endif
            }
            else {
                DBIc_ACTIVE_off(imp_sth);
            }
        }
        dbd_st_destroy(sth, imp_sth);
    }

# end of NuoDB.xst
# vim:ts=8:sw=4:et
