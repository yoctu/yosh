# YOSH (Yoctu Shell) - Bash Micro Web Framework lib

Yosh Provide a bash framework for api and applications.
It is fully written in bash and aims to be easy to use. It provides the required feature of a web framework.
We recommend to use yoctu-starter-kit to build a new application.

# Install

There is a ppa server providing a debian package (dpkg) for quick install :
```
wget -qO - https://goten.yoctu.com/archive.key | sudo apt-key add -
sudo add-apt-repository "deb https://goten.yoctu.com/ all stable"
sudo apt-get update
sudo apt-get install yosh
```

You can git clone the repository and shoot few commands to have it running :

```
git clone https://github.com/yoctu/yosh.git
sudo cp -r yosh /usr/share
```
# Librairies

Yosh provide libraries to manage a couple of external tools : databases, authentications, files..
By default a minimal number of libraries are installed. But you can add more based on your needs.

## Install/Remove Libraries

Soon to come...

## How to Use Libraries 

### Config

### Routes

### Auth

### Log

### Json

### Db

# Example

Few applications use Yosh as Framework. There might be other but the following are known by us. 
(If you use Yosh please let us know.)

## Yoctu

### Yoctapi
Provide a simple API interface to database backend.

### Yosm (ESM)
Server Manager used for Yoctu Services.

### Yoctible
Web Portal to manage Machine creation for Yoctu.

## Other

### SlotMachine
Slot Machine developed for fun.


