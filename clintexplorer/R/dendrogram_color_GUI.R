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

dendrogram_color_GUI<-function(Y,N_CLUSTERS)
{

Y_scaled<-Y
#PARAMETERS

N_SPINES=nrow(Y_scaled)


set.seed(3)
dist1.res <- dist(Y_scaled[1:N_SPINES,2:ncol(Y_scaled)], method = "euclidean")


hc1 <- hclust(dist1.res, method = "average")
ncluster_vector1<-cutree(hc1,k=N_CLUSTERS)


plot(hc1,hang=-1,labels=Y_scaled[1:N_SPINES,1])
nn1<-rect.hclust(hc1, k = N_CLUSTERS,border = 2:4)
g<-recordPlot()


#Calculate clustering statistics
clstats1<-cluster.stats(dist1.res,ncluster_vector1)

clust_quality1=clstats1$wb.ratio*100

output<-list(g,clust_quality1,ncluster_vector1)
return(output)
}



