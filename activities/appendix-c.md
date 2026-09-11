## JumpStart

### Install and Configure JumpStart

How to install and configure JumpStart

### Generate Your Driver Code with JumpStart

How to generate the driver code with JumpStart

### Modify the Driver Code

How to modify the driver code

### Bonus: JumpStart for Mac Users
You don't need to feel left out if you are a Mac user. You can run the Linux executable if you install **Docker** and modify your terminal shell configuration file just a bit. Make sure to consider and look up how to modify these instructions if you are on an older Mac with an Intel chip. You do this at your own risk!

1. Install [**Docker Desktop**](https://www.docker.com/products/docker-desktop).
2. Edit your `.zshrc` file (or make one if you don't have it in your user directory `/Users/[yourusername]/.zshrc`):

```sh
export DOCKER_DEFAULT_PLATFORM=linux/amd64

jumpstart() {
  docker run --rm -it -v "$PWD":/work -w /work ubuntu:24.04 "$@"
}
```

3. In the **terminal** you will type:

```sh
jumpstart ./JumpStart ./SampleDriverFiles/AcmeTv.json ./JumpStartEnvironment.json
```
The first time you run it, Docker will need to download ubuntu v24.04, but after will pull from the local version.

