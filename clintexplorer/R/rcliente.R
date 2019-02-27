# Clint Explorer
# Copyright (c) 2017-2019 GMRV/URJC.
#
# Authors: Fernando Trincado Alonso <fernandotrin@gmail.com>
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

rcliente <- function(valor,ids_matrix,name_group,number_color_red,number_color_green,number_color_blue){
  
  host_name <- 'localhost'
  if(exists("DOCKER_HOST_NAME"))
    host_name <- DOCKER_HOST_NAME
  #rclient just opens the socket and remains open
  
  #name_group,number_color_red,number_color_green,number_color_blue
  
    con <- socketConnection(host=host_name, port = 31400, blocking=FALSE,server=FALSE, open="r+")
    red<-as.matrix(ids_matrix);  
    bb<-paste(red,collapse=';')

    #name_group<-readline(prompt = "Introduzca nombre de grupo:  ")
    #number_color_red<-readline(prompt = "Introduzca número de color rojo:  ")
    #number_color_green<-readline(prompt = "Introduzca número de color verde:  ")
    #number_color_blue<-readline(prompt = "Introduzca número de color azul:  ")
    # 
    # # for (i in 1:
    # # 
    # # number_color_red<-color_grg
    # 
    # 
    # 
    cc<-paste(name_group,number_color_red,number_color_green,number_color_blue,bb,sep='&')

    writeLines(cc,con)
    # 
    
    
    #writeLines("B13",con)
    #data <- readLines(con, 1)
    #print(data)
    


    # if(tolower(sendme)=="q"){
    #   break
    # }
    # write_resp <- writeLines(sendme, con)
    # server_resp <- readLines(con, 1)
    # print(paste("Your upper cased text:  ", server_resp))
    close(con)
    output<-list(valor+1,number_color_red+1)
    return(output)
  
}

#rcliente(1)
