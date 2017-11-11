#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Fri Oct  6 17:10:35 2017

@author: tanner
"""

import numpy
import sympy
import ConfigParser

#T=100 #C

#anCFGDir='/home/tanner/src/thermoProj/data/antX.cfg'
#anRDir='/home/tanner/src/thermoProj/data/anResult.txt'
anCFGDir='/srv/shiny-server/vdw/jData/antX.cfg'
anRDir='/srv/shiny-server/vdw/jData/anResult.txt'


def antoineP(T,A,B,C):
    Psat=10.0**(A-(B)/(T+C))
    return Psat

def antoineT(Psat,A,B,C):
    T=-1.0*(A*C-B-C*numpy.log10(Psat))/(A-numpy.log10(Psat))
#    aP,aA,aB,aC,aT=sympy.symbols('aP,aA,aB,aC,aT')
#    ft=(A-(B)/(aT+C))-sympy.log(pSat,10.0)
#    sol=sympy.solve(f)
    return T

#print antoineP(T,8.07131,1730.63,233.426)
#print antoineT(760.08639,8.07131,1730.63,233.426)

def readJob():
    cfg=ConfigParser.ConfigParser()
    cfg.read(anCFGDir)
    mainDict={}
    options=cfg.options(cfg.sections()[0])
    section=cfg.sections()[0]
    for i in range(len(options)):
        mainDict[options[i]]=cfg.get(section,options[i])
    return mainDict
    
aDict=readJob()
aS='----------------------------------------------------------\n'

def solver():
    if aDict['t']=='SOLVE':
        tSol=antoineT(float(aDict['psat']),float(aDict['a']),float(aDict['b']),float(aDict['c']))
        tS='Calculated Temperature: '+str(tSol)+' degC\n'
        return aS+tS+aS
    if aDict['psat']=='SOLVE':
         pSol=antoineP(float(aDict['t']),float(aDict['a']),float(aDict['b']),float(aDict['c']))
         pS='Calculated Vapor Pressure: '+str(pSol)+' mmHg\n'
         return aS+pS+aS
        
#         return pSol

aResult=solver()
#print aResult
with open(anRDir,'wb') as f:
    f.write(aResult)
    f.close()
        

        
        
        
