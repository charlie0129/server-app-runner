# server-app-runner
A runner script for starting a server application in the background, useful on SSH connections

## How to use

1. fill you own code in `build.sh` and `start.sh`, which is responsible for building you app (if needed) and starting your app, respectively. (you may check out the examples)

2. `chmod +x runner.sh` make the script executable
3. use the script
    1. `./runner.sh start` to build your app and then start it. use `--skip-build` to skip building.
    2. `./runner.sh build` to build you app
    3. `./runner.sh start -s` or `./runner.sh start --silent` to build your app and then start it

[How do I parse command line arguments in Bash? - Stack Overflow](https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)

