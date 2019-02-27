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

dbscan_GUI<-function(Y,indexes,epsilon,minpoints)
  
{## find suitable eps parameter using a k-NN plot for k = dim + 1
  ## Look for the knee!
  kNNdistplot(Y[,indexes[1:3]], k = 5)
  abline(h=.08, col = "red", lty=2)
  
  res <- dbscan(Y_scaledg[,indexes[1:3]], eps = epsilon, minPts = minpoints)
  res
  
 # pairs(Y_scaledg[,indexes[1:3]], col = res$cluster + 1L)
  
  return(res)
}
