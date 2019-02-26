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

kmeans_3D_GUI<-function(Y,indexes,n_clusters)
{


magnitudeX<-indexes[1]
magnitudeY<-indexes[2]
magnitudeZ<-indexes[3]

  
#To compare with shuffled data
#Y_new_lab=shuffle_matrix(Y_scaled)

column_Yscaled_labels<-colnames(Y)

Y_scaled<-Y[,indexes[1:n_clusters]]

# Determine number of clusters. It tries with 1 to 15 clusters and plot the 
#wss for each number of clusters
wss <- (nrow(Y)-1)*sum(apply(Y_scaled,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(Y_scaled,centers=i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")


#Data clustering
set.seed(20)

spineCluster <- kmeans(Y_scaled, n_clusters, nstart = 20)


spineCluster$cluster <- as.factor(spineCluster$cluster)
cluster_vector<-spineCluster$cluster


#Analyze the characteristics of the performed clustering
# get cluster means
aggregate(Y_scaled,by=list(spineCluster$cluster),FUN=mean)

# It adds a column with the cluster assignment to the dataset
# dat1 <- data.frame(dat, spineCluster$cluster) 
# assign("dat1g",dat1, envir = .GlobalEnv)


#Get clustering separation
percentage_qual=(spineCluster$betweenss/spineCluster$totss)*100

output<-list(percentage_qual,cluster_vector,wss)


return(output)

}
