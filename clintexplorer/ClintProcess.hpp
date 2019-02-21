/*
 * Copyright (c) 2017-2019 GMRV/URJC.
 *
 * Authors: Gonzalo Bayo Martinez <gonzalo.bayo@urjc.es>
 *
 * This file is part of ClintExplorer <https://gitlab.gmrv.es/retrieval/ClintExplorer>
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3.0 as published
 * by the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
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
