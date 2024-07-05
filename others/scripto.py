import subprocess
import sys
import re


def main():
    app_name = "/bin/i3-msg"
    params = app_name + " -t get_workspaces"

    result = subprocess.run(params, shell=True,
                            capture_output=True, text=True)

    # 1. Get the id of the workspace we want to change the name and the new name
    new_name = sys.argv[1] + ": " + sys.argv[2]

    # 2. Get the current name of the workspace
    # Typical substring of the result = "num":1,"name":"1"
    pattern = fr'"num":{sys.argv[1]},"name":"([^"]+)"'
    match = re.search(pattern, result.stdout)

    if match:
        old_name = match.group(1)

    print(old_name)

    # 3. Change the name of the workspace to the new name
    params = "/bin/i3-msg 'rename workspace " + \
        f'"{old_name}" to "{new_name}"\''
    print(params)
    result = subprocess.run(params, shell=True, capture_output=True, text=True)


if __name__ == "__main__":
    main()
