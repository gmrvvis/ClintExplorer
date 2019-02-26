# Clint Explorer
# Copyright (c) 2017-2019 GMRV/URJC.
#
# Authors: Fernando Trincado Alonso <fernandotrin@gmail.com>
#
# This file is part of ClintExplorer <https://gitlab.gmrv.es/retrieval/ClintExplorer>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

rserver <- function(n_port){
  while(TRUE){
    writeLines("Listening...")
    con <- socketConnection(host="localhost", port = n_port, blocking=TRUE,
                            server=TRUE, open="r+")
    writeLines("Message received")
    data <- readLines(con, -1)

    writeLines(data)
    #data<-scan(con,-1L)
    
    
    #if(clint_response!="nofile")
    #{
      #data<-read.csv(con)
      #write.csv(data,file="csvprueba3.csv",row.names=FALSE)
    #}
    #else
    #{
    #  print(clint_response)
    #  data<-clint_response
    #}
    
    #print(data)
    #response <- toupper(data) 
    #response<-"holita"
    #writeLines(response, con) 
    #output<-list(clint_response,data)
    return(data)
    close(con)
    
  }
  
}



