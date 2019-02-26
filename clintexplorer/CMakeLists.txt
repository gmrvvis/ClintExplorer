# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   ClintExplorer
#   2017-2019(c) GMRV / Universidad Rey Juan Carlos
#   gmrv@gmrv.es
#   www.gmrv.es
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

source_group(\\ FILES CMakeLists.txt)

set(Name ClintExplorer)
set(NAME CLINTEXPLORER)
set(namespace clintexplorer)
set(NAMESPACE CLINTEXPLORER)
set(INCLUDE_NAME clintexplorer)
set(PROJECT_VERSION_ABI ${${PROJECT_NAME}_VERSION_ABI})
configure_file(${CMAKE_SOURCE_DIR}/CMake/common/cpp/api.h
  ${PROJECT_BINARY_DIR}/include/clintexplorer/api.h @ONLY)
configure_file(${CMAKE_SOURCE_DIR}/CMake/common/cpp/version.h
  ${PROJECT_BINARY_DIR}/include/clintexplorer/version.h @ONLY)
configure_file(${CMAKE_SOURCE_DIR}/CMake/common/cpp/version.cpp
  ${PROJECT_BINARY_DIR}/src/version.cpp @ONLY)

set(CLINTEXPLORER_SOURCES
  ${PROJECT_BINARY_DIR}/src/version.cpp
  main.cpp
  TcpSocketAsyncServer.cpp
  ClintProcess.cpp
)

set(CLINTEXPLORER_HEADERS
  ${PROJECT_BINARY_DIR}/include/clintexplorer/version.h
  TcpSocketAsyncServer.hpp
  ClintProcess.hpp
  Definitions.hpp
)

set( CLINTEXPLORER_R_FILES
  R/CLINTv5.R
  R/PCA_spines_GUI.R
  R/rserver.R
  R/cluster_mean_statistics_GUI.R
  R/permute_features.R
  R/scale_spinematrix_columns.R
  R/dbscan_GUI.R
  R/preprocessing.R
  R/server_prueba.R
  R/dendrogram_color_GUI.R
  R/rcliente.R
  R/shuffle_matrix.R
  R/filtering_by_branch_level.R
  R/rclientfile.R
  R/spine_reprentation.R
  R/kmeans_3D_GUI.R
)

set(CLINTEXPLORER_LINK_LIBRARIES
  Qt5::Core
  Qt5::WebEngineWidgets
  Qt5::WebSockets
  ManCo
  VishnuCommon
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${PROJECT_BINARY_DIR}/include ${PROJECT_BINARY_DIR}/src)

if( MSVC )
  add_definitions("-W4")
  foreach( R_FILE IN LISTS CLINTEXPLORER_R_FILES )
    configure_file( 
      ${R_FILE} 
      ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug/${R_FILE} 
      COPYONLY
    )
    configure_file( 
      ${R_FILE} 
      ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release/${R_FILE} 
      COPYONLY
    )  
  endforeach( R_FILE IN LISTS CLINTEXPLORER_R_FILES )  
else( MSVC )  
  foreach( R_FILE IN LISTS CLINTEXPLORER_R_FILES )
    configure_file( 
      ${R_FILE} 
      ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${R_FILE} 
      COPYONLY
    ) 
  endforeach( R_FILE IN LISTS CLINTEXPLORER_R_FILES )
endif( MSVC )

common_application( ClintExplorer )
