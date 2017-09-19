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
)

set(CLINTEXPLORER_HEADERS
  ${PROJECT_BINARY_DIR}/include/clintexplorer/version.h
  TcpSocketAsyncServer.hpp
  utils/Auxiliars.hpp
)

set(CLINTEXPLORER_LINK_LIBRARIES
    Qt5::Core
    Qt5::WebEngineWidgets
    Qt5::WebSockets
    manco
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${PROJECT_BINARY_DIR}/include ${PROJECT_BINARY_DIR}/src)

common_application(ClintExplorer)
