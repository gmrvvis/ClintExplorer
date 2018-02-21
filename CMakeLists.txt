# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#   ClintExplorer
#   2017 (c) GMRV / Universidad Rey Juan Carlos
#   gmrv@gmrv.es
#   www.gmrv.es
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
cmake_minimum_required( VERSION 3.1 )
set( PROJECT_VERSION_MAJOR "1" )
set( PROJECT_VERSION_MINOR "0" )
set( PROJECT_VERSION_PATCH "0" )
set( PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH} )
project( ClintExplorer VERSION ${PROJECT_VERSION} )
set( ClintExplorer_VERSION_ABI 1 )

# Disable in source building
if( "${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}" )
  message( FATAL "no in source building allowed." )
endif()

list(APPEND CMAKE_MODULE_PATH
  ${PROJECT_SOURCE_DIR}/CMake
  ${CMAKE_SOURCE_DIR}/CMake/common)

# Default build type is Debug
if( NOT CMAKE_BUILD_TYPE )
  set( CMAKE_BUILD_TYPE Debug )
endif( NOT CMAKE_BUILD_TYPE )

if ( CMAKE_BUILD_TYPE MATCHES "Debug" )
  add_definitions( -DDEBUG )
endif( )

include(GitExternal)

set(CLINTEXPLORER_DESCRIPTION "Clint Explorer")
set(COMMON_PROJECT_DOMAIN gmrv.es)

include(Common)

# Allow warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")

common_find_package( Qt5Core SYSTEM REQUIRED )
common_find_package( Qt5WebEngineWidgets SYSTEM REQUIRED )
common_find_package( Qt5WebSockets SYSTEM REQUIRED )
common_find_package( manco REQUIRED )
common_find_package( sp1common REQUIRED )

list(APPEND CLINTEXPLORER_DEPENDENT_LIBRARIES 
  Qt5::Core
  Qt5::WebEngineWidgets
  Qt5::WebSockets
  manco
  sp1common
)

common_find_package_post( )

# Allow warnings
# set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w" )

add_subdirectory( clintexplorer )

if( MSVC )
  # Set ClintExplorer as startup project on Visual Studio, CMake v3.6
  if( CMAKE_VERSION VERSION_GREATER 3.6 )
    set_property( DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ClintExplorer )
  endif( )
endif( )

set( DOXYGEN_MAINPAGE_MD README.md )
set( DOXYGEN_EXTRA_INPUT ${PROJECT_SOURCE_DIR}/README.md )
include( DoxygenRule )

include( CPackConfig )
