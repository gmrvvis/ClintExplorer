#include <cstdlib>
#include <iostream>
#include <boost/bind.hpp>
#include <boost/smart_ptr.hpp>
#include <boost/asio.hpp>
#include <boost/thread/thread.hpp>
#include <vector>
#include <manco/manco.h>

using boost::asio::ip::tcp;
namespace asio = boost::asio;

#define CLOSE_SERVER_MESSAGE "exit"

typedef boost::shared_ptr<tcp::socket> SocketPtr;

bool serverOK = true;

std::vector<std::string> split( const std::string& str, const std::string& delimiter )
{
  std::string s = str;
  std::vector< std::string > v;
  size_t pos = 0;
  std::string token;
  while ( ( pos = s.find( delimiter ) ) != std::string::npos )
  {
    token = s.substr( 0, pos );
    v.push_back( token );
    s.erase( 0, pos + delimiter.length( ) );
  }
  v.push_back(s);
  return v;
}

void sendMessage( SocketPtr socket, const std::string& str )
{
  const std::string msg = str +"\n";
  asio::write( *socket, asio::buffer( msg ) );
}



void manageMessage( SocketPtr /*socket*/, const std::string& str )
{
    std::cout << str << std::endl;
    std::string key;
    std::vector<std::string> ids_vector1 = split(str,"&");
    std::vector<std::string> ids_vector = split(ids_vector1[4],";");

    unsigned int color_red= atoi(ids_vector1[1].c_str());
    unsigned int color_green= atoi(ids_vector1[2].c_str());
    unsigned int color_blue= atoi(ids_vector1[3].c_str());



    std::string key_name = manco::ZeqManager::getKeyOwner(ids_vector1[0], manco::CLINT);

    manco::ZeqManager::instance().publishSyncGroup( key_name, ids_vector1[0], manco::CLINT, ids_vector, color_red, color_green, color_blue);



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

int main( int /*argc*/, char* argv[] )
{
  unsigned int server_port = 31400;
  try
  {
    /*if ( argc == 2 )
    {
      server_port = std::atoi( argv[ 1 ] );
    }
    else
    {
      server_port = 31400;
    }*/

    boost::asio::io_service io_service;
    manco::ZeqManager::instance( ).init( argv[ 1 ] );

    server( io_service, server_port );
  }
  catch ( std::exception& e )
  {
    std::cerr << "Exception: " << e.what() << "\n";
  }

  return 0;
}
