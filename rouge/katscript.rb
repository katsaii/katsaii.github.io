##
# A lexer for the KatScript language.
class KatScript < Rouge::RegexLexer
    tag "katscript"
    filenames "*.kats"
    title "KatScript"
    desc "The KatScript Language"

    def keyword_reserved
        Set.new %w(let if else and or for while fun ret)
    end

    def keyword_constant
        Set.new %w(true false inf NaN none)
    end

    def match_name(chunk, default=Name::Variable)
        if keyword_reserved.include?(chunk)
            token Keyword
        elsif keyword_constant.include?(chunk)
            token Keyword::Constant
        elsif chunk.match?(/^[A-Z][A-Za-z0-9_]*$/)
            token Name::Class
        else
            token default
        end
    end

    state :root do
        rule %r/\s+/, Text::Whitespace
        rule %r/--[^\n]*/, Comment::Single
        rule %r/\d+\.\d+/, Num::Float
        rule %r/\d+/, Num::Integer
        rule %r/\d+r\d+/, Num::Integer
        rule %r/"[^"]*"?/, Str
        rule %r/[()\[\]{};,.]/, Punctuation
        rule %r/[*\/\\!~&+%|^<>=?\-]/, Operator
        rule %r/:\s*[A-Za-z0-9_]*/, Name::Builtin
        rule %r/:\s*[*\/\\!~&+%|^<>=?\-]*/, Name::Builtin
        rule %r/[A-Za-z0-9_]+(?=\()/ do |m|
            match_name(m[0], Name::Function)
        end
        rule %r/[A-Za-z_]+[A-Za-z0-9_]*/ do |m|
            match_name(m[0])
        end
    end
end
