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

source('./preprocessing.R')

datg<- read.csv("/home/user/data/m16 cing 1 9basales SpineRet3_mod.csv", header = TRUE)
Yg<-data.matrix(datg, rownames.force = NA)

Y_nueva<-preprocessing(Yg,"Yes")

spines_level1<-c(which(datg$Spine.Branch.Level==1,matrix(0,1,dim(datg)[1]-length(which(datg$Spine.Branch.Level==1)))))
plot3d(Y_nueva[,18], Y_nueva[,19], Y_nueva[,20], pch = ".", col = as.factor(as.numeric(datg$Spine.Branch.Level)+1), bty = "f", cex = 2, colkey = FALSE)

        
