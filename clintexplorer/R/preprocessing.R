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

preprocessing<-function(Y,geometrical)
{
  out7<-character()
  out8<-character()
  outliers_columns<-matrix(0,ncol(Y))
  u<-1  #Index for columns
  q<-0 #Index for number of outliers
  SDLIMIT<-6  ###ACCORDING TO THE CURRENT CONFIGURATION, A SAMPLE IS CONSIDERED AS OUTLIER WHEN IT IS BEYOND
  ##6 STANDARD DEVIATIONS FROM THE MEAN
  List3<-list()
  
#This function detect NaNs

l<-length(which(is.nan(Y)==TRUE))

if(l>0)
{
  az<-which(is.nan(Y)==TRUE,arr.ind=TRUE)
  out8<-paste("There are ",as.character(l)," NaN at rows ",as.character(az[,1]))
}

  
#This function removes the outliers of the dataset

  # for (i in 1:nrow(Y))
  # {
  #   if(Y[i,8]>8)   #Spine length
  #   {
  #     Y[i,8]=8
  #   }
  # 
  #   if(Y[i,17]<0)  #Orientation angle
  #   {
  #     Y[i,17]=360-abs(Y[i,17])
  #   }
  #   if(Y[i,18]>1100)  #Position X
  #   {
  #     Y[i,18]=700
  #   }
  #   if(Y[i,18]<(-1100))
  #   {
  #     Y[i,18]=-1100
  #   }
  #   if(Y[i,19]>1100)  #Position Y
  #   {
  #     Y[i,19]=1100
  #   }
  #   if(Y[i,19]<(-1100))
  #   {
  #     Y[i,19]=-1100
  #   }
  #   if(Y[i,20]>1100)   #Position Z
  #   {
  #     Y[i,20]=80
  #   }
  #   if(Y[i,20]<(-1100))
  #   {
  #     Y[i,20]=-30
  #   }
  #   if(Y[i,21]>100)   #Spine resistance
  #   {
  #     Y[i,21]=100
  #   }
  # 
  # }
  
  
  
  ################################################
  ###ESTO ES PARA LOS DATOS DE SINAPSIS####
  
  # for (i in 1:nrow(Y))
  # {
  #   if(Y[i,12]>12400)   #MPH X Centroid
  #   {
  #     Y[i,12]=12400
  #   }
  # 
  #   if(Y[i,13]>9200)  #MPH Y Centroid
  #   {
  #     Y[i,13]=9200
  #   }
  #   if(Y[i,14]>7530)  #MPH Z Centroid
  #   {
  #     Y[i,14]=7530
  #   }
  # 
  # }
  
  
  ################################################
  ###ESTO ES GENÉRICO PARA CUALQUIER DATASET####
  
  for (j in 2:ncol(Y))
  {

    zvalues<-scores(Y[,j],type="z")
    aa<-which(abs(zvalues)>SDLIMIT)  ##ACCORDING TO THE CURRENT CONFIGURATION, A SAMPLE IS CONSIDERED AS OUTLIER WHEN IT IS BEYOND
                               ##6 STANDARD DEVIATIONS FROM THE MEAN
    #aa contains the index of the outliers
    
    if(length(aa)>0)  #If there are outliers
    {
      out7<-paste(out7,"There are ",as.character(length(aa))," outliers for feature ",colnames(Y)[j],".")
      outliers_columns[u]<-j
      u<-u+1
      for (k in 1:length(aa))
      {
        q<-q+1
        List3[[q]]=aa[k]
        
      }
    

      
    }

  }

outliers=do.call(cbind,List3)

outliers<-outliers[!duplicated(t(outliers))]  #This line removes duplicated values
#Remove rows with outliers
Y_nueva<-Y[-outliers,]
output<-list(Y_nueva,out7,outliers_columns,u,outliers)

return(output)
  
  
}