require 'json'
require 'rspec'
require 'rspec/core/formatters/json_formatter'

require_relative './rspec_temp'
require_relative './rspec_result_formatter'

class RspecTester
  class << self
    def call(**args)
      new(**args).call
    end
  end

  def initialize(event:, context:)
    @event = event
    @context = context
    @body = JSON.parse(event['body'])
  end

  def call
    file = prepare_file
    run_result = run_tests(file.path)
    result = RspecResultFormatter.call(run_result)

    file.flush

    {
      statusCode: 200,
      body: { data: result }.to_json
    }
  end
  
  private

  def prepare_file
    RspecTemp.new('test_spec.rb').tap do |f|
      f.write("require 'rspec'")
      f.write("\n\n")
      f.write(@body['code'])
      f.write("\n\n")
      f.write(@body['codeTest'])
      f.close
    end
  end

  def run_tests(file_path)
    config = RSpec.configuration
    formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)

    reporter =  RSpec::Core::Reporter.new(config)
    config.instance_variable_set(:@reporter, reporter)

    loader = config.send(:formatter_loader)
    notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)


    reporter.register_listener(formatter, *notifications)

    RSpec::Core::Runner.run([file_path])
    formatter.output_hash
  end
end


#code = <<~EOF
  #def sum(*args)
    #args.inject { |sum, el| sum + el }
  #end
#EOF

#test = <<~EOF
  #describe "#sum" do
    #it { expect(sum(2,3)).to eq 5 }
    #xit { expect(sum(2,3,4)).to eq 9 }
    #it { expect(sum(2,3,4,5)).to eq 14 }
  #end
#EOF
#res = RspecTester.call(event: { 'body' => { code: code, codeTest: test }.to_json}, context: '')

#p "\n"
#p '_'*100
#p res
