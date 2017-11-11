#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 30 12:07:08 2017

@author: tanner
"""

import vdw
import csv
import ConfigParser
import pint
import numpy
import calcUnits

import datetime

abDir='/home/tanner/src/thermoProj/data/ab.csv'
crDir='/home/tanner/src/thermProj/data/critical.csv'
#procDir='/home/tanner/src/thermoProj/data/proc.cfg'
#rDir='/home/tanner/src/thermoProj/data/result.txt'
procDir='/srv/shiny-server/vdw/jData/proc.cfg'
rDir='/srv/shiny-server/vdw/jData/result.txt'

#print datetime.datetime.now().day
f=datetime.datetime.now()
#print f.month, f.day,f.year

print '======================================='
print 'Van Der Waals Solver V1.0'
print '======================================='


u=pint.UnitRegistry()

class vdwStruct:
    """
    This is used to store data for the solver
    """
    species=''
    a=0.0
    b=0.0
    Tc=0.0
    Pc=0.0
    T=0.0
    P=0.0
    sV=0.0
    solve_for=''
    sType=True
    T_units=''
    P_units=''
    sV_units=''
    direct=False

def vdwPrinter(vv):
    """
    For Debugging
    """
    print '======================================='
    print 'Specs Given'
    print '---------------------------------------'
    print vv.species
    print 'a:',vv.a
    print 'b:',vv.b
    print 'Tc:',vv.Tc
    print 'Pc:',vv.Pc
    print 'T:',vv.T
    print 'P:',vv.P
    print 'sv:',vv.sV
    print 'ab?',vv.sType
    print 'TU:',vv.T_units
    print 'PU:',vv.P_units
    print 'svU:',vv.sV_units
    print 'solve for:',vv.solve_for
    print 'Try Direct?',vv.direct
    print '======================================='

    
def getAB():
    """
    Not used to but could get A and B values from CSV
    """
    with open(abDir,'rb') as f:
        abDat=list(csv.reader(f))
    return abDat 

def getCrit():
    """
    Not used to but could get Critical values from CSV
    """
    with open(crDir,'rb') as f:
        crDat=list(csv.reader(f))
    return crDat
    
def readJob():
    """
    Opens CFG file from SHINY UI
    """
    cfg=ConfigParser.ConfigParser()
    cfg.read(procDir)
    mainDict={}
    options=cfg.options(cfg.sections()[0])
    section=cfg.sections()[0]
    for i in range(len(options)):
        mainDict[options[i]]=cfg.get(section,options[i])
    return mainDict

"""
Below is the actual script
"""

mainDict=readJob()
jStruct=vdwStruct()

jStruct.species=str(mainDict['species'])

if mainDict['direct']=='true':
    jStruct.direct=True

if mainDict['pc']=='NaN' and mainDict['tc']=='NaN':
    print 'A and B Given!'
#    jStruct.sType=True
    jStruct.a=float(mainDict['a'])
    jStruct.b=float(mainDict['b'])
if mainDict['a']=='NaN' and mainDict['b']=='NaN':
    print 'Critical T and P Given! need to find A and B...'
    jStruct.Tc=float(mainDict['tc'])
    jStruct.Pc=float(mainDict['pc'])
    jStruct.a=vdw.calcA(jStruct.Tc,jStruct.Pc)
    jStruct.b=vdw.calcB(jStruct.Tc,jStruct.Pc)    
    

jStruct.T_units=mainDict['t_units']
jStruct.P_units=mainDict['p_units']
jStruct.sV_units=mainDict['sv_units']


if mainDict['t']=='SOLVE':
    jStruct.solve_for='temp'
    jStruct.T='SOLVE'
    jStruct.P=calcUnits.convertP(float(mainDict['p']),jStruct.P_units)
    jStruct.sV=float(mainDict['sv'])
if mainDict['p']=='SOLVE':
    jStruct.solve_for='pressure'
    jStruct.P='SOLVE'
    jStruct.T=calcUnits.convertT(float(mainDict['t']),jStruct.T_units)
    jStruct.sV=float(mainDict['sv'])
if mainDict['sv']=='SOLVE':
    jStruct.solve_for='sv'
    jStruct.sV='SOLVE'
    jStruct.T=calcUnits.convertT(float(mainDict['t']),jStruct.T_units)
    jStruct.P=calcUnits.convertP(float(mainDict['p']),jStruct.P_units)

#Convert Units
aS='---------------------------------------\n'

vdwPrinter(jStruct)
def solver(jStruct):
    """
    figures out what to solve and then solves it
    """
    if jStruct.sType==True: #USE A,B, Make LifeEasy
    #    vdw.setParams(jStruct.a,jStruct.b,jStruct.P,jStruct.T,jStruct.sV)
        if jStruct.sV=='SOLVE':
            print '=====================\nSolving For SV!\n====================='
            vSol=0.0
            vBSol=0.0
            if jStruct.direct==True:
                print'TRYING DIRECT SOLVE...'
                try:
                    print 'Trying Sympy direct Sovle...'
                    vSol=vdw.directSolveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b)
                    print 'Got it!'
                except:
                        print 'could not find a solution with sympy... Trying Broyden\'s Method'
                        raise
            print 'TRYING BROYDEN\'S METHOD...'
            try:    
                print 'Trying Guess 0.01...'
                vBSol=vdw.solveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b,0.01)
                print 'root found @g=0.01'
            except:
                print 'Non Convergence with 0.01 Guess...'
                try:
                    print 'Trying Guess 0.1...'
                    vBSol=vdw.solveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b,0.1)
                    print 'root found @g=0.1'
                except:
                        print 'Non Convergence with 0.1 guess...'
                        pass
                        try:
                            print 'Trying Guess 1.0...'
                            vBSol=vdw.solveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b,1.0)
                            print 'root found @g=1.0'
                        except:
                                print 'Non Convergence with 1.0 Guess...'
                                try:
                                    print 'Trying 10.0...'
                                    vBSol=vdw.solveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b,10.0)
                                    print 'root found @g=10.0'
                                except:
                                    print 'Non Convergence with 10...'
                                    try:
                                        print 'Trying 100.0...'
                                        vBSol=vdw.solveForVolume(jStruct.T,jStruct.P,jStruct.a,jStruct.b,100.0)
                                        print 'root found @g=100.0'
                                    except:
                                        print 'Could not converge for 0.01-100.0, end. O_O'
                                        raise
                                        
#            return [vSol,vBSol]
                                        
                                        
            aSa='Specific Volume Results: (L/mol)\n'
            bS='\n'
            if jStruct.direct==True:
                bS='Sympy Solver: '+str(vSol)+'\n'
            cS='Broyden\'s Method: '+str(vBSol)+'\n'
            result=aS+aSa+bS+cS+aS                                                         
            return result
            
        if jStruct.P=='SOLVE':
            print '=====================\nSolving For P!\n====================='
            pSol=vdw.solveForPressure(jStruct.T,jStruct.sV,jStruct.a,jStruct.b)
            pS='Solving for Pressure Results:\n'
#            qS=str(pSol)+' bar\n'
            sS=str(calcUnits.revertP(pSol,jStruct.P_units))+' '+str(jStruct.P_units)+'\n'
            result=aS+pS+sS+aS
            return result
        if jStruct.T=='SOLVE':
            print '=====================\nSolving For T!\n====================='
            tSol=vdw.solveForTemp(jStruct.P,jStruct.sV,jStruct.a,jStruct.b)
            tS='Solving for Temperature Results:\n'
            rS=str(calcUnits.revertT(tSol,jStruct.T_units))+' '+str(jStruct.T_units)+'\n'
            return aS+tS+rS+aS
    

fResult=solver(jStruct)

with open(rDir,'wb') as f:
    f.write(fResult)
    f.close()



    



















