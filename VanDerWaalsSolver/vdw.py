# -*- coding: utf-8 -*-
"""
Created on Wed Aug 30 10:11:25 2017

@author: tanner
"""

import scipy.optimize
import sympy

"""

Van Der Waals Solver Attempt 1

(P-a/v^2)(v-b)=RT

Units Based on
THERMODYNAMIC INFORMATION
AND
TABLES OF DATA
FOR
CHEMICAL ENGINEERS

P: bar
T: Kelvin
A: mol
v: Litre


"""
R=83.1451*10**-3 #bar L / mol K
params={'P':0,'T':0,'a':0,'b':0,'v':0}

def setParams(a,b,P,T,v):
    """
    Set a,b (van Der Waals Parameters), Pressure, Temperature and specific Volume
    Set the one you are solving for to zero for organizations sake
    """
    params['a']=a
    params['b']=b
    params['P']=P
    params['T']=T
    params['v']=v


## Solve for Specific Volume
def vdwVolume(v):
    """
    Function for solving for volume
    """
    a=params['a']
    P=params['P']
    b=params['b']
    T=params['T']
    vSol=(P+a/v**2)*(v-b)-R*T
    return vSol


def vdwTemp():
    """
    Function for solving for Temperature
    """
    a=params['a']
    P=params['P']
    b=params['b']
    v=params['v']
    tSol=((P+a/v**2)*(v-b))/(R)
    return tSol

def vdwPressure():
    """
    Function for solving for Pressure
    """
    a=params['a']
    T=params['T']
    b=params['b']
    v=params['v']
    P=(R*T)/(v-b)-(a)/(v**2)
    return P

def solveForVolume(T,P,a,b,gV):
    """
    Can't Directly Solve for v so we use broyden's Method
    """
    setParams(a,b,P,T,0.0)
#    print params
    sol=scipy.optimize.broyden1(vdwVolume,gV,maxiter=1000,f_tol=1e-7)
    return sol

def solveForTemp(P,v,a,b):
    """
    Direct Solve for T
    """
    setParams(a,b,P,0.0,v)
    sol=vdwTemp()
    return sol

def solveForPressure(T,v,a,b):
    """
    Direct Solve for P
    """
    setParams(a,b,0.0,T,v)
    sol=vdwPressure()
    return sol

def directSolveForVolume(T,P,a,b):
    """
    Use Sympy to attempt to directly solve for Volume
    """
    v=sympy.symbols('v',real=True)
    f=(P+a/v**2)*(v-b)-R*T
    vSol=sympy.solve(f)
    return vSol

def calcA(Tc,Pc):
    """
    Finds a based on crit T and P
    """
    a=(27.*R**2.*Tc**2.)/(64*Pc)
    return a

def calcB(Tc,Pc):
    """
    Finds b based on crit T and P
    """
    b=(R*Tc)/(8.*Pc)
    return b


#fa=0.0346
#fb=0.0238

#print solveForVolume(273.15,1.01325,fa,fb,5.0),'L/mol'
#print solveForTemp(1.01325,22.4363769182,fa,fb),'K'
#print solveForPressure(273.15,22.4363769182,fa,fb),'bar'

#print directSolveForVolume(273.15,1.01325,fa,fb),'L/mol'
