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

scale_spinematrix_columns<-function(Y)
  #Y is the matrix directly converted from the dataset, with all the columns
  #It returns a new matrix, with the columns already normalized, including 
  #only those columns specified in the subset "datos_buenos", 
  #represents the valuable data

{
  
# cont_feat=c(2:4, 8:17,21:25 ,28, 29) #indexes of continuous features
# #I remove position features, I think that this information should not be 
# #considered to cluster
# 
# cont_feat_new=c(1,2,4,8,10,12,14,16,17,21,22,24,28) #this is a new set of 
# #features in which there are not any discrete value. It include also the 
# #spineID column
# 
#datos_normalizables=c(2,8:10,12:14,16,18:22,28,29)#estos son los datos que se pueden normalizar,
#porque son continuos. ESTOS SON PARA EL DATASET DE ESPINAS

 datos_normalizables=c(2:7,9:14)#estos son los datos que se pueden normalizar,
#porque son continuos. ESTOS SON PARA EL DATASET DE SINAPSIS 


#Scale data

Ynueva=Y

for (i in 1:ncol(Y)) 
  {
  a<-match(i,datos_normalizables,nomatch=0)
  if(a!=0)  #Si el valor de i está dentro de datos_normalizables, entonces normalizamos, si no, mantiene el valor que tenía en Y
  {
    intervalo=max(Y[,i])-min(Y[,i])
    Ynueva[,i]<-as.matrix((Y[,i]-min(Y[,i]))/intervalo)
  }


}


return(Ynueva)


}
