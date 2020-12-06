require 'socket'
require 'multicast'

class MulticastClient
  def initialize(adress, port)
    @listener = Multicast::Listener.new(group: adress, port: port)
    @sender = Multicast::Sender.new(group: adress, port: port)
    Thread.new do
      @listener.listen do |message|
        puts "---> [#{message.hostname} / #{message.ip}:#{message.port} (#{message.message.size} bytes)] #{message.message}"
      end
    end
  end

  def send_message message
    @sender.send(message)
  end

  def sender
    @sender
  end

  def listener
    @listener
  end
end
