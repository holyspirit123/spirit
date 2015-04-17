create or replace 
PACKAGE twbcmxml AS
 
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
 