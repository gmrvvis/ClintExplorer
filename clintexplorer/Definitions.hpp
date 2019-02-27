/*
 * Clint Explorer
 * Copyright (c) 2017-2019 GMRV/URJC.
 *
 * Authors: Gonzalo Bayo Martinez <gonzalo.bayo@urjc.es>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <string>

#ifndef CLINTEXPLORER_DEFINITIONS_HPP
  #define CLINTEXPLORER_DEFINITIONS_HPP

  #define APPLICATION_NAME "Clint Explorer"

  #define DEFAULT_ZEQ_SESSION "hbp://"
  #define DEFAULT_SOCKET_PORT 31400
  #define DEFAULT_CLINT_HOST "http://localhost"
  #define DEFAULT_CLINT_PORT 3652
  #define MIN_PORT_ALLOWED 1024
  #define MAX_PORT_ALLOWED 65535

  #define SOCKET_MESSAGE_FILE "file\n"
  #define SOCKET_MESSAGE_NOFILE "nofile\n"
  #define SOCKET_MESSAGE_FILE_READED "filereaded\n"
  #define SOCKET_MESSAGE_EXIT "exit\n"

  #ifdef _WIN32
    #include <Windows.h>
    static std::string getExecPath( void )
    {
      char filePath[ MAX_PATH ];
      GetModuleFileName( NULL, filePath, MAX_PATH );
      std::string filePathStr( filePath );
      filePathStr = filePathStr.substr( 0, filePathStr.find_last_of( "\\" ) + 1 );
      return filePathStr;
    }
  #else
    #include <unistd.h>
    static std::string getExecPath( void )
    {
      char filePath[ PATH_MAX ];
      readlink( "/proc/self/exe", filePath, PATH_MAX );
      std::string filePathStr( filePath );
      filePathStr = filePathStr.substr( 0, filePathStr.find_last_of( "/" ) + 1 );
      return filePathStr;
    }
  #endif

#endif
