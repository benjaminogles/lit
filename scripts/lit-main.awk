
function transition(nstate) {
    if(state != nstate && (state == CODE || state == RUN || nstate == CODE || nstate == RUN))
        print "```"
    if(state == TEXT)
        print ""
    if(nstate == RUN)
        print "TODO run code with opts: '" RUNOPTS "'"
    state = nstate
}

BEGIN {
    START = 0
    CODE = 1
    TEXT = 2
    SKIP_NEXT = 3
    SKIP_CODE = 4
    SKIP_TEXT = 5
    RUN_NEXT = 6
    RUN = 7
    state = START
}

record_is_directive() {
    if(LITKEY == "title")
        print "# " LITVAL
    if(LITKEY == "text")
        transition(TEXT)
    if(LITKEY == "run")
    {
        if(file_is_text_doc())
        {
            print "```"
            print LITVAL
            print "```"
            system(LITVAL)
        }
        else
        {
            RUNOPTS = LITVAL
            transition(RUN_NEXT)
        }
    }
    if(LITKEY == "skip")
        transition(SKIP_NEXT)
    if(LITKEY == "unskip" && (state == SKIP_NEXT || state == SKIP_CODE || state == SKIP_TEXT))
        transition(START)
    next
}

state == SKIP_TEXT && !record_is_comment() { transition(START) }
state == TEXT && !record_is_comment() { transition(START) }
state == RUN && record_is_comment() { transition(START) }
state == START && length($0) { transition(CODE) }

state == SKIP_NEXT {
    if(record_is_comment())
        transition(SKIP_TEXT)
    else if(length($0))
        transition(SKIP_CODE)
}

state == CODE { print }
state == TEXT { print COMMENT }

state == RUN_NEXT && length($0) && !record_is_comment() { transition(RUN) }
state == RUN { print "TODO " $0 }

END {
    if(state == RUN_NEXT)
    {
        print "```"
        print "TODO: run file"
        print "```"
    }
}
