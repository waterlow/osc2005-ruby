require './pukipa'
require './pukiwikiparser'
require 'benchmark'
require 'digest/md5'

def main
  body = File.read('input.puki')
  page_names = ['文法', '自動リンク']
  case ARGV[0]
  when 'benchmark'
    exec_benchmark body, page_names
  when '1prof'
    (ARGV[1] || 1).to_i.times do
      parse1(body, page_names)
    end
  when '2prof'
    (ARGV[1] || 1).to_i.times do
      parse2(body, page_names)
    end
  when '1'
    puts parse1(body, page_names)
  when 'version_up'
    puts parse1(body, page_names) == File.read('./output1.puki').chomp
    puts parse2(body, page_names) == File.read('./output1.puki').chomp
  else
    puts parse2(body, page_names)
  end
end

def exec_benchmark(body, page_names)
  n = (ARGV[1] || 1).to_i
  Benchmark.bm(16) {|x|
    x.report('original') {
      n.times do
        parse1(body, page_names)
      end
    }
    x.report('aamine') {
      n.times do
        parse2(body, page_names)
      end
    }
  }
end

def parse1(body, page_names)
  pukipa = Pukipa.new(body)
  pukipa.pagelist page_names
  pukipa.to_html
end

def parse2(body, page_names)
  #logger = new_logger()
  logger = DummyLogger.new
  PukiWikiParser.new(logger).to_html(body, page_names)
end

def new_logger
  logger = Logger::new($deferr)
  if $DEBUG
    logger.level = Logger::DEBUG
  else
    logger.level = ($VERBOSE ? Logger::INFO : Logger::WARN)
  end
  logger
end

class DummyLogger
  def debug(msg)
    #$stderr.puts msg
  end
end

main
