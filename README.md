# server-app-runner
A runner script for starting a server application. I use it in my projects to simplify the startup process and switch between different environments (typically development and production).

## Features

- Quickly switch environments and run custom scripts related to each environment;
- Load general environment variables from `.env` (check out the example one for some settings);
- Load environment-specific variables from `.env.[mode]`;
- Supports `.local` files for local configurations that are kept out of the repo. These environment variables will override the non-local ones. (e.g. `.env.local`, `.env.[mode].local`)

## Example

Let's analyze a simple example:

if you run `./runner.sh start dev` (`dev` is the environment), the following steps will be executed:

1. load environment variables from `.env` (if exists)
2. load environment variables from `.env.dev` (if exists)
3. load environment variables from `.env.dev.local` (if exists)
4. build the application (defined in `runner_scripts_[mode]/build.sh`)
5. stop the previously started instance (defined in `runner_scripts_[mode]/stop.sh`)
6. start a new instance (defined in `runner_scripts_[mode]/start.sh`)

Examples (projects used this script):

[frog-software/frogsoft-cms: Frogsoft CMS - Universal SaaS Content Management System (github.com)](https://github.com/frog-software/frogsoft-cms)

## How to use

1. Copy `runner.sh` and `runner_scripts_*/` to you project folder.
2. Since the script produces some files you may not want in a git directory (`.env.[env].local`, `started_process.pid` and outputs from stdout, stderr), you may want to merge `.gitignore` with the one in you own project directory to make sure temporary files are ignored by `git`.
3. There 4 scripts in the `runner_scripts_<environment>/` directory, fill each of them with your code. They tell the main script how to build/run your app. Check out the file contents to learn the purpose of each script. (You can customize `<environment>`, e.g. `dev`, `prod`, `test`)
4. Optionally, you can put all the `runner_scripts_<environment>/` directories into another directory to reduce clutter (check out the example `.env` file for instructions).
5. Navigate to your project directory. `chmod +x runner.sh` make the script executable
6. Use the script

For example, `./runner.sh start dev -v -s --skip-build` tells the runner to run scripts in `runner_scripts_dev/` , start in the background, turn on verbose mode, and skip build process.
## Usage

```
server-app-runner

./runner.sh start | build | stop | update [environment] [-d | --detach] [--skip-build] [-v | --verbose] [--file env] [-h | --help]
         start:        build your project, stop a previous process, then start a new one
         build:        build your project
         stop:         stop a previously started background process
         update:       update your project
         environment:  your custom script environments, like dev, prod, etc.
         --skip-build: skip build process when during "start"
         -d --detach:  start project in the background and return
         -v --verbose: turn on verbose mode
         --file:       choose env file
         -h --help:    show this help and exit
```

### Detailed description

#### start

1. build your project (runs `build.sh`, equivalent to `./runner.sh build [env]`, use `--skip-build` to skip)
2. stop a previously started process if exists (runs `stop.sh`)
3. start a new one (runs `start.sh`)

#### build

build your project (runs `build.sh`)

#### stop

stop a previously started process (runs `stop.sh`)

Note: if you use the predefined scripts, this step is only valid when you started the app use `-d/--detach` previously

#### update

runs `update.sh`

#### environment

run the scripts in the specified environment (since each environment has its own scripts)

Q: What are environments?

A: They are essentially different directories holding different `start.sh`, `stop.sh`, `stop.sh`, and `update.sh` scripts, following the pattern `runner_scripts_[env]`, e.g. `runner_scripts_dev`.

Q: Where the environments?

A: They are in the same level as `runner.sh` by default. You can put them in a different directory by defining `RUNNER_SCRIPT_DIR` in `.env` file (defaults to `.`).

#### -d/--detach

sets `$DETACH` to `true`

In the predefined scripts (`start.sh` and `stop.sh`), this will make the command to start you application (defined in `$START_COMMAND`) run in the background and save the `PID` of the started process. You can use `./runner.sh stop [env]` to stop the previously started process. It behaves like `-d/--detach` option in `Docker`.

This is especially useful if you run the application on your server, since if you start a foreground application using SSH, it will be stopped if you logout. 

Typically, when you start a web server, the process will not return unless something goes wrong. If you SSH into your server and start the process, it gets killed when you log out. This option will make the web server run in the background silently and provide options to kill the previously started background process.

Note: if you do not use the predefined scripts, you will need to implement the logic yourself. Checkout the predefined `start.sh` and `stop.sh` for examples.

####  -v/--verbose

show additional debug messages

#### --file

load additional env file
