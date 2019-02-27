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

#ifndef CLINTEXPLORER_CLINTPROCESS_HPP
#define CLINTEXPLORER_CLINTPROCESS_HPP

#include <QObject>
#include <QtCore/QtCore>
#include <QWebEngineView>
#include <QWebEngineProfile>
#include <iostream>
#include <memory>
#include <thread>
#include <chrono>

class ClintProcess : public QObject
{
  Q_OBJECT

  public:
    explicit ClintProcess( const std::string& clintPath,
      const std::string& clintHost, const std::string& clintPort,
      QObject *parent = 0 );

  private:
    std::string _clintHost;
    std::string _clintPort;
    std::unique_ptr<QProcess> _process;
    QWebEngineView _view;

  signals:

  public slots :
    void error(QProcess::ProcessError error);
    void finished(int exitCode, QProcess::ExitStatus exitStatus);
    void readyReadStandardError();
    void readyReadStandardOutput();
    void started();

    void clintIsReady();
};

#endif
