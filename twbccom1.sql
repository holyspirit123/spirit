create or replace 
PACKAGE BODY TWBCCOMN AS

   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : TWBCCOM1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Thu Mar 25 22:04:40 2010
-- MSGSIGN : #91092b3eb68e1b46
--TMI18N.ETR DO NOT CHANGE--
--
   -- FILE NAME..: twbccom1.sql
   -- RELEASE....: 8.2.0.2
   -- OBJECT NAME: TWBCCOMN
   -- PRODUCT....: CHANNELS
   -- COPYRIGHT..: Copyright 2004 - 2010 SunGard. All rights reserved.
   --
   --
   --
   -- =======================================================
   FUNCTION f_get_about(p_data_token IN VARCHAR2)
   RETURN VARCHAR2 IS
      my_xml VARCHAR2(20000);
   BEGIN
      my_xml := '<CHANNELDATA><MESSAGE><GROUP><TEXT>This is about text' ||
                '</TEXT></GROUP></MESSAGE></CHANNELDATA>';
      RETURN my_xml;
   END;

   -- =======================================================
   FUNCTION f_get_help(p_data_token IN VARCHAR2)
   RETURN VARCHAR2 IS
      my_xml VARCHAR2(20000);
   BEGIN
      my_xml := '<CHANNELDATA><MESSAGE><GROUP><TEXT>This is help' ||
                '</TEXT></GROUP></MESSAGE></CHANNELDATA>';
      RETURN my_xml;
   END;

   --
   --
   --------------------------------------------------------------
   --
   -- This functions returns  data in REF Cursor.
   FUNCTION f_get_pref(p_bannerid     IN VARCHAR2,
                       p_channel_name IN VARCHAR2
                       )
      RETURN pref_ref IS
      c_pref pref_ref;
      lv_sub_id   twgruprf.twgruprf_sub_id%type;
   BEGIN
      lv_sub_id := twbcmain.f_get_parm('SUB_ID');
      OPEN c_pref FOR
         SELECT decode(twgruprf_group,'LOCAL_SS','SS',
                                      'LOCAL_WEB','WEB',
                                      'LOCAL_INB','INB',
                       twgruprf_group)      "PREF_GROUP",
                twgruprf_key      "PREF_KEY",
                twgruprf_desc     "PREF_NAME",
                twbccomn.f_encodexml(decode(twgruprf_value,'~','',twgruprf_value))
                "PREF_VALUE",
                twgruprf_edit_ind      "PREF_EDIT",
                twgruprf_sort_order    "PREF_SORT"
           FROM twgruprf
          WHERE twgruprf_name     = upper(p_channel_name) AND
                twgruprf_pref_user = p_bannerid   AND
                twgruprf_sub_id    = lv_sub_id
         UNION
         SELECT decode(twgruprf_group,'LOCAL_SS','SS',
                                      'LOCAL_WEB','WEB',
                                      'LOCAL_INB','INB',
                       twgruprf_group)      "PREF_GROUP",
                twgruprf_key        "PREF_KEY",
                twgruprf_desc     "PREF_NAME",
                twbccomn.f_encodexml(decode(twgruprf_value,'~','',twgruprf_value)),
                twgruprf_edit_ind      "PREF_EDIT",
                twgruprf_sort_order "PREF_SORT"
           FROM twgruprf
          WHERE twgruprf_name = upper(p_channel_name) AND
                twgruprf_pref_user = 'BASELINE' AND
                twgruprf_key NOT IN
                (SELECT twgruprf_key
                    FROM twgruprf
                   WHERE twgruprf_name = upper(p_channel_name) AND
                         twgruprf_pref_user = p_bannerid AND
                         twgruprf_sub_id = lv_sub_id)
          ORDER BY 6;
      RETURN c_pref;
   END;

   --
   -- This functions returns  data in XML format.
   --
   --
   -- =======================================================
   -----------------------------------------------------------------
   PROCEDURE p_update_pref(p_channel_name IN VARCHAR2,
                           p_banner_id    IN VARCHAR2,
                           p_sub_id       IN VARCHAR2,
                           p_pref_name    IN VARCHAR2,
                           p_pref_value   IN VARCHAR2) IS
      CURSOR c_basepref IS
         SELECT *
           FROM twgruprf
          WHERE twgruprf_name = upper(p_channel_name) AND
	        twgruprf_edit_ind = 'Y'  AND
                twgruprf_pref_user = 'BASELINE' AND
                twgruprf_key = p_pref_name;

      CURSOR c_userpref IS
         SELECT 'Y'
           FROM twgruprf
          WHERE twgruprf_name = upper(p_channel_name) AND
                twgruprf_key = p_pref_name AND
                twgruprf_pref_user = p_banner_id AND
                twgruprf_sub_id = p_sub_id;
      pref_found BOOLEAN;
      temp_str   VARCHAR2(20);
      pref_rec   twgruprf%ROWTYPE;
      --
      --
   BEGIN
      --
      --

      OPEN c_userpref;
      FETCH c_userpref
         INTO temp_str;
      IF c_userpref%NOTFOUND
      THEN
         pref_found := FALSE;
      ELSE
         pref_found := TRUE;
      END IF;
      CLOSE c_userpref;
      IF pref_found
      THEN

         UPDATE twgruprf
            SET twgruprf_value         = nvl(p_pref_value,'~'),
                twgruprf_activity_date = SYSDATE,
                twgruprf_user_id       = USER
          WHERE twgruprf_name      = upper(p_channel_name) AND
                twgruprf_key       = p_pref_name AND
                twgruprf_pref_user = p_banner_id AND
                twgruprf_sub_id    = p_sub_id;
      ELSE
         OPEN c_basepref;
         FETCH c_basepref
            INTO pref_rec;
         IF c_basepref%FOUND
         THEN
            INSERT INTO twgruprf
               (twgruprf_name,
                twgruprf_group,
                twgruprf_key,
		        twgruprf_pref_user,
		        twgruprf_sub_id,
                twgruprf_desc,
                twgruprf_value,
                twgruprf_activity_date,
                twgruprf_user_id,
                twgruprf_edit_ind,
                twgruprf_display_type,
                twgruprf_sort_order)
            VALUES
               (pref_rec.twgruprf_name,
                pref_rec.twgruprf_group,
                pref_rec.twgruprf_key,
		        p_banner_id,
                p_sub_id,
                pref_rec.twgruprf_desc,
                nvl(p_pref_value,'~'),
                SYSDATE,
                user,
                pref_rec.twgruprf_edit_ind,
                pref_rec.twgruprf_display_type,
                pref_rec.twgruprf_sort_order);
         END IF;
         CLOSE c_basepref;
      END IF;
   END;

   --
   ------------------------------------------------------------
   --
   FUNCTION f_del_pref_xml(
                           p_data_token   IN VARCHAR2
                           )
   RETURN VARCHAR2 IS
      channel_name    twgrchnl.twgrchnl_name%type := twbcmain.parm_table('CHANNEL_NAME');
      spriden_id      VARCHAR2(50) := twbcmain.parm_table('SPRIDEN_ID');

      pref_exist VARCHAR2(1);
      my_xml     VARCHAR2(32000);
      CURSOR c1_pref IS
         SELECT 'Y'
           FROM twgruprf
          WHERE twgruprf_name = upper(channel_name) AND
                twgruprf_pref_user = spriden_id;
   BEGIN

      OPEN c1_pref;
      FETCH c1_pref
         INTO pref_exist;
      CLOSE c1_pref;
      IF nvl(pref_exist, 'N') = 'Y'
      THEN
         DELETE FROM twgruprf
          WHERE upper(twgruprf_name) = upper(channel_name) AND
                twgruprf_pref_user = spriden_id;
      END IF;
      COMMIT;
      my_xml := twbcmain.f_chnl_default('EDIT');
      RETURN my_xml;
   END;

   --------------------------------------------------------------
   FUNCTION f_set_pref_xml(p_data_token   IN VARCHAR2)
   RETURN VARCHAR2 IS
      c_pref       pref_ref;
      my_xml       VARCHAR2(32000);
      xml_clob     CLOB;
      working_clob CLOB;
      buffer       VARCHAR2(2000);
      fac_pref_tab pref_tab;
      num_tok      NUMBER;
      pref_name    VARCHAR2(255);
      pref_value   VARCHAR2(255);
      channel_name    twgrchnl.twgrchnl_name%type ;
      spriden_id      VARCHAR2(50) ;
      sub_id          twgruprf.twgruprf_sub_id%type;
      CURSOR c1 IS
         SELECT twgruprf_group, twgruprf_key, twgruprf_value
           FROM twgruprf
          WHERE twgruprf_name 	=  upper(channel_name)  AND
                twgruprf_key 	IS NOT NULL 		AND
                twgruprf_pref_user = 'BASELINE' 	AND
                twgruprf_display_type = 'C';
      idx        VARCHAR2(255);
      checkfound BOOLEAN;
   BEGIN
      channel_name    := twbcmain.f_get_parm('CHANNEL_NAME');
      spriden_id      := twbcmain.f_get_parm('SPRIDEN_ID');
      sub_id          := twbcmain.f_get_parm('SUB_ID');

      fac_pref_tab := f_get_chnltoken(p_data_token, num_tok);
      idx := fac_pref_tab.FIRST;
      WHILE idx IS NOT NULL
      LOOP
         -- do something
         pref_name  := idx;
         pref_value := fac_pref_tab(idx);
         p_update_pref(channel_name, spriden_id,sub_id, pref_name, pref_value);
         idx := fac_pref_tab.NEXT(idx);
      END LOOP;
      --
      --  Check boxes if unchecked it does not pass values
      --  Handle it here
      --
      FOR c1_rec IN c1
      LOOP
         pref_name  := c1_rec.twgruprf_key;
         idx        := rtrim(fac_pref_tab.FIRST);
         checkfound := FALSE;
         WHILE idx IS NOT NULL
         LOOP
            IF idx = pref_name
            THEN
               checkfound := TRUE;
               EXIT;
            END IF;
            idx := fac_pref_tab.NEXT(idx);
         END LOOP;
         IF NOT checkfound
         THEN
            p_update_pref(channel_name, spriden_id,sub_id, pref_name, 'N');
         END IF;
      END LOOP;
      COMMIT;
      my_xml :=  twbcmain.f_chnl_default('EDIT');
      RETURN my_xml;
   END;

   -------------------------------------------------------------------
   FUNCTION f_get_pref_xml(p_data_token   IN VARCHAR2)
   RETURN VARCHAR2 IS
      c_pref                       pref_ref;
      my_xml                       VARCHAR2(32000);
      lv_xml                       CLOB;
      lv_working_xml               CLOB;
      buffer                       VARCHAR2(2000);

      lv_channel_name    twgrchnl.twgrchnl_name%type;
      lv_spriden_id      VARCHAR2(50);
      lv_sub_id          twgruprf.twgruprf_sub_id%type;
   BEGIN
      --
      --
      --
      lv_channel_name := twbcmain.f_get_parm('CHANNEL_NAME');
      lv_spriden_id := twbcmain.f_get_parm('SPRIDEN_ID');
      lv_sub_id := twbcmain.f_get_parm('SUB_ID');

      twbcmxml.p_init_xml(lv_xml);
      buffer := twbcmxml.f_header_xml;
      dbms_lob.WRITE(lv_xml, length(buffer), 1, buffer);
      c_pref := f_get_pref(lv_spriden_id, lv_channel_name );
      twbcmxml.p_get_xml(c_pref, lv_working_xml,  'PREF');
      twbcmxml.p_appendxml(lv_xml , lv_working_xml);

    -- I18N Fix

		buffer := '<TXT>';

		buffer := buffer || '<PREFERENCES_TXT>' || G$_NLS.Get('TWBCCOM1-0000','SQL','Preferences') || '</PREFERENCES_TXT>';

		buffer := buffer || '<LINKS_TXT>' || G$_NLS.Get('TWBCCOM1-0001','SQL','Links') || '</LINKS_TXT>';

		buffer := buffer || '<NUMBER_OF_ROWS_TXT>' || G$_NLS.Get('TWBCCOM1-0002','SQL','Number of Rows') || '</NUMBER_OF_ROWS_TXT>';

		buffer := buffer || '<ALPHABETICAL_SORT_TXT>' || G$_NLS.Get('TWBCCOM1-0003','SQL','Alphabetical Sort') || '</ALPHABETICAL_SORT_TXT>';

		buffer := buffer || '<A_TO_Z_TXT>' || G$_NLS.Get('TWBCCOM1-0004','SQL','A to Z') || '</A_TO_Z_TXT>';

		buffer := buffer || '<Z_TO_A_TXT>' || G$_NLS.Get('TWBCCOM1-0005','SQL','Z to A') || '</Z_TO_A_TXT>';

		buffer := buffer || '<SELF_SERVICE_TXT>' || G$_NLS.Get('TWBCCOM1-0006','SQL','Self-Service') || '</SELF_SERVICE_TXT>';

		buffer := buffer || '<INB_TXT>' || G$_NLS.Get('TWBCCOM1-0007','SQL','INB') || '</INB_TXT>';

		buffer := buffer || '<NUMBER_OF_DAYS_TXT>' || G$_NLS.Get('TWBCCOM1-0008','SQL','Number of Days') || '</NUMBER_OF_DAYS_TXT>';

		buffer := buffer || '<DISPLAY_TXT>' || G$_NLS.Get('TWBCCOM1-0009','SQL','Display') || '</DISPLAY_TXT>';

		buffer := buffer || '<ALL_RECORDS_TXT>' || G$_NLS.Get('TWBCCOM1-0010','SQL','All Records') || '</ALL_RECORDS_TXT>';

		buffer := buffer || '<TIME_ENTRY_ONLY_TXT>' || G$_NLS.Get('TWBCCOM1-0011','SQL','Time Entry/Leave Report') || '</TIME_ENTRY_ONLY_TXT>';

		buffer := buffer || '<BACK_TXT>' || G$_NLS.Get('TWBCCOM1-0012','SQL','Back') || '</BACK_TXT>';

		buffer := buffer || '<APPLY_TXT>' || G$_NLS.Get('TWBCCOM1-0013','SQL','Apply') || '</APPLY_TXT>';

		buffer := buffer || '<RESET_TXT>' || G$_NLS.Get('TWBCCOM1-0014','SQL','Reset') || '</RESET_TXT>';

		buffer := buffer || '</TXT>';

      buffer := buffer || twbcmxml.f_footer_xml;

	-- I18N Fix Ends

      dbms_lob.writeappend(lv_xml, length(buffer), buffer);
      twbcmxml.p_convertclob(lv_xml, my_xml);
      RETURN my_xml;
   END;

   --
   --
   --
   FUNCTION get_line_tok(p_string_in IN VARCHAR2) RETURN VARCHAR2 IS
      temp      VARCHAR2(1000);
      longueur  INTEGER;
      pos       INTEGER;
      car       CHAR(1);
      delimiter VARCHAR2(10);
   BEGIN
      delimiter := tok_line_delimiter;
      temp      := substr(p_string_in, length(delimiter) + 1);
      longueur  := length(temp);
      FOR counter IN 1 .. longueur
      LOOP
         car := substr(temp, counter, 1);
         pos := instr(delimiter, car);
         IF pos <> 0
         THEN
            RETURN(substr(temp, 1, counter - 1));
         END IF;
      END LOOP;
      RETURN(temp);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(NULL);
   END;

   --
   --
   ------------------------------------------------------------
   --
   --
   FUNCTION f_get_linetoken(p_token_in IN VARCHAR2) RETURN VARCHAR2 IS
      temp      VARCHAR2(1000);
      delimiter VARCHAR2(2000);
   BEGIN
      --
      --
      delimiter := tok_line_delimiter;
      --
      IF p_token_in IS NULL
      THEN
         RETURN(NULL);
      ELSE
         temp := get_line_tok(p_token_in);
         RETURN(temp);
      END IF;
   END;

   --
   --
   -----------------------------------------------------------------------------
   --
   --
   FUNCTION f_get_chnltoken(p_string_in IN VARCHAR2, p_num_tok OUT NUMBER)
      RETURN pref_tab IS
      delimiter     VARCHAR2(200);
      token_table   pref_tab;
      j             INTEGER := 0;
      prev_pos      NUMBER := 1;
      pos           NUMBER := 1;
      chnl_tokens   pref_tab;
      token_in      VARCHAR2(32000);
      tempstr       VARCHAR2(255);
      temppref_val  VARCHAR2(255);
      temppref_name VARCHAR2(255);
   BEGIN
      delimiter := tok_chnl_delimiter;
      token_in  := substr(p_string_in, length(delimiter) + 1);
      IF token_in IS NULL
      THEN
         RETURN token_table;
      END IF;
      WHILE instr(token_in, delimiter, pos) > 0
      LOOP
         pos     := instr(token_in, delimiter, prev_pos);
         tempstr := substr(token_in, prev_pos, pos - prev_pos);
         IF instr(tempstr, '=') > 0
         THEN
            temppref_val := substr(tempstr,
                                   instr(tempstr, '=') + 1,
                                   length(tempstr));
         END IF;
         temppref_name := substr(tempstr, 1, instr(tempstr, '=') - 1);
         IF temppref_name IS NOT NULL
         THEN
            chnl_tokens(temppref_name) := temppref_val;
         END IF;
         prev_pos := pos + length(delimiter);
         j        := j + 1;
      END LOOP;
      p_num_tok := j - 1;
      RETURN chnl_tokens;
   END;

   --
   -- This functions returns  data in XML format.
   FUNCTION f_get_chnl_list
   RETURN chnl_ref IS
      c_chnl chnl_ref;
   BEGIN
      OPEN c_chnl FOR
         SELECT distinct TWGRCHNL_TYPE "TYPE"
           FROM twgrchnl
          where twgrchnl_type is not null
          ORDER BY 1;
      RETURN c_chnl;
   END;
   --
   --
   --
   -- This functions returns  data in XML format.
   FUNCTION f_get_chnl(p_chnl_name IN VARCHAR2)
   RETURN chnl_ref IS
      c_chnl chnl_ref;
   BEGIN
      OPEN c_chnl FOR
         SELECT twgrchnl_name "NAME"
         FROM twgrchnl
         where twgrchnl_type = p_chnl_name
         ORDER BY 1;
      RETURN c_chnl;
   END;
   --
   --
   ------------------------------------------------------------
   --
   --
   FUNCTION f_get_chnl_xml(p_data_token   IN VARCHAR2)
   RETURN VARCHAR2 IS
      c_chnl                       chnl_ref;
      my_xml                       VARCHAR2(32000);
      lv_xml                       CLOB;
      lv_working_xml               CLOB;
      buffer                       VARCHAR2(2000);
      lv_chnl_name		   VARCHAR2(255);
      channel_name    twgrchnl.twgrchnl_name%type
                         := twbcmain.f_get_parm('CHANNEL_NAME');
      spriden_id      varchar2(50) := twbcmain.parm_table('SPRIDEN_ID');

   BEGIN
      --
      --
      --
      if instr(p_data_token,'chtype') > 0 then
         lv_chnl_name   := twbcmxml.f_get_token_parm_val('chtype',p_data_token);
      end if;
      twbcmxml.p_init_xml(lv_xml);
      buffer := twbcmxml.f_header_xml;
      dbms_lob.WRITE(lv_xml, length(buffer), 1, buffer);
      if lv_chnl_name is not null then
      	c_chnl := f_get_chnl(lv_chnl_name);
      else
      	c_chnl := f_get_chnl('N');
      end if;
      twbcmxml.p_get_xml(c_chnl, lv_working_xml,  'CHNL');
      twbcmxml.p_appendxml(lv_xml , lv_working_xml);
--
--
      c_chnl := f_get_chnl_list;
      twbcmxml.p_get_xml(c_chnl, lv_working_xml,  'CHNLTYPE');
      twbcmxml.p_appendxml(lv_xml , lv_working_xml);
--

	-- I18N Fix

		buffer := '<TXT>';

		buffer := buffer || '<CHANNEL_TYPE_TXT>' || G$_NLS.Get('TWBCCOM1-0015','SQL','Channel Type') || '</CHANNEL_TYPE_TXT>';

		buffer := buffer || '<SELECT_TXT>' || G$_NLS.Get('TWBCCOM1-0016','SQL','Select') || '</SELECT_TXT>';

		buffer := buffer || '<GO_TXT>' || G$_NLS.Get('TWBCCOM1-0017','SQL','Go') || '</GO_TXT>';

		buffer := buffer || '<NEW_CHANNEL_TXT>' || G$_NLS.Get('TWBCCOM1-0018','SQL','New Channel') || '</NEW_CHANNEL_TXT>';

		buffer := buffer || '<PREFERENCES_TXT>' || G$_NLS.Get('TWBCCOM1-0019','SQL','Preferences') || '</PREFERENCES_TXT>';

		buffer := buffer || '<INFORMATIONAL_TXT>' || G$_NLS.Get('TWBCCOM1-0020','SQL','Informational') || '</INFORMATIONAL_TXT>';

		buffer := buffer || '<NAVIGATIONAL_TXT>' || G$_NLS.Get('TWBCCOM1-0021','SQL','Navigational') || '</NAVIGATIONAL_TXT>';

		buffer := buffer || '</TXT>';

      buffer := buffer || twbcmxml.f_footer_xml;

    -- I18N Fix Ends

      dbms_lob.writeappend(lv_xml, length(buffer), buffer);
      twbcmxml.p_convertclob(lv_xml,my_xml);
      RETURN my_xml;
   END;


-----------------------------------------------
--
--
--
--

FUNCTION f_get_time (p_time	IN VARCHAR2)
RETURN VARCHAR2 IS
      lv_time VARCHAR2(30);
BEGIN
      lv_time :=  LTRIM (
                           TO_CHAR (
                              TO_DATE (
                                 p_time,
                                 'HH24MI'
                              ),
                              twbklibs.twgbwrul_rec.twgbwrul_time_fmt
                           ));
   RETURN lv_time;
END;

-----------------------------------------------
--
--
--
--
FUNCTION f_get_date (p_date	IN      DATE)
RETURN VARCHAR2 IS
	lv_date_disp   VARCHAR2(50);
BEGIN
      lv_date_disp := to_char(p_date,twbklibs.date_display_fmt);
	RETURN lv_date_disp;
END;
---------------------------------------------------------------
--
-- This function will test whether the preference setting is
-- either a baseline user or an individual user.
-- Returns either BASELINE or the actual spriden_id.
--
  FUNCTION f_get_pref_user(p_channel_name IN twgruprf.twgruprf_name%TYPE,
                            p_bannerid     IN spriden.spriden_id%TYPE,
                            p_group        IN twgruprf.twgruprf_group%TYPE,
                            p_key          IN twgruprf.twgruprf_key%TYPE)
      RETURN twgruprf.twgruprf_pref_user%TYPE IS
      return_value twgruprf.twgruprf_pref_user%TYPE;

      CURSOR c_pref(lv_channel_name IN twgruprf.twgruprf_name%TYPE,
           lv_bannerid         IN spriden.spriden_id%TYPE,
           lv_group             IN twgruprf.twgruprf_group%TYPE,
           lv_key                IN twgruprf.twgruprf_key%TYPE)
         IS
         SELECT twgruprf_pref_user "PREF_USER"
           FROM twgruprf
          WHERE (twgruprf_name = upper(lv_channel_name)) AND
                        twgruprf_pref_user = lv_bannerid AND
                        twgruprf_key = lv_key AND
                        twgruprf_group = lv_group
         UNION
         SELECT twgruprf_pref_user "PREF_USER"
           FROM twgruprf
          WHERE (twgruprf_name = upper(lv_channel_name) AND
                        twgruprf_pref_user = 'BASELINE' AND
                        twgruprf_group = lv_group AND
                twgruprf_key NOT IN
                (SELECT twgruprf_key
                    FROM twgruprf
                   WHERE twgruprf_name = upper(lv_channel_name) AND
                         twgruprf_pref_user = lv_bannerid));

   BEGIN

      OPEN c_pref(p_channel_name, p_bannerid, p_group, p_key);
      FETCH c_pref INTO return_value;
      CLOSE c_pref;

      RETURN return_value;

   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_get_pref_user;
---------------------------------------------------------------
   --
   -- Function to return twgrwprm values for channel use.
   -- This function resultant of the fact that there is
   -- no way to 'clear out' the twgrwprm table upon a luminis
   -- login or logout.  Therefore, old values could be used
   -- to drive the channels instead of preferences.
   --
   -- This function will only return twgrwprm values that
   -- are not older than 15 minutes ( const_twgrwprm_timeout ).
   --
   FUNCTION f_getparam(p_pidm    IN    twgrwprm.twgrwprm_pidm%TYPE,
                       p_name    IN    twgrwprm.twgrwprm_param_name%TYPE)
      RETURN VARCHAR2
   IS

      CURSOR getparam_c(
         p_pidm   twgrwprm.twgrwprm_pidm%TYPE,
         p_name   twgrwprm.twgrwprm_param_name%TYPE)
         RETURN twgrwprm%ROWTYPE
      IS
         SELECT *
           FROM twgrwprm
          WHERE twgrwprm_pidm = p_pidm
            AND twgrwprm_param_name = p_name
            AND TO_CHAR(twgrwprm_activity_date,'YYYYMMDD') = TO_CHAR(SYSDATE,'YYYYMMDD')
            AND TO_CHAR(twgrwprm_activity_date,'HH24MI') > (TO_CHAR(SYSDATE,'HH24MI') - const_twgrwprm_timeout);

      twgrwprm_rec   twgrwprm%ROWTYPE;
      return_value   twgrwprm.twgrwprm_param_value%TYPE;

   BEGIN

      OPEN getparam_c (p_pidm, p_name);
      FETCH getparam_c INTO twgrwprm_rec;

      IF getparam_c%NOTFOUND THEN
         twgrwprm_rec.twgrwprm_param_value := NULL;
      END IF;

      CLOSE getparam_c;
      RETURN twgrwprm_rec.twgrwprm_param_value;

   END f_getparam;

-------------------------------------------------------------
--
-- Similar to twbkfrmt.f_encodeurl.  This will replace
-- the values '&' and '<' in the string such that
-- the xml will render correctly.
--
   FUNCTION f_encodexml (string_in IN VARCHAR2)
      RETURN VARCHAR2 IS
      temp_url VARCHAR2 (32000) := string_in;
   BEGIN
      IF string_in IS NOT NULL THEN
         temp_url := REPLACE (temp_url, '&', '&amp;');
         temp_url := REPLACE (temp_url, '<', '&lt;');
      ELSE
         temp_url := NULL;
      END IF;

      RETURN temp_url;

   END f_encodexml;

---------------------------------------------------------------
-- Bottom
END TWBCCOMN;

