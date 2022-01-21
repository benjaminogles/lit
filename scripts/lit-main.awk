
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
    if(LITKEY == "run" || LITKEY == "sub")
    {
        if(length(LITVAL))
        {
            if(LITKEY == "run")
            {
                print "```"
                print LITVAL
                print "```"
            }
            system(LITVAL)
        }
        else if(!file_is_text_doc())
        {
            print "```"
            print "TODO build/run file with options: '" LITVAL "'"
            print "```"
        }
    }
    if(LITKEY == "tee" || LITKEY == "pipe")
    {
        PIPE_TEE = (LITKEY == "tee")
        PIPE_COMMAND = LITVAL
        transition(PIPE_NEXT)
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
state == PIPE { print "TODO " $0 " | " PIPE_COMMAND }
state == TEXT && !record_is_comment() { transition(START) }
state == TEXT { print COMMENT }
state == START && length($0) { transition(CODE) }
state == CODE { print }
