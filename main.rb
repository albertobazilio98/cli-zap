require 'socket'
require 'multicast'
require 'byebug'

class MulticastClient
  def initialize(adress, port, name)
    @listener = Multicast::Listener.new(group: adress, port: port)
    @sender = Multicast::Sender.new(group: adress, port: port)
    @name = name
    @leader = false
    @election = false
    @messages = []
    @unseen_by_leader = []
    @joined_at = Time.now.to_f
    @join_times = []

    Thread.new do
      @listener.listen do |message|
        puts "#{message.message}" if !is_system_message?(message)
        # puts is_system_message?(message)
        send_leader_response if @leader && !is_system_message?(message)
        add_message_to_box(message)
      end
    end
    Thread.new do
      loop do
        sleep(1)
        next if @unseen_by_leader.size.zero?
        next if (Time.now.to_f - @unseen_by_leader.first[:time]) < 5
        start_election unless @election
      end
    end
    join_session
  end

  def add_message_box
    @messages
  end

  def send_message message
    @sender.send("#{@name}: #{message}")
  end

  def sender
    @sender
  end

  def listener
    @listener
  end

  private

  def add_message_to_box message
    @messages << message
    @unseen_by_leader << { message: message, time: Time.now.to_f } if not is_system_message?(message)
    @unseen_by_leader.shift if is_leader_response?(message)
    @join_times << message.message[10..-1].to_f if is_election_message?(message)
  end

  def join_session
    @sender.send("join: #{@name} joined the session")
  end

  def is_leader_response? message
    message.message.to_s.start_with?('sys: seen by leader')
  end

  def is_system_message? message
    message.message.to_s.start_with?('sys:')
  end

  def send_leader_response
    @sender.send('sys: seen by leader')
  end

  def is_election_message? message
    message.message.to_s.start_with?('election:')
  end

  def start_election
    @election = true
    @unseen_by_leader = []
    puts 'inicia sabagaça'
    @sender.send("election: #{@joined_at}")
    Thread.new do
      sleep(5)
      @leader = @join_times.all? do |join_time|
        @joined_at >= join_time
      end
      @join_times = []
      @unseen_by_leader = []
      @election = false
    end
  end
end

a = MulticastClient.new('224.0.1.33', 3000, 'alberto')

loop do
  user_input = gets.chomp
  $stdout.flush
  puts '\bbatata'
  a.send_message user_input
end
