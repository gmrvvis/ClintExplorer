#include <cstdlib>
#include <iostream>
#include <boost/bind.hpp>
#include <boost/smart_ptr.hpp>
#include <boost/asio.hpp>
#include <boost/thread/thread.hpp>

using boost::asio::ip::tcp;
namespace asio = boost::asio;

#define CLOSE_SERVER_MESSAGE "exit"

typedef boost::shared_ptr<tcp::socket> SocketPtr;

bool serverOK = true;

void sendMessage( SocketPtr socket, const std::string& str )
{
  const std::string msg = str +"\n";
  asio::write( *socket, asio::buffer( msg ) );
}

void manageMessage( SocketPtr socket, const std::string& message )
{
  if ( message == "hello" )
  {
    sendMessage( socket, "goodbye" );
  }
}

void session(SocketPtr socket)
{
  try
  {
    while( true )
    {
      asio::streambuf buf;
      boost::system::error_code error;
      asio::read_until( *socket, buf, "\n", error );

      if ( error == boost::asio::error::eof )
      {
        break; // Connection closed cleanly by peer
      }
      else if ( error )
      {
        throw boost::system::system_error( error ); // Some other errors
      }

      std::string data = asio::buffer_cast<const char*>(buf.data());
      data.erase( --data.end() );  // remove the last delimeter

      if ( data == CLOSE_SERVER_MESSAGE )
      {
        serverOK = false;
        break;
      }
      else
      {
        manageMessage( socket, data );
      }
    }
  }
  catch (std::exception& e)
  {
    std::cerr << "Exception in thread: " << e.what() << "\n";
  }
}

void server( boost::asio::io_service& io_service, short port )
{
  tcp::acceptor a( io_service, tcp::endpoint(tcp::v4( ), port ) );
  while( serverOK )
  {
    SocketPtr sock( new tcp::socket( io_service ) );
    a.accept( *sock );
    auto t = boost::thread( boost::bind( session, sock ) );
    t.join( );
  }
}

int main( int argc, char* argv[] )
{
  unsigned int server_port;
  try
  {
    if ( argc == 2 )
    {
      server_port = std::atoi( argv[ 1 ] );
    }
    else
    {
      server_port = 31400;
    }

    boost::asio::io_service io_service;

    server( io_service, server_port );
  }
  catch ( std::exception& e )
  {
    std::cerr << "Exception: " << e.what() << "\n";
  }

  return 0;
}