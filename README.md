# threaded_server

* [Homepage](http://github.com/postmodern/threaded_server)
* [Documentation](http://rubydoc.info/gems/threaded_server/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A generic TCP Server with a fixed-size Thread Pool.

## Examples

    require 'threaded_server'

    ThreadedServer.open('127.0.0.1',8080) do |socket|
      socket.puts Time.now
    end

## Install

    $ gem install threaded_server

## Copyright

Copyright (c) 2011 Hal Brodigan

See {file:LICENSE.txt} for details.
