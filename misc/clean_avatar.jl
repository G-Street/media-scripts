# Script written by J.
# Saturday, 23rd July, 2022
# 
# Link: bWFnbmV0Oj94dD11cm46YnRpaDpkOWQ5MDZiMzkxMmMyNTRiNGY2MzY4ZDQxOWZiNjNjOWYzNzIwNGVmJmRuPUF2YXRhci5UaGUuTGFzdC5BaXJiZW5kZXIuUzAxLVMwMy5DT01QTEVURS4xMDgwcC5CbHVSYXkuOGJpdC54MjY1LkhFVkMuQUFDMi4wLVNhbHRCYWUmdHI9dWRwJTNhJTJmJTJmOS5yYXJiZy5tZSUzYTI5MzAlMmZhbm5vdW5jZSZ0cj11ZHAlM2ElMmYlMmY5LnJhcmJnLnRvJTNhMjc4MCUyZmFubm91bmNlJnRyPXVkcCUzYSUyZiUyZnRyYWNrZXIub3BlbnRyYWNrci5vcmclM2ExMzM3JTJmYW5ub3VuY2UmdHI9dWRwJTNhJTJmJTJmdHJhY2tlci56ZXIwZGF5LnRvJTNhMTMzNyUyZmFubm91bmNlJnRyPXVkcCUzYSUyZiUyZnRyYWNrZXIudGhpbmVsZXBoYW50Lm9yZyUzYTEzNzkwJnRyPXVkcCUzYSUyZiUyZnRyYWNrZXIudGFsbHBlbmd1aW4ub3JnJTNhMTU3OTAmdHI9aHR0cCUzYSUyZiUyZnRyYWNrZXIub3BlbmJpdHRvcnJlbnQuY29tJTNhODAlMmZhbm5vdW5jZSZ0cj11ZHAlM2ElMmYlMmZvcGVudHJhY2tlci5pMnAucm9ja3MlM2E2OTY5JTJmYW5ub3VuY2UmdHI9dWRwJTNhJTJmJTJmdHJhY2tlci5pbnRlcm5ldHdhcnJpb3JzLm5ldCUzYTEzMzclMmZhbm5vdW5jZSZ0cj11ZHAlM2ElMmYlMmZ0cmFja2VyLmxlZWNoZXJzLXBhcmFkaXNlLm9yZyUzYTY5NjklMmZhbm5vdW5jZSZ0cj11ZHAlM2ElMmYlMmZjb3BwZXJzdXJmZXIudGslM2E2OTY5JTJmYW5ub3VuY2U=
# 
# Usage:
# julia clean_avatar.jl
# 
# Notes:
# Ensure you have [ReadableRegex.jl](https://github.com/jkrumbiegel/ReadableRegex.jl) installed.
#

using ReadableRegex

function split_keep_delim(string, splitter)
    r = Regex(
        either(
            look_for("", before = splitter),
            look_for("", after = splitter)
        )
    )
    return split(string, r)
end

function cleanname(f::String, stypes::Union{String, Nothing}...)
    info = split(f, " - ")
    _, ext = splitext(f)
    ep_name = info[4]
    ep_name = replace(ep_name, r"(Chapter\s[a-zA-Z\-]+)\s(.*)" => s"\1 - \2")
    if occursin(r"Part\s\d", ep_name)
        # ep_name = replace(ep_name, r"(Part\s\d)(.*)" => s"\1 - \2")
        ep_name_part_components = split_keep_delim(ep_name, rs"Part\s\d")
        ep_name_part_components = strip.(ep_name_part_components)
        ep_name = join(ep_name_part_components, " - ")
    end
    stypes_joined = isempty(stypes) ? "" : "."
    stypes_joined *= join(stypes, '.')
    return "Avatar - The Last Airbender - $(info[3]) - $(ep_name)$stypes_joined$ext"
end

displaymv(f1, f2) = println("\"$f1\" -> \"$f2\""); 

function main()
    for d in readdir()
        isdir(d) || continue
        cd(d) do
            for f in readdir()
                isfile(f) || continue
                f2 = cleanname(f)
                displaymv(f, f2)
                mv(f, f2)
            end
            cd("Subs") do
                for d′ in readdir()
                    isdir(d′) || continue
                    for f′ in readdir(d′)
                        f2′ = cleanname(f′, (d′ == "sdh" ? ("en", d′) : (d′,))...)
                        f′, f2′ = "$d′/$f′", "../$f2′"
                        displaymv(f′, f2′)
                        mv(f′, f2′)
                    end
                end
            end
        end
    end
end

main()
