$gml_names = []
content = File.read("./rouge/gml_builtins.txt")
content.scan(/^([A-Za-z0-9_]+)(.*)$/) do |x|
    ident = x[0]
    kind = if x[1].include?("#")
        :const
    elsif x[1].include?("&")
        :err
    else
        :builtin
    end
    $gml_names.append([ident, kind])
end
$gml_constant = $gml_names
        .filter{|_, kind| kind == :const}
        .map{|ident, _| ident}
        .to_set
$gml_err = $gml_names
        .filter{|_, kind| kind == :err}
        .map{|ident, _| ident}
        .to_set
$gml_builtin = $gml_names
        .filter{|_, kind| kind == :builtin}
        .map{|ident, _| ident}
        .to_set

##
# A lexer for the GameMaker Language (GML).
class Gml < Rouge::RegexLexer
    tag "gml"
    filenames "*.gml"
    title "Gml"
    desc "The GameMaker Language"

    def builtins
        $gml_builtin
    end

    def keyword_reserved
        Set.new %w(
            begin end if then else while do for break continue
            with until repeat exit and or xor not return mod
            div switch case default var globalvar enum function
            try catch finally throw static new delete constructor
        )
    end

    def keyword_constant
        $gml_constant
    end

    def generic_deleted
        $gml_err
    end

    state :root do
        rule %r/\s+/, Text::Whitespace
        rule %r/\/\/[^\n]*/, Comment::Single
        rule %r(/\*[^*]*?\*/), Comment::Multiline
        rule %r/\d+\.\d+/, Num::Float
        rule %r/\.\d+/, Num::Float
        rule %r/\d+\./, Num::Float
        rule %r/(0x|\$|#)[A-Fa-f0-9]+/, Num::Integer
        rule %r/0b[01]+/, Num::Integer
        rule %r/\d+/, Num::Integer
        rule %r/"[^"\n]*"?/, Str
        rule %r/@'[^']*'/, Str
        rule %r/@"[^"]*"/, Str
        rule %r/^#[A-Za-z]+/, Comment::Preproc
        rule %r/[()\[\]{};,]/, Punctuation
        rule %r/[*\/!#@~&+%\\|^<>=?\-:.]/, Operator
        rule %r/[A-Za-z0-9_]+(?=\()/ do |m|
            chunk = m[0]
            if keyword_reserved.include?(chunk)
                token Keyword
            else
                token Name::Builtin
            end
        end
        rule %r/([A-Za-z0-9_])*/ do |m|
            chunk = m[0]
            #if builtins.include?(chunk)
            #    token Name::Builtin
            if keyword_reserved.include?(chunk)
                token Keyword
            elsif keyword_constant.include?(chunk)
                token Keyword::Constant
            elsif generic_deleted.include?(chunk)
                token Generic::Deleted
            elsif chunk.match?(/^[A-Z0-9_]*$/)
                token Name::Variable::Magic
            elsif chunk.match?(/^[A-Z][A-Za-z0-9_]*$/)
                token Keyword::Type
            else
                token Name::Variable
            end
        end
    end
end

##
# A lexer that extends GML with additional reserved words.
class GmlExt < Gml
    def keyword_reserved
        super.merge Set.new %w(
            elif ignore defer after implies bimplies seq print
        )
    end
end
