require 'json'
require 'tempfile'
require 'fileutils'
require 'rspec'
require 'rspec/core/formatters/json_formatter'

def prepare_file(body)
  d = Tempfile.new('test.rb')

  d << "require 'rspec'\n"
  d << body['code']
  d << "\n\n"
  d << body['codeTest']
  puts '-' * 100
  puts File.read(d.path)
  d
end

def run_test(file_path)
  config = RSpec.configuration
  formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)

  reporter =  RSpec::Core::Reporter.new(config)
  config.instance_variable_set(:@reporter, reporter)

  loader = config.send(:formatter_loader)
  notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)


  reporter.register_listener(formatter, *notifications)

  puts '-'*100
  puts file_path
  p file_path
  puts File.read(file_path)
  RSpec::Core::Runner.run([file_path])
  formatter.output_hash
end

def run(event:, context:)
  body = JSON.parse(event['body'])
  temp_dir_name = 'rspec'
  temp_file_name = 'test_spec.rb'
  temp_file_path = "./#{temp_dir_name}/#{temp_file_name}"
  temp_dir = FileUtils.mkdir(temp_dir_name)
  temp_file = File.open(temp_file_path, 'w') do |f|
    f.write("require 'rspec'\n")
    f.write(body['code'])
    f.write("\n\n")
    f.write(body['codeTest'])
  end
  result = run_test(temp_file_path)
  FileUtils.rm_rf(temp_dir_name)
  
  { statusCode: 200, body: JSON.generate(result.to_json) }
end

code = <<~EOF
  def sum(*args)
    args.inject { |sum, el| sum + el }
  end
EOF

test = <<~EOF
  describe "#sum" do
    it { expect(sum(2,3)).to eq 5 }
    it { expect(sum(2,3,4)).to eq 9 }
    it { expect(sum(2,3,4,5)).to eq 15 }
  end
EOF
run(event: { 'body' => { code: code, codeTest: test }.to_json}, context: '')
