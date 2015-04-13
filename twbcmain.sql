SET SCAN OFF

-- AUDIT TRAIL: 7.3
-- 1. rk  03/27/2004
--    Additional parameters added in main_xml for vpd code and locale
-- AUDIT TRAIL: 7.1
-- 1. rk  03/27/2004
--    Chnaged grants from start gurgrtw to grant execute to baninst1 
-- AUDIT TRAIL: 7.0
-- 1. rk  03/07/2004
--    Package created.
--
-- AUDIT TRAIL: NLS_DATE_SUPPORT 
-- 1. TGKinderman   11/11/2005
--    This object was passed through a conversion process relative to preparing
--    the object to support internationalization needs.  Basically, hard coded
--    date format masks of DD-MON-YYYY are converted to a G$_DATE function that
--    returns nls_date_format.  The release number of this object was NOT
--    modified as part of this effort.  This object may or may not have had 
--    conversion process code modifications.  However, this audit trail entry
--    does indicate that the object has been passed through the conversion.
-- AUDIT TRAIL END

CREATE OR REPLACE PACKAGE twbcmain 
AS
   --
   -- FILE NAME..: TWBCMAIN.SQL
   -- RELEASE....: 7.3
   -- OBJECT NAME: TWBCMAIN
   -- PRODUCT....: WTLWEB
   -- USAGE......: Main program for channels.
   -- COPYRIGHT..: Copyright (C) SCT Corporation 2002. All rights reserved.
   --
   -- DESCRIPTION:
   --
   -- This is a description of what this object does.
   --
   -- DESCRIPTION END
   --
   -- Type
   --
   -- Main table which will store instance variable for channels
   --
   TYPE ch_main_parm IS TABLE OF VARCHAR2(500) 
                  INDEX BY VARCHAR2(255);
   parm_table ch_main_parm;

   -- Functions
   --
   -----------------------------------------------------------------
   --
   -- This funtion returns parameter value
   --
   -- Parameters:
   -- p_name : Value is fetched from parameter table for this 
   --
   --
   FUNCTION f_get_parm(p_name IN VARCHAR2) RETURN VARCHAR2;

   ------------------------------------------------------------------
   --
   -- This is the main function called from Java Luminis class. 
   -- This will return XML to Luminis. 
   -- This function is point of entry for Luminis Java Class for Banner 
   -- Channels.
   --
   -- Parameters:
   -- p_channel_name : Channel infosource name passed in from Luminis
   -- p_spriden_id   : Self Service Id being passed in 
   -- p_luminis_id   : This is Luminis_id of the person logging in
   -- p_data_token   : Channel context stored in a token format. 
   --                  Format for this token is 
   --                  ::parm_name=parm_value::parm_name=Parm_value::
   -- p_channel_mode : This defines what view that channel will be shown in.
   -- p_focus        : This shows whether channel is in focus mode or 
   --                 in a normal mode 
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
                       ) RETURN VARCHAR2;

   --
   ------------------------------------------------------------------
   --
   --
   --
   -- This function will display current channel in a different mode.
   --
   -- Parameters:
   -- p_def_mode : Mode in which this channel should be rendeered
   --
   FUNCTION f_chnl_default(p_def_mode IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

END twbcmain;
/
show errors 
SET scan ON 
whenever sqlerror continue; 
drop public synonym twbcmain; 
whenever sqlerror EXIT ROLLBACK; 
CREATE public synonym twbcmain FOR twbcmain; 
rem ** * beginning OF gurmdbp mods ** * 
whenever sqlerror continue 
--start gurgrtw twbcmain;
grant execute on twbcmain to baninst1;
whenever sqlerror EXIT ROLLBACK 
rem ** *END OF gurmdbp mods ** *
