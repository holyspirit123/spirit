--
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
-- 1.  Added a new procedure p_convertclob to replace dbms_lob.substr
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE BODY TWBCMXML AS
   --
   -- FILE NAME..: twbcmxm1.sql
   -- RELEASE....: 8.0
   -- OBJECT NAME: TWBCMXML
   -- PRODUCT....: CHANNELS 
   -- USAGE......: Main helper program for generating XML for channels.
   -- COPYRIGHT..: Copyright (C) SCT Corporation 2002. All rights reserved.
   --
   -- DESCRIPTION:
   --
   -- This is a description of what this object does.
   --
   -- DESCRIPTION END
   --
   --
   --------------------------------------------------------------------------
   --
   --

   PROCEDURE p_init_xml(p_result_out  OUT CLOB) IS
   BEGIN
      dbms_lob.createtemporary(p_result_out, TRUE, dbms_lob.session);
   END p_init_xml;

   ---
   --
------------------------------------------------------------------------ 
   --
   -- Main Procedure used to format a ref_cursor
   -- into an XML CLOB.
   --
   --
   --
   PROCEDURE p_get_xml    (p_cursor_ref    IN sys_refcursor,
                           p_result_out OUT CLOB,
                           p_setlabel   IN VARCHAR2 DEFAULT NULL,
                           p_grouplabel IN VARCHAR2 DEFAULT 'GROUP') IS
      queryctx    dbms_xmlgen.ctxtype;
   BEGIN
   
      queryctx := dbms_xmlgen.newcontext(p_cursor_ref);
   
      IF p_setlabel IS NOT NULL THEN
         dbms_xmlgen.setrowsettag(queryctx,upper(p_setlabel));
      ELSE
         dbms_xmlgen.setrowsettag(queryctx, NULL);
      END IF;
   
      IF p_grouplabel IS NOT NULL THEN
         dbms_xmlgen.setrowtag(queryctx,upper(p_grouplabel));
      ELSE
         dbms_xmlgen.setrowtag(queryctx, NULL);
      END IF;
   
      p_result_out := dbms_xmlgen.getxml(queryctx);
      dbms_xmlgen.closecontext(queryctx);
   END p_get_xml;

   --------------------------------------------------------------------

   PROCEDURE p_get_xml    (p_query      IN VARCHAR2,
                           p_result_out OUT CLOB,
                           p_setlabel   IN VARCHAR2 DEFAULT NULL,
                           p_grouplabel IN VARCHAR2 DEFAULT 'GROUP') IS
   
      queryctx    dbms_xmlquery.ctxtype;
      result      CLOB;
   
   BEGIN
   
      queryctx := dbms_xmlquery.newcontext(p_query);
      IF p_setlabel IS NOT NULL THEN
         dbms_xmlquery.setrowsettag(queryctx, upper(p_setlabel));
      ELSE
         dbms_xmlquery.setrowsettag(queryctx, NULL);
      END IF;
   
      IF p_grouplabel IS NOT NULL THEN
         dbms_xmlquery.setrowtag(queryctx, upper(p_grouplabel));
      ELSE
         dbms_xmlquery.setrowtag(queryctx, NULL);
      END IF;
   
      p_result_out := dbms_xmlquery.getxml(queryctx);
      dbms_xmlquery.closecontext(queryctx);
   
   END p_get_xml;
   ----------------------------------------------------------------------
     PROCEDURE p_convertclob(p_result IN CLOB,my_xml OUT VARCHAR2)
     IS
       tot_len   NUMBER;
     BEGIN
         tot_len := dbms_lob.getlength(p_result);
         DBMS_LOB.READ(p_result,tot_len, 1, my_xml);
     EXCEPTION
     WHEN OTHERS THEN
       NULL;
     END;


   ----------------------------------------------------------------------
   --
   -- Procedure used for updating the 'final' clob
   -- with the XML formated CLOB returned from the
   -- result set.
   --


   PROCEDURE p_appendxml    (p_final_inout IN OUT CLOB, 
                             p_source IN OUT CLOB) IS
   clob_length NUMBER;
   wrk_int     INTEGER;
   grtr_than   VARCHAR2(1) DEFAULT '>';
   my_data     VARCHAR2(32500);
   tot_len     NUMBEr;

   BEGIN
   
      clob_length := dbms_lob.getlength(p_source);


      IF clob_length > 1 THEN
         wrk_int := dbms_lob.instr(p_source, '>', 1, 1);
         tot_len := dbms_lob.getlength(p_source);
         DBMS_LOB.READ(p_source,tot_len, 1, my_data);
         my_data := substr(my_data, wrk_int, clob_length);
         dbms_lob.writeappend(p_final_inout ,length(my_data),my_data);
         dbms_lob.erase(p_source, clob_length, 1);
         dbms_lob.freetemporary(p_source);
      END If;

   END p_appendxml;

   ---------------------------------------------------------------
   --
   -- Function to create header XML tag
   --
   --

   FUNCTION f_header_xml RETURN VARCHAR2 IS
      my_xml VARCHAR2(2000);
   BEGIN
      --
      --
      my_xml := '<CHANNELDATA>';
      RETURN my_xml;
   END f_header_xml;
   --
   --
   --------------------------------------------------------------------
   --
   --

   FUNCTION f_footer_xml RETURN VARCHAR2 IS
   BEGIN
      RETURN '</CHANNELDATA>';
   END f_footer_xml;
   -------------------------------------------------------------------
   --
   --
   --
   --


   FUNCTION f_error_message(p_message IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2 IS
      my_xml VARCHAR2(2000);
   BEGIN
      my_xml := f_header_xml || f_message_xml(p_message) || f_footer_xml;
      RETURN my_xml;
   END f_error_message;
   ------------------------------------------------------------------
   --
   --
   --
   
   FUNCTION f_message_xml(p_message IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      my_xml VARCHAR2(10000);
   BEGIN
      my_xml := '<MESSAGE>';
      my_xml := my_xml || '<TEXT>';
      my_xml := my_xml || p_message;
      my_xml := my_xml || '</TEXT>';
      my_xml := my_xml || '</MESSAGE>';
   
      RETURN my_xml;
   END f_message_xml;

   ------------------------------------------------------------------ 
   --
   --
   --
   PROCEDURE p_printclob(p_result IN CLOB) IS
   
      result          CLOB;
      cvl_tmp         VARCHAR2(32000);
      nvl_amount      NUMBER := 255; --32000;
      nvl_pos         NUMBER := 1;
      nvl_clob_length NUMBER;
      instr_pos       NUMBER;
   
      c_length NUMBER;
   
   BEGIN
   
      result          := p_result;
      nvl_clob_length := dbms_lob.getlength(result);
      cvl_tmp         := NULL;
      c_length        := nvl_clob_length;
      nvl_amount      := 255; --32000;
      nvl_pos         := 1;
   
      LOOP
         instr_pos := nvl(dbms_lob.instr(result, chr(10), nvl_pos, 1),
                          c_length) - nvl_pos;
         --
         -- Debug Code
         --
         -- DBMS_OUTPUT.PUT_LINE(nvl_pos||': Of length : '||instr_pos);

         IF nvl_pos + instr_pos = 0 THEN
            instr_pos := nvl_clob_length - nvl_pos;
         
            dbms_lob.READ(lob_loc => result,
                          amount  => instr_pos,
                          offset  => nvl_pos,
                          buffer  => cvl_tmp);
            dbms_output.put_line(cvl_tmp);
            EXIT;
         END IF;
      
         dbms_lob.READ(lob_loc => result,
                       amount  => instr_pos,
                       offset  => nvl_pos,
                       buffer  => cvl_tmp);
         --
         --
         dbms_output.put_line(cvl_tmp);
         --
         --
         nvl_pos := nvl_pos + instr_pos + 1;
      
         IF nvl_pos > nvl_clob_length THEN
            EXIT;
         END IF;
      END LOOP;
   
   END p_printclob;

   ------------------------------------------------------------------------ 
   --
   -- Alternate print procedure.  At times, there is a problem with 
   -- the above procedure depending upon how the 
   -- last ( closing ) XML tag is entered/saved in your
   -- business logic procedure.
   --
   -- Currently, if your tag contains a space between closing bracket and
   -- closing quote ( '</tag> ' ) - the p_printclob procedure works.
   --
   -- If there is no space ( ( '</tag>' ) - the procedure is failing.
   -- Will need to review this issue at a later date.
   --
   -- In short, if P_PRINTCLOB fails for you, try this procedure
   -- when debugging.
   --
   PROCEDURE p_altprintclob(result_clob IN CLOB) IS
   BEGIN
      IF length(result_clob) > 200 THEN
         dbms_output.put_line(substr(result_clob, 1, 200));
         p_printclob(substr(result_clob, 201, length(result_clob)));
      ELSE
         dbms_output.put_line(result_clob);
      END IF;
   
   END p_altprintclob;

   -------------------------------------------------------------------- 

   PROCEDURE p_printstring(result_string IN VARCHAR2) IS
   
      result          CLOB;
      cvl_tmp         VARCHAR2(32000);
      nvl_amount      NUMBER := 255; --32000;
      nvl_pos         NUMBER := 1;
      nvl_clob_length NUMBER;
      instr_pos       NUMBER;
   
      c_length NUMBER;
   
   BEGIN
   
      result          := result_string;
      nvl_clob_length := dbms_lob.getlength(result);
      cvl_tmp         := NULL;
      c_length        := nvl_clob_length;
      nvl_amount      := 255; --32000;
      nvl_pos         := 1;
   
      LOOP
         instr_pos := nvl(dbms_lob.instr(result, chr(10), nvl_pos, 1),
                          c_length) - nvl_pos;
         IF nvl_pos + instr_pos = 0 THEN
            instr_pos := nvl_clob_length - nvl_pos;
         
            dbms_lob.READ(lob_loc => result,
                          amount  => instr_pos,
                          offset  => nvl_pos,
                          buffer  => cvl_tmp);
            dbms_output.put_line(cvl_tmp);
            EXIT;
         END IF;
      
         dbms_lob.READ(lob_loc => result,
                       amount  => instr_pos,
                       offset  => nvl_pos,
                       buffer  => cvl_tmp);
         --
         --
         dbms_output.put_line(cvl_tmp);
         --
         --
         nvl_pos := nvl_pos + instr_pos + 1;
      
         IF nvl_pos > nvl_clob_length THEN
            EXIT;
         END IF;
      END LOOP;
   
   END p_printstring;

   ------------------------------------------------------------------------- 
   --
   --
   --
   PROCEDURE p_altprintstr(result_str IN VARCHAR2) IS
   BEGIN
      dbms_output.enable(99999);
      IF length(result_str) > 200 THEN
         dbms_output.put_line(substr(result_str, 1, 200));
         p_altprintstr(substr(result_str, 201, length(result_str)));
      ELSE
         dbms_output.put_line(result_str);
      END IF;

   END p_altprintstr;

   --------------------------------------------------------------------

   FUNCTION f_get_token_parm_val(param_name_in IN VARCHAR2,
                                 token_in      IN VARCHAR2) 
   RETURN VARCHAR2 IS
   
      pos      INTEGER := 3;
      prev_pos INTEGER := 3;
      TYPE xml_tabtype IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
      token_table  xml_tabtype;
      j            INTEGER := 1;
      l            INTEGER := 0;
      return_value VARCHAR2(90);
      parm         VARCHAR2(100);
   BEGIN
      WHILE instr(token_in, '::', pos) > 0 LOOP
         pos := instr(token_in, '::', prev_pos);
         token_table(j) := substr(token_in, prev_pos, pos - prev_pos);
         prev_pos := pos + 2;
         j := j + 1;
      END LOOP;
      j := j - 1;
   
      FOR z IN 1 .. j LOOP
         l    := instr(token_table(z), '=');
         parm := substr(token_table(z), 1, l - 1);
      
         IF upper(param_name_in) = upper(parm) THEN
            return_value := substr(token_table(z),
                                   l + 1,
                                   length(token_table(z)));
         END IF;
      
         -- dbms_output.put_line('l              =>' || l);
         -- dbms_output.put_line('token_table z  =>' || token_table(z));
         -- dbms_output.put_line('parm           =>' || parm);
      END LOOP;
   
      RETURN return_value;
   
   END f_get_token_parm_val;

   -------------------------------------------------------------------- 

   FUNCTION f_decode_name_token(param_name_in IN VARCHAR2,
                                token_in      IN VARCHAR2) 
   RETURN VARCHAR2 IS
   
      return_value VARCHAR2(90);
      r_pos        INTEGER;
      l_pos        INTEGER;
   
   BEGIN
   
      -- dbms_output.put_line('parm ' || param_name_in);
      -- dbms_output.put_line('toke ' || token_in);
   
      CASE
         WHEN param_name_in = 'LAST' THEN
            r_pos := instr(token_in, ',', 1);
         
            IF r_pos = 0 THEN
               return_value := substr(token_in, 1, length(token_in));
            ELSE
               return_value := substr(token_in, 1, r_pos - 1);
            END IF;
         
         WHEN param_name_in = 'FIRST' THEN
            l_pos := instr(token_in, ',', 1);
            r_pos := instr(token_in, ',', 1, 2) - 1;
         
            IF l_pos <> 0 THEN
               IF r_pos = -1 THEN
                  return_value := substr(token_in,
                                         l_pos + 1,
                                         (length(token_in) - l_pos));
               ELSE
                  return_value := substr(token_in, l_pos + 1, r_pos - l_pos);
               END IF;
            END IF;
         
         WHEN param_name_in = 'MI' THEN
            l_pos := instr(token_in, ',', 1, 2);
         
            IF l_pos = 0 THEN
               return_value := NULL;
            ELSE
               return_value := substr(token_in,
                                      l_pos + 1,
                                      (length(token_in) - l_pos));
            END IF;
      END CASE;
      RETURN return_value;
   END f_decode_name_token;

   ---------------------------------------------------------------- 
   --
   --
   -- This function came about for the the my prospects
   -- channel.  This channel has three 'buttons' that are
   -- actually images.
   -- ( <INPUT TYPE="IMAGE">
   --
   -- This input type ends up sending in the image 'name'
   -- and not a value - Therefore, we have to test
   -- the string to see what button was pressed.
   --
   FUNCTION f_param_in_token_string(param_value_in IN VARCHAR2,
                                    token_in       IN VARCHAR2) 
   RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      str_pos      INTEGER;
   BEGIN
   
      str_pos := 1;
   
      str_pos := instr(token_in, param_value_in, 1);
      --  
      -- INSTR returns 0 if string is not found.
      --
      IF str_pos = 0 THEN
         return_value := FALSE;
      ELSE
         return_value := TRUE;
      END IF;
 
      RETURN return_value;
 
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
 
   END f_param_in_token_string;

-------------------------------------------------------------------------- 

END TWBCMXML;
/
show errors
