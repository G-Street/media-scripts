# Keep this file in ~/.julia/config/startup.jl

"""
    displaymv(io::IO, src, dst)
    displaymv(src, dest)

Dry run for `mv`.
"""
displaymv(io::IO, f1, f2) = println(io, "$(repr(f1)) -> $(repr(f2))")
displaymv(f1, f2) = displaymv(stdout, f1, f2)

"""
Read the current directory but filter for a given extension.

Will return a vector containing (file name, base name, extension).

If the extension given is nothing, will return this tuple on all elements in the directory.
"""
function _readdir_alt(ext::Union{String, Nothing})
    files = NTuple{3, String}[]
    for f in readdir()
        f_base, f_ext = splitext(f)
        if !isnothing(ext)
            endswith(f_ext, ext) || continue
        end
        push!(files, (f, f_base, f_ext[2:end]))
    end
    return files
end

"""
    readdir_media(; ext = nothing, delim = nothing)

This function will return a vector containing a tuple of `(file name, base name, extension, split parts of the file name)`, of files within the current directory.

The split parts will by default be split by whitespace, however you can provide a new delimiter by which to split.

You can also optionally specify an extension to only filter by certain extensions.

!!! note
    The split component of the returned value will split the file's base name, not the full path.

---

#### Example usages:

    julia> readdir_media()
    julia> readdir_media(ext = "mkv")
    julia> readdir_media(delim = ".")

#### Larger example:

```julia
shell> ls -1
something.txt
something_else.jl
Some.Series.S02E01.720p.mkv
Some.Series.S02E02.720p.mkv
Some.Series.S02E03.720p.mkv

julia> for (f, fb, fe, p) in readdir_media(ext = "mkv", delim = '.')
           f′ = "\$(join(p[1:2], ' ')) - \$(p[3]).\$fe"
           displaymv(f, f′)
           mv(f, f2)
       end
"Some.Series.S02E01.720p.mkv" -> "Some Series - S02E01.mkv"
"Some.Series.S02E02.720p.mkv" -> "Some Series - S02E02.mkv
"Some.Series.S02E03.720p.mkv" -> "Some Series - S02E03.mkv"
```
"""
function readdir_media(; ext = nothing, delim = nothing)
    split_fn = isnothing(delim) ? split : (s -> split(s, delim))
    files = Tuple{String, String, String, Vector{String}}[]
    for (f, f_base, f_ext) in _readdir_alt(ext)
        parts = split_fn(f)
        push!(files, (f, f_base, f_ext, parts))
    end
    return files
end
