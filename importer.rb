require_relative "controller"

argument = ARGV[0]
realestate_id = argument.split('-').last.to_i

controller = Controller.new(realestate_id)
controller.run