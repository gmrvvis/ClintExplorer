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

cluster_mean_statistics_GUI<-function(N_FEAT,NCLUS,datg,color_grg,spineClusterdg,cluster_method)

{

#There is an input parameter "cluster_method", necessary because in dbscan there will be 
#samples which are not assigned to any cluster. These samples will be also considered and
#represented, with black color and "No cluster" label


#No normalizo la matriz, porque para los promedios y para la representacion esquematica de la espina necesito la informacion
#sin normalizar

#Features
features_list<-c("Spine.Area","Spine.Length",
                 "Spine.Max.Diameter","Spine.Mean.Diameter",
                 "Spine.Neck.Length",
                 "Spine.Neck.Max.Diameter","Spine.Neck.Mean.Diameter",
                 "Spine.Neck.Volume",
                 "Spine.Position.X","Spine.Position.Y","Spine.Position.Z",
                 "Spine.Resistance","Spine.Straightness",
                 "Spine.Volume","Membrane.Potential.Peak")

#PARAMETRO DE ENTRADA
#N_FEAT=3

#Build axis labels
List <- list()
for(i in 1:NCLUS)
{
  List[[i]]<-paste("Cluster",i)
}
axis_labels<-do.call(cbind,List)


grupo<-matrix(0,NCLUS,dim(datg)[1])
for (i in 1:NCLUS)
{
  grupo[i,]<-c(which(spineClusterdg==i),matrix(0,1,dim(datg)[1]-length(which(spineClusterdg==i))))
  pp<-aggregate(datg,by=list(spineClusterdg),FUN=mean)
}

#kruskal.test(Spine.Area ~ spineClusterdg, data = datg)

#Loop to represent bar chart with the means for the different clusters (each bar with the corresponding color of the cluster)
#NCLUS=3
color_clusters=matrix(0,1,NCLUS)

for (i in 1:NCLUS)
{
  color_clusters[i]=rgb(color_grg[i,1],color_grg[i,2],color_grg[i,3],maxColorValue = 255)
  
}


#These 2 lines allow to evaluate the value of a single column of the dataset with name features_list[N_FEAT] 

cinstr2<-paste('pp$',features_list[N_FEAT],sep='')
ppp<-eval(parse(text=cinstr2))


max_graf<-max(ppp)

x11()

if(cluster_method=="dbscan")
{
  xx<-barplot(ppp,col=c("black",color_clusters),ylim=c(0, max_graf+0.5*max_graf))
  title(features_list[N_FEAT])
  axis(side=1,at=seq(1,NCLUS+1,1),labels=c("No cluster",axis_labels))
}
else
{
  xx<-barplot(ppp,col=color_clusters,ylim=c(0, max_graf+0.5*max_graf))
  title(features_list[N_FEAT])
  axis(side=1,at=seq(1,NCLUS,1),labels=axis_labels)  
}




#Concatenar 2 datasets
#dat_grupo_total<-rbind(dat_grupo1,dat_grupo2)

#cc<-kruskal.test(Spine.Area ~ cluster_label, data = dat_grupo_total)



#ACTUALIZACION 13/6/2017:
#HE COMPROBADO QUE EL TEST DE TUKEY REQUIERE NORMALIDAD, ASI QUE EN SU LUGAR VOY A USAR EL DE DUNN, QUE INCLUYE KRUSKAL-WALLIS
#CON LA CORRECCION PARA MULTIPLES COMPARACIONES
#Realizar el test de Tukey para comparaciones multiples, em este caso compara el Spine.Area de los 3 clusters
# bb<-aov(Spine.Area ~ spineClusterdg,datg)
# res_tuk<-TukeyHSD(bb)

ii<-paste(features_list[N_FEAT],"~spineClusterdg")
#Test de Dunn
res_dun<-dunnTest(as.formula(ii), data = datg)



#Para anadir lineas con asteriscos de significancia al barplot
#P < 0.05 *
#P < 0.01 **
#P < 0.001 ***


i<-1
ymax_old<-0

for (i in 1:length(res_dun))  #Number of comparisons
{
  if(res_dun$res$P.adj[i] < 0.001)  
  {
    cat("He entrado")
    bar_ini<-strtoi(substr(res_dun$res$Comparison[i],1,1))
    bar_fin<-strtoi(substr(res_dun$res$Comparison[i],5,5))
    
    #In dbscan, samples not assigned to any cluster are labeled with a 0, but are 
    #considered as a group. When making the comparison between groups with Dunn Test
    #bar_ini and bar_fin will return the first and the second group that are compared.
    #Therefore, in the case of the 0 group, bar_ini will be 0, so I need to adjust this
    #because otherwise ppp[bar_ini] could not be computed. The group labelled as 1 is 
    #actually the column 2 in "ppp" variable, so I just need to add 1 to adjust this.
    
    if(cluster_method=="dbscan")
    {
      bar_ini=bar_ini+1
      bar_fin=bar_fin+1
    }
      
    if(bar_ini>bar_fin)
    {
      bar_ini_aux<-bar_fin
      bar_fin<-bar_ini
      bar_ini<-bar_ini_aux
    }
    ymax_new<-max(ppp[bar_ini],ppp[bar_fin])
    
    if(ymax_new>ymax_old)
    {
      ymax<-ymax_new
    }
    else
    {
      ymax<-ymax_old+0.075*max_graf
    }
    ymax_old<-ymax
    
    segments(xx[bar_ini],ymax+0.05*max_graf,xx[bar_fin],ymax+0.05*max_graf)
    midpointx<-(xx[bar_ini]+xx[bar_fin])/2
    text('***',x=midpointx,y=ymax+0.075*max_graf)
    
  }
  else if((res_dun$res$P.adj[i] < 0.01))
  {
    cat("He entrado")
    bar_ini<-strtoi(substr(res_dun$res$Comparison[i],1,1))
    bar_fin<-strtoi(substr(res_dun$res$Comparison[i],5,5))
    
    if(cluster_method=="dbscan")
    {
      bar_ini=bar_ini+1
      bar_fin=bar_fin+1
    }
    
    if(bar_ini>bar_fin)
    {
      bar_ini_aux<-bar_fin
      bar_fin<-bar_ini
      bar_ini<-bar_ini_aux
    }
    ymax_new<-max(ppp[bar_ini],ppp[bar_fin])
    
    if(ymax_new>ymax_old)
    {
      ymax<-ymax_new
    }
    else
    {
      ymax<-ymax_old+0.075*max_graf
    }
    ymax_old<-ymax
    
    segments(xx[bar_ini],ymax+0.05*max_graf,xx[bar_fin],ymax+0.05*max_graf)
    midpointx<-(xx[bar_ini]+xx[bar_fin])/2
    text('**',x=midpointx,y=ymax+0.075*max_graf)
  }
  
  else if((res_dun$res$P.adj[i] < 0.05))
  {
    cat("He entrado")
    bar_ini<-strtoi(substr(res_dun$res$Comparison[i],1,1))
    bar_fin<-strtoi(substr(res_dun$res$Comparison[i],5,5))
    if(bar_ini>bar_fin)
    {
      bar_ini_aux<-bar_fin
      bar_fin<-bar_ini
      bar_ini<-bar_ini_aux
    }
    if(cluster_method=="dbscan")
    {
      bar_ini=bar_ini+1
      bar_fin=bar_fin+1
    }
    ymax_new<-max(ppp[bar_ini],ppp[bar_fin])
    
    if(ymax_new>ymax_old)
    {
      ymax<-ymax_new
    }
    else
    {
      ymax<-ymax_old+0.075*max_graf
    }
    ymax_old<-ymax
    
    segments(xx[bar_ini],ymax+0.05*max_graf,xx[bar_fin],ymax+0.05*max_graf)
    midpointx<-(xx[bar_ini]+xx[bar_fin])/2
    text('*',x=midpointx,y=ymax+0.075*max_graf)
  }  
  
}


#This loop computes the homogeneity of a feature given by N_FEAT within a determined cluster, in this case grupo1


# Yscaledg1<-as.data.frame(Y_scaledg[grupo1,])
# cinstr3<-paste('Yscaledg1$',features_list[N_FEAT],sep='')
# ppp3<-eval(parse(text=cinstr3))
# var_feat_cluster1=var(ppp3)
# hom1<-1/var_feat_cluster1

return(pp)

}
