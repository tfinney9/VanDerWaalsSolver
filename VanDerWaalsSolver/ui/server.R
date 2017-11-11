#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
vdwSpecies<-read.csv(file="/home/tanner/src/thermoProj/data/ab.csv",header=TRUE,sep=",")
critSpec<-read.csv(file="/home/tanner/src/thermoProj/data/critical.csv",header=TRUE,sep=",")
antSpecies<-read.csv(file="/home/tanner/src/thermoProj/data/antoine.csv",header=TRUE,sep=",")

library(shiny)
library(shinyjs)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  useShinyjs()
  
  output$cb<-renderPrint(input$manual)
  tVar<-"0"
  output$primSelect<-renderUI({
    switch(input$manual,

            "1"=switch(input$abcr,
                                 "1"=tagList(
                              selectInput("vdwspec","Select Species A,B",
                                      c(Choose="",vdwSpecies[1]),selectize=TRUE)),
                                  "2"=tagList(
                                    selectInput("vdwcrit","Select Species Critical Values",
                                                c(Choose="",critSpec[2]),selectize=TRUE))
                                  ),
           "2"=switch(input$abcr,
                      "1"=tagList(column(6,
                        numericInput("mA","A (bar (L/mol)^2",value=0)),column(6,numericInput("mB","B (L/mol)",value=0))),
                      "2"=tagList(column(6,
                        numericInput("mTc","Tc (K) ",value=0)),column(6,numericInput("mPc","Pc (bar)",value=0)))
  
                      )
           )
           
    
    
  })
  observeEvent(input$vdwspec,{
    nLoc<-match(input$vdwspec,vdwSpecies[[1]])
    output$fA<-renderPrint(paste("A: ",vdwSpecies[[2]][nLoc]," bar (L/mol)^2",sep=""))
    output$fB<-renderPrint(paste("B: ",vdwSpecies[[3]][nLoc]," L/mol",sep=""))
  })
  observeEvent(input$vdwcrit,{
    nLoc<-match(input$vdwcrit,critSpec[[2]])
    output$fA<-renderPrint(paste("Tc: ",critSpec[[3]][nLoc]," K",sep=""))
    output$fB<-renderPrint(paste("Pc: ",critSpec[[4]][nLoc]," bar",sep=""))
  })
  observeEvent(input$mPc,{
    output$fA<-renderPrint(paste("Tc: ",input$mTc," K",sep=""))
    output$fB<-renderPrint(paste("Pc: ",input$mPc," bar",sep=""))
  })
  observeEvent(input$mB,{
    output$fA<-renderPrint(paste("A: ",input$mA," bar (L/mol)^2",sep=""))
    output$fB<-renderPrint(paste("B: ",input$mB," L/mol",sep=""))
  })
  
  observeEvent(input$sfor,{
    output$shit<-renderPrint(input$sfor)
    if(input$sfor=="1"){
      shinyjs::disable("temp")
      # shinyjs::disable("tempUnits")
      shinyjs::enable("pressure")
      # shinyjs::enable("pressureUnits")
      shinyjs::enable("sv")
      # shinyjs::enable("svUnits")
      
    }
    if(input$sfor=="2"){
      shinyjs::enable("temp")
      # shinyjs::enable("tempUnits")
      shinyjs::disable("pressure")
      # shinyjs::disable("pressureUnits")
      shinyjs::enable("sv")
      # shinyjs::enable("svUnits")
      
    }
    if(input$sfor=="3"){
      shinyjs::enable("temp")
      # shinyjs::enable("tempUnits")
      shinyjs::enable("pressure")
      # shinyjs::enable("pressureUnits")
      shinyjs::disable("sv")
      # shinyjs::disable("svUnits")
      
    }
  })
  
  writeJob<-reactive({
    cfg<-paste("/home/tanner/src/thermoProj/data/proc.cfg")
    cat("[VDW Solver Job]\n",file=cfg)
    if(input$manual==1){
      if(input$abcr==1){ #A,B
        nLoc<-match(input$vdwspec,vdwSpecies[[1]])
        cat(paste("species = ",input$vdwspec,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("A = ",vdwSpecies[[2]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("B = ",vdwSpecies[[3]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Tc = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Pc = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
      }
      if(input$abcr==2){ #Tc,Pc
        nLoc<-match(input$vdwcrit,critSpec[[2]])
        cat(paste("species = ",input$vdwcrit,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("A = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("B = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Tc = ",critSpec[[3]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Pc = ",critSpec[[4]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)
      }
    }
    if(input$manual==2){
      if(input$abcr==1){ #A,B
        cat(paste("species = ","CUSTOM","\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("A = ",input$mA,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("B = ",input$mB,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Tc = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Pc = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
      }
      if(input$abcr==2){ #Tc,Pc
        cat(paste("species = ","CUSTOM","\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("A = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("B = ",NaN,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Tc = ",input$mTc,"\n",collapse=""),file=cfg,append=TRUE)
        cat(paste("Pc = ",input$mPc,"\n",collapse=""),file=cfg,append=TRUE)
      }
    }
    if(input$sfor==1)
    {
      cat(paste("T = ","SOLVE","\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("T_units= ",input$tempUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P = ",input$pressure,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P_units= ",input$pressureUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV = ",input$sv,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV_units= ",input$svUnits,"\n",collapse=""),file=cfg,append=TRUE)
    }
    if(input$sfor==2)
    {
      cat(paste("T = ",input$temp,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("T_units= ",input$tempUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P = ","SOLVE","\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P_units= ",input$pressureUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV = ",input$sv,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV_units= ",input$svUnits,"\n",collapse=""),file=cfg,append=TRUE)
    }
    if(input$sfor==3)
    {
      cat(paste("T = ",input$temp,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("T_units= ",input$tempUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P = ",input$pressure,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("P_units= ",input$pressureUnits,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV = ","SOLVE","\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("SV_units= ",input$svUnits,"\n",collapse=""),file=cfg,append=TRUE)
    }
    if(input$tryDir==TRUE){
      cat(paste("direct = ","true","\n",collapse=""),file=cfg,append=TRUE)
    }
    if(input$tryDir==FALSE){
      cat(paste("direct = ","false","\n",collapse=""),file=cfg,append=TRUE)
    }
    
    
    
  })
  observe({
    if (input$gogo>0)
    {
      shinyjs::hide("gogo")
      output$goResult<-renderPrint("Reload the App to run the equation again")
    }
    if (input$gogo==0)
    {
      shinyjs::show("gogo")
    }
  })
  observeEvent(input$gogo,{
    skaCfg<-writeJob()
    system(paste("/home/tanner/src/thermoProj/one.py"))
    resultFile<-read.csv(file="/home/tanner/src/thermoProj/data/result.txt")
    output$result<-renderPrint(resultFile)
    output$rTitle<-renderUI(tagList(h3("Results")))
  })
  
  
  #==============================================
  #
  # ANTOINE'S EQUATION
  #
  #==============================================
  
  observeEvent(input$antoine1,{
    nLoc<-match(input$antoine1,antSpecies[[1]])
    output$aA<-renderPrint(paste("A: ",antSpecies[[2]][nLoc]," ",sep=""))
    output$aB<-renderPrint(paste("B: ",antSpecies[[3]][nLoc]," degC",sep=""))
    output$aC<-renderPrint(paste("C: ",antSpecies[[4]][nLoc]," degC",sep=""))
    
  })
  
  output$antOption<-renderUI({
   switch(input$antConfig1,
          "1"=tagList(numericInput("psatX",label="Enter Saturation Pressure (mmHg)",value=0.0)),
          "2"=tagList(numericInput("tempX",label="Enter Temperature (degC)",value=0.0))
     
   ) 
  })
  
  writeAnt<-reactive({
    cfg<-paste("/home/tanner/src/thermoProj/data/antX.cfg")
    cat("[Antoine CFG]\n",file=cfg)
    cat(paste("species = ",input$antoine1,"\n",collapse=""),file=cfg,append=TRUE)
    nLoc<-match(input$antoine1,antSpecies[[1]])
    cat(paste("A = ",antSpecies[[2]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)    
    cat(paste("B = ",antSpecies[[3]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)  
    cat(paste("C = ",antSpecies[[4]][nLoc],"\n",collapse=""),file=cfg,append=TRUE)
    if(input$antConfig1==2)
    {
      cat(paste("T = ",input$tempX,"\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("Psat = ","SOLVE","\n",collapse=""),file=cfg,append=TRUE)
    }
    if(input$antConfig1==1)
    {
      cat(paste("T = ","SOLVE","\n",collapse=""),file=cfg,append=TRUE)
      cat(paste("Psat = ",input$psatX,"\n",collapse=""),file=cfg,append=TRUE)
    }
  })
  observe({
    if (input$antoineGo>0)
    {
      shinyjs::hide("antoineGo")
      output$antResultA<-renderPrint("Reload the App to run the equation again")
    }
    if (input$antoineGo==0)
    {
      shinyjs::show("antoineGo")
    }
  })
  observeEvent(input$antoineGo,{
    antCfg<-writeAnt()
    system(paste("/home/tanner/src/thermoProj/antoine.py"))
    ANresultFile<-read.csv(file="/home/tanner/src/thermoProj/data/anResult.txt")
    output$ANresult<-renderPrint(ANresultFile)
    output$ANrTitle<-renderUI(tagList(h3("Results")))
  })
  
  
  
  
  

  
})
