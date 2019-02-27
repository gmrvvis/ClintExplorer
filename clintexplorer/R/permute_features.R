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

permute_features<-function(Y_scaledg,N_feature)
{
#From Y_scaledg matrix, randomly permute values from the selected feature
  #I need Y_scaledg matrix because it has to be normalized
  
  
  
  #Features
  features_list<-c("Spine.Area","Spine.Length",
                   "Spine.Max.Diameter","Spine.Mean.Diameter",
                   "Spine.Neck.Length",
                   "Spine.Neck.Max.Diameter","Spine.Neck.Mean.Diameter",
                   "Spine.Neck.Volume",
                   "Spine.Position.X","Spine.Position.Y","Spine.Position.Z",
                   "Spine.Resistance","Spine.Straightness",
                   "Spine.Volume","Membrane.Potential.Peak")
  
  # cinstr2<-paste('datg$',features_list[N_feature],sep='')
  # pep<-eval(parse(text=cinstr2))
  # return(pep)
  
  de<-sample(nrow(Y_scaledg))
  Y_new<-matrix(0,nrow(Y_scaledg),1)
  Y_new<-Y_scaledg[de,N_feature]
  Y_scaledg_new<-matrix(0,nrow(Y_scaledg),ncol(Y_scaledg))
  Y_scaledg_new<-Y_scaledg
  Y_scaledg_new[,N_feature]<-Y_new
  return(Y_scaledg_new)
  
}
  


