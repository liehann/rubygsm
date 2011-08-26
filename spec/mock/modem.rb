#!/usr/bin/env ruby
# vim: noet

module Gsm
	module Mock
		class Modem
			attr_accessor :echo
			
			def initialize
				@echo = true
				
				@in = ""
				@out = ""
			end
			
			# => obj
			def putc(obj)
				# puts "PUTC: #{obj.inspect}"
				
				# accept numeric/string args like IO.putc
				# http://www.ruby-doc.org/core/classes/IO.html#M002276
				chr = (obj.is_a?(Numeric) ? obj.chr : obj.to_s[0])
				@in << chr
				
				# character echo, if required
				@out << chr if(@echo)
				
				# if this character is a terminator (13.chr (\r)), 
				# interpret and clear the @incoming buffer
				if @in[-1] == 13 || @in[-1] == 26
					output(process(@in[0..-2].strip))
					@in = ""
				end
			end
			

			# Returns the first byte (er, actually, the first CHARACTER,
			# which will no-doubt be a future source of bugs) of the
			# output buffer, or nil, if it's empty.
			def getc
				# puts "GETC: #{@out.inspect}"
				(@out.empty?) ? nil : @out.slice!(0)
			end
			
			def output(str)
				@out << "\r\n#{str}\r\n"
			end
			
			def method_for(cmd)
				if cmd == 'AT'
					return :at, []
				elsif m = cmd.match(/^AT\+([A-Z\?]+)(?:=(.+))?$/)
					# catch and parse AT commands, and process
					# them via an instance method of this class
					cmd, flat_args = *m.captures
					meth = "at_#{cmd.downcase}"
					args = parse_args(flat_args)

					return meth, args
					
				elsif m = cmd.match(/^ATE[01]$/)
					# enable (ATE1) or disable (ATE0) character echo [104]
					return :ate, m.captures[0]
					# @echo = (m.captures[0] == "1") ? true : false
					# return ok

				else
					# when an sms is sent we read a line that is just text
					return :text, [cmd]
				end
			end

			def process(cmd)
				method, args = method_for(cmd)
				return send(method, *args)
			ensure
				@previous_method = method.to_sym
			end
			
			# Returns the argument portion of an AT command
			# split into an array. This isn't as robust as a
			# real modem, but works for RubyGSM.
			def parse_args(str)
				str.to_s.split(",").collect do |arg|
					arg.strip.gsub('"', "")
				end
			end
			
			# ===========
			# AT COMMANDS
			# ===========

			def ate(*args)
				@echo = args[0] == '1'
				ok
			end
			
			def at_cmee(bool)
				ok
			end
			
			def at_wind(bool)
				ok
			end
			
			def at_cmgf(bool)
				ok
			end
		
			def at_csq(*args)
				# return a signal strength of somewhere between 20 and 80
				rsp_csq(rand(60) + 20)
			end

			# Reset
			def at_cfun(*args)
				return ok
			end

			# Send SMS
			def at_cmgs(num)
				return self.>
			end

			# Unrecognized command.
			def text(line)
				# If the previous line was a send sms command return ok,
				# otherwise return error.
				return @previous_method == :at_cmgs ? ok : error
			end

			def at_cnmi(*args)
				ok
			end

			def at_cmgl(*args)
				ok
			end

			def at
				ok
			end

			# ========
			# Response Generators
			# ========

			def error
				"ERROR"
			end
			
			def ok(msg = nil)
				[ msg, "OK" ].compact.join("\r\n")
			end
			
			def >
				"> "
			end

			def rsp_csq(signal_strength)
				ok("+CSQ: #{signal_strength},0")
			end

		end
	end
end
