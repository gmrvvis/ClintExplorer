#include <iostream>
#include <boost/asio.hpp>

namespace asio = boost::asio;

std::string readline( asio::ip::tcp::socket & socket )
{
  asio::streambuf buf;
  asio::read_until( socket, buf, "\n" );

  std::string data = asio::buffer_cast<const char*>(buf.data());
  data.erase( --data.end() );  // remove the last delimeter
  return data;
}

void sendline( asio::ip::tcp::socket & socket, const std::string& str )
{
  const std::string msg = str + "\n";
  asio::write( socket, asio::buffer(msg) );
}

int main( void )
{
  asio::io_service io_service;

  asio::ip::tcp::acceptor acc(
      io_service,
      asio::ip::tcp::endpoint( asio::ip::tcp::v4(), 31400 ) );
  asio::ip::tcp::socket socket(io_service);

  std::cout << "Started TCP socket at localhost at port 31400" << std::endl;

  acc.accept( socket );

  while(true)
  {
    std::string str = readline( socket );
    std::cout << str << std::endl;

    sendline(socket, "pong");
    std::cout << "sent pong" << std::endl;
  }

  return 0;
}