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

#include <sp1common/sp1common.h>

void showHelpInfo( char *argv0 )
{
  std::stringstream message;
  message << "\nUsage:\t" << argv0
    << " [-z value -sp value] [-ce value -ch value -cp value]\n\n"
    << "Options:\n"
    << "\t-h Show help information\n"
    << "\t-z ZeroEQ session\n"
    << "\t-sp Socket Port\n"
    << "\t-ce Clint Executable Path\n"
    << "\t-ch Clint Host\n"
    << "\t-cp Clint Port\n"
    << "\t-f File\n\n"
    << "Example:\n\n"
    << "\t ClintExplorer -z hbp:// -sp 31400 -ce \"../Clint/CLINTv5.R\" -ch \"http://localhost\" -cp 8765\n";
  std::cout << message.str( ) << std::endl;
}

int main( int argc, char* argv[] )
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  TcpSocketAsyncServer* server = nullptr;
  std::unique_ptr<ClintProcess> clintProcess;

  //Args
  std::string zeqSession( "" );
  std::string socketPort( "" );
  unsigned int iSocketPort( 0 );
  std::string clintPath( "" );
  std::string clintHost( "" );
  std::string clintPort( "" );
  unsigned int iClintPort( 0 );
  std::string instanceId( "" );
  std::string file( "" );

  //Parse args
  sp1common::Args args( argc, argv );

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
      if( !sp1common::Maths::inRange<int>( static_cast<int>( iSocketPort ),
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

  //Clint R Path
  if ( args.has( "-ce" ) )
  {
    clintPath = args.get( "-ce" );
    if ( !sp1common::Files::fileExists( clintPath ) )
    {
      std::cerr << "Error: file '" << clintPath << "' doesn't exist!"
        << std::endl;
      return -1;
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
      if( !sp1common::Maths::inRange<int>( static_cast<int>( iClintPort ),
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

  if ( args.has( "-f" ) )
  {
    file = args.get( "-f" );
  }

  instanceId = args.has( "-id" )
    ? args.get( "-id" )
    : sp1common::Strings::generateRandom( 5 );

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

  if ( !clintPath.empty( ) )
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
  app.exec();

  return 0;
}

