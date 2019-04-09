class RspecResultFormatter
  class << self
    def call(input)
      new(input).call
    end
  end

  def initialize(input)
    @input = input
    @passed_tests = 0
    @failed_tests = 0
    @pending_tests = 0
  end

  def call
    {
      results: prepare_results,
      numPassedTests: @passed_tests,
      numFailedTests: @failed_tests,
      numPendingTests: @pending_tests,
      numTotalTests: count_total_tests,
      finalResult: prepare_final_result
    }
  end

  private

  def inc(name)
    current_value = instance_variable_get("@#{name}".to_sym)
    instance_variable_set("@#{name}", current_value + 1)
  end

  def prepare_results
    @input[:examples].map do |example|
      case example[:status]
      when 'passed'
        inc(:passed_tests)
      when 'failed'
        inc(:failed_tests)
      when 'pending'
        inc(:pending_tests)
      end

      {
        fullName: example[:full_description],
        status:   example[:status]
      }
    end
  end

  def count_total_tests
    @passed_tests + @failed_tests + @pending_tests
  end

  def prepare_final_result
    @failed_tests.zero? ? 'passed' : 'failed'
  end
end
