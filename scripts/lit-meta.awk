
function meta_tag(k, v)
{
    return "    <meta name=\"" k "\" content=\"" v "\">" 
}

function title_tag(t)
{
    return "    <title>" t "</title>"
}

record_is_directive() {
    if(LITKEY == "title")
        print title_tag(LITVAL)
    else if(LITKEY == "author" || LITKEY == "description")
        print meta_tag(LITKEY, LITVAL)
}
