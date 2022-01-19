
function arg_or_default(_arg)
{
    if(_arg == 0 && !length(_arg))
        return $0
    return _arg
}

function is_text_doc()
{
    return FILENAME ~ /.*\.(txt|md)/
}

function is_using_c_style_comments()
{
    return FILENAME ~ /\*\.(c|cc|cpp)/
}

function comment_re()
{
    if(is_text_doc())
        return "^"
    if(is_using_c_style_comments())
        return "^ *\\/(\\/|\\*)+ *"
    # TODO
    return "^ *# *"
}

function is_comment(_s)
{
    return arg_or_default(_s) ~ comment_re()
}

function comment(_s, _c)
{
    _c = arg_or_default(_s)
    if(match(_c, comment_re()))
        return substr(_c, RSTART+RLENGTH)
    return ""
}

function directive_re()
{
    return "^ *lit *"
}

function is_directive(_s)
{
    if(is_comment(_s) && comment(_s) ~ directive_re())
    {
        directive(LITDIR, _s)
        return 1
    }
    return 0
}

function directive(d, _s, _c, _n)
{
    _c = arg_or_default(_s)
    if(match(_c, directive_re()))
    {
        _n = split(substr(_c, RSTART+RLENGTH), d)
        if(_n > 1)
        {
            _c = ""
            for(_n = length(d); _n > 1; _n--)
            {
                if(!_c) _c = d[_n]
                else    _c = d[_n] " " _c
                d[_n + 1] = _d[_n]
            }
            d[2] = _c
        }
    }
    else
        split("", d)
}
