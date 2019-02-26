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

spine_reprentation<-function(pp,n_clustersg,colores,cluster_method)
{

#To plot the representation of the average morphology of spines for each cluster
  
#There is an input parameter "cluster_method", necessary because in dbscan there will be 
#samples which are not assigned to any cluster. These samples will be also considered and
#represented, with black color and "No cluster" label
  

#Firstly we build an empty plot, defining the x and y limits
x11()
emptyplot(c(0, 3), c(-1, 8))

#Then, we will add geometric objects to the empty ploy


List2<- list()

#PARAMETERS

List <- list()
for(i in 1:n_clustersg)
{
  List[[i]] <- 0
  List2[[i]]<-paste("Cluster",i)
}
axis_labels<-do.call(cbind,List2)
Xmid = do.call(cbind, List)
Ymid<-Xmid
STPD<-Xmid
SL<-Xmid
NL<-Xmid
SAPD<-Xmid
SNMD<-Xmid

if(cluster_method=="dbscan")
{
  n_clustersg=n_clustersg+1
  colores=c("black",rgb2hex(colores))
}


for (i in 1:n_clustersg)
{
  Xmid[i]=2*i-2
  Ymid[i]=0
  #STPD=datg[i,23]
  STPD[i]=pp[i,24]
  #SL=datg[i,8]
  SL[i]=pp[i,9]
  
  NL[i]=SL[i]-2*STPD[i]
  
  #SAPD=datg[i,3]
  SAPD[i]=pp[i,4]
  
  #SNMD=datg[i,14]
  SNMD[i]=pp[i,15]
  
  if(cluster_method=="dbscan")
  {
    filledcylinder(rx = 0, ry = (NL[i]/2)/2, len = SNMD[i],col = colores[i], mid = c(Xmid[i], Ymid[i]))
    filledcircle(STPD[i],0,col = colores[i], mid = c(Xmid[i], Ymid[i]+NL[i]/4+STPD[i]))
    polygon(c(Xmid[i]-SNMD[i]/2,Xmid[i]-SAPD[i]/2,Xmid[i]+SAPD[i]/2,Xmid[i]+SNMD[i]/2),c(Ymid[i]-NL[i]/4,Ymid[i]-(3/4)*NL[i],Ymid[i]-(3/4)*NL[i],Ymid[i]-NL[i]/4),border=colores[i],fillOddEven=TRUE,col=colores[i])
    
  }
  else
  {
    filledcylinder(rx = 0, ry = (NL[i]/2)/2, len = SNMD[i],col = rgb2hex(colores[i,]), mid = c(Xmid[i], Ymid[i]))
    filledcircle(STPD[i],0,col = rgb2hex(colores[i,]), mid = c(Xmid[i], Ymid[i]+NL[i]/4+STPD[i]))
    polygon(c(Xmid[i]-SNMD[i]/2,Xmid[i]-SAPD[i]/2,Xmid[i]+SAPD[i]/2,Xmid[i]+SNMD[i]/2),c(Ymid[i]-NL[i]/4,Ymid[i]-(3/4)*NL[i],Ymid[i]-(3/4)*NL[i],Ymid[i]-NL[i]/4),border=rgb2hex(colores[i,]),fillOddEven=TRUE,col=rgb2hex(colores[i,]))
    
  }
  #ry es el radio vertical, asi que el diametro va ser el doble del valor que tenga ry

  
  title("Spine shape")
  
  
}

if(cluster_method=="dbscan")
{
  axis(side=1,at=Xmid,labels=c("No cluster",axis_labels))
}
else
{
  axis(side=1,at=Xmid,labels=axis_labels)
}



}