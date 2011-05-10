require 'socket'
require 'thread'

#
# A generic TCP Server with a fixed-size Thread Pool.
#
class ThreadedServer

  # Default maximum number of Connections
  MAX_CONNECTIONS = 64

  # The host the server will listen on
  attr_reader :host

  # The port the server will listen on
  attr_reader :port

  # The maximum number of active connections
  attr_reader :max_connections

  #
  # Creates a new Threaded Server.
  #
  # @param [IPAddr, String] host
  #   The host to listen on.
  #
  # @param [Integer] port
  #   The port to listen on.
  #
  # @param [Hash] options
  #   Additional options.
  #
  # @option options [Integer] :max_connections (MAX_CONNECTIONS)
  #   The maximum number of active connections.
  #
  # @option options [#call] :handler
  #   The handler that will be passed new connections.
  #
  # @yield [connection]
  #   If a block is given, it will be passed the new connections.
  #
  # @yieldparam [TCPSocket] connection
  #   A new connection.
  #
  def initialize(host,port,options={},&block)
    @host = host.to_s
    @port = port

    @max_connections = options.fetch(:max_connections,MAX_CONNECTIONS)
    @queue = SizedQueue.new(@max_connections)
    @handler = options.fetch(:handler,block)

    @thread_pool = Array.new(@max_connections) do
      Thread.new do
        loop do
          # receive a pending connection
          client = @queue.pop

          begin
            # handle the connection
            @handler.call(client)
          rescue => error
            on_error(client,error)
          end

          # close the connection
          client.close
        end
      end
    end
  end

  #
  # Creates a new Threaded Server and begins listening for connections.
  #
  # @param [IPAddr, String] host
  #   The host to listen on.
  #
  # @param [Integer] port
  #   The port to listen on.
  #
  # @param [Hash] options
  #   Additional options.
  #
  # @option options [Integer] :max_connections (MAX_CONNECTIONS)
  #   The maximum number of active connections.
  #
  # @option options [#call] :handler
  #   The handler that will be passed new connections.
  #
  # @yield [connection]
  #   If a block is given, it will be passed the new connections.
  #
  # @yieldparam [TCPSocket] connection
  #   A new connection.
  #
  # @see #listen
  #
  def self.open(host,port,options={},&block)
    server = new(host,port,options,&block)
    server.listen
  end

  #
  # Opens a listening TCP socket and begins accepting connections.
  #
  def listen
    @server = TCPServer.new(@host,@port)

    @server.listen(@max_connections)

    loop do
      client = begin
                 @server.accept
               rescue
                 next
               end

      on_connect(client)
      @queue.push(client)
    end
  end

  #
  # Closes the listening TCP socket.
  #
  def close
    @server.close
  end

  protected

  #
  # Place holder method that will be passed newly connected sockets.
  #
  # @param [TCPSocket] socket
  #   The newly connected socket.
  #
  def on_connect(socket)
  end

  #
  # Place holder method that will be passed soon to be closed sockets.
  #
  # @param [TCPSocket] socket
  #   The socket that will be closed.
  #
  def on_disconnect(socket)
  end

  #
  # Place holder method that will be passed any exceptions that occurred.
  #
  # @param [TCPSocket] socket
  #   The socket that raised the exception.
  #
  # @param [Exception] error
  #   The exception.
  #
  def on_error(socket,error)
    STDERR.puts "#{error.class}: #{error.message}"
  end

end
