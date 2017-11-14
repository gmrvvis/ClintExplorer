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
#include "utils/Auxiliars.hpp"

static std::string _zeqSession = DEFAULT_ZEQ_SESSION;
static unsigned int _socketPort = DEFAULT_SOCKET_PORT;
static std::string _clintHost = DEFAULT_CLINT_HOST;
static unsigned int _clintPort = DEFAULT_CLINT_PORT;
static std::string _file = "";

void parseArgs(int argc, char** argv);

int main( int argc, char* argv[] )
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);

  //Parse args
  parseArgs(argc, argv);  

  //Show args
  std::cout << "ZeroEQ session: " << _zeqSession << "\n" <<
    "Socket Port: " << _socketPort << "\n" <<
    "Clint URL: " << _clintHost << ":" << _clintPort <<
    std::endl;

  //Init Zeq session
  std::cout << "Init ZeqSession (" << _zeqSession << ")..." << std::endl;
  manco::ZeqManager::instance( ).init( _zeqSession );

  //Clint process
  std::cout << "Starting Clint process..." << std::endl;
  std::unique_ptr<ClintProcess> clintProcess( new ClintProcess( _clintHost, std::to_string(_clintPort) ) );

  //Tcp async socket
  TcpSocketAsyncServer* server = new TcpSocketAsyncServer( static_cast<quint16>( _socketPort ) );
  QObject::connect(server, &TcpSocketAsyncServer::closed, &app, &QCoreApplication::quit);

  //Launch app
  return app.exec();
}

void parseArgs(int argc, char** argv)
{
  std::map<std::string, std::string> args = Auxiliars::splitArgs(argc, argv);

  //ZeqSession
  auto it = args.find("-z");
  if (it != args.end())
  {
    _zeqSession = it->second;
  }

  //Socket port
  it = args.find("-sp");
  if (it != args.end())
  {
    try
    {
      _socketPort = static_cast<unsigned short>(std::stoi(it->second));
      if (!Auxiliars::inRange<int>(static_cast<int>(_socketPort),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED))
      {
        std::cout << "Invalid socket port. Please, enter port number between " <<
          MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED <<
          ". Using default socket port " << DEFAULT_SOCKET_PORT << "..." << std::endl;
        _socketPort = DEFAULT_SOCKET_PORT;
      }
    }
    catch (...)
    {
      std::cout << "Invalid socket port. Please, enter port number between " <<
        MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED <<
        ". Using default socket port " << DEFAULT_SOCKET_PORT << "..." << std::endl;
      _socketPort = DEFAULT_SOCKET_PORT;
    }
  }

  //Clint Host
  it = args.find("-ch");
  if (it != args.end())
  {
    _clintHost = it->second;
  }

  //Clint Port
  it = args.find("-cp");
  if (it != args.end())
  {
    try
    {
      _clintPort = static_cast<unsigned short>(std::stoi(it->second));
      if (!Auxiliars::inRange<int>(static_cast<int>(_clintPort),
        MIN_PORT_ALLOWED, MAX_PORT_ALLOWED))
      {
        std::cout << "Invalid Clint port. Please, enter port number between " <<
          MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED <<
          ". Using Clint default port " << DEFAULT_CLINT_PORT << "..." << std::endl;
        _clintPort = DEFAULT_CLINT_PORT;
      }
    }
    catch (...)
    {
      std::cout << "Invalid Clint port. Please, enter port number between " <<
        MIN_PORT_ALLOWED << " and " << MAX_PORT_ALLOWED <<
        ". Using default Clint port " << DEFAULT_CLINT_PORT << "..." << std::endl;
      _clintPort = DEFAULT_CLINT_PORT;
    }
  }
}

