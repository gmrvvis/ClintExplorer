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
 
library(shiny)
library(ggbiplot)
library(plot3D)
library(ggplot2)
library(rgl)
library(imager)
library(devtools)
library(GMD)
library(fpc)
library(idendr0)
library(Hmisc)
library(spatstat) #To use nndist
library(dbscan) 
library(FSA)
library(shinyjs)
library(shape)
library(dunn.test)
library(outliers)
library(plotly)


source('./PCA_spines_GUI.R')
source('./dendrogram_color_GUI.R')
source('./preprocessing.R')
source('./scale_spinematrix_columns.R')
source('./shuffle_matrix.R')
source('./kmeans_3D_GUI.R')
source('./dbscan_GUI.R')
source('./rcliente.R')
source('./rclientfile.R')
source('./rserver.R')
source('./permute_features.R')
source('./cluster_mean_statistics_GUI.R')
source('./spine_reprentation.R')

#Client connection to request for files
#We open a client to send "file" command to ClintExplorer. If there
#is a file, "rclientfile" will receive such file preceded by its number of rows. 
#If there is no file, "rclientfile" will receive a "nofile" command.
clientfile_request<-rclientfile(31400)

assign("clintexplorer_responseg",clientfile_request[[1]] , envir = .GlobalEnv)
assign("clintexplorer_fileg",clientfile_request[[2]] , envir = .GlobalEnv)

#server_output<-rserver(31400) #Server stays listening

#con<-rclient(1)

## Only run examples in interactive R sessions


ui <-fluidPage( 
  useShinyjs(),
  pageWithSidebar(
  
  # Application title
  headerPanel("CLINT"),
  
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the br()
  # element to introduce extra vertical spacing
  sidebarPanel(
    imageOutput("logo"),

    textOutput("text"),
  
    # checkboxGroupInput("check","2.Select features:",c("Spine.Area","Spine.Length",
    #                                                   "Spine.Max.Diameter","Spine.Mean.Diameter",
    #                                                   "Spine.Neck.Length",
    #                                                   "Spine.Neck.Max.Diameter","Spine.Neck.Mean.Diameter",
    #                                                   "Spine.Neck.Volume",
    #                                                   "Spine.Position.X","Spine.Position.Y","Spine.Position.Z",
    #                                                   "Spine.Resistance","Spine.Straightness",
    #                                                   "Spine.Volume","Membrane.Potential.Peak")),
    

    uiOutput("select_features"),
    
    br(),
    actionButton("exit_but","Exit")
    
  ),
  
  # Show a tabset that includes a plot, summary, and table view
  # of the generated distribution
  mainPanel(
    tabsetPanel(
      tabPanel("File",    fileInput("file1", "Choose CSV file",
                                    accept = c(
                                      "text/csv",
                                      "text/comma-separated-values,text/plain",
                                      ".csv")),
               tags$hr(),
               checkboxInput("header", "Header", TRUE),
               selectInput("geometrical","Do you need neuron geometry?",c("Yes","No"))
 
      ),
  

      tabPanel("Preprocessing",actionButton("load_but",'1.Load dataset'),
               actionButton("prepro_but","2.Pre-processing"),
               actionButton("norm_but","3.Normalize"),plotlyOutput("plot6")),
      tabPanel("Exploratory Analysis", actionButton("dim_but","Explore PCA and correlations"), tableOutput("weights_PCA"), 
               plotlyOutput("plot"),plotOutput("plot2"),sliderInput("corr","Absolute value of correlation",min=0,max=1,value=0.5,round=FALSE,step=0.05,width='30%')), 
      tabPanel("Clustering",selectInput("select_cl","Choose method:",c("K-means","Hierarchical","Interactive Hierarchical","dbscan")),
               numericInput("nclus","Enter number of groups",3),numericInput("epsilon","Enter epsilon (distance between points to be considered part of the same cluster)",0.1),
               numericInput("minpoints","Enter minimum number of neighbours to be part of a cluster",8),actionButton("show_elbow","Show elbow diagram"),
               actionButton("clust_but","Start process"),actionButton("save_but","Save configuration"),actionButton("scatterplots","Visualize scatterplots"),plotOutput("plot3"),plotOutput("plot4")),
               
      tabPanel("Compare results",     actionButton("compare_config","Compare configurations"),
               actionButton("send_data","Send data"),actionButton("cluster_mean_stats","Cluster statistics"),numericInput("nfeat","Enter number of feature",3),
               textOutput("text2"),tableOutput("cluster_configurations"),plotOutput("plot5"))
    )
  )
))#End of page




server <- function(input, output,session) {
  
  hide("scatterplots")

 
  datalist_cluster_configs<-list(Name="kmeans1",Number_of_clusters=integer(),Features="length")

  
  assign("datalist_cluster_configsg",datalist_cluster_configs , envir = .GlobalEnv)
  
  
  # output$logo<-renderPlot({
  #   
  #   im<-load.image("~/clint3.jpeg")
  #   
  #   plot(im,axes=FALSE,xlab="",ylab="")
  #   
  #   
  #   
  #   # 
  # })
  
  
  observeEvent(input$load_but, {
    
    if(clintexplorer_responseg!="nofile")  #There is a file,so we will read the file from the socket
    {
      #read file from the socket 
      dat<-read.csv(text = paste0(clintexplorer_fileg, collapse = "\n"), header=TRUE)
      assign("datg",dat,envir = .GlobalEnv)
      
    }
    else
    {
      inFile <- input$file1
      
      if (is.null(inFile))
        return(NULL)
      
      dat<-read.csv(inFile$datapath, header = input$header)
      assign("datg",dat,envir = .GlobalEnv)
      
    }
   
    Y<-data.matrix(datg, rownames.force = NA)
    assign("Yg",Y, envir = .GlobalEnv)
    output$text<-renderText({print("Correct selection of CSV file")})
    
    
    #Definition of the input checkbox, by reading column names
    
    checkbox_names<-names(datg)

    output$select_features<-renderUI({

      checkboxGroupInput("check","4.Select features:",choices=checkbox_names)

 })
#     
    
    
    
    #Initialization of a global counter to measure the number of clusterings performed for each dataset,to later save it
    
    index_clusters=1
    assign("index_clustersg",index_clusters, envir = .GlobalEnv)
    
    
  })#End of load_but observe_event
  
  
  observeEvent(input$prepro_but, {
    prepro_output<-preprocessing(Yg,input$geometrical)
    Y_nueva<-prepro_output[[1]]
    assign("Y_nuevag",Y_nueva , envir = .GlobalEnv)
    
    #Y_nuevag is the output of "preprocessing function", therefore it is the data without outliers
    
    datg_filt<-as.data.frame(Y_nueva)
    assign("datg_filtg",datg_filt, envir = .GlobalEnv)
    number_of_columns_with_outliers<-prepro_output[[4]]-1
    all_columns<-prepro_output[[3]]
    outliers_columns<-all_columns[1:number_of_columns_with_outliers]
    
    outliers<-prepro_output[[5]]
    assign("outliersg",outliers, envir = .GlobalEnv)
    
    
    #Transform number of columns with outliers returned by "preprocessing" in feature_names
    features<-colnames(Y_nuevag)

    showModal(modalDialog(title = prepro_output[[2]],
                          "Which feature do you want to visualize?",
                          checkboxGroupInput("feat_outliers","Select ONLY ONE feature:",choices=features[outliers_columns]),
                          footer = tagList(
                            modalButton("Cancel"),
                            actionButton("ok_but2", "OK")
                          )
    ))
    

  })
  observeEvent(input$norm_but, {
    list3<-list()
    j<-1
    
    #Block to show a modal dialog to ask the user whether to remove outliers or not
    
    showModal(modalDialog(title = "Outliers message",
                          "Do you want to remove outliers? ",
                      
                          footer = tagList(
                            modalButton("Yes"),
                            actionButton("no_but", "No")
                          )
    ))
    
    #Perform normality test
    for (i in 2:ncol(Y_nuevag))
    {
      ee<-ks.test(Y_nuevag[,i],"pnorm",mean(Y_nuevag[,i]),sd(Y_nuevag[,i])) 
      if(ee$p.value>0.01)  #This means that this column will not be normal
      {
         list3[[j]]<-i
         j<-j+1
      }
      
    }
    features_not_normal=do.call(cbind,list3)
    
    
    Y_scaled<-scale_spinematrix_columns(Y_nuevag)
    assign("Y_scaledg",Y_scaled , envir = .GlobalEnv)
    
    if(j==1)
    {
      out8<-"All features are normally distributed. Correct normalization"
    }
    else
    {
      out8<-paste("There are ",as.character(j-1)," features not normally distributed: ",colnames(Y_scaledg)[features_not_normal],".")
    }
    
    
    output$text<-renderText({print(out8)})
    
    ss<-matrix(0,ncol(Yg),ncol(Yg))
    corr_mask<-matrix(1,ncol(Yg),ncol(Yg))
    assign("ssg",ss , envir = .GlobalEnv)
    assign("corr_maskg",corr_mask , envir = .GlobalEnv)
    
  })
  #Save configuration
  observeEvent(input$save_but, {
    filename1<-paste(method_clus_nameg,index_clustersg)
    filename2<-paste(method_clus_nameg,index_clustersg,"clus_qualityg")
    filename3<-paste(method_clus_nameg,index_clustersg,"clus_colorg")
    filename4<-paste(method_clus_nameg,index_clustersg,"clus_features")
    save(spineClusterdg,file=filename1)
    save(clus_qualityg,file=filename2)
    save(color_grg,file=filename3)
    save(choiceg,file=filename4)
    
    datalist_cluster_configsg$Name[index_clustersg]=filename1
    datalist_cluster_configsg$Number_of_clusters[index_clustersg]=n_clustersg
    datalist_cluster_configsg$Features[index_clustersg]=paste(choiceg,collapse=',')

    
    index_clustersg=index_clustersg+1
    assign("index_clustersg",index_clustersg , envir = .GlobalEnv)
    assign("datalist_cluster_configsg",datalist_cluster_configsg , envir = .GlobalEnv)
    
    
    output$text2<-renderText({print("SAVED CLUSTERING CONFIGURATIONS")})
    output$cluster_configurations<-renderTable({datalist_cluster_configsg},rownames=TRUE)
    
    #Send group
    #writeLines("B14",socket_con)
    
    
    #source('~/rclient.R')
    output$text<-renderText({
      print("Correct saving") })
  })
  
  
  observeEvent(input$compare_config, {
    
    clus_qual=matrix(0,20)  #Admite hasta 20 configs
    for  (i in 1:(index_clustersg-1))
    {
      
      filename2<-paste(datalist_cluster_configsg$Name[i],"clus_qualityg")
      load(filename2)
      clus_qual[i]=clus_qualityg
    }
    
    output$plot5 <- renderPlot({
      print(barplot(clus_qual[1:index_clustersg]))
      axis(side=1,at=seq(1,index_clustersg-1,1),labels=datalist_cluster_configsg$Name)
      })
    
  })
  
  
  #Show cluster mean statistics
  observeEvent(input$cluster_mean_stats, {
    
    
    pp<-cluster_mean_statistics_GUI(input$nfeat,n_clustersg,datg_filtg,color_grg,spineClusterdg,input$select_cl)
    
    spine_reprentation(pp,n_clustersg,color_grg,input$select_cl)

    
  })
  
  
  
  
  #Send group
  observeEvent(input$send_data, {
    
    
    #source('~/rclient.R')
    # for (i in 1:datalist_cluster_configsg$Number_of_clusters[index_clustersg])
    # {
    #   aa<-col2rgb(curr_colors[i])
    #   color_gr[i,1]=aa[1]   #Red value
    #   color_gr[i,2]=aa[2]  #Green value
    #   color_gr[i,3]=aa[3]  #Blue value
    #   rm(aa)
    #   
    # }
    
    for(i in 1:n_clustersg)
    {  
      grupo<-which(spineClusterdg==i)
      dat_grupo<-datg[grupo,]
     
    
      valor_ret<-rcliente(1,dat_grupo[,1],paste(datalist_cluster_configsg$Name[index_clustersg-1],"_cluster",i),color_grg[i,1],color_grg[i,2],color_grg[i,3])
  
      out6<-paste("Devuelve",as.character(valor_ret[[2]]))
      output$text<-renderText({
      print(out6) })
    }

    
    output$text<-renderText({
      print("Correct sending") })
  })
  
  
  
  
  generate_corr_filtered<-reactive({
    
    abs((ssg>=input$corr)*ssg)
    
  })
  
  
  
  #PCA Analysis
  observeEvent(input$dim_but, {
    #features<-colnames(Y_scaledg)  

    #features contain the column names of Y_scaledg, therefore it is included the Spine_id, so 
    #for the first feature(Spine-Area), indexes_choices will contain 2, for example
    
    
    
    
    #It is necessary to update indexes_choices every time the user clics on PCA button, in order to perform PCA with 
    #the new feature selection

    features<-colnames(Yg)    
    choice<-input$check
    indexes_choices<-matrix(0,ncol(Yg))
    
    for (i in 1:length(choice))
    {
      indexes_choices[i]<-match(choice[i],features)
    }
    assign("indexes_choicesg",indexes_choices , envir = .GlobalEnv)
    
    
    PCA_output<-PCA_spines_GUI(Y_scaledg,indexes_choicesg)
    

    output$weights_PCA<-renderTable({PCA_output[[2]]},rownames=TRUE)
    
    
    
    output$plot <- renderPlotly({
      ggplotly(PCA_output[[1]])})
    
    output$plot2<-renderPlot({
      #heatmap(generate_corr_filtered(),Rowv=NA,Colv=NA)
      par(mai=c(2.8,2.8,0.2,0.2))
      image(1-generate_corr_filtered(),col=rainbow(20),xaxt='n',yaxt='n',xaxs='r',yaxs='r')
      
      axis(side=1,at=seq(0,1,1/(ncol(Yg)-1)),labels=rownames(ssg),tick=FALSE,las=2, cex.axis=0.9)
      axis(side=2,at=seq(0,1,1/(ncol(Yg)-1)),labels=rownames(ssg),tick=FALSE,las=2, cex.axis=0.9)},
      width=600,height=600
      
      
    )
    cer<-dev.size("px")
    assign("cerg",cer,envir = .GlobalEnv)
    
    
    #Correlation Analysis
    ss<-rcorr(Y_scaledg[,1:ncol(Y_scaledg)], type="pearson") # type can be pearson or spearman
    assign("ssg",ss$r , envir = .GlobalEnv)
    

  })
  
  observeEvent(input$select_cl,{
    if(input$select_cl=="K-means")
    {
      show("show_elbow")
      hide("epsilon")
      hide("minpoints")
    }
    if(input$select_cl=="Hierarchical")
    {
      hide("show_elbow")
      hide("epsilon")
      hide("minpoints")
      
    }
    if(input$select_cl=="Interactive Hierarchical")
    {
      hide("show_elbow")
      hide("nclus")
      hide("epsilon")
      hide("minpoints")
    }
    if(input$select_cl=="dbscan")
    {
      hide("show_elbow")
      hide("nclus")
      show("epsilon")
      show("minpoints")
    }
    
    
    
  })
  
  #Clustering
  observeEvent(input$clust_but, {
    feat_relevance<-matrix(0,1,3)
    features<-colnames(Yg)    
    choice<-input$check
    assign("choiceg",choice , envir = .GlobalEnv)
    assign("n_clustersg",input$nclus , envir = .GlobalEnv)

    indexes_choices<-matrix(0,ncol(Yg))
    for (i in 1:length(choice))
    {
      indexes_choices[i]<-match(choice[i],features)
    }
    assign("indexes_choicesg",indexes_choices , envir = .GlobalEnv)

    if(input$select_cl=="K-means")
    {
      color_gr<-matrix(0,n_clustersg,3)  #Máximo 10 clusters
      assign("color_grg",color_gr, envir = .GlobalEnv)
      method_clus_name="K-means"
      assign("method_clus_nameg",method_clus_name , envir = .GlobalEnv)
      output_kmeans<-kmeans_3D_GUI(Y_scaledg,indexes_choicesg,input$nclus)
      spineClusterd<-output_kmeans[[2]]
      wss<-output_kmeans[[3]]
      assign("wssg",wss , envir = .GlobalEnv)
     
      assign("spineClusterdg",spineClusterd , envir = .GlobalEnv)
      assign("clus_qualityg",output_kmeans[[1]] , envir = .GlobalEnv)
        
      output$text<-renderText({
          out3<-paste("Cluster quality",as.character(output_kmeans[[1]]))
          print(out3)
        })
      
      column_Yscaled_labels=colnames(Y_scaledg)

      #If data are from spines, we will show a 3dplot with clusters in the 3d structure of the neuron, otherwise, scatterplots
      #2vs2 will be plotted
      
      if(input$geometrical=="Yes")
      {
        open3d()
        
        #PARA ESPINAS
        #plot3d(Y_scaledg[,18], Y_scaledg[,19], Y_scaledg[,20], pch = ".", col = as.factor(as.numeric(spineClusterd)+1), bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[18],ylab=column_Yscaled_labels[19],zlab=column_Yscaled_labels[20])
        
        #plot_ly(Y_scaledg[,18], Y_scaledg[,19], Y_scaledg[,20], pch = ".", col = as.factor(as.numeric(spineClusterd)+1), bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[18],ylab=column_Yscaled_labels[19],zlab=column_Yscaled_labels[20])
        
        
        #PARA SINAPSIS
        plot3d(Y_scaledg[,12], Y_scaledg[,13], Y_scaledg[,14], pch = ".", col = as.factor(as.numeric(spineClusterd)+1), bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[12],ylab=column_Yscaled_labels[13],zlab=column_Yscaled_labels[14])
        
      }
      else
      {
        show("scatterplots")
        showModal(modalDialog(title = "Important message",
                              "Select features to display",
                              checkboxGroupInput("feat_scatter","Select features:",choices=choiceg),
                              footer = tagList(
                                modalButton("Cancel"),
                                actionButton("ok_but", "OK")
                              )
                  ))
        
      }
      curr_colors<-palette()
      for (i in 1:input$nclus)
      {
        aa<-col2rgb(curr_colors[i+1])
        color_grg[i,1]=aa[1]   #Red value
        color_grg[i,2]=aa[2]  #Green value
        color_grg[i,3]=aa[3]  #Blue value
        rm(aa)
        
      }
      assign("color_grg",color_grg , envir = .GlobalEnv)
      
      #This section is to perform the same clustering but with shuffled data from the selected feature
      
      for (i in 1:length(choice))
      {
      
      Y_scaledg_new<-permute_features(Y_scaledg,indexes_choicesg[i])
      output_kmeans_new<-kmeans_3D_GUI(Y_scaledg_new,indexes_choicesg,input$nclus)
      spineClusterd_new<-output_kmeans_new[[2]]
      coincidences<-spineClusterd_new==spineClusterd
      num_coinc<-length(which(coincidences==TRUE))
      perc_coinc<-(num_coinc/length(spineClusterd))*100
      
      #The larger the number of coincidences, the lesser the importance of the feature in the clustering
      
      out4<-paste("Relevance [%]",as.character(100-perc_coinc))
      feat_relevance[i]<-100-perc_coinc
      output$text<-renderText({
        print(out4)
       })
      }
      output$plot4 <- renderPlot({print(barplot(feat_relevance,ylim=c(0,100),ylab="Relevance [%]"))
        axis(side=1,at=seq(1,length(choice),1),labels=choiceg)
        ("Feature relevance")
       
        })
      assign("n_clustersg",input$nclus, envir = .GlobalEnv)

      
      
      
    }#End of k-means loop
    
    
    
    if(input$select_cl=="Hierarchical")
    {
      color_gr<-matrix(0,n_clustersg,3)  #Máximo 10 clusters
      assign("color_grg",color_gr, envir = .GlobalEnv)
      method_clus_name="Hierarchical"
      assign("method_clus_nameg",method_clus_name , envir = .GlobalEnv)
      output_hierarchical<-dendrogram_color_GUI(Y_scaledg,input$nclus)
      output$plot4 <- renderPlot({output_hierarchical[[1]]})
      out3<-paste("Cluster quality",as.character(output_hierarchical[[2]]))
      cluster_vector<-output_hierarchical[[3]]
      column_Yscaled_labels=colnames(Y_scaledg)
      
      #Hide elbow button
      hide("show_elbow")

      if(input$geometrical=="Yes")
      {
        open3d()
        plot3d(Y_scaledg[,18], Y_scaledg[,19], Y_scaledg[,20], pch = ".", col = cluster_vector+1, bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[18],ylab=column_Yscaled_labels[19],zlab=column_Yscaled_labels[20])
        
      }
      else
      {
        show("scatterplots")
        showModal(modalDialog(title = "Important message",
                              "Select features to display",
                              checkboxGroupInput("feat_scatter","Select features:",choices=choiceg),
                              footer = tagList(
                                modalButton("Cancel"),
                                actionButton("ok_but", "OK")
                              )
        ))
        
      }
      
    
     curr_colors<-palette()
      for (i in 1:input$nclus)
      {
        aa<-col2rgb(curr_colors[i+1])
        color_gr[i,1]=aa[1]   #Red value
        color_gr[i,2]=aa[2]  #Green value
        color_gr[i,3]=aa[3]  #Blue value
        rm(aa)
        
      }
      assign("color_grg",color_gr , envir = .GlobalEnv)
      
      
      assign("spineClusterdg",as.factor(cluster_vector) , envir = .GlobalEnv)
      assign("clus_qualityg",output_hierarchical[[2]] , envir = .GlobalEnv)
      
      rm(cluster_vector)
      
      output$text<-renderText({
        print(out3)
      })  
      assign("n_clustersg",input$nclus, envir = .GlobalEnv)
      
    }#End of hierarchical
    if(input$select_cl=="Interactive Hierarchical")
    {
      method_clus_name="Interactive Hierarchical"
      assign("method_clus_nameg",method_clus_name , envir = .GlobalEnv)
      
      
      #hc <- hclust(dist(Y_scaledg[,2:ncol(Y_scaledg)]))
      hc <- hclust(dist(Y_scaledg[,c(2:16,18:ncol(Y_scaledg))]))
      
      #cl_idendro<-idendro(hc, Y_scaledg[,2:ncol(Y_scaledg)])
      cl_idendro<-idendro(hc, Y_scaledg[,c(2:16,18:ncol(Y_scaledg))])
      
      assign("cl_idendrog",cl_idendro, envir = .GlobalEnv)
      #dat2 <- data.frame(dat, cl_idendrog) 
      column_Yscaled_labels=colnames(Y_scaledg)
      
      cs = cluster.stats(dist(Y_scaledg[,indexes_choicesg]), cl_idendro)
      clust_quality1=cs$wb.ratio*100
      assign("clus_qualityg",clust_quality1, envir = .GlobalEnv)
      out3<-paste("Cluster quality",as.character(clust_quality1))
      output$text<-renderText({
        print(out3)
      })  
      
      if(input$geometrical=="Yes")
      {
        open3d()
        plot3d(Y_scaledg[,18], Y_scaledg[,19], Y_scaledg[,20], pch = ".", col = cl_idendrog+1, bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[18],ylab=column_Yscaled_labels[19],zlab=column_Yscaled_labels[20])
      }
      else
      {
        show("scatterplots")
        showModal(modalDialog(title = "Important message",
                              "Select features to display",
                              checkboxGroupInput("feat_scatter","Select features:",choices=choiceg),
                              footer = tagList(
                                modalButton("Cancel"),
                                actionButton("ok_but", "OK")
                              )
        ))
        
      }
      curr_colors<-palette()
      
      assign("n_clustersg",max(cl_idendrog), envir = .GlobalEnv)
      
      color_gr<-matrix(0,n_clustersg,3)  #Máximo 10 clusters
      assign("color_grg",color_gr, envir = .GlobalEnv)
      for (i in 1:n_clustersg)   
      {
        aa<-col2rgb(curr_colors[i+1])
        color_grg[i,1]=aa[1]   #Red value
        color_grg[i,2]=aa[2]  #Green value
        color_grg[i,3]=aa[3]  #Blue value
        rm(aa)
        
      }
      assign("color_grg",color_grg , envir = .GlobalEnv)
      
      
      assign("spineClusterdg",as.factor(cl_idendrog) , envir = .GlobalEnv)
     

      
      rm(cl_idendro)
      
      
    }#End of interactive hierarchical
    if(input$select_cl=="dbscan")
    {
      method_clus_name="Dbscan"
      assign("method_clus_nameg",method_clus_name , envir = .GlobalEnv)
      res<-dbscan_GUI(Y_scaledg,indexes_choicesg,input$epsilon,input$minpoints)
      output$plot4 <- renderPlot({pairs(Y_scaledg[,indexes_choicesg[1:3]], col = res$cluster + 1L)})
      cs = cluster.stats(dist(Y_scaledg[,indexes_choicesg]), res$cluster)
      column_Yscaled_labels=colnames(Y_scaledg)
      
      if(input$geometrical=="Yes")
      {
        open3d()
        plot3d(Y_scaledg[,18], Y_scaledg[,19], Y_scaledg[,20], pch = ".", col = res$cluster + 1L, bty = "f", cex = 2, colkey = FALSE,xlab=column_Yscaled_labels[18],ylab=column_Yscaled_labels[19],zlab=column_Yscaled_labels[20])
      }
      else
      {
        show("scatterplots")
        showModal(modalDialog(title = "Important message",
                              "Select features to display",
                              checkboxGroupInput("feat_scatter","Select features:",choices=choiceg),
                              footer = tagList(
                                modalButton("Cancel"),
                                actionButton("ok_but", "OK")
                              )
        ))
        
      }
      
      curr_colors<-palette()
      assign("n_clustersg",max(res$cluster), envir = .GlobalEnv)

      color_gr<-matrix(0,n_clustersg,3)  #Máximo 10 clusters
      assign("color_grg",color_gr, envir = .GlobalEnv)
      for (i in 1:n_clustersg)  
      {
        aa<-col2rgb(curr_colors[i+1])
        color_grg[i,1]=aa[1]   #Red value
        color_grg[i,2]=aa[2]  #Green value
        color_grg[i,3]=aa[3]  #Blue value
        rm(aa)
        
      }
      assign("color_grg",color_grg , envir = .GlobalEnv)
      
      assign("spineClusterdg",as.factor(res$cluster) , envir = .GlobalEnv)
      
      clust_quality1=cs$wb.ratio*100
      assign("clus_qualityg",clust_quality1, envir = .GlobalEnv)
      out3<-paste("Cluster quality",as.character(clust_quality1))
      output$text<-renderText({
        print(out3)
      })  
      
      
    } #End of dbscan
    
    
    #Matrix to save the homogeneity of each feature at each cluster
    hom_matrixg<-matrix(0,n_clustersg,length(choiceg))
    assign("hom_matrixg",hom_matrixg , envir = .GlobalEnv)
    
    #Color matrix for the homogeneity plot
    color_mat<-matrix(0,n_clustersg,length(choiceg))
    assign("color_matg",color_mat , envir = .GlobalEnv)
    
    
    #Homogeneity
    for (i in 1:n_clustersg) #For each cluster
    {
      
      groupcl<-which(spineClusterdg==i)
      Yscaledgrupo<-as.data.frame(Y_scaledg[groupcl,])
      for (j in 1:length(choiceg)) #For each feature
      {

        #If size of a cluster=1, this instruction will not work
        
        if(length(groupcl)==1)
        {
          var_feat_cluster<-0
        }
        else
        {
          cinstr3<-paste('Yscaledgrupo$',choiceg[j],sep='')
          ppp3<-eval(parse(text=cinstr3))
          var_feat_cluster=var(ppp3)
        }

       
        if(var_feat_cluster>0)
        {
          hom<-1/var_feat_cluster
        }
        else
        {
          hom<-0
          output$text<-renderText({print("There are one or more variances equal to zero, therefore homogeneity could not be calculated")})

        }

        hom_matrixg[i,j]<-hom
      }

    }
    assign("hom_matrixg",hom_matrixg , envir = .GlobalEnv)

    List <- list()
    # for(i in 1:n_clusters)  #colors for the bars
    # {
    #   xx<-color_grg[i,]
    #   cs<-rgb2hsv(xx[1],xx[2],xx[3])
    #
    #   color_old <- rev(rainbow(length(choiceg), s = 1, v = 1, start = cs[1], end = cs[1]+0.083, alpha = 1))
    #   index_yvalues_ordered<-sort(hom_matrixg[i,],index.return=TRUE)
    #   color_new<-seq(1,1,length(choiceg))
    #   color_new[index_yvalues_ordered$ix]<-color_old
    #
    #   List[[i]]<-color_new
    # }

    #Instead of different colors, this loop is for different saturations

    #Firstly, normalize hom_matrixg to assign saturations to the normalized values
    maxhom<-max(hom_matrixg)
    minhom<-min(hom_matrixg)
    interhom<-maxhom-minhom

    hom_matrixgnorm<-(hom_matrixg-minhom)/interhom


    for(i in 1:n_clustersg)  #colors for the bars
    {
      xx<-color_grg[i,]
      cs<-rgb2hsv(xx[1],xx[2],xx[3])  #cs[1] will contain the hue of the color
      colors_bars<-hsv(h=cs[1],s=0.8*c(hom_matrixgnorm[i,])+0.2,v=1,alpha=1)

     List[[i]]<-colors_bars
    }


    color_Matrix = do.call(cbind, List)

    List2 <- list()
    for (i in 1:n_clustersg)   #sequence of x coordinates for the text of the bars
    {
      numa=1.5+(i-1)*(length(choiceg)+1)
      numb=numa+length(choiceg)-1
      List2[[i]]<-seq(numa,numb,1)
    }
    seq_Matrix = do.call(cbind, List2)

    output$plot3<-renderPlot({
      print(barplot(t(hom_matrixg),beside=T,col=color_Matrix,xlab="Cluster"))
      text(choiceg[1:length(choiceg)],x=cbind(seq_Matrix),y=matrix((maxhom-minhom)/2,1,length(choiceg)),srt=90)
      title("Feature homogeneity")


    })

    rm(hom_matrixg)
    
    #Loop to compute percentage of spines of the same dendrite that belongs to the same cluster
    
    
    
    
    
    
    
  })#End of clustering observeEvent loop
  
  
  #Loop to show scatterplots
  observeEvent(input$ok_but,{
    removeModal()   #OK button closes the dialog box
    feat_scatter_choice<-input$feat_scatter
    features<-colnames(Yg)
    feat_scatter_indexes<-matrix(0,ncol(Yg))
    for (i in 1:length(feat_scatter_choice))
    {
      feat_scatter_indexes[i]<-match(feat_scatter_choice[i],features)
    }
    assign("feat_scatter_indexesg",feat_scatter_indexes , envir = .GlobalEnv)
    x11()
    plot(Yg[,feat_scatter_indexes[1]],Yg[,feat_scatter_indexes[2]],col=as.numeric(spineClusterdg)+1,pch=19,xlab=feat_scatter_choice[1],ylab=feat_scatter_choice[2])

  }
                )
  
  observeEvent(input$scatterplots,{
    showModal(modalDialog(title = "Important message",
                          "Select features to display",
                          checkboxGroupInput("feat_scatter","Select features:",choices=choiceg),
                          footer = tagList(
                            modalButton("Cancel"),
                            actionButton("ok_but", "OK")
                          )))
                          
  }
  
               
               )
  
  observeEvent(input$show_elbow, {
    
    features<-colnames(Yg)
    choice<-input$check
    assign("choiceg",choice , envir = .GlobalEnv)
    indexes_choices<-matrix(0,ncol(Yg))
    for (i in 1:length(choice))
    {
      indexes_choices[i]<-match(choice[i],features)
    }
    assign("indexes_choicesg",indexes_choices , envir = .GlobalEnv)
    output_kmeans<-kmeans_3D_GUI(Y_scaledg,indexes_choicesg,input$nclus)
    wss<-output_kmeans[[3]]
    output$plot3<-renderPlot({plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")
      
    })
  })
  
  observeEvent(input$ok_but2,{
    
    removeModal()   #OK button closes the dialog box
    choice_prueba<-input$check
    dddd<-paste('~',input$feat_outliers)
    ccc<-paste('~',colnames(Y_nuevag)[1])
    output$plot6<-renderPlotly({
      plot_ly(datg_filtg, y = eval(parse(text=dddd)), mode = "markers", type = "scatter",text=eval(parse(text=ccc)))
      
    })
    
  })
  
  
  observeEvent(input$no_but,{
    
    removeModal()   #No button closes the dialog box
    assign("Y_nuevag",Yg,envir = .GlobalEnv)

    
  })
  
  observeEvent(input$exit_but, {
    remove(list=ls(envir = .GlobalEnv),envir = .GlobalEnv)
    stopApp()
  })
  
  session$onSessionEnded(function() {
    remove(list=ls(envir = .GlobalEnv),envir = .GlobalEnv)
    stopApp()
  })
  
  
  
}


shinyApp(ui = ui, server = server)

