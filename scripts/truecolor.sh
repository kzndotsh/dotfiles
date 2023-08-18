#!/bin/bash

LINES=$(tput lines)
COLUMNS=$(tput cols)

# Code from https://twitter.com/josh_cheek/status/1116321447234940928
ruby -eh,w=$LINES,$COLUMNS'
B=(0..20).map{[0,rand*h,rand*5,rand]}
loop{B. map!{|x,y,v,a|[(x+v),y+a=y<0?-a:a-0.1,v,a]}
$><<"\e[H"<<h.times. map{|v|w.times. map{|u|d=B. map{|x,y|Math.sqrt (w/2-(x+w/2-u)%w)**2/4+(v-y)**2}.min*9
"\e[48;2;#{d<0?0:d>255?255:d. to_i};0;0m "}*""}*"\n"}'
