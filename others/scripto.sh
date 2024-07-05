#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <workspace_number> <new_name>"
    exit 1
fi

# Variables
workspace_number=$1
new_name="$workspace_number: $2"
app_name="/bin/i3-msg"

# Get the current workspaces
result=$($app_name -t get_workspaces)

# Extract the current name of the workspace
# Typical substring of the result = "num":1,"name":"1"
pattern="\"num\":$workspace_number,\"name\":\"([^\"]+)\""
if [[ $result =~ $pattern ]]; then
    old_name="${BASH_REMATCH[1]}"
else
    echo "Workspace number $workspace_number not found."
    exit 1
fi

echo "Old workspace name: $old_name"

# Change the name of the workspace to the new name
params="$app_name 'rename workspace \"$old_name\" to \"$new_name\"'"
echo "Executing: $params"
eval $params
