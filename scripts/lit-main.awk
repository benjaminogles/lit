
function starting_code_block(nstate)
{
    return state != nstate && nstate == CODE
}

function ending_code_block(nstate)
{
    return state != nstate && state == CODE
}

function transition(nstate) {
    if(starting_code_block(nstate) || ending_code_block(nstate))
        print "```"
    if(state == TEXT)
        print ""
    if(state == PIPE)
    {
        if(pipe_tee)
        {
            print "```"
            for(pipe_line = 1; pipe_line <= pipe_lines; pipe_line++)
                print pipe_text[pipe_line]
            print "```"
        }
        print "```"
        for(pipe_line = 1; pipe_line <= pipe_lines; pipe_line++)
            print pipe_text[pipe_line] | pipe_command
        print "```"
        pipe_lines = 0
        close(pipe_command)
    }
    state = nstate
}

BEGIN {
    START = 0
    CODE = 1
    TEXT = 2
    SKIP = 3
    PIPE_NEXT = 4
    PIPE = 5
    state = START
}

record_is_directive() {
    if(LITKEY == "exe" || LITKEY == "sub")
    {
        if(length(LITVAL))
        {
            print "```"
            if(LITKEY == "exe")
            {
                print LITVAL
                print ""
            }
            if(system(LITVAL))
            {
                print "ERROR: command failed"
                if(LITKEY == "sub")
                    print "  command was " LITVAL
            }
            print "```"
        }
    }
    if(LITKEY == "run")
    {
        if(!file_is_text_doc())
        {
            build_command = build_command_for_file()
            run_command = run_command_for_file()
            if(length(build_command))
            {
                print "```"
                print build_command
                print ""
                if(system(build_command))
                    print "ERROR: build command failed"
                close(build_command)
                print "```"
            }
            if(length(run_command))
            {
                print "```"
                print run_command
                print ""
                if(system(run_command))
                    print "ERROR: run command failed"
                close(build_command)
                print "```"
            }
        }
    }
    if(LITKEY == "tee" || LITKEY == "pipe")
    {
        if(length(LITVAL))
        {
            pipe_tee = (LITKEY == "tee")
            pipe_command = LITVAL
            transition(PIPE_NEXT)
        }
    }
    if(LITKEY == "skip")
        transition(SKIP)
    if(LITKEY == "unskip" && state == SKIP)
        transition(START)
    if(LITKEY == "text")
        transition(TEXT)
    if(LITKEY == "title")
        print "# " LITVAL
    next
}

state == SKIP { next }
state == PIPE_NEXT && !record_is_comment() && length($0) { transition(PIPE) }
state == PIPE && record_is_comment() { transition(START) }
state == PIPE { pipe_text[++pipe_lines] = $0 }
state == TEXT && !record_is_comment() { transition(START) }
state == TEXT { print COMMENT }
state == START && length($0) { transition(CODE) }
state == CODE { print }
