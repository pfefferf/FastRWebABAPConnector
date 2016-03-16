"! Test FastRWebABAPConnector - kMeans clustering with customer demo data
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
REPORT zz_test_fastrwebcon_kmeans.

" ----------------------------------------------------------------------------------------------------------------------------------
" test data preparation
TYPES: BEGIN OF lts_settings,
         centers TYPE i,
       END OF lts_settings.

TYPES: BEGIN OF lts_customer,
         id        TYPE int4,
         lifespend TYPE dec10_2,
         newspend  TYPE dec10_2,
         income    TYPE dec10_2,
         loyalty   TYPE dec10_2,
       END OF lts_customer,
       ltt_customer TYPE STANDARD TABLE OF lts_customer WITH DEFAULT KEY.

TYPES: BEGIN OF lts_cluster,
         id      TYPE int4,
         cluster TYPE int4,
       END OF lts_cluster,
       ltt_cluster TYPE STANDARD TABLE OF lts_cluster WITH DEFAULT KEY.

DATA(lt_customer) = VALUE ltt_customer(
  ( id = 1 lifespend = '7.2' newspend = '3.6' income = '6.1' loyalty = '2.5' )
  ( id = 2 lifespend = '5.4' newspend = '3.4' income = '1.5' loyalty = '0.4' )
  ( id = 3 lifespend = '6.9' newspend = '3.2' income = '5.7' loyalty = '2.3' )
  ( id = 4 lifespend = '5.5' newspend = '2.3' income = '4' loyalty = '1.3' )
  ( id = 5 lifespend = '6.1' newspend = '2.9' income = '4.7' loyalty = '1.4' )
  ( id = 6 lifespend = '5' newspend = '3.3' income = '1.4' loyalty = '0.2' )
  ( id = 7 lifespend = '5.8' newspend = '2.7' income = '5.1' loyalty = '1.9' )
  ( id = 8 lifespend = '5.1' newspend = '3.4' income = '1.5' loyalty = '0.2' )
  ( id = 9 lifespend = '6.4' newspend = '3.2' income = '5.3' loyalty = '2.3' )
  ( id = 10 lifespend = '5.7' newspend = '2.8' income = '4.5' loyalty = '1.3' )
  ( id = 11 lifespend = '6.8' newspend = '3' income = '5.5' loyalty = '2.1' )
  ( id = 12 lifespend = '4.3' newspend = '3' income = '1.1' loyalty = '0.1' )
  ( id = 13 lifespend = '7' newspend = '3.2' income = '4.7' loyalty = '1.4' )
  ( id = 14 lifespend = '5.4' newspend = '3.4' income = '1.7' loyalty = '0.2' )
  ( id = 15 lifespend = '5.4' newspend = '3' income = '4.5' loyalty = '1.5' )
  ( id = 16 lifespend = '5.7' newspend = '2.9' income = '4.2' loyalty = '1.3' )
  ( id = 17 lifespend = '6.3' newspend = '2.9' income = '5.6' loyalty = '1.8' )
  ( id = 18 lifespend = '5.1' newspend = '3.7' income = '1.5' loyalty = '0.4' )
  ( id = 19 lifespend = '6.3' newspend = '2.8' income = '5.1' loyalty = '1.5' )
  ( id = 20 lifespend = '5.6' newspend = '2.5' income = '3.9' loyalty = '1.1' )
  ( id = 21 lifespend = '5.7' newspend = '2.6' income = '3.5' loyalty = '1' )
  ( id = 22 lifespend = '5.4' newspend = '3.9' income = '1.3' loyalty = '0.4' )
  ( id = 23 lifespend = '6' newspend = '3' income = '4.8' loyalty = '1.8' )
  ( id = 24 lifespend = '5.5' newspend = '2.6' income = '4.4' loyalty = '1.2' )
  ( id = 25 lifespend = '4.7' newspend = '3.2' income = '1.3' loyalty = '0.2' )
  ( id = 26 lifespend = '6.8' newspend = '2.8' income = '4.8' loyalty = '1.4' )
  ( id = 27 lifespend = '5.9' newspend = '3' income = '4.2' loyalty = '1.5' )
  ( id = 28 lifespend = '5.1' newspend = '3.8' income = '1.9' loyalty = '0.4' )
  ( id = 29 lifespend = '5' newspend = '3.5' income = '1.3' loyalty = '0.3' )
  ( id = 30 lifespend = '5.8' newspend = '4' income = '1.2' loyalty = '0.2' )
  ( id = 31 lifespend = '7.7' newspend = '2.8' income = '6.7' loyalty = '2' )
  ( id = 32 lifespend = '5.2' newspend = '2.7' income = '3.9' loyalty = '1.4' )
  ( id = 33 lifespend = '4.4' newspend = '2.9' income = '1.4' loyalty = '0.2' )
  ( id = 34 lifespend = '5' newspend = '3' income = '1.6' loyalty = '0.2' )
  ( id = 35 lifespend = '7.6' newspend = '3' income = '6.6' loyalty = '2.1' )
  ( id = 36 lifespend = '5.1' newspend = '3.5' income = '1.4' loyalty = '0.3' )
  ( id = 37 lifespend = '6' newspend = '3.4' income = '4.5' loyalty = '1.6' )
  ( id = 38 lifespend = '5.7' newspend = '3.8' income = '1.7' loyalty = '0.3' )
  ( id = 39 lifespend = '6.2' newspend = '3.4' income = '5.4' loyalty = '2.3' )
  ( id = 40 lifespend = '7.3' newspend = '2.9' income = '6.3' loyalty = '1.8' )
  ( id = 41 lifespend = '5.7' newspend = '2.5' income = '5' loyalty = '2' )
  ( id = 42 lifespend = '6.7' newspend = '3.1' income = '5.6' loyalty = '2.4' )
  ( id = 43 lifespend = '6.1' newspend = '2.8' income = '4.7' loyalty = '1.2' )
  ( id = 44 lifespend = '5.7' newspend = '4.4' income = '1.5' loyalty = '0.4' )
  ( id = 45 lifespend = '5.6' newspend = '2.7' income = '4.2' loyalty = '1.3' )
  ( id = 46 lifespend = '5.5' newspend = '4.2' income = '1.4' loyalty = '0.2' )
  ( id = 47 lifespend = '6.3' newspend = '3.4' income = '5.6' loyalty = '2.4' )
  ( id = 48 lifespend = '6.7' newspend = '3.1' income = '4.7' loyalty = '1.5' )
  ( id = 49 lifespend = '6.3' newspend = '3.3' income = '6' loyalty = '2.5' )
  ( id = 50 lifespend = '6.3' newspend = '2.3' income = '4.4' loyalty = '1.3' )
  ( id = 51 lifespend = '6' newspend = '2.2' income = '5' loyalty = '1.5' )
  ( id = 52 lifespend = '6.4' newspend = '2.8' income = '5.6' loyalty = '2.2' )
  ( id = 53 lifespend = '6.3' newspend = '2.7' income = '4.9' loyalty = '1.8' )
  ( id = 54 lifespend = '6.2' newspend = '2.2' income = '4.5' loyalty = '1.5' )
  ( id = 55 lifespend = '6.3' newspend = '2.5' income = '4.9' loyalty = '1.5' )
  ( id = 56 lifespend = '5.5' newspend = '2.5' income = '4' loyalty = '1.3' )
  ( id = 57 lifespend = '6.9' newspend = '3.1' income = '4.9' loyalty = '1.5' )
  ( id = 58 lifespend = '4.6' newspend = '3.1' income = '1.5' loyalty = '0.2' )
  ( id = 59 lifespend = '5.6' newspend = '2.8' income = '4.9' loyalty = '2' )
  ( id = 60 lifespend = '6.4' newspend = '2.8' income = '5.6' loyalty = '2.1' )
  ( id = 61 lifespend = '4.8' newspend = '3.4' income = '1.6' loyalty = '0.2' )
  ( id = 62 lifespend = '5.7' newspend = '3' income = '4.2' loyalty = '1.2' )
  ( id = 63 lifespend = '5' newspend = '2.3' income = '3.3' loyalty = '1' )
  ( id = 64 lifespend = '6.1' newspend = '2.6' income = '5.6' loyalty = '1.4' )
  ( id = 65 lifespend = '5.4' newspend = '3.7' income = '1.5' loyalty = '0.2' )
  ( id = 66 lifespend = '6.4' newspend = '2.9' income = '4.3' loyalty = '1.3' )
  ( id = 67 lifespend = '5.5' newspend = '3.5' income = '1.3' loyalty = '0.2' )
  ( id = 68 lifespend = '7.2' newspend = '3' income = '5.8' loyalty = '1.6' )
  ( id = 69 lifespend = '6.5' newspend = '3' income = '5.2' loyalty = '2' )
  ( id = 70 lifespend = '5.5' newspend = '2.4' income = '3.8' loyalty = '1.1' )
  ( id = 71 lifespend = '4.7' newspend = '3.2' income = '1.6' loyalty = '0.2' )
  ( id = 72 lifespend = '6' newspend = '2.2' income = '4' loyalty = '1' )
  ( id = 73 lifespend = '6.1' newspend = '2.8' income = '4' loyalty = '1.3' )
  ( id = 74 lifespend = '7.7' newspend = '3.8' income = '6.7' loyalty = '2.2' )
  ( id = 75 lifespend = '5' newspend = '3.2' income = '1.2' loyalty = '0.2' )
  ( id = 76 lifespend = '4.9' newspend = '3' income = '1.4' loyalty = '0.2' )
  ( id = 77 lifespend = '5' newspend = '3.4' income = '1.6' loyalty = '0.4' )
  ( id = 78 lifespend = '6' newspend = '2.7' income = '5.1' loyalty = '1.6' )
  ( id = 79 lifespend = '5.5' newspend = '2.4' income = '3.7' loyalty = '1' )
  ( id = 80 lifespend = '5.1' newspend = '3.8' income = '1.5' loyalty = '0.3' )
  ( id = 81 lifespend = '4.9' newspend = '3.1' income = '1.5' loyalty = '0.1' )
  ( id = 82 lifespend = '5' newspend = '3.5' income = '1.6' loyalty = '0.6' )
  ( id = 83 lifespend = '5.2' newspend = '3.5' income = '1.5' loyalty = '0.2' )
  ( id = 84 lifespend = '4.6' newspend = '3.2' income = '1.4' loyalty = '0.2' )
  ( id = 85 lifespend = '6.5' newspend = '3' income = '5.5' loyalty = '1.8' )
  ( id = 86 lifespend = '4.9' newspend = '2.5' income = '4.5' loyalty = '1.7' )
  ( id = 87 lifespend = '7.1' newspend = '3' income = '5.9' loyalty = '2.1' )
  ( id = 88 lifespend = '7.7' newspend = '2.6' income = '6.9' loyalty = '2.3' )
  ( id = 89 lifespend = '4.8' newspend = '3.4' income = '1.9' loyalty = '0.2' )
  ( id = 90 lifespend = '6.4' newspend = '3.2' income = '4.5' loyalty = '1.5' )
  ( id = 91 lifespend = '5.1' newspend = '3.5' income = '1.4' loyalty = '0.2' )
  ( id = 92 lifespend = '5.8' newspend = '2.7' income = '4.1' loyalty = '1' )
  ( id = 93 lifespend = '6.1' newspend = '3' income = '4.9' loyalty = '1.8' )
  ( id = 94 lifespend = '6.7' newspend = '3' income = '5' loyalty = '1.7' )
  ( id = 95 lifespend = '5.8' newspend = '2.6' income = '4' loyalty = '1.2' )
  ( id = 96 lifespend = '5.1' newspend = '3.8' income = '1.6' loyalty = '0.2' )
  ( id = 97 lifespend = '6.9' newspend = '3.1' income = '5.4' loyalty = '2.1' )
  ( id = 98 lifespend = '4.8' newspend = '3.1' income = '1.6' loyalty = '0.2' )
  ( id = 99 lifespend = '4.5' newspend = '2.3' income = '1.3' loyalty = '0.3' )
  ( id = 100 lifespend = '6.8' newspend = '3.2' income = '5.9' loyalty = '2.3' )
  ( id = 101 lifespend = '6' newspend = '2.9' income = '4.5' loyalty = '1.5' )
  ( id = 102 lifespend = '7.7' newspend = '3' income = '6.1' loyalty = '2.3' )
  ( id = 103 lifespend = '6.4' newspend = '2.7' income = '5.3' loyalty = '1.9' )
  ( id = 104 lifespend = '5.9' newspend = '3' income = '5.1' loyalty = '1.8' )
  ( id = 105 lifespend = '5' newspend = '3.6' income = '1.4' loyalty = '0.2' )
  ( id = 106 lifespend = '5.4' newspend = '3.9' income = '1.7' loyalty = '0.4' )
  ( id = 107 lifespend = '6.6' newspend = '2.9' income = '4.6' loyalty = '1.3' )
  ( id = 108 lifespend = '5.9' newspend = '3.2' income = '4.8' loyalty = '1.8' )
  ( id = 109 lifespend = '5.8' newspend = '2.7' income = '5.1' loyalty = '1.9' )
  ( id = 110 lifespend = '5.2' newspend = '3.4' income = '1.4' loyalty = '0.2' )
  ( id = 111 lifespend = '7.4' newspend = '2.8' income = '6.1' loyalty = '1.9' )
  ( id = 112 lifespend = '4.4' newspend = '3.2' income = '1.3' loyalty = '0.2' )
  ( id = 113 lifespend = '6.9' newspend = '3.1' income = '5.1' loyalty = '2.3' )
  ( id = 114 lifespend = '5.6' newspend = '3' income = '4.1' loyalty = '1.3' )
  ( id = 115 lifespend = '6.5' newspend = '3' income = '5.8' loyalty = '2.2' )
  ( id = 116 lifespend = '5' newspend = '2' income = '3.5' loyalty = '1' )
  ( id = 117 lifespend = '6.2' newspend = '2.9' income = '4.3' loyalty = '1.3' )
  ( id = 118 lifespend = '4.9' newspend = '3.1' income = '1.5' loyalty = '0.1' )
  ( id = 119 lifespend = '4.9' newspend = '2.4' income = '3.3' loyalty = '1' )
  ( id = 120 lifespend = '5.6' newspend = '3' income = '4.5' loyalty = '1.5' )
  ( id = 121 lifespend = '6.6' newspend = '3' income = '4.4' loyalty = '1.4' )
  ( id = 122 lifespend = '6.7' newspend = '3.3' income = '5.7' loyalty = '2.1' )
  ( id = 123 lifespend = '4.6' newspend = '3.4' income = '1.4' loyalty = '0.3' )
  ( id = 124 lifespend = '5.1' newspend = '2.5' income = '3' loyalty = '1.1' )
  ( id = 125 lifespend = '5' newspend = '3.4' income = '1.5' loyalty = '0.2' )
  ( id = 126 lifespend = '4.8' newspend = '3' income = '1.4' loyalty = '0.1' )
  ( id = 127 lifespend = '4.9' newspend = '3.1' income = '1.5' loyalty = '0.1' )
  ( id = 128 lifespend = '6.3' newspend = '3.3' income = '4.7' loyalty = '1.6' )
  ( id = 129 lifespend = '7.9' newspend = '3.8' income = '6.4' loyalty = '2' )
  ( id = 130 lifespend = '6.4' newspend = '3.1' income = '5.5' loyalty = '1.8' )
  ( id = 131 lifespend = '6.1' newspend = '3' income = '4.6' loyalty = '1.4' )
  ( id = 132 lifespend = '4.6' newspend = '3.6' income = '1' loyalty = '0.2' )
  ( id = 133 lifespend = '6.7' newspend = '2.5' income = '5.8' loyalty = '1.8' )
  ( id = 134 lifespend = '5.7' newspend = '2.8' income = '4.1' loyalty = '1.3' )
  ( id = 135 lifespend = '6.3' newspend = '2.5' income = '5' loyalty = '1.9' )
  ( id = 136 lifespend = '5.6' newspend = '2.9' income = '3.6' loyalty = '1.3' )
  ( id = 137 lifespend = '6.5' newspend = '3.2' income = '5.1' loyalty = '2' )
  ( id = 138 lifespend = '7.2' newspend = '3.2' income = '6' loyalty = '1.8' )
  ( id = 139 lifespend = '6.5' newspend = '2.8' income = '4.6' loyalty = '1.5' )
  ( id = 140 lifespend = '6.7' newspend = '3' income = '5.2' loyalty = '2.3' )
  ( id = 141 lifespend = '6.7' newspend = '3.1' income = '4.4' loyalty = '1.4' )
  ( id = 142 lifespend = '5.2' newspend = '4.1' income = '1.5' loyalty = '0.1' )
  ( id = 143 lifespend = '4.8' newspend = '3' income = '1.4' loyalty = '0.3' )
  ( id = 144 lifespend = '6.7' newspend = '3.3' income = '5.7' loyalty = '2.5' )
  ( id = 145 lifespend = '4.4' newspend = '3' income = '1.3' loyalty = '0.2' )
  ( id = 146 lifespend = '5.1' newspend = '3.3' income = '1.7' loyalty = '0.5' )
  ( id = 147 lifespend = '5.3' newspend = '3.7' income = '1.5' loyalty = '0.2' )
  ( id = 148 lifespend = '5.8' newspend = '2.7' income = '3.9' loyalty = '1.2' )
  ( id = 149 lifespend = '6.2' newspend = '2.8' income = '4.8' loyalty = '1.8' )
  ( id = 150 lifespend = '5.8' newspend = '2.8' income = '5.1' loyalty = '2.4' )
).

" ----------------------------------------------------------------------------------------------------------------------------------
" execute R script via FastRWeb Connector
DATA(lo_r_kmeans) = NEW zz_cl_fastrweb_connector( iv_result_type = zz_if_fastrweb_connector=>mc_result_type_json
                                                  iv_destination = 'Z_RSERVE_FP'
                                                  iv_rscript_path = '/R/kmeans_by_nw' ).

DATA lt_parameter TYPE zz_if_fastrweb_connector=>mtt_key_value.
APPEND VALUE #( key = 'customer' value = REF #( lt_customer ) ) TO lt_parameter.

DATA(ls_settings) = VALUE lts_settings( centers = 4 ).
APPEND VALUE #( key = 'settings' value = REF #( ls_settings ) ) TO lt_parameter.

DATA lt_result TYPE zz_if_fastrweb_connector=>mtt_key_value.
DATA lt_cluster TYPE ltt_cluster.
APPEND VALUE #( key = zz_if_fastrweb_connector=>mc_result_key value = REF #( lt_cluster ) ) TO lt_result.

TRY.
    lo_r_kmeans->execute_script( EXPORTING it_parameter = lt_parameter
                                 CHANGING ct_result = lt_result ).
  CATCH cx_t100_msg INTO DATA(lx_t100_msg).
    WRITE: / lx_t100_msg->get_text( ).
ENDTRY.

WRITE:       |Customer ID|,
       AT 20 |Cluster ID|.

DATA(lv_i) = 0.
DO lines( lt_cluster[] ) TIMES.
  lv_i = lv_i + 1.
  WRITE: /       lt_cluster[ lv_i ]-id,
           AT 20 lt_cluster[ lv_i ]-cluster.
ENDDO.

" ----------------------------------------------------------------------------------------------------------------------------------
" coding of R script "kmeans_by_nw"
*run <- function(settings, customer){
*  # load jsonlite library for JSON data handling (i/o)
*  library(jsonlite)
*
*  # load amap library for k-Means algorithm
*  library(amap)
*
*  # convert input parameters in JSON to data frame
*  customerData <- fromJSON(customer)
*  settingsData <- fromJSON(settings)
*
*  # remove ID for clustering
*  inputWoID <- data.frame(lifespend=customerData$DATA$LIFESPEND, newspan=customerData$DATA$NEWSPEND, income=customerData$DATA$INCOME, loyalty=customerData$DATA$LOYALTY)
*
*  # k-Means execution; 3 clusters, max 100 iterations, Euclidean method
*  resultKMeans <- Kmeans(inputWoID, centers=settingsData$DATA$CENTERS, iter.max=100, method="euclidean")
*
*  # combine customer information with clusters
*  customerAssignedToCluster <- data.frame(ID=customerData$DATA$ID, CLUSTER=resultKMeans$cluster)
*
*  # convert result data frame to JSON
*  customerAssignedToClusterRoot <- list(DATA=customerAssignedToCluster)
*  resultJSON <- toJSON(customerAssignedToClusterRoot)
*
*  done(resultJSON, cmd = "html", type = "application/json")
*}
