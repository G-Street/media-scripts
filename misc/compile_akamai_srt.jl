using HTTP

M3U8_AES_META_RE = r"""#EXT-X-KEY:METHOD=(.*),URI="(.*?)"(,IV=(.*))?"""
SRT_MILISECOND_RE = r"(\d\d).(\d\d\d)"
SRT_TS_RE = r"(\d\d):(\d\d):(\d\d),(\d\d\d)"
SRT_TS_RE_MALFORMED = r"(\d\d:\d\d,\d\d\d)"

function parse_subtitle_segment(url::String, i::Int = 1; encrypted::Bool = false, key::Union{Vector{UInt8}, Nothing} = nothing, iv::Union{UInt128, Nothing} = nothing)
    # Get segment content (encrypted)
    seg_req = HTTP.get(url)
    out_seg = IOBuffer()

    # make temp file to write ciphertext to
    mktemp() do ct_path, ct_io
        write(ct_io, seg_req.body)
        
        # make temp file to write plain text to
        mktemp() do pt_path, pt_io
            _out_file = decrypt_m3u8(ct_path, key, iv, pt_path)
            # seg_buf = IOBuffer(pt_io)
            line_itr = eachline(pt_io)
            
            # discard first three lines (metadata)
            for _ in 1:3
                iterate(line_itr)
            end
            # error("not yet implemented")
            
            # Parse subtitle content
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
                        @assert(occursin(SRT_TS_RE_MALFORMED, line), "Line malformed: \"$line\"")
                        line = replace(line, SRT_TS_RE_MALFORMED => s"00:\1")
                        @assert(occursin(SRT_TS_RE, line), "Line malformed: \"$line\"")
                    end
                end
                println(out_seg, line)
            end
        end
    end
    return take!(out_seg), i
end

# gist.github.com/refractalize/1561849
function decrypt_m3u8(in_file::String, key::Vector{UInt8}, iv::UInt128, out_file::String)
    key_hex = bytes2hex(key)
    iv_hex = string(iv, pad = sizeof(iv)<<1, base = 16)
    cmd = Cmd(`openssl aes-128-cbc -d -K $key_hex -iv $iv_hex -nosalt -in $in_file -out $out_file`)
    run(cmd)
    return out_file
end

function main(segment_url::String; encrypted::Bool = false)
    @info("Obtaining subtitle segment URLs from \"$segment_url\"")
    segment_urls_req = HTTP.get(segment_url)
    segment_itr = eachline(IOBuffer(segment_urls_req.body))
    i = 1
    key, iv = nothing, nothing
    open("main.srt", "w") do out_io
        for segment_url_line in segment_itr
            if encrypted && occursin(M3U8_AES_META_RE, segment_url_line)
                m = match(M3U8_AES_META_RE, segment_url_line)
                method = m.captures[1]
                @assert(method == "AES-128", "Cannot decrypt method \"$method\"")
                key_uri = m.captures[2]
                key = HTTP.get(key_uri).body
                @info("Found key for decryption: $(bytes2hex(key))")
                if length(m.captures) > 3
                    iv = parse(UInt128, m.captures[4])
                    @info("Found initialisation vector for AES decryption: $(m.captures[4])")
                end
            end
            startswith(segment_url_line, '#') && continue
            isempty(strip(segment_url_line)) && continue
            @info("Parsing URL \"$segment_url_line\"")
            sub_seg, i = parse_subtitle_segment(segment_url_line, i; encrypted = encrypted, key = key, iv = iv)
            write(out_io, sub_seg)
        end
    end
    
    return "main.srt"
end

# main("https://manifest.prod.boltdns.net/manifest/v1/hls/v4/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/c27df393-f12f-4e6c-94f3-fef10c28f39f/10s/rendition.m3u8?fastly_token=NjMxMmMzZWZfZTgyODlhOTc1Yzc4YzkzYmIyYzRmMjhmNDkyNDM2YWMzNDJhNGYwYWFkZDdkMTEyYWMyM2Y3YjY1MzVjYmQyNg%3D%3D")
main("https://manifest.prod.boltdns.net/manifest/v1/hls/v4/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/16b434bb-adb4-4297-be03-0bf7ef7902d7/10s/rendition.m3u8?fastly_token=NjMxMmMzZWZfNWE0NmRhYjRjMThhYjllYjBmODkyMTQzMGU5ZWJiMjI4NDQxM2ViZTExNzYwM2NlOTU1ZTRkMjY5N2U0ZjA2MA%3D%3D", encrypted = true)
#=
#EXT-X-KEY:METHOD=AES-128,URI="https://manifest.prod.boltdns.net/license/v1/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/b0394c73-bc83-414e-9cfe-04a15a098d7c?fastly_token=NjMxMmQ4NGZfMGNkMGZkNTM1MDY4MzA1ODJiZDgwZmFiNzRlNzZjMDA5M2EyM2UzNWRlMzA1ZTE1NGM4YzIzZjU4MDRlNTY3NQ%3D%3D",IV=0xae6328c329689918fb53f3f2fcbd1c89

julia> kuri
"https://manifest.prod.boltdns.net/license/v1/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/b0394c73-bc83-414e-9cfe-04a15a098d7c?fastly_token=NjMxMmQ4NGZfMGNkMGZkNTM1MDY4MzA1ODJiZDgwZmFiNzRlNzZjMDA5M2EyM2UzNWRlMzA1ZTE1NGM4YzIzZjU4MDRlNTY3NQ%3D%3D"

julia> iv
0xae6328c329689918fb53f3f2fcbd1c89

julia> buri
"https://bcbolta98cc749-a.akamaihd.net/media/v1/hls/v4/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/c27df393-f12f-4e6c-94f3-fef10c28f39f/b0394c73-bc83-414e-9cfe-04a15a098d7c/5x/segment0.ts?akamai_token=exp=1662179407~acl=/media/v1/hls/v4/aes128/6093072280001/fa624b7f-ed55-41a9-b143-78f86dd5d579/c27df393-f12f-4e6c-94f3-fef10c28f39f/b0394c73-bc83-414e-9cfe-04a15a098d7c/*~hmac=3c6340353d77acd9f6bca83a89200fcad1079c12589cde6e2f16f201a3427f87"

julia> key = bytes2hex(HTTP.get(kuri).body)
julia> open("temp", "w") do io
           write(io, HTTP.get(buri).body)
       end
julia> iv_hex = string(iv, pad = sizeof(iv)<<1, base = 16)
julia> cmd = Cmd(`openssl aes-128-cbc -d -K $key -iv $iv_hex -nosalt -in temp -out temp-out`)
=#
