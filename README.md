# YOSH (Yoctu Shell) - Bash Micro Web Framework lib

Yosh Provide a bash framework for api and applications.
It is fully written in bash and aims to be easy to use. It provides the required feature of a web framework.
We recommend to use [yoctu-starter-kit](https://github.com/yoctu/yoctu-starter-kit) to build a new application.

---

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

---



# Librairies

Yosh provide libraries to manage a couple of external tools : databases, authentications, files..
By default a minimal number of libraries are installed. But you can add more based on your needs.

## Install/Remove Libraries

Soon to come...

## How to Use Libraries 

### Type

#### Type::array
- **Type::array::fusion srcArray dstArray Regex(Optional)** : merge 2 associative arrays into 1 array. Output Array is Array2.

Example without regex:
```
Type::array::fusion array1 array2
```

Ex with regex, the regex will only fusion the matching keys: 
```
Type::array::fusion array1 array2 "testkeys::.*"
```
- **Type::array::get::key Array Regex** : list all matching keys

Example:
```
Type::array::get::key array1 "testkeys::.*"
```
- **Type::array::contains array string** : Check if array contains a matching value

Example:
```
Type::array::contains array testing
```
- **Type::array::is::assoc array** : check if array is associative

Example:
```
Type::array::is::assoc array
```
- **Type::fusion::array::in::assoc array assoc** : Fusion an array in associative array

Example:
```
Type::fusion::array::in::assoc array assoc
```
#### Type::variable
- **Type::variable::set variable ** : check if the following variables are set 

Example:
```
Type::variable::set variable1 variable2
```
#### Type::function
- **Type::function::exist function** : Check if a function exist

Example:
```
Type::function::exist function1 function2
```
#### Type::command
- **Type::command::exist command** : Check if command exist

Example:
```
Type::command::exist command1 command2
```
### Config

### Routes

### Auth

### Log

### Json
- **Json::create Array** : output a json based on a Array input

Example:
```
Json::create Array
```
- **Json::to::array Array JsonData** : create an associative Array from json format data 

Example:
```
Json::to::array array "Json"
```

### Db

---


# Example

Few applications use Yosh as Framework. There might be other but the following are known by us. 
(If you use Yosh please let us know.)

## Yoctu

### Yoctapi
Provide a simple API interface to database backend :
[https://github.com/yoctu/yoctapi](https://github.com/yoctu/yoctapi "Yoctapi Homepage")

### Yosm (ESM)
Server Manager used for Yoctu Services :
[https://github.com/yoctu/yosm](https://github.com/yoctu/yosm "Yosm Homepage")

### Yoctible
Web Portal to manage Machine creation for Yoctu :
[https://github.com/yoctu/yoctible](https://github.com/yoctu/yoctible "Yoctible Homepage")

## Other

### SlotMy
Slot Machine developed for fun :
[https://github.com/lvenier/slotmy](https://github.com/lvenier/slotmy "SlotMy Homepage")

---


# Contributors

- [Dzove855](https://github.com/dzove855 "Dzove855 Homepage") : Main (and unique) Developer...

- [LaV](https://github.com/lvenier "LaV Homepage") : Main developer Bottom Kicker...


![Yoctu](https://www.yoctu.com/wp-content/themes/yoctu/images/logo.svg "Yoctu")
