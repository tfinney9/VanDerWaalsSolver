# -*- coding: utf-8 -*-
"""
Created on Fri Oct  6 14:51:48 2017

@author: tanner
"""

import pint as pynt

u=pynt.UnitRegistry()

def convertT(temp,unit):
    if unit=='K':
        return temp
    if unit=='R':
        temp=temp*u.rankine
        rtemp=temp.to(u.kelvin)
        return rtemp.magnitude
    if unit=='F':
        tempF=u.Quantity
        fTemp=tempF(temp,u.degF)
        cTemp=fTemp.to(u.kelvin)
        return cTemp.magnitude
    if unit=='C':
        tempC=u.Quantity
        cTemp=tempC(temp,u.degC)
        kTemp=cTemp.to(u.kelvin)
        return kTemp.magnitude

def revertT(temp,unit):
    if unit=='K':
        return temp
    if unit=='R':
        temp=temp*u.kelvin
        rtemp=temp.to(u.rankine)
        return rtemp.magnitude
    if unit=='F':
        tempF=u.Quantity
        fTemp=tempF(temp,u.kelvin)
        cTemp=fTemp.to(u.degF)
        return cTemp.magnitude
    if unit=='C':
        tempC=u.Quantity
        cTemp=tempC(temp,u.kelvin)
        kTemp=cTemp.to(u.degC)
        return kTemp.magnitude
        
def convertP(p,unit):
    if unit=='bar':
        return p
    if unit=='atm':
        p=p*u.atm
        q=p.to(u.bar)
        return q.magnitude
    if unit=='Pa':
        p=p*u.Pa
        q=p.to(u.bar)
        return q.magnitude
    if unit=='torr':
        p=p*u.torr
        q=p.to(u.bar)
        return q.magnitude
    if unit=='inHg':
        p=p*u.inHg
        q=p.to(u.bar)
        return q.magnitude

def revertP(p,unit):
    if unit=='bar':
        return p
    if unit=='atm':
        p=p*u.bar
        q=p.to(u.atm)
        return q.magnitude
    if unit=='Pa':
        p=p*u.bar
        q=p.to(u.Pa)
        return q.magnitude
    if unit=='torr':
        p=p*u.bar
        q=p.to(u.torr)
        return q.magnitude
    if unit=='inHg':
        p=p*u.bar
        q=p.to(u.inHg)
        return q.magnitude        

    


        