#ifndef CLINTEXPLORER_TCPSOCKETASYNCSERVER_HPP
#define CLINTEXPLORER_TCPSOCKETASYNCSERVER_HPP

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QBuffer>
#include <iostream>
#include <string>
#include <manco/manco.h>
#include <sp1common/sp1common.h>
#include "Definitions.hpp"

class TcpSocketAsyncServer : public QTcpServer
{
  Q_OBJECT

  public:
    explicit TcpSocketAsyncServer( const quint16& port,
      const std::string& instanceId, const std::string& file = std::string( ),
      QObject* parent = 0 );
    void start( quint16 port );
    ~TcpSocketAsyncServer();

  Q_SIGNALS:
    void closed();

  signals:
    void signalClintIsReady();

  public slots:
    void newConnection();

  private slots:
    void readyRead();

  private:
    //QTcpServer* _serverSocket;
    void manageMessage( const std::string& str );
    std::string _owner;
    std::string _file;
};

#endif
