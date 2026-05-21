#!/bin/bash

# Give the desktop a split second to fully load after boot
sleep 1

# Launch the GNOME Terminal maximized, running tmux right inside it
gnome-terminal --full-screen -- bash -c "
  tmux new-session -d -s dev;
  tmux split-window -h -t dev 'ssh server-cristian; bash';
  tmux split-window -v -t dev:0.1 'ssh server-cristian; bash';
  tmux attach-session -t dev
"
