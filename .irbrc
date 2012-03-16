require 'irb/completion'
require 'irb/ext/save-history'

ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

IRB.conf[:HISTORY_FILE] = File.expand_path('~/.irb_history')
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true

require 'rubygems'
begin
  require 'ap'
  unless ENV['DISABLE_AP']
    unless IRB.version.include?('DietRB')
      IRB::Irb.class_eval do
        def output_value
          ap @context.last_value
        end
      end
    else # MacRuby
      IRB.formatter = Class.new(IRB::Formatter) do
        def inspect_object(object)
          object.ai
        end
      end.new
    end
  end
rescue LoadError
  puts "IRB was initialized without awesome_print support: 'gem install awesome_print' to enable this functionality."
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

def copy(string)
  IO.popen('pbcopy', 'w') { |f| f << string.to_s }
  "Copied '#{string.to_s}' to the clipboard"
end

def paste
  `pbpaste`
end

railsrc_path = File.expand_path('~/.railsrc')
if ( ENV['RAILS_ENV'] || defined? Rails ) && File.exist?( railsrc_path )
  begin
    load railsrc_path
  rescue Exception => ex
    warn "Could not load: #{ railsrc_path }" # because of $!.message
    puts ex.to_s
    puts ex.backtrace.join("\n")
  end
end