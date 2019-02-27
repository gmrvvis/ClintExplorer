/*
 * Clint Explorer
 * Copyright (c) 2017-2019 GMRV/URJC.
 *
 * Authors: Cristian Rodriguez Bernal <cristian.rodriguez@urjc.es>
 *          Gonzalo Bayo Martinez <gonzalo.bayo@urjc.es>
 *
 * This file is part of ClintExplorer <https://gitlab.gmrv.es/retrieval/ClintExplorer>
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

#include <cstdlib>
#include <iostream>
#include <vector>
#include <map>
#include <memory>
#include <QApplication>
#include <QProcess>

#include "TcpSocketAsyncServer.hpp"
#include "ClintProcess.hpp"
#include "Definitions.hpp"

#include <vishnucommon/vishnucommon.h>

void showHelpInfo( char *argv0 )
{
  std::stringstream message;
  message << "\nUsage:\t" << argv0
    << " [-z value -sp value] [-ce value -ch value -cp value]\n\n"
    << "Options:\n"
    << "\t-h Show help information\n"
    << "\t-z ZeroEQ session\n"
    << "\t-sp Socket Port\n"
    << "\t-ch Clint Host\n"
    << "\t-cp Clint Port\n"
    << "\t-f File\n\n"
    << "Example:\n\n"
    << "\t ClintExplorer -z hbp:// -sp 31400 -ch \"http://localhost\" -cp 8765\n";
  std::cout << message.str( ) << std::endl;
}

int main( int argc, char* argv[] )
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  TcpSocketAsyncServer* server = nullptr;
  std::unique_ptr<ClintProcess> clintProcess;
  std::string execPath = getExecPath( );

  //Args
  std::string zeqSession( "" );
  std::string socketPort( "" );
  unsigned int iSocketPort( 0 );
  std::string clintPath( execPath + "R/CLINTv5.R" );
  std::string clintHost( "" );
  std::string clintPort( "" );
  unsigned int iClintPort( 0 );
  std::string instanceId( "" );
  std::string file( "" );

  //Clint R Path
  if ( !vishnucommon::Files::exist( clintPath ) )
  {
    vishnucommon::Error::throwError( vishnucommon::Error::ErrorType::Error,
      "File '" + clintPath + "' doesn't exist!", true );
  }

  //Parse args
  vishnucommon::Args args( argc, argv );

  if ( ( argc == 1 ) || ( args.has( "-h" ) ) )
  {
    showHelpInfo( argv[0] );
    return 0;
  }

  //ZeqSession
  zeqSession = args.get( "-z" );

  //Socket port
  socketPort = args.get( "-sp" );
  if( !socketPort.empty( ) )
  {
    try
    {
      iSocketPort = static_cast<unsigned short>( std::stoi( socketPort ) );
      if( !vishnucommon::Maths::inRange<int>( static_cast<int>( iSocketPort ),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED ) )
      {
        std::cout << "Invalid socket port. Please, enter port number between "
          << MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
        exit( -1 );
      }
    }
    catch( ... )
    {
      std::cout << "Invalid socket port. Please, enter port number between "
        << MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
      exit( -1 );
    }
  }

  //Clint Host
  clintHost = args.get( "-ch" );

  //Clint Port
  clintPort = args.get( "-cp" );
  if( !clintPort.empty( ) )
  {
    try
    {
      iClintPort = static_cast<unsigned short>( std::stoi( clintPort ) );
      if( !vishnucommon::Maths::inRange<int>( static_cast<int>( iClintPort ),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED ) )
      {
        vishnucommon::Error::throwError( vishnucommon::Error::ErrorType::Error,
          "Invalid Clint port. Please, enter port number between "
          + std::to_string( MIN_PORT_ALLOWED ) + " and "
          + std::to_string( MAX_PORT_ALLOWED ), true );
      }
    }
    catch( ... )
    {
        vishnucommon::Error::throwError( vishnucommon::Error::ErrorType::Error,
          "Invalid Clint port. Please, enter port number between "
          + std::to_string( MIN_PORT_ALLOWED ) + " and "
          + std::to_string( MAX_PORT_ALLOWED ), true );
    }
  }

  if ( args.has( "-f" ) )
  {
    file = args.get( "-f" );
  }

  instanceId = args.has( "-id" )
    ? args.get( "-id" )
    : vishnucommon::Strings::generateRandom( 5 );

  bool enableCommunication = ( ( !zeqSession.empty( ) )
    && ( !socketPort.empty( ) ) );
  bool openClint = ( ( !clintHost.empty( ) ) && ( !clintPort.empty( ) ) );

  if ( ( !enableCommunication ) && ( !openClint) )
  {
    std::cerr << "Error: Invalid args." << std::endl;
    showHelpInfo( argv[0] );
    return -1;
  }

  //Show args
  std::stringstream message;
  if ( enableCommunication )
  {
    message << "ZeroEQ session: " << zeqSession << "\n"
      << "Socket Port: " << iSocketPort << "\n";
  }
  if ( !clintPath.empty( ) )
  {
    message << APPLICATION_NAME << " in standalone mode." << "\n"
      << "Clint path: " << clintPath << "\n";
  }
  if ( openClint )
  {
    message << "Clint URL: " << clintHost << ":" << iClintPort << "\n";
  }
  std::cout << message.str( ) << std::endl;

  if ( enableCommunication )
  {
    //Init Zeq session
    std::cout << "Init ZeqSession (" << zeqSession << ")..." << std::endl;
    manco::ZeqManager::instance( ).init( zeqSession );
  }

  if ( enableCommunication )
  {
    //Tcp async socket
    server = new TcpSocketAsyncServer(
      static_cast<quint16>( iSocketPort ), instanceId, file );

    QObject::connect(server, &TcpSocketAsyncServer::closed, &app,
      &QCoreApplication::quit);
  }

  if ( ( !clintHost.empty( ) ) && ( iClintPort != 0 ) )
  {
    //Clint process
    std::cout << "Starting Clint process..." << std::endl;
    clintProcess.reset( new ClintProcess(
      clintPath, clintHost, std::to_string(iClintPort) ) );

    if ( enableCommunication )
    {
      QObject::connect( server, &TcpSocketAsyncServer::signalClintIsReady,
        clintProcess.get( ), &ClintProcess::clintIsReady );
    }
    else
    {
      clintProcess->clintIsReady( );
    }
  }

  //Launch app
  return app.exec();
}

