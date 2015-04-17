create or replace 
PACKAGE BODY twbcmain AS

--AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : TWBCMAI1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Tue Dec 29 14:25:12 2009
-- MSGSIGN : #82abe2b63bf2e035
--TMI18N.ETR DO NOT CHANGE--
-- PROJECT : MSGKEY
-- MODULE  : TWBCMAI1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Fri Jun 20 03:55:44 2008
-- MSGSIGN : #2019bd2754be9482
--TMI18N.ETR DO NOT CHANGE--
--
-- FILE NAME..: TWBCMAI1.SQL
-- RELEASE....: 8.2.0.1
-- OBJECT NAME: TWBCMAIN
-- PRODUCT....: CHANNELS
-- USAGE......: Main channel package.
-- COPYRIGHT..: Copyright 2004 - 2009 SunGard. All rights reserved.
--
-- DESCRIPTION:
--
-- Channel Main Package.
--
-- This will be the main package that Luminis java classes will call.
--
-- DESCRIPTION END
--
--
-----------------------------------------------------------------
--
--
--
   FUNCTION f_get_pidm(p_spriden_id IN VARCHAR2) RETURN NUMBER;
   --
   --
   -----------------------------------------------------------------
   --
   --
   FUNCTION f_current_view (p_token IN VARCHAR2)
   RETURN VARCHAR2;

   --
   --
   -----------------------------------------------------------------
   --
   -- This will be called from channel unsubscribe event
   --
   --
   PROCEDURE p_channel_cleanup(p_name       IN VARCHAR2,
                               p_banner_id  IN VARCHAR2,
                               p_sub_id     IN VARCHAR2) IS
   BEGIN
       delete from twgruprf where
		twgruprf_name      = p_name      AND
		twgruprf_pref_user = p_banner_id AND
		twgruprf_sub_id    = p_sub_id;
   END;

   -----------------------------------------------------------------
   --
   --
   --
   --
   PROCEDURE p_set_parm(p_name  IN VARCHAR2,
                        p_value IN VARCHAR2) IS
   BEGIN
      twbcmain.parm_table(p_name) := p_value;
   END;

   --
   --
   -----------------------------------------------------------------
   --
   --
   --
   --
   FUNCTION f_main_xml(p_channel_name IN VARCHAR2,
                       p_spriden_id   IN VARCHAR2,
                       p_luminis_id   IN VARCHAR2,
                       p_data_token   IN VARCHAR2,
                       p_channel_mode IN VARCHAR2,
                       p_focus        IN VARCHAR2,
                       p_sub_id       IN VARCHAR2 DEFAULT NULL,
                       p_locale       IN VARCHAR2 DEFAULT NULL,
                       p_vpd_code     IN VARCHAR2 DEFAULT NULL
                       ) RETURN VARCHAR2 IS
      CURSOR c_twgrchnl(ch_name IN VARCHAR2,
                        ch_mode IN VARCHAR2,
                        ch_view IN VARCHAR2) IS
         SELECT twgrcmap_procedure,
                twgrchnl_secure_ind
           FROM twgrchnl,
                twgrcmap
          WHERE twgrchnl_name = twgrcmap_name AND
                twgrcmap_name = upper(ch_name) AND
                twgrcmap_mode = upper(ch_mode) AND
                twgrcmap_view = upper(ch_view);

      lv_procedure     twgrcmap.twgrcmap_procedure%TYPE;
      lv_sec_ind       twgrchnl.twgrchnl_secure_ind%TYPE;
      lv_proc_name     twgrchnl.twgrchnl_name%TYPE;
      lv_sub_id        twgruprf.twgruprf_sub_id%type;
      lv_view          twgrcmap.twgrcmap_view%type;
      lv_pidm          NUMBER;
      lv_err           VARCHAR2(2000);
      lv_proc_str      VARCHAR2(2000);
      lv_mode_notfound BOOLEAN := TRUE;
      --my_xml           NVARCHAR2(32600);
      my_xml           VARCHAR2(32600);
      lv_xml           CLOB;
      mode_not_found EXCEPTION;
      vpd_not_found EXCEPTION;
      vpd_not_valid EXCEPTION;
      invalid_banner_id EXCEPTION;
      parm_table twbcmain.ch_main_parm;
   BEGIN

      IF p_channel_mode = 'UNSUBSCRIBE' THEN
        p_channel_cleanup(p_channel_name,
			  p_spriden_id,
		          p_sub_id);
        return my_xml;
      END IF;

      IF p_locale IS NOT NULL THEN
        dbms_session.set_nls('NLS_LANGUAGE', '"'||UTL_I18N.MAP_LANGUAGE_FROM_ISO(p_locale)||'"');
        dbms_session.set_nls('NLS_TERRITORY', '"'||UTL_I18N.MAP_TERRITORY_FROM_ISO(p_locale)||'"');
      END IF;

      IF p_vpd_code is NOT NULL THEN
      IF G$_VPDI_SECURITY.G$_IS_MIF_ENABLED  THEN
        IF not gokvpda.F_IS_VPDI_CODE_VALID(user,p_vpd_code) THEN
            RAISE vpd_not_valid;
        END IF;
        gokvpda.p_set_vpdi_for_query(p_vpd_code);
      END IF;
      END IF;
      lv_sub_id := p_sub_id;
      lv_mode_notfound := TRUE;
      lv_view := f_current_view (p_data_token);
----------------------------------------------------
--
--  Get procedure/Function name
--
      OPEN c_twgrchnl(p_channel_name,
                      p_channel_mode,
                      lv_view);
      FETCH c_twgrchnl
         INTO lv_procedure, lv_sec_ind;
      IF c_twgrchnl%NOTFOUND
      THEN
         lv_mode_notfound := FALSE;
      END IF;
      CLOSE c_twgrchnl;
      IF NOT lv_mode_notfound
      THEN
         OPEN c_twgrchnl(p_channel_name,
                         'DEFAULT',
                         'DEFAULT');
         FETCH c_twgrchnl
            INTO lv_procedure, lv_sec_ind;
         IF c_twgrchnl%NOTFOUND
         THEN
            RAISE mode_not_found;
         END IF;
         CLOSE c_twgrchnl;
      END IF;

--
--  Validate only if secured indicator is checked
--

      IF nvl(lv_sec_ind,'Y') = 'Y' THEN
        lv_pidm := f_get_pidm(p_spriden_id);
      	IF lv_pidm IS NULL
      		THEN
        	RAISE invalid_banner_id;
      	END IF;
      END IF;
--
--  End of Secured indicator
--
----- Build Channel Parameter PL/SQL table ------------------

      p_set_parm('CHANNEL_NAME',
                 p_channel_name);
      p_set_parm('CHANNEL_MODE',
                 p_channel_mode);
      p_set_parm('SPRIDEN_ID',
                 p_spriden_id);
      p_set_parm('LUMINIS_ID',
                 p_luminis_id);
      p_set_parm('FOCUS',
                 p_focus);
      p_set_parm('PIDM',
                 lv_pidm);
      if lv_sub_id is null then
         p_set_parm('SUB_ID',
                 'DEFAULT');
      else
         p_set_parm('SUB_ID',
                 lv_sub_id);
      end if;
      ------------------------------------------------------------------
      lv_proc_str := 'begin :1 := ' || lv_procedure || ' ( :2 ); end;';

      EXECUTE IMMEDIATE lv_proc_str
      USING OUT lv_xml, IN p_data_token;

      twbcmxml.p_convertclob(lv_xml,my_xml);


      RETURN my_xml;
      --
      -- Exceptions
      --
   EXCEPTION
      WHEN invalid_banner_id THEN
         my_xml := twbcmxml.f_error_message(
             g$_nls.get('TWBCMAI1-0000','SQL','External System ID not found. '));
         RETURN my_xml;
      WHEN vpd_not_valid THEN
         my_xml := twbcmxml.f_error_message(
             g$_nls.get('TWBCMAI1-0001','SQL','Invalid Institution. '));
         RETURN my_xml;
      WHEN vpd_not_found THEN
         my_xml := twbcmxml.f_error_message(
             g$_nls.get('TWBCMAI1-0002','SQL','Invalid Institution. '));
         RETURN my_xml;
      WHEN mode_not_found THEN
         my_xml := twbcmxml.f_error_message(
                             g$_nls.get('TWBCMAI1-0003','SQL', 'Channel Mode not defined.'));
         RETURN my_xml;
      WHEN OTHERS THEN
         lv_err := substr(SQLERRM,
                          1,
                          255);
         my_xml := twbcmxml.f_error_message(G$_nls.Get('TWBCMAI1-0004','SQL','Error processing channel: %01% %02%',p_channel_name,p_channel_mode));
         RETURN my_xml;
   END f_main_xml;

   --
   --
   --
   --
   --
   -----------------------------------------------------------------
   --
   --
   FUNCTION f_chnl_default(p_def_mode IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2
      IS
      CURSOR c_twgrchnl(ch_name IN VARCHAR2, ch_mode IN VARCHAR2) IS
         SELECT twgrcmap_procedure
           FROM twgrchnl,
                twgrcmap
          WHERE twgrchnl_name = twgrcmap_name AND
                twgrcmap_name = upper(ch_name) AND
                twgrcmap_mode = upper(ch_mode);
      lv_procedure twgrcmap.twgrcmap_procedure%TYPE;
      lv_pidm      NUMBER;
      lv_err       VARCHAR2(2000);
      lv_proc_str  VARCHAR2(2000);
      my_xml       NVARCHAR2(32600);
      mode_not_found EXCEPTION;
      parm_table      twbcmain.ch_main_parm;
      lv_channel_name twgrchnl.twgrchnl_name%TYPE;
      lv_data_token   VARCHAR2(200) := NULL;
   BEGIN
      --
      ---
      --Debug statement here
      --
      --
      lv_channel_name := f_get_parm('CHANNEL_NAME');
      OPEN c_twgrchnl(lv_channel_name,
                      p_def_mode);
      FETCH c_twgrchnl
         INTO lv_procedure;
      IF c_twgrchnl%NOTFOUND
      THEN
         CLOSE c_twgrchnl;
         RAISE mode_not_found;
      END IF;
      CLOSE c_twgrchnl;
      lv_proc_str := 'begin :1 := ' || lv_procedure || ' ( :2 ); end;';
      EXECUTE IMMEDIATE lv_proc_str
         USING OUT my_xml, IN lv_data_token;
      RETURN my_xml;
   EXCEPTION
      WHEN mode_not_found THEN
         my_xml := twbcmxml.f_error_message
              (g$_nls.get('TWBCMAI1-0005','SQL','Channel Mode not defined for channel '));
         RETURN my_xml;
      WHEN OTHERS THEN
         lv_err := substr(SQLERRM,
                          1,
                          255);
         my_xml := twbcmxml.f_error_message(G$_nls.Get('TWBCMAI1-0006','SQL','Error rendering channel'));
         RETURN my_xml;
   END f_chnl_default;

   --
   --
   --
   --
   --------------------------------------------------------------------------
   FUNCTION f_current_view (p_token  IN VARCHAR2)
   RETURN VARCHAR2 IS
      lv_current_view  twgrcmap.twgrcmap_view%type;
   BEGIN
       lv_current_view := 'DEFAULT';
       IF instr(p_token , 'VIEW') > 0 THEN
         lv_current_view := twbcmxml.f_get_token_parm_val('VIEW' , p_token);
       END IF;
       RETURN lv_current_view;
   END;
   --
   --
   --
   --
   --------------------------------------------------------------------------
   FUNCTION f_get_pidm(p_spriden_id IN VARCHAR2) RETURN NUMBER IS
      lv_pidm     number;
      lv_proc_str varchar2(1000);
   BEGIN
     lv_pidm := twbkslib.f_fetchpidm(p_spriden_id);
     RETURN lv_pidm;
   END f_get_pidm;

   --
   --
   -----------------------------------------------------------------
   --
   --
   --
   --
   FUNCTION f_get_parm(p_name IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
      RETURN twbcmain.parm_table(p_name);
   END;

---------------------------------------------------------------------------
END twbcmain;
 