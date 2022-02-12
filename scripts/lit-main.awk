
function try_python_repl_init()
{
    if(BREAKPOINT_FIFO && FILENAME ~ /\.py$/)
    {
        repl_out = "python3"
        repl_in = BREAKPOINT_FIFO
        while((getline < FILENAME) > 0)
        {
            if(record_is_directive() && LITKEY == "execute" && !length(LITVAL))
            {
                print "print('lit breakpoint', flush=True)" |& repl_out
                print "with open('" BREAKPOINT_FIFO "', 'r') as lit_breakpoint_fifo:" |& repl_out
                print "    _ = lit_breakpoint_fifo.readline()" |& repl_out
            }
            else
            {
                print $0 |& repl_out
            }
        }
        close(FILENAME)
        close(repl_out, "to")
        return 1
    }
    return 0
}

function try_repl_init() {
    return try_python_repl_init()
}

function try_repl_cleanup() {
    if(repl_in)
        close(repl_in)
    if(repl_out)
        close(repl_out)
}

function basename(fname, _n, _parts)
{
    _n = split(fname, _parts, "/")
    return _parts[_n]
}

function join_fields(from_field, _i, _s)
{
    _s = ""
    for(_i = from_field; _i <= NF; _i++)
    {
        if(_s) _s = _s " " $_i
        else   _s = $_i
    }
    return _s
}

function file_language()
{
    if(FILENAME ~ /.*\.c$/)
        return "c"
    else if(FILENAME ~ /\.(h|hh|hpp|hxx|cc|cpp|cxx)$/)
        return "cpp"
    else if(FILENAME ~ /\.py$/)
        return "python"
    return "plaintext"
}

function file_is_using_c_style_comments()
{
    return FILENAME ~ /\.(h|c|cc|hh|cpp|hpp|cxx|hxx)$/
}

function comment_re()
{
    if(file_is_using_c_style_comments())
        return "^\\/+"
    return "^#"
}

function record_is_comment()
{
    if($1 ~ comment_re())
    {
        COMMENT = join_fields(2)
        return 1
    }
    return 0
}

function record_is_directive()
{
    if(record_is_comment() && $2 == "lit")
    {
        LITKEY = $3
        LITVAL = join_fields(4)
        return 1
    }
    LITKEY = ""
    LITVAL = ""
    return 0
}

function init_or_insert_figures(_init, _command, _output, _parts, _name, _mtime)
{
    _command = "find . -maxdepth 1 -type f -name '*.png' -printf '%p|' -exec date +%H%M%N -r {} \\;"
    while((_command | getline _output) > 0)
    {
        split(_output, _parts, "|")
        _name = _parts[1]
        _mtime = _parts[2]
        if(!_init)
        {
            if(!FIGURES[_name]) FIGURES[_name] = _mtime - 1
            if(_mtime > FIGURES[_name])
            {
                if(system("cp " _name " " OUTPUT_DIR "/" FIGURES_DIR "/" basename(_name)))
                    print "Failed to copy figure to output directory"
                else
                    print "![](" FIGURES_DIR "/" basename(_name) ")"
            }
        }
        FIGURES[_name] = _mtime
    }
    close(_command)
}

function starting_code_block(nstate)
{
    return state != nstate && nstate == CODE
}

function ending_code_block(nstate)
{
    return state != nstate && state == CODE
}

function transition(nstate) {
    if(state == TEXT)
        print ""
    if(starting_code_block(nstate))
        print "```" file_language()
    else if(ending_code_block(nstate))
        print "```"
    state = nstate
    nblank = 0
}

BEGIN {
    START = 0
    CODE = 1
    TEXT = 2

    state = START
    skipping = 0
    nblank = 0

    if(!length(OUTPUT_DIR))
        OUTPUT_DIR = "."
    if(!length(FIGURES_DIR))
        FIGURE_DIR = "."
    init_or_insert_figures(1)
}

FNR == 1 {
    # FIXME skips first line in input file
    if(try_repl_init())
        next
}

record_is_directive() {
    if(LITKEY == "text")
        transition(TEXT)
    else if(LITKEY == "skip")
        skipping = 1
    else if(LITKEY == "unskip")
        skipping = 0
    else if(LITKEY == "title")
        print "# " LITVAL
    else if(LITKEY == "execute")
    {
        if(state == CODE)
            transition(START)

        if(length(LITVAL))
        {
            print "```sh"
            print LITVAL
            print "```"

            while(1)
            {
                status = (LITVAL | getline output)
                if(status == 0)
                    break;
                else if(status != 1)
                {
                    execute_lines[++num_execute_lines] = "ERROR: command failed"
                    break;
                }
                else
                    execute_lines[++num_execute_lines] = output
            }
            close(LITVAL)
        }
        else if(repl_in && repl_out)
        {
            while(1)
            {
                status = (repl_out |& getline output)
                if(status == 0)
                {
                    repl_command = "lit quit"
                    break;
                }
                else if(output == "lit breakpoint")
                {
                    repl_command = "lit continue"
                    break;
                }
                else if(status != 1)
                {
                    execute_lines[++num_execute_lines] = "ERROR: repl interaction failed"
                    break;
                }
                else
                    execute_lines[++num_execute_lines] = output
            }
        }
        else
            execute_lines[++num_execute_lines] = "ERROR: no active repl"

        if(num_execute_lines)
        {
            print "```plaintext"
            for(i = 1; i <= num_execute_lines; i++)
                print execute_lines[i]
            print "```"
        }
        num_execute_lines = 0

        init_or_insert_figures()

        if(repl_command)
        {
            print repl_command > repl_in
            close(repl_in)
            repl_command = ""
        }
    }
    next
}

skipping { next }
state == TEXT && !record_is_comment() { transition(START) }
state == TEXT { print COMMENT }
state == START && length($0) { transition(CODE) }
state == CODE {
    if(length($0))
    {
        for(i = 1; i <= nblank; i++)
            print ""
        print
        nblank = 0
    }
    else
        nblank++
}

END {
    try_repl_cleanup()
}
