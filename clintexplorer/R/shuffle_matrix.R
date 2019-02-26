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

shuffle_matrix<-function(Y)
{
  #It generates a new matrix with shuffle data from Y, except the first 
  #column, which is the Spine ID

Y_new=Y[,2:ncol(Y)]

Y_new<- Y_new[sample(nrow(Y_new)),sample(ncol(Y_new))]
Y_new_labeled=matrix(0,nrow(Y),ncol(Y))
Y_new_labeled[,1]=Y[,1]
Y_new_labeled[,2:ncol(Y)]=Y_new
return(Y_new_labeled)
}