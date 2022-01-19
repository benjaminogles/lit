
function meta_tag(k, v)
{
    return "    <meta name=\"" k "\" content=\"" v "\">" 
}

function title_tag(t)
{
    return "    <title>" t "</title>"
}

is_directive() {
    if(LITDIR[1] == "title")
        print title_tag(LITDIR[2])
    else if(LITDIR[1] == "author" || LITDIR[1] == "description")
        print meta_tag(LITDIR[1], LITDIR[2])
}
