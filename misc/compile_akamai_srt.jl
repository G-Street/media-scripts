using HTTP

SRT_MILISECOND_RE = r"(\d\d).(\d\d\d)"
SRT_TS_RE = r"(\d\d):(\d\d):(\d\d),(\d\d\d)"
SRT_TS_RE_MALFORMED = r"(\d\d:\d\d,\d\d\d)"

function parse_subtitle_segment(url::String, i::Int = 1)
    seg_req = HTTP.get(url)
    # sub_seg = String(seg_req.body)
    line_itr = eachline(IOBuffer(seg_req.body))
    for _ in 1:3  # discard first three lines (metadata)
        iterate(line_itr)
    end
    out_seg = IOBuffer()
    for line in line_itr
        # https://docs.fileformat.com/video/srt/
        if contains(line, "-->")
            # Print number subtitle
            println(out_seg, i)
            i += 1
            # Modify timestamp milisecond format
            line = replace(line, SRT_MILISECOND_RE => s"\1,\2")
            # Both components of the timestamp shoud have the hours section, as srt can't infer
            hour_match = findall(SRT_TS_RE, line)
            if length(hour_match) < 2
                # Then we probably need to add the hour mark
                @assert(occursin(SRT_TS_RE_MALFORMED, line))
                line = replace(line, SRT_TS_RE_MALFORMED => s"00:\1")
                @assert(occursin(SRT_TS_RE, line))
            end
        end
        println(out_seg, line)
    end
    return take!(out_seg), i
end

function main(segment_url::String)
    @info("Obtaining subtitle segment URLs from \"$segment_url\"")
    segment_urls_req = HTTP.get(segment_url)
    segment_itr = eachline(IOBuffer(segment_urls_req.body))
    i = 1
    open("main.srt", "w") do out_io
        for segment_url_line in segment_itr
            startswith(segment_url_line, '#') && continue
            isempty(strip(segment_url_line)) && continue
            @info("Parsing URL \"$segment_url_line\"")
            sub_seg, i = parse_subtitle_segment(segment_url_line, i)
            write(out_io, sub_seg)
        end
    end
    
    return "main.srt"
end

main("https://manifest.prod.boltdns.net/manifest/v1/hls/v4/clear/6005208634001/6b9f14c3-3d1c-47f7-9ec3-89bbc266d080/18ac1499-a2e3-4a74-a9f6-987c216e7822/rendition.m3u8?fastly_token=NjMxMmI5MTJfOGMxMjI1YzFlZjcxMTBkYzEwNDI1NTFmNzY4ZWY5MmY2OTkxMDAwOGM0ZmE5MWVhZmE0NGE0MmY3ZDIwYmFmNA%3D%3D")
