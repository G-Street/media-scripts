IGNORE_BASE_PATHS = ("Scripts", "Raw")
MEDIA_TYPES = Dict{String, Symbol}("Movies" => :Film, "Series" => :Series)
FILM_RE = r".*\(\d+\)"

abstract type Media end

struct Film <: Media
    name::String
end

struct Series <: Media
    name::String
end

struct Catalogue
    films::Vector{Film}
    series::Vector{Series}
end

function parse_old_catalogue(contents::Vector{String})
    tmp = Dict{Symbol, Vector{Vector{String}}}(:Film => Vector{String}[], :Series => Vector{String}[])
    
    for path in contents
        path_components = splitpath(path)
        isone(length(path_components)) && continue  # Path is a base bath
        media_type = first(path_components)
        media_type ∈ IGNORE_BASE_PATHS && continue  # Path should be ignored; not part of official media
        push!(tmp[MEDIA_TYPES[media_type]], path_components)
    end
    
    films = Film[]
    for film_raw in tmp[:Film]
        film_name = film_raw[end]
        if occursin(FILM_RE, film_name)
            push!(films, Film(film_name))
        end
    end
    
    series = Series[]
    for series_raw in tmp[:Series]
        series_indiv = Series(series_raw[2])
        if series_indiv ∉ series
            push!(series, series_indiv)
        end
    end

    return Catalogue(films, series)
end

read_old_catalogue(filename::String) = parse_old_catalogue(readlines(filename))

function save_catalogue(out_file::String, catalogue::Catalogue)
    open(out_file, "w") do io
        write(io, "# Films", '\n' ^ 2)
        for film in catalogue.films
            write(io, "  - [ ] ", film.name, '\n')
        end
        write(io, '\n' ^ 2, "# Series", '\n' ^ 2)
        for series in catalogue.series
            write(io, "  - [ ] ", series.name, '\n')
        end
    end
    return out_file
end

function main(cat_loc::String)
    catalogue = read_old_catalogue(cat_loc)
    save_catalogue("old_$(first(splitext(basename(cat_loc)))).md", catalogue)
    return catalogue
end

catalogue = main("/Volumes/NO NAME/media_catalogue_18.04.2021.txt")

