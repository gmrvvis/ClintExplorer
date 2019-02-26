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

rclientfile <- function( n_port )
{
  host_name <- 'localhost'
  if(exists("DOCKER_HOST_NAME"))
    host_name <- DOCKER_HOST_NAME

  #Sync connection to request for file
  con <- socketConnection( host = host_name, port = n_port, blocking=TRUE, 
    server=FALSE, open="r+" )

  print( "Request for input file..." )
  writeLines( "file", con )

  #ClintExplorer response (nofile or number of rows)
  clint_response <- readLines( con, 1 ) 
    
  if ( clint_response != "nofile" )
  {
    #Rows of csv
    rows <- strtoi( clint_response ) 

    print( paste0( "Reading file from socket...(", rows, " rows)" ))
    csv_data <- readLines( con, n=rows, ok=TRUE, warn=FALSE )

    #Response to ClintExplorer in order to open QWebEngineView
    print( "Done!" )
    writeLines( "filereaded", con )
  }
  else
  {
    print( clint_response )
    csv_data <- clint_response
  }  

  #Closing socket connection
  close( con )  

  #Return result
  output <- list( clint_response, csv_data )
  return( output )  
}
