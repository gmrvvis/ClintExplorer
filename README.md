# ClintExplorer
Copyright (c) 2017-2019 GMRV/URJC.

## Introduction

Clint Explorer is an application that uses supervised and unsupervised 
learning techniques to cluster neurobiological dataset. 
The main contributions of this software is that incorporates the expert’s 
know-how in the clustering process. Besides, it allows to interpret the 
results providing different metrics.

## Dependencies

* ManCo
* VishnuCommon

## Building

ClintExplorer has been successfully built and tested on Ubuntu 18.04 / 
Windows 10. The following steps are for build:

```bash
$ git clone git@gitlab.gmrv.es:retrieval/clintexplorer.git
$ mkdir clintexplorer/build && cd clintexplorer/build
$ cmake .. [-DCLONE_SUBPROJECTS=ON]
```

## License

GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
