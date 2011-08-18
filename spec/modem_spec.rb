require 'spec_helper'

describe Gsm::Modem do
	it "initializes the modem" do
		lambda do
			modem = Gsm::Mock::Modem.new
			Gsm::Modem.new(modem)
		end.should_not raise_error
	end
	
	it "resets the modem after 5 consecutive errors" do
		
		# this modem will return errors when AT+CSQ is
		# called, UNTIL the modem is reset. a flag is
		# also set, so we can check for the reset
		class TestModem < Gsm::Mock::Modem
			attr_reader :has_reset
			
			def at_csq(*args)
				@has_reset ? super : false
			end
			
			def at_cfun(*args)
				(@has_reset = true)
			end
		end

		# start rubygsm, and call
		# the troublesome method
		modem = TestModem.new		
		gsm = Gsm::Modem.new(modem)
		gsm.signal_strength
		
		# it should have called AT+CFUN!
		modem.has_reset.should == true
	end

  it "calls the callback when receiving messages" do
    modem = Gsm::Mock::Modem.new
    modem = Gsm::Modem.new(modem)

    # this is ugly, but I'm trying to test the callback loop
    modem.expects(:command).with('AT')
    modem.expects(:try_command).with("AT+CNMI=2,2,0,0,0")
    modem.expects(:fetch_stored_messages)
    
    modem.instance_variable_get(:@incoming) << (msg = Gsm::Incoming.new(modem, 'sender', Time.at(0), 'text'))

    received = []
    modem.receive! do |msg|
      received << msg
    end

    received.should == [msg]

    modem.instance_variable_get(:@incoming).should be_empty
    modem.instance_variable_get(:@polled).should == 1
  end
end

