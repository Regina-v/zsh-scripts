#!/bin/zsh

function ProgressBar {
  let _progress=(${1}*100/${2}*100)/100
  let _done=(${_progress}*4)/10
  let _left=40-$_done
  _fill=$(printf "%${_done}s")
  _empty=$(printf "%${_left}s")
  echo -ne "\rProgress : [${_fill// /▇}${_empty// /-}] ${_progress}%"
}

export ProgressBar
