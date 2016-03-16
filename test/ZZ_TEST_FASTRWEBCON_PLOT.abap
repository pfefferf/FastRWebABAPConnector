"! Test FastRWebABAPConnector - simple plot creation and output via classical dynpro
"!
"! Copyright 2016 Florian Pfeffer
"!
"! Licensed under the Apache License, Version 2.0 (the "License");
"! you may not use this file except in compliance with the License.
"! You may obtain a copy of the License at
"!
"!    http://www.apache.org/licenses/LICENSE-2.0
"!
"! Unless required by applicable law or agreed to in writing, software
"! distributed under the License is distributed on an "AS IS" BASIS,
"! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"! See the License for the specific language governing permissions and
"! limitations under the License.
"!
REPORT zz_test_fastrwebcon_plot.

" ----------------------------------------------------------------------------------------------------------------------------------
" vars
DATA ok_code TYPE syucomm.
DATA go_cc_plot TYPE REF TO cl_gui_custom_container.
DATA gv_image TYPE xstring.

" ----------------------------------------------------------------------------------------------------------------------------------
" execute R script via FastRWeb Connector
DATA(lo_r_plot) = NEW zz_cl_fastrweb_connector( iv_result_type = zz_if_fastrweb_connector=>mc_result_type_image
                                                iv_destination = 'Z_RSERVE_FP'
                                                iv_rscript_path = '/R/plot' ).

DATA lt_result TYPE zz_if_fastrweb_connector=>mtt_key_value.
APPEND VALUE #( key = zz_if_fastrweb_connector=>mc_result_key value = REF #( gv_image ) ) TO lt_result.

TRY.
    lo_r_plot->execute_script( CHANGING ct_result = lt_result ).
  CATCH cx_t100_msg INTO DATA(lx_t100_msg).
    WRITE: / lx_t100_msg->get_text( ).
ENDTRY.

" ----------------------------------------------------------------------------------------------------------------------------------
" call screen to display created image on dynpro
CALL SCREEN 0100.

" ----------------------------------------------------------------------------------------------------------------------------------
" screen modules (quick and dirty)

MODULE set_status_0100 OUTPUT.
  SET PF-STATUS '0100'.
ENDMODULE.

MODULE set_image_0100 OUTPUT.
  TYPES: BEGIN OF lts_binary,
           line(255) TYPE x,
         END OF lts_binary.

  DATA lt_image TYPE TABLE OF lts_binary.

  IF NOT go_cc_plot IS INITIAL.
    RETURN.
  ENDIF.

  go_cc_plot = NEW cl_gui_custom_container( container_name = 'CC_PLOT' ).

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = gv_image
    TABLES
      binary_tab = lt_image.

  DATA lv_url(255) TYPE c.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type                 = 'IMAGE'   " MIME Type
      subtype              = 'PNG'
    TABLES
      data                 = lt_image
    CHANGING
      url                  = lv_url
    EXCEPTIONS
      dp_invalid_parameter = 1
      dp_error_put_table   = 2
      dp_error_general     = 3
      OTHERS               = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA(lo_picture) = NEW cl_gui_picture( parent = go_cc_plot ).

  lo_picture->load_picture_from_url(
    EXPORTING
      url    = lv_url
    EXCEPTIONS
      error  = 1
      OTHERS = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lo_picture->set_display_mode(
    EXPORTING
      display_mode = lo_picture->display_mode_normal
    EXCEPTIONS
      error        = 1
      OTHERS       = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMODULE.


MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

" ----------------------------------------------------------------------------------------------------------------------------------
" coding of R script "plot"
*run <- function(n=10) {
*   p <- WebPlot(800, 600)
*   n <- as.integer(n)
*   plot(rnorm(n), rnorm(n), col=2, pch=19)
*   p
*}