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

server_prueba<-function()
  
{

con <- socketConnection(host="localhost", port = 31400, blocking=FALSE,server=TRUE, open="r+")
# 
assign("socket_con",con , envir = .GlobalEnv)


########INTRODUCIR AQUÍ LA RUTA DEL FICHERO#########


#datg<- read.csv("/home/user/data/m16 cing 1 9basales SpineRet3_mod.csv", header = TRUE)  ##--> ESPINAS
datg<- read.csv("/home/user/data/dataset_sinapsis1800_con_centroides.csv", header = TRUE) ##-->SINAPSIS


Y<-as.matrix(datg)

# for (i in 1:nrow(datg))
# {
#   
#   write(datg[i,],con)
# }

#write.csv(datg,con,row.names=FALSE)


####INTRODUCIR AQUÍ EL NÚMERO DE FILAS DEL CSV########

#ESPINAS
#writeLines("4456",con)  #We send "file" command to ClintExplorer. If there
#is a file, "rserver" will receive such file. If there is no file, "rserver"
#will receive a "nofile" command.

#SINAPSIS
writeLines("1800",con)  #We send "file" command to ClintExplorer. If there
#is a file, "rserver" will receive such file. If there is no file, "rserver"
#will receive a "nofile" command.

write.csv(datg,con,row.names=FALSE)

}