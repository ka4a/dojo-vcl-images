# Workspace Images

Ready-to-use Docker images for code assignments of VCL application.

## Documentation
- [Configure docker image and code for an assignment](https://woven-dojo.atlassian.net/wiki/spaces/DOJO/pages/9895983/Create+coding+assignment+images?src=search)
- [Build new images for coding assignments](./CONTRIBUTING.md)

## Images

Each contains a set of chunks. Usually: 
- A common base with Visual Studio code server.
- Hardware drivers (e.g. for GPUs)
- A programming language.
- Software libraries.

Some chunks in this repo are:
1. cpp - contains necessary dependencies for running cpp code assignments.
2. vscode - contains VScode server
3. nvidia-gpu-support - contains all libs to run GPU projects
4. pytorch - contains python, pytorch installation

## Getting started

```bash
# Install buildkitd(Available for Linux only)
# https://github.com/moby/buildkit
# run buildkitd using systemd or as a process
buildkitd &

# Install dazzle
git clone git@github.com:gitpod-io/dazzle.git ../dazzle
(cd ../dazzle && go install)

# Build chunks
dazzle build docker.io/\<your account\>/\<name of a repo\>

# Combine chunks
dazzle combine docker.io/\<your account\>/\<name of a repo\> --all

# Run CPP coding assignment
docker run -it -v <path to workspaces>/vcl-workspaces/:/home/workspaces -e DEFAULT_WORKSPACE=/home/workspaces -e PASSWORD=123 -p 8080:8080 coolco/test-vscode:project2-cpp-monitor bash /usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 .

# Open browser 127.0.0.1:8080. Enter password 123

```

## Github actions

To run github actions locally use the next tool: <https://github.com/nektos/act>

```bash
act -s GITHUB_TOKEN=<token>  -s AWS_ACCESS_KEY_ID=<aws access key> -s AWS_SECRET_ACCESS_KEY=<secret key>  --privileged
```
