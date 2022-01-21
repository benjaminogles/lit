
function arg_or_default(_arg)
{
    if(_arg == 0 && !length(_arg))
        return $0
    return _arg
}

function strip_ext(fwithext, _pos, _chars)
{
    _pos = split(fwithext, _chars, "")
    while(_pos > 0 && _chars[_pos] != ".")
        _pos--
    return _pos > 1 ? substr(fwithext, 1, _pos-1) : ""
}

function file_is_text_doc()
{
    return FILENAME ~ /.*\.(txt|md)/
}

function file_is_using_c_style_comments()
{
    return FILENAME ~ /.*\.(c|cc|cpp)/
}

function comment_re()
{
    if(file_is_text_doc())
        return "^"
    if(file_is_using_c_style_comments())
        return "^\\/(\\/|\\*)"
    return "^#"
}

function join_fields(from_field, _i, _j)
{
    _j = ""
    for(_i = from_field; _i <= NF; _i++)
    {
        if(_j) _j = _j " " $_i
        else   _j = $_i
    }
    return _j
}

function lit_field()
{
    if(file_is_text_doc())
        return 1
    return 2
}

function record_is_comment()
{
    if($1 ~ comment_re())
    {
        COMMENT = join_fields(lit_field())
        return 1
    }
    return 0
}

function record_is_directive(_f)
{
    _f = lit_field()
    if(record_is_comment() && $_f == "lit")
    {
        _f++
        LITKEY = $_f
        LITVAL = join_fields(_f + 1)
        return 1
    }
    LITKEY = ""
    LITVAL = ""
    return 0
}
