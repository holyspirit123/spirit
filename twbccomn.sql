-- AUDIT TRAIL: 7.1
-- 1. rk  04/07/2004
--    Whenever sqlerror continue addded in this script.
-- AUDIT TRAIL: 7.0
-- 1. rk  03/07/2004
--    Package created.
--
-- AUDIT TRAIL END

CREATE OR REPLACE PACKAGE TWBCCOMN AS

   --
   -- FILE NAME..: twbccomn.sql
   -- RELEASE....: 7.1
   -- OBJECT NAME: TWBCCOMN
   -- PRODUCT....: WTLWEB
   -- USAGE......: common functions/procedures for channels.
   -- COPYRIGHT..: Copyright (C) SCT Corporation 2003. All rights reserved.
   --
   -- DESCRIPTION:
   --
   -- Common methods for channels. 
   --
   -- DESCRIPTION END
   --
   -- Constants
   --
   const_twgrwprm_timeout        CONSTANT NUMBER := 10;
   --
   -- Types
   --
   tok_line_delimiter VARCHAR2(10) := '=';

   tok_chnl_delimiter VARCHAR2(10) := '::';

   TYPE tab_tokens IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

   TYPE pref_tab IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(255);

------------------------------------------------------------------------
-- Entity record types:
--
--
--
   TYPE pref_rec IS RECORD(
      r_group      twgruprf.twgruprf_group%TYPE,
      r_key        twgruprf.twgruprf_key%TYPE,
      r_string     twgruprf.twgruprf_desc%TYPE,
      r_value      twgruprf.twgruprf_value%TYPE,
      r_edit       twgruprf.twgruprf_edit_ind%TYPE,
      r_sort_order twgruprf.twgruprf_sort_order%TYPE);

   TYPE pref_ref IS REF CURSOR RETURN pref_rec;

   TYPE chnl_rec IS RECORD(
      r_name      twgrchnl.twgrchnl_name%TYPE
			  );

   TYPE chnl_ref IS REF CURSOR RETURN chnl_rec;
---------------------------------------------------------------
--
--
--
--
   FUNCTION f_get_chnltoken(p_string_in          IN         VARCHAR2, 
                            p_num_tok            OUT        NUMBER
                            )
   RETURN pref_tab;
---------------------------------------------------------------
--
--
--
--
   FUNCTION f_get_linetoken(p_token_in IN VARCHAR2) 
   RETURN VARCHAR2;
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
      RETURN twgruprf.twgruprf_pref_user%TYPE;
---------------------------------------------------------------
--
--
--
   FUNCTION f_get_pref(p_bannerid               IN VARCHAR2, 
                       p_channel_name           IN VARCHAR2)
   RETURN pref_ref;
-------------------------------------------------------------
   FUNCTION f_set_pref_xml( p_data_token   IN VARCHAR2 )
   RETURN VARCHAR2;
------------------------------------------------------------
   FUNCTION f_del_pref_xml( p_data_token   IN VARCHAR2 )
   RETURN VARCHAR2;
------------------------------------------------------------
   FUNCTION f_get_about ( p_data_token   IN VARCHAR2 ) 
   RETURN VARCHAR2;

------------------------------------------------------------
   FUNCTION f_get_help ( p_data_token   IN VARCHAR2  ) 
   RETURN VARCHAR2;

----------------------------------------------------------
   FUNCTION f_get_pref_xml ( p_data_token   IN VARCHAR2 )
   RETURN VARCHAR2;
----------------------------------------------------------
   FUNCTION f_get_chnl_xml ( p_data_token   IN VARCHAR2 )
   RETURN VARCHAR2;

----------------------------------------------------------
   FUNCTION f_get_time (p_time	IN VARCHAR2)
   RETURN VARCHAR2;
----------------------------------------------------------
   FUNCTION f_get_date (p_date	IN      DATE)
   RETURN VARCHAR2;
----------------------------------------------------------
--
-- 
--
   FUNCTION f_getparam(p_pidm    IN    twgrwprm.twgrwprm_pidm%TYPE,
                       p_name    IN    twgrwprm.twgrwprm_param_name%TYPE)
   RETURN VARCHAR2;

----------------------------------------------------------
--
-- Similar to twbkfrmt.f_encodeurl.  This will replace
-- the values '&' and '<' in the string such that 
-- the xml will render correctly.
--  
   FUNCTION f_encodexml (string_in IN VARCHAR2)
      RETURN VARCHAR2; 

----------------------------------------------------------
-- BOTTOM
END TWBCCOMN;
/
show errors 
SET scan ON 
whenever sqlerror continue; 
drop public synonym TWBCCOMN; 
whenever sqlerror EXIT ROLLBACK; 
CREATE public synonym TWBCCOMN FOR TWBCCOMN; 
whenever sqlerror continue; 
start gurgrtw TWBCCOMN
WHENEVER SQLERROR EXIT ROLLBACK
REM *** END OF GURMDBP MODS ***
set scan on
