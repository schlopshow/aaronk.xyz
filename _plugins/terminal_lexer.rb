# frozen_string_literal: true

require 'rouge'

module Rouge
  module Lexers
    class Terminal < Rouge::RegexLexer
      title "Terminal"
      desc "Terminal/Console output with variable highlighting"
      tag 'terminal'
      aliases 'console', 'shell-session', 'plaintext', 'text'
      filenames '*.terminal', '*.console', '*.txt'

      state :root do
        # Variables starting with $ (GREEN)
        rule %r/\$[A-Za-z_][A-Za-z0-9_]*/, Name::Variable

        # IP addresses
        rule %r/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/, Num

        # Port numbers
        rule %r/\d+\/tcp|\d+\/udp/, Num

        # Numbers
        rule %r/\d+/, Num

        # Strings
        rule %r/'[^']*'/, Str::Single
        rule %r/"[^"]*"/, Str::Double

        # Command names at start of line or after prompt
        rule %r/^([a-z][a-z0-9_-]*)/i, Name::Builtin
        rule %r/\s([a-z][a-z0-9_-]*)/i, Name::Builtin

        # Flags/options
        rule %r/-[A-Za-z][A-Za-z0-9_-]*/, Name::Tag
        rule %r/--[A-Za-z-]+/, Name::Tag

        # Everything else
        rule %r/./, Text
        rule %r/\n/, Text
      end
    end
  end
end
