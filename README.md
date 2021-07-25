# server-app-runner
A runner script for starting a server application in the background, useful on SSH connections.

Example:

Typically, when you start a web server, the process will not return unless something goes wrong. If you SSH into your server and start the process, it gets killed when you log out.

This tool will make the web server run in the background silently and provide options to kill the previously started background process.

## How to use

1. There 4 scripts in the `runner_scripts_<environment>` directory, fill each of them with your code. They tell the main script how to build/run your app. Check out the file contents to learn the purpose of each script. (You can custom the `<environment>` and tell the runner to run scripts in the different environments.)

2. Copy `runner.sh` and `runner_scripts_*` to you project folder that you want to start in.

3. Since the script produces some temporary files, you may want to merge `.gitignore` with the one in you own project directory to make sure temporary files are ignored by `git`.

4. Navigate to your project directory. `chmod +x runner.sh` make the script executable

5. use the script
    ```
    server-app-runner
    
    ./runner.sh start | build | stop | update [environment] [-s | --silent] [--skip-build] [-v | --verbose] [-h | --help]
             start:        build your project, stop a previous process, then start a new one
             build:        build your project
             stop:         stop a previously started background process
             update:       update your project
             environment:  your custom script environments, like dev, prod, etc.
             --skip-build: skip build process when during "start"
             -s --silent:  start project in the background and return
             -v --verbose: turn on verbose mode
             -h --help:    show this help and exit
    ```
    
    For example, `./runner.sh start dev -v -s --skip-build` tells the runner to run scripts in `runner_scripts_dev` , start in the background, turn on verbose mode, and skip build process.