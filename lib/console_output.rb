# frozen_string_literal: true

module ConsoleOutput
  def self.print(message)
    puts message
  end

  def self.print_errors(errors)
    puts "Errors:\n#{errors.join("\n")}"
  end
end
