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

#include "TcpSocketAsyncServer.hpp"

TcpSocketAsyncServer::TcpSocketAsyncServer( const quint16& port,
  const std::string& instanceId, const std::string& file, QObject *parent )
  : QTcpServer( parent )
  , _file( file )
{
  _owner = toString( vishnucommon::ApplicationType::CLINT )
    + instanceId;

  connect( this, SIGNAL( newConnection( ) ),
    this, SLOT(newConnection( ) ) );

  if ( !this->listen( QHostAddress::Any, port ) )
  {
    vishnucommon::Error::throwError( vishnucommon::Error::ErrorType::Error,
      "Server cannot start on port ", true );
  }
  else
  {
    std::cout << "TcpServer started on port " << port << " successfully."
      << std::endl;
  }
}

TcpSocketAsyncServer::~TcpSocketAsyncServer( )
{
  this->close( );
}

void TcpSocketAsyncServer::newConnection( )
{
  QTcpSocket* socket = this->nextPendingConnection();
  if( socket )
  {
    connect(socket, SIGNAL(readyRead()), this, SLOT(readyRead()));
    connect(socket, SIGNAL(disconnected()), socket , SLOT(deleteLater()));
  }
}

void TcpSocketAsyncServer::readyRead( )
{
  QTcpSocket* socket = dynamic_cast< QTcpSocket* >( sender( ) );
  if( socket )
  {
    QBuffer buffer;
    buffer.open( QIODevice::WriteOnly );
    buffer.write( socket->readAll( ) );

    QString qMessage = QString::fromUtf8( buffer.data( ) );
    vishnucommon::Debug::consoleMessage( "received message: '" +
      qMessage.trimmed( ).toStdString( ) + "'");

    if ( qMessage == SOCKET_MESSAGE_FILE )
    {
      if ( !_file.empty( ) )
      {
        std::string rawCsv = vishnucommon::Files::readRawCsv( _file );
        size_t csvSize = vishnucommon::Strings::split( rawCsv, '\n',
          true ).size( );
        std::string sizeResponse = std::to_string( csvSize ) + "\n";

        vishnucommon::Debug::consoleMessage(
          "Requested file. Sending file size response" );
        socket->write( sizeResponse.c_str( ) );
        socket->waitForBytesWritten( );

        vishnucommon::Debug::consoleMessage( "Sending CSV file" );
        socket->write( rawCsv.c_str() );
        socket->waitForBytesWritten( );

        vishnucommon::Debug::consoleMessage( "CSV file sent" );
      }
      else
      {
        vishnucommon::Debug::consoleMessage(
          "Requested file. Sending no file response" );
        const char* response = SOCKET_MESSAGE_NOFILE;
        socket->write( response );
        socket->waitForBytesWritten( );

        emit signalClintIsReady( );
      }
    }
    else if ( qMessage == SOCKET_MESSAGE_FILE_READED)
    {
      if ( !_file.empty( ) )
      {
        emit signalClintIsReady( );
      }
    }
    else
    {
      manageMessage( qMessage.toStdString( ) );
    }
  }
}

void TcpSocketAsyncServer::manageMessage( const std::string& str )
{
  vishnucommon::Debug::consoleMessage( "Manage message" );

  if ( str == SOCKET_MESSAGE_EXIT )
  {
    exit( 0 );
  }
  else
  {
    vishnucommon::Debug::consoleMessage( str );

    std::string key;

    try
    {
      std::vector< std::string > ids_vector1 =
        manco::ZeqManager::split( str, "&" );

      std::vector< std::string > ids_vector =
        manco::ZeqManager::split( ids_vector1[ 4 ], ";" );

      unsigned int color_red= atoi( ids_vector1[ 1 ].c_str( ) );
      unsigned int color_green= atoi( ids_vector1[ 2 ].c_str( ) );
      unsigned int color_blue= atoi( ids_vector1[ 3 ].c_str( ) );

      std::string key_name = manco::ZeqManager::getKeyOwner( ids_vector1[ 0 ],
        _owner );

      manco::ZeqManager::instance( ).publishSyncGroup( key_name,
        ids_vector1[ 0 ], _owner, ids_vector, color_red, color_green,
        color_blue );

      vishnucommon::Debug::consoleMessage( "Published sync group" );
    }
    catch (...)
    {
      vishnucommon::Error::throwError( vishnucommon::Error::ErrorType::Warning,
        "Unknown message format or incomplete message. Skipping message publication"
        , false );
    }
  }
}
