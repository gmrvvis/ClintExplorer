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

#ifndef CLINTEXPLORER_TCPSOCKETASYNCSERVER_HPP
#define CLINTEXPLORER_TCPSOCKETASYNCSERVER_HPP

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QBuffer>
#include <iostream>
#include <string>
#include <manco/manco.h>
#include <vishnucommon/vishnucommon.h>
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
    void manageMessage( const std::string& str );
    std::string _owner;
    std::string _file;
};

#endif
