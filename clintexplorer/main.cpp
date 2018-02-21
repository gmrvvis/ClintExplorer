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

#include <sp1common/Args.hpp>
#include <sp1common/Common.hpp>

int main( int argc, char* argv[] )
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);

  //Args
  std::string zeqSession( "" );
  std::string socketPort( "" );
  unsigned int iSocketPort( 0 );
  std::string clintHost( "" );
  std::string clintPort( "" );
  unsigned int iClintPort( 0 );

  //Parse args
  sp1common::Args args( argc, argv );

  //ZeqSession
  zeqSession = args.get( "-z" );

  //Socket port
  socketPort = args.get( "-sp" );
  if( !socketPort.empty( ) )
  {
    try
    {
      iSocketPort = static_cast<unsigned short>( std::stoi( socketPort ) );
      if( !sp1common::Common::inRange<int>( static_cast<int>( iSocketPort ),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED ) )
      {
        std::cout << "Invalid socket port. Please, enter port number between " <<
          MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
        exit( -1 );
      }
    }
    catch( ... )
    {
      std::cout << "Invalid socket port. Please, enter port number between " <<
        MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
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
      if( !sp1common::Common::inRange<int>( static_cast<int>( iClintPort ),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED ) )
      {
        std::cout << "Invalid Clint port. Please, enter port number between " <<
          MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
        exit( -1 );
      }
    }
    catch( ... )
    {
      std::cout << "Invalid Clint port. Please, enter port number between " <<
        MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED << std::endl;
      exit( -1 );
    }
  }

  //Show args
  std::cout << "ZeroEQ session: " << zeqSession << "\n" <<
    "Socket Port: " << iSocketPort << "\n" <<
    "Clint URL: " << clintHost << ":" << iClintPort <<
    std::endl;

  //Init Zeq session
  std::cout << "Init ZeqSession (" << zeqSession << ")..." << std::endl;
  manco::ZeqManager::instance( ).init( zeqSession );

  //Clint process
  std::cout << "Starting Clint process..." << std::endl;
  std::unique_ptr<ClintProcess> clintProcess( new ClintProcess( clintHost, std::to_string(iClintPort) ) );

  //Tcp async socket
  TcpSocketAsyncServer* server = new TcpSocketAsyncServer( static_cast<quint16>( iSocketPort ) );
  QObject::connect(server, &TcpSocketAsyncServer::closed, &app, &QCoreApplication::quit);

  //Launch app
  return app.exec();
}

