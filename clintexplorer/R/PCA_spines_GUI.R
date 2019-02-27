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

PCA_spines_GUI<-function(Y_scaled,indexes)
{  

#To compare with shuffled data
Y_new_lab=shuffle_matrix(Y_scaled)


Y_scaled_PCA <- princomp(Y_scaled[,indexes])

#plot(Y_scaled_PCA, type = "l")

g <- ggbiplot(Y_scaled_PCA, obs.scale = 1, var.scale = 1,var.axes=FALSE)



output<-list(g,Y_scaled_PCA$loadings[,1:3])

return(output)


}



