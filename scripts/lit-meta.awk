
function is_meta_key(k) {
    return k == "author" || k == "description"
    }

function is_open_graph_key(k) {
    return k == "title" || k == "type" || k == "url" || k == "description" || k == "image"
    }

function meta_tag(k, v) {
    return "<meta name=\"" k "\" content=\"" v "\">" 
    }

function open_graph_tag(k, v) {
    return "<meta property=\"og:" k "\" content=\"" v "\">"
    }

function title_tag(t) {
    return "<title>" t "</title>"
    }

BEGIN                                      { enabled=0 }
!enabled && /^[ #;\/]*lit-meta/            { enabled=1 }
enabled && /^[ #;\/]*lit(-end)?[ #;\/]*$/  { enabled=0 }
enabled && !key && /^[ #;\/]*title/        { key="title" }
enabled && !key && /^[ #;\/]*author/       { key="author" }
enabled && !key && /^[ #;\/]*description/  { key="description" }
enabled && !key && /^[ #;\/]*image/        { key="image" }
enabled && !key && /^[ #;\/]*url/          { key="url" }
key                                        { match($0, key) }
key && RSTART                              { value=substr($0, RSTART+RLENGTH+1) }
key && value {
    if(key == "title")
        print title_tag(value)
    if(is_meta_key(key))
        print meta_tag(key, value)
    if(is_open_graph_key(key))
        print open_graph_tag(key, value)
}

{
    key = ""
    value = ""
}
