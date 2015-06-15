require 'calabash'

platform = Calabash::Environment.variable('PLATFORM')

case platform
  when 'android'
    require 'calabash/android'

    World(Calabash::Android)

    identifier = Calabash::Android::Device.default_serial
    server = Calabash::Android::Server.default

    # Setup the default device
    Calabash::Device.default =
        Calabash::Android::Device.new(identifier, server)

    # Setup the default application
    Calabash::Application.default =
        Calabash::Android::Application.default_from_environment
  when 'ios'
    require 'calabash/ios'

    World(Calabash::IOS)

    #identifier = Calabash::IOS::Device.default_serial
    server = Calabash::IOS::Server.default

    # Setup the default device
    Calabash::Device.default =
        Calabash::IOS::Device.new(nil, server)

    # Setup the default application
    Calabash::Application.default =
        Calabash::IOS::Application.default_from_environment
  else
    message = if platform.nil? || platform.empty?
                'No platform given'
              else
                "Invalid platform '#{platform}'. Expected 'android' or 'ios'"
              end

    failure_messages =
        [
            'ERROR! Unable to start the cucumber test:',
            message,
            "Use the profile 'android' or 'ios', or run cucumber using $ calabash run"
        ]

    Calabash::Logger.error(failure_messages.join("\n"))
    exit(1)
end