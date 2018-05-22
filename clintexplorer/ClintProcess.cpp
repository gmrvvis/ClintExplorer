#include "ClintProcess.hpp"

ClintProcess::ClintProcess( const std::string& clintPath,
  const std::string& clintHost, const std::string& clintPort, QObject *parent )
  : QObject( parent )
  , _clintHost( clintHost )
  , _clintPort( clintPort )
{
  if ( !clintPath.empty( ) )
  {
    QString clintApp = QString("R");
    std::string shiny = "shiny::runApp(appDir='" + clintPath + "',port="
      + clintPort + ")";
    QStringList clintArguments;
      clintArguments << QString("-e");
      clintArguments << QString::fromStdString(shiny);

    _process.reset( new QProcess( ) );
    _process->setReadChannel(QProcess::StandardOutput);
    //_process->setProcessChannelMode(QProcess::ForwardedChannels); //debug
    _process->start(
      clintApp,
      clintArguments
    );

    QObject::connect( _process.get( ), SIGNAL( readyReadStandardOutput( ) ), this,
      SLOT( readyReadStandardOutput( ) ) );
  }
}

void ClintProcess::clintIsReady( )
{
  std::cout << "Starting Clint browser..." << std::endl;

  std::this_thread::sleep_for(std::chrono::milliseconds(1000));

  _view.page()->profile( )->setHttpCacheType( QWebEngineProfile::NoCache );
  _view.setUrl( QUrl( QString::fromStdString( _clintHost + ":" + _clintPort ) ) );
  _view.setWindowTitle( QString( "Clint - " ) + QString::fromStdString( _clintPort ) );
  _view.showMaximized( );
}

void ClintProcess::error(QProcess::ProcessError error)
{
  qDebug() << "Error: " << error;
}

void ClintProcess::finished(int exitCode, QProcess::ExitStatus exitStatus)
{
  qDebug() << "Finished: " << exitCode;
  qApp->exit();
}

void ClintProcess::readyReadStandardError()
{
  qDebug() << "ReadyError";
}

void ClintProcess::readyReadStandardOutput()
{
  /*QByteArray buf = _process->readAllStandardOutput();

  QString output = buf;
  if (output.contains(QString::fromStdString("> shiny::runApp(appDir='")))
  {
    std::cout << output.toStdString() << std::endl;
    std::cout << "Starting Clint browser..." << std::endl;

    std::this_thread::sleep_for(std::chrono::milliseconds(3000));

    _view.page()->profile( )->setHttpCacheType( QWebEngineProfile::NoCache );
    _view.setUrl( QUrl( QString::fromStdString( _clintHost + ":" + _clintPort ) ) );
    _view.setWindowTitle( QString( "Clint - " ) + QString::fromStdString( _clintPort ) );
    _view.showMaximized( );
  }*/
}

void ClintProcess::started()
{
  qDebug() << "Process Started";
}
