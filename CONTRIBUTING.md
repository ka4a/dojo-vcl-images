# Contribution Guidelines

## Prerequisite

The intended use of this project is to build and deploy images for coding assignments in CI, using the [build-master workflow](.github/workflows/build-master.yaml). We also provide, however, the tool to build and test images locally in order for Dojo Admin to be able to prepare and test coding assignment environments.

Here is a list of dependencies and tools:

1. [docker](https://docs.docker.com/get-started/overview/) - to start a local registry server
1. [buildkitd](https://github.com/moby/buildkit) - to help build the images
1. [dazzle](https://github.com/gitpod-io/dazzle/) - primary tool used to build docker images
1. [registry image](https://aws.amazon.com/ecr/?nc1=h_ls) - a local registry server image

## Building images

### Locally

We ship a [Makefile](Makefile) that can be used to build the images locally. See the following sub sections for usage.

Coding assignments are built from chunks. Some of these are shared across all assignments (e.g. to provide VSCode server) while some chunks are dedicated to specific assignments. This script will first build the chunks and run tests, followed by creation of container images. It uses `dazzle` to perform these tasks.

The images will be pushed to the local registry server running on port 5000. You can pull the images using:

```bash
docker pull localhost:5000/dazzle:combo
```

where `combo` is the name of the combination defined in [dazzle.yaml](dazzle.yaml) e.g. `project2-cpp-monitor`, `python-dog-image-classifier`.

## How to work on localhost


### Adding a chunk

Follow the below steps to add your chunk:

1. Create your chunk directory under [./chunks](chunks)
1. Create a `chunk.yaml` file if your chunk has more than one active versions.
You can look at the existing files in this repo for reference e.g. [pytorch](chunks/pytorch/chunk.yaml).
1. Create a docker file containing instructions on how to install the tool.
Make sure you use the default base image like other chunks.

Here is a list of best practices you should keep in mind while adding a chunk:

1. Add variants through `chunk.yaml` if more than one version is popular for the chunk.
1. Install specific version of the tool/language.
1. Make sure the user `coder` can access the installed tool/lang.
1. The last `USER` command of the image should always be `coder` and **NOT** `root`.
1. Always add new path as prefix to existing path.
e.g. `ENV PATH=/my-tool/path/bin:$PATH`.
Not doing so can cause path conflicts and can potentially break other images.
1. **DO NOT** update the default shell rc files like `.bashrc` unless you are making change in the base layer.
1. Use `gpg` to unpack and store keyrings and add them to apt sources explicitly.
e.g.

    ```bash
    # fetch keyring over https connection and unpack it using gpg's --dearmor option
    curl -fsSL https://apt.my-secure.org/my-unofficial-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/my-unofficial-repo.gpg.key
    # and then add them to a apt key sources list.
    echo "deb [signed-by=/usr/share/keyrings/my-unofficial-repo.gpg.key] http://apt.my-secure.org/focal/ \
    my-unofficial-repo-toolchain main" | sudo tee /etc/apt/sources.list.d/my-unofficial-repo.list > /dev/null
    ```

### Create a new coding assignment

A coding assignment is a combination of chunks.
Follow steps to add a new coding assignment:

1. Open dazzle.yaml
2. Add a new combination to combiner.combinations
3. Name - it is the name of your coding assignment. It will be used a tag of the target docker repository.
\<registry>/\<repo>:\<Name>
4. The new combination must include `vscode` chunk.
5. Add any necessary chunks to the combination.
6. Build and combine your chunks by the above instructions.

### Writing Tests

Follow the instructions below to add tests for a chunk:

1. Create a `category-name.yaml` file under the [tests](tests) directory.
1. Write your tests with proper assertions.
You can read more on how to write tests in the [dazzle documentation](https://github.com/gitpod-io/dazzle/#testing-layers-and-merged-images)

Here is a list of best practices you should keep in mind while writing a test:

1. Test should check the version of the tools and languages and their dependencies that are being installed.
1. Test must assert on the exit code i.e. the `status`.
1. Test must check the existence of directories that are required for the chunk to work.

### Updating dazzle.yml

Adding a combination is easy and only requires you list the base reference and the set of chunks.
You can refer to the existing combinations to learn more.

Here is a list of best practices you should keep in mind while adding a combination:

1. Use a meaningful name of the combination, it should not conflict with existing names.

### Useful commands

[Makefile](Makefile) provides targets to build and combine chunks.

| Command              | Description                                                                             |
| -------------------- | --------------------------------------------------------------------------------------- |
| start-local-registry | pulls and run docker registry at localhost                                              |
| stop-local-registry  | stops and remove volumes for the local docker registry                                  |
| builder              | builds a docker image with tools to build and combine coding assignments                |
| start-builder        | runs a builder as a background container for a future usage                             |
| stop-builder         | stops and remove builder container and corresponding volumes                            |
| build-all            | builds all chunks (See sections below)                                                  |
| combine-all          | combines all chunks (See sections below)                                                |
| up                   | performs all actions to up necessary environment for building chunks and combinations   |
| down                 | performs all actions to down necessary environment for building chunks and combinations |
| build                | builds specific chunks. See examples below                                              |
| combine              | builds and combine a specific combination. See examples below                           |

See examples below.

### Build specific chunks

Often, you would want to test only the chunks that you modify. You can do that with make build using the -c flag.

```bash
PARAM="-c vscode -c python3.9" make build
```

Above command will build only chunks vscode and python3.9

### Build Specific Combination

Sometimes you only want to build one specific combination e.g. the python-dog-image-classifier or other images. You can do that with

```bash
PARAM="python-dog-image-classifier" make combine
```

This will build all chunks that are referenced by the `python-dog-image-classifier` combination and then combine them to create the `python-dog-image-classifier` image.

### Build All Chunks

Execute the following command to build using the default config `dazzle.yaml` shipped in this repo:

```bash
make build-all
```

> **NOTE:** Building images locally consumes a lot of resources.
Subsequent builds are faster if the number modified chunks is less.

### Build all Combinations

You may want to build combinations. You can do that with

```bash
make combine-all
```

This will combine all chunks that already built by build-all target.

### Examples

In this example you will see full workflow to build and combine chunks from scratch.

```bash
make up
make build-all combine-all
make down
```

## Pipeline

We use [Github Actions](https://docs.github.com/en/actions) for our pipelines.

### Build

We have a Build pipeline which gets triggered on the following two events:

1. **[Build from Master](.github/workflows/build-master.yml)** - On push to the default branch `master`.

### Release

We have one release workflows:

1. **[Build from Master](.github/workflows/build-master.yml)** - On push to the default branch `master` release.

All the images are built within GH Actions and tested using dazzle.

As evident from previous sections, we use a single Github Actions Workflow to build and then release the created images.

#### Images

Dazzle builds and stores the images as tags of `<AWS ECR>/coding-assignment` image.
