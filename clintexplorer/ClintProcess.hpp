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
      const std::string& clintHost, const std::string& clintPort, QObject *parent = 0 );

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
};

#endif
