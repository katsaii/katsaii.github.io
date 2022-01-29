##
# A lexer for the Catears language.
class Catears < Rouge::RegexLexer
    tag "catears"
    filenames "*.cate"
    title "Catears"
    desc "The Cate Language"

    def keyword_reserved
        Set.new %w(
            if else and or for while continue break def ret
            try catch throw throws use impl as
        )
    end

    def keyword_constant
        Set.new %w(true false none)
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
        rule %r/[0-9_]+\.[0-9_]+/, Num::Float
        rule %r/[0-9_]+r[A-Za-z0-9_]/, Num::Integer
        rule %r/[0-9_]+/, Num::Integer
        rule %r/"[^"]*"?/, Str
        rule %r/'[A-Za-z0-9_]+/, Str::Symbol
        rule %r/[()\[\]{};:,.]/, Punctuation
        rule %r/[*\/\\!~&+%|^<>=?\-]/, Operator
        rule %r/[A-Za-z0-9_]+(?=\()/ do |m|
            match_name(m[0], Name::Function)
        end
        rule %r/[A-Za-z_]+[A-Za-z0-9_]*/ do |m|
            match_name(m[0])
        end
    end
end
