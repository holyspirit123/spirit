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
-- AUDIT TRAIL: 8.0
-- 1. A new function added to convert clob to varchar2. 
-- 
-- AUDIT TRAIL END

CREATE OR REPLACE PACKAGE twbcmxml AS

   --
   -- FILE NAME..: twbcmxml.sql
   -- RELEASE....: 8.0
   -- OBJECT NAME: TWBCMXML
   -- PRODUCT....: WTLWEB
   -- USAGE......: Main program for generating XML for channels.
   -- COPYRIGHT..: Copyright (C) SCT Corporation 2002. All rights reserved.
   --
   -- DESCRIPTION:
   --
   -- Main program for generating XML for channels.
   --
   -- DESCRIPTION END
   --
   --
   ---------------------------------------------------------------------------
   --
   --
   --
   PROCEDURE p_init_xml(p_result_out OUT CLOB);

   ---------------------------------------------------------------------------
   --
   --
   -- Main Procedure used to format a ref_cursor
   -- into an XML wrapped CLOB.
   --
   --PARAMETERS
   --
   -- p_cursor_ref        System ref cursor
   -- p_result_out        XML in CLOB format
   -- p_setlabel          Label with with this set needs to be identified in XML
   -- p_grouplabel        Label of the group
   --        
   --
   PROCEDURE p_get_xml(p_cursor_ref IN sys_refcursor,
                       p_result_out OUT CLOB,
                       p_setlabel   IN VARCHAR2 DEFAULT NULL,
                       p_grouplabel IN VARCHAR2 DEFAULT 'GROUP');

   ------------------------------------------------------------------------
   --
   --
   -- Main Procedure used to format a query
   -- into an XML wrapped CLOB.
   --
   --PARAMETERS
   --
   -- p_query             Query for which XML needs to be generated
   -- p_result_out        XML in CLOB format
   -- p_setlabel          Label with with this set needs to be identified in XML
   -- p_grouplabel        Label of the group     
   --
   PROCEDURE p_get_xml(p_query      IN VARCHAR2,
                       p_result_out OUT CLOB,
                       p_setlabel   IN VARCHAR2 DEFAULT NULL,
                       p_grouplabel IN VARCHAR2 DEFAULT 'GROUP');

   ---------------------------------------------------------------------------
   --
   --
   -- Procedure used for updating the 'final' clob
   -- with the XML formated CLOB returned from the result set.
   --
   --
   PROCEDURE p_appendxml(p_final_inout IN OUT CLOB, 
                         p_source IN OUT CLOB);

   --
   --
   -------------------------------------------------------------------------
   --
   --
   FUNCTION f_header_xml RETURN VARCHAR2;

   -------------------------------------------------------------------------
   --
   --
   FUNCTION f_footer_xml RETURN VARCHAR2;

   -------------------------------------------------------------------------
   --
   --
   FUNCTION f_error_message(p_message IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   ------------------------------------------------------------------------
   --
   --
   FUNCTION f_message_xml(p_message IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

   ------------------------------------------------------------------------
   --
   --
   --
   PROCEDURE p_printclob(p_result IN CLOB);
--
   PROCEDURE p_convertclob(p_result IN CLOB,my_xml OUT VARCHAR2);

   --
   --
   -- 
   PROCEDURE p_altprintclob(result_clob IN CLOB);

   --
   --
   --
   PROCEDURE p_printstring(result_string IN VARCHAR2);

   --
   --
   --
   PROCEDURE p_altprintstr(result_str IN VARCHAR2);

   --
   --
   --
   FUNCTION f_get_token_parm_val(param_name_in IN VARCHAR2,
                                 token_in      IN VARCHAR2) RETURN VARCHAR2;

   --
   --
   --
   FUNCTION f_decode_name_token(param_name_in IN VARCHAR2,
                                token_in      IN VARCHAR2) RETURN VARCHAR2;

   --
   --
   --
   FUNCTION f_param_in_token_string(param_value_in IN VARCHAR2,
                                    token_in       IN VARCHAR2) RETURN BOOLEAN;

-----------------------------------------------------------------------
-- BOTTOM
--
END twbcmxml;
/
show errors 
SET scan ON 
whenever sqlerror continue; 
drop public synonym twbcmxml; 
whenever sqlerror EXIT ROLLBACK; 
CREATE public synonym twbcmxml FOR twbcmxml; 
rem ** * beginning OF gurmdbp mods ** * 
whenever sqlerror continue 
START gurgrtw twbcmxml 
rem ** *END OF gurmdbp mods ** *
