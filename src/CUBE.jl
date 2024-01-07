module CUBE
export CubeFile

using Unitful
using UnitfulAtomic
using StaticArrays
using AtomsBase
using Printf

const Vec3{T} = SVector{3, T} where {T}

struct CubeFile{N, U, T, S <: AbstractSystem}
    comment::String
    origin::Vec3{T}
    unit_voxel::Vector{Vec3{T}}
    system::S
    data::Array{U, N}
end

function read(filename::AbstractString)
    T = Float64
    lines = readlines(filename)  # TODO Be a bit more clever. cube files can be huge

    # First two lines are comment
    comment = strip(lines[1]) * "\n" * strip(lines[2])

    # Line 3 is number of atoms and centre
    line3 = split(lines[3])
    @assert length(line3) in (4, 5)
    n_atoms = parse(Int, line3[1])
    n_components = length(line3) == 4 ? 1 : parse(Int, line3[5])

    # Lines 4-6 is number of voxels and delta vectors (side of the voxels)
    # Note that voxels may be be non-cubic.
    line_x = split(lines[4])
    line_y = split(lines[5])
    line_z = split(lines[6])
    @assert length(line_x) == length(line_y) == length(line_z) == 4

    n_voxels = (parse(Int, line_x[1]), parse(Int, line_y[1]), parse(Int, line_z[1]))
    n_v_sign = sign(n_voxels[1])
    length_unit = n_v_sign > 0 ? u"bohr" : u"Å"
    if !all(isequal(n_v_sign), sign.(n_voxels))
        @warn "Signs of n_voxel not all the same, assuming the unit is $length_unit"
    end
    unit_voxel = Vec3.([parse.(T, line_x[2:4]),
                        parse.(T, line_y[2:4]),
                        parse.(T, line_z[2:4])]) * length_unit
    origin = Vec3(parse.(T, line3[2:4])) * length_unit

    # Next section is the list of atoms
    atoms = map(lines[7:6+n_atoms]) do line
        sline = split(line)
        @assert length(sline) == 5
        Atom(parse(Int, sline[1]), parse.(T, sline[3:5]) * length_unit;
             charge=parse(T, sline[2]))
    end
    system = isolated_system(atoms)

    # First read stream of data just as a linear vector:
    data = T[]
    for line in lines[7+n_atoms:end]
        append!(data, parse.(T, split(line)))
    end
    data = reshape(data, abs.(n_voxels)..., n_components)  # Data in file is column-major

    CubeFile(comment, origin, unit_voxel, system, data)
end

function save(io::IO, cube::CubeFile)
    @assert ndims(cube.data) ≥ 3
    n_voxels     = size(cube.data)[1:3]
    n_components = size(cube.data, 4)

    # Lines 1-3
    origin = austrip.(cube.origin)
    println(io, join(split(cube.comment, "\n")[1:2], "\n"))
    @printf(io, "%5d %12.6f %12.6f %12.6f %5d\n",
            length(cube.system), origin[1], origin[2], origin[3], n_components)

    # Lines 4-6
    for i in 1:3
        voxi = austrip.(cube.unit_voxel[i])
        @printf(io, "%5d %12.6f %12.6f %12.6f\n",
                n_voxels[i], voxi[1], voxi[2], voxi[3])
    end

    # Atoms
    for atom in cube.system
        pos = austrip.(position(atom))
        @printf(io, "%5d %12.6f %12.6f %12.6f %12.6f\n",
                atomic_number(atom), atom[:charge], pos[1], pos[2], pos[3])
    end

    # Data
    for (i, d) in enumerate(cube.data)
        @printf(io, " %12.5e", d)
        mod1(i, 6) == 6 && println(io)
    end
end
function save(filename::AbstractString, cube::CubeFile)
    open(filename, "w") do fp
        save(fp, cube)
    end
end

end
