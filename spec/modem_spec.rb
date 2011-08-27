require 'spec_helper'

describe Gsm::Modem do
	it "initializes the modem" do
		lambda do
			modem = Gsm::Mock::Modem.new
			Gsm::Modem.new(modem)
		end.should_not raise_error
	end
	
  context 'with a test modem' do
    before do
      @modem = Gsm::Mock::Modem.new		
      @gsm = Gsm::Modem.new(@modem)
    end

    it "resets the modem" do
      @modem.expects(:at_cfun).once.returns(@modem.ok)
      @gsm.reset!
    end

    it "resets the modem after 5 errors" do
      # hack to make the test run faster
      @gsm.instance_variable_set(:@retry_commands, 0)
      @modem.expects(:at_csq).twice.returns(@modem.error, @modem.rsp_csq(20))
      @modem.expects(:at_cfun).once.returns(@modem.ok)
      @gsm.signal_strength.should == 20
    end

    it "sends an sms" do
      num = '+271234567890'
      message = 'hello world'
      @modem.expects(:at_cmgs).with(num).returns(@modem.>)
      @modem.expects(:text).with(message).returns(@modem.ok)
      @gsm.send_sms(num, message)
    end

    it "calls the callback when receiving messages" do
      @gsm.instance_variable_get(:@incoming) << (msg = Gsm::Incoming.new(@gsm, 'sender', Time.at(0), 'text'))
      received = []
      @gsm.receive! { |msg| received << msg }
      received.should == [msg]

      @gsm.instance_variable_get(:@incoming).should be_empty
      @gsm.instance_variable_get(:@polled).should == 1
    end

    describe '.receive' do
      it "calls the error callback when there is an error receiving messages" do
        # Setup modem to error out when fetching stored messages, including
        # erroring on modem reset.
        @gsm.instance_variable_set(:@retry_commands, 0)
        @modem.stubs(:at_cmgl).returns(@modem.error)
        @modem.stubs(:at_cfun).returns(@modem.error)

        error = false
        error_callback = lambda do |e|
          e.should be_a(Gsm::ResetError)
          error = true
          Thread.exit
        end
        @gsm.receive(nil, 5, true, error_callback) { }

        error.should == true
      end
    end

  end

end

