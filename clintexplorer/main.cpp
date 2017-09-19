#include <cstdlib>
#include <iostream>
#include <vector>
#include <QApplication>
#include <QProcess>
#include <QWebEngineView>
#include <QWebEngineProfile>
#include "TcpSocketAsyncServer.hpp"
#include "utils/Auxiliars.hpp"

#define DEFAULT_ZEQ_SESSION "hbp://"
#define DEFAULT_SOCKET_PORT "31400"
#define DEFAULT_CLINT_HOST "http://localhost"
#define DEFAULT_CLINT_PORT "3652"

int main( int argc, char* argv[] )
{
  //Parse args
  std::map<std::string, std::string> args = Auxiliars::splitArgs( argc, argv );

  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);

  //ZeqSession
  auto it = args.find( "-z" );
  if ( it == args.end( ) )
  {
    args["-z"] = DEFAULT_ZEQ_SESSION;
  }

  //Socket port
  it = args.find( "-sp" );
  if ( it == args.end( ) )
  {
    args["-sp"] = DEFAULT_SOCKET_PORT;
  }

  //Clint Host
  it = args.find( "-ch" );
  if ( it == args.end( ) )
  {
    args["-ch"] = DEFAULT_CLINT_HOST;
  }

  //Clint Port
  it = args.find( "-cp" );
  if ( it == args.end( ) )
  {
    args["-cp"] = DEFAULT_CLINT_PORT;
  }

  std::cout << "Zeq Session: " << args["-z"] << "\n" <<
    "Socket Port: " << args["-sp"] << "\n" <<
    "Clint URL: " << args["-ch"] << ":" << args["-cp"] <<
    std::endl;

  std::string zeqSession = args["-z"];
  quint16 socketPort = QString( args["-sp"].c_str() ).toUShort();
  std::string clintUrl = args["-ch"] + ":" + args["-cp"];
  unsigned int clintPort = static_cast<unsigned int>( std::stoi( args["-cp"] ) );

  //Zeq session
  std::cout << "Init ZeqSession (" << zeqSession << ")..." << std::endl;
  manco::ZeqManager::instance( ).init( zeqSession );

  //Clint process
  std::cout << "Starting Clint..." << std::endl;
  QString clintApp = QString( "R" );
  QStringList clintArguments;
  std::string clint = qApp->applicationDirPath().toStdString() + "/CLINTv4.R";
  std::string shiny = "shiny::runApp(appDir = '" + clint + "', port = " +
    std::to_string( clintPort ) + ")";
  clintArguments << QString( "-e" );
  clintArguments << QString::fromStdString( shiny );

  std::unique_ptr<QProcess> qProcess( new QProcess( ) );
  qProcess->setWorkingDirectory( qApp->applicationDirPath( ) );
  qProcess->setReadChannel( QProcess::StandardOutput );
  //qProcess->setProcessChannelMode(QProcess::ForwardedChannels); //debug
  qProcess->waitForReadyRead( );
  qProcess->readAllStandardOutput( );
  qProcess->start( clintApp, clintArguments );

  std::cout << "Starting Clint browser..." << std::endl;
  QWebEngineView view;
  view.page()->profile()->setHttpCacheType(QWebEngineProfile::NoCache);
  view.setUrl(QUrl(QString::fromStdString(clintUrl)));
  view.setWindowTitle(QString("Clint - " + QString::number(clintPort)));
  view.showMaximized();

  //Tcp async socket
  TcpSocketAsyncServer* server = new TcpSocketAsyncServer( socketPort );
  QObject::connect(server, &TcpSocketAsyncServer::closed, &app, &QCoreApplication::quit);

  //Launch app
  return app.exec();
}
