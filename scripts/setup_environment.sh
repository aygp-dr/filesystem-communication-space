#!/bin/bash
# [[file:../00-foundations.org::*Appendix: Setting Up the Environment][Appendix: Setting Up the Environment:1]]
# Setup script for exploring filesystem communication

# Create standard directories for experiments
mkdir -p /tmp/fsc-experiments/{pipes,sockets,locks,messages}

# Set up permissions for shared communication
chmod 1777 /tmp/fsc-experiments

# TODO: Add more setup steps
# - [ ] Check for required tools
# - [ ] Create test users for permission experiments
# - [ ] Set up monitoring tools

echo "Filesystem communication space initialized at /tmp/fsc-experiments"
# Appendix: Setting Up the Environment:1 ends here
