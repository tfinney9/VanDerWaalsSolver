#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

vdwSpecies<-read.csv(file="/home/tanner/src/thermoProj/data/ab.csv",header=TRUE,sep=",")
antSpecies<-read.csv(file="/home/tanner/src/thermoProj/data/antoine.csv",header=TRUE,sep=",")

library(shiny)
library(shinyjs)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(navbarPage("ECHM 407 Project",
                  tabPanel("Van Der Waal's Equation",
                           useShinyjs(),
                           
                        fluidPage(theme= shinytheme("sandstone"),
                          fluidRow(
                            column(12,
                                   h3('Select Species')
                            )
                          ),
                          hr(),
                          fluidRow(
                            column(12,
                          fluidRow(
                           column(2,wellPanel(
                                              radioButtons("manual",label="Select Input Type",choices=list("Select from List"=1,"Manual Input"=2),selected=1)
                                              
                                              )),
                           column(4,
                                  wellPanel(
                                  radioButtons("abcr",label="Select Species Parameters",choices=list("A,B"=1,"Critical Temperature and Pressure"=2),selected=1,inline=TRUE)
                                  # checkboxInput("manual",label="Manually Enter Parameters",value=0)
                                  ),
                                  
                           # fluidRow(
                           # column(6,
                           wellPanel(
                           uiOutput("primSelect"),style="height:100px"
                           )),
                          column(4,
                                 wellPanel(tags$b("Species Information"),
                                           verbatimTextOutput("fA"),
                                           verbatimTextOutput("fB"),
                                           uiOutput("customAB")
                                           ,style="height:223px")
                                 )
                          )
                          )),
                          fluidRow(
                            column(12,
                                   h3('Specify Variable of Interest')
                            )
                          ),
                          hr(),
                          fluidRow(
                            column(10,
                                   wellPanel(
                                   radioButtons("sfor",label="Solve For:",choices=list("Temperature"=1,"Pressure"=2,"Specific Volume"=3),selected=3,inline=TRUE)
                                   ))
                          ),
                          fluidRow(
                            column(5,
                                   wellPanel(
                                     column(6,
                                     numericInput("temp","Temperature",value=273.15)),
                                     column(4,
                                     selectInput("tempUnits","Temperature Units",choices=list("K","C","F","R"),selected=1)),style="height:100px"
                                   )
                                   ),
                            column(5,
                                   wellPanel(
                                     column(6,
                                            numericInput("pressure","Pressure",value=1)),
                                     column(4,
                                            selectInput("pressureUnits","Pressure Units",choices=list("bar","atm","Pa","torr","inHg"))),style="height:100px"
                                   )),
                            column(5,
                                   wellPanel(
                                     column(6,
                                            numericInput("sv","Specific Volume",value=0)),
                                     column(4,
                                            selectInput("svUnits","SV Units",choices=list("L/mol"),selected=1)),style="height:100px"
                                   )
                            ),
                            column(5,
                                   wellPanel(
                                     checkboxInput("tryDir","Try Direct Solver (When solving for Specific Volume)",value=0)
                                   )
           
                            ),
                            # verbatimTextOutput("shit")
                            column(12,
                                   actionButton("gogo","Run VDW"),
                                   verbatimTextOutput("goResult"),
                                   br(),
                                   uiOutput("rTitle"),
                                   hr(),
                                   column(6,
                                   verbatimTextOutput("result"))
                                   )
                          ))
                           
                           ),
                  tabPanel("Antoine's Equation",
                           h3("Select Species"),
                           hr(),
                           fluidRow(
                           column(3,
                           selectInput("antoine1","Select Species",c(choose="",antSpecies[1],selectize=TRUE))
                           ),
                           column(3,
                                  wellPanel(
                                    tags$b("Species Antoine Coefficients"),
                                    verbatimTextOutput("aA"),
                                    verbatimTextOutput("aB"),
                                    verbatimTextOutput("aC")
                                  )
                                  )),
                           fluidRow(column(12,
                           h3("Variable Configuration"),
                           hr())
                           ),
                           fluidRow(
                             column(2,
                                    wellPanel(
                                      radioButtons("antConfig1","Solve For:",choices=list("Temperature"=1,"Vapor Pressure"=2),selected=2)
                                    )
                                    ),
                             column(2,
                                    wellPanel(
                                      uiOutput("antOption")
                                    ))
                           ),
                           hr(),
                           fluidRow(
                             column(12,
                             actionButton("antoineGo","Run Antoine's Equation"),
                             br(),
                             uiOutput("ANrTitle"),
                             hr(),
                             column(6,
                                    verbatimTextOutput("ANresult")))
                           )
                           
                           )
                  
                  ))
