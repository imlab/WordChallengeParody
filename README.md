Word Challenge Parody
=====================

The parody is a mock implementation of playfish's already-offline flash game ["Word Challenge"](http://www.playfish.com/?page=game_wordchallenge), including an iOS client app, a server app(written in django) with protobuf defined service api. It is originally developed for internal testing purpose to demonstrate the client/server communication in a real time gaming with HTTP protocols.

The source code contains three parts:

1. iOS app - use Xcode to open and run in simulator or ios device.
2. django-server - you can run with django environment on your localhost or push to a remote server(tested on appfog).
3. protobuf definitions - the proto file is a reference for the service requests.

## Quick Start

### django-server setup

1. setup django environment with the following dependencies:
```text
Django==1.3.1
protobuf==2.4.1
```

2. initialize the sqlite3 database and create admin user with below commands:
```shell
cd django-server
python manage.py syncdb
```

3. (optional)if you need to push to server and use the django-admin module, you might want to copy the static resources(css,img,js) from "$PYTHON_LIB/site-packages/django/contrib/admin/media/*" to "django-server/static/admin/".

4. If you use other host to run the server app, remember to update the server host in iOS_Words/Words/ViewController.h
```objective-c
#define SERVER_HOST @"http://localhost:8000"
``` 

### protobuf usage

If you want to modify the protobuf definitions, please follow google's [protobuf guide](https://developers.google.com/protocol-buffers/docs/overview), and also need to install the [objc plugin](http://code.google.com/p/protobuf/wiki/ThirdPartyAddOns) for protobuf compiler.

To generate the source files for python and objective-c is like below:
```shell
protoc foo.proto --python_out=py --objc_out=objc
```


